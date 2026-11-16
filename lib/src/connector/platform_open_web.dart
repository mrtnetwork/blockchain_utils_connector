import 'package:blockchain_utils_connector/src/platform/bindings.dart';
import 'package:blockchain_utils_connector/src/connector/bu_config.dart';
import 'package:blockchain_utils_connector/src/connector/web/wasm_platform.dart';

BuPlatformBindings openPlatformBindings(BuConfig config) {
  return WasmPlatformBindings.attach();
}

/// Loads the WASM module for [config] (imports the glue module unless the
/// page already bootstrapped `BuWasm`). Web only; must be awaited before
/// [Bu.init] when the glue was not pre-imported via `<script type="module">`
/// tags.
Future<void> ensurePlatformWasmLoaded(BuConfig config) {
  return WasmPlatformBindings.ensureLoaded(
    glueUrl: config.effectiveGlueUrl,
    moduleUrl: config.effectiveModuleUrl,
  );
}
