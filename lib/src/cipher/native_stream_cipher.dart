import 'package:blockchain_utils_connector/src/bytes/bytes.dart';
import 'package:blockchain_utils_connector/src/error/bu_error.dart';
import 'package:blockchain_utils_connector/src/platform/bindings.dart';
import 'package:blockchain_utils_connector/src/cipher/stream_cipher.dart';

class BuNativeChaCha20 implements BuStreamCipher {
  BuNativeChaCha20._(this._b, this._key);
  final BuPlatformBindings _b;
  final BuBytes _key;
  bool _cleaned = false;

  static BuResult<BuNativeChaCha20> create(BuPlatformBindings b, BuBytes key) {
    if (key.length != 32) {
      return BuResult.err(BuError.invalidKey);
    }
    return BuResult.ok(BuNativeChaCha20._(b, BuBytes.owned(key)));
  }

  @override
  BuBytes process(
    List<int> data, {
    required List<int> nonce,
    int nonceInplaceCounterLength = 0,
    int seekBytes = 0,
    List<int>? dst,
  }) {
    if (_cleaned) throw BuError.invalidState;
    final d = BuBytes.from(data);
    final n = BuBytes.from(nonce);
    final o = dst == null ? BuBytes.zero(d.length) : BuBytes.from(dst);

    // Match Dart layout:
    //   counter = zeros(16); counter.setRange(16-nonce.length, 16, nonce);
    // When caller already built a 16-byte block, use inplace counter prefix.
    var inplace = nonceInplaceCounterLength;
    if (inplace == 0 && n.length == 16) {
      // Standard IETF: 4-byte counter + 12-byte nonce at the end.
      // If trailing 8 bytes look like classic 8-byte nonce (leading 8 zeros
      // beyond first 4), still use 4 — matches Dart setRange for 12-byte nonce.
      inplace = 4;
    } else if (inplace == 0 &&
        n.length != 8 &&
        n.length != 12 &&
        n.length != 16) {
      throw BuError.invalidNonce;
    }

    _b.chacha20StreamXor(
      key: _key,
      nonce: n,
      data: d,
      out: o,
      nonceInplaceCounterLength: inplace,
      seekBytes: seekBytes,
    );
    return o;
  }

  @override
  void clean() {
    _cleaned = true;
    _key.zero();
  }
}
