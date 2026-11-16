import 'package:blockchain_utils_connector/src/bytes/bytes.dart';
import 'package:blockchain_utils_connector/src/error/bu_error.dart';
import 'package:blockchain_utils_connector/src/api/secp256k1_signing_api.dart'
    show BuEcdsaSignature;

class BuSecp256r1SignParams {
  const BuSecp256r1SignParams({required this.digest, this.extraEntropy});
  final BuBytes digest;
  final BuBytes? extraEntropy;
}

abstract interface class BuSecp256r1SigningApi {
  /// True if public key is valid (33 compressed or 65 uncompressed).
  bool isValidPublicKey(List<int> publicKey);

  /// True if 32-byte secret is in [1, n-1].
  bool isValidSecretKey(List<int> secret);

  BuResult<BuBytes> publicKey(BuBytes sk);
  BuResult<BuEcdsaSignature> signEcdsa(
    BuBytes sk,
    BuSecp256r1SignParams params,
  );
  BuResult<bool> verifyEcdsa({
    required BuBytes pk,
    required BuBytes digest,
    required BuEcdsaSignature signature,
  });

  /// Validate any accepted public-key form and return its canonical
  /// compressed base encoding, rejecting the point at infinity.
  BuResult<BuBytes> normalizePublicKey(List<int> publicKey);
}
