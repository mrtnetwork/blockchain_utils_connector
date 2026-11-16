import 'package:blockchain_utils_connector/blockchain_utils_connector.dart';
import 'package:test/test.dart';

import '../test_utils.dart';

/// KDF + RNG: lengths, determinism, domain separation, and fail-closed
/// misuse paths. All inputs are inline literals — no files, no skips.
void runKdfRngSuite(Bu Function() openBu) {
  String hx(List<int> b) =>
      b.map((e) => e.toRadixString(16).padLeft(2, '0')).join();

  group('kdf', () {
    test('pbkdf2-sha512 length + determinism + salt sensitivity', () {
      final bu = openBu();
      BuBytes dk(List<int> s) =>
          bu.hash
              .pbkdf2Sha512DeriveKey(
                password: [1, 2, 3],
                salt: s,
                iterations: 2,
                length: 64,
              )
              .unwrapOrThrow();
      expect(dk([4, 5]), hasLength(64));
      expect(hx(dk([4, 5])), hx(dk([4, 5])));
      expect(hx(dk([4, 5])), isNot(hx(dk([4, 6]))));
    });

    test('scrypt length + determinism (n=2^14 light)', () {
      final bu = openBu();
      BuBytes sc(List<int> s) =>
          BuKdf.scrypt(
            bu.bindings,
            password: [1, 2, 3],
            salt: s,
            n: 16384,
            r: 8,
            p: 1,
            length: 32,
          ).unwrapOrThrow();
      final a = sc([9, 9]);
      expect(a, hasLength(32));
      expect(hx(a), hx(sc([9, 9])));
      expect(hx(a), isNot(hx(sc([9, 10]))));
    });

    test('hkdf expand length + info separation', () {
      final bu = openBu();
      BuBytes hk(List<int> info) =>
          BuHkdf(
            bindings: bu.bindings,
            prf: BuKdfPrf.sha256,
            ikm: BuBytes([11, 22, 33]),
            salt: BuBytes([44, 55]),
            info: BuBytes(info),
          ).expand(length: 42).unwrapOrThrow();
      expect(hk([1]), hasLength(42));
      expect(hx(hk([1])), isNot(hx(hk([2]))));
    });

    test('kdf rejects bad lengths', () {
      final bu = openBu();
      expect(
        bu.hash
            .pbkdf2Sha256DeriveKey(
              password: [1],
              salt: [2],
              iterations: 1,
              length: 0,
            )
            .isErr,
        isTrue,
      );
      expect(
        BuKdf.scrypt(
          bu.bindings,
          password: [1],
          salt: [2],
          n: 16,
          r: 1,
          p: 1,
          length: 0,
        ).isErr,
        isTrue,
      );
    });
  });

  group('rng', () {
    test('seed once -> fill nonzero; reseed rejected', () {
      final bu = openBu();
      final first = bu.rng.seed(seed32: List<int>.filled(32, 7));
      // Fresh (ok) or already seeded by an earlier suite in this process:
      // both are legal; anything else is a bug.
      expect(
        first.isOk || first.error?.type == DefaultErrorType.invalidState,
        isTrue,
      );
      expect(bu.rng.isSeeded, isTrue);
      final out = bu.rng.fill(length: 64).unwrapOrThrow();
      expect(out, hasLength(64));
      expect(out.any((b) => b != 0), isTrue);
      // Exactly-once seed semantics: seeding again must fail.
      expect(bu.rng.seed(seed32: List<int>.filled(32, 8)).isErr, isTrue);
      expect(bu.rng.fill(length: 0).isErr, isTrue);
    });
  });
}

/// Standalone entry: `dart test test/backend/kdf_rng_test.dart` (VM, FFI backend).
void main() async {
  await ConnectorTestApi.ensureBackend();
  runKdfRngSuite(() => ConnectorTestApi.bu);
}
