import 'package:blockchain_utils_connector/blockchain_utils_connector.dart';
import 'package:test/test.dart';

import '../test_utils.dart';

/// Signatures: ecdsa (k1/r1), schnorr/bip340, ed25519, sr25519, reddsa.
///
/// Roundtrips with fixed keys, tamper-fails-closed, recover, and misuse
/// paths. All keys/messages are inline literals — no files, no skips.
void runSigningSuite(Bu Function() openBu) {
  BuBytes bz(List<int> b) => BuBytes(b);
  final sk1 = BuBytes(List<int>.filled(31, 0) + [1]);
  final msg32 = BuBytes(List<int>.generate(32, (i) => i + 1));

  group('ecdsa secp256k1', () {
    test('sign/verify with digest + recover + tamper-fail', () {
      final bu = openBu();
      final s = bu.secp256k1Signing;
      final pk = s.publicKey(sk1).unwrapOrThrow();
      final sig =
          s
              .signEcdsa(sk1, BuSecp256k1SignParams(digest: msg32))
              .unwrapOrThrow();
      expect(
        s.verifyEcdsa(pk: pk, digest: msg32, signature: sig).unwrapOrThrow(),
        isTrue,
      );
      final bad = BuEcdsaSignature(
        r: sig.r,
        s: BuBytes(List<int>.filled(32, 0xFF)),
        recoveryId: sig.recoveryId,
      );
      expect(
        s.verifyEcdsa(pk: pk, digest: msg32, signature: bad).unwrapOrThrow(),
        isFalse,
      );
      final rec = s.recoverEcdsa(digest: msg32, signature: sig).unwrapOrThrow();
      expect(rec, pk);
    });

    test('bip340 sign/verify + tamper', () {
      final bu = openBu();
      final s = bu.secp256k1Signing;
      final xonly = s.xOnlyPublicKey(sk1).unwrapOrThrow();
      expect(xonly, hasLength(32));
      final sig =
          s
              .signBip340(sk1, BuSecp256k1Bip340Params(digest: msg32))
              .unwrapOrThrow();
      expect(
        s
            .verifyBip340(
              xOnlyPk: xonly,
              messageOrDigest: msg32,
              signature: sig,
            )
            .unwrapOrThrow(),
        isTrue,
      );
      final bad = BuEcdsaSignature(
        r: sig.r,
        s: sig.s,
        recoveryId: sig.recoveryId,
      );
      bad.s[0] ^= 1;
      expect(
        s
            .verifyBip340(
              xOnlyPk: xonly,
              messageOrDigest: msg32,
              signature: bad,
            )
            .unwrapOrThrow(),
        isFalse,
      );
    });

    test('schnorr aux + taproot tweak via bindings', () {
      final bu = openBu();
      final out = BuBytes.zero(64);
      // Explicit aux, no tweak.
      expect(
        bu.bindings.schnorrSignAux(
          sk1,
          msg32,
          BuBytes(List<int>.filled(32, 0xA0)),
          null,
          out,
        ),
        0,
      );
      expect(out.any((b) => b != 0), isTrue);
      // Same aux + tweak must differ.
      final outT = BuBytes.zero(64);
      expect(
        bu.bindings.schnorrSignAux(
          sk1,
          msg32,
          BuBytes(List<int>.filled(32, 0xA0)),
          BuBytes(List<int>.filled(32, 0x0B)),
          outT,
        ),
        0,
      );
      expect(outT.toList(), isNot(out.toList()));
      // Bad lengths rejected.
      expect(
        bu.bindings.schnorrSignAux(
          BuBytes([1]),
          msg32,
          null,
          null,
          BuBytes.zero(64),
        ),
        isNot(0),
      );
    });
  });

  group('ecdsa secp256r1', () {
    test('sign/verify roundtrip + tamper', () {
      final bu = openBu();
      final s = bu.secp256r1Signing;
      final sk = BuBytes(List<int>.filled(31, 0) + [2]);
      final pk = s.publicKey(sk).unwrapOrThrow();
      expect(pk, hasLength(33));
      final sig =
          s.signEcdsa(sk, BuSecp256r1SignParams(digest: msg32)).unwrapOrThrow();
      expect(
        s.verifyEcdsa(pk: pk, digest: msg32, signature: sig).unwrapOrThrow(),
        isTrue,
      );
      expect(
        s
            .verifyEcdsa(
              pk: pk,
              digest: BuBytes(List<int>.filled(32, 9)),
              signature: sig,
            )
            .unwrapOrThrow(),
        isFalse,
      );
    });
  });

  group('ed25519', () {
    test('pinned pubkey + sign/verify + tamper', () {
      final bu = openBu();
      final s = bu.ed25519Signing;
      final seed = BuBytes(List<int>.filled(32, 1));
      final pk = s.publicKey(seed).unwrapOrThrow();
      expect(
        pk.map((e) => e.toRadixString(16).padLeft(2, '0')).join(),
        '8a88e3dd7409f195fd52db2d3cba5d72ca6709bf1d94121bf3748801b40f6f5c',
      );
      final sig =
          s.sign(secret: seed, message: bz([10, 20, 30])).unwrapOrThrow();
      expect(
        s
            .verify(publicKey: pk, message: bz([10, 20, 30]), signature: sig)
            .unwrapOrThrow(),
        isTrue,
      );
      expect(
        s
            .verify(publicKey: pk, message: bz([10, 20, 31]), signature: sig)
            .unwrapOrThrow(),
        isFalse,
      );
    });
  });

  group('ed25519 variants (blake2b/kholaw/monero)', () {
    test('pinned pubkeys + sign/verify + cross-domain rejection', () {
      final bu = openBu();
      final s = bu.ed25519Signing;
      const msg = [10, 20, 30];
      // Pinned oracles generated from the Rust core (shared by both backends).
      final vectors = <BuEd25519Variant, (List<int>, String)>{
        BuEd25519Variant.ed25519Blake2b: (
          List<int>.filled(32, 1),
          '7745ba4c261a2702472fdc87b4ebf61184abb2685727ca3b2d33ab3cff260e49',
        ),
        BuEd25519Variant.ed25519Kholaw: (
          List<int>.generate(64, (i) => i + 1),
          'ce92350b547b6cf028df0618bf9aba55f949930059308d83ebd727e13472ed99',
        ),
        BuEd25519Variant.ed25519Monero: (
          List<int>.generate(64, (i) => i + 1),
          'ce92350b547b6cf028df0618bf9aba55f949930059308d83ebd727e13472ed99',
        ),
      };
      String hx(List<int> b) =>
          b.map((e) => e.toRadixString(16).padLeft(2, '0')).join();
      for (final entry in vectors.entries) {
        final variant = entry.key;
        final sk = BuBytes(entry.value.$1);
        final pk = s.publicKey(sk, variant: variant).unwrapOrThrow();
        expect(hx(pk), entry.value.$2);
        final sig =
            s
                .sign(secret: sk, message: BuBytes(msg), variant: variant)
                .unwrapOrThrow();
        expect(
          s
              .verify(
                publicKey: pk,
                message: BuBytes(msg),
                signature: sig,
                variant: variant,
              )
              .unwrapOrThrow(),
          isTrue,
        );
        // Wrong message fails.
        expect(
          s
              .verify(
                publicKey: pk,
                message: BuBytes([10, 20, 31]),
                signature: sig,
                variant: variant,
              )
              .unwrapOrThrow(),
          isFalse,
        );
      }
      // Hash-domain separation: the same key/signature pair verifies
      // under its own variant but not under plain Ed25519 (different k).
      final seed = BuBytes(List<int>.filled(32, 1));
      final blakePk =
          s
              .publicKey(seed, variant: BuEd25519Variant.ed25519Blake2b)
              .unwrapOrThrow();
      final blakeSig =
          s
              .sign(
                secret: seed,
                message: BuBytes(msg),
                variant: BuEd25519Variant.ed25519Blake2b,
              )
              .unwrapOrThrow();
      expect(
        s
            .verify(
              publicKey: blakePk,
              message: BuBytes(msg),
              signature: blakeSig,
              variant: BuEd25519Variant.ed25519,
            )
            .unwrapOrThrow(),
        isFalse,
      );
      // Bad variant secret lengths are rejected.
      expect(
        s
            .publicKey(
              BuBytes([1, 2]),
              variant: BuEd25519Variant.ed25519Blake2b,
            )
            .isErr,
        isTrue,
      );
      expect(
        s
            .publicKey(
              BuBytes(List<int>.filled(32, 1)),
              variant: BuEd25519Variant.ed25519Kholaw,
            )
            .isErr,
        isTrue,
      );
    });
  });

  group('sr25519', () {
    test('seed -> pk -> sign/verify + tamper', () {
      final bu = openBu();
      final s = bu.sr25519;
      final seed = List<int>.filled(32, 3);
      final pk = s.publicKeyFromSeed(seed).unwrapOrThrow();
      expect(pk, hasLength(32));
      expect(s.isValidPublicKey(pk.toList()), isTrue);
      final sig =
          s
              .sign(
                seedOrSk: seed,
                message: [5, 6, 7],
                nonce64: List<int>.filled(64, 8),
              )
              .unwrapOrThrow();
      expect(
        s
            .verify(
              publicKey: pk.toList(),
              message: [5, 6, 7],
              signature: sig.toList(),
            )
            .unwrapOrThrow(),
        isTrue,
      );
      expect(
        s
            .verify(
              publicKey: pk.toList(),
              message: [5, 6, 8],
              signature: sig.toList(),
            )
            .unwrapOrThrow(),
        isFalse,
      );
    });
  });

  group('reddsa jubjub', () {
    test('keygen/sign/verify + tamper', () {
      final bu = openBu();
      final r = bu.reddsa;
      final sk = BuBytes(List<int>.filled(32, 4));
      final pk =
          r
              .publicKey(domain: BuReddsaDomain.jubjubAuth, sk: sk)
              .unwrapOrThrow();
      expect(pk, hasLength(32));
      final sig =
          r
              .sign(
                domain: BuReddsaDomain.jubjubAuth,
                sk: sk,
                message: bz([1, 1, 1]),
              )
              .unwrapOrThrow();
      expect(sig, hasLength(64));
      expect(
        r
            .verify(
              domain: BuReddsaDomain.jubjubAuth,
              pk: pk,
              message: bz([1, 1, 1]),
              signature: sig,
            )
            .unwrapOrThrow(),
        isTrue,
      );
      expect(
        r
            .verify(
              domain: BuReddsaDomain.jubjubAuth,
              pk: pk,
              message: bz([1, 1, 2]),
              signature: sig,
            )
            .unwrapOrThrow(),
        isFalse,
      );
    });
  });
}

/// Standalone entry: `dart test test/backend/signing_test.dart` (VM, FFI backend).
void main() async {
  await ConnectorTestApi.ensureBackend();
  runSigningSuite(() => ConnectorTestApi.bu);
}
