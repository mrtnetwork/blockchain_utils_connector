import 'package:blockchain_utils_connector/src/bytes/bytes.dart';
import 'package:blockchain_utils_connector/src/error/bu_error.dart';

/// FF1 (NIST SP 800-38G) format-preserving encryption.
///
/// Flexible path: digit arrays (each byte a digit in `0..radix-1`) →
/// `FlexibleNumeralString(digits)`.
///
/// Binary path: packed bit-bytes → `BinaryNumeralString(data)`.
abstract interface class BuFf1Api {
  /// Encrypt digits [pt] under AES key and optional [tweak].
  BuResult<BuBytes> encrypt({
    required List<int> key,
    required int radix,
    required List<int> pt,
    List<int> tweak = const [],
  });

  /// Decrypt digits [ct].
  BuResult<BuBytes> decrypt({
    required List<int> key,
    required int radix,
    required List<int> ct,
    List<int> tweak = const [],
  });

  /// Encrypt packed binary (radix 2). Returns bytes for `BinaryNumeralString`.
  BuResult<BuBytes> encryptBinary({
    required List<int> key,
    required List<int> pt,
    List<int> tweak = const [],
  });

  /// Decrypt packed binary (radix 2).
  BuResult<BuBytes> decryptBinary({
    required List<int> key,
    required List<int> ct,
    List<int> tweak = const [],
  });
}
