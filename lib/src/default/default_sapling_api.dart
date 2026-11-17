import 'package:blockchain_utils_connector/src/api/sapling_api.dart';
import 'package:blockchain_utils_connector/src/bytes/bytes.dart';
import 'package:blockchain_utils_connector/src/error/bu_error.dart';
import 'package:blockchain_utils_connector/src/platform/bindings.dart';

/// Sapling ceremony params with a finalizer safety net.
///
/// A raw params handle (`Pointer` on FFI, `int` on WASM) cannot own a
/// [Finalizer] itself — finalization rejects numbers and FFI pointers — so
/// [DefaultSaplingApi.setSpendParams]/[setOutputParams] hand out this wrapper
/// as the opaque `Object` handle. Existing `prove`/`verify`/`paramsFree`
/// call sites keep working unchanged: wrappers are unwrapped (with a
/// use-after-free guard) and any other `Object` passes straight through.
///
/// Forgetting [free]/[paramsFree] still releases natively on GC
/// (best-effort); double-free and use-after-free surface as [BuError],
/// never a native crash.
class BuSaplingParams {
  BuSaplingParams._(this._b, this._handle) {
    _finalizer.attach(this, _SaplingParamsToken(_b, _handle), detach: this);
  }

  /// Safety net: `saplingParamsFree` when GC'd without [free].
  static final Finalizer<_SaplingParamsToken> _finalizer = Finalizer(
    (token) => token.free(),
  );

  final BuPlatformBindings _b;
  final Object _handle;
  bool _freed = false;

  /// Releases the params. Idempotent; detaches the [Finalizer].
  void free() {
    if (_freed) {
      return;
    }
    _freed = true;
    _finalizer.detach(this);
    _b.saplingParamsFree(_handle);
  }
}

/// Finalizer token for [BuSaplingParams]: owns only the bindings + opaque
/// handle — never the owner — so the callback cannot resurrect the params.
class _SaplingParamsToken {
  _SaplingParamsToken(this.bindings, this.handle);

  final BuPlatformBindings bindings;
  final Object handle;

  void free() {
    try {
      bindings.saplingParamsFree(handle);
    } catch (_) {
      // Best-effort: already freed explicitly.
    }
  }
}

class DefaultSaplingApi implements BuSaplingApi {
  DefaultSaplingApi(this._b);
  final BuPlatformBindings _b;
  static BuError _map(int rc) => BuError.fromNativeCode(switch (rc) {
    0 => 7, // unreachable: callers check rc != 0 first
    1 => 1,
    2 => 4,
    3 => 10,
    4 => 7,
    5 => 5,
    6 => 7,
    7 => 10,
    _ => rc,
  });

  int _witnessLen(int kind) => switch (kind) {
    BuSaplingApi.spend => BuSaplingApi.spendWitnessLen,
    BuSaplingApi.output => BuSaplingApi.outputWitnessLen,
    _ => -1,
  };

  int _inputsLen(int kind) => switch (kind) {
    BuSaplingApi.spend => BuSaplingApi.spendInputsLen,
    BuSaplingApi.output => BuSaplingApi.outputInputsLen,
    _ => -1,
  };

  BuBytes _as(List<int> x) => BuBytes.from(x);

  /// Unwraps a [BuSaplingParams] handle (fail-closed after [BuSaplingParams.free]).
  /// Any other `Object` is a raw/legacy handle and passes straight through.
  static Object _raw(Object handle) {
    if (handle is BuSaplingParams) {
      if (handle._freed) {
        throw BuError.invalidState;
      }
      return handle._handle;
    }
    return handle;
  }

  @override
  BuResult<Object> setSpendParams({required List<int> params}) {
    if (params.isEmpty) {
      return BuResult.err(BuError.invalidArgument);
    }
    final out = <Object?>[null];
    final rc = _b.saplingSetSpendParams(_as(params), out);
    if (rc != 0 || out[0] == null) {
      return BuResult.err(_map(rc));
    }
    return BuResult.ok(BuSaplingParams._(_b, out[0]!));
  }

  @override
  BuResult<Object> setOutputParams({required List<int> params}) {
    if (params.isEmpty) {
      return BuResult.err(BuError.invalidArgument);
    }
    final out = <Object?>[null];
    final rc = _b.saplingSetOutputParams(_as(params), out);
    if (rc != 0 || out[0] == null) {
      return BuResult.err(_map(rc));
    }
    return BuResult.ok(BuSaplingParams._(_b, out[0]!));
  }

  @override
  void paramsFree(Object handle) {
    if (handle is BuSaplingParams) {
      handle.free();
      return;
    }
    _b.saplingParamsFree(handle);
  }

  @override
  BuResult<BuSaplingProof> prove({
    required Object handle,
    required int kind,
    required List<int> witness,
  }) {
    final Object h;
    try {
      h = _raw(handle);
    } on BuError catch (e) {
      return BuResult.err(e);
    }
    final need = _witnessLen(kind);
    if (need < 0) {
      return BuResult.err(BuError.invalidArgument);
    }
    if (witness.length < need) {
      return BuResult.err(
        BuError.length(what: 'witness', expected: need, actual: witness.length),
      );
    }
    final inLen = _inputsLen(kind);
    final proof = BuBytes.zero(BuSaplingApi.proofLen);
    final inputs = BuBytes.zero(inLen);
    final rc = _b.saplingProve(h, kind, _as(witness), proof, inputs);
    if (rc != 0) {
      return BuResult.err(_map(rc));
    }
    return BuResult.ok(BuSaplingProof(proof: proof, inputs: inputs));
  }

  @override
  BuResult<void> verify({
    required Object handle,
    required int kind,
    required BuBytes proof,
    required BuBytes inputs,
  }) {
    final Object h;
    try {
      h = _raw(handle);
    } on BuError catch (e) {
      return BuResult.err(e);
    }
    final inLen = _inputsLen(kind);
    if (inLen < 0) {
      return BuResult.err(BuError.invalidArgument);
    }
    if (proof.length != BuSaplingApi.proofLen) {
      return BuResult.err(
        BuError.length(
          what: 'proof',
          expected: BuSaplingApi.proofLen,
          actual: proof.length,
        ),
      );
    }
    if (inputs.length != inLen) {
      return BuResult.err(
        BuError.length(what: 'inputs', expected: inLen, actual: inputs.length),
      );
    }
    final rc = _b.saplingVerify(
      handle: h,
      kind: kind,
      proof: proof,
      inputs: inputs,
    );
    if (rc != 0) {
      return BuResult.err(_map(rc));
    }
    return BuResult.ok(null);
  }
}
