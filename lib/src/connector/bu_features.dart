/// Backend build introspection: which Cargo features the loaded `.so` /
/// `.wasm` was compiled with.
///
/// The bit layout mirrors `blockchain-utils/src/connector/mod.rs`
/// (`build_features()`); both the FFI (`bu_build_features`) and WASM
/// (`backendFeatures`) exports report the same bits, so one enum decodes
/// both backends. [Bu.backendInfo] queries the attached backend at runtime.
library;

/// Single Cargo feature compiled into the backend artifact.
enum BuBuildFeature {
  /// `std` (OS-backed; always on for FFI, on for WASM via wasm-bindgen).
  std(1 << 0),

  /// `alloc` (allocation-using APIs available).
  alloc(1 << 1),

  /// `ffi` (native C ABI present — always set on [BuBackendKind.ffi]).
  ffi(1 << 2),

  /// `wasm` (wasm-bindgen exports present — always set on [BuBackendKind.wasm]).
  wasm(1 << 3),

  /// `groth16` (Groth16 verifiers).
  groth16(1 << 4),

  /// `groth16-prover` (Groth16 proving machinery).
  groth16Prover(1 << 5),

  /// `poseidon-bn254` (circomlib-compatible BN254 Poseidon).
  poseidonBn254(1 << 6),

  /// `multicore` (parallel MSM/FFT for native proving).
  multicore(1 << 7),

  /// `solana-zk` (Solana confidential-transfer ZK).
  solanaZk(1 << 8),

  /// `orchard-halo2` (standalone Orchard Halo2 port).
  orchardHalo2(1 << 9),

  /// `zcash-sapling` (Sapling prove/verify).
  zcashSapling(1 << 10),

  /// `zcash-halo2` (Orchard prove/verify).
  zcashHalo2(1 << 11),

  /// `zcash-incrementalmerkle` (Frontier wallet trees).
  zcashMerkle(1 << 12),

  /// `hw` (hardware-wallet codecs).
  hw(1 << 13),

  /// `monero` (Bulletproofs+ prove/verify + output scanning).
  monero(1 << 14);

  /// Creates a feature with its [mask] bit.
  const BuBuildFeature(this.mask);

  /// Bit this feature occupies in the `bu_build_features` mask.
  final int mask;

  /// Whether [features] (a raw `bu_build_features` mask) has this bit set.
  bool isIn(int features) => (features & mask) != 0;

  /// Decodes every known feature present in [features].
  static Set<BuBuildFeature> decode(int features) =>
      BuBuildFeature.values.where((f) => f.isIn(features)).toSet();
}

/// Which transport the attached backend speaks.
enum BuBackendKind {
  /// Native dynamic library over `dart:ffi`.
  ffi,

  /// wasm-bindgen module over `dart:js_interop`.
  wasm,
}

/// Runtime description of the attached backend artifact.
class BuBackendInfo {
  /// Creates a description of the attached backend.
  const BuBackendInfo({
    required this.kind,
    required this.interfaceVersion,
    required this.features,
  });

  /// Transport of the attached backend.
  final BuBackendKind kind;

  /// `bu_build_version` / `backendVersion` (currently 1).
  final int interfaceVersion;

  /// Raw `bu_build_features` / `backendFeatures` bitmask.
  final int features;

  /// Whether the backend was compiled with [feature].
  bool has(BuBuildFeature feature) => feature.isIn(features);

  /// Every known feature the backend reports.
  Set<BuBuildFeature> get decoded => BuBuildFeature.decode(features);

  @override
  String toString() =>
      'BuBackendInfo(kind: ${kind.name}, version: $interfaceVersion, '
      'features: 0x${features.toRadixString(16)})';
}
