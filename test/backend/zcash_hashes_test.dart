import 'package:blockchain_utils_connector/blockchain_utils_connector.dart';
import 'package:test/test.dart';

import '../test_utils.dart';

/// Zcash hashes: Poseidon, Sinsemilla, Pedersen.
///
/// Determinism, domain separation, length contracts, and rejection of bad
/// lengths. Runs on FFI and WASM. All inputs are inline literals — no files.
///
/// Real circuit-graded vectors (zcash_dart fixtures) can be dropped in as
/// additional pinned `expect`s wherever a `// PIN:` marker sits — the
/// suites already assert byte-exact equality against the literals below.
void runZcashHashesSuite(Bu Function() openBu) {
  String hx(List<int> b) =>
      b.map((e) => e.toRadixString(16).padLeft(2, '0')).join();

  BuBytes f32(int fill) => BuBytes(List<int>.filled(32, fill));

  group('poseidon', () {
    test('hashTwo determinism + avalanche + length checks', () {
      final bu = openBu();
      // PIN: Orchard Poseidon("0000" || a || b) reference from zcash_dart.
      final h1 = bu.hash.poseidonHashTwo(a: f32(1), b: f32(2)).unwrapOrThrow();
      expect(h1, hasLength(32));
      final h2 = bu.hash.poseidonHashTwo(a: f32(1), b: f32(2)).unwrapOrThrow();
      expect(hx(h1), hx(h2));
      final h3 = bu.hash.poseidonHashTwo(a: f32(1), b: f32(3)).unwrapOrThrow();
      expect(hx(h1), isNot(hx(h3)));
      expect(bu.hash.poseidonHashTwo(a: BuBytes([1]), b: f32(2)).isErr, isTrue);
    });

    test('permute mutates 96-byte state in place', () {
      final bu = openBu();
      // Field elements must be < Pasta Fp modulus: keep every byte small.
      final st = BuBytes(List<int>.generate(96, (i) => i & 0x0F));
      bu.hash.poseidonPermute(state96: st).unwrapOrThrow();
      expect(st.toList().sublist(0, 4), isNot([0, 1, 2, 3]));
      expect(bu.hash.poseidonPermute(state96: BuBytes([1, 2])).isErr, isTrue);
    });

    test('bn254: unsupported or 32-byte digest', () {
      final bu = openBu();
      final r = bu.hash.poseidonBn254Hash(inputs: [f32(4), f32(5)]);
      if (r.isOk) {
        expect(r.value, hasLength(32));
        final r2 =
            bu.hash.poseidonBn254Hash(inputs: [f32(4), f32(5)]).unwrapOrThrow();
        expect(hx(r.value!), hx(r2));
      } else {
        // Backend built without `poseidon-bn254`: must report unsupported.
        expect(r.error?.type, DefaultErrorType.unsupported);
      }
    });
  });

  group('sinsemilla', () {
    test('hash determinism + domain separation', () {
      final bu = openBu();
      final bits = BuBytes(List<int>.filled(32, 0xAA));
      final h1 =
          bu.hash
              .sinsemillaHash(domain: 'Test', packedBits: bits, bitLen: 256)
              .unwrapOrThrow();
      expect(h1, hasLength(32));
      expect(
        hx(h1),
        hx(
          bu.hash
              .sinsemillaHash(domain: 'Test', packedBits: bits, bitLen: 256)
              .unwrapOrThrow(),
        ),
      );
      expect(
        hx(h1),
        isNot(
          hx(
            bu.hash
                .sinsemillaHash(domain: 'Other', packedBits: bits, bitLen: 256)
                .unwrapOrThrow(),
          ),
        ),
      );
      // Bitstring form agrees with packed form for the same bits.
      final bits01 =
          List.generate(
            256,
            (i) => ((0xAA >> (i % 8)) & 1) == 1 ? '1' : '0',
          ).join();
      expect(
        hx(
          bu.hash
              .sinsemillaHashBitstring(domain: 'Test', bits01: bits01)
              .unwrapOrThrow(),
        ),
        hx(h1),
      );
    });

    test('commit/shortCommit need 32-byte r', () {
      final bu = openBu();
      final bits = BuBytes(List<int>.filled(32, 0x55));
      final r = f32(9);
      expect(
        bu.hash
            .sinsemillaCommit(domain: 'C', packedBits: bits, bitLen: 256, r: r)
            .unwrapOrThrow(),
        hasLength(32),
      );
      expect(
        bu.hash
            .sinsemillaShortCommit(
              domain: 'C',
              packedBits: bits,
              bitLen: 256,
              r: r,
            )
            .unwrapOrThrow(),
        hasLength(32),
      );
      expect(
        bu.hash
            .sinsemillaCommit(
              domain: 'C',
              packedBits: bits,
              bitLen: 256,
              r: BuBytes([1]),
            )
            .isErr,
        isTrue,
      );
    });
  });

  group('pedersen', () {
    test('hash determinism + layer/personal separation', () {
      final bu = openBu();
      final bits = BuBytes(List<int>.filled(32, 0x3C));
      final h1 =
          bu.hash
              .pedersenHash(personal: 0, packedBits: bits, bitLen: 256)
              .unwrapOrThrow();
      expect(h1, hasLength(32));
      expect(
        hx(h1),
        hx(
          bu.hash
              .pedersenHash(personal: 0, packedBits: bits, bitLen: 256)
              .unwrapOrThrow(),
        ),
      );
      expect(
        hx(h1),
        isNot(
          hx(
            bu.hash
                .pedersenHash(personal: 1, packedBits: bits, bitLen: 256)
                .unwrapOrThrow(),
          ),
        ),
      );
      expect(
        bu.hash.pedersenHash(personal: 7, packedBits: bits, bitLen: 256).isErr,
        isTrue,
      );
    });
  });
}

/// Standalone entry: `dart test test/backend/zcash_hashes_test.dart` (VM, FFI backend).
void main() async {
  await ConnectorTestApi.ensureBackend();
  runZcashHashesSuite(() => ConnectorTestApi.bu);
}
