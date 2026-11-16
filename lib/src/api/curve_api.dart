import 'package:blockchain_utils_connector/src/bytes/bytes.dart';
import 'package:blockchain_utils_connector/src/error/bu_error.dart';

abstract interface class BuCurveApi {
  int get curveId;
  int get pointLen;

  /// Uncompressed point length (k1/r1: 65, G1: 96, G2: 192, …).
  int get uncompressedLen;
  int get scalarLen;
  bool scCheck(List<int> scalarBytes);
  BuResult<BuBytes> multBase(List<int> scalar);
  BuResult<BuBytes> mult(List<int> scalar, List<int> point);
  BuResult<BuBytes> add(List<int> pointA, List<int> pointB);
  BuResult<BuBytes> sub(List<int> pointA, List<int> pointB);
  BuResult<BuBytes> neg(List<int> point);
  BuResult<BuBytes> scAdd(List<int> scalarA, List<int> scalarB);
  BuResult<BuBytes> scSub(List<int> scalarA, List<int> scalarB);
  BuResult<BuBytes> scMul(List<int> scalarA, List<int> scalarB);
  BuResult<BuBytes> scNeg(List<int> scalar);
  BuResult<BuBytes> scReduce(List<int> scalar);
  BuResult<BuBytes> generator();
  BuResult<BuBytes> identity();

  /// Re-encode any accepted form (compressed or uncompressed) as compressed.
  /// Strict validation on decode (canonical, on-curve, subgroup for BLS).
  BuResult<BuBytes> compress(List<int> point);

  /// Re-encode any accepted form as uncompressed.
  BuResult<BuBytes> uncompress(List<int> point);

  /// Validate any accepted point form and re-encode it as compressed,
  /// rejecting the point at infinity.
  BuResult<BuBytes> normalizePublicKey(List<int> point);
  BuResult<BuBytes> generateSecret(List<int> seed);
  BuResult<BuBytes> mulAdd(
    List<int> s1,
    List<int> p1,
    List<int> s2,
    List<int> p2,
  );
}

abstract interface class BuSecp256k1CurveApi implements BuCurveApi {}

abstract interface class BuSecp256r1CurveApi implements BuCurveApi {}

abstract interface class BuEd25519CurveApi implements BuCurveApi {
  BuResult<BuBytes> scReduce32(List<int> scalar32);
  BuResult<BuBytes> scReduce64(List<int> scalar64);

  /// Monero `ge_fromfe_frombytes_vartime`: 32-byte field element → compressed point.
  /// Variable-time; public inputs only (hash-to-point).
  BuResult<BuBytes> fromFeBytes(List<int> fe32);

  /// Monero `[8] Hp(u)` — hash-to-point then clear cofactor (key-image style).
  BuResult<BuBytes> fromFeBytesClearCofactor(List<int> fe32);

  /// Monero `hash_to_ec`: Keccak-256(data) → from_fe → ×8 → compressed point.
  BuResult<BuBytes> hashToEc(List<int> data);

  /// On-curve public key check (variable-time).
  bool checkKey(List<int> pk32);

  /// Multiply point by cofactor 8.
  BuResult<BuBytes> mulByCofactor(List<int> point32);

  /// Key image `I = a · Hp` (constant-time).
  BuResult<BuBytes> scalarmultKeyImage(List<int> hp32, List<int> a32);

  /// Fused `mul8(mult(s, P))`: `8 * (s * P)` (constant-time on secret `s`).
  /// Single Rust decode/encode; avoids intermediate `toBytes`/`fromBytes`.
  BuResult<BuBytes> mul8Mult(List<int> scalar32, List<int> point32);

  /// Odd multiples table `[P,3P,…,15P]` as 256 bytes (8×32).
  BuResult<BuBytes> geDsmPrecomp(List<int> point32);

  /// `a·A + b·B` with precomp tables (256 bytes each).
  BuResult<BuBytes> geDoubleScalarMultPrecomp(
    List<int> a32,
    List<int> aI256,
    List<int> b32,
    List<int> bI256,
  );

  /// `a·A + b·B` with B = basepoint.
  BuResult<BuBytes> geDoubleScalarMultBase(
    List<int> a32,
    List<int> gA32,
    List<int> b32,
  );

  /// `a·B + b·P + c·Q` with B = base.
  BuResult<BuBytes> geTripleScalarMultBase(
    List<int> a32,
    List<int> b32,
    List<int> bI256,
    List<int> c32,
    List<int> cI256,
  );

  /// `a·A + b·B + c·C` with three precomp tables.
  BuResult<BuBytes> geTripleScalarMultPrecomp(
    List<int> a32,
    List<int> aI256,
    List<int> b32,
    List<int> bI256,
    List<int> c32,
    List<int> cI256,
  );

  /// Variable-time [s]P (public scalar only — faster than [mul]).
  BuResult<BuBytes> mulVartime(List<int> scalar, List<int> point);

  /// Variable-time [s]B.
  BuResult<BuBytes> mulBaseVartime(List<int> scalar);

  /// Variable-time s1*P1 + s2*P2.
  BuResult<BuBytes> mulAddVartime(
    List<int> s1,
    List<int> p1,
    List<int> s2,
    List<int> p2,
  );
  BuResult<BuBytes> addVartime(List<int> a, List<int> b);
  BuResult<BuBytes> subVartime(List<int> a, List<int> b);
  BuResult<BuBytes> negVartime(List<int> point);
  BuResult<BuBytes> doubleVartime(List<int> point);
}

abstract interface class BuRistrettoCurveApi implements BuCurveApi {
  /// Edwards compressed (32) → Ristretto compressed (32).
  BuResult<BuBytes> pointFromEdwardBytes(List<int> edwards32);

  /// Ristretto compressed (32) → Edwards compressed (32).
  BuResult<BuBytes> toEdwardBytes(List<int> ristretto32);

  /// 64-byte LE integer → 32-byte LE scalar mod L (same order as Ed25519 / sr25519).
  BuResult<BuBytes> scReduce64(List<int> scalar64);
}

abstract interface class BuJubjubCurveApi implements BuCurveApi {
  /// 64-byte LE integer → 32-byte LE scalar mod Jubjub order (Zcash/RedDSA).
  BuResult<BuBytes> scReduce64(List<int> scalar64);
}

abstract interface class BuG1ProjectiveCurveApi implements BuCurveApi {
  BuResult<BuBytes> hashToG1(List<int> msg, {List<int>? dst});
}

abstract interface class BuG2ProjectiveCurveApi implements BuCurveApi {
  BuResult<BuBytes> hashToG2(List<int> msg, {List<int>? dst});
}

/// BN254 (alt_bn128) G1: 64-byte uncompressed points (EIP-197), 32-byte
/// big-endian scalars. No compressed form exists for alt_bn128.
abstract interface class BuBn254G1CurveApi implements BuCurveApi {}

/// BN254 (alt_bn128) G2: 128-byte uncompressed points (EIP-197 word order
/// x1,x0,y1,y0), 32-byte big-endian scalars.
abstract interface class BuBn254G2CurveApi implements BuCurveApi {}

abstract interface class BuPallasCurveApi implements BuCurveApi {
  BuResult<BuBytes> hashToCurve(List<int> msg, {List<int>? dst});
  BuResult<BuBytes> hashToCurvePasta(List<int> msg, {List<int>? personal});

  /// 64-byte LE integer → 32-byte LE scalar mod Pallas order (Orchard/RedDSA).
  BuResult<BuBytes> scReduce64(List<int> scalar64);
}

abstract interface class BuVestaCurveApi implements BuCurveApi {
  BuResult<BuBytes> hashToCurve(List<int> msg, {List<int>? dst});

  /// 64-byte LE integer → 32-byte LE scalar mod Vesta order.
  BuResult<BuBytes> scReduce64(List<int> scalar64);
}

abstract interface class BuPallasIsoCurveApi implements BuCurveApi {
  BuResult<BuBytes> hashToCurve(List<int> msg, {List<int>? dst});
}

abstract interface class BuVestaIsoCurveApi implements BuCurveApi {
  BuResult<BuBytes> hashToCurve(List<int> msg, {List<int>? dst});
}

abstract interface class BuCurvesApi {
  BuSecp256k1CurveApi secp256k1();
  BuSecp256r1CurveApi secp256r1();
  BuEd25519CurveApi ed25519();
  BuRistrettoCurveApi ristretto();
  BuJubjubCurveApi jubjub();
  BuG1ProjectiveCurveApi g1();
  BuG2ProjectiveCurveApi g2();
  BuBn254G1CurveApi bn254G1();
  BuBn254G2CurveApi bn254G2();
  BuPallasCurveApi pallas();
  BuVestaCurveApi vesta();
  BuPallasIsoCurveApi pallasIso();
  BuVestaIsoCurveApi vestaIso();
}
