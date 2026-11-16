import 'package:blockchain_utils_connector/src/api/ed25519_signing_api.dart';
import 'package:blockchain_utils_connector/src/api/curve_id.dart';
import 'package:blockchain_utils_connector/src/bytes/bytes.dart';
import 'package:blockchain_utils_connector/src/error/bu_error.dart';
import 'package:blockchain_utils_connector/src/platform/bindings.dart';

class DefaultEd25519SigningApi implements BuEd25519SigningApi {
  DefaultEd25519SigningApi(this._b);
  final BuPlatformBindings _b;

  @override
  BuResult<BuBytes> publicKey(
    BuBytes secret, {
    BuEd25519Variant variant = BuEd25519Variant.ed25519,
  }) {
    if (variant == BuEd25519Variant.ed25519) {
      final out = BuBytes.zero(32);
      final k = BuBytes.owned(secret);
      try {
        final rc = _b.ed25519PublicKey(k, out);
        return rc == 0
            ? BuResult.ok(out)
            : BuResult.err(BuError.fromNativeCode(rc));
      } finally {
        k.zero();
      }
    }
    final out = BuBytes.zero(32);
    final k = BuBytes.owned(secret);
    try {
      final rc = _b.ed25519PublicKeyVariant(variant, k, out);
      return rc == 0
          ? BuResult.ok(out)
          : BuResult.err(BuError.fromNativeCode(rc));
    } finally {
      k.zero();
    }
  }

  @override
  BuResult<BuEd25519Signature> sign({
    required BuBytes secret,
    required BuBytes message,
    BuEd25519Variant variant = BuEd25519Variant.ed25519,
  }) {
    if (variant == BuEd25519Variant.ed25519) {
      final out = BuBytes.zero(64);
      final k = BuBytes.owned(secret);
      try {
        final rc = _b.ed25519Sign(k, message, out);
        return rc == 0
            ? BuResult.ok(BuEd25519Signature(out))
            : BuResult.err(BuError.fromNativeCode(rc));
      } finally {
        k.zero();
      }
    }
    final out = BuBytes.zero(64);
    final k = BuBytes.owned(secret);
    try {
      final rc = _b.ed25519SignVariant(variant, k, message, out);
      return rc == 0
          ? BuResult.ok(BuEd25519Signature(out))
          : BuResult.err(BuError.fromNativeCode(rc));
    } finally {
      k.zero();
    }
  }

  @override
  BuResult<bool> verify({
    required BuBytes publicKey,
    required BuBytes message,
    required BuEd25519Signature signature,
    BuEd25519Variant variant = BuEd25519Variant.ed25519,
  }) {
    if (variant == BuEd25519Variant.ed25519) {
      return BuResult.ok(
        _b.ed25519Verify(publicKey, message, signature.bytes) == 0,
      );
    }
    return BuResult.ok(
      _b.ed25519VerifyVariant(variant, publicKey, message, signature.bytes) ==
          0,
    );
  }

  @override
  bool isValidPublicKey(List<int> publicKey) {
    if (publicKey.length != 32) {
      return false;
    }
    final pk = BuBytes.from(publicKey);
    // decode via verify-style: ed25519 check uses point parse in curve path
    final one = BuBytes.zero(32);
    one[0] = 1; // LE scalar 1
    final out = BuBytes.zero(32);
    return _b.curveMul(BuCurveId.ed25519, one, pk, out) == 0;
  }

  @override
  bool isValidSecretKey(
    List<int> secret, {
    BuEd25519Variant variant = BuEd25519Variant.ed25519,
  }) {
    if (variant == BuEd25519Variant.ed25519Kholaw ||
        variant == BuEd25519Variant.ed25519Monero) {
      if (secret.length != 64) {
        return false;
      }
    } else if (secret.length != 32 && secret.length != 64) {
      return false;
    }
    // Non-all-zero check for seed; for 32-byte seed any bytes accepted by expand
    var nonzero = false;
    for (final b in secret) {
      if (b != 0) {
        nonzero = true;
        break;
      }
    }
    return nonzero;
  }

  @override
  BuResult<BuBytes> normalizePublicKey(List<int> publicKey) {
    final n = _b.curvePointLen(BuCurveId.ed25519);
    if (n <= 0) {
      return BuResult.err(BuError.internalErr(message: 'unknown point length'));
    }
    final out = BuBytes.zero(n);
    final pk = BuBytes.from(publicKey);
    final rc = _b.curveNormalizePubkey(BuCurveId.ed25519, pk, out);
    if (rc != 0) {
      return BuResult.err(
        BuError.fromNativeCode(rc, details: {'op': 'normalizePublicKey'}),
      );
    }
    return BuResult.ok(out);
  }
}
