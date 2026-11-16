/// Backend selection for [Bu.init].
///
/// Cross-platform safe: only the fields matching the current platform are
/// used, the rest are ignored — one config value works on VM, web and mobile.
///
/// - Native VM (`dart.library.io`): [libraryPath] selects the dynamic
///   library (`DynamicLibrary.open`). `null` means the platform default name
///   (`libblockchain_utils.so` / `.dylib` / `.dll` on `PATH`).
/// - Web (`dart.library.js_interop`): [wasmGlueUrl] selects the
///   wasm-bindgen glue script (default `wasm_assets/bu.js`, resolved relative
///   to the page — e.g. served by `dart test` from `test/wasm_assets/`).
///   [wasmModuleUrl] overrides the `.wasm` location; when `null` the glue
///   auto-locates `<glue>_bg.wasm` next to itself.
class BuConfig {
  const BuConfig({
    this.libraryPath,
    this.librarySha256,
    this.wasmGlueUrl,
    this.wasmModuleUrl,
    @Deprecated('Use wasmModuleUrl instead.') this.wasmUrl,
  });

  /// FFI dynamic-library path. Native platforms only; ignored on web.
  ///
  /// An explicitly provided path must be absolute: relative paths resolve
  /// against the process working directory, which an attacker may influence
  /// (library hijacking). `null` keeps the platform default lookup.
  final String? libraryPath;

  /// Expected SHA-256 hex digest of the file at [libraryPath], verified
  /// before `DynamicLibrary.open`. Pinning fails closed: a mismatch, a
  /// missing file, or a non-explicit (linker-searched) library all throw.
  /// `null` (default) keeps the previous behavior: no verification.
  final String? librarySha256;

  /// wasm-bindgen glue script URL. Web only; ignored on native.
  /// Defaults to `wasm_assets/bu.js` when `null`.
  final String? wasmGlueUrl;

  /// `.wasm` module URL. Web only; `null` auto-locates it next to the glue.
  final String? wasmModuleUrl;

  /// Legacy alias of [wasmModuleUrl]. Prefer [wasmModuleUrl] in new code.
  @Deprecated('Use wasmModuleUrl instead.')
  final String? wasmUrl;

  /// Glue script URL after defaults.
  String get effectiveGlueUrl => wasmGlueUrl ?? 'wasm_assets/bu.js';

  /// `.wasm` module URL after defaults (`null` = auto-locate by the glue).
  String? get effectiveModuleUrl => wasmModuleUrl ?? wasmUrl;
}
