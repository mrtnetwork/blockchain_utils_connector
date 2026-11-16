import 'package:blockchain_utils_connector/src/bytes/bytes.dart';
import 'package:blockchain_utils_connector/src/error/bu_error.dart';
import 'package:blockchain_utils_connector/src/platform/bindings.dart';
import 'package:blockchain_utils_connector/src/hash/hash.dart';

/// Token wiped/freed by [_finalizer] when a [BuNativeHash] is GC'd without
/// [BuNativeHash.clean]. Holds only the platform bindings + the opaque
/// native handle — never the owner — so the callback cannot resurrect it.
class _HashFinalizerToken {
  _HashFinalizerToken(this.bindings, this.handle);

  final BuPlatformBindings bindings;
  final Object handle;

  void clean() {
    try {
      bindings.hashClean(handle);
    } catch (_) {
      // Best-effort: the native allocation may already be gone.
    }
    try {
      bindings.hashFree(handle);
    } catch (_) {
      // Freed twice (explicit clean raced GC) — ignore.
    }
  }
}

/// Token freeing a saved snapshot ([BuNativeHash.saveState]) when it is
/// GC'd without [BuNativeHash.cleanSavedState]. Owns only the bindings, the
/// snapshot handle, and the global live-set it unregisters from — never the
/// owner (holding the owner would pin it and the finalizer would never fire).
class _HashStateToken {
  _HashStateToken(this.bindings, this.state, this.live);

  final BuPlatformBindings bindings;
  final Object state;

  /// All currently live snapshot handles, across every hash context: the
  /// arbiter that guarantees exactly one path ever frees a handle (snapshots
  /// are portable values — any context may restore a live one).
  final Set<Object> live;

  void free() {
    // Whoever unregisters first wins the right to free: exactly one path
    // (explicit free, parent clean, or this callback) ever frees a handle.
    if (!live.remove(state)) {
      return;
    }
    try {
      bindings.hashFreeState(state);
    } catch (_) {
      // Best-effort: already freed explicitly.
    }
  }
}

/// Native hash context: streaming `update` / `finish` over a Rust (FFI) or
/// wasm-bindgen (web) allocation.
///
/// Lifecycle: [clean] releases the native allocation **and** marks this
/// wrapper unusable (further calls throw [BuError.invalidState]).
/// Forgetting [clean] still frees the allocation via a [Finalizer] safety
/// net (GC timing, best-effort) — but explicit [clean] is deterministic and
/// preferred, especially for long-lived contexts. [clean] is idempotent.
class BuNativeHash implements BuSerializableHash, SecretState {
  BuNativeHash._(
    this._b,
    this._handle,
    this._digestLen,
    this._blockSize,
    this._algo,
  ) {
    _finalizer.attach(this, _HashFinalizerToken(_b, _handle), detach: this);
  }

  /// Safety net: `hashClean + hashFree` when GC'd without [clean].
  static final Finalizer<_HashFinalizerToken> _finalizer = Finalizer(
    (token) => token.clean(),
  );

  /// Safety net: `hashFreeState` for snapshots GC'd without
  /// [cleanSavedState].
  static final Finalizer<_HashStateToken> _stateFinalizer = Finalizer(
    (token) => token.free(),
  );

  static BuResult<BuNativeHash> create(
    BuPlatformBindings bindings,
    BuHashNativeConfig config,
  ) {
    try {
      final h = bindings.hashNew(config);
      return BuResult.ok(
        BuNativeHash._(
          bindings,
          h,
          bindings.hashDigestLen(h),
          bindings.hashBlockSize(h),
          config.algo,
        ),
      );
    } catch (_) {
      return BuResult.err(BuError.unsupported);
    }
  }

  final BuPlatformBindings _b;
  final Object _handle;
  final int _digestLen;
  final int _blockSize;
  final int _algo;
  bool _cleaned = false;

  /// All currently live snapshot handles, across every hash context.
  /// Authorization set for [restoreState]/[cleanSavedState] and the state
  /// [Finalizer]: a handle is freed by exactly one path, while any context
  /// may restore a live snapshot (snapshots are independent, portable
  /// values — they outlive the context that minted them).
  static final Set<Object> _liveStates = {};

  void _ensure() {
    if (_cleaned) {
      throw BuError.invalidState;
    }
  }

  bool get isShake =>
      _algo == BuHashAlgo.shake128 || _algo == BuHashAlgo.shake256;

  @override
  int get getDigestLength => _digestLen;
  @override
  int get getBlockSize => _blockSize;

  @override
  BuHash update(List<int> data) {
    _ensure();
    final bytes = BuBytes.from(data);
    _b.hashUpdate(_handle, bytes);
    return this;
  }

  @override
  BuHash reset() {
    _ensure();
    _b.hashReset(_handle);
    return this;
  }

  @override
  BuHash finish(List<int> out) {
    _ensure();
    if (!isShake && out.length < _digestLen) {
      throw BuError.bufferTooSmall;
    }
    if (isShake && out.isEmpty) {
      throw BuError.invalidLength;
    }
    final o = BuBytes.from(out);
    _b.hashFinish(_handle, o);
    return this;
  }

  @override
  BuBytes digest() {
    _ensure();
    final out = BuBytes.zero(_digestLen == 0 ? 32 : _digestLen);
    _b.hashFinish(_handle, out);
    return out;
  }

  /// Releases the native allocation. Idempotent; detaches the [Finalizer]
  /// so GC never double-frees. Snapshots minted by [saveState] are
  /// independent allocations: they stay live (and restorable) after this
  /// returns; each is freed by its own [cleanSavedState] or, forgotten,
  /// by the state [Finalizer].
  @override
  void clean() {
    if (_cleaned) {
      return;
    }
    _cleaned = true;
    _finalizer.detach(this);
    try {
      _b.hashClean(_handle);
    } finally {
      _b.hashFree(_handle);
    }
  }

  /// Alias of [clean] for the [SecretState] disposal contract.
  @override
  void dispose() => clean();

  /// Snapshots the current state. Snapshots are independent, portable
  /// values: any live context may [restoreState] them, including after the
  /// minting context was cleaned. Restoring after [cleanSavedState] throws
  /// [BuError.invalidState] instead of touching freed native memory.
  @override
  BuHashState saveState() {
    _ensure();
    final saved = BuHashState(_b.hashSaveState(_handle));
    _liveStates.add(saved.handle);
    _stateFinalizer.attach(
      saved,
      _HashStateToken(_b, saved.handle, _liveStates),
      detach: saved,
    );
    return saved;
  }

  /// Restores a live snapshot minted by [saveState] (any context).
  @override
  BuSerializableHash restoreState(BuHashState saved) {
    _ensure();
    if (!_liveStates.contains(saved.handle)) {
      throw BuError.invalidState;
    }
    _b.hashRestoreState(_handle, saved.handle);
    return this;
  }

  /// Releases a snapshot. Idempotent; detaches the state [Finalizer] so GC
  /// never double-frees.
  @override
  void cleanSavedState(BuHashState saved) {
    if (!_liveStates.remove(saved.handle)) {
      return;
    }
    _stateFinalizer.detach(saved);
    _b.hashFreeState(saved.handle);
  }
}
