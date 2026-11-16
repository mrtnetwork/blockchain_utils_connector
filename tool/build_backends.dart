/// Prebuilds the Rust backends used by `blockchain_utils_connector` tests.
///
/// ```sh
/// dart tool/build_backends.dart --ffi [--profile debug|release]
/// dart tool/build_backends.dart --wasm [--profile release] [--force]
/// dart tool/build_backends.dart --all [--profile release] [--force]
/// ```
///
/// The Rust checkout resolves via `BU_RUST_CRATE`, else a managed
/// `<package>/build/rust-crate` directory, which is downloaded from
/// `https://github.com/mrtnetwork/blockchain-utils` on demand
/// (unless `--no-clone`).
/// WASM assets land in `test/wasm_assets/` (served by `dart test -p chrome`).
library;

import 'dart:io' show exit, stderr, stdout;

import '../test/test_backend_io.dart' as bio;

const _usage = '''
Usage: dart tool/build_backends.dart (--ffi|--wasm|--all) [options]

Targets (at least one required):
  --ffi       cargo-build the FFI shared library used by VM tests.
  --wasm      cargo-build the WASM module + wasm-bindgen glue into
              test/wasm_assets/.
  --all       both of the above.

Options:
  --profile=<debug|release>  cargo profile (default: release).
  --force                    rebuild WASM assets even when bu.js and
                             bu_bg.wasm already exist.
  --no-clone                 never clone the Rust crate; fail when the
                             checkout is missing.
  -h, --help                 print this usage.
''';

Future<void> main(List<String> args) async {
  var ffi = false;
  var wasm = false;
  var profile = 'release';
  var force = false;
  var clone = true;
  for (final arg in args) {
    switch (arg) {
      case '--ffi':
        ffi = true;
      case '--wasm':
        wasm = true;
      case '--all':
        ffi = true;
        wasm = true;
      case '--force':
        force = true;
      case '--no-clone':
        clone = false;
      case '-h':
      case '--help':
        stdout.write(_usage);
        return;
      default:
        if (arg.startsWith('--profile=')) {
          profile = arg.substring('--profile='.length);
        } else {
          stderr.writeln('Unknown argument: $arg\n$_usage');
          exit(2);
        }
    }
  }
  if (profile != 'debug' && profile != 'release') {
    stderr.writeln('Invalid --profile=$profile (want debug|release).\n$_usage');
    exit(2);
  }
  if (!ffi && !wasm) {
    stderr.writeln('Nothing to build: pass --ffi, --wasm, or --all.\n$_usage');
    exit(2);
  }
  try {
    if (ffi) {
      final path = await bio.ensureFfiLibrary(
        profile: profile,
        buildMissing: true,
        cloneIfMissing: clone,
      );
      stdout.writeln('FFI library: $path');
    }
    if (wasm) {
      await bio.ensureWasmAssets(
        profile: profile,
        force: force,
        cloneIfMissing: clone,
      );
      stdout.writeln('WASM assets: ${bio.defaultWasmOutDir()}');
    }
  } on StateError catch (e) {
    stderr.writeln('build_backends failed: $e');
    rethrow;
  }
}
