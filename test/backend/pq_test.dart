import 'package:blockchain_utils_connector/blockchain_utils_connector.dart';
import 'package:test/test.dart';

import '../test_utils.dart';

/// Post-quantum signatures: ML-DSA keygen/sign/verify roundtrip
/// with fixed seeds, plus tamper-fails-closed. Inline literals only.
void runPqSuite(Bu Function() openBu) {
  group('mldsa-65', () {
    test('keygen/sign/verify + tamper (seeded)', () {
      final bu = openBu();
      final m = bu.mlDsa;
      final seed = BuBytes(List<int>.generate(32, (i) => i + 1));
      final keys = m.keygen(level: 65, seed: seed).unwrapOrThrow();
      final (pk, sk) = keys;
      expect(m.isValidPublicKey(pk.toList(), level: 65), isTrue);
      expect(m.isValidSecretKey(sk.toList(), level: 65), isTrue);
      expect(m.publicKeyFromSecret(sk: sk).unwrapOrThrow(), pk);
      final sig = m.sign(sk: sk, message: BuBytes([7, 7, 7])).unwrapOrThrow();
      expect(
        m
            .verify(pk: pk, message: BuBytes([7, 7, 7]), signature: sig)
            .unwrapOrThrow(),
        isTrue,
      );
      expect(
        m
            .verify(pk: pk, message: BuBytes([7, 7, 8]), signature: sig)
            .unwrapOrThrow(),
        isFalse,
      );
    });
  });
}

/// Standalone entry: `dart test test/backend/pq_test.dart` (VM, FFI backend).
void main() async {
  await ConnectorTestApi.ensureBackend();
  runPqSuite(() => ConnectorTestApi.bu);
}
