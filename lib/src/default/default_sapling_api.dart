import 'package:blockchain_utils_connector/src/api/sapling_api.dart';
import 'package:blockchain_utils_connector/src/bytes/bytes.dart';
import 'package:blockchain_utils_connector/src/error/bu_error.dart';
import 'package:blockchain_utils_connector/src/platform/bindings.dart';

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
    return BuResult.ok(out[0]!);
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
    return BuResult.ok(out[0]!);
  }

  @override
  void paramsFree(Object handle) => _b.saplingParamsFree(handle);

  @override
  BuResult<BuSaplingProof> prove({
    required Object handle,
    required int kind,
    required List<int> witness,
  }) {
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
    final rc = _b.saplingProve(handle, kind, _as(witness), proof, inputs);
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
      handle: handle,
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
