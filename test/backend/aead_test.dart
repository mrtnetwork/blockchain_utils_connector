import 'package:blockchain_utils_connector/blockchain_utils_connector.dart';
import 'package:test/test.dart';

import '../test_utils.dart';

/// AEAD: roundtrips, tamper-fails-closed, AAD binding, and misuse paths.
///
/// Runs on FFI and WASM. All keys/nonces are inline literals — no files.
void runAeadSuite(Bu Function() openBu) {
  group('aead roundtrips', () {
    test('chacha20poly1305 encrypt/decrypt + tamper + aad', () {
      final bu = openBu();
      final aead =
          bu.aead.chacha20Poly1305(List<int>.filled(32, 1)).unwrapOrThrow();
      try {
        const nonce = [2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2];
        const pt = [104, 105];
        final ct = aead.encrypt(nonce, pt);
        expect(ct.length, pt.length + 16);
        expect(aead.decrypt(nonce, ct.toList()), pt);
        // Bit-flip fails closed (null, not garbage).
        final bad = ct.toList()..[0] ^= 1;
        expect(aead.decrypt(nonce, bad), isNull);
        // AAD binds: decrypt with different AAD fails.
        final ctAad = aead.encrypt(nonce, pt, associatedData: [7, 7]);
        expect(aead.decrypt(nonce, ctAad.toList(), associatedData: [7, 7]), pt);
        expect(
          aead.decrypt(nonce, ctAad.toList(), associatedData: [7, 8]),
          isNull,
        );
      } finally {
        aead.clean();
      }
    });

    test('aes-gcm 128/192/256 roundtrip + tamper', () {
      final bu = openBu();
      for (final klen in [16, 24, 32]) {
        final aead =
            bu.aead
                .aesGcm(List<int>.generate(klen, (i) => i + 1))
                .unwrapOrThrow();
        try {
          final nonce = List<int>.generate(12, (i) => i);
          final pt = List<int>.generate(48, (i) => i * 3);
          final ct = aead.encrypt(nonce, pt);
          expect(aead.decrypt(nonce, ct.toList()), pt);
          final bad = ct.toList()..[20] ^= 0x40;
          expect(aead.decrypt(nonce, bad), isNull);
        } finally {
          aead.clean();
        }
      }
    });

    test('xsalsa20poly1305 roundtrip + nonce strictness', () {
      final bu = openBu();
      final aead =
          bu.aead.xsalsa20Poly1305(List<int>.filled(32, 9)).unwrapOrThrow();
      try {
        final nonce = List<int>.filled(24, 3);
        final pt = [1, 2, 3, 4, 5];
        final sealed = aead.encrypt(nonce, pt);
        // Wire order TAG || CIPHERTEXT.
        expect(sealed.length, pt.length + 16);
        expect(aead.decrypt(nonce, sealed.toList()), pt);
        expect(
          () => aead.encrypt(List<int>.filled(12, 0), pt),
          throwsA(isA<BuError>()),
        );
      } finally {
        aead.clean();
      }
    });

    test('salsabox beforenm + seal/open + tamper', () {
      final bu = openBu();
      final aliceSk = List<int>.filled(32, 0xA)..[31] = 0x01;
      final bobSk = List<int>.filled(32, 0xB)..[31] = 0x02;
      // Deterministic keypairs from fixed secrets via x25519 base multiply.
      final alicePk = bu.x25519.publicKey(aliceSk).unwrapOrThrow();
      final bobPk = bu.x25519.publicKey(bobSk).unwrapOrThrow();
      final k1 =
          bu.aead
              .salsaBoxBeforenm(peerPublicKey: bobPk, secretKey: aliceSk)
              .unwrapOrThrow();
      final k2 =
          bu.aead
              .salsaBoxBeforenm(peerPublicKey: alicePk, secretKey: bobSk)
              .unwrapOrThrow();
      expect(k1, k2);
      final nonce = List<int>.filled(24, 5);
      final sealed =
          bu.aead
              .salsaBoxEncrypt(
                peerPublicKey: bobPk,
                secretKey: aliceSk,
                nonce: nonce,
                plaintext: [9, 8, 7],
              )
              .unwrapOrThrow();
      expect(
        bu.aead
            .salsaBoxDecrypt(
              peerPublicKey: alicePk,
              secretKey: bobSk,
              nonce: nonce,
              sealed: sealed,
            )
            .unwrapOrThrow(),
        [9, 8, 7],
      );
      final bad = sealed.toList()..[0] ^= 1;
      expect(
        bu.aead
            .salsaBoxDecrypt(
              peerPublicKey: alicePk,
              secretKey: bobSk,
              nonce: nonce,
              sealed: bad,
            )
            .unwrapOrThrow(),
        isNull,
      );
    });

    test('aead rejects bad key lengths', () {
      final bu = openBu();
      expect(bu.aead.chacha20Poly1305(List<int>.filled(16, 1)).isErr, isTrue);
      expect(bu.aead.xsalsa20Poly1305(List<int>.filled(16, 1)).isErr, isTrue);
    });
  });
}

/// Standalone entry: `dart test test/backend/aead_test.dart` (VM, FFI backend).
void main() async {
  await ConnectorTestApi.ensureBackend();
  runAeadSuite(() => ConnectorTestApi.bu);
}
