import 'package:blockchain_utils_connector/src/bytes/bytes.dart';
import 'package:blockchain_utils_connector/src/error/bu_error.dart';
import 'package:blockchain_utils_connector/src/platform/bindings.dart';
import 'package:blockchain_utils_connector/src/aead/aead.dart';

enum _Kind { chacha, aesGcm, xsalsa }

class BuNativeAead implements BuAead {
  BuNativeAead._(this._b, this._key, this._kind);
  final BuPlatformBindings _b;
  final BuBytes _key;
  final _Kind _kind;
  bool _cleaned = false;

  static BuResult<BuNativeAead> chacha20Poly1305(
    BuPlatformBindings b,
    BuBytes key,
  ) {
    if (key.length != 32) {
      return BuResult.err(BuError.invalidKey);
    }
    return BuResult.ok(BuNativeAead._(b, BuBytes.owned(key), _Kind.chacha));
  }

  static BuResult<BuNativeAead> aesGcm(BuPlatformBindings b, BuBytes key) {
    if (key.length != 16 && key.length != 24 && key.length != 32) {
      return BuResult.err(BuError.invalidKey);
    }
    return BuResult.ok(BuNativeAead._(b, BuBytes.owned(key), _Kind.aesGcm));
  }

  /// XSalsa20-Poly1305 (NaCl secretbox). Wire order `TAG ‖ CIPHERTEXT`
  /// (authenticator first) — unlike ChaCha20-Poly1305 / AES-GCM.
  static BuResult<BuNativeAead> xsalsa20Poly1305(
    BuPlatformBindings b,
    BuBytes key,
  ) {
    if (key.length != 32) {
      return BuResult.err(BuError.invalidKey);
    }
    return BuResult.ok(BuNativeAead._(b, BuBytes.owned(key), _Kind.xsalsa));
  }

  @override
  int get nonceLength => _kind == _Kind.xsalsa ? 24 : 12;
  @override
  int get tagLength => 16;

  void _ensure() {
    if (_cleaned) throw BuError.invalidState;
  }

  @override
  BuBytes encrypt(
    List<int> nonce,
    List<int> plaintext, {
    List<int>? associatedData,
    List<int>? dst,
  }) {
    _ensure();
    final n = BuBytes.from(nonce);
    final pt = BuBytes.from(plaintext);
    final aad = associatedData == null ? null : (BuBytes.from(associatedData));
    if (_kind == _Kind.xsalsa && n.length != 24) throw BuError.invalidNonce;
    final out = BuBytes.zero(pt.length + tagLength);
    if (_kind == _Kind.chacha) {
      _b.chacha20Poly1305Encrypt(
        key: _key,
        nonce: n,
        plaintext: pt,
        aad: aad,
        out: out,
      );
    } else if (_kind == _Kind.xsalsa) {
      // NaCl secretbox authenticates the ciphertext only.
      if (aad != null && aad.isNotEmpty) throw BuError.unsupported;
      _b.xsalsa20Poly1305Encrypt(key: _key, nonce: n, plaintext: pt, out: out);
    } else {
      _b.aesGcmEncrypt(key: _key, nonce: n, plaintext: pt, aad: aad, out: out);
    }
    return out;
  }

  @override
  BuBytes? decrypt(
    List<int> nonce,
    List<int> ciphertext, {
    List<int>? associatedData,
    List<int>? dst,
  }) {
    _ensure();
    final n = BuBytes.from(nonce);
    final ct = BuBytes.from(ciphertext);
    // XSalsa20 (NaCl secretbox) demands a strict 24-byte nonce: programmer
    // error, so throw before treating short input as decrypt failure.
    if (_kind == _Kind.xsalsa && n.length != 24) throw BuError.invalidNonce;
    if (ct.length < tagLength) {
      return null;
    }
    final aad = associatedData == null ? null : (BuBytes.from(associatedData));
    final out = BuBytes.zero(ct.length - tagLength);
    bool ok;
    if (_kind == _Kind.chacha) {
      ok = _b.chacha20Poly1305Decrypt(
        key: _key,
        nonce: n,
        ciphertext: ct,
        aad: aad,
        out: out,
      );
    } else if (_kind == _Kind.xsalsa) {
      if (aad != null && aad.isNotEmpty) throw BuError.unsupported;
      ok = _b.xsalsa20Poly1305Decrypt(
        key: _key,
        nonce: n,
        sealed: ct,
        out: out,
      );
    } else {
      ok = _b.aesGcmDecrypt(
        key: _key,
        nonce: n,
        ciphertext: ct,
        aad: aad,
        out: out,
      );
    }
    return ok ? out : null;
  }

  @override
  void clean() {
    _cleaned = true;
    _key.zero();
  }
}
