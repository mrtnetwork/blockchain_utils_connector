import 'package:blockchain_utils_connector/blockchain_utils_connector.dart';
import 'package:test/test.dart';

import '../test_utils.dart';

/// Solana confidential-transfer ZK roundtrips. Runs on FFI and WASM: all vectors are inline
/// hex/data in this file, opened through [openBu].
void runSolanaZkSuite(Bu Function() openBu) {
  BuSolanaZkApi api() => openBu().solanaZk;

  List<int> seed(int fill) => List<int>.filled(32, fill);

  test('elgamal + sigma + range + withdraw roundtrip', () {
    final a = api();

    // Keygen / encrypt / decrypt.
    final secret = List<int>.filled(32, 7);
    final pubkey = a.pubkeyFromSecret(secret).unwrapOrThrow();
    expect(pubkey, hasLength(32));
    final ct =
        a
            .encryptWith(
              pubkey: pubkey.toList(),
              amount: 12345,
              opening: List<int>.filled(32, 3),
            )
            .unwrapOrThrow();
    expect(ct, hasLength(64));
    expect(
      a.decryptU32(secret: secret, ciphertext: ct.toList()).unwrapOrThrow(),
      12345,
    );

    // Pubkey-validity prove/verify.
    final pv =
        a.provePubkeyValidity(secret: secret, seed32: seed(5)).unwrapOrThrow();
    expect(pv, hasLength(64));
    expect(
      a
          .verifyPubkeyValidity(pubkey: pubkey.toList(), proof: pv.toList())
          .unwrapOrThrow(),
      isTrue,
    );

    // Withdraw bundle (1256 bytes) + component verification.
    final cur =
        a
            .encryptWith(
              pubkey: pubkey.toList(),
              amount: 100,
              opening: List<int>.filled(32, 9),
            )
            .unwrapOrThrow();
    final w =
        a
            .proveWithdraw(
              sourceSecret: secret,
              sourcePubkey: pubkey.toList(),
              currentCiphertext: cur.toList(),
              currentBalance: 100,
              withdrawAmount: 45,
              seed32: seed(11),
            )
            .unwrapOrThrow();
    expect(w, hasLength(1256));
    final wEq = w.sublist(0, 192).toList();
    final wRange = w.sublist(192, 192 + 672).toList();
    final wRemComm = w.sublist(192 + 672 + 264, 192 + 672 + 264 + 32).toList();
    final wRemCt =
        w.sublist(192 + 672 + 264 + 64, 192 + 672 + 264 + 64 + 64).toList();
    expect(
      a
          .verifyEquality(
            pubkey: pubkey.toList(),
            ciphertext: wRemCt,
            commitment: wRemComm,
            proof: wEq,
          )
          .unwrapOrThrow(),
      isTrue,
    );
    expect(
      a
          .verifyBatchedRange(proof: wRange, commitments: wRemComm, n: 1)
          .unwrapOrThrow(),
      isTrue,
    );
  });

  test('transfer bundle roundtrip', () {
    final a = api();
    final s = List<int>.filled(32, 2);
    final ps = a.pubkeyFromSecret(s).unwrapOrThrow();
    final pd = a.pubkeyFromSecret(List<int>.filled(32, 4)).unwrapOrThrow();
    final pa = List<int>.filled(32, 0);
    final cur =
        a
            .encryptWith(
              pubkey: ps.toList(),
              amount: 1000,
              opening: List<int>.filled(32, 3),
            )
            .unwrapOrThrow();
    final t =
        a
            .proveTransfer(
              sourceSecret: s,
              sourcePubkey: ps.toList(),
              destPubkey: pd.toList(),
              auditorPubkey: pa,
              currentCiphertext: cur.toList(),
              currentBalance: 1000,
              transferAmount: 55,
              seed32: seed(13),
            )
            .unwrapOrThrow();
    expect(t, hasLength(1896));
    // Validity proof at offset 192, 192 bytes; grouped lo/hi after
    // equality + validity + range + pod context.
    const off = 192 + 192 + 736 + 264;
    final tVal = t.sublist(192, 384).toList();
    final glo = t.sublist(off, off + 128).toList();
    final ghi = t.sublist(off + 128, off + 256).toList();
    expect(
      a
          .verifyBatchedGroupedValidity3(
            firstPubkey: ps.toList(),
            secondPubkey: pd.toList(),
            thirdPubkey: pa,
            groupedLo128: glo,
            groupedHi128: ghi,
            proof: tVal,
          )
          .unwrapOrThrow(),
      isTrue,
    );
  });

  test('transfer-with-fee bundle roundtrip', () {
    final a = api();
    final s = List<int>.filled(32, 2);
    final ps = a.pubkeyFromSecret(s).unwrapOrThrow();
    final pd = a.pubkeyFromSecret(List<int>.filled(32, 4)).unwrapOrThrow();
    final pa = a.pubkeyFromSecret(List<int>.filled(32, 6)).unwrapOrThrow();
    final cur =
        a
            .encryptWith(
              pubkey: ps.toList(),
              amount: 10000,
              opening: List<int>.filled(32, 3),
            )
            .unwrapOrThrow();
    final f =
        a
            .proveTransferWithFee(
              sourceSecret: s,
              sourcePubkey: ps.toList(),
              destPubkey: pd.toList(),
              auditorPubkey: pa.toList(),
              authorityPubkey: pa.toList(),
              currentCiphertext: cur.toList(),
              currentBalance: 10000,
              transferAmount: 1000,
              feeRateBasisPoints: 400,
              maximumFee: 50,
              seed32: seed(13),
            )
            .unwrapOrThrow();
    expect(f, hasLength(2576));
    // Percentage proof at 192+192 = 384, 256 bytes.
    final pct = f.sublist(384, 384 + 256).toList();
    // fee/delta/claimed commitments after range pod context:
    // 192+192+256+160+800+264 = 1864; +128+128+96+96 = 2248.
    const co = 1864 + 128 + 128 + 96 + 96 + 32 + 32 + 64;
    final feeComm = f.sublist(co, co + 32).toList();
    final deltaComm = f.sublist(co + 32, co + 64).toList();
    final claimedComm = f.sublist(co + 64, co + 96).toList();
    expect(
      a
          .verifyPercentageWithCap(
            percentageCommitment: feeComm,
            deltaCommitment: deltaComm,
            claimedCommitment: claimedComm,
            maxValue: 50,
            proof: pct,
          )
          .unwrapOrThrow(),
      isTrue,
    );
  });

  test('AES-GCM-SIV roundtrip', () {
    final a = api();
    final key = List<int>.generate(16, (i) => i);
    final nonce = List<int>.generate(12, (i) => 0x10 + i);
    const amount = 0x00010203040506; // < 2^53: exact on JS f64 too
    final enc =
        a.aeEncrypt(key16: key, amount: amount, nonce12: nonce).unwrapOrThrow();
    expect(enc, hasLength(36));
    expect(enc.sublist(0, 12).toList(), nonce);
    expect(a.aeDecrypt(key16: key, ae: enc.toList()).unwrapOrThrow(), amount);
    // Tampered tag fails closed.
    final bad = enc.toList();
    bad[35] ^= 1;
    expect(a.aeDecrypt(key16: key, ae: bad).isErr, isTrue);
  });
}

/// Standalone entry: `dart test test/backend/solana_zk_test.dart` (VM, FFI backend).
void main() async {
  await ConnectorTestApi.ensureBackend();
  runSolanaZkSuite(() => ConnectorTestApi.bu);
}
