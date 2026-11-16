import 'package:blockchain_utils_connector/src/bytes/bytes.dart';
import 'package:blockchain_utils_connector/src/error/bu_error.dart';

/// BLS12-381 Groth16 + BN254 + Sapling verify API (official VK path).
abstract interface class BuGroth16Api {
  /// Generic BLS12 Groth16 verify (Zcash proof layout: 192-byte compressed).
  BuResult<void> verifyBls({
    required BuBytes proof,
    required BuBytes vk,
    required BuBytes publicInputs,
  });

  /// BN254 Groth16 verify (Sui/Aptos layout: 256-byte uncompressed,
  /// public inputs big-endian).
  BuResult<void> verifyBn254({
    required BuBytes proof,
    required BuBytes vk,
    required BuBytes publicInputs,
  });

  /// Expected BLS proof length (192).
  int get blsProofLen;

  /// Expected BN254 proof length (256).
  int get bn254ProofLen;

  /// Sapling Spend: [publicInputs] = 7×32 LE Fr (cv‖rk‖rt‖nf).
  BuResult<void> verifySpend({
    required BuBytes proof,
    required BuBytes vk,
    required BuBytes publicInputs,
  });

  /// Sapling Output: [publicInputs] = 5×32 LE Fr.
  BuResult<void> verifyOutput({
    required BuBytes proof,
    required BuBytes vk,
    required BuBytes publicInputs,
  });
}
