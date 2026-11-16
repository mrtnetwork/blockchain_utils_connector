# Changelog

## 0.1.0

- Initial release: Dart frontend for
  [blockchain-utils](https://github.com/mrtnetwork/blockchain-utils).
- One interface (`BuPlatformBindings`) over two backends: native dynamic
  library via `dart:ffi`, and wasm-bindgen module via `dart:js_interop`.
- Per-domain facades: hash, AEAD, block/stream ciphers, KDF/HKDF, curves,
  ECDSA/Schnorr/Ed25519/SR25519/BLS/MuSig2/DKLs23/FROST/ML-DSA/RedDSA
  signing, FF1, X25519, Groth16, Sapling/Orchard/Merkle, Monero, Solana ZK,
  hardware-wallet codecs, transcripts, and RNG.
