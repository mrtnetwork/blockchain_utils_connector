/// Browser-stub twin of `test_backend_io.dart` (same signatures).
/// Imported only through the conditional import in `test_utils.dart`.
library;

bool ffiLibraryExists(String path) {
  throw UnsupportedError('ffiLibraryExists needs the Dart VM.');
}

Future<String> ensureFfiLibrary({
  String? explicitPath,
  String profile = 'release',
  bool buildMissing = false,
  bool cloneIfMissing = true,
}) {
  throw UnsupportedError('ensureFfiLibrary needs the Dart VM.');
}

String defaultFfiLibraryPath({String profile = 'release'}) {
  throw UnsupportedError('defaultFfiLibraryPath needs the Dart VM.');
}

String defaultWasmOutDir() {
  throw UnsupportedError('defaultWasmOutDir needs the Dart VM.');
}

Future<void> ensureWasmAssets({
  String? outDir,
  String profile = 'release',
  bool force = false,
  bool cloneIfMissing = true,
}) {
  throw UnsupportedError('ensureWasmAssets needs the Dart VM.');
}

Future<String> ensureRustCrate({String? dir, bool cloneIfMissing = false}) {
  throw UnsupportedError('ensureRustCrate needs the Dart VM.');
}
