import 'package:blockchain_utils_connector/blockchain_utils_connector.dart';
import 'package:test/test.dart';

import '../test_utils.dart';

/// Hardware-wallet sign flows (Ledger template + Trezor `SignMessage`).
///
/// Runs on FFI and WASM: all vectors are inline data in this file, opened
/// through [openBu].
void runHwSignSuite(Bu Function() openBu) {
  BuHwApi api() => openBu().hw;

  group('hw sign', () {
    // hw is an opt-in Cargo feature: capability-gate at run time (the
    // backend is only initialized in setUpAll, so this cannot run at
    // registration). Never a failure.
    setUpAll(() {
      if (!openBu().backendInfo.has(BuBuildFeature.hw)) {
        markTestSkipped('backend built without hw feature');
      }
    });

    BuBytes pathU32() {
      final r = api().parsePath("m/44'/0'/0'/0/0");
      expect(r.isErr, isFalse);
      // 5 indexes as u32 LE = 20 bytes (native returns a count; the
      // platform layer normalizes to bytes — regression for the truncation).
      expect(r.value!.length, 20);
      expect(r.value!.toList().sublist(0, 4), [0x2C, 0x00, 0x00, 0x80]);
      return r.value!;
    }

    /// `?## || be16(type) || be32(len) || body`, padded into 63-byte chunks.
    BuBytes trezorFrame(int type, List<int> body) {
      final out = <int>[
        0x3F,
        0x23,
        0x23,
        (type >> 8) & 0xFF,
        type & 0xFF,
        (body.length >> 24) & 0xFF,
        (body.length >> 16) & 0xFF,
        (body.length >> 8) & 0xFF,
        body.length & 0xFF,
        ...body,
      ];
      while (out.length % 63 != 0) {
        out.add(0);
      }
      return BuBytes(out);
    }

    group('ledger sign ', () {
      test('bare-hash sign is Unimplemented (v2 = PSBT wallet flow)', () async {
        final path = pathU32();
        final hash = BuBytes(List<int>.filled(32, 0xAB));

        final req = api().signRequest(
          device: BuHwDevice.ledgerNanoSPlus,
          coin: BuHwCoin.btc,
          pathU32: path,
          payload: hash,
        );
        expect(req.isErr, isTrue);

        final sig = await api().executeSign(
          device: BuHwDevice.ledgerNanoSPlus,
          coin: BuHwCoin.btc,
          pathU32: path,
          payload: hash,
          transport: BuMockHwTransport([
            [0x90, 0x00],
          ]),
        );
        expect(sig.isErr, isTrue);
      });

      test('v2 xpub request shape + fingerprint', () {
        final path = pathU32();
        final req = api().getAddressRequest(
          device: BuHwDevice.ledgerNanoSPlus,
          coin: BuHwCoin.btc,
          pathU32: path,
        );
        expect(req.isErr, isFalse);
        // E1 00 00 01 || Lc(22) || display(0) || path_len(5) || be32(44') ...
        expect(req.value!.toList().sublist(0, 7), [
          0xE1,
          0x00,
          0x00,
          0x01,
          0x16,
          0x00,
          0x05,
        ]);
        expect(req.value!.toList().sublist(7, 11), [0x80, 0x00, 0x00, 0x2C]);

        final fp = api().ledgerFingerprint();
        expect(fp.isErr, isFalse);
        expect(fp.value!.toList(), [0xE1, 0x05, 0x00, 0x01]);
        final parsed = api().ledgerFingerprintParse(
          response: BuBytes([0x12, 0x34, 0x56, 0x78, 0x90, 0x00]),
        );
        expect(parsed.isErr, isFalse);
        expect(parsed.value!.toList(), [0x12, 0x34, 0x56, 0x78]);
        expect(
          api().ledgerFingerprintParse(response: BuBytes([0x69, 0x85])).isErr,
          isTrue,
        );
      });
    });

    group('trezor SignMessage ', () {
      test('approve + wrong message type', () async {
        final path = pathU32();
        final msg = BuBytes('hello trezor'.codeUnits);
        final sig = List<int>.filled(65, 0x99);
        // MessageSignature{ address: "x", signature: sig }
        final body = <int>[0x0A, 0x01, 0x78, 0x12, 0x41, ...sig];
        final frame = trezorFrame(40, body);

        final dev = BuMockHwTransport([frame.toList()]);
        final out = await api().executeSign(
          device: BuHwDevice.trezorSafe5,
          coin: BuHwCoin.btc,
          pathU32: path,
          payload: msg,
          transport: dev,
        );
        expect(out.isErr, isFalse);
        expect(out.value!.toList(), sig);

        // ADDRESS (30) answering a sign -> error, never a panic.
        final dev2 = BuMockHwTransport([
          trezorFrame(30, [0x0A, 0x01, 0x78]).toList(),
        ]);
        final wrong = await api().executeSign(
          device: BuHwDevice.trezorSafe5,
          coin: BuHwCoin.btc,
          pathU32: path,
          payload: msg,
          transport: dev2,
        );
        expect(wrong.isErr, isTrue);
      });
    });

    group('refusal contracts ', () {
      test('airgap sign is qr-only, oversized trezor message rejected', () {
        final path = pathU32();
        final hash = BuBytes(List<int>.filled(32, 0));
        final air = api().signRequest(
          device: BuHwDevice.passport,
          coin: BuHwCoin.btc,
          pathU32: path,
          payload: hash,
        );
        expect(air.isErr, isTrue);
        final big = api().signRequest(
          device: BuHwDevice.trezorSafe5,
          coin: BuHwCoin.btc,
          pathU32: path,
          payload: BuBytes(List<int>.filled(1025, 0)),
        );
        expect(big.isErr, isTrue);
      });
    });

    /// Hand-built `TxRequest{type, details{index}}` frame.
    BuBytes txReqFrame(int type, int? index) {
      final body = <int>[0x08, type];
      if (index != null) {
        body.addAll([0x12, 0x02, 0x08, index]);
      }
      return trezorFrame(21, body);
    }

    group('trezor SignTx loop ', () {
      test('start -> meta -> input -> output -> finished', () async {
        final path = pathU32();

        // open: SIGN_TX frame (?## magic, be16 type 15)
        final start = api().signTxStart(
          device: BuHwDevice.trezorSafe5,
          coin: BuHwCoin.btc,
          inputsCount: 1,
          outputsCount: 1,
        );
        expect(start.isErr, isFalse);
        final sb = start.value!.toList();
        expect(sb.sublist(0, 3), [0x3F, 0x23, 0x23]);
        expect((sb[3] << 8) | sb[4], 15);
        // ledger refuses the session open
        final noLedger = api().signTxStart(
          device: BuHwDevice.ledgerNanoSPlus,
          coin: BuHwCoin.btc,
          inputsCount: 1,
          outputsCount: 1,
        );
        expect(noLedger.isErr, isTrue);

        // script the device side
        final sig = List<int>.filled(64, 0xAA);
        final stx = [0xBB, 0x01, 0x02];
        final innerFin = <int>[
          0x08,
          0x00,
          0x12,
          sig.length,
          ...sig,
          0x1A,
          stx.length,
          ...stx,
        ];
        final finBody = <int>[0x08, 0x03, 0x1A, innerFin.length, ...innerFin];
        final dev = BuMockHwTransport([
          txReqFrame(2, null).toList(), // TXMETA=2
          txReqFrame(0, 0).toList(), // TXINPUT=0 #0
          txReqFrame(1, 0).toList(), // TXOUTPUT=1 #0
          trezorFrame(21, finBody).toList(), // TXFINISHED + sig + tx
        ]);

        Future<(int, int)> round(BuBytes req) async {
          final resp = await dev.exchange(req);
          final pr = api().parseTxRequest(
            device: BuHwDevice.trezorSafe5,
            response: resp,
          );
          expect(pr.isErr, isFalse);
          return pr.value!;
        }

        expect(await round(start.value!), (2, -1));
        final ackMeta = api().txAckMeta(
          version: 2,
          lockTime: 0,
          inputsCount: 1,
          outputsCount: 1,
        );
        expect(ackMeta.isErr, isFalse);
        expect(await round(ackMeta.value!), (0, 0));

        final ackIn = api().txAckInput(
          prevHash32: BuBytes(List<int>.filled(32, 0xCC)),
          prevIndex: 3,
          pathU32: path,
          amountSat: 60000,
          scriptSig: BuBytes([]),
          scriptType: 0,
        );
        expect(ackIn.isErr, isFalse);
        expect(await round(ackIn.value!), (1, 0));

        final ackOut = api().txAckOutput(
          address: 'bc1qtest',
          amountSat: 50000,
          scriptType: 0,
        );
        expect(ackOut.isErr, isFalse);
        final fin = await dev.exchange(ackOut.value!);
        final finParsed = api().parseTxRequest(
          device: BuHwDevice.trezorSafe5,
          response: fin,
        );
        expect(finParsed.value!, (3, -1));
        final gotSig = api().txRequestSignature(
          device: BuHwDevice.trezorSafe5,
          response: fin,
        );
        expect(gotSig.value!.toList(), sig);
        final gotTx = api().txRequestSerialized(
          device: BuHwDevice.trezorSafe5,
          response: fin,
        );
        expect(gotTx.value!.toList(), stx);

        expect(dev.seen.length, 4);
      });
    });

    group('trezor SignIdentity ', () {
      test('encode + request + parse signed identity', () {
        final id = api().identityEncode(
          proto: 'ssh',
          user: 'alice',
          host: 'example.com',
        );
        expect(id.isErr, isFalse);
        // IdentityType{1:ssh, 2:alice, 3:example.com, 6:index=0}
        // (index always encoded, matching trezorlib byte-for-byte)
        expect(id.value!.toList(), [
          0x0A,
          3,
          ...'ssh'.codeUnits,
          0x12,
          5,
          ...'alice'.codeUnits,
          0x1A,
          11,
          ...'example.com'.codeUnits,
          0x30,
          0x00,
        ]);
        expect(api().identityEncode(proto: '').isErr, isTrue);

        final req = api().signIdentityRequest(
          identity: id.value!,
          hidden: BuBytes(List<int>.filled(32, 0xAA)),
          visual: '2026-10-06',
        );
        expect(req.isErr, isFalse);
        // framed message type 53: ?## 0035 len32 ...
        final raw = req.value!.toList();
        expect(raw.sublist(0, 5), [0x3F, 0x23, 0x23, 0x00, 53]);
        expect(
          api()
              .signIdentityRequest(identity: BuBytes([]), hidden: BuBytes([]))
              .isErr,
          isTrue,
        );

        // hand-rolled SignedIdentity{1:addr, 2:pubkey, 3:sig}
        final body = <int>[
          0x0A,
          5,
          ...'alice'.codeUnits,
          0x12,
          33,
          ...List<int>.filled(33, 0x02),
          0x1A,
          65,
          ...List<int>.filled(65, 0xCC),
        ];
        final resp = BuBytes(body);
        expect(api().signedIdentityAddress(response: resp).value!, 'alice');
        expect(api().signedIdentityPubkey(response: resp).value!.length, 33);
        expect(api().signedIdentitySignature(response: resp).value!.length, 65);
        expect(
          api().signedIdentityAddress(response: BuBytes([0x12, 1, 0x02])).isErr,
          isTrue,
        );
        expect(
          api().signedIdentitySignature(response: BuBytes([0xFF])).isErr,
          isTrue,
        );
      });
    });
  });
}

/// Standalone entry: `dart test test/backend/hw_sign_test.dart` (VM, FFI backend).
void main() async {
  await ConnectorTestApi.ensureBackend();
  runHwSignSuite(() => ConnectorTestApi.bu);
}
