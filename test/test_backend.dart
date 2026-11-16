/// Backend selection + configuration for `blockchain_utils_connector` tests.
///
/// Browser-safe: this file imports neither `dart:io` nor `dart:ffi`
/// (environment access goes through the conditional `test_backend_env_*`
/// pair; WASM loading through `Bu.ensureWasmLoaded`). VM-only helpers
/// (cargo builds) live in `test_backend_io.dart`.
///
/// Resolution order for every field: explicit [BuTestConfig] value →
/// environment variable (VM only) → built-in default.
///
/// Environment (VM):
/// - `BU_BACKEND=ffi|wasm` (`rust`/`native` are aliases of `ffi`;
///   `web`/`browser`/`chrome` are aliases of `wasm`). Default `ffi`.
/// - `BU_LIB_PATH` — FFI `.so`/`.dylib`/`.dll` path. Default: auto-resolved
///   to `<rust-crate>/target/<profile>/libblockchain_utils.so`, where the
///   crate is `BU_RUST_CRATE` or the managed `<package>/build/rust-crate`
///   checkout (downloaded on demand, honoring `BU_FFI_PROFILE` (`release`,
///   default) and `CARGO_TARGET_DIR`.
/// - `BU_BUILD=1|ffi|wasm|all` — build the backend with cargo when the
///   artifact is missing (VM only; same as calling `tool/build_backends.dart`).
/// - `BU_WASM_GLUE_URL` — glue script URL (default `wasm_assets/bu.js`).
/// - `BU_WASM_MODULE_URL` — `.wasm` module URL (default: auto-located next
///   to the glue script).
library;

import 'package:blockchain_utils_connector/blockchain_utils_connector.dart'
    show BuConfig;

import 'test_backend_env_stub.dart'
    if (dart.library.io) 'test_backend_env_vm.dart'
    as test_env;

/// Reads a raw env var (VM `Platform.environment`) / define default.
/// Browser-safe: stub returns the define default (`null` unless passed).
String? testEnvVar(String name, {String? defineDefault}) {
  return test_env.testEnvVar(name, defineDefault: defineDefault);
}

/// Selectable test backend (connector has no pure-Dart backend).
enum BuTestBackend {
  /// Rust backend over FFI (`Bu.init(libraryPath:)`). VM only.
  ffi,

  /// Rust backend over WASM (glue/module URLs). Browser only.
  wasm;

  /// Parses `BU_BACKEND` values; unknown/empty → [ffi].
  static BuTestBackend parse(String? value) {
    switch (value?.trim().toLowerCase()) {
      case 'wasm':
      case 'web':
      case 'browser':
      case 'chrome':
        return BuTestBackend.wasm;
      case 'ffi':
      case 'rust':
      case 'native':
      case null:
      case '':
        return BuTestBackend.ffi;
      default:
        return BuTestBackend.ffi;
    }
  }
}

/// Backend configuration. Construct explicitly or via [BuTestConfig.fromEnv].
class BuTestConfig {
  const BuTestConfig({
    this.backend = BuTestBackend.ffi,
    this.ffiLibraryPath,
    this.ffiProfile = 'release',
    this.buildMissing = false,
    this.wasmGlueUrl = 'wasm_assets/bu.js',
    this.wasmModuleUrl,
  });

  /// Explicit config; resolution order per field: argument → env → default.
  factory BuTestConfig.fromEnv({
    BuTestBackend? backend,
    String? ffiLibraryPath,
    String? ffiProfile,
    bool? buildMissing,
    String? wasmGlueUrl,
    String? wasmModuleUrl,
  }) {
    final build = test_env.testEnvVar('BU_BUILD');
    return BuTestConfig(
      backend:
          backend ?? BuTestBackend.parse(test_env.testEnvVar('BU_BACKEND')),
      ffiLibraryPath: ffiLibraryPath ?? test_env.testEnvVar('BU_LIB_PATH'),
      ffiProfile:
          ffiProfile ?? test_env.testEnvVar('BU_FFI_PROFILE') ?? 'release',
      buildMissing:
          buildMissing ??
          (build == '1' ||
              (build ?? '')
                  .split(',')
                  .any((p) => p.trim() == 'ffi' || p.trim() == 'all')),
      wasmGlueUrl:
          wasmGlueUrl ??
          test_env.testEnvVar('BU_WASM_GLUE_URL') ??
          'wasm_assets/bu.js',
      wasmModuleUrl: wasmModuleUrl ?? test_env.testEnvVar('BU_WASM_MODULE_URL'),
    );
  }

  /// Active backend.
  final BuTestBackend backend;

  /// FFI library path (`null` = auto-resolve, VM only).
  final String? ffiLibraryPath;

  /// Cargo profile used to resolve/build the FFI library (`release` default).
  final String ffiProfile;

  /// Build the backend with cargo when the artifact is missing (VM only).
  final bool buildMissing;

  /// wasm-bindgen glue script URL (browser only).
  final String wasmGlueUrl;

  /// `.wasm` module URL; `null` auto-locates next to the glue (browser only).
  final String? wasmModuleUrl;

  /// Whether `BU_BUILD` also requests a WASM rebuild (VM only).
  bool get buildWasm {
    final build = test_env.testEnvVar('BU_BUILD');
    if (build == null) return buildMissing;
    final parts = build.split(',').map((p) => p.trim()).toSet();
    return parts.contains('1') ||
        parts.contains('all') ||
        parts.contains('wasm');
  }

  /// Converts to the connector's [BuConfig].
  BuConfig toBuConfig({String? resolvedFfiPath}) {
    return BuConfig(
      libraryPath: resolvedFfiPath ?? ffiLibraryPath,
      wasmGlueUrl: wasmGlueUrl,
      wasmModuleUrl: wasmModuleUrl,
    );
  }
}
