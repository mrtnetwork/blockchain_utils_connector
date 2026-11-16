# blockchain_utils_connector

Dart frontend for [`blockchain-utils`](https://github.com/mrtnetwork/blockchain-utils):
zero-dependency cryptographic and blockchain utilities implemented in Rust.
This package opens the backend — a native dynamic library over `dart:ffi`,
or a wasm-bindgen module over `dart:js_interop` — behind one interface
(`BuPlatformBindings`) with per-domain facades (`Bu.hash`, `Bu.aead`, …).

All cryptography runs in Rust. Dart holds opaque handles (`BuBytes`) and
never reimplements primitives.

## Features

| Domain | API |
| --- | --- |
| Hashing | SHA-1/2/3, MD4/5, RIPEMD, BLAKE2, Keccak/SHAKE, XOFs, HMAC, PBKDF2, Zcash Poseidon/Sinsemilla/Pedersen |
| AEAD | `Bu.aead` encrypt/decrypt for every supported cipher |
| Ciphers | block (`Bu.blockCipher`), stream (`Bu.streamCipher`), padding |
| KDF / HKDF | `BuKdf`, HKDF helpers |
| Curves | curve registry, point/scalar lengths (`Bu.curves`) |
| Signatures | ECDSA (secp256k1/secp256r1, incl. recovery), Schnorr (incl. BIP-340 aux/tweak, Bitcoin Cash), Ed25519, BLS, MuSig2, DKLs23, FROST, ML-DSA, RedDSA (Jubjub/Pallas), SR25519 |
| Key exchange | X25519 (`Bu.x25519`) |
| Format-preserving encryption | FF1 (`Bu.ff1`) |
| Zero knowledge | Groth16, BN254 Poseidon, Solana confidential-transfer ZK, Sapling/Orchard proving, Merkle contexts, Monero (Bulletproofs+, scan) |
| Transcripts | Merlin / Strobe (`Bu.transcripts`) |
| Hardware wallets | APDU / Trezor / UR / PSBT codecs, unified `BuHwApi` |
| RNG | `Bu.rng` backed by the native backend |

## Requirements

- Dart SDK `>=3.7.0 <4.0.0`.
- To **build** a backend from source: a Rust toolchain (`cargo`). The Rust
  sources are fetched automatically (see below); you never vendor them.
- To build the **WASM** backend additionally: the `wasm32-unknown-unknown`
  target and a `wasm-bindgen-cli` matching the crate's `wasm-bindgen`
  version (the test helper resolves it; CI pins it from `Cargo.toml`).

## Installation

```yaml
dependencies:
  blockchain_utils_connector:
    git:
      url: https://github.com/mrtnetwork/blockchain_utils_connector
```

then:

```sh
dart pub get
```

## Quick start

Native (FFI):

```dart
import 'package:blockchain_utils_connector/blockchain_utils_connector.dart';

void main() {
  final bu = Bu.init(); // FFI: $BU_LIB_PATH or platform default lookup
  final hasher = bu.hash.sha256().unwrapOrThrow();
  hasher.update([0x61, 0x62, 0x63]); // "abc"
  final digest = hasher.digest(); // 32 bytes
  assert(digest.length == 32);
  hasher.clean(); // explicit release (a Finalizer backs up forgetful callers)
}
```

Web (WASM):

```dart
await Bu.ensureWasmLoaded(const BuConfig(wasmGlueUrl: 'wasm_assets/bu.js'));
final bu = Bu.init(const BuConfig(wasmGlueUrl: 'wasm_assets/bu.js'));
```

`Bu.init` takes an optional `BuConfig`:

| Field | Platform | Meaning |
| --- | --- | --- |
| `libraryPath` | native | Absolute path to `libblockchain_utils.so`/`.dylib`/`.dll`. `null` = platform default lookup. Must be absolute (relative paths are a hijacking risk). |
| `librarySha256` | native | Expected SHA-256 hex of the file; verified before `dlopen`. Fails closed on mismatch. `null` = no verification. |
| `wasmGlueUrl` | web | wasm-bindgen glue script URL (default `wasm_assets/bu.js`). |
| `wasmModuleUrl` | web | `.wasm` module URL (`null` = auto-located next to the glue). |

## Backend introspection

`Bu.backendInfo` reports which Cargo features the loaded `.so`/`.wasm`
was compiled with, so callers gate on capability instead of probing:

```dart
if (bu.backendInfo.has(BuBuildFeature.solanaZk)) {
  // ... use Bu.solanaZk
}
```

Features include `groth16`, `zcashSapling`, `zcashOrchard`, `monero`, `hw`,
`solanaZk`, … (see `BuBuildFeature`).

## Building backends

```sh
dart tool/build_backends.dart --ffi [--profile debug|release]
  [--features hw] [--no-default-features]
dart tool/build_backends.dart --wasm [--profile release] [--force]
dart tool/build_backends.dart --all
```

- `--ffi` cargo-builds the shared library used by VM tests.
- `--features` / `--no-default-features` select the FFI cargo features
  (default `hw` + crate defaults; any combination still loads — optional
  domains report `unsupported`, see `test/ffi_load_test.dart`).
- `--wasm` builds the WASM module + `wasm-bindgen --target web` glue
  into `test/wasm_assets/` (`bu.js` + `bu_bg.wasm`).
- `--force` rebuilds WASM assets even when they already exist.

The Rust checkout resolves via `BU_RUST_CRATE`, else a managed
`<package>/build/rust-crate` directory, which is downloaded from
https://github.com/mrtnetwork/blockchain-utils on demand
(`--no-clone` disables that). The FFI build enables the default crate
features plus `hw`; the WASM build uses
`wasm,std,groth16,poseidon-bn254,zcash-full,monero,hw,solana-zk`.

## Testing

```sh
dart test                                        # VM, FFI (default release .so)
BU_BACKEND=ffi BU_BUILD=ffi dart test            # cargo-build the .so if missing
CHROME_EXECUTABLE=<chrome> dart test -p chrome test/browser_wasm_test.dart
```

Environment variables (see `test/test_backend.dart`):

| Variable | Meaning | Default |
| --- | --- | --- |
| `BU_BACKEND` | `ffi` (`rust`/`native` aliases) or `wasm` (`web`/`browser`/`chrome` aliases) | `ffi` |
| `BU_LIB_PATH` | explicit FFI library path | auto-resolved under the Rust crate target dir |
| `BU_FFI_PROFILE` | cargo profile used to resolve/build the FFI lib | `release` |
| `BU_FFI_FEATURES` | cargo features for FFI builds (combined with crate defaults) | `hw` |
| `BU_FFI_NO_DEFAULT_FEATURES` | `1` = pass `--no-default-features` to the FFI cargo build | off |
| `BU_BUILD` | `1`/`ffi`/`wasm`/`all` — build the backend with cargo when missing | off |
| `BU_RUST_CRATE` | Rust checkout location | `<package>/build/rust-crate` (downloaded on demand) |
| `CARGO_TARGET_DIR` | cargo target dir override | `<crate>/target` |
| `BU_WASM_GLUE_URL` | glue script URL (browser) | `wasm_assets/bu.js` |
| `BU_WASM_MODULE_URL` | `.wasm` module URL (browser) | auto-located next to the glue |
| `BU_EMU_LIVE` | `1` enables live hardware-emulator tests (needs reachable emulators) | off (skipped) |

Notes:

- `test/ffi_load_test.dart` (VM) locks the loading contract: whatever the
  lib was built with, `Bu.init` + `backendInfo` + core hash work and every
  optional domain fails closed (`BuError`, never a crash). Run it against a
  reduced build to prove any feature set loads:
  ```sh
  dart tool/build_backends.dart --ffi --profile=debug \
    --features=ffi --no-default-features
  BU_LIB_PATH=$PWD/build/rust-crate/target/debug/libblockchain_utils.so \
  BU_FFI_PROFILE=debug dart test test/ffi_load_test.dart
  ```
- `test/parity_test.dart` (VM) asserts every Rust FFI export has a
  wasm-bindgen twin (or is on the documented exclusion list).
- `test/emu_live_test.dart` needs `BU_EMU_LIVE=1` plus reachable
  Trezor/BitBox/Speculos emulators; it skips otherwise (CI has none).
- GitHub Actions (`.github/workflows/dart.yml`) runs an FFI job
  (build `.so`, `dart analyze`, `dart test`) and a WASM job
  (checkout Rust crate, install matching `wasm-bindgen-cli`, build assets
  with `--force`, run Chrome tests).

## Project structure

```text
lib/
  blockchain_utils_connector.dart  # public exports (never FFI/WASM types)
  src/api/        # backend-agnostic interfaces (BuHashApi, BuAeadApi, …)
  src/default/    # connector implementations over BuPlatformBindings
  src/platform/   # FFI/WASM binding interfaces
  src/connector/  # Bu entrypoint, backend open/init, web + io loaders
  src/{bytes,error,hash,cipher,aead,kdf,hkdf}/  # value types, errors, helpers
test/
  test_backend*.dart  # backend selection, env config, VM cargo builders
  backend_suite.dart  # shared crypto suite run on both backends
  backend/ unit/      # per-domain tests
  browser_wasm_test.dart  # browser entry (TestOn browser, wasm tag)
  wasm_assets/        # built glue + module (CI rebuilds with --force)
tool/build_backends.dart  # prebuild CLI for FFI + WASM backends
```

## Security

- Pass an **absolute** `libraryPath`, and pin `librarySha256` when the
  library comes from anywhere you do not fully control.
- Secrets live in `BuBytes` buffers: prefer owned copies for secrets and
  `clean()`/`zero()` them when done.

## License

MIT — see [LICENSE](LICENSE). Upstream Rust sources:
https://github.com/mrtnetwork/blockchain-utils.
