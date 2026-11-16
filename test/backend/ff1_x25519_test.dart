import 'package:blockchain_utils_connector/blockchain_utils_connector.dart';
import 'package:test/test.dart';

import '../test_utils.dart';

/// FF1 + X25519: roundtrips, DH consistency, and pinned vectors.
///
/// Runs on FFI and WASM. All inputs are inline literals — no files.
void runFf1X25519Suite(Bu Function() openBu) {
  String hx(List<int> b) =>
      b.map((e) => e.toRadixString(16).padLeft(2, '0')).join();

  group('ff1', () {
    test('digit roundtrip + tweak separation', () {
      final bu = openBu();
      final key = List<int>.generate(16, (i) => i);
      const pt = [1, 2, 3, 4, 5, 6];
      final ct =
          bu.ff1
              .encrypt(key: key, radix: 10, pt: pt, tweak: [9])
              .unwrapOrThrow();
      expect(ct.length, pt.length);
      expect(
        bu.ff1.decrypt(key: key, radix: 10, ct: ct, tweak: [9]).unwrapOrThrow(),
        pt,
      );
      // Wrong tweak fails to recover.
      expect(
        bu.ff1.decrypt(key: key, radix: 10, ct: ct, tweak: [8]).unwrapOrThrow(),
        isNot(pt),
      );
    });

    test('binary roundtrip', () {
      final bu = openBu();
      final key = List<int>.generate(16, (i) => i + 5);
      final pt = [0xDE, 0xAD, 0xBE, 0xEF, 0x01, 0x02, 0x03, 0x04, 0x05, 0x06];
      final ct =
          bu.ff1.encryptBinary(key: key, pt: pt, tweak: [1, 2]).unwrapOrThrow();
      expect(
        bu.ff1.decryptBinary(key: key, ct: ct, tweak: [1, 2]).unwrapOrThrow(),
        pt,
      );
    });
  });

  group('x25519', () {
    test('pinned DH pair (1,2)', () {
      final bu = openBu();
      expect(
        hx(
          bu.x25519
              .diffieHellman(
                privateKey: List<int>.filled(32, 1),
                peerPublic: List<int>.filled(32, 2),
              )
              .unwrapOrThrow(),
        ),
        '047f039121185037c302191e45982949f7d9b2c310cf0e173321535fbc14df3e',
      );
    });

    test('DH symmetry: dh(a, pubB) == dh(b, pubA)', () {
      final bu = openBu();
      final a = List<int>.filled(32, 0xA)..[0] = 0x10;
      final b = List<int>.filled(32, 0xB)..[0] = 0x20;
      final pubA = bu.x25519.publicKey(a).unwrapOrThrow();
      final pubB = bu.x25519.publicKey(b).unwrapOrThrow();
      expect(pubA, hasLength(32));
      final s1 =
          bu.x25519
              .diffieHellman(privateKey: a, peerPublic: pubB)
              .unwrapOrThrow();
      final s2 =
          bu.x25519
              .diffieHellman(privateKey: b, peerPublic: pubA)
              .unwrapOrThrow();
      expect(s1, s2);
      expect(s1.any((x) => x != 0), isTrue);
    });

    test('ed25519 conversions smoke', () {
      final bu = openBu();
      final seed = List<int>.filled(32, 1);
      final edPk = bu.ed25519Signing.publicKey(BuBytes(seed)).unwrapOrThrow();
      final xpk = bu.x25519.fromEd25519PublicKey(edPk.toList()).unwrapOrThrow();
      expect(xpk, hasLength(32));
      final xsk = bu.x25519.fromEd25519Seed(seed).unwrapOrThrow();
      expect(xsk, hasLength(32));
    });
  });
}

/// Standalone entry: `dart test test/backend/ff1_x25519_test.dart` (VM, FFI backend).
void main() async {
  await ConnectorTestApi.ensureBackend();
  runFf1X25519Suite(() => ConnectorTestApi.bu);
}
