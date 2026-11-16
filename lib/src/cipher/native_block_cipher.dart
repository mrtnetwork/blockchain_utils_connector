import 'package:blockchain_utils_connector/src/bytes/bytes.dart';
import 'package:blockchain_utils_connector/src/error/bu_error.dart';
import 'package:blockchain_utils_connector/src/platform/bindings.dart';
import 'package:blockchain_utils_connector/src/cipher/block_cipher.dart';

/// Token freed by [_finalizer] when a [BuNativeAes] is GC'd without [clean].
/// Holds only the bindings + opaque handle — never the owner.
class _AesFinalizerToken {
  _AesFinalizerToken(this.bindings, this.handle);

  final BuPlatformBindings bindings;
  final Object handle;

  void clean() {
    try {
      bindings.aesFree(handle);
    } catch (_) {
      // Best-effort: already freed explicitly.
    }
  }
}

class BuNativeAes implements BuBlockCipher, SecretState {
  BuNativeAes._(this._b, this._handle, this._key) {
    _finalizer.attach(this, _AesFinalizerToken(_b, _handle), detach: this);
  }

  /// Safety net: `aesFree` when GC'd without [clean].
  static final Finalizer<_AesFinalizerToken> _finalizer = Finalizer(
    (token) => token.clean(),
  );
  final BuPlatformBindings _b;
  final Object _handle;
  final BuBytes _key;
  bool _cleaned = false;

  static BuResult<BuNativeAes> create(BuPlatformBindings b, BuBytes key) {
    if (key.length != 16 && key.length != 24 && key.length != 32) {
      return BuResult.err(BuError.invalidKey);
    }
    final owned = BuBytes.owned(key);
    try {
      final h = b.aesNew(owned);
      return BuResult.ok(BuNativeAes._(b, h, owned));
    } catch (_) {
      owned.zero();
      return BuResult.err(BuError.internal);
    }
  }

  @override
  int get blockSize => 16;

  @override
  BuBytes encryptBlock(List<int> src, [List<int>? dst]) {
    if (_cleaned) throw BuError.invalidState;
    final s = BuBytes.from(src);
    final o = dst == null ? BuBytes.zero(16) : BuBytes.from(dst);
    _b.aesEncryptBlock(_handle, s, o);
    return o;
  }

  @override
  BuBytes decryptBlock(List<int> src, [List<int>? dst]) {
    if (_cleaned) throw BuError.invalidState;
    final s = BuBytes.from(src);
    final o = dst == null ? BuBytes.zero(16) : BuBytes.from(dst);
    _b.aesDecryptBlock(_handle, s, o);
    return o;
  }

  @override
  void clean() {
    if (_cleaned) return;
    _cleaned = true;
    _finalizer.detach(this);
    _b.aesFree(_handle);
    _key.zero();
  }

  /// Alias of [clean] for the [SecretState] disposal contract.
  @override
  void dispose() => clean();
}

class BuNativeAesCbc implements BuBlockCipherCbc {
  BuNativeAesCbc._(this._b, this._key, this._iv);
  final BuPlatformBindings _b;
  final BuBytes _key;
  final BuBytes _iv;
  bool _cleaned = false;

  static BuResult<BuNativeAesCbc> create(
    BuPlatformBindings b,
    BuBytes key,
    BuBytes iv,
  ) {
    if (iv.length != 16) {
      return BuResult.err(BuError.invalidNonce);
    }
    return BuResult.ok(
      BuNativeAesCbc._(b, BuBytes.owned(key), BuBytes.owned(iv)),
    );
  }

  @override
  BuBytes encrypt(List<int> data, [List<int>? dst]) {
    if (_cleaned) throw BuError.invalidState;
    final d = BuBytes.from(data);
    final o = BuBytes.zero(d.length);
    _b.aesCbcEncrypt(key: _key, iv: _iv, data: d, out: o);
    return o;
  }

  @override
  BuBytes decrypt(List<int> data, [List<int>? dst]) {
    if (_cleaned) throw BuError.invalidState;
    final d = BuBytes.from(data);
    final o = BuBytes.zero(d.length);
    _b.aesCbcDecrypt(key: _key, iv: _iv, data: d, out: o);
    return o;
  }

  @override
  void clean() {
    _cleaned = true;
    _key.zero();
    _iv.zero();
  }
}

class BuNativeAesEcb implements BuAesEcb {
  BuNativeAesEcb._(this._b, this._key, this._padding);
  final BuPlatformBindings _b;
  final BuBytes _key;
  final BuPaddingAlgorithm _padding;
  bool _cleaned = false;

  static BuResult<BuNativeAesEcb> create(
    BuPlatformBindings b,
    BuBytes key,
    BuPaddingAlgorithm padding,
  ) {
    if (key.length != 16 && key.length != 24 && key.length != 32) {
      return BuResult.err(BuError.invalidKey);
    }
    return BuResult.ok(BuNativeAesEcb._(b, BuBytes.owned(key), padding));
  }

  int get _padCode => switch (_padding) {
    BuPaddingAlgorithm.none => 0,
    BuPaddingAlgorithm.pkcs7 => 1,
    BuPaddingAlgorithm.iso7816 => 2,
    BuPaddingAlgorithm.x923 => 3,
  };

  @override
  BuBytes encrypt(List<int> data) {
    if (_cleaned) throw BuError.invalidState;
    final d = BuBytes.from(data);
    return _b.aesEcbEncryptPadded(key: _key, data: d, padding: _padCode);
  }

  @override
  BuBytes? decrypt(List<int> data) {
    if (_cleaned) throw BuError.invalidState;
    final d = BuBytes.from(data);
    return _b.aesEcbDecryptPadded(key: _key, data: d, padding: _padCode);
  }

  @override
  void clean() {
    _cleaned = true;
    _key.zero();
  }
}

class BuNativeAesCtr implements BuAesCtr {
  BuNativeAesCtr._(this._b, this._key, this._counter);
  final BuPlatformBindings _b;
  final BuBytes _key;
  final BuBytes _counter;
  bool _cleaned = false;

  static BuResult<BuNativeAesCtr> create(
    BuPlatformBindings b,
    BuBytes key,
    BuBytes iv,
  ) {
    final counter = BuBytes.zero(16);
    final src = iv.length >= 16 ? iv : iv;
    final n = src.length < 16 ? src.length : 16;
    for (var i = 0; i < n; i++) {
      counter[i] = src[i];
    }
    return BuResult.ok(BuNativeAesCtr._(b, BuBytes.owned(key), counter));
  }

  @override
  void process(List<int> data, List<int> out) {
    if (_cleaned) throw BuError.invalidState;
    final d = BuBytes.from(data);
    final o = BuBytes.from(out);
    _b.aesCtr(key: _key, counter: _counter, data: d, out: o);
  }

  @override
  void clean() {
    _cleaned = true;
    _key.zero();
    _counter.zero();
  }
}
