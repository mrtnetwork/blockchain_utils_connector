import 'package:blockchain_utils_connector/src/bytes/bytes.dart';
import 'package:blockchain_utils_connector/src/error/bu_error.dart';

/// X25519 (RFC 7748) Diffie–Hellman API.
abstract interface class BuX25519Api {
  /// `X25519(k, u)` — clamp [scalar], Montgomery ladder with peer/base [u].
  BuResult<BuBytes> x25519({required List<int> scalar, required List<int> u});

  /// Public key = `X25519(private, 9)`.
  BuResult<BuBytes> publicKey(List<int> privateKey);

  /// Shared secret = `X25519(private, peerPublic)`.
  BuResult<BuBytes> diffieHellman({
    required List<int> privateKey,
    required List<int> peerPublic,
  });

  /// Convert Ed25519 compressed public key to X25519.
  BuResult<BuBytes> fromEd25519PublicKey(List<int> ed25519Pk);

  /// Expand Ed25519 seed (SHA-512 + clamp) to X25519 secret.
  BuResult<BuBytes> fromEd25519Seed(List<int> seed);
}
