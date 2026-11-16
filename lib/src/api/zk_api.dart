import 'package:blockchain_utils_connector/src/connector/bu_features.dart';

/// ZK bridge version / logging, plus backend build introspection.
///
/// Mirrors Rust `ffi::zkcodes`: `ZK_API_VERSION == 1`, logging is an
/// accepted no-op (no backend linked). Build introspection mirrors
/// `bu_build_version` / `bu_build_features` (FFI) and `backendVersion` /
/// `backendFeatures` (WASM).
abstract interface class BuZkApi {
  /// API version (currently 1).
  int version();

  /// Accepted no-op logging toggle. Returns true on `ZK_OK`.
  bool enableLogging({int enable = 1, int mode = 0});

  /// Backend interface version (currently 1). `0` = pre-introspection build.
  int backendVersion();

  /// Cargo feature bitmask of the attached artifact (see [BuBuildFeature]).
  int backendFeatures();

  /// Whether the attached backend was compiled with [feature].
  bool hasFeature(BuBuildFeature feature);
}
