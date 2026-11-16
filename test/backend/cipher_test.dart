import 'package:blockchain_utils_connector/blockchain_utils_connector.dart';
import 'package:test/test.dart';

import '../test_utils.dart';

/// Block/stream ciphers: roundtrips, padding, and misuse paths.
///
/// Runs on FFI and WASM. All keys/ivs are inline literals — no files.
void runCipherSuite(Bu Function() openBu) {
  group('block cipher', () {
    test('aes ecb block invertibility (128/192/256)', () {
      final bu = openBu();
      for (final klen in [16, 24, 32]) {
        final c =
            bu.blockCipher
                .aes(List<int>.generate(klen, (i) => i))
                .unwrapOrThrow();
        try {
          expect(c.blockSize, 16);
          final pt = List<int>.generate(16, (i) => i * 7);
          final ct = c.encryptBlock(pt);
          expect(ct, isNot(pt));
          expect(c.decryptBlock(ct.toList()), pt);
        } finally {
          c.clean();
        }
      }
    });

    test('aes-cbc roundtrip incl. empty + use-after-clean', () {
      final bu = openBu();
      final c =
          bu.blockCipher
              .aesCbc(List<int>.generate(16, (i) => i), List<int>.filled(16, 9))
              .unwrapOrThrow();
      try {
        for (final len in [0, 16, 48]) {
          final pt = List<int>.generate(len, (i) => i);
          final ct = c.encrypt(pt);
          expect(ct.length, len);
          expect(c.decrypt(ct.toList()), pt);
        }
      } finally {
        c.clean();
      }
      expect(() => c.encrypt([1]), throwsA(isA<BuError>()));
    });

    test('aes-ecb pkcs7 pad/unpad incl. block-aligned', () {
      final bu = openBu();
      final ecb =
          bu.blockCipher
              .aesEcb(List<int>.generate(16, (i) => i))
              .unwrapOrThrow();
      try {
        // Empty -> one full padding block.
        final ct0 = ecb.encrypt([]);
        expect(ct0.length, 16);
        expect(ecb.decrypt(ct0.toList()), isEmpty);
        // 16 bytes -> extra padding block.
        final pt16 = List<int>.generate(16, (i) => i + 1);
        final ct16 = ecb.encrypt(pt16);
        expect(ct16.length, 32);
        expect(ecb.decrypt(ct16.toList()), pt16);
        expect(ecb.decrypt([1, 2, 3]), isNull);
      } finally {
        ecb.clean();
      }
    });

    test('aes-ctr process is its own inverse', () {
      final bu = openBu();
      final ctr =
          bu.blockCipher
              .aesCtr(List<int>.generate(32, (i) => i), List<int>.filled(16, 4))
              .unwrapOrThrow();
      try {
        final pt = List<int>.generate(100, (i) => i);
        final out = BuBytes.zero(100);
        ctr.process(pt, out);
        expect(out.toList(), isNot(pt));
        final back = BuBytes.zero(100);
        // Fresh keystream position? CTR state advances, so decrypt with a
        // fresh instance over the same counter start.
        final ctr2 =
            bu.blockCipher
                .aesCtr(
                  List<int>.generate(32, (i) => i),
                  List<int>.filled(16, 4),
                )
                .unwrapOrThrow();
        try {
          ctr2.process(out, back);
          expect(back.toList(), pt);
        } finally {
          ctr2.clean();
        }
      } finally {
        ctr.clean();
      }
    });

    test('keccak-f1600 permutation sanity (in-place, avalanche)', () {
      final bu = openBu();
      final s = BuBytes.zero(200);
      bu.hash.keccakF1600(s).unwrapOrThrow();
      expect(s.any((b) => b != 0), isTrue);
      final s2 = BuBytes.zero(200)..[199] = 1;
      bu.hash.keccakF1600(s2).unwrapOrThrow();
      var diff = 0;
      for (var i = 0; i < 200; i++) {
        if (s[i] != s2[i]) diff++;
      }
      expect(diff, greaterThan(50));
    });
  });

  group('stream cipher', () {
    test('chacha20 invertibility + seek domain separation', () {
      final bu = openBu();
      BuBytes run(List<int> key, List<int> nonce, int seek, List<int> pt) {
        final c = bu.streamCipher.chacha20(key).unwrapOrThrow();
        try {
          return c.process(pt, nonce: nonce, seekBytes: seek);
        } finally {
          c.clean();
        }
      }

      final key = List<int>.generate(32, (i) => i + 3);
      final nonce = List<int>.filled(12, 8);
      const pt = [10, 20, 30, 40, 50];
      final ct = run(key, nonce, 0, pt);
      expect(ct.toList(), isNot(pt));
      // Decrypt = encrypt with same seek.
      expect(run(key, nonce, 0, ct.toList()).toList(), pt);
      // Different seek (next block) -> different keystream.
      expect(run(key, nonce, 64, pt).toList(), isNot(ct.toList()));
    });
  });
}

/// Standalone entry: `dart test test/backend/cipher_test.dart` (VM, FFI backend).
void main() async {
  await ConnectorTestApi.ensureBackend();
  runCipherSuite(() => ConnectorTestApi.bu);
}
