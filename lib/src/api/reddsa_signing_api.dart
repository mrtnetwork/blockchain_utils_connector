import 'package:blockchain_utils_connector/src/bytes/bytes.dart';
import 'package:blockchain_utils_connector/src/error/bu_error.dart';

/// RedDSA domain (Zcash Sapling / Orchard).
enum BuReddsaDomain {
  /// Sapling spend-auth (Jubjub + `Zcash_RedJubjubH`)
  jubjubAuth,

  /// Sapling binding (Jubjub)
  jubjubBinding,

  /// Orchard spend-auth (Pallas + `Zcash_RedPallasH`)
  pallasAuth,

  /// Orchard binding (Pallas)
  pallasBinding,
}

/// RedDSA signing (Jubjub Auth/Binding + Pallas Auth/Binding).
///
/// - sk / pk: 32 bytes
/// - signature: 64 bytes (`R || s`)
/// - [rand80]: 80-byte signing randomness, or `null`/empty → **global RNG**
abstract interface class BuReddsaSigningApi {
  /// True if 32-byte public key decodes for [domain] curve (Jubjub/Pallas).
  bool isValidPublicKey({
    required BuReddsaDomain domain,
    required List<int> publicKey,
  });

  /// True if 32-byte secret is a valid non-zero scalar for [domain].
  bool isValidSecretKey({
    required BuReddsaDomain domain,
    required List<int> secret,
  });

  /// Derive public key for [domain] from 32-byte secret.
  BuResult<BuBytes> publicKey({
    required BuReddsaDomain domain,
    required BuBytes sk,
  });

  /// Sign [message]. [rand80] null/empty uses global ChaCha backend.
  BuResult<BuBytes> sign({
    required BuReddsaDomain domain,
    required BuBytes sk,
    required BuBytes message,
    BuBytes? rand80,
  });

  /// Verify 64-byte signature under 32-byte [pk].
  BuResult<bool> verify({
    required BuReddsaDomain domain,
    required BuBytes pk,
    required BuBytes message,
    required BuBytes signature,
  });

  // Convenience domain helpers
  BuResult<BuBytes> jubjubAuthSign({
    required BuBytes sk,
    required BuBytes message,
    BuBytes? rand80,
  });
  BuResult<bool> jubjubAuthVerify({
    required BuBytes pk,
    required BuBytes message,
    required BuBytes signature,
  });
  BuResult<BuBytes> jubjubBindingSign({
    required BuBytes sk,
    required BuBytes message,
    BuBytes? rand80,
  });
  BuResult<bool> jubjubBindingVerify({
    required BuBytes pk,
    required BuBytes message,
    required BuBytes signature,
  });
  BuResult<BuBytes> pallasAuthSign({
    required BuBytes sk,
    required BuBytes message,
    BuBytes? rand80,
  });
  BuResult<bool> pallasAuthVerify({
    required BuBytes pk,
    required BuBytes message,
    required BuBytes signature,
  });
  BuResult<BuBytes> pallasBindingSign({
    required BuBytes sk,
    required BuBytes message,
    BuBytes? rand80,
  });
  BuResult<bool> pallasBindingVerify({
    required BuBytes pk,
    required BuBytes message,
    required BuBytes signature,
  });

  /// Validate any accepted JubJub public-key form and return its canonical
  /// 32-byte base encoding, rejecting the point at infinity.
  BuResult<BuBytes> normalizeJubjubPublicKey(List<int> publicKey);

  /// Validate any accepted Pallas public-key form and return its canonical
  /// 32-byte base encoding, rejecting the point at infinity.
  BuResult<BuBytes> normalizePallasPublicKey(List<int> publicKey);
}
