import 'package:blockchain_utils_connector/blockchain_utils_connector.dart';
import 'package:test/test.dart';

/// Pure-Dart buffer semantics: no backend, no files, no skips.
void runBytesUnitSuite() {
  group('BuBytes', () {
    test('factories: owned vs view vs immutable', () {
      final src = [1, 2, 3];
      final owned = BuBytes(src);
      expect(owned.isOwned, isTrue);
      src[0] = 9;
      expect(owned[0], 1); // copy, not alias
      final view = BuBytes.from(src);
      expect(view.isOwned, isFalse);
      expect(view[0], 9); // alias
      final imm = BuBytes.immutable(src);
      expect(imm.isImmutable, isTrue);
      expect(() => imm[0] = 0, throwsA(isA<BuError>()));
      expect(BuBytes.from(owned), same(owned)); // identity
    });

    test('validation rejects out-of-range bytes', () {
      expect(() => BuBytes([256]), throwsA(isA<BuError>()));
      expect(() => BuBytes([-1]), throwsA(isA<BuError>()));
      expect(BuBytes.toBytes([256, -1]), [0, 255]); // masked, not thrown
    });

    test('zero wipes owned, refuses immutable', () {
      final b = BuBytes([1, 2, 3]);
      expect(b.zero(), isTrue);
      expect(b.toList(), [0, 0, 0]);
      final imm = BuBytes.immutable([1, 2]);
      expect(imm.zero(), isFalse); // operator-guarded path refuses
      expect(imm.toList(), [1, 2]); // untouched
      // forceZero bypasses the guard: fixed-length backing still wipes.
      expect(imm.forceZero(), isTrue);
    });

    test('value equality is content-based', () {
      expect(BuBytes([1, 2]), BuBytes([1, 2]));
      expect(BuBytes([1, 2]), isNot(BuBytes([1, 3])));
      expect(BuBytes([1, 2]), isNot([1, 2, 3]));
    });

    test('concat/sublist/clone/reverse', () {
      final c = BuBytes.concat([
        [1, 2],
        [3],
      ]);
      expect(c.toList(), [1, 2, 3]);
      expect(c.sublist(1).toList(), [2, 3]);
      expect(c.cloneBytes().toList(), [1, 2, 3]);
      expect(c.reverse().toList(), [3, 2, 1]);
    });
  });

  group('SecretBytes', () {
    test('reads reveal, writes throw, zero kills reads', () {
      final s = SecretBytes([10, 20, 30]);
      expect(s.toList(), [10, 20, 30]);
      expect(() => s[0] = 0, throwsA(isA<BuError>()));
      expect(() => s.add(1), throwsA(isA<BuError>()));
      expect(() => s.length = 5, throwsA(isA<BuError>()));
      expect(s.toString(), contains('hidden'));
      expect(s.isZeroed, isFalse);
      s.zero();
      expect(s.isZeroed, isTrue);
      expect(() => s[0], throwsA(isA<BuError>()));
      expect(s.toString(), contains('zeroed'));
      s.zero(); // idempotent
    });

    test('take wipes source; random differs', () {
      final src = [5, 6, 7];
      final s = SecretBytes.take(src);
      expect(src, [0, 0, 0]);
      expect(s.toList(), [5, 6, 7]);
      expect(
        SecretBytes.random(32).toList(),
        isNot(SecretBytes.random(32).toList()),
      );
    });

    test('constant-time equality + no hashCode', () {
      expect(SecretBytes([1, 2]), SecretBytes([1, 2]));
      expect(SecretBytes([1, 2]), isNot(SecretBytes([1, 3])));
      expect(() => SecretBytes([1]).hashCode, throwsA(isA<BuError>()));
    });

    test('splitAt/consume + takeBytes consume', () {
      final s = SecretBytes(List<int>.generate(64, (i) => i));
      final (l, r) = s.splitAt(32, consume: true);
      expect(s.isZeroed, isTrue);
      expect(l.toList(), List<int>.generate(32, (i) => i));
      expect(r.toList(), List<int>.generate(32, (i) => i + 32));
      final t = SecretBytes([9, 9]);
      final owned = t.takeBytes();
      expect(t.isZeroed, isTrue);
      expect(owned.toList(), [9, 9]);
    });

    test('NoneTransform stores plain; XorTransform default', () {
      final s = SecretBytes([1, 2], transform: const NoneTransform());
      expect(s.transform, isA<NoneTransform>());
      expect(s.toList(), [1, 2]);
      final x = SecretBytes([1, 2]);
      expect(x.transform, isA<XorTransform>());
    });
  });
}

/// Standalone entry: `dart test test/unit/bytes_test.dart` (pure Dart).
void main() => runBytesUnitSuite();
