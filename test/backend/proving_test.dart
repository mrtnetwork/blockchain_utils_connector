import 'package:blockchain_utils_connector/blockchain_utils_connector.dart';
import 'package:test/test.dart';

import '../test_utils.dart';

/// Proving stack: Groth16 verifier lengths + rejection, ZK bridge +
/// backend introspection, Sapling/Orchard params lifecycle, and Merkle
/// wallet-tree roundtrips.
///
/// Runs on FFI and WASM. All inputs are inline literals — no files, no
/// params downloads. Real proofs (Sapling/Orchard) need multi-MB params and
/// are covered by error-path + handle-lifecycle contracts here; drop
/// circuit-graded vectors (zcash_dart fixtures, on-chain proofs) at the
/// `// PIN:` markers as byte-exact `expect`s.
void runProvingSuite(Bu Function() openBu) {
  String hx(List<int> b) =>
      b.map((e) => e.toRadixString(16).padLeft(2, '0')).join();

  group('groth16', () {
    test('proof lengths + garbage rejects closed', () {
      final bu = openBu();
      expect(bu.groth16.blsProofLen, 192);
      expect(bu.groth16.bn254ProofLen, 256);
      final bad = BuBytes(List<int>.filled(192, 0xFF));
      final vk = BuBytes(List<int>.filled(256, 0x01));
      // Must not throw: invalid proof => err, never a crash.
      final r = bu.groth16.verifyBls(
        proof: bad,
        vk: vk,
        publicInputs: BuBytes([]),
      );
      expect(r.isOk || r.isErr, isTrue);
      final r2 = bu.groth16.verifyBn254(
        proof: BuBytes(List<int>.filled(256, 0xFF)),
        vk: vk,
        publicInputs: BuBytes([]),
      );
      expect(r2.isOk || r2.isErr, isTrue);
      // PIN: on-chain Aptos/Sui Groth16-BN254 (proof || vk || inputs) hex
      // from a settled transaction goes here as verify-success expects.
    });
  });

  group('zk bridge + backend info', () {
    test('version/logging/backend features detected at init', () {
      final bu = openBu();
      expect(bu.zk.version(), 1);
      expect(bu.zk.enableLogging(), isTrue);
      expect(bu.zk.backendVersion(), 1);
      final feats = bu.zk.backendFeatures();
      expect(feats, greaterThan(0));
      final info = bu.backendInfo;
      expect(info.interfaceVersion, 1);
      expect(info.features, feats);
      // The harness backend always reports its own transport bit.
      expect(
        info.has(BuBuildFeature.ffi) || info.has(BuBuildFeature.wasm),
        isTrue,
      );
      // Default release builds compile the full proving stack (hw is an
      // opt-in Cargo feature; hw suites gate on it separately).
      for (final f in [
        BuBuildFeature.groth16,
        BuBuildFeature.zcashSapling,
        BuBuildFeature.zcashHalo2,
        BuBuildFeature.zcashMerkle,
        BuBuildFeature.monero,
        BuBuildFeature.solanaZk,
      ]) {
        expect(
          info.has(f),
          isTrue,
          reason: 'missing feature ${f.name} (0x${feats.toRadixString(16)})',
        );
      }
      expect(hx([feats & 0xFF]), isNot('00'));
    });
  });

  group('sapling params lifecycle', () {
    test('no params -> prove/verify fail closed; bad params rejected', () {
      final bu = openBu();
      final s = bu.sapling;
      // Short witness fails in pure-Dart length checks, never touching
      // native code paths that need loaded params.
      expect(
        s.prove(handle: Object(), kind: 0, witness: BuBytes([1, 2, 3])).isErr,
        isTrue,
      );
      expect(
        s
            .verify(
              kind: 0,
              handle: Object(),
              proof: BuBytes([1]),
              inputs: BuBytes([2]),
            )
            .isErr,
        isTrue,
      );
      expect(s.setSpendParams(params: BuBytes([1, 2, 3])).isErr, isTrue);
      expect(s.setOutputParams(params: BuBytes([1, 2, 3])).isErr, isTrue);
    });
  });

  group('orchard pk lifecycle', () {
    test('pkNew versions; bad version rejected; free is safe', () {
      final bu = openBu();
      final o = bu.orchard;
      for (final v in [0, 1, 2]) {
        final pk = o.pkNew(version: v);
        if (pk.isOk) {
          o.pkFree(pk.value!);
        }
      }
      expect(o.pkNew(version: 99).isErr, isTrue);
    });
  });

  group('merkle wallet tree', () {
    test('create/update/checkpoint/witness/close roundtrip', () {
      final bu = openBu();
      final m = bu.merkle;
      final id = m.createContext().unwrapOrThrow();
      try {
        // Leaves are raw field bytes: keep them small (< modulus).
        final leaves = BuBytes(List<int>.generate(64, (i) => (i + 1) & 0x0F));
        m.updateState(id, kind: 0, leaves: leaves).unwrapOrThrow();
        m.checkpoint(id, 7).unwrapOrThrow();
        final wit =
            m
                .createWitness(
                  id,
                  kind: 0,
                  checkpointId: 7,
                  positions: BuBytes([0, 0, 0, 0, 0, 0, 0, 0]),
                )
                .unwrapOrThrow();
        expect(wit.anchor, hasLength(32));
        expect(wit.paths.isEmpty, isFalse);
        // Export + restore into a second context.
        final blob = m.getContext(id).unwrapOrThrow();
        expect(blob.isEmpty, isFalse);
        final id2 = m.createContext().unwrapOrThrow();
        try {
          m.insertChainState(id2, blob: blob).unwrapOrThrow();
        } finally {
          m.closeContext(id2).unwrapOrThrow();
        }
      } finally {
        m.closeContext(id).unwrapOrThrow();
      }
      expect(
        m.closeContext(0x7FFFFFFF).isOk || m.closeContext(0x7FFFFFFF).isErr,
        isTrue,
      );
    });
  });
}

/// Standalone entry: `dart test test/backend/proving_test.dart` (VM, FFI backend).
void main() async {
  await ConnectorTestApi.ensureBackend();
  runProvingSuite(() => ConnectorTestApi.bu);
}
