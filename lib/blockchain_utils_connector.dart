/// blockchain_utils_connector — public API never exposes FFI/WASM types.
library;

export 'src/bytes/bytes.dart';
export 'src/error/error_type.dart';
export 'src/error/bu_error.dart';

export 'src/hash/hash.dart';
export 'src/hash/blake2_config.dart';
export 'src/aead/aead.dart';
export 'src/cipher/block_cipher.dart';
export 'src/cipher/stream_cipher.dart';
export 'src/cipher/padding.dart';

export 'src/api/hash_api.dart';
export 'src/api/aead_api.dart';
export 'src/api/block_cipher_api.dart';
export 'src/api/stream_cipher_api.dart';
export 'src/api/curve_api.dart';
export 'src/api/curve_id.dart';
export 'src/api/secp256k1_signing_api.dart';
export 'src/api/secp256r1_signing_api.dart';
export 'src/api/ed25519_signing_api.dart';
export 'src/api/bls_signing_api.dart';
export 'src/api/mldsa_signing_api.dart';
export 'src/api/reddsa_signing_api.dart';
export 'src/api/musig2_api.dart';
export 'src/api/dkls23_api.dart';
export 'src/api/frost_api.dart';
export 'src/api/sr25519_signing_api.dart';

export 'src/default/default_hash_api.dart';
export 'src/default/default_aead_api.dart';
export 'src/default/default_block_cipher_api.dart';
export 'src/default/default_stream_cipher_api.dart';
export 'src/default/default_curve_api.dart';
export 'src/default/default_secp256k1_signing_api.dart';
export 'src/default/default_secp256r1_signing_api.dart';
export 'src/default/default_bls_signing_api.dart';
export 'src/default/default_ed25519_signing_api.dart';
export 'src/default/default_musig2_api.dart';
export 'src/default/default_dkls23_api.dart';
export 'src/default/default_frost_api.dart';
export 'src/default/default_sr25519_signing_api.dart';
export 'src/default/default_mldsa_signing_api.dart';
export 'src/default/default_reddsa_signing_api.dart';

export 'src/platform/bindings.dart';
export 'src/connector/bu.dart';
export 'src/connector/bu_config.dart';

export 'src/kdf/kdf.dart';
export 'src/hkdf/hkdf.dart';
export 'src/api/rng_api.dart';
export 'src/default/default_rng_api.dart';
export 'src/api/hw_api.dart';
export 'src/api/hw_support.dart';
export 'src/connector/emulator/emulator_stub.dart'
    if (dart.library.io) 'src/connector/emulator/emulator_io.dart';
export 'src/default/default_hw_api.dart';
export 'src/api/zk_api.dart';
export 'src/default/default_zk_api.dart';
export 'src/api/sapling_api.dart';
export 'src/default/default_sapling_api.dart';
export 'src/api/orchard_api.dart';
export 'src/default/default_orchard_api.dart';
export 'src/api/merkle_api.dart';
export 'src/default/default_merkle_api.dart';
export 'src/api/monero_api.dart';
export 'src/default/default_monero_api.dart';

export 'src/api/groth16_api.dart';
export 'src/default/default_groth16_api.dart';

export 'src/api/solana_zk_api.dart';
export 'src/default/default_solana_zk_api.dart';

export 'src/api/transcript_api.dart';
export 'src/default/default_transcript_api.dart';

export 'src/api/ff1_api.dart';
export 'src/api/x25519_api.dart';
export 'src/default/default_ff1_api.dart';
export 'src/default/default_x25519_api.dart';
export 'src/serialization/serialization.dart';
