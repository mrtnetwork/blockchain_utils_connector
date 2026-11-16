import 'package:blockchain_utils_connector/blockchain_utils_connector.dart';
import 'package:test/test.dart';

/// `BuHwKind` ids mirror `BuHwDevice` ids; resolver semantics. Pure Dart
/// (no native library needed).
void main() {
  group('BuHwKind ids match BuHwDevice', () {
    test('order and fromId', () {
      expect(BuHwKind.ledgerNanoSPlus.id, BuHwDevice.ledgerNanoSPlus);
      expect(BuHwKind.trezorModelT.id, BuHwDevice.trezorModelT);
      expect(BuHwKind.trezorSafe5.id, BuHwDevice.trezorSafe5);
      expect(BuHwKind.bitBox02.id, BuHwDevice.bitBox02);
      expect(BuHwKind.jadeQr.id, BuHwDevice.jadeQr);
      expect(BuHwKind.values.length, BuHwDevice.count);
      expect(BuHwKind.fromId(5), BuHwKind.trezorModelT);
      expect(BuHwKind.fromId(11), BuHwKind.bitBox02);
      expect(BuHwKind.fromId(99), isNull);
    });
  });

  group('hwFor resolver', () {
    const table = [
      HwVariantSupport(
        device: BuHwKind.trezorModelT,
        variant: 'p2pkh',
        readiness: HwReadiness.ready,
        why: 'test',
      ),
      HwVariantSupport(
        device: BuHwKind.bitBox02,
        variant: 'p2pkh',
        readiness: HwReadiness.impossible,
        why: 'test',
      ),
      HwVariantSupport(
        device: BuHwKind.ledgerNanoSPlus,
        variant: 'p2wpkh',
        readiness: HwReadiness.needsAppWork,
        why: 'test',
      ),
    ];

    test('filters by variant, empty on missing', () {
      final p2pkh = hwFor(table, 'p2pkh');
      expect(p2pkh.length, 2);
      expect(hwFor(table, 'p2tr'), isEmpty);
      expect(hwFor(null, 'p2pkh'), isEmpty);
      expect(hwFor([], 'p2pkh'), isEmpty);
    });

    test('hwBest collapses to max readiness', () {
      expect(hwBest(hwFor(table, 'p2pkh')), HwReadiness.ready);
      expect(hwBest(hwFor(table, 'p2wpkh')), HwReadiness.needsAppWork);
      expect(hwBest(hwFor(table, 'nope')), HwReadiness.unknown);
    });
  });
}
