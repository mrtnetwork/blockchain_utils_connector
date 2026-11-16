import 'package:blockchain_utils_connector/src/bytes/bytes.dart';
import 'package:blockchain_utils_connector/src/error/bu_error.dart';

/// Global ChaCha20 RNG (seeded once via `bu_rng_seed`).
///
/// Clean surface over `BuPlatformBindings.rngSeed/rngIsSeeded/rngFill`.
/// No new native symbols needed.
abstract interface class BuRngApi {
  /// Seed the global RNG with exactly 32 bytes. Second call reports
  /// [DefaultErrorType.invalidState] (Rust `BU_RNG_ALREADY`).
  BuResult<void> seed({required List<int> seed32});

  /// True when the global RNG was seeded.
  bool get isSeeded;

  /// Fill [length] bytes from the global RNG.
  BuResult<BuBytes> fill({required int length});
}
