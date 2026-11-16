import 'package:blockchain_utils_connector/src/bytes/bytes.dart';
import 'package:blockchain_utils_connector/src/error/bu_error.dart';
import 'package:blockchain_utils_connector/src/hash/blake2_config.dart';
import 'package:blockchain_utils_connector/src/hash/hash.dart';

abstract interface class BuHashApi {
  BuResult<BuSerializableHash> blake2b({
    int digestLength = 64,
    BuBlake2Config? config,
  });
  BuResult<BuSerializableHash> blake2s({
    int digestLength = 32,
    BuBlake2Config? config,
  });
  BuResult<BuSerializableHash> sha3({int digestLength = 32});
  BuResult<BuSerializableHash> md4();
  BuResult<BuSerializableHash> md5();
  BuResult<BuSerializableHash> ripemd320();
  BuResult<BuSerializableHash> ripemd256();
  BuResult<BuSerializableHash> ripemd160();
  BuResult<BuSerializableHash> ripemd128();
  BuResult<BuSerializableHash> sha1();
  BuResult<BuSerializableHash> sha256();
  BuResult<BuSerializableHash> sha224();
  BuResult<BuSerializableHash> sha384();
  BuResult<BuSerializableHash> sha512();
  BuResult<BuSerializableHash> sha512256();
  BuResult<BuSerializableHash> xxHash({int bitLength = 64});
  BuResult<BuSerializableHash> keccack({int digestLength = 64});
  BuResult<BuSerializableHash> shake128({int digestLength = 32});
  BuResult<BuSerializableHash> shake256({int digestLength = 64});
  BuResult<BuSerializableHash> hmacSha256(List<int> key);
  BuResult<BuSerializableHash> hmacSha512(List<int> key);
  BuResult<BuSerializableHash> hmacSha384(List<int> key);
  BuResult<BuBytes> pbkdf2Sha512DeriveKey({
    required List<int> password,
    required List<int> salt,
    required int iterations,
    required int length,
  });
  BuResult<BuBytes> pbkdf2Sha256DeriveKey({
    required List<int> password,
    required List<int> salt,
    required int iterations,
    required int length,
  });
  BuResult<BuBytes> keccakF1600(BuBytes src);

  // —— Zcash hashes (Poseidon + Sinsemilla + Pedersen), moved from BuZCryptoApi.
  //
  // Wire formats are little-endian where applicable:
  // - Poseidon Fp in/out: 32-byte LE
  // - Sinsemilla `r`: 32-byte LE Vesta Fq
  // - Commit point out: 32-byte Pasta compressed
  // - Short commit: 32-byte LE Fp (affine x)
  BuResult<BuBytes> poseidonHashTwo({required BuBytes a, required BuBytes b});

  BuResult<BuBytes> poseidonHash({required List<BuBytes> inputs});

  /// circomlib-compatible Poseidon over BN254 Fr (Sui zkLogin / Aptos
  /// keyless): 1..64 inputs of 32-byte LE Fr → 32-byte LE digest.
  /// Backends built without the Rust `poseidon-bn254` feature report
  /// unsupported.
  BuResult<BuBytes> poseidonBn254Hash({required List<BuBytes> inputs});

  BuResult<BuBytes> sinsemillaHash({
    required String domain,
    required BuBytes packedBits,
    required int bitLen,
  });

  BuResult<BuBytes> sinsemillaCommit({
    required String domain,
    required BuBytes packedBits,
    required int bitLen,
    required BuBytes r,
  });

  BuResult<BuBytes> sinsemillaShortCommit({
    required String domain,
    required BuBytes packedBits,
    required int bitLen,
    required BuBytes r,
  });

  /// In-place Poseidon permutation over a 96-byte width-3 state (3×32 LE).
  BuResult<void> poseidonPermute({required BuBytes state96});

  /// Sinsemilla hash of an ASCII `0`/`1` bit-string (Dart-style).
  BuResult<BuBytes> sinsemillaHashBitstring({
    required String domain,
    required String bits01,
  });

  /// Pedersen personalization ids (mirror Rust `BU_PEDERSEN_*`).
  static const int pedersenNoteCommitment = 0;
  static const int pedersenMerkleTree = 1;

  /// Pedersen hash over packed LSB-first bits → 32-byte Jubjub compressed.
  BuResult<BuBytes> pedersenHash({
    required int personal,
    int layer = 0,
    required BuBytes packedBits,
    required int bitLen,
  });

  /// Pedersen hash of a bit list.
  BuResult<BuBytes> pedersenHashBitstring({
    required int personal,
    int layer = 0,
    required List<bool> bits,
  });
}
