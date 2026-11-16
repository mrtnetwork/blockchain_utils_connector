import 'package:blockchain_utils_connector/src/bytes/bytes.dart';
import 'package:blockchain_utils_connector/src/error/bu_error.dart';
import 'package:blockchain_utils_connector/src/platform/bindings.dart';

abstract final class BuKdf {
  static BuResult<BuBytes> pbkdf2(
    BuPlatformBindings bindings, {
    int prf = BuKdfPrf.sha256,
    required List<int> password,
    required List<int> salt,
    required int iterations,
    required int length,
  }) {
    final pw = BuBytes.owned(password);
    final sa = BuBytes.owned(salt);
    try {
      final out = BuBytes.zero(length);
      bindings.pbkdf2(
        prf: prf,
        password: pw,
        salt: sa,
        iterations: iterations,
        out: out,
      );
      return BuResult.ok(out);
    } catch (_) {
      return BuResult.err(BuError.internal);
    } finally {
      pw.zero();
      sa.zero();
    }
  }

  static BuResult<BuBytes> scrypt(
    BuPlatformBindings bindings, {
    required List<int> password,
    required List<int> salt,
    required int n,
    required int r,
    required int p,
    required int length,
  }) {
    if (length <= 0) {
      return BuResult.err(BuError.invalidLength);
    }
    final pw = BuBytes.owned(password);
    final sa = BuBytes.owned(salt);
    try {
      final out = BuBytes.zero(length);
      bindings.scrypt(password: pw, salt: sa, n: n, r: r, p: p, out: out);
      return BuResult.ok(out);
    } catch (_) {
      return BuResult.err(BuError.internal);
    } finally {
      pw.zero();
      sa.zero();
    }
  }
}
