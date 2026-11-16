import 'package:blockchain_utils_connector/blockchain_utils_connector.dart';
import 'package:test/test.dart';

import '../test_utils.dart';

/// BLS12-381 (min-PK and min-sig): keygen, sign/verify, aggregate, and
/// tamper-fails-closed. All keys/messages are inline literals — no files.
void runBlsSuite(Bu Function() openBu) {
  String hx(List<int> b) =>
      b.map((e) => e.toRadixString(16).padLeft(2, '0')).join();

  group('bls', () {
    test('pinned G1 pubkey for sk=7', () {
      final bu = openBu();
      final pk =
          bu.blsSigning
              .publicKeyG1(BuBytes(List<int>.filled(32, 7)))
              .unwrapOrThrow();
      expect(pk, hasLength(48));
      expect(
        hx(pk),
        'a4cafe0e4602bb74340d45b931591034894f6be4aae24c4e80931d622636bb4da64804903072c655995b423113f41705',
      );
      final pk2 =
          bu.blsSigning
              .publicKeyG2(BuBytes(List<int>.filled(32, 7)))
              .unwrapOrThrow();
      expect(pk2, hasLength(96));
    });

    test('minPk sign/verify + tamper', () {
      final bu = openBu();
      final b = bu.blsSigning;
      final sk = BuBytes(List<int>.filled(32, 3));
      final pk = b.publicKeyG1(sk).unwrapOrThrow();
      final msg = BuBytes([1, 2, 3, 4]);
      final sig = b.signMinPk(sk: sk, message: msg).unwrapOrThrow();
      expect(sig, hasLength(96));
      expect(
        b.verifyMinPk(pk: pk, message: msg, signature: sig).unwrapOrThrow(),
        isTrue,
      );
      expect(
        b
            .verifyMinPk(pk: pk, message: BuBytes([1, 2, 3, 5]), signature: sig)
            .unwrapOrThrow(),
        isFalse,
      );
    });

    test('bls hash-to-curve determinism + pinned G1', () {
      final bu = openBu();
      BuBytes h1(List<int> m, List<int> d, int n) {
        final out = BuBytes.zero(n);
        expect(
          n == 48
              ? bu.bindings.blsHashToG1(BuBytes(m), BuBytes(d), out)
              : bu.bindings.blsHashToG2(BuBytes(m), BuBytes(d), out),
          0,
        );
        return out;
      }

      expect(
        hx(h1([104, 105], [68, 83, 84], 48)),
        '96ca43c7c79c0bcfb25c0ce809b65ce3e262046727989027aee052a0706c4905'
        '2d1ee2935dc7625288e5b9fde78d7b35',
      );
      expect(
        hx(h1([104, 105], [68, 83, 84], 48)),
        hx(h1([104, 105], [68, 83, 84], 48)),
      );
      expect(
        hx(h1([104, 105], [68, 83, 84], 48)),
        isNot(hx(h1([104, 106], [68, 83, 84], 48))),
      );
      final g2 = h1([104, 105], [68, 83, 84], 96);
      expect(g2, hasLength(96));
      expect(
        hx(g2).substring(0, 64),
        '834e8f715687833d5ec9db858ab9dad9f66a25a41b0b08d689e9610454f0d24b',
      );
    });

    test('minSig sign/verify + aggregate + fast-aggregate', () {
      final bu = openBu();
      final b = bu.blsSigning;
      final sk1 = BuBytes(List<int>.filled(32, 5));
      final sk2 = BuBytes(List<int>.filled(32, 6));
      final msg = BuBytes([9, 9, 9]);
      final pk1 = b.publicKeyG2(sk1).unwrapOrThrow();
      final pk2 = b.publicKeyG2(sk2).unwrapOrThrow();
      final sig1 = b.signMinSig(sk: sk1, message: msg).unwrapOrThrow();
      final sig2 = b.signMinSig(sk: sk2, message: msg).unwrapOrThrow();
      expect(
        b.verifyMinSig(pk: pk1, message: msg, signature: sig1).unwrapOrThrow(),
        isTrue,
      );
      // Same-message aggregate verifies under the aggregated key.
      final apk =
          b.aggregatePublicKeysG2(BuBytes.concat([pk1, pk2])).unwrapOrThrow();
      final asig =
          b.aggregateSignaturesG1(BuBytes.concat([sig1, sig2])).unwrapOrThrow();
      expect(
        b
            .fastAggregateVerifyMinSig(
              aggregatePublicKey: apk,
              message: msg,
              signature: asig,
            )
            .unwrapOrThrow(),
        isTrue,
      );
      // Wrong message fails.
      expect(
        b
            .fastAggregateVerifyMinSig(
              aggregatePublicKey: apk,
              message: BuBytes([9, 9, 8]),
              signature: asig,
            )
            .unwrapOrThrow(),
        isFalse,
      );
    });
  });
}

/// Standalone entry: `dart test test/backend/bls_test.dart` (VM, FFI backend).
void main() async {
  await ConnectorTestApi.ensureBackend();
  runBlsSuite(() => ConnectorTestApi.bu);
}
