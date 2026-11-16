import 'package:blockchain_utils_connector/src/bytes/bytes.dart';
import 'package:blockchain_utils_connector/src/error/bu_error.dart';

enum BuEd25519Variant {
  ed25519(0),
  ed25519Blake2b(1),
  ed25519Kholaw(2),
  ed25519Monero(3);

  const BuEd25519Variant(this.id);
  final int id;
}

class BuEd25519Signature {
  const BuEd25519Signature(this.bytes);
  final BuBytes bytes;
}

abstract interface class BuEd25519SigningApi {
  /// True if 32-byte compressed Ed25519 public key is on-curve / decodable.
  bool isValidPublicKey(List<int> publicKey);

  /// True if secret is usable (32-byte seed or 64-byte expanded depending on variant).
  bool isValidSecretKey(
    List<int> secret, {
    BuEd25519Variant variant = BuEd25519Variant.ed25519,
  });

  BuResult<BuBytes> publicKey(
    BuBytes secret, {
    BuEd25519Variant variant = BuEd25519Variant.ed25519,
  });
  BuResult<BuEd25519Signature> sign({
    required BuBytes secret,
    required BuBytes message,
    BuEd25519Variant variant = BuEd25519Variant.ed25519,
  });
  BuResult<bool> verify({
    required BuBytes publicKey,
    required BuBytes message,
    required BuEd25519Signature signature,
    BuEd25519Variant variant = BuEd25519Variant.ed25519,
  });

  /// Validate any accepted public-key form and return its canonical
  /// 32-byte base encoding, rejecting the point at infinity.
  BuResult<BuBytes> normalizePublicKey(List<int> publicKey);
}
