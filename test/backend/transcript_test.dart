import 'package:blockchain_utils_connector/blockchain_utils_connector.dart';
import 'package:test/test.dart';

import '../test_utils.dart';

/// Merlin transcripts + Strobe contexts: determinism, fork equality,
/// domain separation, and pinned oracles.
///
/// Runs on FFI and WASM. All labels/messages are inline literals — no files.
void runTranscriptSuite(Bu Function() openBu) {
  String hx(List<int> b) =>
      b.map((e) => e.toRadixString(16).padLeft(2, '0')).join();

  group('merlin', () {
    test('challenge determinism + fork equality + pinned vector', () {
      final bu = openBu();
      BuBytes run() {
        final m =
            bu.transcripts
                .merlin(label: [77, 69, 82, 76, 73, 78])
                .unwrapOrThrow();
        try {
          m.append(label: [1], message: [2, 3]);
          return m.challenge(label: [9], length: 64);
        } finally {
          m.clean();
        }
      }

      final c1 = run();
      expect(hx(c1), hx(run())); // deterministic
      expect(
        hx(c1),
        '2efecd2289a644a2ea67a59d13a6a8edb9488313e58cc5aab3e37c49c436263b'
        '16aacb43afb557e2f0745c84edb8e902b5b71e6dc5fe68ddf94063b528f005a9',
      );
      // Fork before challenging: identical challenges afterwards.
      final m = bu.transcripts.merlin(label: [77]).unwrapOrThrow();
      try {
        m.append(label: [1], message: [2]);
        final f = m.fork();
        try {
          expect(
            hx(f.challenge(label: [9], length: 32)),
            hx(m.challenge(label: [9], length: 32)),
          );
        } finally {
          f.clean();
        }
        // Diverged after use: next challenge differs.
        expect(
          hx(m.challenge(label: [9], length: 32)),
          isNot(hx(c1.sublist(0, 32))),
        );
      } finally {
        m.clean();
      }
      expect(() {
        final dead = bu.transcripts.merlin(label: [1]).unwrapOrThrow();
        dead.clean();
        dead.clean(); // idempotent
        dead.append(label: [1], message: [2]);
      }, throwsA(isA<BuError>()));
    });
  });

  group('strobe', () {
    test('key/ad/prf determinism + pinned vector + domain separation', () {
      final bu = openBu();
      BuBytes run(List<int> proto) {
        final s = bu.transcripts.strobe(protocol: proto).unwrapOrThrow();
        try {
          s.key([4, 5]);
          s.ad([6, 7]);
          return s.prf(64);
        } finally {
          s.clean();
        }
      }

      expect(hx(run([83, 84, 82])), hx(run([83, 84, 82])));
      expect(
        hx(run([83, 84, 82])),
        'bdb813cf3292ce4749cec350a4d67c3f8ee8987861883a39b645801cc73f3ec1'
        'c376f07dad0331aaa5967c25aa56ef03e1f6c82d70e812d4e99c1ff686dfe8a4',
      );
      expect(hx(run([83, 84, 82])), isNot(hx(run([83, 84, 83]))));
      expect(
        () => bu.transcripts.strobe(protocol: [1]).unwrapOrThrow().prf(0),
        throwsA(isA<BuError>()),
      );
    });
  });
}

/// Standalone entry: `dart test test/backend/transcript_test.dart` (VM, FFI backend).
void main() async {
  await ConnectorTestApi.ensureBackend();
  runTranscriptSuite(() => ConnectorTestApi.bu);
}
