import 'package:blockchain_utils_connector/src/api/bls_signing_api.dart';
import 'package:blockchain_utils_connector/src/api/curve_id.dart';
import 'package:blockchain_utils_connector/src/bytes/bytes.dart';
import 'package:blockchain_utils_connector/src/error/bu_error.dart';
import 'package:blockchain_utils_connector/src/platform/bindings.dart';

class DefaultBlsSigningApi implements BuBlsSigningApi {
  DefaultBlsSigningApi(this._b);
  final BuPlatformBindings _b;

  BuResult<BuBytes> _map(int rc, BuBytes out) {
    if (rc == 0) {
      return BuResult.ok(out);
    }
    if (rc == 6) {
      return BuResult.err(BuError.unsupported);
    }
    return BuResult.err(BuError(DefaultErrorType.internal, 'bls error $rc'));
  }

  BuResult<bool> _mapBool(int rc) {
    if (rc == 0) {
      return BuResult.ok(true);
    }
    if (rc == 6) {
      return BuResult.err(BuError.unsupported);
    }
    // BLS verify/agg failure is a normal false, not unsupported
    return BuResult.ok(false);
  }

  @override
  BuResult<BuBytes> publicKeyG1(BuBytes sk) {
    final out = BuBytes.zero(48);
    final k = BuBytes.owned(sk);
    try {
      return _map(_b.blsPublicKeyG1(k, out), out);
    } finally {
      k.zero();
    }
  }

  @override
  BuResult<BuBytes> publicKeyG2(BuBytes sk) {
    final out = BuBytes.zero(96);
    final k = BuBytes.owned(sk);
    try {
      return _map(_b.blsPublicKeyG2(k, out), out);
    } finally {
      k.zero();
    }
  }

  @override
  BuResult<BuBytes> signMinPk({
    required BuBytes sk,
    required BuBytes message,
    BuBytes? dst,
  }) {
    final out = BuBytes.zero(96);
    final k = BuBytes.owned(sk);
    try {
      return _map(_b.blsSignMinPk(k, message, dst, out), out);
    } finally {
      k.zero();
    }
  }

  @override
  BuResult<BuBytes> signMinSig({
    required BuBytes sk,
    required BuBytes message,
    BuBytes? dst,
  }) {
    final out = BuBytes.zero(48);
    final k = BuBytes.owned(sk);
    try {
      return _map(_b.blsSignMinSig(k, message, dst, out), out);
    } finally {
      k.zero();
    }
  }

  @override
  BuResult<bool> verifyMinPk({
    required BuBytes pk,
    required BuBytes message,
    required BuBytes signature,
    BuBytes? dst,
  }) => _mapBool(_b.blsVerifyMinPk(pk, message, signature, dst));

  @override
  BuResult<bool> verifyMinSig({
    required BuBytes pk,
    required BuBytes message,
    required BuBytes signature,
    BuBytes? dst,
  }) => _mapBool(_b.blsVerifyMinSig(pk, message, signature, dst));

  @override
  BuResult<BuBytes> aggregatePublicKeysG1(BuBytes pksConcat) {
    final out = BuBytes.zero(48);
    return _map(_b.blsAggregatePublicKeysG1(pksConcat, out), out);
  }

  @override
  BuResult<BuBytes> aggregatePublicKeysG2(BuBytes pksConcat) {
    final out = BuBytes.zero(96);
    return _map(_b.blsAggregatePublicKeysG2(pksConcat, out), out);
  }

  @override
  BuResult<BuBytes> aggregateSignaturesG1(BuBytes sigsConcat) {
    if (sigsConcat.isEmpty) {
      return BuResult.err(BuError.invalidLength);
    }
    // Prefer G1 (48-byte chunks). Footgun: min-pk path often passes G2 (96-byte) sigs here.
    if (sigsConcat.length % 48 == 0) {
      final out = BuBytes.zero(48);
      final rc = _b.blsAggregateSignaturesG1(sigsConcat, out);
      if (rc == 0) {
        return BuResult.ok(out);
      }
    }
    if (sigsConcat.length % 96 == 0) {
      final out = BuBytes.zero(96);
      final rc = _b.blsAggregateSignaturesG2(sigsConcat, out);
      if (rc == 0) {
        return BuResult.ok(out);
      }
    }
    return BuResult.err(
      BuError(
        DefaultErrorType.invalidArgument,
        'aggregateSignaturesG1: expected 48-byte G1 sigs '
        '(or 96-byte G2); len=${sigsConcat.length}',
      ),
    );
  }

  @override
  BuResult<BuBytes> aggregateSignaturesG2(BuBytes sigsConcat) {
    if (sigsConcat.isEmpty) {
      return BuResult.err(BuError.invalidLength);
    }
    // Prefer G2 (96-byte chunks). Footgun: min-sig path often passes G1 (48-byte) sigs here.
    if (sigsConcat.length % 96 == 0) {
      final out = BuBytes.zero(96);
      final rc = _b.blsAggregateSignaturesG2(sigsConcat, out);
      if (rc == 0) {
        return BuResult.ok(out);
      }
    }
    if (sigsConcat.length % 48 == 0) {
      final out = BuBytes.zero(48);
      final rc = _b.blsAggregateSignaturesG1(sigsConcat, out);
      if (rc == 0) {
        return BuResult.ok(out);
      }
    }
    return BuResult.err(
      BuError(
        DefaultErrorType.invalidArgument,
        'aggregateSignaturesG2: expected 96-byte G2 sigs '
        '(or 48-byte G1); len=${sigsConcat.length}',
      ),
    );
  }

  @override
  BuResult<bool> fastAggregateVerifyMinPk({
    required BuBytes aggregatePublicKey,
    required BuBytes message,
    required BuBytes signature,
    BuBytes? dst,
  }) => _mapBool(
    _b.blsFastAggregateVerifyMinPk(aggregatePublicKey, message, signature, dst),
  );

  @override
  BuResult<bool> fastAggregateVerifyMinSig({
    required BuBytes aggregatePublicKey,
    required BuBytes message,
    required BuBytes signature,
    BuBytes? dst,
  }) => _mapBool(
    _b.blsFastAggregateVerifyMinSig(
      aggregatePublicKey,
      message,
      signature,
      dst,
    ),
  );

  @override
  BuResult<bool> aggregateVerifyMinPk({
    required BuBytes pksConcat,
    required BuBytes messagesBlob,
    required int messageCount,
    required BuBytes signature,
    BuBytes? dst,
  }) => _mapBool(
    _b.blsAggregateVerifyMinPk(
      pksConcat,
      messagesBlob,
      messageCount,
      signature,
      dst,
    ),
  );

  @override
  BuResult<bool> aggregateVerifyMinSig({
    required BuBytes pksConcat,
    required BuBytes messagesBlob,
    required int messageCount,
    required BuBytes signature,
    BuBytes? dst,
  }) => _mapBool(
    _b.blsAggregateVerifyMinSig(
      pksConcat,
      messagesBlob,
      messageCount,
      signature,
      dst,
    ),
  );

  @override
  BuResult<bool> batchVerifyMinPk({
    required BuBytes pksConcat,
    required BuBytes messagesBlob,
    required int messageCount,
    required BuBytes sigsConcat,
    BuBytes? dst,
  }) => _mapBool(
    _b.blsBatchVerifyMinPk(
      pksConcat,
      messagesBlob,
      messageCount,
      sigsConcat,
      dst,
    ),
  );

  @override
  BuResult<bool> batchVerifyMinSig({
    required BuBytes pksConcat,
    required BuBytes messagesBlob,
    required int messageCount,
    required BuBytes sigsConcat,
    BuBytes? dst,
  }) => _mapBool(
    _b.blsBatchVerifyMinSig(
      pksConcat,
      messagesBlob,
      messageCount,
      sigsConcat,
      dst,
    ),
  );

  @override
  bool isValidPublicKeyG1(List<int> publicKey) {
    if (publicKey.length != 48) {
      return false;
    }
    final pk = BuBytes.from(publicKey);
    final one = BuBytes.zero(32)..[0] = 1; // LE for BLS FFI scalars
    final out = BuBytes.zero(48);
    return _b.curveMul(BuCurveId.bls12G1, one, pk, out) == 0;
  }

  @override
  bool isValidPublicKeyG2(List<int> publicKey) {
    if (publicKey.length != 96) {
      return false;
    }
    final pk = BuBytes.from(publicKey);
    final one = BuBytes.zero(32)..[0] = 1;
    final out = BuBytes.zero(96);
    return _b.curveMul(BuCurveId.bls12G2, one, pk, out) == 0;
  }

  @override
  bool isValidSecretKey(List<int> secret) {
    if (secret.length != 32) {
      return false;
    }
    final s = BuBytes.from(secret);
    return _b.curveScCheck(BuCurveId.bls12G1, s) == 1;
  }

  @override
  BuResult<BuBytes> normalizeG1PublicKey(List<int> publicKey) {
    final out = BuBytes.zero(_b.curvePointLen(BuCurveId.bls12G1));
    final pk = BuBytes.from(publicKey);
    return _map(_b.curveNormalizePubkey(BuCurveId.bls12G1, pk, out), out);
  }

  @override
  BuResult<BuBytes> normalizeG2PublicKey(List<int> publicKey) {
    final out = BuBytes.zero(_b.curvePointLen(BuCurveId.bls12G2));
    final pk = BuBytes.from(publicKey);
    return _map(_b.curveNormalizePubkey(BuCurveId.bls12G2, pk, out), out);
  }
}
