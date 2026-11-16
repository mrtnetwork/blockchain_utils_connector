import 'package:blockchain_utils_connector/src/api/rng_api.dart';
import 'package:blockchain_utils_connector/src/bytes/bytes.dart';
import 'package:blockchain_utils_connector/src/error/bu_error.dart';
import 'package:blockchain_utils_connector/src/platform/bindings.dart';

class DefaultRngApi implements BuRngApi {
  DefaultRngApi(this._b);
  final BuPlatformBindings _b;
  static const _tag = 'rng';

  @override
  BuResult<void> seed({required List<int> seed32}) {
    final s = BuBytes.from(seed32);
    if (s.length != 32) {
      return BuResult.err(
        BuError.length(what: 'seed', expected: 32, actual: s.length),
      );
    }
    final rc = _b.rngSeed(s);
    if (rc == 0) {
      return BuResult.ok(null);
    }
    if (rc == 2) {
      return BuResult.err(
        BuError(DefaultErrorType.invalidState, '$_tag.seed: already seeded'),
      );
    }
    return BuResult.err(BuError.fromNativeCode(7));
  }

  @override
  bool get isSeeded => _b.rngIsSeeded() == 1;

  @override
  BuResult<BuBytes> fill({required int length}) {
    if (length <= 0) {
      return BuResult.err(
        BuError.length(what: 'length', expected: 1, actual: length),
      );
    }
    final out = BuBytes.zero(length);
    final rc = _b.rngFill(out);
    if (rc == 0) {
      return BuResult.ok(out);
    }
    return BuResult.err(BuError.fromNativeCode(7));
  }
}
