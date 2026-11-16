import 'package:blockchain_utils_connector/src/bytes/bytes.dart';
import 'package:blockchain_utils_connector/src/error/bu_error.dart';

/// Sapling Groth16 prove/verify under loaded ceremony parameters.
///
/// Packed witness blobs (little-endian, mirror Rust `ffi::sapling` docs):
/// - spend ([spendWitnessLen]B): value_u64 | randomness | ak | nsk | g_d |
///   commitment_randomness | ar | auth_path[32][32] | pos[32] (bytes 0/1) |
///   anchor
/// - output ([outputWitnessLen]B): value_u64 | randomness | g_d | pk_d |
///   commitment_randomness | esk
///
/// Prove randomness comes from the global RNG (seed via `BuRngApi`).
abstract interface class BuSaplingApi {
  /// Circuit kind: Spend.
  static const int spend = 0;

  /// Circuit kind: Output.
  static const int output = 1;

  /// Packed spend witness size.
  static const int spendWitnessLen = 1288;

  /// Packed output witness size.
  static const int outputWitnessLen = 168;

  /// Groth16 proof size.
  static const int proofLen = 192;

  /// Spend public inputs size (7×32 LE limbs: rk_u,rk_v,cv_u,cv_v,anchor,nf_lo,nf_hi).
  static const int spendInputsLen = 224;

  /// Output public inputs size (5×32 LE limbs: cv_u,cv_v,epk_u,epk_v,cm_u).
  static const int outputInputsLen = 160;

  /// Load Spend ceremony parameters. Caller must [paramsFree] the handle.
  BuResult<Object> setSpendParams({required List<int> params});

  /// Load Output ceremony parameters. Caller must [paramsFree] the handle.
  BuResult<Object> setOutputParams({required List<int> params});

  /// Release a params handle.
  void paramsFree(Object handle);

  /// Prove under [handle]. Returns 192-byte proof + 7/5×32 public inputs.
  BuResult<BuSaplingProof> prove({
    required Object handle,
    required int kind,
    required List<int> witness,
  });

  /// Verify under [handle].
  BuResult<void> verify({
    required Object handle,
    required int kind,
    required BuBytes proof,
    required BuBytes inputs,
  });
}

/// Sapling proof + positional public inputs (LE limbs).
class BuSaplingProof {
  const BuSaplingProof({required this.proof, required this.inputs});
  final BuBytes proof;
  final BuBytes inputs;
}
