import 'package:blockchain_utils_connector/src/bytes/bytes.dart';
import 'package:blockchain_utils_connector/src/error/bu_error.dart';

/// Schnorrkel / sr25519 (Substrate) signing, HDKD, and VRF.
abstract interface class BuSr25519SigningApi {
  /// Mini-secret (32) → public key (32). [uniform] selects expand mode.
  BuResult<BuBytes> publicKeyFromSeed(List<int> seed32, {bool uniform = false});

  /// Mini-secret (32) → expanded secret (64 = scalar‖nonce).
  /// [uniform] false = Ed25519 expand (Substrate default); true = Merlin uniform.
  BuResult<BuBytes> secretFromSeed(List<int> seed32, {bool uniform = false});

  /// Expanded secret (64 = scalar‖nonce) → public key.
  BuResult<BuBytes> publicKeyFromSecret(List<int> sk64);

  /// True if compressed Ristretto public key is valid and non-identity.
  bool isValidPublicKey(List<int> pk32);

  /// True if 64-byte expanded secret parses.
  bool isValidSecretKey(List<int> sk64);

  /// Sign under SigningContext([context]) + message. [nonce64] required.
  /// [fromSeed] true → [seedOrSk] is mini-secret 32; false → expanded 64.
  BuResult<BuBytes> sign({
    required List<int> seedOrSk,
    required List<int> message,
    required List<int> nonce64,
    bool fromSeed = true,
    bool uniform = false,
    List<int>? context,
  });

  BuResult<bool> verify({
    required List<int> publicKey,
    required List<int> message,
    required List<int> signature,
    List<int>? context,
  });

  /// (8·sk)‖nonce — Dart `toEd25519Bytes`.
  BuResult<BuBytes> toEd25519Bytes(List<int> sk64);

  /// Hard HDKD. Returns (newSk64, chainCode32).
  BuResult<(BuBytes, BuBytes)> hardDerive({
    required List<int> seedOrSk,
    required List<int> chainCode32,
    List<int>? message,
    bool fromSeed = true,
    bool uniform = false,
  });

  /// Soft HDKD. [newNonce32] required. Returns (newSk64, chainCode32).
  BuResult<(BuBytes, BuBytes)> softDerive({
    required List<int> seedOrSk,
    required List<int> chainCode32,
    required List<int> newNonce32,
    List<int>? message,
    bool fromSeed = true,
    bool uniform = false,
  });

  /// Soft public derive. Returns (newPk32, chainCode32).
  BuResult<(BuBytes, BuBytes)> derivePublic({
    required List<int> publicKey,
    required List<int> chainCode32,
    List<int>? message,
  });

  /// VRF input point H from SigningContext + message + pk.
  BuResult<BuBytes> vrfHash({
    required List<int> publicKey,
    required List<int> message,
    List<int>? context,
  });

  /// VRF (input32‖output32).
  BuResult<BuBytes> vrfInOut({
    required List<int> seedOrSk,
    required List<int> message,
    bool fromSeed = true,
    bool uniform = false,
    List<int>? context,
  });

  /// DLEQ proof (c‖s = 64). [inout64] = input‖output.
  /// [extra] is optional prove-transcript data (Dart `vrfScript(extra:)`).
  BuResult<BuBytes> dleqProve({
    required List<int> seedOrSk,
    required List<int> inout64,
    required List<int> nonce64,
    bool fromSeed = true,
    bool uniform = false,
    bool kusamaVrf = true,
    List<int>? extra,
  });

  /// [extra] must match the value used at prove time for the prove transcript.
  BuResult<bool> dleqVerify({
    required List<int> publicKey,
    required List<int> inout64,
    required List<int> proof64,
    bool kusamaVrf = true,
    List<int>? extra,
  });

  /// VRF sign → preOut32‖proof64 (96 bytes).
  /// [extra] is optional prove-transcript data (Dart `vrfScript(extra:)`).
  BuResult<BuBytes> vrfSign({
    required List<int> seedOrSk,
    required List<int> message,
    required List<int> nonce64,
    bool fromSeed = true,
    bool uniform = false,
    List<int>? context,
    List<int>? extra,
    bool kusamaVrf = true,
  });

  /// [extra] must match the value used at sign time for the prove transcript.
  BuResult<bool> vrfVerify({
    required List<int> publicKey,
    required List<int> message,
    required List<int> preOut32,
    required List<int> proof64,
    List<int>? context,
    List<int>? extra,
    bool kusamaVrf = true,
  });

  /// Validate any accepted public-key form and return its canonical
  /// 32-byte base encoding, rejecting the point at infinity.
  BuResult<BuBytes> normalizePublicKey(List<int> publicKey);
}
