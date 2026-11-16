@TestOn('vm')
library emu_live_test;

/// Live emulator integration (Trezor UDP + BitBox TCP + Speculos APDU).
///
/// VM-only. Runs ONLY with `BU_EMU_LIVE=1` and reachable emulator ports;
/// otherwise every test skips (CI has no emulators). Stateless calls only —
/// Speculos serves one flow per boot, so no signing flows here. Backend
/// resolution (FFI path / cargo build) goes through [ConnectorTestApi].
import 'dart:io';

import 'package:blockchain_utils_connector/blockchain_utils_connector.dart';
import 'package:test/test.dart';

import 'test_utils.dart';

void main() async {
  await ConnectorTestApi.ensureBackend();

  BuHwApi api() => ConnectorTestApi.bu.hw;

  Future<bool> tcpUp(String host, int port) async {
    try {
      final s = await Socket.connect(
        host,
        port,
        timeout: const Duration(seconds: 2),
      );
      s.destroy();
      return true;
    } catch (_) {
      return false;
    }
  }

  // `markTestSkipped` only flags without stopping, so the
  // group is declared `skip:` unless live emulators are requested AND the
  // debug library exists (per-test tcpUp guards still narrow to live ports).
  group('emulator transports', () {
    setUpAll(() {
      if (testEnvVar('BU_EMU_LIVE') != '1') {
        markTestSkipped('BU_EMU_LIVE != 1');
      }
    });

    BuBytes pathU32() {
      final p = api().parsePath("m/44'/0'/0'/0/0");
      expect(p.isErr, isFalse);
      return p.value!;
    }

    test('trezor emulator: GetAddress matches banked vector', () async {
      final req = api().getAddressRequest(
        device: BuHwDevice.trezorModelT,
        coin: BuHwCoin.btc,
        pathU32: pathU32(),
      );
      expect(req.isErr, isFalse);
      final dev = TrezorEmulatorTransport();
      BuBytes resp;
      try {
        resp = await dev
            .exchange(req.value!)
            .timeout(const Duration(seconds: 15));
      } catch (_) {
        markTestSkipped('trezor emulator down');
        return;
      }
      final addr = api().parseAddressResponse(
        device: BuHwDevice.trezorModelT,
        response: resp,
      );
      expect(addr.isErr, isFalse);
      expect(
        String.fromCharCodes(addr.value!),
        '1LqBGSKuX5yYUonjxT5qGfpUsXKYYWeabA',
      );
    });

    Future<void> bitboxHandshake() async {
      expect(api().bitboxFree().isErr, isFalse);
      final dev = BitBoxSimulatorTransport();
      try {
        final init = await dev.exchange(BuBytes([0x68 /*h*/]));
        expect(init.toList(), [0x00]);
        expect(
          api()
              .bitboxHsNew(
                staticPriv32: BuBytes(List<int>.filled(32, 0x41)),
                ephemeralPriv32: BuBytes(List<int>.filled(32, 0x42)),
              )
              .isErr,
          isFalse,
        );
        final m1 = api().bitboxHsM1();
        expect(m1.isErr, isFalse);
        final m2 = await dev.exchange(BuBytes([0x48 /*H*/, ...m1.value!]));
        expect(
          api().bitboxHsM2(m2: m2.sublist(1)).isErr,
          isFalse,
          reason: 'firmware m2 (96 B after inner OP status)',
        );
        final m3 = api().bitboxHsM3();
        expect(m3.isErr, isFalse);
        final done = await dev.exchange(BuBytes([0x48 /*H*/, ...m3.value!]));
        expect(done.length, 2); // [OP_STATUS, pairing]
        expect(done[0], 0);
        expect(api().bitboxHsSplit().isErr, isFalse);
        final h = api().bitboxHsHash();
        expect(h.isErr, isFalse);
        expect(h.value!.length, 32);
      } finally {
        expect(api().bitboxFree().isErr, isFalse);
        await dev.close();
      }
    }

    test('bitbox simulator: Noise_XX handshake completes', () async {
      if (!await tcpUp('127.0.0.1', EmuPorts.bitboxTcp)) {
        markTestSkipped('bitbox simulator down');
        return;
      }
      // without a live simulator a refused connection is a
      // skip, never a failure (also covers check-then-act races).
      try {
        await bitboxHandshake();
      } on SocketException {
        markTestSkipped('bitbox simulator went away');
      }
    });

    test('speculos: fingerprint + xpub shape', () async {
      if (!await tcpUp('127.0.0.1', EmuPorts.speculosApdu)) {
        markTestSkipped('speculos down (set port via BU_SPECULOS_PORT?)');
        return;
      }
      // without a live simulator a refused connection is a
      // skip, never a failure (also covers check-then-act races).
      try {
        final dev = SpeculosApduTransport();
        final fp = await dev.exchange(BuBytes([0xE1, 0x05, 0x00, 0x01]));
        expect(fp.length, 6); // 4 bytes + SW
        expect(fp.sublist(4), [0x90, 0x00]);
      } on SocketException {
        markTestSkipped('speculos went away');
      }
    });
  }, skip: testEnvVar('BU_EMU_LIVE') != '1' ? 'BU_EMU_LIVE != 1' : null);
}
