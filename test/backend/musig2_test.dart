import 'package:blockchain_utils_connector/blockchain_utils_connector.dart';
import 'package:test/test.dart';

import '../test_utils.dart';

/// MuSig2 (BIP-327) 2-of-2: key aggregation, nonces, partials, aggregate
/// verify, plus tamper-fails-closed. All keys are inline literals.
void runMusig2Suite(Bu Function() openBu) {
  group('musig2 2-of-2', () {
    test('keyAgg + sign -> aggregate -> verify', () {
      final bu = openBu();
      final m = bu.musig2;
      final k1 =
          bu.secp256k1Signing
              .publicKey(BuBytes(List<int>.filled(32, 1)))
              .unwrapOrThrow();
      final k2 =
          bu.secp256k1Signing
              .publicKey(BuBytes(List<int>.filled(32, 2)))
              .unwrapOrThrow();
      final agg = m.keyAgg([k1, k2]).unwrapOrThrow();
      expect(agg, hasLength(33));
      expect(m.isValidPublicKey(agg.toList()), isTrue);

      final msg = BuBytes(List<int>.generate(32, (i) => i));
      // Explicit per-signer randomness (deterministic fixtures, no RNG).
      final n1 =
          m
              .nonceGenerate(
                publicKey: k1,
                rand: BuBytes(List<int>.filled(32, 0xA1)),
                msg: msg,
              )
              .unwrapOrThrow();
      final n2 =
          m
              .nonceGenerate(
                publicKey: k2,
                rand: BuBytes(List<int>.filled(32, 0xA2)),
                msg: msg,
              )
              .unwrapOrThrow();
      final aggNonce = m.nonceAgg([n1.pubnonce, n2.pubnonce]).unwrapOrThrow();
      expect(aggNonce, hasLength(66));

      final p1 =
          m
              .partialSign(
                secnonce: n1.secnonce,
                sk: BuBytes(List<int>.filled(32, 1)),
                publicKeys: [k1, k2],
                aggnonce: aggNonce,
                msg: msg,
              )
              .unwrapOrThrow();
      final p2 =
          m
              .partialSign(
                secnonce: n2.secnonce,
                sk: BuBytes(List<int>.filled(32, 2)),
                publicKeys: [k1, k2],
                aggnonce: aggNonce,
                msg: msg,
              )
              .unwrapOrThrow();
      expect(
        m
            .partialSigVerify(
              partial: p1,
              pubnonce: n1.pubnonce,
              pk: k1,
              publicKeys: [k1, k2],
              aggnonce: aggNonce,
              msg: msg,
            )
            .unwrapOrThrow(),
        isTrue,
      );
      final aggSig =
          m
              .partialSigAgg(
                partials: [p1, p2],
                publicKeys: [k1, k2],
                aggnonce: aggNonce,
                msg: msg,
              )
              .unwrapOrThrow();
      expect(aggSig, hasLength(64));
      final xonly = agg.sublist(1);
      expect(
        m
            .verifyAggregate(
              message: msg,
              signature64: aggSig,
              aggXOnly32: xonly,
            )
            .unwrapOrThrow(),
        isTrue,
      );
      expect(
        m
            .verifyAggregate(
              message: BuBytes(List<int>.generate(32, (i) => i + 1)),
              signature64: aggSig,
              aggXOnly32: xonly,
            )
            .unwrapOrThrow(),
        isFalse,
      );
    });

    test('deterministicSign verifies under aggregate key', () {
      final bu = openBu();
      final m = bu.musig2;
      final k1 =
          bu.secp256k1Signing
              .publicKey(BuBytes(List<int>.filled(32, 1)))
              .unwrapOrThrow();
      final k2 =
          bu.secp256k1Signing
              .publicKey(BuBytes(List<int>.filled(32, 2)))
              .unwrapOrThrow();
      final agg = m.keyAgg([k1, k2]).unwrapOrThrow();
      final msg = BuBytes(List<int>.filled(32, 0xAA));
      // Second signer contributes a fixed other-nonce (deterministic path).
      final other =
          m
              .nonceGenerate(
                publicKey: k2,
                rand: BuBytes(List<int>.filled(32, 0xB2)),
                msg: msg,
              )
              .unwrapOrThrow();
      final det =
          m
              .deterministicSign(
                sk: BuBytes(List<int>.filled(32, 1)),
                aggotherNonce66: other.pubnonce,
                publicKeys: [k1, k2],
                msg: msg,
              )
              .unwrapOrThrow();
      final aggNonce =
          m.nonceAgg([det.pubnonce, other.pubnonce]).unwrapOrThrow();
      final p1 = det.partial;
      final p2 =
          m
              .partialSign(
                secnonce: other.secnonce,
                sk: BuBytes(List<int>.filled(32, 2)),
                publicKeys: [k1, k2],
                aggnonce: aggNonce,
                msg: msg,
              )
              .unwrapOrThrow();
      final aggSig =
          m
              .partialSigAgg(
                partials: [p1, p2],
                publicKeys: [k1, k2],
                aggnonce: aggNonce,
                msg: msg,
              )
              .unwrapOrThrow();
      expect(
        m
            .verifyAggregate(
              message: msg,
              signature64: aggSig,
              aggXOnly32: agg.sublist(1),
            )
            .unwrapOrThrow(),
        isTrue,
      );
    });
  });
}

/// Standalone entry: `dart test test/backend/musig2_test.dart` (VM, FFI backend).
void main() async {
  await ConnectorTestApi.ensureBackend();
  runMusig2Suite(() => ConnectorTestApi.bu);
}
