import 'package:blockchain_utils_connector/src/aead/aead.dart';
import 'package:blockchain_utils_connector/src/aead/native_aead.dart';
import 'package:blockchain_utils_connector/src/api/aead_api.dart';
import 'package:blockchain_utils_connector/src/bytes/bytes.dart';
import 'package:blockchain_utils_connector/src/error/bu_error.dart';
import 'package:blockchain_utils_connector/src/platform/bindings.dart';

class DefaultAeadApi implements BuAeadApi {
  DefaultAeadApi(this._b);
  final BuPlatformBindings _b;
  @override
  BuResult<BuAead> chacha20Poly1305(List<int> key) =>
      BuNativeAead.chacha20Poly1305(_b, BuBytes.from(key));
  @override
  BuResult<BuAead> aesGcm(List<int> aesKey) =>
      BuNativeAead.aesGcm(_b, BuBytes.from(aesKey));
  @override
  BuResult<BuAead> xsalsa20Poly1305(List<int> key) =>
      BuNativeAead.xsalsa20Poly1305(_b, BuBytes.from(key));

  BuBytes _as(List<int> data) => BuBytes.from(data);

  BuError? _boxKeys(List<int> peerPublicKey, List<int> secretKey, String what) {
    return BuValidate.length(peerPublicKey, 32, what: 'peerPublicKey') ??
        BuValidate.length(secretKey, 32, what: 'secretKey');
  }

  BuError? _boxNonce(List<int> nonce, String what) {
    return BuValidate.length(nonce, 24, what: 'nonce');
  }

  @override
  BuResult<BuBytes> salsaBoxBeforenm({
    required List<int> peerPublicKey,
    required List<int> secretKey,
  }) {
    final argErr = _boxKeys(peerPublicKey, secretKey, 'salsaBoxBeforenm');
    if (argErr != null) {
      return BuResult.err(argErr);
    }
    try {
      return BuResult.ok(
        _b.salsaBoxBeforenm(
          peerPublicKey: _as(peerPublicKey),
          secretKey: _as(secretKey),
        ),
      );
    } on BuError catch (e) {
      return BuResult.err(e);
    }
  }

  @override
  BuResult<BuBytes> salsaBoxEncrypt({
    required List<int> peerPublicKey,
    required List<int> secretKey,
    required List<int> nonce,
    required List<int> plaintext,
  }) {
    final argErr =
        _boxKeys(peerPublicKey, secretKey, 'salsaBoxEncrypt') ??
        _boxNonce(nonce, 'salsaBoxEncrypt');
    if (argErr != null) {
      return BuResult.err(argErr);
    }
    try {
      final out = BuBytes.zero(plaintext.length + 16);
      _b.salsaBoxEncrypt(
        peerPublicKey: _as(peerPublicKey),
        secretKey: _as(secretKey),
        nonce: _as(nonce),
        plaintext: _as(plaintext),
        out: out,
      );
      return BuResult.ok(out);
    } on BuError catch (e) {
      return BuResult.err(e);
    }
  }

  @override
  BuResult<BuBytes?> salsaBoxDecrypt({
    required List<int> peerPublicKey,
    required List<int> secretKey,
    required List<int> nonce,
    required List<int> sealed,
  }) {
    final argErr =
        _boxKeys(peerPublicKey, secretKey, 'salsaBoxDecrypt') ??
        _boxNonce(nonce, 'salsaBoxDecrypt');
    if (argErr != null) {
      return BuResult.err(argErr);
    }
    // Truncated attacker input fails closed (null), like the Dart backend.
    if (sealed.length < 16) {
      return BuResult.ok(null);
    }
    try {
      final out = BuBytes.zero(sealed.length - 16);
      final ok = _b.salsaBoxDecrypt(
        peerPublicKey: _as(peerPublicKey),
        secretKey: _as(secretKey),
        nonce: _as(nonce),
        sealed: _as(sealed),
        out: out,
      );
      return BuResult.ok(ok ? out : null);
    } on BuError catch (e) {
      return BuResult.err(e);
    }
  }
}
