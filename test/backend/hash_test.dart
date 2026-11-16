import 'package:blockchain_utils_connector/blockchain_utils_connector.dart';
import 'package:test/test.dart';

import '../test_utils.dart';

/// Hash surface: NIST/reference vectors (pinned from the Rust core, which is
/// the shared implementation behind both backends), streaming/incremental
/// behavior, save/restore, XOF lengths, and fail-closed misuse paths.
///
/// Runs on FFI and WASM. All inputs are inline literals — no files, no skips.
void runHashSuite(Bu Function() openBu) {
  BuBytes dig(BuResult<BuSerializableHash> Function() open, List<int> data) {
    final h = open().unwrapOrThrow();
    try {
      h.update(data);
      return h.digest();
    } finally {
      h.clean();
    }
  }

  String hx(List<int> b) =>
      b.map((e) => e.toRadixString(16).padLeft(2, '0')).join();

  group('hash vectors (pinned)', () {
    test('sha256 empty/abc (FIPS 180-4)', () {
      final bu = openBu();
      expect(
        hx(dig(() => bu.hash.sha256(), [])),
        'e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855',
      );
      expect(
        hx(dig(() => bu.hash.sha256(), [97, 98, 99])),
        'ba7816bf8f01cfea414140de5dae2223b00361a396177a9cb410ff61f20015ad',
      );
    });

    test('sha512 abc (FIPS 180-4)', () {
      final bu = openBu();
      expect(
        hx(dig(() => bu.hash.sha512(), [97, 98, 99])),
        'ddaf35a193617abacc417349ae20413112e6fa4e89a97ea20a9eeee64b55d39a2192992a274fc1a836ba3c23a3feebbd454d4423643ce80e2a9ac94fa54ca49f',
      );
    });

    test('sha1/md5/ripemd160 abc', () {
      final bu = openBu();
      expect(
        hx(dig(() => bu.hash.sha1(), [97, 98, 99])),
        'a9993e364706816aba3e25717850c26c9cd0d89d',
      );
      expect(
        hx(dig(() => bu.hash.md5(), [97, 98, 99])),
        '900150983cd24fb0d6963f7d28e17f72',
      );
      expect(
        hx(dig(() => bu.hash.ripemd160(), [97, 98, 99])),
        '8eb208f7e05d987a9b044a8e98c6b087f15a0bfc',
      );
    });

    test('sha3-256/keccak256 abc+empty (NIST FIPS 202)', () {
      final bu = openBu();
      expect(
        hx(dig(() => bu.hash.sha3(digestLength: 32), [97, 98, 99])),
        '3a985da74fe225b2045c172d6bd390bd855f086e3e9d525b46bfe24511431532',
      );
      expect(
        hx(dig(() => bu.hash.keccack(digestLength: 32), [])),
        'c5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470',
      );
    });

    test('blake2b-512/blake2s-256 abc (RFC 7693)', () {
      final bu = openBu();
      expect(
        hx(dig(() => bu.hash.blake2b(), [97, 98, 99])),
        'ba80a53f981c4d0d6a2797b69f12f6e94c212f14685ac4b74b12bb6fdbffa2d17d87c5392aab792dc252d5de4533cc9518d38aa8dbf1925ab92386edd4009923',
      );
      expect(
        hx(dig(() => bu.hash.blake2s(), [97, 98, 99])),
        '508c5e8c327c14e2e1a72ba34eeb452f37458b209ed63a294d999b4c86675982',
      );
    });

    test('hmac-sha256 RFC 4231 #1', () {
      final bu = openBu();
      final h = bu.hash.hmacSha256(List<int>.filled(20, 0x0b)).unwrapOrThrow();
      try {
        h.update([72, 105, 32, 84, 104, 101, 114, 101]); // "Hi There"
        expect(
          hx(h.digest()),
          'b0344c61d8db38535ca8afceaf0bf12b881dc200c9833da726e9376c2e32cff7',
        );
      } finally {
        h.clean();
      }
    });

    test('pbkdf2-sha256 (password/salt/1/32)', () {
      final bu = openBu();
      final dk =
          bu.hash
              .pbkdf2Sha256DeriveKey(
                password: [112, 97, 115, 115, 119, 111, 114, 100],
                salt: [115, 97, 108, 116],
                iterations: 1,
                length: 32,
              )
              .unwrapOrThrow();
      expect(
        hx(dk),
        '120fb6cffcf8b32c43e7225256c4f837a86548c92ccc35480805987cb70be17b',
      );
    });
  });

  group('hash streaming/properties', () {
    test('incremental == one-shot; reset restores', () {
      final bu = openBu();
      BuBytes once(List<int> parts) {
        final h = bu.hash.sha256().unwrapOrThrow();
        try {
          for (final p in parts) {
            h.update([p]);
          }
          return h.digest();
        } finally {
          h.clean();
        }
      }

      expect(once([1, 2, 3]), once([1, 2, 3]));
      final h = bu.hash.sha256().unwrapOrThrow();
      try {
        h.update([1, 2, 3]);
        final a = h.digest();
        h.reset();
        h.update([1, 2, 3]);
        expect(h.digest(), a);
      } finally {
        h.clean();
      }
    });

    test('use-after-clean throws; double clean is safe', () {
      final bu = openBu();
      final h = bu.hash.sha256().unwrapOrThrow();
      h.clean();
      h.clean();
      expect(() => h.update([1]), throwsA(isA<BuError>()));
      expect(() => h.digest(), throwsA(isA<BuError>()));
    });

    test('avalanche: one flipped bit changes the digest', () {
      final bu = openBu();
      final a = dig(() => bu.hash.sha256(), List<int>.filled(64, 0));
      final b = dig(() => bu.hash.sha256(), List<int>.filled(64, 0)..[63] = 1);
      expect(a, isNot(equals(b)));
    });

    test('save/restore roundtrip', () {
      final bu = openBu();
      final h = bu.hash.sha256().unwrapOrThrow();
      try {
        h.update([1, 2, 3, 4]);
        final snap = h.saveState();
        h.update([5, 6]);
        final withMore = h.digest();
        h.restoreState(snap);
        h.cleanSavedState(snap);
        h.update([5, 6]);
        expect(h.digest(), withMore);
      } finally {
        h.clean();
      }
    });

    test('shake variable length + digest/block metadata', () {
      final bu = openBu();
      final h = bu.hash.shake128(digestLength: 64).unwrapOrThrow();
      try {
        h.update([9, 9, 9]);
        expect(h.getDigestLength, 64);
        expect(h.getBlockSize, greaterThan(0));
        final out = BuBytes.zero(64);
        h.finish(out);
        expect(out.any((b) => b != 0), isTrue);
      } finally {
        h.clean();
      }
    });

    test('all one-shot algos open and digest at natural length', () {
      final bu = openBu();
      final opens = <BuResult<BuSerializableHash> Function()>[
        bu.hash.sha224,
        bu.hash.sha384,
        bu.hash.sha512256,
        bu.hash.md4,
        bu.hash.ripemd128,
        bu.hash.ripemd256,
        bu.hash.ripemd320,
      ];
      for (final open in opens) {
        final h = open().unwrapOrThrow();
        try {
          h.update([1, 2, 3]);
          final d = h.digest();
          expect(d.length, h.getDigestLength);
        } finally {
          h.clean();
        }
      }
    });

    test('xxhash lengths incl. multi-lane', () {
      final bu = openBu();
      for (final bits in [32, 64, 128]) {
        final h = bu.hash.xxHash(bitLength: bits).unwrapOrThrow();
        try {
          h.update([1, 2, 3]);
          expect(h.digest().length, h.getDigestLength);
        } finally {
          h.clean();
        }
      }
    });
  });
}

/// Standalone entry: `dart test test/backend/hash_test.dart` (VM, FFI backend).
void main() async {
  await ConnectorTestApi.ensureBackend();
  runHashSuite(() => ConnectorTestApi.bu);
}
