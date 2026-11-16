import 'package:blockchain_utils_connector/src/api/groth16_api.dart';
import 'package:blockchain_utils_connector/src/bytes/bytes.dart';
import 'package:blockchain_utils_connector/src/error/bu_error.dart';
import 'package:blockchain_utils_connector/src/platform/bindings.dart';

class DefaultGroth16Api implements BuGroth16Api {
  DefaultGroth16Api(this._b);
  final BuPlatformBindings _b;
  static const _tag = 'Groth16';

  BuResult<void> _map(int rc, String op) {
    if (rc == 0) {
      return BuResult.ok(null);
    }
    final code = switch (rc) {
      1 => DefaultErrorType.nullPointer,
      2 => DefaultErrorType.invalidLength,
      3 => DefaultErrorType.invalidPoint,
      4 => DefaultErrorType.invalidLength,
      5 => DefaultErrorType.cryptoVerifyFailed,
      _ => DefaultErrorType.unsupported,
    };
    return BuResult.err(BuError(code, '$_tag.$op'));
  }

  @override
  BuResult<void> verifyBls({
    required BuBytes proof,
    required BuBytes vk,
    required BuBytes publicInputs,
  }) => _map(
    _b.groth16VerifyBls(proof: proof, vk: vk, publicInputs: publicInputs),
    'verifyBls',
  );

  @override
  BuResult<void> verifyBn254({
    required BuBytes proof,
    required BuBytes vk,
    required BuBytes publicInputs,
  }) => _map(
    _b.groth16VerifyBn254(proof: proof, vk: vk, publicInputs: publicInputs),
    'verifyBn254',
  );

  @override
  int get blsProofLen => _b.groth16BlsProofLen();

  @override
  int get bn254ProofLen => _b.groth16Bn254ProofLen();

  @override
  BuResult<void> verifySpend({
    required BuBytes proof,
    required BuBytes vk,
    required BuBytes publicInputs,
  }) {
    if (publicInputs.length != 7 * 32) {
      return BuResult.err(
        BuError(
          DefaultErrorType.invalidLength,
          '$_tag.verifySpend: expected 224 public input bytes',
        ),
      );
    }
    return _map(
      _b.saplingVerifySpend(proof: proof, vk: vk, publicInputs: publicInputs),
      'verifySpend',
    );
  }

  @override
  BuResult<void> verifyOutput({
    required BuBytes proof,
    required BuBytes vk,
    required BuBytes publicInputs,
  }) {
    if (publicInputs.length != 5 * 32) {
      return BuResult.err(
        BuError(
          DefaultErrorType.invalidLength,
          '$_tag.verifyOutput: expected 160 public input bytes',
        ),
      );
    }
    return _map(
      _b.saplingVerifyOutput(proof: proof, vk: vk, publicInputs: publicInputs),
      'verifyOutput',
    );
  }
}
