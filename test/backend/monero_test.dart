import 'package:blockchain_utils_connector/blockchain_utils_connector.dart';
import 'package:test/test.dart';

import '../test_utils.dart';

/// Monero output scan + Bulletproofs+ roundtrips.
///
/// Runs on FFI and WASM: all vectors are inline data in this file, opened
/// through [openBu]. Scan vectors match
/// `blockchain-utils/tests/monero_scan_kat.rs` (C oracle).
void runMoneroSuite(Bu Function() openBu) {
  BuBytes hx(String s) => BuBytes([
    for (var i = 0; i < s.length; i += 2)
      int.parse(s.substring(i, i + 2), radix: 16),
  ]);

  // `markTestSkipped` only flags without stopping — declare
  // `skip:` so these never execute without the debug library.
  test('unlockBatch finds oracle output', () {
    final api = openBu().monero;
    final view = [0x77, ...List<int>.filled(30, 0), 0x05];
    final res = api.unlockBatch(
      accounts: [
        BuMoneroScanAccount(
          viewSecret: view,
          spendPubs: [
            hx(
              '9e85d0e9a7d19f4a56a7c5269e2ea8224eff39f1cb063f9368ab0348bc30bb7c',
            ),
          ],
        ),
      ],
      outputs: [
        BuMoneroScanOutput(
          outKey: hx(
            '0a2a09d53c51bd054372cfbb32db89490f3843e044cfce5c800c52dfb9bd5883',
          ),
          txPub: hx(
            '3473799e0a88477e856dfff95ee217d1fa2576fe6811f942874bbb5256fd1732',
          ),
          viewTag: 59,
        ),
        BuMoneroScanOutput(
          outKey: List<int>.filled(32, 0xAB),
          txPub: hx(
            '3473799e0a88477e856dfff95ee217d1fa2576fe6811f942874bbb5256fd1732',
          ),
          viewTag: 7,
        ),
      ],
    );
    expect(res.isOk, isTrue, reason: '${res.error}');
    final matches = res.value!;
    expect(matches.length, 1);
    expect(matches[0].outIndex, 0);
    expect(matches[0].accountIndex, 0);
    expect(matches[0].addressPos, 0);
    expect(
      matches[0].derivation.toList(),
      hx('7306b0cf9ff5818b1f98e08d2e0fc9795e2002161eaced79a7d6d8f2cfa43e65'),
    );
    expect(
      matches[0].derivedPk.toList(),
      hx('0a2a09d53c51bd054372cfbb32db89490f3843e044cfce5c800c52dfb9bd5883'),
    );
  });

  test('unlockBatch validation rejects bad keys', () {
    // Pure-Dart validation runs before any native call.
    final api = openBu().monero;
    final bad = api.unlockBatch(accounts: [], outputs: []);
    expect(bad.isErr, isTrue);
  });

  test('bulletproofs+ prove/verify roundtrip (M=1, fixed seed)', () {
    final api = openBu().monero;
    final gamma = [List<int>.filled(32, 0)..[0] = 7];
    final seed = List<int>.filled(32, 9);
    final amounts = [
      [0, 0, 0, 0, 0, 0, 0, 0],
    ];
    final proof =
        api
            .bpPlusProveAmounts(amountsLe: amounts, gamma: gamma, seed: seed)
            .unwrapOrThrow();
    expect(proof.isEmpty, isFalse);
    // Verify consumes a packed batch: n:u32le || len:u32le || proof.
    BuBytes pack(BuBytes blob) => BuBytes([
      1,
      0,
      0,
      0,
      blob.length & 0xFF,
      (blob.length >> 8) & 0xFF,
      (blob.length >> 16) & 0xFF,
      (blob.length >> 24) & 0xFF,
      ...blob,
    ]);
    expect(api.bpPlusVerify(pack(proof)).unwrapOrThrow(), isTrue);
    // Tampered blob fails closed (false or framing error, never a crash
    // or a forged true).
    final bad = proof.toList()..[10] ^= 1;
    final t = api.bpPlusVerify(pack(BuBytes(bad)));
    expect(t.isErr || t.value == false, isTrue);
  });

  test('parseMoneroUnlockMatches rejects bad lengths', () {
    expect(() => parseMoneroUnlockMatches([1, 2, 3]), throwsA(isA<BuError>()));
    expect(parseMoneroUnlockMatches([]), isEmpty);
  });
}

/// Standalone entry: `dart test test/backend/monero_test.dart` (VM, FFI backend).
void main() async {
  await ConnectorTestApi.ensureBackend();
  runMoneroSuite(() => ConnectorTestApi.bu);
}
