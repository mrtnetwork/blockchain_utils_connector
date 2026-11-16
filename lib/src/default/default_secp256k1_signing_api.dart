import 'package:blockchain_utils_connector/src/api/secp256k1_signing_api.dart';
import 'package:blockchain_utils_connector/src/api/curve_id.dart';
import 'package:blockchain_utils_connector/src/bytes/bytes.dart';
import 'package:blockchain_utils_connector/src/error/bu_error.dart';
import 'package:blockchain_utils_connector/src/platform/bindings.dart';

class DefaultSecp256k1SigningApi implements BuSecp256k1SigningApi {
  DefaultSecp256k1SigningApi(this._b);
  final BuPlatformBindings _b;

  BuResult<BuBytes> _map(int rc, BuBytes out) {
    if (rc == 0) {
      return BuResult.ok(out);
    }
    return BuResult.err(
      BuError.fromNativeCode(rc, details: {'op': 'sig error $rc'}),
    );
  }

  BuBytes _xOnly(BuBytes pk) {
    if (pk.length == 32) {
      return pk;
    }
    if (pk.length == 33) {
      final o = BuBytes.zero(32);
      for (var i = 0; i < 32; i++) {
        o[i] = pk[i + 1];
      }
      return o;
    }
    throw BuError.invalidArgument;
  }

  /// SHA-256 via native hash engine.
  BuBytes _sha256(BuBytes data) {
    final cfg = BuHashNativeConfig(algo: BuHashAlgo.sha256);
    final h = _b.hashNew(cfg);
    try {
      _b.hashUpdate(h, data);
      final out = BuBytes.zero(32);
      _b.hashFinish(h, out);
      return out;
    } finally {
      _b.hashFree(h);
    }
  }

  BuBytes _concat(BuBytes a, BuBytes b) {
    final o = BuBytes.zero(a.length + b.length);
    for (var i = 0; i < a.length; i++) {
      o[i] = a[i];
    }
    for (var i = 0; i < b.length; i++) {
      o[a.length + i] = b[i];
    }
    return o;
  }

  /// Bitcoin varint (CompactSize) for lengths used in message hashing.
  BuBytes _compactSize(int n) {
    if (n < 0xfd) {
      return BuBytes.from([n]);
    }
    if (n <= 0xffff) {
      return BuBytes.from([0xfd, n & 0xff, (n >> 8) & 0xff]);
    }
    if (n <= 0xffffffff) {
      return BuBytes.from([
        0xfe,
        n & 0xff,
        (n >> 8) & 0xff,
        (n >> 16) & 0xff,
        (n >> 24) & 0xff,
      ]);
    }
    throw BuError.invalidLength;
  }

  @override
  BuResult<BuBytes> publicKey(BuBytes sk) {
    final out = BuBytes.zero(33);
    final k = BuBytes.owned(sk);
    try {
      return _map(_b.ecdsaK1PublicKey(k, out), out);
    } finally {
      k.zero();
    }
  }

  @override
  BuResult<BuBytes> xOnlyPublicKey(BuBytes sk) {
    final out = BuBytes.zero(32);
    final k = BuBytes.owned(sk);
    try {
      return _map(_b.schnorrPublicKey(k, out), out);
    } finally {
      k.zero();
    }
  }

  @override
  BuResult<BuEcdsaSignature> signEcdsa(
    BuBytes sk,
    BuSecp256k1SignParams params,
  ) {
    final out = BuBytes.zero(64);
    final k = BuBytes.owned(sk);
    try {
      final rc =
          params.extraEntropy == null
              ? _b.ecdsaK1Sign(k, params.digest, out)
              : _b.ecdsaK1SignEx(k, params.digest, params.extraEntropy, out);
      if (rc != 0) {
        return BuResult.err(
          BuError.fromNativeCode(rc, details: {'op': 'ecdsa sign $rc'}),
        );
      }
      int? recId;
      final idOut = BuBytes.zero(1);
      final pk = BuBytes.zero(33);
      if (_b.ecdsaK1PublicKey(k, pk) == 0) {
        final idRc = _b.ecdsaK1RecoveryId(params.digest, out, pk, idOut);
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
  }) => BuResult.ok(_b.ecdsaK1Verify(pk, digest, signature.compact) == 0);

  @override
  BuResult<BuBytes> recoverEcdsa({
    required BuBytes digest,
    required BuEcdsaSignature signature,
  }) {
    final id = signature.recoveryId;
    if (id == null) {
      return BuResult.err(BuError.invalidArgument);
    }
    final out = BuBytes.zero(33);
    return _map(_b.ecdsaK1Recover(digest, signature.compact, id, out), out);
  }

  @override
  BuResult<(BuBytes, int)> recoverEcdsaAny({
    required BuBytes digest,
    required BuBytes compactSig,
  }) {
    for (var id = 0; id < 4; id++) {
      final out = BuBytes.zero(33);
      if (_b.ecdsaK1Recover(digest, compactSig, id, out) == 0) {
        return BuResult.ok((out, id));
      }
    }
    return BuResult.err(BuError.internal);
  }

  @override
  BuResult<BuEcdsaSignature> signBip340(
    BuBytes sk,
    BuSecp256k1Bip340Params params,
  ) {
    final out = BuBytes.zero(64);
    var key = BuBytes.owned(sk);
    try {
      // Optional taproot tweak first (matches Dart: operate on tKey).
      if (params.tapTweakHash != null) {
        final tweaked = BuBytes.zero(32);
        final rc = _b.schnorrTweakSecret(key, params.tapTweakHash!, tweaked);
        if (rc != 0) {
          return BuResult.err(
            BuError.fromNativeCode(rc, details: {'op': 'tweak $rc'}),
          );
        }
        key.zero();
        key = tweaked;
      }

      /// default aux was SHA256(digest||key) (secret-derived,
      /// non-standard and backend-divergent). Default aux is fresh backend
      /// randomness (BIP-340): never derived from the secret. Explicit aux
      /// stays deterministic for test vectors.
      BuBytes? aux = params.aux;
      if (aux == null) {
        final random = BuBytes.zero(32);
        if (_b.rngFill(random) != 0) {
          key.zero();
          return BuResult.err(
            BuError(DefaultErrorType.invalidState, 'bip340 sign: RNG unseeded'),
          );
        }
        aux = random;
      }

      final rc = _b.schnorrSign(key, params.digest, aux, out);
      if (rc != 0) {
        return BuResult.err(
          BuError.fromNativeCode(rc, details: {'op': 'bip340 sign $rc'}),
        );
      }
      return BuResult.ok(BuEcdsaSignature.fromCompact(out));
    } finally {
      key.zero();
    }
  }

  @override
  BuResult<bool> verifyBip340({
    required BuBytes xOnlyPk,
    required BuBytes messageOrDigest,
    required BuEcdsaSignature signature,
  }) {
    try {
      final x = _xOnly(xOnlyPk);
      return BuResult.ok(
        _b.schnorrVerify(x, messageOrDigest, signature.compact) == 0,
      );
    } on BuError catch (e) {
      return BuResult.err(e);
    }
  }

  @override
  BuResult<BuBytes> tweakSecret(BuBytes sk, BuBytes tweak32) {
    final out = BuBytes.zero(32);
    final k = BuBytes.owned(sk);
    try {
      return _map(_b.schnorrTweakSecret(k, tweak32, out), out);
    } finally {
      k.zero();
    }
  }

  @override
  BuResult<BuBytes> tweakPublicXOnly(BuBytes xOnlyPk, BuBytes tweak32) {
    final out = BuBytes.zero(32);
    try {
      final x = _xOnly(xOnlyPk);
      return _map(_b.schnorrTweakPublic(x, tweak32, out), out);
    } on BuError catch (e) {
      return BuResult.err(e);
    }
  }

  @override
  BuResult<BuEcdsaSignature> signSchnorr(
    BuBytes sk,
    BuSecp256k1SignParams params,
  ) {
    final out = BuBytes.zero(64);
    final k = BuBytes.owned(sk);
    try {
      final rc = _b.schnorrBchSign(k, params.digest, params.extraEntropy, out);
      if (rc != 0) {
        return BuResult.err(
          BuError.fromNativeCode(rc, details: {'op': 'bch schnorr $rc'}),
        );
      }
      return BuResult.ok(BuEcdsaSignature.fromCompact(out));
    } finally {
      k.zero();
    }
  }

  @override
  BuResult<bool> verifySchnorr({
    required BuBytes pk,
    required BuBytes digest,
    required BuEcdsaSignature signature,
  }) {
    if (pk.length == 32) {
      return verifyBip340(
        xOnlyPk: pk,
        messageOrDigest: digest,
        signature: signature,
      );
    }
    return BuResult.ok(_b.schnorrBchVerify(pk, digest, signature.compact) == 0);
  }

  // ---- Bitcoin signed message (double-SHA256 of prefix||compactSize||msg) ----

  BuResult<BuBytes> _bitcoinMessageHash(
    BuBytes message, {
    String messagePrefix = '\x18Bitcoin Signed Message:\n',
  }) {
    try {
      final prefix = BuBytes.from(messagePrefix.codeUnits);
      final body = _concat(
        _concat(prefix, _compactSize(message.length)),
        message,
      );
      return BuResult.ok(_sha256(_sha256(body)));
    } on BuError catch (e) {
      return BuResult.err(e);
    }
  }

  @override
  BuResult<BuBytes> bitcoinMessageHash(BuBytes message) =>
      _bitcoinMessageHash(message);

  @override
  BuResult<BuEcdsaSignature> signBitcoinMessage({
    required BuBytes sk,
    required BuBytes message,
    String messagePrefix = '\x18Bitcoin Signed Message:\n',
  }) {
    final h = _bitcoinMessageHash(message, messagePrefix: messagePrefix);
    if (h.isErr) {
      return BuResult.err(h.error!);
    }
    return signEcdsa(sk, BuSecp256k1SignParams(digest: h.value!));
  }

  @override
  BuResult<bool> verifyBitcoinMessage({
    required BuBytes pk,
    required BuBytes message,
    required BuEcdsaSignature signature,
    String messagePrefix = '\x18Bitcoin Signed Message:\n',
  }) {
    final h = _bitcoinMessageHash(message, messagePrefix: messagePrefix);
    if (h.isErr) {
      return BuResult.err(h.error!);
    }
    return verifyEcdsa(pk: pk, digest: h.value!, signature: signature);
  }

  @override
  BuResult<BuBytes> recoverBitcoinMessagePublicKey({
    required BuBytes message,
    required BuEcdsaSignature signature,
    String messagePrefix = '\x18Bitcoin Signed Message:\n',
  }) {
    final h = _bitcoinMessageHash(message, messagePrefix: messagePrefix);
    if (h.isErr) {
      return BuResult.err(h.error!);
    }
    return recoverEcdsa(digest: h.value!, signature: signature);
  }

  @override
  BuResult<BuEcdsaSignature> signMessageSignature({
    required BuBytes sk,
    required BuBytes message,
    String messagePrefix = '\x18Bitcoin Signed Message:\n',
  }) => signBitcoinMessage(
    sk: sk,
    message: message,
    messagePrefix: messagePrefix,
  );

  @override
  BuResult<bool> verifyMessageSignature({
    required BuBytes pk,
    required BuBytes message,
    required BuEcdsaSignature signature,
    String messagePrefix = '\x18Bitcoin Signed Message:\n',
  }) => verifyBitcoinMessage(
    pk: pk,
    message: message,
    signature: signature,
    messagePrefix: messagePrefix,
  );

  @override
  bool isValidPublicKey(List<int> publicKey, {bool xOnly = false}) {
    if (xOnly) {
      if (publicKey.length != 32) {
        return false;
      }
      final pk = BuBytes.from(publicKey);
      // x-only: try BIP-340 style — lift via schnorr verify path not available; use curve with 02 prefix
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

  @override
  BuResult<BuBytes> normalizePublicKey(List<int> publicKey) {
    final n = _b.curvePointLen(BuCurveId.secp256k1);
    if (n <= 0) {
      return BuResult.err(BuError.internalErr(message: 'unknown point length'));
    }
    final out = BuBytes.zero(n);
    final pk = BuBytes.from(publicKey);
    final rc = _b.curveNormalizePubkey(BuCurveId.secp256k1, pk, out);
    return _map(rc, out);
  }
}
