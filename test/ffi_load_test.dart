@TestOn('vm')
library;

/// FFI load contract: whatever the library was built with, loading it must
/// never crash the process.
///
/// - `Bu.init` succeeds for standard and reduced feature sets (core hash /
///   AEAD / cipher / curve symbols are mandatory; every other domain is
///   optional and reports `unsupported` instead of faulting).
/// - If `Bu.init` itself cannot resolve the core symbols it fails closed
///   with a Dart-level error (`ArgumentError` from symbol lookup) — still
///   no native crash.
/// - Every probe below must complete without throwing anything but
///   [BuError] (a segfault would kill the runner: non-zero exit).
///
/// Run against the default build:
/// ```sh
/// dart test test/ffi_load_test.dart
/// ```
/// or against any custom build (e.g. reduced features):
/// ```sh
/// dart tool/build_backends.dart --ffi --profile=debug \
///   --features=ffi --no-default-features
/// BU_LIB_PATH=$PWD/build/rust-crate/target/debug/libblockchain_utils.so \
/// BU_FFI_PROFILE=debug dart test test/ffi_load_test.dart
/// ```
import 'package:blockchain_utils_connector/blockchain_utils_connector.dart';
import 'package:test/test.dart';

import 'test_utils.dart';

String _hx(List<int> bytes) =>
    bytes.map((e) => e.toRadixString(16).padLeft(2, '0')).join();

/// Runs [op]; passes when it completes with any [BuResult] (ok or err) or
/// throws [BuError]. Anything else (including a native crash, which fails
/// the whole run) is a failure.
void _graceful(String name, Object? Function() op) {
  test(name, () {
    try {
      op();
    } on BuError {
      // Fail-closed domain: expected when the backend lacks the feature.
    }
  });
}

void main() async {
  await ConnectorTestApi.ensureBackend();
  final bu = ConnectorTestApi.bu;

  test('backend loads: backendInfo is readable', () {
    final info = bu.backendInfo;
    expect(info.interfaceVersion, greaterThanOrEqualTo(0));
    expect(info.features, greaterThanOrEqualTo(0));
  });

  test('core hash executes (sha256 empty vector)', () {
    final h = bu.hash.sha256().unwrapOrThrow();
    try {
      h.update([]);
      expect(
        _hx(h.digest()),
        'e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855',
      );
    } finally {
      h.clean();
    }
  });

  group('optional domains fail closed, never crash', () {
    _graceful('rng fill', () => bu.rng.fill(length: 8));
    _graceful('merlin open', () => bu.transcripts.merlin(label: [0x01]));
    _graceful('strobe open', () => bu.transcripts.strobe(protocol: [0x02]));
    _graceful(
      'sapling params rejected without native fault',
      () => bu.sapling.setSpendParams(params: [1, 2, 3]),
    );
    _graceful(
      'hw fingerprint without native fault',
      () => bu.hw.ledgerFingerprint(),
    );
  });
}
