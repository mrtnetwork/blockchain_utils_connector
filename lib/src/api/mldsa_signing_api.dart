import 'package:blockchain_utils_connector/src/bytes/bytes.dart';
import 'package:blockchain_utils_connector/src/error/bu_error.dart';

/// ML-DSA (FIPS 204 / Dilithium) signing API.
///
/// Parameter sets: [level] ∈ `{44, 65, 87}` (ML-DSA-44 / 65 / 87).
///
/// ## Randomness model
/// Rust never reads OS entropy.
/// - [keygen] [seed]: 32 bytes, or `null` → global RNG fills 32 bytes.
/// - [sign] [rnd]: optional 32-byte seed for local ChaCha → FIPS rnd;
///   `null` → global RNG.
/// - [context]: FIPS 204 pure context (≤ 255 bytes; default empty).
abstract interface class BuMlDsaSigningApi {
  /// True if public key length matches [level] (or inferred).
  bool isValidPublicKey(List<int> publicKey, {int? level});

  /// True if secret key length matches [level] (or inferred).
  bool isValidSecretKey(List<int> secret, {int? level});

  /// Generate a key pair.
  ///
  /// [level] required for keygen. [seed] null → global RNG (32 bytes).
  BuResult<(BuBytes, BuBytes)> keygen({required int level, BuBytes? seed});

  /// Derive public key from secret key.
  ///
  /// [level] optional; inferred from [sk].length.
  BuResult<BuBytes> publicKeyFromSecret({int? level, required BuBytes sk});

  /// Sign [message].
  ///
  /// [level] optional (from [sk].length). [rnd] null → global RNG.
  /// [context] default empty.
  BuResult<BuBytes> sign({
    int? level,
    required BuBytes sk,
    required BuBytes message,
    BuBytes? rnd,
    BuBytes? context,
  });

  /// Verify [signature].
  ///
  /// [level] optional (from [pk].length). [context] must match sign-time.
  BuResult<bool> verify({
    int? level,
    required BuBytes pk,
    required BuBytes message,
    required BuBytes signature,
    BuBytes? context,
  });
}
