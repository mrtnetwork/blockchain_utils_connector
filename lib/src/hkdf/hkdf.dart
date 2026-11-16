import 'package:blockchain_utils_connector/src/bytes/bytes.dart';
import 'package:blockchain_utils_connector/src/error/bu_error.dart';
import 'package:blockchain_utils_connector/src/platform/bindings.dart';

class BuHkdf {
  BuHkdf({
    required this.bindings,
    required this.prf,
    required this.ikm,
    this.salt,
    this.info,
  });
  final BuPlatformBindings bindings;
  final int prf;
  final BuBytes ikm;
  final BuBytes? salt;
  final BuBytes? info;

  BuResult<BuBytes> expand({required int length}) {
    try {
      final out = BuBytes.zero(length);
      bindings.hkdf(prf: prf, ikm: ikm, salt: salt, info: info, out: out);
      return BuResult.ok(out);
    } catch (_) {
      return BuResult.err(BuError.internal);
    }
  }
}
