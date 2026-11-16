import 'package:blockchain_utils_connector/blockchain_utils_connector.dart';
import 'package:test/test.dart';

import '../test_utils.dart';

/// Elliptic curves: pinned generator vectors, group laws, compress/uncompress
/// roundtrips, scalar arithmetic, and hash-to-curve determinism.
///
/// Runs on FFI and WASM. All scalars/points are inline literals — no files.
void runCurveSuite(Bu Function() openBu) {
  String hx(List<int> b) =>
      b.map((e) => e.toRadixString(16).padLeft(2, '0')).join();

  group('curves', () {
    test('secp256k1 G vector + group laws', () {
      final bu = openBu();
      final k1 = bu.curves.secp256k1();
      final g = k1.multBase(List<int>.filled(31, 0) + [1]).unwrapOrThrow();
      expect(
        hx(g),
        '0279be667ef9dcbbac55a06295ce870b07029bfcdb2dce28d959f2815b16f81798',
      );
      // 2*G via add(G, G) == multBase(2).
      final two = k1.add(g, g).unwrapOrThrow();
      expect(
        hx(two),
        hx(k1.multBase(List<int>.filled(31, 0) + [2]).unwrapOrThrow()),
      );
      // G - G == identity; identity + G == G.
      final id = k1.sub(g, g).unwrapOrThrow();
      expect(hx(id), hx(k1.identity().unwrapOrThrow()));
      expect(hx(k1.add(id, g).unwrapOrThrow()), hx(g));
      expect(hx(k1.neg(g).unwrapOrThrow()), isNot(hx(g)));
      // scalar field: 1 + 1 == 2, 2 - 1 == 1, 3 * 4 == 12 (order n).
      BuBytes sc(int v) => BuBytes(List<int>.filled(31, 0) + [v]);
      expect(hx(k1.scAdd(sc(1), sc(1)).unwrapOrThrow()), hx(sc(2)));
      expect(hx(k1.scSub(sc(2), sc(1)).unwrapOrThrow()), hx(sc(1)));
      expect(hx(k1.scMul(sc(3), sc(4)).unwrapOrThrow()), hx(sc(12)));
      expect(hx(k1.scNeg(sc(1)).unwrapOrThrow()), isNot(hx(sc(1))));
      expect(k1.scCheck(sc(1)), isTrue);
    });

    test('secp256r1/ed25519 generator determinism + compress roundtrip', () {
      final bu = openBu();
      for (final c in [bu.curves.secp256r1(), bu.curves.ed25519()]) {
        final g1 = c.multBase(List<int>.filled(31, 0) + [1]).unwrapOrThrow();
        final g2 = c.multBase(List<int>.filled(31, 0) + [1]).unwrapOrThrow();
        expect(g1, g2);
        // Already-compressed input re-encodes identically.
        final comp = c.compress(g1).unwrapOrThrow();
        expect(comp, g1);
        // Uncompressed form round-trips back to the canonical encoding.
        final uncomp = c.uncompress(g1).unwrapOrThrow();
        expect(c.compress(uncomp).unwrapOrThrow(), g1);
        expect(c.normalizePublicKey(g1).unwrapOrThrow(), g1);
        expect(c.normalizePublicKey(uncomp).unwrapOrThrow(), g1);
      }
    });

    test('ed25519 helpers: scReduce + checkKey + hashToEc', () {
      final bu = openBu();
      final ed = bu.curves.ed25519();
      final r = ed.scReduce64(List<int>.filled(64, 1)).unwrapOrThrow();
      expect(r, hasLength(32));
      final g = ed.multBase(List<int>.filled(31, 0) + [1]).unwrapOrThrow();
      expect(ed.checkKey(g), isTrue);
      // All-zero decodes to the order-2 point (y=0): valid encoding,
      // but normalizePublicKey rejects infinity-adjacent/wrong forms only.
      expect(ed.checkKey(List<int>.filled(32, 0)), isTrue);
      // Wrong length is not a key.
      expect(ed.checkKey(List<int>.filled(33, 1)), isFalse);
      final h1 = ed.hashToEc([1, 2, 3]).unwrapOrThrow();
      expect(h1, hasLength(32));
      expect(hx(h1), hx(ed.hashToEc([1, 2, 3]).unwrapOrThrow()));
    });

    test('ristretto/jubjub/pallas/vesta roundtrips', () {
      final bu = openBu();
      final r =
          bu.curves
              .ristretto()
              .multBase(List<int>.filled(31, 0) + [1])
              .unwrapOrThrow();
      expect(r, hasLength(32));
      for (final c in [bu.curves.pallas(), bu.curves.vesta()]) {
        final g = c.multBase(List<int>.filled(31, 0) + [1]).unwrapOrThrow();
        expect(c.compress(g).unwrapOrThrow(), hasLength(32));
      }
      final h1 =
          bu.curves
              .pallas()
              .hashToCurvePasta([9, 9], personal: [1])
              .unwrapOrThrow();
      expect(
        hx(h1),
        hx(
          bu.curves
              .pallas()
              .hashToCurvePasta([9, 9], personal: [1])
              .unwrapOrThrow(),
        ),
      );
    });

    test('generateSecret is 32 bytes and deterministic', () {
      final bu = openBu();
      BuBytes gen(List<int> seed) {
        final out = BuBytes.zero(32);
        expect(
          bu.bindings.curveGenerateSecret(
            BuCurveId.secp256k1,
            BuBytes(seed),
            out,
          ),
          0,
        );
        return out;
      }

      expect(
        hx(gen(List<int>.filled(16, 3))),
        '6399f6d863b08f4652b342c2e1350b4c01e291332d9d84d84b575bf7272897d2',
      );
      expect(
        hx(gen(List<int>.filled(16, 3))),
        hx(gen(List<int>.filled(16, 3))),
      );
      expect(
        hx(gen(List<int>.filled(16, 3))),
        isNot(hx(gen(List<int>.filled(16, 4)))),
      );
      expect(
        bu.bindings.curveGenerateSecret(
          BuCurveId.secp256k1,
          BuBytes([]),
          BuBytes.zero(32),
        ),
        isNot(0),
      );
    });

    test('isInfinity: identity yes, generator no', () {
      final bu = openBu();
      final k1 = bu.curves.secp256k1();
      final g = k1.multBase(List<int>.filled(31, 0) + [1]).unwrapOrThrow();
      final id = k1.sub(g, g).unwrapOrThrow();
      expect(bu.bindings.curveIsInfinity(BuCurveId.secp256k1, id), 1);
      expect(bu.bindings.curveIsInfinity(BuCurveId.secp256k1, g), 0);
    });
  });
}

/// Standalone entry: `dart test test/backend/curve_test.dart` (VM, FFI backend).
void main() async {
  await ConnectorTestApi.ensureBackend();
  runCurveSuite(() => ConnectorTestApi.bu);
}
