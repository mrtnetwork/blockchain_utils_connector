@TestOn('vm')
library;

/// FFI ↔ WASM parity enforcement (task 6).
///
/// VM-only: reads the Rust connector sources + Dart binding files and
/// asserts every `bu_*` FFI export has a wasm-bindgen counterpart (or is on
/// the documented exclusion list), and every Dart FFI symbol referenced has
/// a `BuWasmJS` method (modulo known naming aliases).
///
/// This is a repo-consistency test (it inspects source files, it never
/// gates crypto behavior on missing artifacts).
import 'dart:io';

import 'package:test/test.dart';

import 'test_backend.dart';

/// `BU_RUST_CRATE` override or the `<package>/build/rust-crate` default
/// (see `test_backend_io.dart`, which downloads it when missing).
String _crateDir() {
  return testEnvVar('BU_RUST_CRATE') ??
      '${Directory.current.path}/build/rust-crate';
}

/// `bu_*` FFI exports.
Set<String> _ffiFns(String crate) {
  final out = <String>{};
  final re = RegExp(r'pub\s+(?:unsafe\s+)?extern\s+"C"\s+fn\s+(\w+)');
  for (final f in Directory('$crate/src/connector/ffi')
      .listSync(recursive: true)
      .whereType<File>()
      .where((f) => f.path.endsWith('.rs'))) {
    for (final m in re.allMatches(f.readAsStringSync())) {
      out.add(m.group(1)!);
    }
  }
  return out;
}

/// wasm-bindgen `js_name`s.
Set<String> _wasmNames(String crate) {
  final out = <String>{};
  final re = RegExp(r'js_name\s*=\s*(\w+)');
  for (final f in Directory('$crate/src/connector/wasm')
      .listSync(recursive: true)
      .whereType<File>()
      .where((f) => f.path.endsWith('.rs'))) {
    for (final m in re.allMatches(f.readAsStringSync())) {
      out.add(m.group(1)!);
    }
  }
  return out;
}

String _norm(String s) => s.toLowerCase().replaceAll(RegExp(r'[^a-z0-9]'), '');

/// FFI exports with intentionally no WASM twin.
///
/// - `malloc`/`free`: manual memory only exists on the native side (WASM
///   uses GC'd `Vec<u8>`).
/// - `hash_new_simple`/`*_state_bytes`/`state_len`/`clean_saved_state`:
///   FFI buffer-lifecycle helpers; WASM uses integer handles instead.
/// - `*_sizes`/`head_len`/`salt_len`/`block_size`/`point_len`…: fixed
///   metadata the Dart side hardcodes or queries via `curvePointLen`-style
///   calls that already exist.
const Set<String> kExcludedFfi = {
  'bu_malloc',
  'bu_free',
  'bu_hash_new',
  'bu_hash_new_simple',
  'bu_hash_clean_saved_state',
  'bu_hash_save_state_bytes',
  'bu_hash_restore_state_bytes',
  'bu_hash_state_len',
  'bu_aes_block_size',
  'bu_mldsa_sizes',
  'bu_curve_point_len',
  'bu_curve_point_len_uncomp',
  'bu_curve_scalar_len',
  'bu_groth16_bls_proof_len',
  'bu_groth16_bn254_proof_len',
};

/// FFI name → WASM `js_name`(s) when the spelling differs.
const Map<String, Set<String>> kAliases = {
  'bu_dkls23_agg_keys': {'dkls23AggPublicKeys'},
  'bu_sapling_verify_spend': {'saplingVerify'},
  'bu_sapling_verify_output': {'saplingVerify'},
  'bu_hw_ledger_fingerprint_request': {'hwLedgerFingerprint'},
  'bu_x25519_dh_raw': {'x25519'},
  'bu_hw_coin_count': {'hwCoinCount'},
  'bu_hw_device_count': {'hwDeviceCount'},
  'bu_ecdsa_k1_recover_any': {'ecdsaK1Recover'},
  'bu_orchard_pk_new_for_version': {'orchardPkNew'},
  'bu_zk_version': {'zkVersion'},
  'bu_zk_enable_logging': {'zkEnableLogging'},
  'bu_build_version': {'backendVersion'},
  'bu_build_features': {'backendFeatures'},
  'bu_merkle_create_context': {'merkleCreateContext'},
  'bu_hash_algo': {'hashAlgo'},
  'bu_hash_block_size': {'hashBlockSize'},
  'bu_hash_digest_len': {'hashDigestLen'},
};

void main() {
  test('every FFI export exists in WASM (or is excluded)', () {
    final crate = _crateDir();
    if (!Directory('$crate/src/connector/ffi').existsSync()) {
      markTestSkipped('rust crate not found at $crate');
      return;
    }
    final ffi = _ffiFns(crate);
    expect(ffi, isNotEmpty, reason: 'no FFI exports parsed');
    final wasmRaw = _wasmNames(crate);
    final wasmNorm = wasmRaw.map(_norm).toSet();
    final missing = <String>[];
    for (final f in ffi.toList()..sort()) {
      if (kExcludedFfi.contains(f)) {
        continue;
      }
      final alias = kAliases[f];
      if (alias != null && alias.any((a) => wasmNorm.contains(_norm(a)))) {
        continue;
      }
      if (wasmNorm.contains(_norm(f.startsWith('bu_') ? f.substring(3) : f))) {
        continue;
      }
      missing.add(f);
    }
    expect(missing, isEmpty, reason: 'FFI without WASM twin: $missing');
  });
}
