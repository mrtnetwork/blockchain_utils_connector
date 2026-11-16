import 'package:blockchain_utils_connector/src/api/musig2_api.dart';
import 'package:blockchain_utils_connector/src/api/curve_id.dart';
import 'package:blockchain_utils_connector/src/bytes/bytes.dart';
import 'package:blockchain_utils_connector/src/error/bu_error.dart';
import 'package:blockchain_utils_connector/src/platform/bindings.dart';

class DefaultMusig2Api implements BuMusig2Api {
  DefaultMusig2Api(this._b);
  final BuPlatformBindings _b;

  BuResult<BuBytes> _map(int rc, BuBytes out) {
    if (rc == 0) {
      return BuResult.ok(out);
    }
    if (rc == 6) {
      return BuResult.err(
        BuError.unsupportedAlgo(
          message: 'MuSig2 is not available in this native build',
        ),
      );
    }
    if (rc == 2) {
      return BuResult.err(
        BuError(DefaultErrorType.invalidLength, 'invalid MuSig2 input length'),
      );
    }
    if (rc == 3) {
      return BuResult.err(
        BuError.key(message: 'invalid MuSig2 key or public key encoding'),
      );
    }
    if (rc == 4) {
      return BuResult.err(BuError.verify());
    }
    return BuResult.err(
      BuError.internalErr(message: 'MuSig2 operation failed'),
    );
  }

  BuBytes _concatKeys(List<BuBytes> keys) {
    if (keys.isEmpty) {
      return BuBytes.empty();
    }
    final n = keys.length * keys.first.length;
    final out = BuBytes.zero(n);
    var off = 0;
    for (final k in keys) {
      for (var i = 0; i < k.length; i++) {
        out[off + i] = k[i];
      }
      off += k.length;
    }
    return out;
  }

  BuBytes _encodeTweaks(List<BuMusig2Tweak> tweaks) {
    if (tweaks.isEmpty) {
      return BuBytes.empty();
    }
    final out = BuBytes.zero(tweaks.length * 33);
    for (var i = 0; i < tweaks.length; i++) {
      final t = tweaks[i];
      out[i * 33] = t.isXOnly ? 1 : 0;
      for (var j = 0; j < 32; j++) {
        out[i * 33 + 1 + j] = t.tweak32[j];
      }
    }
    return out;
  }

  @override
  BuResult<List<BuBytes>> sortPublicKeys(List<BuBytes> keys) {
    final sorted = List<BuBytes>.from(keys);
    sorted.sort((a, b) {
      final n = a.length < b.length ? a.length : b.length;
      for (var i = 0; i < n; i++) {
        if (a[i] != b[i]) {
          return a[i].compareTo(b[i]);
        }
      }
      return a.length.compareTo(b.length);
    });
    return BuResult.ok(sorted);
  }

  @override
  BuResult<BuBytes> keyAgg(List<BuBytes> keys) {
    if (keys.length < 2) {
      return BuResult.err(BuError.invalidLength);
    }
    for (final k in keys) {
      if (k.length != 33) {
        return BuResult.err(BuError.invalidLength);
      }
    }
    final out = BuBytes.zero(33);
    final rc = _b.musig2KeyAgg(_concatKeys(keys), keys.length, out);
    return _map(rc, out);
  }

  @override
  BuResult<BuBytes> keyAggAndTweak({
    required List<BuBytes> keys,
    List<BuMusig2Tweak> tweaks = const [],
  }) {
    if (keys.length < 2) {
      return BuResult.err(BuError.invalidLength);
    }
    final out = BuBytes.zero(33);
    final tw = _encodeTweaks(tweaks);
    final rc = _b.musig2KeyAggTweak(
      _concatKeys(keys),
      keys.length,
      tw,
      tweaks.length,
      out,
    );
    return _map(rc, out);
  }

  @override
  BuResult<BuMusig2Nonce> nonceGenerate({
    required BuBytes publicKey,
    BuBytes? sk,
    BuBytes? aggPubKey,
    BuBytes? msg,
    BuBytes? extra,
    required BuBytes rand,
  }) {
    if (publicKey.length != 33) {
      return BuResult.err(BuError.invalidLength);
    }
    if (rand.length != 32) {
      return BuResult.err(BuError.invalidLength);
    }
    final sec = BuBytes.zero(97);
    final pub = BuBytes.zero(66);
    final rc = _b.musig2NonceGen(
      sk: sk,
      publicKey: publicKey,
      aggPubKey: aggPubKey,
      msg: msg,
      extra: extra,
      rand: rand,
      secnonceOut97: sec,
      pubnonceOut66: pub,
    );
    if (rc != 0) {
      if (rc == 6) {
        return BuResult.err(BuError.unsupported);
      }
      return BuResult.err(BuError(DefaultErrorType.internal, 'nonce_gen $rc'));
    }
    return BuResult.ok(BuMusig2Nonce(secnonce: sec, pubnonce: pub));
  }

  @override
  BuResult<BuBytes> nonceAgg(List<BuBytes> pubnonces) {
    if (pubnonces.isEmpty) {
      return BuResult.err(BuError.invalidLength);
    }
    for (final n in pubnonces) {
      if (n.length != 66) {
        return BuResult.err(BuError.invalidLength);
      }
    }
    final out = BuBytes.zero(66);
    final rc = _b.musig2NonceAgg(_concatKeys(pubnonces), pubnonces.length, out);
    return _map(rc, out);
  }

  @override
  BuResult<BuBytes> partialSign({
    required BuBytes secnonce,
    required BuBytes sk,
    required List<BuBytes> publicKeys,
    required BuBytes aggnonce,
    required BuBytes msg,
    List<BuMusig2Tweak> tweaks = const [],
  }) {
    final out = BuBytes.zero(32);
    final skc = BuBytes.owned(sk);
    try {
      final tw = _encodeTweaks(tweaks);
      final rc = _b.musig2PartialSign(
        secnonce: secnonce,
        sk: skc,
        keysConcat: _concatKeys(publicKeys),
        nKeys: publicKeys.length,
        aggnonce: aggnonce,
        msg: msg,
        tweaksConcat: tweaks.isEmpty ? null : tw,
        nTweaks: tweaks.length,
        out32: out,
      );
      return _map(rc, out);
    } finally {
      skc.zero();
    }
  }

  @override
  BuResult<BuBytes> partialSigAgg({
    required List<BuBytes> partials,
    required List<BuBytes> publicKeys,
    required BuBytes aggnonce,
    required BuBytes msg,
    List<BuMusig2Tweak> tweaks = const [],
  }) {
    final out = BuBytes.zero(64);
    final tw = _encodeTweaks(tweaks);
    final rc = _b.musig2PartialSigAgg(
      partialsConcat: _concatKeys(partials),
      nPartials: partials.length,
      keysConcat: _concatKeys(publicKeys),
      nKeys: publicKeys.length,
      aggnonce: aggnonce,
      msg: msg,
      tweaksConcat: tweaks.isEmpty ? null : tw,
      nTweaks: tweaks.length,
      out64: out,
    );
    return _map(rc, out);
  }

  @override
  BuResult<bool> partialSigVerify({
    required BuBytes partial,
    required BuBytes pubnonce,
    required BuBytes pk,
    required List<BuBytes> publicKeys,
    required BuBytes aggnonce,
    required BuBytes msg,
    List<BuMusig2Tweak> tweaks = const [],
  }) {
    final tw = _encodeTweaks(tweaks);
    final rc = _b.musig2PartialSigVerify(
      partial: partial,
      pubnonce: pubnonce,
      pk: pk,
      keysConcat: _concatKeys(publicKeys),
      nKeys: publicKeys.length,
      aggnonce: aggnonce,
      msg: msg,
      tweaksConcat: tweaks.isEmpty ? null : tw,
      nTweaks: tweaks.length,
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
      BuError(DefaultErrorType.internal, 'partial_verify $rc'),
    );
  }

  @override
  BuResult<BuMusig2DeterministicSignature> deterministicSign({
    required BuBytes sk,
    required BuBytes aggotherNonce66,
    required List<BuBytes> publicKeys,
    required BuBytes msg,
    List<BuMusig2Tweak> tweaks = const [],
    BuBytes? rand,
  }) {
    if (sk.length != 32 || aggotherNonce66.length != 66) {
      return BuResult.err(BuError.invalidLength);
    }
    if (publicKeys.length < 2) {
      return BuResult.err(BuError.invalidLength);
    }
    final pub = BuBytes.zero(66);
    final partial = BuBytes.zero(32);
    final tw = _encodeTweaks(tweaks);
    final rc = _b.musig2DeterministicSign(
      sk: sk,
      aggother66: aggotherNonce66,
      keysConcat: _concatKeys(publicKeys),
      nKeys: publicKeys.length,
      msg: msg,
      tweaksConcat: tweaks.isEmpty ? null : tw,
      nTweaks: tweaks.length,
      rand: rand,
      pubnonceOut66: pub,
      partialOut32: partial,
    );
    if (rc != 0) {
      if (rc == 6) {
        return BuResult.err(BuError.unsupported);
      }
      return BuResult.err(BuError(DefaultErrorType.internal, 'det_sign $rc'));
    }
    return BuResult.ok(
      BuMusig2DeterministicSignature(pubnonce: pub, partial: partial),
    );
  }

  @override
  BuResult<bool> verifyAggregate({
    required BuBytes message,
    required BuBytes signature64,
    required BuBytes aggXOnly32,
  }) {
    if (signature64.length != 64 || aggXOnly32.length != 32) {
      return BuResult.err(BuError.invalidLength);
    }
    final rc = _b.musig2VerifyAggregate(
      message: message,
      signature64: signature64,
      aggXOnly32: aggXOnly32,
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
      BuError(DefaultErrorType.internal, 'verify_aggregate $rc'),
    );
  }

  @override
  bool isValidPublicKey(List<int> publicKey, {bool xOnly = false}) {
    if (xOnly) {
      if (publicKey.length != 32) {
        return false;
      }
      final pk = BuBytes.from(publicKey);
      final comp = BuBytes.zero(33);
      comp[0] = 0x02;
      for (var i = 0; i < 32; i++) {
        comp[i + 1] = pk[i];
      }
      final one = BuBytes.zero(32)..[31] = 1;
      final out = BuBytes.zero(33);
      return _b.curveMul(BuCurveId.secp256k1, one, comp, out) == 0;
    }
    if (publicKey.length != 33 && publicKey.length != 65) {
      return false;
    }
    final pk = BuBytes.from(publicKey);
    final one = BuBytes.zero(32)..[31] = 1;
    final out = BuBytes.zero(33);
    return _b.curveMul(BuCurveId.secp256k1, one, pk, out) == 0;
  }

  @override
  bool isValidSecretKey(List<int> secret) {
    if (secret.length != 32) {
      return false;
    }
    final s = BuBytes.from(secret);
    return _b.curveScCheck(BuCurveId.secp256k1, s) == 1;
  }
}
