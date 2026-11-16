import 'package:blockchain_utils_connector/src/bytes/bytes.dart';
import 'package:blockchain_utils_connector/src/error/bu_error.dart';

abstract interface class BuBlsSigningApi {
  /// True if G1 public key (48 bytes compressed) is valid.
  bool isValidPublicKeyG1(List<int> publicKey);

  /// True if G2 public key (96 bytes compressed) is valid.
  bool isValidPublicKeyG2(List<int> publicKey);

  /// True if 32-byte BLS secret scalar is valid (mod r, non-zero).
  bool isValidSecretKey(List<int> secret);

  BuResult<BuBytes> publicKeyG1(BuBytes sk);
  BuResult<BuBytes> publicKeyG2(BuBytes sk);
  BuResult<BuBytes> signMinPk({
    required BuBytes sk,
    required BuBytes message,
    BuBytes? dst,
  });
  BuResult<BuBytes> signMinSig({
    required BuBytes sk,
    required BuBytes message,
    BuBytes? dst,
  });
  BuResult<bool> verifyMinPk({
    required BuBytes pk,
    required BuBytes message,
    required BuBytes signature,
    BuBytes? dst,
  });
  BuResult<bool> verifyMinSig({
    required BuBytes pk,
    required BuBytes message,
    required BuBytes signature,
    BuBytes? dst,
  });
  BuResult<BuBytes> aggregatePublicKeysG1(BuBytes pksConcat);
  BuResult<BuBytes> aggregatePublicKeysG2(BuBytes pksConcat);
  BuResult<BuBytes> aggregateSignaturesG1(BuBytes sigsConcat);
  BuResult<BuBytes> aggregateSignaturesG2(BuBytes sigsConcat);
  BuResult<bool> fastAggregateVerifyMinPk({
    required BuBytes aggregatePublicKey,
    required BuBytes message,
    required BuBytes signature,
    BuBytes? dst,
  });
  BuResult<bool> fastAggregateVerifyMinSig({
    required BuBytes aggregatePublicKey,
    required BuBytes message,
    required BuBytes signature,
    BuBytes? dst,
  });
  BuResult<bool> aggregateVerifyMinPk({
    required BuBytes pksConcat,
    required BuBytes messagesBlob,
    required int messageCount,
    required BuBytes signature,
    BuBytes? dst,
  });
  BuResult<bool> aggregateVerifyMinSig({
    required BuBytes pksConcat,
    required BuBytes messagesBlob,
    required int messageCount,
    required BuBytes signature,
    BuBytes? dst,
  });
  BuResult<bool> batchVerifyMinPk({
    required BuBytes pksConcat,
    required BuBytes messagesBlob,
    required int messageCount,
    required BuBytes sigsConcat,
    BuBytes? dst,
  });
  BuResult<bool> batchVerifyMinSig({
    required BuBytes pksConcat,
    required BuBytes messagesBlob,
    required int messageCount,
    required BuBytes sigsConcat,
    BuBytes? dst,
  });

  /// Validate any accepted G1 public-key form and return its canonical
  /// 48-byte compressed base encoding, rejecting the point at infinity.
  BuResult<BuBytes> normalizeG1PublicKey(List<int> publicKey);

  /// Validate any accepted G2 public-key form and return its canonical
  /// 96-byte compressed base encoding, rejecting the point at infinity.
  BuResult<BuBytes> normalizeG2PublicKey(List<int> publicKey);
}
