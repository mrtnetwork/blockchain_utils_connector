import 'package:blockchain_utils_connector/src/platform/bindings.dart';
import 'package:blockchain_utils_connector/src/error/bu_error.dart';
import 'package:blockchain_utils_connector/src/connector/bu_config.dart';
import 'package:blockchain_utils_connector/src/connector/io/ffi_platform.dart';

BuPlatformBindings openPlatformBindings(BuConfig config) {
  return FfiPlatformBindings.open(config.libraryPath);
}

/// WASM is never loaded on native targets.
Future<void> ensurePlatformWasmLoaded(BuConfig config) {
  throw BuError(
    DefaultErrorType.unsupported,
    'ensurePlatformWasmLoaded is web-only; use libraryPath on native.',
  );
}
