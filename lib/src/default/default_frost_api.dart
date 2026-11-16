import 'package:blockchain_utils_connector/src/api/frost_api.dart';
import 'package:blockchain_utils_connector/src/bytes/bytes.dart';
import 'package:blockchain_utils_connector/src/error/bu_error.dart';
import 'package:blockchain_utils_connector/src/platform/bindings.dart';

class DefaultFrostApi implements BuFrostApi {
  DefaultFrostApi(this._b);
  final BuPlatformBindings _b;

  BuResult<BuBytes> _map(int rc, BuBytes out) {
    if (rc == 0) {
      return BuResult.ok(out);
    }
    if (rc == 6) {
      return BuResult.err(
        BuError.unsupportedAlgo(
          message: 'FROST is not available in this native build',
        ),
      );
    }
    if (rc == 2) {
      return BuResult.err(
        BuError(DefaultErrorType.invalidLength, 'invalid FROST input length'),
      );
    }
    if (rc == 3) {
      return BuResult.err(
        BuError.key(message: 'invalid FROST key or commitment encoding'),
      );
    }
    if (rc == 4) {
      return BuResult.err(BuError.verify());
    }
    return BuResult.err(BuError.internalErr(message: 'FROST operation failed'));
  }

  BuResult<bool> _mapVerify(int rc) {
    if (rc == 0) {
      return BuResult.ok(true);
    }
    if (rc == 4) {
      return BuResult.ok(false);
    }
    if (rc == 6) {
      return BuResult.err(BuError.unsupported);
    }
    return BuResult.err(BuError(DefaultErrorType.internal, 'frost_verify $rc'));
  }

  BuBytes _encodeCommitment(int id, BuBytes hiding, BuBytes binding) {
    final out = BuBytes.zero(4 + hiding.length + binding.length);
    out[0] = id & 0xff;
    out[1] = (id >> 8) & 0xff;
    out[2] = (id >> 16) & 0xff;
    out[3] = (id >> 24) & 0xff;
    for (var i = 0; i < hiding.length; i++) {
      out[4 + i] = hiding[i];
    }
    for (var i = 0; i < binding.length; i++) {
      out[4 + hiding.length + i] = binding[i];
    }
    return out;
  }

  // -- secp256k1 suite --
  @override
  BuResult<BuFrostShard> frostK1Shard({
    required BuBytes secret32,
    required BuBytes coeffsConcat,
    required int nCoeffs,
    required int max,
  }) {
    if (secret32.length != 32) {
      return BuResult.err(BuError.invalidLength);
    }
    if (coeffsConcat.length != nCoeffs * 32) {
      return BuResult.err(BuError.invalidLength);
    }
    if (max <= 0) {
      return BuResult.err(BuError.invalidLength);
    }
    final shares = BuBytes.zero(max * 36);
    final poly = BuBytes.zero((1 + nCoeffs) * 32);
    final rc = _b.frostK1Shard(
      secret32,
      coeffsConcat,
      nCoeffs,
      max,
      shares,
      poly,
    );
    if (rc != 0) {
      final e = _map(rc, shares);
      return BuResult.err(e.error!);
    }
    return BuResult.ok(BuFrostShard(sharesConcat: shares, polyConcat: poly));
  }

  @override
  BuResult<BuBytes> frostK1Combine(BuBytes sharesConcat, int n) {
    if (sharesConcat.length != n * 36 || n == 0) {
      return BuResult.err(BuError.invalidLength);
    }
    final out = BuBytes.zero(32);
    final rc = _b.frostK1Combine(sharesConcat, n, out);
    return _map(rc, out);
  }

  @override
  BuResult<BuFrostNonces> frostK1Commit({
    required BuBytes secretShare32,
    required BuBytes hidingRand32,
    required BuBytes bindingRand32,
  }) {
    if (secretShare32.length != 32 ||
        hidingRand32.length != 32 ||
        bindingRand32.length != 32) {
      return BuResult.err(BuError.invalidLength);
    }
    final hiding = BuBytes.zero(32);
    final binding = BuBytes.zero(32);
    final hc = BuBytes.zero(33);
    final bc = BuBytes.zero(33);
    final rc = _b.frostK1Commit(
      secretShare32,
      hidingRand32,
      bindingRand32,
      hiding,
      binding,
      hc,
      bc,
    );
    if (rc != 0) {
      final e = _map(rc, hiding);
      return BuResult.err(e.error!);
    }
    return BuResult.ok(
      BuFrostNonces(
        hiding: hiding,
        binding: binding,
        hidingCommitment: hc,
        bindingCommitment: bc,
      ),
    );
  }

  @override
  BuResult<BuBytes> frostK1BindingFactors({
    required BuBytes groupPk33,
    required BuBytes commitmentsConcat,
    required int n,
    required BuBytes msg,
  }) {
    if (groupPk33.length != 33) {
      return BuResult.err(BuError.invalidLength);
    }
    if (commitmentsConcat.length != n * 70 || n == 0) {
      return BuResult.err(BuError.invalidLength);
    }
    final out = BuBytes.zero(n * 36);
    final rc = _b.frostK1BindingFactors(
      groupPk33,
      commitmentsConcat,
      n,
      msg,
      out,
    );
    return _map(rc, out);
  }

  @override
  BuResult<BuBytes> frostK1GroupCommitment({
    required BuBytes commitmentsConcat,
    required BuBytes factorsConcat,
    required int n,
  }) {
    if (commitmentsConcat.length != n * 70 ||
        factorsConcat.length != n * 36 ||
        n == 0) {
      return BuResult.err(BuError.invalidLength);
    }
    final out = BuBytes.zero(33);
    final rc = _b.frostK1GroupCommitment(
      commitmentsConcat,
      factorsConcat,
      n,
      out,
    );
    return _map(rc, out);
  }

  @override
  BuResult<BuBytes> frostK1Sign({
    required int id,
    required BuBytes secretShare32,
    required BuBytes groupPk33,
    required BuFrostNonces nonces,
    required BuBytes commitmentsConcat,
    required int n,
    required BuBytes msg,
  }) {
    if (secretShare32.length != 32 || groupPk33.length != 33) {
      return BuResult.err(BuError.invalidLength);
    }
    if (commitmentsConcat.length != n * 70 || n == 0) {
      return BuResult.err(BuError.invalidLength);
    }
    final out = BuBytes.zero(32);
    final rc = _b.frostK1Sign(
      id,
      secretShare32,
      groupPk33,
      nonces.hiding,
      nonces.binding,
      nonces.hidingCommitment,
      nonces.bindingCommitment,
      commitmentsConcat,
      n,
      msg,
      out,
    );
    return _map(rc, out);
  }

  @override
  BuResult<BuFrostSignature> frostK1Aggregate({
    required BuBytes commitmentsConcat,
    required int n,
    required BuBytes msg,
    required BuBytes groupPk33,
    required BuBytes sharesConcat,
    required int nShares,
  }) {
    if (commitmentsConcat.length != n * 70 || n == 0) {
      return BuResult.err(BuError.invalidLength);
    }
    if (groupPk33.length != 33) {
      return BuResult.err(BuError.invalidLength);
    }
    if (sharesConcat.length != nShares * 32 || nShares == 0) {
      return BuResult.err(BuError.invalidLength);
    }
    final r = BuBytes.zero(33);
    final z = BuBytes.zero(32);
    final rc = _b.frostK1Aggregate(
      commitmentsConcat,
      n,
      msg,
      groupPk33,
      sharesConcat,
      nShares,
      r,
      z,
    );
    if (rc != 0) {
      final e = _map(rc, r);
      return BuResult.err(e.error!);
    }
    return BuResult.ok(BuFrostSignature(r: r, z: z));
  }

  @override
  BuResult<bool> frostK1VerifyShare({
    required int id,
    required BuBytes pkShare33,
    required BuFrostCommitment comm,
    required BuBytes share32,
    required BuBytes commitmentsConcat,
    required int n,
    required BuBytes groupPk33,
    required BuBytes msg,
  }) {
    if (pkShare33.length != 33 || share32.length != 32) {
      return BuResult.err(BuError.invalidLength);
    }
    if (comm.hiding.length != 33 || comm.binding.length != 33) {
      return BuResult.err(BuError.invalidLength);
    }
    if (groupPk33.length != 33) {
      return BuResult.err(BuError.invalidLength);
    }
    if (commitmentsConcat.length != n * 70 || n == 0) {
      return BuResult.err(BuError.invalidLength);
    }
    final rec = _encodeCommitment(id, comm.hiding, comm.binding);
    final rc = _b.frostK1VerifyShare(
      id,
      pkShare33,
      rec,
      share32,
      commitmentsConcat,
      n,
      groupPk33,
      msg,
    );
    return _mapVerify(rc);
  }

  @override
  BuResult<BuBytes> frostK1PrepareShares({
    required BuBytes sharesConcat,
    required int n,
    required int threshold,
  }) {
    if (sharesConcat.length != n * 36 || n == 0) {
      return BuResult.err(BuError.invalidLength);
    }
    final out = BuBytes.zero(n * 32);
    final rc = _b.frostK1PrepareShares(sharesConcat, n, threshold, out);
    return _map(rc, out);
  }

  @override
  BuResult<BuBytes> frostK1GroupFromMembers({
    required BuBytes idsConcat,
    required BuBytes pubsConcat,
    required int n,
    required int threshold,
  }) {
    if (idsConcat.length != n * 4 || pubsConcat.length != n * 33 || n == 0) {
      return BuResult.err(BuError.invalidLength);
    }
    final out = BuBytes.zero(33);
    final rc = _b.frostK1GroupFromMembers(
      idsConcat,
      pubsConcat,
      n,
      threshold,
      out,
    );
    return _map(rc, out);
  }

  @override
  BuResult<BuFrostGroupInfo> frostK1GroupInfo({
    required BuBytes vssConcat,
    required int nComms,
    required int max,
  }) {
    if (vssConcat.length != nComms * 33 || nComms == 0 || max <= 0) {
      return BuResult.err(BuError.invalidLength);
    }
    final group = BuBytes.zero(33);
    final pks = BuBytes.zero(max * 33);
    final rc = _b.frostK1GroupInfo(vssConcat, nComms, max, group, pks);
    if (rc != 0) {
      final e = _map(rc, group);
      return BuResult.err(e.error!);
    }
    return BuResult.ok(BuFrostGroupInfo(group: group, pksConcat: pks));
  }

  @override
  BuResult<BuFrostReshare> frostK1Reshare({
    required BuBytes idsConcat,
    required BuBytes secretsConcat,
    required int n,
    required BuBytes coeffsConcat,
    required int nCoeffs,
    required int threshold,
  }) {
    if (n < 2 || threshold < 2 || threshold > n) {
      return BuResult.err(BuError.invalidLength);
    }
    if (idsConcat.length != n * 4 ||
        secretsConcat.length != n * 32 ||
        coeffsConcat.length != nCoeffs * 32 ||
        nCoeffs != n * (threshold - 1)) {
      return BuResult.err(BuError.invalidLength);
    }
    final shares = BuBytes.zero(n * 32);
    final pubs = BuBytes.zero(n * 33);
    final group = BuBytes.zero(33);
    final rc = _b.frostK1Reshare(
      idsConcat,
      secretsConcat,
      n,
      coeffsConcat,
      nCoeffs,
      threshold,
      shares,
      pubs,
      group,
    );
    if (rc != 0) {
      final e = _map(rc, shares);
      return BuResult.err(e.error!);
    }
    return BuResult.ok(
      BuFrostReshare(sharesConcat: shares, pubsConcat: pubs, group: group),
    );
  }

  @override
  BuResult<bool> frostK1Verify({
    required BuBytes r33,
    required BuBytes z32,
    required BuBytes groupPk33,
    required BuBytes msg,
  }) {
    if (r33.length != 33 || z32.length != 32 || groupPk33.length != 33) {
      return BuResult.err(BuError.invalidLength);
    }
    final rc = _b.frostK1Verify(r33, z32, groupPk33, msg);
    return _mapVerify(rc);
  }

  @override
  BuResult<BuBytes> frostK1VssCommit({
    required BuBytes coeffsConcat,
    required int nCoeffs,
  }) {
    if (coeffsConcat.length != nCoeffs * 32 || nCoeffs == 0) {
      return BuResult.err(BuError.invalidLength);
    }
    final out = BuBytes.zero(nCoeffs * 33);
    final rc = _b.frostK1VssCommit(coeffsConcat, nCoeffs, out);
    return _map(rc, out);
  }

  // -- Ed25519 suite --
  @override
  BuResult<BuFrostShard> frostEdShard({
    required BuBytes secret32,
    required BuBytes coeffsConcat,
    required int nCoeffs,
    required int max,
    bool isScalar = true,
  }) {
    if (secret32.length != 32) {
      return BuResult.err(BuError.invalidLength);
    }
    if (coeffsConcat.length != nCoeffs * 32) {
      return BuResult.err(BuError.invalidLength);
    }
    if (max <= 0) {
      return BuResult.err(BuError.invalidLength);
    }
    final shares = BuBytes.zero(max * 36);
    final poly = BuBytes.zero((1 + nCoeffs) * 32);
    final rc = _b.frostEdShard(
      secret32,
      coeffsConcat,
      nCoeffs,
      max,
      shares,
      poly,
      isScalar: isScalar,
    );
    if (rc != 0) {
      final e = _map(rc, shares);
      return BuResult.err(e.error!);
    }
    return BuResult.ok(BuFrostShard(sharesConcat: shares, polyConcat: poly));
  }

  @override
  BuResult<BuBytes> frostEdCombine(
    BuBytes sharesConcat,
    int n, {
    bool isScalar = true,
  }) {
    if (sharesConcat.length != n * 36 || n == 0) {
      return BuResult.err(BuError.invalidLength);
    }
    final out = BuBytes.zero(32);
    final rc = _b.frostEdCombine(sharesConcat, n, out, isScalar: isScalar);
    return _map(rc, out);
  }

  @override
  BuResult<BuFrostNonces> frostEdCommit({
    required BuBytes secretShare32,
    required BuBytes hidingRand32,
    required BuBytes bindingRand32,
    bool isScalar = true,
  }) {
    if (secretShare32.length != 32 ||
        hidingRand32.length != 32 ||
        bindingRand32.length != 32) {
      return BuResult.err(BuError.invalidLength);
    }
    final hiding = BuBytes.zero(32);
    final binding = BuBytes.zero(32);
    final hc = BuBytes.zero(32);
    final bc = BuBytes.zero(32);
    final rc = _b.frostEdCommit(
      secretShare32,
      hidingRand32,
      bindingRand32,
      hiding,
      binding,
      hc,
      bc,
      isScalar: isScalar,
    );
    if (rc != 0) {
      final e = _map(rc, hiding);
      return BuResult.err(e.error!);
    }
    return BuResult.ok(
      BuFrostNonces(
        hiding: hiding,
        binding: binding,
        hidingCommitment: hc,
        bindingCommitment: bc,
      ),
    );
  }

  @override
  BuResult<BuBytes> frostEdBindingFactors({
    required BuBytes groupPk32,
    required BuBytes commitmentsConcat,
    required int n,
    required BuBytes msg,
  }) {
    if (groupPk32.length != 32) {
      return BuResult.err(BuError.invalidLength);
    }
    if (commitmentsConcat.length != n * 68 || n == 0) {
      return BuResult.err(BuError.invalidLength);
    }
    final out = BuBytes.zero(n * 36);
    final rc = _b.frostEdBindingFactors(
      groupPk32,
      commitmentsConcat,
      n,
      msg,
      out,
    );
    return _map(rc, out);
  }

  @override
  BuResult<BuBytes> frostEdGroupCommitment({
    required BuBytes commitmentsConcat,
    required BuBytes factorsConcat,
    required int n,
  }) {
    if (commitmentsConcat.length != n * 68 ||
        factorsConcat.length != n * 36 ||
        n == 0) {
      return BuResult.err(BuError.invalidLength);
    }
    final out = BuBytes.zero(32);
    final rc = _b.frostEdGroupCommitment(
      commitmentsConcat,
      factorsConcat,
      n,
      out,
    );
    return _map(rc, out);
  }

  @override
  BuResult<BuBytes> frostEdSign({
    required int id,
    required BuBytes secretShare32,
    required BuBytes groupPk32,
    required BuFrostNonces nonces,
    required BuBytes commitmentsConcat,
    required int n,
    required BuBytes msg,
    bool isScalar = true,
  }) {
    if (secretShare32.length != 32 || groupPk32.length != 32) {
      return BuResult.err(BuError.invalidLength);
    }
    if (commitmentsConcat.length != n * 68 || n == 0) {
      return BuResult.err(BuError.invalidLength);
    }
    final out = BuBytes.zero(32);
    final rc = _b.frostEdSign(
      id,
      secretShare32,
      groupPk32,
      nonces.hiding,
      nonces.binding,
      nonces.hidingCommitment,
      nonces.bindingCommitment,
      commitmentsConcat,
      n,
      msg,
      out,
      isScalar: isScalar,
    );
    return _map(rc, out);
  }

  @override
  BuResult<BuFrostSignature> frostEdAggregate({
    required BuBytes commitmentsConcat,
    required int n,
    required BuBytes msg,
    required BuBytes groupPk32,
    required BuBytes sharesConcat,
    required int nShares,
  }) {
    if (commitmentsConcat.length != n * 68 || n == 0) {
      return BuResult.err(BuError.invalidLength);
    }
    if (groupPk32.length != 32) {
      return BuResult.err(BuError.invalidLength);
    }
    if (sharesConcat.length != nShares * 32 || nShares == 0) {
      return BuResult.err(BuError.invalidLength);
    }
    final r = BuBytes.zero(32);
    final z = BuBytes.zero(32);
    final rc = _b.frostEdAggregate(
      commitmentsConcat,
      n,
      msg,
      groupPk32,
      sharesConcat,
      nShares,
      r,
      z,
    );
    if (rc != 0) {
      final e = _map(rc, r);
      return BuResult.err(e.error!);
    }
    return BuResult.ok(BuFrostSignature(r: r, z: z));
  }

  @override
  BuResult<bool> frostEdVerifyShare({
    required int id,
    required BuBytes pkShare32,
    required BuFrostCommitment comm,
    required BuBytes share32,
    required BuBytes commitmentsConcat,
    required int n,
    required BuBytes groupPk32,
    required BuBytes msg,
  }) {
    if (pkShare32.length != 32 || share32.length != 32) {
      return BuResult.err(BuError.invalidLength);
    }
    if (comm.hiding.length != 32 || comm.binding.length != 32) {
      return BuResult.err(BuError.invalidLength);
    }
    if (groupPk32.length != 32) {
      return BuResult.err(BuError.invalidLength);
    }
    if (commitmentsConcat.length != n * 68 || n == 0) {
      return BuResult.err(BuError.invalidLength);
    }
    final rec = _encodeCommitment(id, comm.hiding, comm.binding);
    final rc = _b.frostEdVerifyShare(
      id,
      pkShare32,
      rec,
      share32,
      commitmentsConcat,
      n,
      groupPk32,
      msg,
    );
    return _mapVerify(rc);
  }

  @override
  BuResult<BuBytes> frostEdPrepareShares({
    required BuBytes sharesConcat,
    required int n,
    required int threshold,
    bool isScalar = true,
  }) {
    if (sharesConcat.length != n * 36 || n == 0) {
      return BuResult.err(BuError.invalidLength);
    }
    final out = BuBytes.zero(n * 32);
    final rc = _b.frostEdPrepareShares(
      sharesConcat,
      n,
      threshold,
      out,
      isScalar: isScalar,
    );
    return _map(rc, out);
  }

  @override
  BuResult<BuBytes> frostEdGroupFromMembers({
    required BuBytes idsConcat,
    required BuBytes pubsConcat,
    required int n,
    required int threshold,
  }) {
    if (idsConcat.length != n * 4 || pubsConcat.length != n * 32 || n == 0) {
      return BuResult.err(BuError.invalidLength);
    }
    final out = BuBytes.zero(32);
    final rc = _b.frostEdGroupFromMembers(
      idsConcat,
      pubsConcat,
      n,
      threshold,
      out,
    );
    return _map(rc, out);
  }

  @override
  BuResult<BuFrostGroupInfo> frostEdGroupInfo({
    required BuBytes vssConcat,
    required int nComms,
    required int max,
  }) {
    if (vssConcat.length != nComms * 32 || nComms == 0 || max <= 0) {
      return BuResult.err(BuError.invalidLength);
    }
    final group = BuBytes.zero(32);
    final pks = BuBytes.zero(max * 32);
    final rc = _b.frostEdGroupInfo(vssConcat, nComms, max, group, pks);
    if (rc != 0) {
      final e = _map(rc, group);
      return BuResult.err(e.error!);
    }
    return BuResult.ok(BuFrostGroupInfo(group: group, pksConcat: pks));
  }

  @override
  BuResult<BuFrostReshare> frostEdReshare({
    required BuBytes idsConcat,
    required BuBytes secretsConcat,
    required int n,
    required BuBytes coeffsConcat,
    required int nCoeffs,
    required int threshold,
  }) {
    if (n < 2 || threshold < 2 || threshold > n) {
      return BuResult.err(BuError.invalidLength);
    }
    if (idsConcat.length != n * 4 ||
        secretsConcat.length != n * 32 ||
        coeffsConcat.length != nCoeffs * 32 ||
        nCoeffs != n * (threshold - 1)) {
      return BuResult.err(BuError.invalidLength);
    }
    final shares = BuBytes.zero(n * 32);
    final pubs = BuBytes.zero(n * 32);
    final group = BuBytes.zero(32);
    final rc = _b.frostEdReshare(
      idsConcat,
      secretsConcat,
      n,
      coeffsConcat,
      nCoeffs,
      threshold,
      shares,
      pubs,
      group,
    );
    if (rc != 0) {
      final e = _map(rc, shares);
      return BuResult.err(e.error!);
    }
    return BuResult.ok(
      BuFrostReshare(sharesConcat: shares, pubsConcat: pubs, group: group),
    );
  }

  @override
  BuResult<bool> frostEdVerify({
    required BuBytes r32,
    required BuBytes z32,
    required BuBytes groupPk32,
    required BuBytes msg,
  }) {
    if (r32.length != 32 || z32.length != 32 || groupPk32.length != 32) {
      return BuResult.err(BuError.invalidLength);
    }
    final rc = _b.frostEdVerify(r32, z32, groupPk32, msg);
    return _mapVerify(rc);
  }

  @override
  BuResult<BuBytes> frostEdVssCommit({
    required BuBytes coeffsConcat,
    required int nCoeffs,
  }) {
    if (coeffsConcat.length != nCoeffs * 32 || nCoeffs == 0) {
      return BuResult.err(BuError.invalidLength);
    }
    final out = BuBytes.zero(nCoeffs * 32);
    final rc = _b.frostEdVssCommit(coeffsConcat, nCoeffs, out);
    return _map(rc, out);
  }
}
