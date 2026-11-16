import 'package:blockchain_utils_connector/src/api/sr25519_signing_api.dart';
import 'package:blockchain_utils_connector/src/api/curve_id.dart';
import 'package:blockchain_utils_connector/src/bytes/bytes.dart';
import 'package:blockchain_utils_connector/src/error/bu_error.dart';
import 'package:blockchain_utils_connector/src/platform/bindings.dart';

class DefaultSr25519SigningApi implements BuSr25519SigningApi {
  DefaultSr25519SigningApi(this._b);
  final BuPlatformBindings _b;
  static const _tag = 'sr25519';

  BuBytes _as(List<int> x) => BuBytes.from(x);

  BuResult<BuBytes> _ok(int rc, BuBytes out, String tag) =>
      rc == 0
          ? BuResult.ok(out)
          : BuResult.err(BuError.fromNativeCode(rc, details: {'op': tag}));

  @override
  BuResult<BuBytes> publicKeyFromSeed(
    List<int> seed32, {
    bool uniform = false,
  }) {
    if (seed32.length != 32) {
      return BuResult.err(
        BuError.length(what: 'seed', expected: 32, actual: seed32.length),
      );
    }
    final out = BuBytes.zero(32);
    return _ok(
      _b.sr25519PublicKey(_as(seed32), uniform ? 1 : 0, out),
      out,
      '$_tag.publicKeyFromSeed',
    );
  }

  @override
  BuResult<BuBytes> secretFromSeed(List<int> seed32, {bool uniform = false}) {
    if (seed32.length != 32) {
      return BuResult.err(
        BuError.length(what: 'seed', expected: 32, actual: seed32.length),
      );
    }
    final out = BuBytes.zero(64);
    return _ok(
      _b.sr25519SecretFromSeed(_as(seed32), uniform ? 1 : 0, out),
      out,
      '$_tag.secretFromSeed',
    );
  }

  @override
  BuResult<BuBytes> publicKeyFromSecret(List<int> sk64) {
    if (sk64.length != 64) {
      return BuResult.err(
        BuError.length(what: 'sk', expected: 64, actual: sk64.length),
      );
    }
    final out = BuBytes.zero(32);
    return _ok(
      _b.sr25519PublicKeyFromSecret(_as(sk64), out),
      out,
      '$_tag.publicKeyFromSecret',
    );
  }

  @override
  bool isValidPublicKey(List<int> pk32) {
    if (pk32.length != 32) {
      return false;
    }
    return _b.sr25519IsValidPublicKey(_as(pk32)) == 1;
  }

  @override
  bool isValidSecretKey(List<int> sk64) {
    if (sk64.length != 64) {
      return false;
    }
    return _b.sr25519IsValidSecretKey(_as(sk64)) == 1;
  }

  @override
  BuResult<BuBytes> sign({
    required List<int> seedOrSk,
    required List<int> message,
    required List<int> nonce64,
    bool fromSeed = true,
    bool uniform = false,
    List<int>? context,
  }) {
    if (nonce64.length != 64) {
      return BuResult.err(
        BuError.length(what: 'nonce', expected: 64, actual: nonce64.length),
      );
    }
    final out = BuBytes.zero(64);
    final rc = _b.sr25519Sign(
      seedOrSk: _as(seedOrSk),
      fromSeed: fromSeed ? 1 : 0,
      uniform: uniform ? 1 : 0,
      message: _as(message),
      nonce64: _as(nonce64),
      sigOut64: out,
    );
    return _ok(rc, out, '$_tag.sign');
  }

  @override
  BuResult<bool> verify({
    required List<int> publicKey,
    required List<int> message,
    required List<int> signature,
    List<int>? context,
  }) {
    final rc = _b.sr25519Verify(
      publicKey: _as(publicKey),
      message: _as(message),
      signature64: _as(signature),
    );
    if (rc == 0) {
      return BuResult.ok(true);
    }
    if (rc == 4) {
      return BuResult.ok(false);
    }
    return BuResult.err(
      BuError.fromNativeCode(rc, details: {'op': '$_tag.verify'}),
    );
  }

  @override
  BuResult<BuBytes> toEd25519Bytes(List<int> sk64) {
    if (sk64.length != 64) {
      return BuResult.err(
        BuError.length(what: 'sk', expected: 64, actual: sk64.length),
      );
    }
    final out = BuBytes.zero(64);
    return _ok(
      _b.sr25519ToEd25519Bytes(_as(sk64), out),
      out,
      '$_tag.toEd25519Bytes',
    );
  }

  BuResult<(BuBytes, BuBytes)> _split96(int rc, BuBytes out96, String tag) {
    if (rc != 0) {
      return BuResult.err(BuError.fromNativeCode(rc, details: {'op': tag}));
    }
    final sk = BuBytes.zero(64);
    final cc = BuBytes.zero(32);
    for (var i = 0; i < 64; i++) {
      sk[i] = out96[i];
    }
    for (var i = 0; i < 32; i++) {
      cc[i] = out96[64 + i];
    }
    return BuResult.ok((sk, cc));
  }

  @override
  BuResult<(BuBytes, BuBytes)> hardDerive({
    required List<int> seedOrSk,
    required List<int> chainCode32,
    List<int>? message,
    bool fromSeed = true,
    bool uniform = false,
  }) {
    final out = BuBytes.zero(96);
    final rc = _b.sr25519HardDerive(
      seedOrSk: _as(seedOrSk),
      fromSeed: fromSeed ? 1 : 0,
      uniform: uniform ? 1 : 0,
      chain32: _as(chainCode32),
      message: message == null ? null : _as(message),
      out96: out,
    );
    return _split96(rc, out, '$_tag.hardDerive');
  }

  @override
  BuResult<(BuBytes, BuBytes)> softDerive({
    required List<int> seedOrSk,
    required List<int> chainCode32,
    required List<int> newNonce32,
    List<int>? message,
    bool fromSeed = true,
    bool uniform = false,
  }) {
    final out = BuBytes.zero(96);
    final rc = _b.sr25519SoftDerive(
      seedOrSk: _as(seedOrSk),
      fromSeed: fromSeed ? 1 : 0,
      uniform: uniform ? 1 : 0,
      chain32: _as(chainCode32),
      message: message == null ? null : _as(message),
      newNonce32: _as(newNonce32),
      out96: out,
    );
    return _split96(rc, out, '$_tag.softDerive');
  }

  @override
  BuResult<(BuBytes, BuBytes)> derivePublic({
    required List<int> publicKey,
    required List<int> chainCode32,
    List<int>? message,
  }) {
    final out = BuBytes.zero(64);
    final rc = _b.sr25519DerivePublic(
      publicKey: _as(publicKey),
      chain32: _as(chainCode32),
      message: message == null ? null : _as(message),
      out64: out,
    );
    if (rc != 0) {
      return BuResult.err(
        BuError.fromNativeCode(rc, details: {'op': '$_tag.derivePublic'}),
      );
    }
    final pk = BuBytes.zero(32);
    final cc = BuBytes.zero(32);
    for (var i = 0; i < 32; i++) {
      pk[i] = out[i];
      cc[i] = out[32 + i];
    }
    return BuResult.ok((pk, cc));
  }

  @override
  BuResult<BuBytes> vrfHash({
    required List<int> publicKey,
    required List<int> message,
    List<int>? context,
  }) {
    final out = BuBytes.zero(32);
    return _ok(
      _b.sr25519VrfHash(
        publicKey: _as(publicKey),
        context: context == null ? null : _as(context),
        message: _as(message),
        out32: out,
      ),
      out,
      '$_tag.vrfHash',
    );
  }

  @override
  BuResult<BuBytes> vrfInOut({
    required List<int> seedOrSk,
    required List<int> message,
    bool fromSeed = true,
    bool uniform = false,
    List<int>? context,
  }) {
    final out = BuBytes.zero(64);
    return _ok(
      _b.sr25519VrfInOut(
        seedOrSk: _as(seedOrSk),
        fromSeed: fromSeed ? 1 : 0,
        uniform: uniform ? 1 : 0,
        context: context == null ? null : _as(context),
        message: _as(message),
        out64: out,
      ),
      out,
      '$_tag.vrfInOut',
    );
  }

  @override
  BuResult<BuBytes> dleqProve({
    required List<int> seedOrSk,
    required List<int> inout64,
    required List<int> nonce64,
    bool fromSeed = true,
    bool uniform = false,
    bool kusamaVrf = true,
    List<int>? extra,
  }) {
    final out = BuBytes.zero(64);
    return _ok(
      _b.sr25519DleqProve(
        seedOrSk: _as(seedOrSk),
        fromSeed: fromSeed ? 1 : 0,
        uniform: uniform ? 1 : 0,
        inout64: _as(inout64),
        nonce64: _as(nonce64),
        kusama: kusamaVrf ? 1 : 0,
        extra: extra == null ? null : _as(extra),
        out64: out,
      ),
      out,
      '$_tag.dleqProve',
    );
  }

  @override
  BuResult<bool> dleqVerify({
    required List<int> publicKey,
    required List<int> inout64,
    required List<int> proof64,
    bool kusamaVrf = true,
    List<int>? extra,
  }) {
    final rc = _b.sr25519DleqVerify(
      publicKey: _as(publicKey),
      inout64: _as(inout64),
      proof64: _as(proof64),
      kusama: kusamaVrf ? 1 : 0,
      extra: extra == null ? null : _as(extra),
    );
    if (rc == 0) {
      return BuResult.ok(true);
    }
    if (rc == 4) {
      return BuResult.ok(false);
    }
    return BuResult.err(
      BuError.fromNativeCode(rc, details: {'op': '$_tag.dleqVerify'}),
    );
  }

  @override
  BuResult<BuBytes> vrfSign({
    required List<int> seedOrSk,
    required List<int> message,
    required List<int> nonce64,
    bool fromSeed = true,
    bool uniform = false,
    List<int>? context,
    List<int>? extra,
    bool kusamaVrf = true,
  }) {
    final out = BuBytes.zero(96);
    return _ok(
      _b.sr25519VrfSign(
        seedOrSk: _as(seedOrSk),
        fromSeed: fromSeed ? 1 : 0,
        uniform: uniform ? 1 : 0,
        context: context == null ? null : _as(context),
        message: _as(message),
        nonce64: _as(nonce64),
        kusama: kusamaVrf ? 1 : 0,
        extra: extra == null ? null : _as(extra),
        out96: out,
      ),
      out,
      '$_tag.vrfSign',
    );
  }

  @override
  BuResult<bool> vrfVerify({
    required List<int> publicKey,
    required List<int> message,
    required List<int> preOut32,
    required List<int> proof64,
    List<int>? context,
    List<int>? extra,
    bool kusamaVrf = true,
  }) {
    final rc = _b.sr25519VrfVerify(
      publicKey: _as(publicKey),
      context: context == null ? null : _as(context),
      message: _as(message),
      preOut32: _as(preOut32),
      proof64: _as(proof64),
      kusama: kusamaVrf ? 1 : 0,
      extra: extra == null ? null : _as(extra),
    );
    if (rc == 0) {
      return BuResult.ok(true);
    }
    if (rc == 4) {
      return BuResult.ok(false);
    }
    return BuResult.err(
      BuError.fromNativeCode(rc, details: {'op': '$_tag.vrfVerify'}),
    );
  }

  @override
  BuResult<BuBytes> normalizePublicKey(List<int> publicKey) {
    final n = _b.curvePointLen(BuCurveId.ristretto);
    if (n <= 0) {
      return BuResult.err(BuError.internalErr(message: 'unknown point length'));
    }
    final out = BuBytes.zero(n);
    final rc = _b.curveNormalizePubkey(
      BuCurveId.ristretto,
      _as(publicKey),
      out,
    );
    if (rc != 0) {
      return BuResult.err(
        BuError.fromNativeCode(rc, details: {'op': 'normalizePublicKey'}),
      );
    }
    return BuResult.ok(out);
  }
}
