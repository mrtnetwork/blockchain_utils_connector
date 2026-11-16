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
  /// so GC never double-frees.
  @override
  void clean() {
    if (_cleaned) {
      return;
    }
    _cleaned = true;
    _finalizer.detach(this);
    _b.hashClean(_handle);
    _b.hashFree(_handle);
  }

  /// Alias of [clean] for the [SecretState] disposal contract.
  @override
  void dispose() => clean();

  @override
  BuHashState saveState() {
    _ensure();
    return BuHashState(_b.hashSaveState(_handle));
  }

  @override
  BuSerializableHash restoreState(BuHashState saved) {
    _ensure();
    _b.hashRestoreState(_handle, saved.handle);
    return this;
  }

  @override
  void cleanSavedState(BuHashState saved) {
    _b.hashFreeState(saved.handle);
  }
}
