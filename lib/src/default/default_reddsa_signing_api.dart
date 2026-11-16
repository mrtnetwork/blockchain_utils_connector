import 'package:blockchain_utils_connector/src/api/reddsa_signing_api.dart';
import 'package:blockchain_utils_connector/src/api/curve_id.dart';
import 'package:blockchain_utils_connector/src/bytes/bytes.dart';
import 'package:blockchain_utils_connector/src/error/bu_error.dart';
import 'package:blockchain_utils_connector/src/platform/bindings.dart';

class DefaultReddsaSigningApi implements BuReddsaSigningApi {
  DefaultReddsaSigningApi(this._b);
  final BuPlatformBindings _b;

  BuResult<void> _checkSk(BuBytes sk, String ctx) {
    if (sk.length != 32) {
      return BuResult.err(
        BuError.length(
          what: 'RedDSA secret key',
          expected: 32,
          actual: sk.length,
        ),
      );
    }
    return BuResult.ok(null);
  }

  BuResult<void> _checkPk(BuBytes pk, String ctx) {
    if (pk.length != 32) {
      return BuResult.err(
        BuError.length(
          what: 'RedDSA public key',
          expected: 32,
          actual: pk.length,
        ),
      );
    }
    return BuResult.ok(null);
  }

  /// null/empty → 80 bytes from the seeded global ChaCha backend.
  /// Returns [DefaultErrorType.notInitialized] when the global RNG was never
  /// seeded (both native backends reject caller-absent randomness rather
  /// than silently substituting it, so unseeded output can never become a
  /// signature nonce).
  BuResult<BuBytes> _randOrFill(BuBytes? rand80) {
    if (rand80 == null || rand80.isEmpty) {
      final out = BuBytes.zero(80);
      final rc = _b.rngFill(out);
      if (rc != 0) {
        return BuResult.err(BuError.fromNativeCode(11));
      }
      return BuResult.ok(out);
    }
    return BuResult.ok(rand80);
  }

  BuResult<void> _checkRand(BuBytes r, String ctx) {
    if (r.isEmpty) {
      return BuResult.ok(null);
    }
    if (r.length != 80) {
      return BuResult.err(
        BuError.length(what: 'RedDSA rand80', expected: 80, actual: r.length),
      );
    }
    return BuResult.ok(null);
  }

  @override
  BuResult<BuBytes> publicKey({
    required BuReddsaDomain domain,
    required BuBytes sk,
  }) {
    final c = _checkSk(sk, 'reddsa.publicKey');
    if (c.isErr) {
      return BuResult.err(c.error!);
    }
    final pk = BuBytes.zero(32);
    final rc = switch (domain) {
      BuReddsaDomain.jubjubAuth => _b.reddsaJubjubAuthPk(sk, pk),
      BuReddsaDomain.jubjubBinding => _b.reddsaJubjubBindingPk(sk, pk),
      BuReddsaDomain.pallasAuth => _b.reddsaPallasAuthPk(sk, pk),
      BuReddsaDomain.pallasBinding => _b.reddsaPallasBindingPk(sk, pk),
    };
    if (rc != 0) {
      return BuResult.err(BuError.fromNativeCode(rc));
    }
    return BuResult.ok(pk);
  }

  @override
  BuResult<BuBytes> sign({
    required BuReddsaDomain domain,
    required BuBytes sk,
    required BuBytes message,
    BuBytes? rand80,
  }) {
    final c = _checkSk(sk, 'reddsa.sign');
    if (c.isErr) {
      return BuResult.err(c.error!);
    }
    final r = _randOrFill(rand80);
    if (r.isErr) {
      return BuResult.err(r.error!);
    }
    final cr = _checkRand(r.value!, 'reddsa.sign');
    if (cr.isErr) {
      return BuResult.err(cr.error!);
    }
    final sig = BuBytes.zero(64);
    final rc = switch (domain) {
      BuReddsaDomain.jubjubAuth => _b.reddsaJubjubAuthSign(
        sk,
        message,
        r.value!,
        sig,
      ),
      BuReddsaDomain.jubjubBinding => _b.reddsaJubjubBindingSign(
        sk,
        message,
        r.value!,
        sig,
      ),
      BuReddsaDomain.pallasAuth => _b.reddsaPallasAuthSign(
        sk,
        message,
        r.value!,
        sig,
      ),
      BuReddsaDomain.pallasBinding => _b.reddsaPallasBindingSign(
        sk,
        message,
        r.value!,
        sig,
      ),
    };
    if (rc != 0) {
      return BuResult.err(BuError.fromNativeCode(rc));
    }
    return BuResult.ok(sig);
  }

  @override
  BuResult<bool> verify({
    required BuReddsaDomain domain,
    required BuBytes pk,
    required BuBytes message,
    required BuBytes signature,
  }) {
    final c = _checkPk(pk, 'reddsa.verify');
    if (c.isErr) {
      return BuResult.err(c.error!);
    }
    if (signature.length != 64) {
      return BuResult.err(
        BuError.length(
          what: 'RedDSA signature',
          expected: 64,
          actual: signature.length,
        ),
      );
    }
    final rc = switch (domain) {
      BuReddsaDomain.jubjubAuth => _b.reddsaJubjubAuthVerify(
        pk,
        message,
        signature,
      ),
      BuReddsaDomain.jubjubBinding => _b.reddsaJubjubBindingVerify(
        pk,
        message,
        signature,
      ),
      BuReddsaDomain.pallasAuth => _b.reddsaPallasAuthVerify(
        pk,
        message,
        signature,
      ),
      BuReddsaDomain.pallasBinding => _b.reddsaPallasBindingVerify(
        pk,
        message,
        signature,
      ),
    };
    if (rc == 0) {
      return BuResult.ok(true);
    }
    if (rc == 1 || rc == 5 || rc == 14) {
      return BuResult.ok(false);
    }
    return BuResult.err(BuError.fromNativeCode(rc));
  }

  @override
  BuResult<BuBytes> jubjubAuthSign({
    required BuBytes sk,
    required BuBytes message,
    BuBytes? rand80,
  }) => sign(
    domain: BuReddsaDomain.jubjubAuth,
    sk: sk,
    message: message,
    rand80: rand80,
  );
  @override
  BuResult<bool> jubjubAuthVerify({
    required BuBytes pk,
    required BuBytes message,
    required BuBytes signature,
  }) => verify(
    domain: BuReddsaDomain.jubjubAuth,
    pk: pk,
    message: message,
    signature: signature,
  );
  @override
  BuResult<BuBytes> jubjubBindingSign({
    required BuBytes sk,
    required BuBytes message,
    BuBytes? rand80,
  }) => sign(
    domain: BuReddsaDomain.jubjubBinding,
    sk: sk,
    message: message,
    rand80: rand80,
  );
  @override
  BuResult<bool> jubjubBindingVerify({
    required BuBytes pk,
    required BuBytes message,
    required BuBytes signature,
  }) => verify(
    domain: BuReddsaDomain.jubjubBinding,
    pk: pk,
    message: message,
    signature: signature,
  );
  @override
  BuResult<BuBytes> pallasAuthSign({
    required BuBytes sk,
    required BuBytes message,
    BuBytes? rand80,
  }) => sign(
    domain: BuReddsaDomain.pallasAuth,
    sk: sk,
    message: message,
    rand80: rand80,
  );
  @override
  BuResult<bool> pallasAuthVerify({
    required BuBytes pk,
    required BuBytes message,
    required BuBytes signature,
  }) => verify(
    domain: BuReddsaDomain.pallasAuth,
    pk: pk,
    message: message,
    signature: signature,
  );
  @override
  BuResult<BuBytes> pallasBindingSign({
    required BuBytes sk,
    required BuBytes message,
    BuBytes? rand80,
  }) => sign(
    domain: BuReddsaDomain.pallasBinding,
    sk: sk,
    message: message,
    rand80: rand80,
  );
  @override
  BuResult<bool> pallasBindingVerify({
    required BuBytes pk,
    required BuBytes message,
    required BuBytes signature,
  }) => verify(
    domain: BuReddsaDomain.pallasBinding,
    pk: pk,
    message: message,
    signature: signature,
  );

  int _curveIdFor(BuReddsaDomain domain) {
    switch (domain) {
      case BuReddsaDomain.jubjubAuth:
      case BuReddsaDomain.jubjubBinding:
        return BuCurveId.jubjub;
      case BuReddsaDomain.pallasAuth:
      case BuReddsaDomain.pallasBinding:
        return BuCurveId.pallas;
    }
  }

  @override
  bool isValidPublicKey({
    required BuReddsaDomain domain,
    required List<int> publicKey,
  }) {
    if (publicKey.length != 32) {
      return false;
    }
    final pk = BuBytes.from(publicKey);
    final one = BuBytes.zero(32)..[0] = 1; // LE
    final out = BuBytes.zero(32);
    return _b.curveMul(_curveIdFor(domain), one, pk, out) == 0;
  }

  @override
  bool isValidSecretKey({
    required BuReddsaDomain domain,
    required List<int> secret,
  }) {
    if (secret.length != 32) {
      return false;
    }
    final s = BuBytes.from(secret);
    return _b.curveScCheck(_curveIdFor(domain), s) == 1;
  }

  @override
  BuResult<BuBytes> normalizeJubjubPublicKey(List<int> publicKey) {
    return _normalize(BuCurveId.jubjub, publicKey);
  }

  @override
  BuResult<BuBytes> normalizePallasPublicKey(List<int> publicKey) {
    return _normalize(BuCurveId.pallas, publicKey);
  }

  BuResult<BuBytes> _normalize(int curveId, List<int> publicKey) {
    final n = _b.curvePointLen(curveId);
    if (n <= 0) {
      return BuResult.err(BuError.internalErr(message: 'unknown point length'));
    }
    final out = BuBytes.zero(n);
    final pk = BuBytes.from(publicKey);
    final rc = _b.curveNormalizePubkey(curveId, pk, out);
    if (rc != 0) {
      return BuResult.err(
        BuError.fromNativeCode(rc, details: {'op': 'normalizePublicKey'}),
      );
    }
    return BuResult.ok(out);
  }
}
