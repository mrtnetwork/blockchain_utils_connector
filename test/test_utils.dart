import 'package:blockchain_utils_connector/blockchain_utils_connector.dart';
import 'package:test/test.dart';

import 'test_backend.dart';

export 'test_backend.dart';
import 'test_backend_stub.dart'
    if (dart.library.io) 'test_backend_io.dart'
    as backend_io;

/// Shared backend bootstrap for `blockchain_utils_connector` tests.
///
/// Browser-safe: this file imports neither `dart:io` nor `dart:ffi` directly
/// (VM access goes through the conditional `test_backend_io.dart` import).
/// Selection order: explicit [configure] → environment (VM only) → default.
///
/// VM examples:
/// ```sh
/// BU_BACKEND=ffi dart test test/hash_ffi_test.dart
/// BU_BACKEND=ffi BU_LIB_PATH=/path/to/libblockchain_utils.so dart test test/
/// BU_BACKEND=ffi BU_BUILD=ffi dart test test/   # cargo-build .so if missing
/// ```
/// Browser (see `test/browser_wasm_test.dart`):
/// ```sh
/// CHROME_EXECUTABLE=/tmp/chrome-nosandbox.sh dart test -p chrome test/browser_wasm_test.dart
/// ```
/// with WASM assets built via `dart tool/build_backends.dart --wasm`
/// (served from `test/wasm_assets/`).
class ConnectorTestApi {
  static bool _inited = false;
  static BuTestConfig? _explicit;
  static Bu? _bu;

  /// Pins an explicit backend config (overrides environment). A test `main()`
  /// may `await ensureBackend()` after this for cargo builds.
  static void configure(BuTestConfig config) {
    _explicit = config;
    _inited = false;
    _bu = null;
  }

  static BuTestConfig _resolve([BuTestConfig? override]) {
    return override ?? _explicit ?? BuTestConfig.fromEnv();
  }

  /// Resolves + applies the backend, building the FFI library with cargo
  /// first when missing and `BU_BUILD=ffi|all|1` (VM only). Call once from an
  /// async `main()` before registering tests to allow builds:
  /// ```dart
  /// void main() async {
  ///   await ConnectorTestApi.ensureBackend();
  ///   ...register tests...
  /// }
  /// ```
  static Future<void> ensureBackend([BuTestConfig? config]) async {
    if (_inited) return;
    final c = _resolve(config);
    if (c.backend == BuTestBackend.wasm) {
      throw UnsupportedError(
        'wasm backend needs a browser: run '
        '`dart test -p chrome test/browser_wasm_test.dart` '
        '(or call ConnectorTestApi.initWasmBrowser on web).',
      );
    }
    final path = await backend_io.ensureFfiLibrary(
      explicitPath: c.ffiLibraryPath,
      profile: c.ffiProfile,
      buildMissing: c.buildMissing,
      features: c.ffiFeatures,
      noDefaultFeatures: c.ffiNoDefaultFeatures,
    );
    _bu = Bu.init(c.toBuConfig(resolvedFfiPath: path));
    _inited = true;
  }

  /// Browser entry point: loads the WASM glue/module from [config] (defaults
  /// `wasm_assets/bu.js` + auto-located `bu_bg.wasm`, served by `dart test`
  /// from `test/wasm_assets/`) and opens the backend. Web only.
  static Future<void> initWasmBrowser([BuTestConfig? config]) async {
    final c = _resolve(config);
    final buConfig = c.toBuConfig();
    await Bu.ensureWasmLoaded(buConfig);
    _bu = Bu.init(buConfig);
    _inited = true;
  }

  static void _initSync() {
    if (_inited) return;
    final c = _resolve();
    if (c.backend == BuTestBackend.wasm) {
      throw UnsupportedError(
        'wasm backend needs a browser: run '
        '`dart test -p chrome test/browser_wasm_test.dart` '
        '(or call ConnectorTestApi.initWasmBrowser on web).',
      );
    }
    // Fast sync path: no cargo involved (use ensureBackend()/BU_BUILD=ffi
    // to build when missing).
    String? path = c.ffiLibraryPath;
    try {
      path ??= backend_io.defaultFfiLibraryPath(profile: c.ffiProfile);
      if (!backend_io.ffiLibraryExists(path)) {
        if (c.buildMissing) {
          throw StateError(
            'FFI library missing: $path. Call '
            '`await ConnectorTestApi.ensureBackend()` from an async '
            'main() (or run `dart tool/build_backends.dart --ffi`) to '
            'build it with cargo first.',
          );
        }
        path = null; // fall back to platform default lookup
      }
    } on UnsupportedError {
      path = c.ffiLibraryPath;
    }
    _bu = Bu.init(c.toBuConfig(resolvedFfiPath: path));
    _inited = true;
  }

  /// Opened backend (initializes synchronously on first use).
  static Bu get bu {
    _initSync();
    return _bu!;
  }

  /// Opens a fresh backend instance with the same resolved config
  /// (useful for tests that must not share handles).
  static Bu openFresh() {
    _initSync();
    final c = _resolve();
    String? path = c.ffiLibraryPath;
    try {
      path ??= backend_io.defaultFfiLibraryPath(profile: c.ffiProfile);
      if (!backend_io.ffiLibraryExists(path)) path = null;
    } on UnsupportedError {
      path = c.ffiLibraryPath;
    }
    return Bu.init(c.toBuConfig(resolvedFfiPath: path));
  }
}

/// Skips the current test with [message] when the FFI backend cannot be
/// opened (missing library and no `BU_BUILD=ffi`). Use inside tests that
/// support a pure `skip:` fast path:
/// ```dart
/// final bu = ConnectorTestApi.tryBu();
/// if (bu == null) {
///   markTestSkipped('native lib missing');
///   return;
/// }
/// ```
Bu? tryBu() {
  try {
    return ConnectorTestApi.bu;
  } on StateError catch (e) {
    markTestSkipped('$e');
    return null;
  }
}
