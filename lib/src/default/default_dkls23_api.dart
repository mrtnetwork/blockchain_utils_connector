import 'package:blockchain_utils_connector/src/api/dkls23_api.dart';
import 'package:blockchain_utils_connector/src/bytes/bytes.dart';
import 'package:blockchain_utils_connector/src/error/bu_error.dart';
import 'package:blockchain_utils_connector/src/platform/bindings.dart';

class DefaultDkls23Api implements BuDkls23Api {
  DefaultDkls23Api(this._b);
  final BuPlatformBindings _b;

  BuResult<BuBytes> _mapBytes(int rc, BuBytes out) {
    if (rc == 0) {
      return BuResult.ok(out);
    }
    if (rc == 6) {
      return BuResult.err(
        BuError.unsupportedAlgo(
          message: 'DKLs23 is not available in this native build',
        ),
      );
    }
    if (rc == 2) {
      return BuResult.err(
        BuError(DefaultErrorType.invalidLength, 'invalid DKLs23 input length'),
      );
    }
    if (rc == 3) {
      return BuResult.err(
        BuError.key(message: 'invalid DKLs23 key or share encoding'),
      );
    }
    if (rc == 4) {
      return BuResult.err(BuError.verify());
    }
    return BuResult.err(
      BuError.internalErr(message: 'DKLs23 operation failed'),
    );
  }

  @override
  BuResult<BuBytes> dkg({
    required BuDkls23Curve curve,
    required BuBytes sid,
    required int n,
    required int t,
    required BuBytes seeds,
  }) {
    if (n == 0 || t == 0 || t > n) {
      return BuResult.err(BuError.invalidLength);
    }
    if (seeds.length != n * 32) {
      return BuResult.err(BuError.invalidLength);
    }
    final out = <BuBytes>[];
    final rc = _b.dkls23Dkg(
      curveId: curve.id,
      sid: sid,
      n: n,
      t: t,
      seedsConcat: seeds,
      outBlob: out,
    );
    if (rc != 0) {
      _mapBytes(rc, BuBytes.empty()).unwrapOrThrow();
    }
    if (out.isEmpty) {
      throw BuError.internalErr(message: 'DKLs23 dkg returned no blob');
    }
    return BuResult.ok(out.first);
  }

  @override
  BuResult<BuBytes> sign({
    required BuDkls23Curve curve,
    required BuBytes sid,
    required BuBytes msgHash32,
    required BuBytes sharesBlob,
    required BuBytes seeds,
  }) {
    if (msgHash32.length != 32) {
      return BuResult.err(BuError.invalidLength);
    }
    if (sharesBlob.isEmpty) {
      return BuResult.err(BuError.invalidLength);
    }
    final out = BuBytes.zero(64);
    final rc = _b.dkls23Sign(
      curveId: curve.id,
      sid: sid,
      msgHash32: msgHash32,
      sharesBlob: sharesBlob,
      seedsConcat: seeds,
      out64: out,
    );
    return _mapBytes(rc, out);
  }

  @override
  BuResult<BuBytes> refresh({
    required BuBytes sid,
    required BuBytes sharesBlob,
    required BuBytes seeds,
  }) {
    if (sharesBlob.isEmpty) {
      return BuResult.err(BuError.invalidLength);
    }
    final out = <BuBytes>[];
    final rc = _b.dkls23Refresh(
      sid: sid,
      sharesBlob: sharesBlob,
      seedsConcat: seeds,
      outBlob: out,
    );
    if (rc != 0) {
      _mapBytes(rc, BuBytes.empty()).unwrapOrThrow();
    }
    if (out.isEmpty) {
      throw BuError.internalErr(message: 'DKLs23 refresh returned no blob');
    }
    return BuResult.ok(out.first);
  }

  @override
  BuResult<bool> verify({
    required BuDkls23Curve curve,
    required BuBytes groupPk33,
    required BuBytes msgHash32,
    required BuBytes sig64,
  }) {
    if (groupPk33.length != 33 ||
        msgHash32.length != 32 ||
        sig64.length != 64) {
      return BuResult.err(BuError.invalidLength);
    }
    final rc = _b.dkls23Verify(
      curveId: curve.id,
      groupPk33: groupPk33,
      msgHash32: msgHash32,
      sig64: sig64,
    );
    if (rc == 0) {
      return BuResult.ok(true);
    }
    if (rc == 4) {
      return BuResult.ok(false);
    }
    if (rc == 6) {
      return BuResult.err(BuError.unsupported);
    }
    return BuResult.err(
      BuError(DefaultErrorType.internal, 'dkls23_verify $rc'),
    );
  }

  @override
  BuResult<BuBytes> aggKeys({
    required BuDkls23Curve curve,
    required BuBytes membersConcat,
    required int n,
  }) {
    if (n < 2 || membersConcat.length != n * 33) {
      return BuResult.err(BuError.invalidLength);
    }
    final out = BuBytes.zero(33);
    final rc = _b.dkls23AggKeys(
      curveId: curve.id,
      membersConcat: membersConcat,
      n: n,
      out33: out,
    );
    return _mapBytes(rc, out);
  }

  @override
  BuResult<BuBytes> importSecrets({
    required BuDkls23Curve curve,
    required BuBytes secretsConcat,
    required int n,
  }) {
    if (n < 2 || secretsConcat.length != n * 32) {
      return BuResult.err(BuError.invalidLength);
    }
    final out = <BuBytes>[];
    final rc = _b.dkls23ImportSecrets(
      curveId: curve.id,
      secretsConcat: secretsConcat,
      n: n,
      outBlob: out,
    );
    if (rc != 0) {
      _mapBytes(rc, BuBytes.empty()).unwrapOrThrow();
    }
    if (out.isEmpty) {
      throw BuError.internalErr(message: 'DKLs23 import returned no blob');
    }
    return BuResult.ok(out.first);
  }

  @override
  BuResult<BuBytes> xOnly({
    required BuDkls23Curve curve,
    required BuBytes groupPk33,
  }) {
    if (groupPk33.length != 33) {
      return BuResult.err(BuError.invalidLength);
    }
    final out = BuBytes.zero(32);
    final rc = _b.dkls23XOnly(
      curveId: curve.id,
      groupPk33: groupPk33,
      out32: out,
    );
    return _mapBytes(rc, out);
  }
}
