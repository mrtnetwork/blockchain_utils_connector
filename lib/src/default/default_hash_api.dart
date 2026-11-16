import 'package:blockchain_utils_connector/src/api/hash_api.dart';
import 'package:blockchain_utils_connector/src/bytes/bytes.dart';
import 'package:blockchain_utils_connector/src/error/bu_error.dart';
import 'package:blockchain_utils_connector/src/hash/blake2_config.dart';
import 'package:blockchain_utils_connector/src/hash/hash.dart';
import 'package:blockchain_utils_connector/src/hash/native_hash.dart';
import 'package:blockchain_utils_connector/src/platform/bindings.dart';

class DefaultHashApi implements BuHashApi {
  DefaultHashApi(this._b);
  final BuPlatformBindings _b;

  BuResult<BuSerializableHash> _plain(int algo, {int digestLength = 0}) =>
      BuNativeHash.create(
        _b,
        BuHashNativeConfig(algo: algo, digestLength: digestLength),
      );

  BuResult<BuSerializableHash> _hmac(int algo, List<int> key) {
    final k = BuBytes.owned(key);
    try {
      return BuNativeHash.create(
        _b,
        BuHashNativeConfig(algo: algo, hmac: true, key: k),
      );
    } finally {
      k.zero();
    }
  }

  @override
  BuResult<BuSerializableHash> sha256() => _plain(BuHashAlgo.sha256);
  @override
  BuResult<BuSerializableHash> sha224() => _plain(BuHashAlgo.sha224);
  @override
  BuResult<BuSerializableHash> sha512() => _plain(BuHashAlgo.sha512);
  @override
  BuResult<BuSerializableHash> sha384() => _plain(BuHashAlgo.sha384);
  @override
  BuResult<BuSerializableHash> sha512256() => _plain(BuHashAlgo.sha512_256);
  @override
  BuResult<BuSerializableHash> sha1() => _plain(BuHashAlgo.sha1);
  @override
  BuResult<BuSerializableHash> md5() => _plain(BuHashAlgo.md5);
  @override
  BuResult<BuSerializableHash> md4() => _plain(BuHashAlgo.md4);
  @override
  BuResult<BuSerializableHash> ripemd160() => _plain(BuHashAlgo.ripemd160);
  @override
  BuResult<BuSerializableHash> ripemd128() => _plain(BuHashAlgo.ripemd128);
  @override
  BuResult<BuSerializableHash> ripemd256() => _plain(BuHashAlgo.ripemd256);
  @override
  BuResult<BuSerializableHash> ripemd320() => _plain(BuHashAlgo.ripemd320);

  @override
  BuResult<BuSerializableHash> sha3({int digestLength = 32}) {
    final algo = switch (digestLength) {
      28 => BuHashAlgo.sha3_224,
      32 => BuHashAlgo.sha3_256,
      48 => BuHashAlgo.sha3_384,
      64 => BuHashAlgo.sha3_512,
      _ => BuHashAlgo.sha3_256,
    };
    return _plain(algo);
  }

  @override
  BuResult<BuSerializableHash> keccack({int digestLength = 64}) {
    final algo = switch (digestLength) {
      28 => BuHashAlgo.keccak224,
      32 => BuHashAlgo.keccak256,
      48 => BuHashAlgo.keccak384,
      64 => BuHashAlgo.keccak512,
      _ when digestLength <= 32 => BuHashAlgo.keccak256,
      _ => BuHashAlgo.keccak512,
    };
    return _plain(algo);
  }

  @override
  BuResult<BuSerializableHash> shake128({int digestLength = 32}) =>
      _plain(BuHashAlgo.shake128, digestLength: digestLength);
  @override
  BuResult<BuSerializableHash> shake256({int digestLength = 64}) =>
      _plain(BuHashAlgo.shake256, digestLength: digestLength);

  @override
  BuResult<BuSerializableHash> xxHash({int bitLength = 64}) {
    // Dart XXHash64: multi-lane XXH64 when bitLength > 64.
    // digestLength = ceil(bitLength/64)*8 (8..=64), each lane seed=i.
    if (bitLength <= 32) {
      return _plain(BuHashAlgo.xxh32, digestLength: 4);
    }
    // Keep classic multi-lane XXH64 for bitLength > 64 (matches blockchain_utils tests).
    final digestLength = ((bitLength + 63) ~/ 64) * 8;
    final len = digestLength.clamp(8, 64);
    return _plain(BuHashAlgo.xxh64, digestLength: len);
  }

  BuResult<BuSerializableHash> _blake(
    int algo,
    int digestLength,
    BuBlake2Config? config,
  ) {
    config ??= const BuBlake2Config();
    final key = config.key == null ? null : BuBytes.owned(config.key!);
    final salt = config.salt == null ? null : BuBytes.owned(config.salt!);
    final personal =
        config.personalization == null
            ? null
            : BuBytes.owned(config.personalization!);
    try {
      return BuNativeHash.create(
        _b,
        BuHashNativeConfig(
          algo: algo,
          digestLength: digestLength,
          key: key,
          salt: salt,
          personal: personal,
          fanout: config.fanout,
          maxDepth: config.maxDepth,
          leafSize: config.leafSize,
          nodeOffset: config.nodeOffset,
          nodeDepth: config.nodeDepth,
          innerDigestLength: config.innerDigestLength,
          lastNode: config.lastNode,
        ),
      );
    } finally {
      key?.zero();
      salt?.zero();
      personal?.zero();
    }
  }

  @override
  BuResult<BuSerializableHash> blake2b({
    int digestLength = 64,
    BuBlake2Config? config,
  }) => _blake(BuHashAlgo.blake2b, digestLength, config);
  @override
  BuResult<BuSerializableHash> blake2s({
    int digestLength = 32,
    BuBlake2Config? config,
  }) => _blake(BuHashAlgo.blake2s, digestLength, config);

  @override
  BuResult<BuSerializableHash> hmacSha256(List<int> key) =>
      _hmac(BuHashAlgo.sha256, key);
  @override
  BuResult<BuSerializableHash> hmacSha512(List<int> key) =>
      _hmac(BuHashAlgo.sha512, key);
  @override
  BuResult<BuSerializableHash> hmacSha384(List<int> key) =>
      _hmac(BuHashAlgo.sha384, key);

  BuResult<BuBytes> _pbkdf(
    int prf,
    List<int> password,
    List<int> salt,
    int iterations,
    int length,
  ) {
    if (length <= 0 || iterations <= 0) {
      return BuResult.err(BuError.invalidLength);
    }
    final pw = BuBytes.owned(password);
    final sa = BuBytes.owned(salt);
    try {
      final out = BuBytes.zero(length);
      _b.pbkdf2(
        prf: prf,
        password: pw,
        salt: sa,
        iterations: iterations,
        out: out,
      );
      return BuResult.ok(out);
    } catch (_) {
      return BuResult.err(BuError.internal);
    } finally {
      pw.zero();
      sa.zero();
    }
  }

  @override
  BuResult<BuBytes> pbkdf2Sha256DeriveKey({
    required List<int> password,
    required List<int> salt,
    required int iterations,
    required int length,
  }) => _pbkdf(BuKdfPrf.sha256, password, salt, iterations, length);

  @override
  BuResult<BuBytes> pbkdf2Sha512DeriveKey({
    required List<int> password,
    required List<int> salt,
    required int iterations,
    required int length,
  }) => _pbkdf(BuKdfPrf.sha512, password, salt, iterations, length);

  @override
  BuResult<BuBytes> keccakF1600(BuBytes src) {
    if (src.length != 200) {
      return BuResult.err(BuError.invalidLength);
    }
    try {
      return BuResult.ok(_b.keccakF1600(src));
    } catch (_) {
      return BuResult.err(BuError.internal);
    }
  }

  @override
  BuResult<BuBytes> poseidonHashTwo({required BuBytes a, required BuBytes b}) {
    final ca = _fp32zc(a, 'poseidon a');
    if (ca.isErr) {
      return BuResult.err(ca.error!);
    }
    final cb = _fp32zc(b, 'poseidon b');
    if (cb.isErr) {
      return BuResult.err(cb.error!);
    }
    final out = BuBytes.zero(32);
    final rc = _b.poseidonHashTwo(a, b, out);
    if (rc != 0) {
      return BuResult.err(_fromZcash(rc));
    }
    return BuResult.ok(out);
  }

  @override
  BuResult<BuBytes> poseidonHash({required List<BuBytes> inputs}) {
    for (final i in inputs) {
      final c = _fp32zc(i, 'poseidon input');
      if (c.isErr) {
        return BuResult.err(c.error!);
      }
    }
    final out = BuBytes.zero(32);
    final rc = _b.poseidonHash(inputs, out);
    if (rc != 0) {
      return BuResult.err(_fromZcash(rc));
    }
    return BuResult.ok(out);
  }

  @override
  BuResult<BuBytes> poseidonBn254Hash({required List<BuBytes> inputs}) {
    // BN254 Fr elements: length-checked here, range-checked (< r) natively.
    for (final i in inputs) {
      if (i.length != 32) {
        return BuResult.err(
          BuError.length(
            what: 'poseidonBn254 input',
            expected: 32,
            actual: i.length,
          ),
        );
      }
    }
    final out = BuBytes.zero(32);
    final rc = _b.poseidonBn254Hash(inputs, out);
    if (rc != 0) {
      return BuResult.err(_fromZcash(rc));
    }
    return BuResult.ok(out);
  }

  @override
  BuResult<BuBytes> sinsemillaHash({
    required String domain,
    required BuBytes packedBits,
    required int bitLen,
  }) {
    if (bitLen < 0) {
      return BuResult.err(BuError.invalidArgument);
    }
    final out = BuBytes.zero(32);
    final rc = _b.sinsemillaHashBits(domain, packedBits, bitLen, out);
    if (rc != 0) {
      return BuResult.err(_fromZcash(rc));
    }
    return BuResult.ok(out);
  }

  @override
  BuResult<BuBytes> sinsemillaCommit({
    required String domain,
    required BuBytes packedBits,
    required int bitLen,
    required BuBytes r,
  }) {
    final cr = _fp32zc(r, 'sinsemilla r');
    if (cr.isErr) {
      return BuResult.err(cr.error!);
    }
    final out = BuBytes.zero(32);
    final rc = _b.sinsemillaCommit(domain, packedBits, bitLen, r, out);
    if (rc != 0) {
      return BuResult.err(_fromZcash(rc));
    }
    return BuResult.ok(out);
  }

  @override
  BuResult<BuBytes> sinsemillaShortCommit({
    required String domain,
    required BuBytes packedBits,
    required int bitLen,
    required BuBytes r,
  }) {
    final cr = _fp32zc(r, 'sinsemilla r');
    if (cr.isErr) {
      return BuResult.err(cr.error!);
    }
    final out = BuBytes.zero(32);
    final rc = _b.sinsemillaShortCommit(domain, packedBits, bitLen, r, out);
    if (rc != 0) {
      return BuResult.err(_fromZcash(rc));
    }
    return BuResult.ok(out);
  }

  @override
  BuResult<void> poseidonPermute({required BuBytes state96}) {
    if (state96.length < 96) {
      return BuResult.err(
        BuError.length(what: 'state', expected: 96, actual: state96.length),
      );
    }
    final rc = _b.poseidonPermute(state96);
    if (rc != 0) {
      return BuResult.err(_fromZcash(rc));
    }
    return BuResult.ok(null);
  }

  @override
  BuResult<BuBytes> sinsemillaHashBitstring({
    required String domain,
    required String bits01,
  }) {
    for (var i = 0; i < bits01.length; i++) {
      final c = bits01[i];
      if (c != '0' && c != '1') {
        return BuResult.err(BuError.invalidArgument);
      }
    }
    final out = BuBytes.zero(32);
    final rc = _b.sinsemillaHashBitstring(domain, bits01, out);
    if (rc != 0) {
      return BuResult.err(_fromZcash(rc));
    }
    return BuResult.ok(out);
  }

  @override
  BuResult<BuBytes> pedersenHash({
    required int personal,
    int layer = 0,
    required BuBytes packedBits,
    required int bitLen,
  }) {
    if (personal != 0 && personal != 1) {
      return BuResult.err(BuError.invalidArgument);
    }
    if (bitLen < 0) {
      return BuResult.err(BuError.invalidArgument);
    }
    final out = BuBytes.zero(32);
    final rc = _b.pedersenHash(personal, layer, packedBits, bitLen, out);
    if (rc != 0) {
      return BuResult.err(_fromZcash(rc));
    }
    return BuResult.ok(out);
  }

  @override
  BuResult<BuBytes> pedersenHashBitstring({
    required int personal,
    int layer = 0,
    required List<bool> bits,
  }) {
    if (personal != 0 && personal != 1) {
      return BuResult.err(BuError.invalidArgument);
    }
    final out = BuBytes.zero(32);
    final bits01 = String.fromCharCodes([
      for (final b in bits) b ? 0x31 : 0x30,
    ]);
    final rc = _b.pedersenHashBitstring(personal, layer, bits01, out);
    if (rc != 0) {
      return BuResult.err(_fromZcash(rc));
    }
    return BuResult.ok(out);
  }

  BuResult<void> _fp32zc(BuBytes b, String what) {
    if (b.length != 32) {
      return BuResult.err(
        BuError.length(what: what, expected: 32, actual: b.length),
      );
    }
    return BuResult.ok(null);
  }

  static BuError _fromZcash(int rc) => BuError.fromNativeCode(switch (rc) {
    0 => 7, // unreachable: callers check rc != 0 first
    1 => 1,
    2 => 9,
    3 => 10,
    4 => 10,
    5 => 7,
    6 => 6,
    12 => 12,
    _ => rc,
  });
}
