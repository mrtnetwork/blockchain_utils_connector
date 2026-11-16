import 'package:blockchain_utils_connector/src/bytes/bytes.dart';
import 'package:blockchain_utils_connector/src/error/bu_error.dart';
import 'package:blockchain_utils_connector/src/platform/bindings.dart';

/// Merlin transcript handle.
///
/// Explicit [clean] releases the native allocation; forgetting it still
/// frees via a [Finalizer] safety net (GC timing, best-effort). Mirrors
/// `bu_merlin_*` (FFI) and `merlin*` (WASM).
class BuMerlin implements SecretState {
  BuMerlin._(this._b, this._handle) {
    _finalizer.attach(this, _MerlinToken(_b, _handle), detach: this);
  }

  /// Opens a Merlin transcript over [label].
  static BuResult<BuMerlin> open(
    BuPlatformBindings bindings, {
    required List<int> label,
  }) {
    try {
      return BuResult.ok(
        BuMerlin._(bindings, bindings.merlinNew(BuBytes.from(label))),
      );
    } on BuError catch (e) {
      return BuResult.err(e);
    } catch (_) {
      return BuResult.err(BuError.internal);
    }
  }

  /// Safety net: `merlinFree` when GC'd without [clean].
  static final Finalizer<_MerlinToken> _finalizer = Finalizer(
    (token) => token.free(),
  );

  final BuPlatformBindings _b;
  final Object _handle;
  bool _freed = false;

  void _ensure() {
    if (_freed) {
      throw BuError.invalidState;
    }
  }

  /// `append_message(label, message)`.
  void append({required List<int> label, required List<int> message}) {
    _ensure();
    _b.merlinAppend(_handle, BuBytes.from(label), BuBytes.from(message));
  }

  /// `challenge_bytes(label)` — [length] bytes.
  BuBytes challenge({required List<int> label, required int length}) {
    _ensure();
    if (length <= 0) {
      throw BuError.invalidLength;
    }
    final out = BuBytes.zero(length);
    _b.merlinChallenge(_handle, BuBytes.from(label), out);
    return out;
  }

  /// Fork into an independent transcript with identical state.
  BuMerlin fork() {
    _ensure();
    return BuMerlin._(_b, _b.merlinFork(_handle));
  }

  /// Releases the native handle. Idempotent; detaches the [Finalizer].
  void clean() {
    if (_freed) {
      return;
    }
    _freed = true;
    _finalizer.detach(this);
    _b.merlinFree(_handle);
  }

  /// Alias of [clean] for the [SecretState] disposal contract.
  @override
  void dispose() => clean();
}

/// Finalizer token for [BuMerlin]: owns only the bindings + opaque handle.
class _MerlinToken {
  _MerlinToken(this.bindings, this.handle);

  final BuPlatformBindings bindings;
  final Object handle;

  void free() {
    try {
      bindings.merlinFree(handle);
    } catch (_) {
      // Best-effort: already freed explicitly.
    }
  }
}

/// Strobe-128 context handle.
///
/// Explicit [clean] releases the native allocation; forgetting it still
/// frees via a [Finalizer] safety net (GC timing, best-effort). Mirrors
/// `bu_strobe_*` (FFI) and `strobe*` (WASM).
class BuStrobe implements SecretState {
  BuStrobe._(this._b, this._handle) {
    _finalizer.attach(this, _StrobeToken(_b, _handle), detach: this);
  }

  /// Opens a Strobe-128 context over [protocol].
  static BuResult<BuStrobe> open(
    BuPlatformBindings bindings, {
    required List<int> protocol,
  }) {
    try {
      return BuResult.ok(
        BuStrobe._(bindings, bindings.strobeNew(BuBytes.from(protocol))),
      );
    } on BuError catch (e) {
      return BuResult.err(e);
    } catch (_) {
      return BuResult.err(BuError.internal);
    }
  }

  /// Safety net: `strobeFree` when GC'd without [clean].
  static final Finalizer<_StrobeToken> _finalizer = Finalizer(
    (token) => token.free(),
  );

  final BuPlatformBindings _b;
  final Object _handle;
  bool _freed = false;

  void _ensure() {
    if (_freed) {
      throw BuError.invalidState;
    }
  }

  /// `key(data)` ratchet.
  void key(List<int> data) {
    _ensure();
    _b.strobeKey(_handle, BuBytes.from(data));
  }

  /// `ad(data)` (`meta` selects meta-AD).
  void ad(List<int> data, {bool meta = false}) {
    _ensure();
    _b.strobeAd(_handle, meta, BuBytes.from(data));
  }

  /// `prf` — [length] bytes.
  BuBytes prf(int length) {
    _ensure();
    if (length <= 0) {
      throw BuError.invalidLength;
    }
    final out = BuBytes.zero(length);
    _b.strobePrf(_handle, out);
    return out;
  }

  /// Releases the native handle. Idempotent; detaches the [Finalizer].
  void clean() {
    if (_freed) {
      return;
    }
    _freed = true;
    _finalizer.detach(this);
    _b.strobeFree(_handle);
  }

  /// Alias of [clean] for the [SecretState] disposal contract.
  @override
  void dispose() => clean();
}

/// Finalizer token for [BuStrobe]: owns only the bindings + opaque handle.
class _StrobeToken {
  _StrobeToken(this.bindings, this.handle);

  final BuPlatformBindings bindings;
  final Object handle;

  void free() {
    try {
      bindings.strobeFree(handle);
    } catch (_) {
      // Best-effort: already freed explicitly.
    }
  }
}

/// Transcripts entry point: Merlin transcripts + Strobe contexts.
///
/// Both backends implement the same transcript semantics (STROBE-128,
/// Merlin over the same core), so transcripts agree byte-for-byte across
/// FFI and WASM given identical inputs.
abstract interface class BuTranscriptApi {
  /// Open a Merlin transcript over [label].
  BuResult<BuMerlin> merlin({required List<int> label});

  /// Open a Strobe-128 context over [protocol].
  BuResult<BuStrobe> strobe({required List<int> protocol});
}
