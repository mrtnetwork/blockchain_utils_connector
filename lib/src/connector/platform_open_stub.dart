import 'package:blockchain_utils_connector/src/error/bu_error.dart';
import 'package:blockchain_utils_connector/src/platform/bindings.dart';
import 'package:blockchain_utils_connector/src/connector/bu_config.dart';

BuPlatformBindings openPlatformBindings(BuConfig config) {
  throw BuError.unsupportedAlgo(message: 'no platform backend for this target');
}

/// No platform backend on this target.
Future<void> ensurePlatformWasmLoaded(BuConfig config) {
  throw BuError.unsupportedAlgo(message: 'no platform backend for this target');
}
