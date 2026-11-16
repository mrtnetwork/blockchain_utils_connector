import 'package:blockchain_utils_connector/src/api/aead_api.dart';
import 'package:blockchain_utils_connector/src/api/block_cipher_api.dart';
import 'package:blockchain_utils_connector/src/api/bls_signing_api.dart';
import 'package:blockchain_utils_connector/src/api/curve_api.dart';
import 'package:blockchain_utils_connector/src/api/ed25519_signing_api.dart';
import 'package:blockchain_utils_connector/src/api/mldsa_signing_api.dart';
import 'package:blockchain_utils_connector/src/api/reddsa_signing_api.dart';
import 'package:blockchain_utils_connector/src/api/groth16_api.dart';
import 'package:blockchain_utils_connector/src/api/hash_api.dart';
import 'package:blockchain_utils_connector/src/api/merkle_api.dart';
import 'package:blockchain_utils_connector/src/api/monero_api.dart';
import 'package:blockchain_utils_connector/src/api/solana_zk_api.dart';
import 'package:blockchain_utils_connector/src/api/transcript_api.dart';
import 'package:blockchain_utils_connector/src/api/orchard_api.dart';
import 'package:blockchain_utils_connector/src/api/hw_api.dart';
import 'package:blockchain_utils_connector/src/api/rng_api.dart';
import 'package:blockchain_utils_connector/src/api/sapling_api.dart';
import 'package:blockchain_utils_connector/src/api/zk_api.dart';
import 'package:blockchain_utils_connector/src/api/musig2_api.dart';
import 'package:blockchain_utils_connector/src/api/dkls23_api.dart';
import 'package:blockchain_utils_connector/src/api/frost_api.dart';
import 'package:blockchain_utils_connector/src/api/secp256k1_signing_api.dart';
import 'package:blockchain_utils_connector/src/api/secp256r1_signing_api.dart';
import 'package:blockchain_utils_connector/src/api/stream_cipher_api.dart';
import 'package:blockchain_utils_connector/src/default/default_aead_api.dart';
import 'package:blockchain_utils_connector/src/default/default_block_cipher_api.dart';
import 'package:blockchain_utils_connector/src/default/default_bls_signing_api.dart';
import 'package:blockchain_utils_connector/src/default/default_curve_api.dart';
import 'package:blockchain_utils_connector/src/default/default_ed25519_signing_api.dart';
import 'package:blockchain_utils_connector/src/default/default_mldsa_signing_api.dart';
import 'package:blockchain_utils_connector/src/default/default_reddsa_signing_api.dart';
import 'package:blockchain_utils_connector/src/default/default_groth16_api.dart';
import 'package:blockchain_utils_connector/src/default/default_ff1_api.dart';
import 'package:blockchain_utils_connector/src/default/default_x25519_api.dart';
import 'package:blockchain_utils_connector/src/default/default_sr25519_signing_api.dart';
import 'package:blockchain_utils_connector/src/api/ff1_api.dart';
import 'package:blockchain_utils_connector/src/api/x25519_api.dart';
import 'package:blockchain_utils_connector/src/api/sr25519_signing_api.dart';
import 'package:blockchain_utils_connector/src/default/default_hash_api.dart';
import 'package:blockchain_utils_connector/src/default/default_merkle_api.dart';
import 'package:blockchain_utils_connector/src/default/default_monero_api.dart';
import 'package:blockchain_utils_connector/src/default/default_solana_zk_api.dart';
import 'package:blockchain_utils_connector/src/default/default_transcript_api.dart';
import 'package:blockchain_utils_connector/src/default/default_orchard_api.dart';
import 'package:blockchain_utils_connector/src/default/default_hw_api.dart';
import 'package:blockchain_utils_connector/src/default/default_rng_api.dart';
import 'package:blockchain_utils_connector/src/default/default_sapling_api.dart';
import 'package:blockchain_utils_connector/src/default/default_zk_api.dart';
import 'package:blockchain_utils_connector/src/default/default_musig2_api.dart';
import 'package:blockchain_utils_connector/src/default/default_dkls23_api.dart';
import 'package:blockchain_utils_connector/src/default/default_frost_api.dart';
import 'package:blockchain_utils_connector/src/default/default_secp256k1_signing_api.dart';
import 'package:blockchain_utils_connector/src/default/default_secp256r1_signing_api.dart';
import 'package:blockchain_utils_connector/src/default/default_stream_cipher_api.dart';
import 'package:blockchain_utils_connector/src/platform/bindings.dart';
import 'package:blockchain_utils_connector/src/connector/bu_config.dart';
import 'package:blockchain_utils_connector/src/connector/bu_features.dart';
import 'package:blockchain_utils_connector/src/connector/platform_open_stub.dart'
    if (dart.library.io) 'package:blockchain_utils_connector/src/connector/platform_open_io.dart'
    if (dart.library.js_interop) 'package:blockchain_utils_connector/src/connector/platform_open_web.dart';

export 'bu_config.dart';
export 'bu_features.dart';

class Bu {
  Bu._(this.bindings)
    : hash = DefaultHashApi(bindings),
      aead = DefaultAeadApi(bindings),
      blockCipher = DefaultBlockCipherApi(bindings),
      streamCipher = DefaultStreamCipherApi(bindings),
      curves = DefaultCurvesApi(bindings),
      secp256k1Signing = DefaultSecp256k1SigningApi(bindings),
      secp256r1Signing = DefaultSecp256r1SigningApi(bindings),
      blsSigning = DefaultBlsSigningApi(bindings),
      musig2 = DefaultMusig2Api(bindings),
      dkls23 = DefaultDkls23Api(bindings),
      frost = DefaultFrostApi(bindings),
      ed25519Signing = DefaultEd25519SigningApi(bindings),
      mlDsa = DefaultMlDsaSigningApi(bindings),
      reddsa = DefaultReddsaSigningApi(bindings),
      groth16 = DefaultGroth16Api(bindings),
      ff1 = DefaultFf1Api(bindings),
      x25519 = DefaultX25519Api(bindings),
      sr25519 = DefaultSr25519SigningApi(bindings),
      rng = DefaultRngApi(bindings),
      hw = DefaultHwApi(bindings),
      sapling = DefaultSaplingApi(bindings),
      orchard = DefaultOrchardApi(bindings),
      merkle = DefaultMerkleApi(bindings),
      monero = DefaultMoneroApi(bindings),
      solanaZk = DefaultSolanaZkApi(bindings),
      transcripts = DefaultTranscriptApi(bindings),
      zk = DefaultZkApi(bindings);

  final BuPlatformBindings bindings;
  final BuHashApi hash;
  final BuAeadApi aead;
  final BuBlockCipherApi blockCipher;
  final BuStreamCipherApi streamCipher;
  final BuCurvesApi curves;
  final BuSecp256k1SigningApi secp256k1Signing;
  final BuSecp256r1SigningApi secp256r1Signing;
  final BuBlsSigningApi blsSigning;
  final BuMusig2Api musig2;
  final BuDkls23Api dkls23;
  final BuFrostApi frost;
  final BuEd25519SigningApi ed25519Signing;
  final BuMlDsaSigningApi mlDsa;
  final BuReddsaSigningApi reddsa;
  final BuGroth16Api groth16;
  final BuFf1Api ff1;
  final BuX25519Api x25519;
  final BuSr25519SigningApi sr25519;
  final BuRngApi rng;
  final BuHwApi hw;
  final BuSaplingApi sapling;
  final BuOrchardApi orchard;
  final BuMerkleApi merkle;
  final BuMoneroApi monero;
  final BuSolanaZkApi solanaZk;
  final BuTranscriptApi transcripts;
  final BuZkApi zk;

  /// Runtime description of the attached backend artifact.
  ///
  /// Queries `bu_build_version` / `bu_build_features` (FFI) or
  /// `backendVersion` / `backendFeatures` (WASM) and reports which Cargo
  /// features the loaded `.so` / `.wasm` was compiled with, so callers can
  /// gate on e.g. [BuBuildFeature.solanaZk] instead of probing blindly.
  /// Backends predating build introspection report version `0` / no features.
  BuBackendInfo get backendInfo => BuBackendInfo(
    kind: bindings.backendKind,
    interfaceVersion: bindings.backendVersion(),
    features: bindings.backendFeatures(),
  );

  /// Creates the single backend instance for this [Bu].
  ///
  /// There is no global: every `init` call opens the backend described by
  /// [config] and returns its own instance. Hold the result and pass it to
  /// whoever needs native access — never store it in a static.
  static Bu init([BuConfig config = const BuConfig()]) {
    return Bu._(openPlatformBindings(config));
  }

  /// Loads the WASM module described by [config] (web only: injects the
  /// glue script and awaits bootstrap). Await before [init] when the page
  /// did not preload the glue via `<script>` tags. Throws [UnsupportedError]
  /// on native targets.
  static Future<void> ensureWasmLoaded([BuConfig config = const BuConfig()]) {
    return ensurePlatformWasmLoaded(config);
  }
}
