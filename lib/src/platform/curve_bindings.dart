import 'package:blockchain_utils_connector/src/bytes/bytes.dart';

abstract interface class BuCurveBindings {
  int curvePointLen(int curveId);
  int curveScalarLen(int curveId);
  int curveScCheck(int curveId, BuBytes scalar);
  int curveGenerator(int curveId, BuBytes out);
  int curveIdentity(int curveId, BuBytes out);
  int curveAdd(int curveId, BuBytes a, BuBytes b, BuBytes out);
  int curveSub(int curveId, BuBytes a, BuBytes b, BuBytes out);
  int curveNeg(int curveId, BuBytes point, BuBytes out);
  int curveMul(int curveId, BuBytes scalar, BuBytes point, BuBytes out);
  int curveMulBase(int curveId, BuBytes scalar, BuBytes out);
  int curveMulAdd(
    int curveId,
    BuBytes s1,
    BuBytes p1,
    BuBytes s2,
    BuBytes p2,
    BuBytes out,
  );
  int curveGenerateSecret(int curveId, BuBytes seed, BuBytes out);

  /// 1 = point at infinity, 0 = not, negative = malformed/unsupported.
  int curveIsInfinity(int curveId, BuBytes point);
  int curveScAdd(int curveId, BuBytes a, BuBytes b, BuBytes out);
  int curveScSub(int curveId, BuBytes a, BuBytes b, BuBytes out);
  int curveScMul(int curveId, BuBytes a, BuBytes b, BuBytes out);
  int curveScNeg(int curveId, BuBytes s, BuBytes out);
  int curveScReduce(int curveId, BuBytes s, BuBytes out);
  int ed25519ScReduce32(BuBytes in32, BuBytes out32);
  int ed25519ScReduce64(BuBytes in64, BuBytes out32);
  int ed25519FromFeBytes(BuBytes fe32, BuBytes out32);
  int ed25519FromFeBytesClearCofactor(BuBytes fe32, BuBytes out32);

  /// Monero hash_to_ec(data) → 32-byte point.
  int ed25519HashToEc(BuBytes data, BuBytes out32);
  int ed25519CheckKey(BuBytes pk32);
  int ed25519MulByCofactor(BuBytes point32, BuBytes out32);
  int ed25519ScalarmultKeyImage(BuBytes hp32, BuBytes a32, BuBytes out32);
  int ed25519Mul8Mult(BuBytes scalar32, BuBytes point32, BuBytes out32);

  /// Precomp table: 8×32 = 256 bytes.
  int ed25519GeDsmPrecomp(BuBytes point32, BuBytes out256);
  int ed25519GeDoubleScalarMultPrecomp(
    BuBytes a32,
    BuBytes aI256,
    BuBytes b32,
    BuBytes bI256,
    BuBytes out32,
  );
  int ed25519GeDoubleScalarMultBase(
    BuBytes a32,
    BuBytes gA32,
    BuBytes b32,
    BuBytes out32,
  );
  int ed25519GeTripleScalarMultBase(
    BuBytes a32,
    BuBytes b32,
    BuBytes bI256,
    BuBytes c32,
    BuBytes cI256,
    BuBytes out32,
  );
  int ed25519GeTripleScalarMultPrecomp(
    BuBytes a32,
    BuBytes aI256,
    BuBytes b32,
    BuBytes bI256,
    BuBytes c32,
    BuBytes cI256,
    BuBytes out32,
  );
  int jubjubScReduce64(BuBytes in64, BuBytes out32);

  /// Edwards32 → Ristretto32.
  int ristrettoFromEdwards(BuBytes ed32, BuBytes out32);

  /// Ristretto32 → Edwards32.
  int ristrettoToEdwards(BuBytes ristretto32, BuBytes out32);
  int pallasScReduce64(BuBytes in64, BuBytes out32);
  int vestaScReduce64(BuBytes in64, BuBytes out32);
  int blsHashToG1(BuBytes msg, BuBytes dst, BuBytes out48);
  int blsHashToG2(BuBytes msg, BuBytes dst, BuBytes out96);
  int pallasHashToCurve(BuBytes msg, BuBytes dst, BuBytes out);
  int pallasHashToCurvePasta(BuBytes msg, BuBytes personal, BuBytes out);
  int vestaHashToCurve(BuBytes msg, BuBytes dst, BuBytes out);

  // Ed25519 variable-time (public data only — faster)
  int ed25519MulVartime(BuBytes scalar32, BuBytes point32, BuBytes out32);
  int ed25519MulBaseVartime(BuBytes scalar32, BuBytes out32);
  int ed25519MulAddVartime(
    BuBytes s1,
    BuBytes p1,
    BuBytes s2,
    BuBytes p2,
    BuBytes out32,
  );
  int ed25519AddVartime(BuBytes a32, BuBytes b32, BuBytes out32);
  int ed25519SubVartime(BuBytes a32, BuBytes b32, BuBytes out32);
  int ed25519NegVartime(BuBytes p32, BuBytes out32);
  int ed25519DoubleVartime(BuBytes p32, BuBytes out32);
}
