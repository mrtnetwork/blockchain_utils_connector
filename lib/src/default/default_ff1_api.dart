import 'package:blockchain_utils_connector/src/api/ff1_api.dart';
import 'package:blockchain_utils_connector/src/bytes/bytes.dart';
import 'package:blockchain_utils_connector/src/error/bu_error.dart';
import 'package:blockchain_utils_connector/src/platform/bindings.dart';

class DefaultFf1Api implements BuFf1Api {
  DefaultFf1Api(this._b);
  final BuPlatformBindings _b;
  BuBytes _as(List<int> x) => BuBytes.from(x);

  static BuError _map(int rc) => BuError.fromNativeCode(switch (rc) {
    0 => 7, // unreachable: callers check rc != 0 first
    1 => 1,
    2 => 9,
    3 => 10,
    4 => 10,
    5 => 4,
    _ => rc,
  });

  @override
  BuResult<BuBytes> encrypt({
    required List<int> key,
    required int radix,
    required List<int> pt,
    List<int> tweak = const [],
  }) {
    if (pt.isEmpty) {
      return BuResult.err(BuError.length(what: 'pt', expected: 2, actual: 0));
    }
    final out = BuBytes.zero(pt.length);
    final rc = _b.ff1Encrypt(
      key: _as(key),
      radix: radix,
      pt: _as(pt),
      tweak: tweak.isEmpty ? null : _as(tweak),
      out: out,
    );
    return rc == 0 ? BuResult.ok(out) : BuResult.err(_map(rc));
  }

  @override
  BuResult<BuBytes> decrypt({
    required List<int> key,
    required int radix,
    required List<int> ct,
    List<int> tweak = const [],
  }) {
    if (ct.isEmpty) {
      return BuResult.err(BuError.length(what: 'ct', expected: 2, actual: 0));
    }
    final out = BuBytes.zero(ct.length);
    final rc = _b.ff1Decrypt(
      key: _as(key),
      radix: radix,
      ct: _as(ct),
      tweak: tweak.isEmpty ? null : _as(tweak),
      out: out,
    );
    return rc == 0 ? BuResult.ok(out) : BuResult.err(_map(rc));
  }

  @override
  BuResult<BuBytes> encryptBinary({
    required List<int> key,
    required List<int> pt,
    List<int> tweak = const [],
  }) {
    if (pt.isEmpty) {
      return BuResult.err(BuError.length(what: 'pt', expected: 1, actual: 0));
    }
    final out = BuBytes.zero(pt.length);
    final rc = _b.ff1EncryptBinary(
      key: _as(key),
      pt: _as(pt),
      tweak: tweak.isEmpty ? null : _as(tweak),
      out: out,
    );
    return rc == 0 ? BuResult.ok(out) : BuResult.err(_map(rc));
  }

  @override
  BuResult<BuBytes> decryptBinary({
    required List<int> key,
    required List<int> ct,
    List<int> tweak = const [],
  }) {
    if (ct.isEmpty) {
      return BuResult.err(BuError.length(what: 'ct', expected: 1, actual: 0));
    }
    final out = BuBytes.zero(ct.length);
    final rc = _b.ff1DecryptBinary(
      key: _as(key),
      ct: _as(ct),
      tweak: tweak.isEmpty ? null : _as(tweak),
      out: out,
    );
    return rc == 0 ? BuResult.ok(out) : BuResult.err(_map(rc));
  }
}
