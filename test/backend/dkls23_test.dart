import 'package:blockchain_utils_connector/blockchain_utils_connector.dart';
import 'package:test/test.dart';

import '../test_utils.dart';

/// DKLs23 threshold ECDSA: import -> sign -> verify against the summed group
/// key, plus rejection contracts. All secrets/seeds are inline literals.
void runDkls23Suite(Bu Function() openBu) {
  final sid = BuBytes(List<int>.filled(32, 0x51));
  final seeds2 = BuBytes(List<int>.filled(64, 0x33));
  final msgHash = BuBytes(List<int>.generate(32, (i) => i + 4));

  String hx(List<int> b) =>
      b.map((e) => e.toRadixString(16).padLeft(2, '0')).join();

  group('dkls23 secp256k1', () {
    test('importSecrets -> sign -> verify under summed group key', () {
      final bu = openBu();
      final d = bu.dkls23;
      const curve = BuDkls23Curve.secp256k1;
      final s1 = BuBytes(List<int>.filled(32, 0x11));
      final s2 = BuBytes(List<int>.filled(32, 0x22));
      // Additive quorum: group key == pk1 + pk2 on secp256k1.
      final pk1 = bu.curves.secp256k1().multBase(s1).unwrapOrThrow();
      final pk2 = bu.curves.secp256k1().multBase(s2).unwrapOrThrow();
      final group = bu.curves.secp256k1().add(pk1, pk2).unwrapOrThrow();
      expect(group, hasLength(33));
      final blob =
          d
              .importSecrets(
                curve: curve,
                secretsConcat: BuBytes([...s1, ...s2]),
                n: 2,
              )
              .unwrapOrThrow();
      final sig =
          d
              .sign(
                curve: curve,
                sid: sid,
                msgHash32: msgHash,
                sharesBlob: blob,
                seeds: seeds2,
              )
              .unwrapOrThrow();
      expect(sig, hasLength(64));
      expect(
        d
            .verify(
              curve: curve,
              groupPk33: group,
              msgHash32: msgHash,
              sig64: sig,
            )
            .unwrapOrThrow(),
        isTrue,
      );
      expect(
        d
            .verify(
              curve: curve,
              groupPk33: group,
              msgHash32: BuBytes(List<int>.filled(32, 9)),
              sig64: sig,
            )
            .unwrapOrThrow(),
        isFalse,
      );
      // xOnly is the 32-byte half of the compressed group key.
      expect(
        hx(d.xOnly(curve: curve, groupPk33: group).unwrapOrThrow()),
        hx(group.sublist(1)),
      );
    });

    test('rejection contracts', () {
      final bu = openBu();
      final d = bu.dkls23;
      const curve = BuDkls23Curve.secp256k1;
      expect(
        d
            .importSecrets(curve: curve, secretsConcat: BuBytes([1, 2]), n: 2)
            .isErr,
        isTrue,
      );
      expect(
        d.dkg(curve: curve, sid: sid, n: 1, t: 2, seeds: seeds2).isErr,
        isTrue,
      );
    });
  });
}

/// Standalone entry: `dart test test/backend/dkls23_test.dart` (VM, FFI backend).
void main() async {
  await ConnectorTestApi.ensureBackend();
  runDkls23Suite(() => ConnectorTestApi.bu);
}
