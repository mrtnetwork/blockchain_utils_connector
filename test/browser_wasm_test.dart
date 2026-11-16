@TestOn('browser')
@Tags(['wasm'])
library;

import 'package:test/test.dart';

import 'backend_suite.dart';
import 'test_utils.dart';
import 'unit/bytes_test.dart';

/// Browser entry: WASM backend. Run with:
/// ```sh
/// CHROME_EXECUTABLE=<wrapper with --no-sandbox> dart test -p chrome test/browser_wasm_test.dart
/// ```
/// with WASM assets built via `dart tool/build_backends.dart --wasm`
/// (served from `test/wasm_assets/`).
void main() {
  setUpAll(() async {
    // Shared harness: imports the glue module (served by the dart-test
    // static handler from test/wasm_assets/), waits for bootstrap, then
    // opens the backend. No .so involved.
    // Optional overrides: pass an explicit config:
    //   await ConnectorTestApi.initWasmBrowser(const BuTestConfig(
    //     backend: BuTestBackend.wasm,
    //     wasmGlueUrl: 'https://host/bu.js',
    //     wasmModuleUrl: 'https://host/bu_bg.wasm',
    //   ));
    await ConnectorTestApi.initWasmBrowser();
  });

  runBytesUnitSuite();
  runBackendSuite(() => ConnectorTestApi.bu);
}
