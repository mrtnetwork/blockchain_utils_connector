import 'package:blockchain_utils_connector/blockchain_utils_connector.dart';
import 'package:test/test.dart';

import '../test_utils.dart';

/// Allocates and drops garbage to encourage GC (and finalizer) runs.
/// Finalization timing is best-effort — this only raises the odds.
Future<void> _gcPressure() async {
  for (var i = 0; i < 10; i++) {
    List<int>.filled(100000, i);
  }
  await Future<void>.delayed(Duration.zero);
}

/// Finalizer safety: forgetting `clean`/`zero` must free natively on GC
/// without a double-free or use-after-free crash — on both backends.
/// A native fault would kill the test runner (non-zero exit), so every
/// passing test below is evidence the protocol holds.
void runFinalizerSuite(Bu Function() openBu) {
  group('finalizer safety (forgotten clean must not crash)', () {
    test('hash contexts freed by GC stay usable afterwards', () async {
      final bu = openBu();
      for (var i = 0; i < 500; i++) {
        final h = bu.hash.sha256().unwrapOrThrow();
        h.update([i & 0xff]);
        h.digest();
        // Deliberately no clean(): the Finalizer owns it now.
        if (i % 100 == 0) await _gcPressure();
      }
      await _gcPressure();
      final h = bu.hash.sha256().unwrapOrThrow();
      try {
        h.update([1, 2, 3]);
        expect(h.digest().length, 32);
      } finally {
        h.clean();
      }
    });

    test('aes contexts freed by GC stay usable afterwards', () async {
      final bu = openBu();
      final key = BuBytes(List<int>.filled(32, 7));
      try {
        for (var i = 0; i < 500; i++) {
          final c = bu.blockCipher.aes(key).unwrapOrThrow();
          c.encryptBlock(List<int>.filled(16, i & 0xff));
          if (i % 100 == 0) await _gcPressure();
        }
        await _gcPressure();
        final c = bu.blockCipher.aes(key).unwrapOrThrow();
        try {
          expect(c.encryptBlock(List<int>.filled(16, 0)).length, 16);
        } finally {
          c.clean();
        }
      } finally {
        key.zero();
      }
    });

    test('transcripts freed by GC stay usable afterwards', () async {
      final bu = openBu();
      final m = bu.transcripts.merlin(label: [1, 2, 3]);
      if (m.isErr) {
        markTestSkipped('merlin unsupported: $m');
        return;
      }
      for (var i = 0; i < 200; i++) {
        final t = bu.transcripts.merlin(label: [i & 0xff]).unwrapOrThrow();
        t.append(label: [9], message: [i & 0xff]);
        t.challenge(label: [9], length: 32);
        if (i % 50 == 0) await _gcPressure();
      }
      final s = bu.transcripts.strobe(protocol: [4, 5]);
      if (s.isErr) {
        markTestSkipped('strobe unsupported: $s');
        return;
      }
      for (var i = 0; i < 200; i++) {
        final t = bu.transcripts.strobe(protocol: [i & 0xff]).unwrapOrThrow();
        t.prf(32);
        if (i % 50 == 0) await _gcPressure();
      }
      await _gcPressure();
      final t = bu.transcripts.merlin(label: [7]).unwrapOrThrow();
      try {
        expect(t.challenge(label: [7], length: 16).length, 16);
      } finally {
        t.clean();
      }
    });

    test('saved snapshots freed by GC stay usable afterwards', () async {
      final bu = openBu();
      final h = bu.hash.sha256().unwrapOrThrow();
      try {
        for (var i = 0; i < 200; i++) {
          h.update([i & 0xff]);
          h.saveState(); // Deliberately never cleaned.
          if (i % 50 == 0) await _gcPressure();
        }
        await _gcPressure();
        final snap = h.saveState();
        h.update([0xff]);
        h.restoreState(snap);
        h.cleanSavedState(snap);
      } finally {
        h.clean();
      }
    });

    test('unzeroed secrets wiped by GC stay usable afterwards', () async {
      for (var i = 0; i < 500; i++) {
        SecretBytes.random(32); // Deliberately never zeroed.
        if (i % 100 == 0) await _gcPressure();
      }
      await _gcPressure();
      final s = SecretBytes.random(16);
      try {
        expect(s.length, 16);
      } finally {
        s.zero();
      }
      expect(s.isZeroed, isTrue);
    });

    test('double clean is idempotent (no double free)', () {
      final bu = openBu();
      final h = bu.hash.sha256().unwrapOrThrow();
      h.clean();
      h.clean();
      expect(() => h.update([1]), throwsA(isA<BuError>()));
      expect(() => h.digest(), throwsA(isA<BuError>()));
      final m = bu.transcripts.merlin(label: [1]);
      if (m.isOk) {
        m.value!.clean();
        m.value!.clean();
      }
      final snapH = bu.hash.sha256().unwrapOrThrow();
      try {
        final snap = snapH.saveState();
        snapH.cleanSavedState(snap);
        snapH.cleanSavedState(snap);
        expect(() => snapH.restoreState(snap), throwsA(isA<BuError>()));
      } finally {
        snapH.clean();
      }
    });
  });
}

/// Standalone entry: `dart test test/backend/finalizer_test.dart` (VM, FFI backend).
void main() async {
  await ConnectorTestApi.ensureBackend();
  runFinalizerSuite(() => ConnectorTestApi.bu);
}
