import 'package:blockchain_utils_connector/src/bytes/bytes.dart';
import 'package:blockchain_utils_connector/src/error/bu_error.dart';

/// Solana confidential-transfer ZK (dalek Bulletproofs +
/// Sigma protocols, NOT Monero Bulletproofs+). All proving runs in the Rust
/// `solana_zk` backend under on-chain instruction transcripts; the Dart
/// layer only marshals bytes. Error codes mirror Rust `BU_SOLANA_ZK_*`:
/// 0 ok, 1 invalid-equation, -1 null, -2 length, -3 parse, -4 crypto,
/// -5 internal, -6 backend-not-linked.
abstract interface class BuSolanaZkApi {
  /// Validate a 32-byte ElGamal pubkey.
  BuResult<bool> validatePubkey(List<int> pubkey);

  /// Validate a 64-byte ElGamal ciphertext.
  BuResult<bool> validateCiphertext(List<int> ciphertext);

  /// Validate a 36-byte AES decryptable balance.

  /// AES-GCM-SIV encrypt a u64 balance (36 bytes out).
  BuResult<BuBytes> aeEncrypt({
    required List<int> key16,
    required int amount,
    required List<int> nonce12,
  });

  /// AES-GCM-SIV decrypt a 36-byte balance.
  BuResult<int> aeDecrypt({required List<int> key16, required List<int> ae});
  BuResult<bool> validateAe(List<int> ae);

  /// Derive `P = s^{-1} * H` (32 bytes) from a secret.
  BuResult<BuBytes> pubkeyFromSecret(List<int> secret);

  /// Deterministic encrypt-with-opening; 64-byte ciphertext.
  BuResult<BuBytes> encryptWith({
    required List<int> pubkey,
    required int amount,
    required List<int> opening,
  });

  /// Decrypt a ciphertext to its u32 amount.
  BuResult<int> decryptU32({
    required List<int> secret,
    required List<int> ciphertext,
  });

  /// Prove pubkey-validity (64 bytes).
  BuResult<BuBytes> provePubkeyValidity({
    required List<int> secret,
    required List<int> seed32,
  });

  /// Verify a 64-byte pubkey-validity proof.
  BuResult<bool> verifyPubkeyValidity({
    required List<int> pubkey,
    required List<int> proof,
  });

  /// Prove zero-ciphertext (96 bytes).
  BuResult<BuBytes> proveZeroCiphertext({
    required List<int> secret,
    required List<int> pubkey,
    required List<int> ciphertext,
    required List<int> seed32,
  });

  /// Verify a 96-byte zero-ciphertext proof.
  BuResult<bool> verifyZeroCiphertext({
    required List<int> pubkey,
    required List<int> ciphertext,
    required List<int> proof,
  });

  /// Prove ciphertext-commitment equality (192 bytes).
  BuResult<BuBytes> proveEquality({
    required List<int> secret,
    required List<int> pubkey,
    required List<int> ciphertext,
    required List<int> commitment,
    required List<int> opening,
    required int amount,
    required List<int> seed32,
  });

  /// Verify a 192-byte equality proof.
  BuResult<bool> verifyEquality({
    required List<int> pubkey,
    required List<int> ciphertext,
    required List<int> commitment,
    required List<int> proof,
  });

  /// Prove ciphertext-ciphertext equality (224 bytes).
  BuResult<BuBytes> proveCiphertextEquality({
    required List<int> firstSecret,
    required List<int> firstPubkey,
    required List<int> secondPubkey,
    required List<int> firstCiphertext,
    required List<int> secondCiphertext,
    required List<int> secondOpening,
    required int amount,
    required List<int> seed32,
  });

  /// Verify a 224-byte ciphertext-equality proof.
  BuResult<bool> verifyCiphertextEquality({
    required List<int> firstPubkey,
    required List<int> secondPubkey,
    required List<int> firstCiphertext,
    required List<int> secondCiphertext,
    required List<int> proof,
  });

  /// Prove 2-handle grouped validity (160 bytes).
  BuResult<BuBytes> proveGroupedValidity2({
    required List<int> firstPubkey,
    required List<int> secondPubkey,
    required List<int> grouped96,
    required int amount,
    required List<int> opening,
    required List<int> seed32,
  });

  /// Verify a 160-byte 2-handle proof.
  BuResult<bool> verifyGroupedValidity2({
    required List<int> firstPubkey,
    required List<int> secondPubkey,
    required List<int> grouped96,
    required List<int> proof,
  });

  /// Prove 3-handle grouped validity (192 bytes).
  BuResult<BuBytes> proveGroupedValidity3({
    required List<int> firstPubkey,
    required List<int> secondPubkey,
    required List<int> thirdPubkey,
    required List<int> grouped128,
    required int amount,
    required List<int> opening,
    required List<int> seed32,
  });

  /// Verify a 192-byte 3-handle proof.
  BuResult<bool> verifyGroupedValidity3({
    required List<int> firstPubkey,
    required List<int> secondPubkey,
    required List<int> thirdPubkey,
    required List<int> grouped128,
    required List<int> proof,
  });

  /// Prove batched 2-handle validity (160 bytes).
  BuResult<BuBytes> proveBatchedGroupedValidity2({
    required List<int> firstPubkey,
    required List<int> secondPubkey,
    required List<int> groupedLo96,
    required List<int> groupedHi96,
    required int amountLo,
    required int amountHi,
    required List<int> openingLo,
    required List<int> openingHi,
    required List<int> seed32,
  });

  /// Verify a 160-byte batched 2-handle proof.
  BuResult<bool> verifyBatchedGroupedValidity2({
    required List<int> firstPubkey,
    required List<int> secondPubkey,
    required List<int> groupedLo96,
    required List<int> groupedHi96,
    required List<int> proof,
  });

  /// Prove batched 3-handle validity (192 bytes).
  BuResult<BuBytes> proveBatchedGroupedValidity3({
    required List<int> firstPubkey,
    required List<int> secondPubkey,
    required List<int> thirdPubkey,
    required List<int> groupedLo128,
    required List<int> groupedHi128,
    required int amountLo,
    required int amountHi,
    required List<int> openingLo,
    required List<int> openingHi,
    required List<int> seed32,
  });

  /// Verify a 192-byte batched 3-handle proof.
  BuResult<bool> verifyBatchedGroupedValidity3({
    required List<int> firstPubkey,
    required List<int> secondPubkey,
    required List<int> thirdPubkey,
    required List<int> groupedLo128,
    required List<int> groupedHi128,
    required List<int> proof,
  });

  /// Prove percentage-with-cap (256 bytes).
  BuResult<BuBytes> provePercentageWithCap({
    required List<int> percentageCommitment,
    required List<int> percentageOpening,
    required int percentageAmount,
    required List<int> deltaCommitment,
    required List<int> deltaOpening,
    required int deltaAmount,
    required List<int> claimedCommitment,
    required List<int> claimedOpening,
    required int maxValue,
    required List<int> seed32,
  });

  /// Verify a 256-byte percentage proof.
  BuResult<bool> verifyPercentageWithCap({
    required List<int> percentageCommitment,
    required List<int> deltaCommitment,
    required List<int> claimedCommitment,
    required int maxValue,
    required List<int> proof,
  });

  /// Prove batched range. Returns
  /// `proof || pod_commitments(256) || pod_bit_lengths(8)`; the proof length
  /// is a pure function of `n` (single-64: 672 bytes).
  BuResult<BuBytes> proveBatchedRange({
    required List<List<int>> amountsLe,
    required List<List<int>> openings,
    required List<int> seed32,
  });

  /// Verify a batched range proof against n×32 commitments.
  BuResult<bool> verifyBatchedRange({
    required List<int> proof,
    required List<int> commitments,
    required int n,
  });

  /// Prove withdraw bundle (fixed 1256-byte layout).
  BuResult<BuBytes> proveWithdraw({
    required List<int> sourceSecret,
    required List<int> sourcePubkey,
    required List<int> currentCiphertext,
    required int currentBalance,
    required int withdrawAmount,
    required List<int> seed32,
  });

  /// Prove transfer bundle (fixed 1896-byte layout).
  BuResult<BuBytes> proveTransfer({
    required List<int> sourceSecret,
    required List<int> sourcePubkey,
    required List<int> destPubkey,
    required List<int> auditorPubkey,
    required List<int> currentCiphertext,
    required int currentBalance,
    required int transferAmount,
    required List<int> seed32,
  });

  /// Prove transfer-with-fee bundle (fixed 2576-byte layout).
  BuResult<BuBytes> proveTransferWithFee({
    required List<int> sourceSecret,
    required List<int> sourcePubkey,
    required List<int> destPubkey,
    required List<int> auditorPubkey,
    required List<int> authorityPubkey,
    required List<int> currentCiphertext,
    required int currentBalance,
    required int transferAmount,
    required int feeRateBasisPoints,
    required int maximumFee,
    required List<int> seed32,
  });
}
