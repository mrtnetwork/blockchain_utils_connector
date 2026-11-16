import 'package:blockchain_utils_connector/blockchain_utils_connector.dart';

import 'backend/aead_test.dart';
import 'backend/bls_test.dart';
import 'backend/cipher_test.dart';
import 'backend/curve_test.dart';
import 'backend/dkls23_test.dart';
import 'backend/ff1_x25519_test.dart';
import 'backend/frost_test.dart';
import 'backend/finalizer_test.dart';
import 'backend/hash_test.dart';
import 'backend/hw_bitbox_test.dart';
import 'backend/hw_sign_test.dart';
import 'backend/kdf_rng_test.dart';
import 'backend/monero_test.dart';
import 'backend/musig2_test.dart';
import 'backend/pq_test.dart';
import 'backend/proving_test.dart';
import 'backend/signing_test.dart';
import 'backend/solana_zk_test.dart';
import 'backend/transcript_test.dart';
import 'backend/zcash_hashes_test.dart';

/// Shared FFI/WASM suite: every backend test in one place.
///
/// [openBu] returns the backend under test (VM: FFI via
/// `ConnectorTestApi.bu`; browser: WASM via `initWasmBrowser`).
/// All suites use inline literals only — no files, no skips.
void runBackendSuite(Bu Function() openBu) {
  runHashSuite(openBu);
  runKdfRngSuite(openBu);
  runAeadSuite(openBu);
  runCipherSuite(openBu);
  runCurveSuite(openBu);
  runSigningSuite(openBu);
  runBlsSuite(openBu);
  runMusig2Suite(openBu);
  runDkls23Suite(openBu);
  runFrostSuite(openBu);
  runFinalizerSuite(openBu);
  runPqSuite(openBu);
  runFf1X25519Suite(openBu);
  runZcashHashesSuite(openBu);
  runProvingSuite(openBu);
  runMoneroSuite(openBu);
  runSolanaZkSuite(openBu);
  runTranscriptSuite(openBu);
  runHwBitboxSuite(openBu);
  runHwSignSuite(openBu);
}
