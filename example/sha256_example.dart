import 'package:blockchain_utils_connector/blockchain_utils_connector.dart';

/// SHA-256 + BLAKE2b-256 over the FFI backend.
///
/// ```sh
/// dart run example/sha256_example.dart [library-path]
/// ```
///
/// Without [library-path] the platform default lookup is used
/// (`libblockchain_utils.so` on `PATH`); point it at a cargo-built
/// `target/<profile>/libblockchain_utils.so` otherwise
/// (see `dart tool/build_backends.dart --ffi`).
void main(List<String> args) {
  final bu = Bu.init(BuConfig(libraryPath: args.isEmpty ? null : args.single));

  final sha = bu.hash.sha256().unwrapOrThrow();
  sha.update([0x61, 0x62, 0x63]); // "abc"
  print('sha256(abc): ${_hex(sha.digest())}');
  sha.clean();

  final b2 = bu.hash.blake2b(digestLength: 32).unwrapOrThrow();
  b2.update([0x68, 0x69]); // "hi"
  print('blake2b-256(hi): ${_hex(b2.digest())}');
  b2.clean();
}

String _hex(List<int> bytes) =>
    bytes.map((e) => e.toRadixString(16).padLeft(2, '0')).join();
