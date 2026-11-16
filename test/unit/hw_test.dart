import 'package:test/test.dart';
import 'package:blockchain_utils_connector/blockchain_utils_connector.dart';

void main() {
  group('hw ids', () {
    test('device ids match Rust DeviceKind::ALL order', () {
      expect(BuHwDevice.ledgerNanoSPlus, 0);
      expect(BuHwDevice.ledgerNanoX, 1);
      expect(BuHwDevice.ledgerFlex, 2);
      expect(BuHwDevice.ledgerStax, 3);
      expect(BuHwDevice.trezorOne, 4);
      expect(BuHwDevice.trezorModelT, 5);
      expect(BuHwDevice.trezorSafe3, 6);
      expect(BuHwDevice.trezorSafe5, 7);
      expect(BuHwDevice.trezorSafe7, 8);
      expect(BuHwDevice.keepKey, 9);
      expect(BuHwDevice.oneKey, 10);
      expect(BuHwDevice.bitBox02, 11);
      expect(BuHwDevice.passport, 12);
      expect(BuHwDevice.keystone3, 13);
      expect(BuHwDevice.keystonePro, 14);
      expect(BuHwDevice.coldcardQr, 15);
      expect(BuHwDevice.jadeQr, 16);
      expect(BuHwDevice.count, 17);
      expect(BuHwDevice.airgap.length, 5);
    });

    test('coin ids match Rust WELL_KNOWN_COINS order', () {
      expect(BuHwCoin.btc, 0);
      expect(BuHwCoin.eth, 3);
      expect(BuHwCoin.xtzTz1, 8);
      expect(BuHwCoin.xtzTz2, 9);
      expect(BuHwCoin.xtzTz3, 10);
      expect(BuHwCoin.sol, 11);
      expect(BuHwCoin.zecTransparent, 19);
      expect(BuHwCoin.btcTestnet, 20);
      expect(BuHwCoin.count, 21);
    });
  });

  group('u32 LE helpers', () {
    test('roundtrip', () {
      const idx = [0x8000002C, 0x80000000, 0, 5];
      final b = u32sToLeBytes(idx);
      expect(b.length, 16);
      expect(b.sublist(0, 4), [0x2C, 0x00, 0x00, 0x80]);
      expect(leBytesToU32s(b), idx);
    });

    test('bad length throws BuError', () {
      expect(() => leBytesToU32s([1, 2, 3]), throwsA(isA<BuError>()));
    });
  });

  group('base32 no-pad', () {
    test('roundtrip incl. empty', () {
      for (final v in <List<int>>[
        [],
        [0],
        [255],
        [104, 101, 108, 108, 111],
        List<int>.generate(64, (i) => (i * 37) & 0xFF),
      ]) {
        expect(buBase32DecodeNoPad(buBase32EncodeNoPad(v)).toList(), v);
      }
    });

    test('uppercase accepted, garbage rejected', () {
      final lower = buBase32EncodeNoPad([104, 105]);
      expect(buBase32DecodeNoPad(lower.toUpperCase()).toList(), [104, 105]);
      expect(() => buBase32DecodeNoPad('!!!'), throwsA(isA<BuError>()));
    });
  });

  group('BuUrAssembler', () {
    String shard(String type, int seq, int total, List<int> payload) {
      return 'ur:$type/$seq-of-$total/${buBase32EncodeNoPad(payload)}';
    }

    test('out-of-order + duplicates reassemble', () {
      final a = BuUrAssembler();
      expect(a.isEmpty, isTrue);
      expect(a.feed(shard('bytes', 2, 3, [4, 5, 6, 7])), isNull);
      expect(a.feed(shard('bytes', 1, 3, [1, 2, 3])), isNull);
      expect(a.feed(shard('bytes', 2, 3, [4, 5, 6, 7])), isNull); // dup
      final done = a.feed(shard('bytes', 3, 3, [8, 9]));
      expect(done?.toList(), [1, 2, 3, 4, 5, 6, 7, 8, 9]);
    });

    test('mixed streams and bad envelopes throw BuError', () {
      final a = BuUrAssembler();
      a.feed(shard('bytes', 1, 2, [1]));
      expect(
        () => a.feed(shard('crypto-psbt', 2, 2, [2])),
        throwsA(isA<BuError>()),
      );
      expect(() => a.feed('ur:bytes/9-of-2/aa'), throwsA(isA<BuError>()));
      expect(() => a.feed('not-a-ur'), throwsA(isA<BuError>()));
      expect(() => a.feed('ur:bytes/aa'), throwsA(isA<BuError>()));
    });
  });

  group('discovery', () {
    test('VID lookup', () {
      expect(BuHwKnownVids.familyFor(0x2C97), 'ledger');
      expect(BuHwKnownVids.familyFor(0x534C), 'trezor');
      expect(BuHwKnownVids.familyFor(0x1209), 'trezor');
      expect(BuHwKnownVids.familyFor(0x2B24), 'trezor');
      expect(BuHwKnownVids.familyFor(0x03EB), 'bitbox');
      expect(BuHwKnownVids.familyFor(0x046D), isNull);
      expect(BuHwKnownVids.isCandidate(0x2C97), isTrue);
      expect(BuHwKnownVids.isCandidate(0x046D), isFalse);
    });

    test('device info family guess + static discovery', () async {
      final d = BuStaticHwDiscovery([
        BuHwDeviceInfo(id: const BuHwUsbId(0x2C97, 0x0001), path: 'hid-1'),
        BuHwDeviceInfo(id: const BuHwUsbId(0x046D, 0xC52B)),
      ]);
      final all = await d.list();
      expect(all.length, 2);
      expect(all.first.familyGuess, 'ledger');
      expect(all.last.familyGuess, isNull);
      final alive =
          all.where((e) => BuHwKnownVids.isCandidate(e.id.vid)).toList();
      expect(alive.length, 1);
    });

    test('HID frame capacity math', () {
      expect(BuHwHid.frameCap(0), 64);
      expect(BuHwHid.frameCap(57), 64);
      expect(BuHwHid.frameCap(58), 128);
      expect(BuHwHid.frameCap(200), 64 * 4);
    });
  });

  group('BuMockHwTransport', () {
    test('records requests, replays script, exhausts', () async {
      final dev = BuMockHwTransport([
        [0x90, 0x00],
        [1, 2, 3],
      ]);
      final r1 = await dev.exchange(BuBytes([0xB0, 0x40]));
      expect(r1.toList(), [0x90, 0x00]);
      expect(dev.seen.length, 1);
      expect(dev.seen.first.toList(), [0xB0, 0x40]);
      await dev.exchange(BuBytes([1]));
      expect(dev.remaining, 0);
      await expectLater(dev.exchange(BuBytes([2])), throwsA(isA<BuError>()));
    });
  });
}
