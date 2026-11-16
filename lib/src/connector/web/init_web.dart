import 'package:blockchain_utils_connector/src/connector/bu.dart';

/// Web init. When the glue script was not preloaded, await
/// [Bu.ensureWasmLoaded] first so `BuWasm` is bootstrapped.
Bu initWeb({String? wasmGlueUrl, String? wasmModuleUrl, String? wasmUrl}) {
  return Bu.init(
    BuConfig(wasmGlueUrl: wasmGlueUrl, wasmModuleUrl: wasmModuleUrl ?? wasmUrl),
  );
}
