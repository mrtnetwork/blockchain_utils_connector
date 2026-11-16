import 'package:blockchain_utils_connector/blockchain_utils_connector.dart';
import 'package:test/test.dart';

import '../test_utils.dart';

/// BitBox02 codec + session state machine.
///
/// Runs on FFI and WASM: all vectors are inline data in this file, opened
/// through [openBu]. Positive crypto paths (full handshake) are proven in
/// Rust (`hw_bitbox.rs`); here we pin the state machine, OP-less codec
/// shapes, and fail-closed semantics.
void runHwBitboxSuite(Bu Function() openBu) {
  BuHwApi api() => openBu().hw;

  group('hw bitbox', () {
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
      return r.value!;
    }

    group('bitbox codec ', () {
      test('btc_pub request shape + pub parse + refusals', () {
        final path = pathU32();
        final req = api().bitboxBtcPubRequest(
          coin: BuHwCoin.btc,
          pathU32: path,
          xpubType: 1,
          display: false,
        );
        expect(req.isErr, isFalse);
        final b = req.value!.toList();
        expect(b[0], 0x42); // Request.btc_pub = field 8, length-delimited
        expect(b[1], b.length - 2);

        // hand-built Response{pub: {pub: "xpubT"}} round-trips
        final inner = [0x0A, 5, ...'xpubT'.codeUnits];
        final resp = BuBytes([0x2A, inner.length, ...inner]);
        expect(resp.toList()[0], 0x2A); // Response.pub = field 5
        final parsed = api().bitboxPubParse(response: resp);
        expect(parsed.isErr, isFalse);
        expect(parsed.value!, 'xpubT');

        // device Error envelope -> err, never a string
        final errResp = BuBytes([0x12, 0x02, 0x08, 0x01]);
        expect(errResp.toList()[0], 0x12); // Response.error = field 2
        expect(api().bitboxPubParse(response: errResp).isErr, isTrue);

        // bad coin / bad xpub type rejected host-side
        expect(
          api()
              .bitboxBtcPubRequest(
                coin: BuHwCoin.xtzTz1,
                pathU32: path,
                xpubType: 1,
                display: false,
              )
              .isErr,
          isTrue,
        );
        expect(
          api()
              .bitboxBtcPubRequest(
                coin: BuHwCoin.btc,
                pathU32: path,
                xpubType: 99,
                display: false,
              )
              .isErr,
          isTrue,
        );
      });
    });

    group('bitbox session state machine ', () {
      test('open/double-open/m1/wrong-state/garbage-m2/free', () {
        final s32 = BuBytes(List<int>.filled(32, 0x11));
        final e32 = BuBytes(List<int>.filled(32, 0x12));
        expect(
          api().bitboxHsNew(staticPriv32: s32, ephemeralPriv32: e32).isErr,
          isFalse,
        );
        // double-open fails instead of clobbering
        expect(
          api().bitboxHsNew(staticPriv32: s32, ephemeralPriv32: e32).isErr,
          isTrue,
        );

        final m1 = api().bitboxHsM1();
        expect(m1.isErr, isFalse);
        expect(m1.value!.length, 32);

        // encrypt/hash/split before handshake completion: wrong state
        expect(
          api().bitboxEncrypt(plaintext: BuBytes([1, 2, 3])).isErr,
          isTrue,
        );
        expect(api().bitboxHsHash().isErr, isTrue);
        expect(api().bitboxHsSplit().isErr, isTrue);

        // garbage m2: rejected AND session spent (fail-closed)
        expect(
          api().bitboxHsM2(m2: BuBytes(List<int>.filled(96, 0xFF))).isErr,
          isTrue,
        );
        expect(api().bitboxHsM1().isErr, isTrue);

        // free wipes; everything fails until reopened; free is idempotent
        expect(api().bitboxFree().isErr, isFalse);
        expect(api().bitboxHsM1().isErr, isTrue);
        expect(
          api()
              .bitboxDecrypt(ciphertext: BuBytes(List<int>.filled(16, 0)))
              .isErr,
          isTrue,
        );
        expect(api().bitboxFree().isErr, isFalse);

        // bad key lengths rejected without touching the slot
        expect(
          api()
              .bitboxHsNew(
                staticPriv32: BuBytes(List<int>.filled(31, 0)),
                ephemeralPriv32: e32,
              )
              .isErr,
          isTrue,
        );
      });
    });

    /// Hand-built `Response{btc: BTCResponse{sign_next}}` (independent of the
    /// native encoder): outer tag (13<<3)|2 = 0x6A, inner tag (3<<3)|2 = 0x1A.
    BuBytes bbSignNext(int type, int? index, List<int>? sig, [int? prevIndex]) {
      final sn = <int>[0x08, type];
      if (index != null) {
        sn.addAll([0x10, index]);
      }
      if (sig != null) {
        sn.addAll([0x18, 0x01, 0x22, sig.length, ...sig]);
      }
      if (prevIndex != null) {
        sn.addAll([0x28, prevIndex]);
      }
      final btc = <int>[0x1A, sn.length, ...sn];
      return BuBytes([0x6A, btc.length, ...btc]);
    }

    /// Hand-built DIRECT `Response{btc_sign_next}` (what firmware sends for
    /// the simple single-sig flow): outer tag (6<<3)|2 = 0x32.
    BuBytes bbSignNextDirect(int type, int? index, List<int>? sig) {
      final sn = <int>[0x08, type];
      if (index != null) {
        sn.addAll([0x10, index]);
      }
      if (sig != null) {
        sn.addAll([0x18, 0x01, 0x22, sig.length, ...sig]);
      }
      return BuBytes([0x32, sn.length, ...sn]);
    }

    group('bitbox sign flow ', () {
      test('init shape + next parse + acks + signature extract', () {
        final path = pathU32();
        final init = api().bitboxSignInit(
          coin: BuHwCoin.btc,
          pathU32: path,
          simpleType: 1,
          version: 1,
          inputsCount: 1,
          outputsCount: 1,
          locktime: 0,
        );
        expect(init.isErr, isFalse);
        expect(init.value!.toList()[0], 0x4A); // Request.btc_sign_init = 9
        expect(
          api()
              .bitboxSignInit(
                coin: BuHwCoin.btc,
                pathU32: path,
                simpleType: 1,
                version: 0,
                inputsCount: 1,
                outputsCount: 1,
                locktime: 0,
              )
              .isErr,
          isTrue,
        ); // version must be 1-2

        // INPUT#2 parses; absent index maps to -1
        final q = api().bitboxSignNextParse(response: bbSignNext(0, 2, null));
        expect(q.isErr, isFalse);
        expect(q.value!, (0, 2));
        final qNoIndex = api().bitboxSignNextParse(
          response: bbSignNext(2, null, null),
        );
        expect(qNoIndex.value!, (2, -1));
        // prev_index extractor: present vs absent
        expect(
          api()
              .bitboxSignNextPrevIndex(response: bbSignNext(4, 0, null, 7))
              .value!,
          7,
        );
        expect(
          api()
              .bitboxSignNextPrevIndex(response: bbSignNext(4, 0, null))
              .value!,
          -1,
        );

        // ack builders produce the right envelopes
        final ackIn = api().bitboxSignInput(
          prevHash32: BuBytes(List<int>.filled(32, 0x11)),
          prevIndex: 0,
          amountSat: 60000,
          sequence: 0xFFFFFFFF,
          pathU32: path,
          scriptConfigIndex: 0,
        );
        expect(ackIn.isErr, isFalse);
        expect(ackIn.value!.toList()[0], 0x52); // Request.btc_sign_input = 10
        final ackOut = api().bitboxSignOutput(
          outputType: 1,
          amountSat: 40000,
          payload: BuBytes(List<int>.filled(20, 0x22)),
        );
        expect(ackOut.isErr, isFalse);
        expect(ackOut.value!.toList()[0], 0x5A); // Request.btc_sign_output = 11
        final ackChange = api().bitboxSignChange(
          pathU32: path,
          amountSat: 20000,
          scriptConfigIndex: 0,
        );
        expect(ackChange.isErr, isFalse);

        // DONE with a 64-byte signature extracts byte-exact
        final sig = List<int>.filled(64, 0xBB);
        final fin = api().bitboxSignNextParse(response: bbSignNext(2, 0, sig));
        expect(fin.value!, (2, 0));
        final got = api().bitboxSignNextSignature(
          response: bbSignNext(2, 0, sig),
        );
        expect(got.isErr, isFalse);
        expect(got.value!.toList(), sig);
        // no signature present -> err, never empty bytes
        expect(
          api().bitboxSignNextSignature(response: bbSignNext(2, 0, null)).isErr,
          isTrue,
        );

        // DIRECT envelope (firmware simple-flow) parses identically, and an
        // empty sign_next is INPUT-with-defaults (proto3 zero omission).
        final dq = api().bitboxSignNextParse(
          response: bbSignNextDirect(0, 0, null),
        );
        expect(dq.value!, (0, 0));
        final dqEmpty = api().bitboxSignNextParse(
          response: BuBytes([0x32, 0x00]),
        );
        expect(dqEmpty.value!, (0, -1));

        // prevtx ack builders: Request{btc = 25} envelopes
        final pInit = api().bitboxSignPrevtxInit(
          version: 2,
          inputsCount: 1,
          outputsCount: 1,
          locktime: 0,
        );
        expect(pInit.isErr, isFalse);
        expect(pInit.value!.toList()[0], 0xCA); // (25<<3)|2 = 0xCA
        final pIn = api().bitboxSignPrevtxInput(
          prevHash32: BuBytes(List<int>.filled(32, 0x33)),
          prevIndex: 0,
          scriptSig: BuBytes([]),
          sequence: 0xFFFFFFFF,
        );
        expect(pIn.isErr, isFalse);
        expect(pIn.value!.toList()[0], 0xCA);
        final pOut = api().bitboxSignPrevtxOutput(
          amountSat: 60000,
          script: BuBytes(List<int>.filled(22, 0x44)),
        );
        expect(pOut.isErr, isFalse);
        expect(pOut.value!.toList()[0], 0xCA);
      });
    });
  });
}

/// Standalone entry: `dart test test/backend/hw_bitbox_test.dart` (VM, FFI backend).
void main() async {
  await ConnectorTestApi.ensureBackend();
  runHwBitboxSuite(() => ConnectorTestApi.bu);
}
