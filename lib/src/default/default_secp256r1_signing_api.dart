import 'package:blockchain_utils_connector/src/api/secp256k1_signing_api.dart'
    show BuEcdsaSignature;
import 'package:blockchain_utils_connector/src/api/secp256r1_signing_api.dart';
import 'package:blockchain_utils_connector/src/api/curve_id.dart';
import 'package:blockchain_utils_connector/src/bytes/bytes.dart';
import 'package:blockchain_utils_connector/src/error/bu_error.dart';
import 'package:blockchain_utils_connector/src/platform/bindings.dart';

class DefaultSecp256r1SigningApi implements BuSecp256r1SigningApi {
  DefaultSecp256r1SigningApi(this._b);
  final BuPlatformBindings _b;

  @override
  BuResult<BuBytes> publicKey(BuBytes sk) {
    final out = BuBytes.zero(33);
    final k = BuBytes.owned(sk);
    try {
      final rc = _b.ecdsaR1PublicKey(k, out);
      return rc == 0
          ? BuResult.ok(out)
          : BuResult.err(BuError.fromNativeCode(rc));
    } finally {
      k.zero();
    }
  }

  @override
  BuResult<BuEcdsaSignature> signEcdsa(
    BuBytes sk,
    BuSecp256r1SignParams params,
  ) {
    final out = BuBytes.zero(64);
    final k = BuBytes.owned(sk);
    try {
      final rc =
          params.extraEntropy == null
              ? _b.ecdsaR1Sign(k, params.digest, out)
              : _b.ecdsaR1SignEx(k, params.digest, params.extraEntropy, out);
      if (rc != 0) {
        return BuResult.err(BuError.fromNativeCode(rc));
      }
      int? recId;
      final idOut = BuBytes.zero(1);
      final pk = BuBytes.zero(33);
      if (_b.ecdsaR1PublicKey(k, pk) == 0) {
        final idRc = _b.ecdsaR1RecoveryId(params.digest, out, pk, idOut);
        if (idRc == 0) recId = idOut[0];
      }
      return BuResult.ok(BuEcdsaSignature.fromCompact(out, recoveryId: recId));
    } finally {
      k.zero();
    }
  }

  @override
  BuResult<bool> verifyEcdsa({
    required BuBytes pk,
    required BuBytes digest,
    required BuEcdsaSignature signature,
  }) => BuResult.ok(_b.ecdsaR1Verify(pk, digest, signature.compact) == 0);

  @override
  bool isValidPublicKey(List<int> publicKey) {
    if (publicKey.length != 33 && publicKey.length != 65) {
      return false;
    }
    final pk = BuBytes.from(publicKey);
    final one = BuBytes.zero(32)..[31] = 1;
    final out = BuBytes.zero(33);
    return _b.curveMul(BuCurveId.secp256r1, one, pk, out) == 0;
  }

  @override
  bool isValidSecretKey(List<int> secret) {
    if (secret.length != 32) {
      return false;
    }
    final s = BuBytes.from(secret);
    return _b.curveScCheck(BuCurveId.secp256r1, s) == 1;
  }

  @override
  BuResult<BuBytes> normalizePublicKey(List<int> publicKey) {
    final n = _b.curvePointLen(BuCurveId.secp256r1);
    if (n <= 0) {
      return BuResult.err(BuError.internalErr(message: 'unknown point length'));
    }
    final out = BuBytes.zero(n);
    final pk = BuBytes.from(publicKey);
    final rc = _b.curveNormalizePubkey(BuCurveId.secp256r1, pk, out);
    if (rc != 0) {
      return BuResult.err(BuError.fromNativeCode(rc));
    }
    return BuResult.ok(out);
  }
}
