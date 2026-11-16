// ignore_for_file: library_private_types_in_public_api
// FFI typedefs are internal (never exported from blockchain_utils_connector.dart).
import 'dart:ffi' as ffi;

/// Native Solana confidential-transfer ZK symbols.
///
/// Fixed-size outputs are written into caller buffers; the batched range
/// prover uses the size-query convention (`out`/`out_len`).
/// Return codes: 0 ok, 1 invalid-equation, -1 null, -2 length, -3 parse,
/// -4 crypto, -5 internal, -6 backend-not-linked.
class BuSolanaZkFfi {
  BuSolanaZkFfi(ffi.DynamicLibrary lib)
    : validatePubkey = lib.lookupFunction<_P1N, _P1D>(
        'bu_solana_zk_validate_pubkey',
      ),
      validateCiphertext = lib.lookupFunction<_P1N, _P1D>(
        'bu_solana_zk_validate_ciphertext',
      ),
      validateAe = lib.lookupFunction<_P1N, _P1D>('bu_solana_zk_validate_ae'),
      aeEncrypt = lib.lookupFunction<_AeEncN, _AeEncD>(
        'bu_solana_zk_ae_encrypt',
      ),
      aeDecrypt = lib.lookupFunction<_AeDecN, _AeDecD>(
        'bu_solana_zk_ae_decrypt',
      ),
      pubkeyFromSecret = lib.lookupFunction<_P2N, _P2D>(
        'bu_solana_zk_pubkey_from_secret',
      ),
      encryptWith = lib.lookupFunction<_EncryptN, _EncryptD>(
        'bu_solana_zk_encrypt_with',
      ),
      decryptU32 = lib.lookupFunction<_DecryptN, _DecryptD>(
        'bu_solana_zk_decrypt_u32',
      ),
      provePubkeyValidity = lib.lookupFunction<_P3N, _P3D>(
        'bu_solana_zk_prove_pubkey_validity',
      ),
      verifyPubkeyValidity = lib.lookupFunction<_P2N, _P2D>(
        'bu_solana_zk_verify_pubkey_validity',
      ),
      proveZeroCiphertext = lib.lookupFunction<_P5N, _P5D>(
        'bu_solana_zk_prove_zero_ciphertext',
      ),
      verifyZeroCiphertext = lib.lookupFunction<_P3N, _P3D>(
        'bu_solana_zk_verify_zero_ciphertext',
      ),
      proveEquality = lib.lookupFunction<_ProveEqN, _ProveEqD>(
        'bu_solana_zk_prove_equality',
      ),
      verifyEquality = lib.lookupFunction<_VerifyEqN, _VerifyEqD>(
        'bu_solana_zk_verify_equality',
      ),
      proveCiphertextEquality = lib.lookupFunction<_ProveCtEqN, _ProveCtEqD>(
        'bu_solana_zk_prove_ciphertext_equality',
      ),
      verifyCiphertextEquality = lib.lookupFunction<_VerifyCtEqN, _VerifyCtEqD>(
        'bu_solana_zk_verify_ciphertext_equality',
      ),
      proveGroupedValidity2 = lib.lookupFunction<_ProveG2N, _ProveG2D>(
        'bu_solana_zk_prove_grouped_validity_2',
      ),
      verifyGroupedValidity2 = lib.lookupFunction<_VerifyG2N, _VerifyG2D>(
        'bu_solana_zk_verify_grouped_validity_2',
      ),
      proveGroupedValidity3 = lib.lookupFunction<_ProveG3N, _ProveG3D>(
        'bu_solana_zk_prove_grouped_validity_3',
      ),
      verifyGroupedValidity3 = lib.lookupFunction<_VerifyG3N, _VerifyG3D>(
        'bu_solana_zk_verify_grouped_validity_3',
      ),
      proveBatchedGroupedValidity2 = lib.lookupFunction<_ProveBG2N, _ProveBG2D>(
        'bu_solana_zk_prove_batched_grouped_validity_2',
      ),
      verifyBatchedGroupedValidity2 = lib
          .lookupFunction<_VerifyBG2N, _VerifyBG2D>(
            'bu_solana_zk_verify_batched_grouped_validity_2',
          ),
      proveBatchedGroupedValidity3 = lib.lookupFunction<_ProveBG3N, _ProveBG3D>(
        'bu_solana_zk_prove_batched_grouped_validity_3',
      ),
      verifyBatchedGroupedValidity3 = lib
          .lookupFunction<_VerifyBG3N, _VerifyBG3D>(
            'bu_solana_zk_verify_batched_grouped_validity_3',
          ),
      provePercentageWithCap = lib.lookupFunction<_ProvePwcN, _ProvePwcD>(
        'bu_solana_zk_prove_percentage_with_cap',
      ),
      verifyPercentageWithCap = lib.lookupFunction<_VerifyPwcN, _VerifyPwcD>(
        'bu_solana_zk_verify_percentage_with_cap',
      ),
      proveBatchedRange = lib.lookupFunction<_ProveRangeN, _ProveRangeD>(
        'bu_solana_zk_prove_batched_range',
      ),
      verifyBatchedRange = lib.lookupFunction<_VerifyRangeN, _VerifyRangeD>(
        'bu_solana_zk_verify_batched_range',
      ),
      proveWithdraw = lib.lookupFunction<_ProveWithdrawN, _ProveWithdrawD>(
        'bu_solana_zk_prove_withdraw',
      ),
      proveTransfer = lib.lookupFunction<_ProveTransferN, _ProveTransferD>(
        'bu_solana_zk_prove_transfer',
      ),
      proveTransferWithFee = lib.lookupFunction<_ProveFeeN, _ProveFeeD>(
        'bu_solana_zk_prove_transfer_with_fee',
      );

  final _P1D validatePubkey;
  final _P1D validateCiphertext;
  final _P1D validateAe;
  final _AeEncD aeEncrypt;
  final _AeDecD aeDecrypt;
  final _P2D pubkeyFromSecret;
  final _EncryptD encryptWith;
  final _DecryptD decryptU32;
  final _P3D provePubkeyValidity;
  final _P2D verifyPubkeyValidity;
  final _P5D proveZeroCiphertext;
  final _P3D verifyZeroCiphertext;
  final _ProveEqD proveEquality;
  final _VerifyEqD verifyEquality;
  final _ProveCtEqD proveCiphertextEquality;
  final _VerifyCtEqD verifyCiphertextEquality;
  final _ProveG2D proveGroupedValidity2;
  final _VerifyG2D verifyGroupedValidity2;
  final _ProveG3D proveGroupedValidity3;
  final _VerifyG3D verifyGroupedValidity3;
  final _ProveBG2D proveBatchedGroupedValidity2;
  final _VerifyBG2D verifyBatchedGroupedValidity2;
  final _ProveBG3D proveBatchedGroupedValidity3;
  final _VerifyBG3D verifyBatchedGroupedValidity3;
  final _ProvePwcD provePercentageWithCap;
  final _VerifyPwcD verifyPercentageWithCap;
  final _ProveRangeD proveBatchedRange;
  final _VerifyRangeD verifyBatchedRange;
  final _ProveWithdrawD proveWithdraw;
  final _ProveTransferD proveTransfer;
  final _ProveFeeD proveTransferWithFee;
}

// Single readable pointer → code.
typedef _P1N = ffi.Int32 Function(ffi.Pointer<ffi.Uint8>);
typedef _P1D = int Function(ffi.Pointer<ffi.Uint8>);

// (in, out) pointers → code.
typedef _P2N =
    ffi.Int32 Function(ffi.Pointer<ffi.Uint8>, ffi.Pointer<ffi.Uint8>);
typedef _P2D = int Function(ffi.Pointer<ffi.Uint8>, ffi.Pointer<ffi.Uint8>);

// (in, in, out) pointers → code.
typedef _P3N =
    ffi.Int32 Function(
      ffi.Pointer<ffi.Uint8>,
      ffi.Pointer<ffi.Uint8>,
      ffi.Pointer<ffi.Uint8>,
    );
typedef _P3D =
    int Function(
      ffi.Pointer<ffi.Uint8>,
      ffi.Pointer<ffi.Uint8>,
      ffi.Pointer<ffi.Uint8>,
    );

// (4 in pointers, out) → code.
typedef _P5N =
    ffi.Int32 Function(
      ffi.Pointer<ffi.Uint8>,
      ffi.Pointer<ffi.Uint8>,
      ffi.Pointer<ffi.Uint8>,
      ffi.Pointer<ffi.Uint8>,
      ffi.Pointer<ffi.Uint8>,
    );
typedef _P5D =
    int Function(
      ffi.Pointer<ffi.Uint8>,
      ffi.Pointer<ffi.Uint8>,
      ffi.Pointer<ffi.Uint8>,
      ffi.Pointer<ffi.Uint8>,
      ffi.Pointer<ffi.Uint8>,
    );

typedef _EncryptN =
    ffi.Int32 Function(
      ffi.Pointer<ffi.Uint8>,
      ffi.Uint64,
      ffi.Pointer<ffi.Uint8>,
      ffi.Pointer<ffi.Uint8>,
    );
typedef _EncryptD =
    int Function(
      ffi.Pointer<ffi.Uint8>,
      int,
      ffi.Pointer<ffi.Uint8>,
      ffi.Pointer<ffi.Uint8>,
    );

typedef _DecryptN =
    ffi.Int32 Function(
      ffi.Pointer<ffi.Uint8>,
      ffi.Pointer<ffi.Uint8>,
      ffi.Pointer<ffi.Uint64>,
    );
typedef _DecryptD =
    int Function(
      ffi.Pointer<ffi.Uint8>,
      ffi.Pointer<ffi.Uint8>,
      ffi.Pointer<ffi.Uint64>,
    );

// Equality prove: secret, pubkey, ciphertext, commitment, opening, amount,
// seed, out(192).
typedef _ProveEqN =
    ffi.Int32 Function(
      ffi.Pointer<ffi.Uint8>,
      ffi.Pointer<ffi.Uint8>,
      ffi.Pointer<ffi.Uint8>,
      ffi.Pointer<ffi.Uint8>,
      ffi.Pointer<ffi.Uint8>,
      ffi.Uint64,
      ffi.Pointer<ffi.Uint8>,
      ffi.Pointer<ffi.Uint8>,
    );
typedef _ProveEqD =
    int Function(
      ffi.Pointer<ffi.Uint8>,
      ffi.Pointer<ffi.Uint8>,
      ffi.Pointer<ffi.Uint8>,
      ffi.Pointer<ffi.Uint8>,
      ffi.Pointer<ffi.Uint8>,
      int,
      ffi.Pointer<ffi.Uint8>,
      ffi.Pointer<ffi.Uint8>,
    );

// Equality verify: pubkey, ciphertext, commitment, proof(192).
typedef _VerifyEqN =
    ffi.Int32 Function(
      ffi.Pointer<ffi.Uint8>,
      ffi.Pointer<ffi.Uint8>,
      ffi.Pointer<ffi.Uint8>,
      ffi.Pointer<ffi.Uint8>,
    );
typedef _VerifyEqD =
    int Function(
      ffi.Pointer<ffi.Uint8>,
      ffi.Pointer<ffi.Uint8>,
      ffi.Pointer<ffi.Uint8>,
      ffi.Pointer<ffi.Uint8>,
    );

// Ciphertext-equality prove: fs, p1, p2, c1, c2, opening, amount, seed,
// out(224).
typedef _ProveCtEqN =
    ffi.Int32 Function(
      ffi.Pointer<ffi.Uint8>,
      ffi.Pointer<ffi.Uint8>,
      ffi.Pointer<ffi.Uint8>,
      ffi.Pointer<ffi.Uint8>,
      ffi.Pointer<ffi.Uint8>,
      ffi.Pointer<ffi.Uint8>,
      ffi.Uint64,
      ffi.Pointer<ffi.Uint8>,
      ffi.Pointer<ffi.Uint8>,
    );
typedef _ProveCtEqD =
    int Function(
      ffi.Pointer<ffi.Uint8>,
      ffi.Pointer<ffi.Uint8>,
      ffi.Pointer<ffi.Uint8>,
      ffi.Pointer<ffi.Uint8>,
      ffi.Pointer<ffi.Uint8>,
      ffi.Pointer<ffi.Uint8>,
      int,
      ffi.Pointer<ffi.Uint8>,
      ffi.Pointer<ffi.Uint8>,
    );

// Ciphertext-equality verify: p1, p2, c1, c2, proof(224).
typedef _VerifyCtEqN =
    ffi.Int32 Function(
      ffi.Pointer<ffi.Uint8>,
      ffi.Pointer<ffi.Uint8>,
      ffi.Pointer<ffi.Uint8>,
      ffi.Pointer<ffi.Uint8>,
      ffi.Pointer<ffi.Uint8>,
    );
typedef _VerifyCtEqD =
    int Function(
      ffi.Pointer<ffi.Uint8>,
      ffi.Pointer<ffi.Uint8>,
      ffi.Pointer<ffi.Uint8>,
      ffi.Pointer<ffi.Uint8>,
      ffi.Pointer<ffi.Uint8>,
    );

// Grouped-2 prove: p1, p2, grouped(96), amount, opening, seed, out(160).
typedef _ProveG2N =
    ffi.Int32 Function(
      ffi.Pointer<ffi.Uint8>,
      ffi.Pointer<ffi.Uint8>,
      ffi.Pointer<ffi.Uint8>,
      ffi.Uint64,
      ffi.Pointer<ffi.Uint8>,
      ffi.Pointer<ffi.Uint8>,
      ffi.Pointer<ffi.Uint8>,
    );
typedef _ProveG2D =
    int Function(
      ffi.Pointer<ffi.Uint8>,
      ffi.Pointer<ffi.Uint8>,
      ffi.Pointer<ffi.Uint8>,
      int,
      ffi.Pointer<ffi.Uint8>,
      ffi.Pointer<ffi.Uint8>,
      ffi.Pointer<ffi.Uint8>,
    );

// Grouped-2 verify: p1, p2, grouped(96), proof(160).
typedef _VerifyG2N =
    ffi.Int32 Function(
      ffi.Pointer<ffi.Uint8>,
      ffi.Pointer<ffi.Uint8>,
      ffi.Pointer<ffi.Uint8>,
      ffi.Pointer<ffi.Uint8>,
    );
typedef _VerifyG2D =
    int Function(
      ffi.Pointer<ffi.Uint8>,
      ffi.Pointer<ffi.Uint8>,
      ffi.Pointer<ffi.Uint8>,
      ffi.Pointer<ffi.Uint8>,
    );

// Grouped-3 prove: p1, p2, p3, grouped(128), amount, opening, seed, out(192).
typedef _ProveG3N =
    ffi.Int32 Function(
      ffi.Pointer<ffi.Uint8>,
      ffi.Pointer<ffi.Uint8>,
      ffi.Pointer<ffi.Uint8>,
      ffi.Pointer<ffi.Uint8>,
      ffi.Uint64,
      ffi.Pointer<ffi.Uint8>,
      ffi.Pointer<ffi.Uint8>,
      ffi.Pointer<ffi.Uint8>,
    );
typedef _ProveG3D =
    int Function(
      ffi.Pointer<ffi.Uint8>,
      ffi.Pointer<ffi.Uint8>,
      ffi.Pointer<ffi.Uint8>,
      ffi.Pointer<ffi.Uint8>,
      int,
      ffi.Pointer<ffi.Uint8>,
      ffi.Pointer<ffi.Uint8>,
      ffi.Pointer<ffi.Uint8>,
    );

// Grouped-3 verify: p1, p2, p3, grouped(128), proof(192).
typedef _VerifyG3N =
    ffi.Int32 Function(
      ffi.Pointer<ffi.Uint8>,
      ffi.Pointer<ffi.Uint8>,
      ffi.Pointer<ffi.Uint8>,
      ffi.Pointer<ffi.Uint8>,
      ffi.Pointer<ffi.Uint8>,
    );
typedef _VerifyG3D =
    int Function(
      ffi.Pointer<ffi.Uint8>,
      ffi.Pointer<ffi.Uint8>,
      ffi.Pointer<ffi.Uint8>,
      ffi.Pointer<ffi.Uint8>,
      ffi.Pointer<ffi.Uint8>,
    );

// Batched grouped-2 prove: p1, p2, lo(96), hi(96), aLo, aHi, oLo, oHi, seed,
// out(160).
typedef _ProveBG2N =
    ffi.Int32 Function(
      ffi.Pointer<ffi.Uint8>,
      ffi.Pointer<ffi.Uint8>,
      ffi.Pointer<ffi.Uint8>,
      ffi.Pointer<ffi.Uint8>,
      ffi.Uint64,
      ffi.Uint64,
      ffi.Pointer<ffi.Uint8>,
      ffi.Pointer<ffi.Uint8>,
      ffi.Pointer<ffi.Uint8>,
      ffi.Pointer<ffi.Uint8>,
    );
typedef _ProveBG2D =
    int Function(
      ffi.Pointer<ffi.Uint8>,
      ffi.Pointer<ffi.Uint8>,
      ffi.Pointer<ffi.Uint8>,
      ffi.Pointer<ffi.Uint8>,
      int,
      int,
      ffi.Pointer<ffi.Uint8>,
      ffi.Pointer<ffi.Uint8>,
      ffi.Pointer<ffi.Uint8>,
      ffi.Pointer<ffi.Uint8>,
    );

// Batched grouped-2 verify: p1, p2, lo(96), hi(96), proof(160).
typedef _VerifyBG2N =
    ffi.Int32 Function(
      ffi.Pointer<ffi.Uint8>,
      ffi.Pointer<ffi.Uint8>,
      ffi.Pointer<ffi.Uint8>,
      ffi.Pointer<ffi.Uint8>,
      ffi.Pointer<ffi.Uint8>,
    );
typedef _VerifyBG2D =
    int Function(
      ffi.Pointer<ffi.Uint8>,
      ffi.Pointer<ffi.Uint8>,
      ffi.Pointer<ffi.Uint8>,
      ffi.Pointer<ffi.Uint8>,
      ffi.Pointer<ffi.Uint8>,
    );

// Batched grouped-3 prove: p1, p2, p3, lo(128), hi(128), aLo, aHi, oLo, oHi,
// seed, out(192).
typedef _ProveBG3N =
    ffi.Int32 Function(
      ffi.Pointer<ffi.Uint8>,
      ffi.Pointer<ffi.Uint8>,
      ffi.Pointer<ffi.Uint8>,
      ffi.Pointer<ffi.Uint8>,
      ffi.Pointer<ffi.Uint8>,
      ffi.Uint64,
      ffi.Uint64,
      ffi.Pointer<ffi.Uint8>,
      ffi.Pointer<ffi.Uint8>,
      ffi.Pointer<ffi.Uint8>,
      ffi.Pointer<ffi.Uint8>,
    );
typedef _ProveBG3D =
    int Function(
      ffi.Pointer<ffi.Uint8>,
      ffi.Pointer<ffi.Uint8>,
      ffi.Pointer<ffi.Uint8>,
      ffi.Pointer<ffi.Uint8>,
      ffi.Pointer<ffi.Uint8>,
      int,
      int,
      ffi.Pointer<ffi.Uint8>,
      ffi.Pointer<ffi.Uint8>,
      ffi.Pointer<ffi.Uint8>,
      ffi.Pointer<ffi.Uint8>,
    );

// Batched grouped-3 verify: p1, p2, p3, lo(128), hi(128), proof(192).
typedef _VerifyBG3N =
    ffi.Int32 Function(
      ffi.Pointer<ffi.Uint8>,
      ffi.Pointer<ffi.Uint8>,
      ffi.Pointer<ffi.Uint8>,
      ffi.Pointer<ffi.Uint8>,
      ffi.Pointer<ffi.Uint8>,
      ffi.Pointer<ffi.Uint8>,
    );
typedef _VerifyBG3D =
    int Function(
      ffi.Pointer<ffi.Uint8>,
      ffi.Pointer<ffi.Uint8>,
      ffi.Pointer<ffi.Uint8>,
      ffi.Pointer<ffi.Uint8>,
      ffi.Pointer<ffi.Uint8>,
      ffi.Pointer<ffi.Uint8>,
    );

// Percentage prove: pc, po, pa, dc, do, da, cc, co, max, seed, out(256).
typedef _ProvePwcN =
    ffi.Int32 Function(
      ffi.Pointer<ffi.Uint8>,
      ffi.Pointer<ffi.Uint8>,
      ffi.Uint64,
      ffi.Pointer<ffi.Uint8>,
      ffi.Pointer<ffi.Uint8>,
      ffi.Uint64,
      ffi.Pointer<ffi.Uint8>,
      ffi.Pointer<ffi.Uint8>,
      ffi.Uint64,
      ffi.Pointer<ffi.Uint8>,
      ffi.Pointer<ffi.Uint8>,
    );
typedef _ProvePwcD =
    int Function(
      ffi.Pointer<ffi.Uint8>,
      ffi.Pointer<ffi.Uint8>,
      int,
      ffi.Pointer<ffi.Uint8>,
      ffi.Pointer<ffi.Uint8>,
      int,
      ffi.Pointer<ffi.Uint8>,
      ffi.Pointer<ffi.Uint8>,
      int,
      ffi.Pointer<ffi.Uint8>,
      ffi.Pointer<ffi.Uint8>,
    );

// Percentage verify: pc, dc, cc, max, proof(256).
typedef _VerifyPwcN =
    ffi.Int32 Function(
      ffi.Pointer<ffi.Uint8>,
      ffi.Pointer<ffi.Uint8>,
      ffi.Pointer<ffi.Uint8>,
      ffi.Uint64,
      ffi.Pointer<ffi.Uint8>,
    );
typedef _VerifyPwcD =
    int Function(
      ffi.Pointer<ffi.Uint8>,
      ffi.Pointer<ffi.Uint8>,
      ffi.Pointer<ffi.Uint8>,
      int,
      ffi.Pointer<ffi.Uint8>,
    );

// Batched range prove: amounts(n*8), openings(n*32), n, seed, out, outLen.
typedef _ProveRangeN =
    ffi.Int32 Function(
      ffi.Pointer<ffi.Uint8>,
      ffi.Pointer<ffi.Uint8>,
      ffi.Size,
      ffi.Pointer<ffi.Uint8>,
      ffi.Pointer<ffi.Uint8>,
      ffi.Pointer<ffi.Size>,
    );
typedef _ProveRangeD =
    int Function(
      ffi.Pointer<ffi.Uint8>,
      ffi.Pointer<ffi.Uint8>,
      int,
      ffi.Pointer<ffi.Uint8>,
      ffi.Pointer<ffi.Uint8>,
      ffi.Pointer<ffi.Size>,
    );

// Batched range verify: proof, proofLen, commitments(n*32), n.
typedef _VerifyRangeN =
    ffi.Int32 Function(
      ffi.Pointer<ffi.Uint8>,
      ffi.Size,
      ffi.Pointer<ffi.Uint8>,
      ffi.Size,
    );
typedef _VerifyRangeD =
    int Function(ffi.Pointer<ffi.Uint8>, int, ffi.Pointer<ffi.Uint8>, int);

// Withdraw prove: secret, pubkey, curCt, curBal, amount, seed, out(1256).
typedef _ProveWithdrawN =
    ffi.Int32 Function(
      ffi.Pointer<ffi.Uint8>,
      ffi.Pointer<ffi.Uint8>,
      ffi.Pointer<ffi.Uint8>,
      ffi.Uint64,
      ffi.Uint64,
      ffi.Pointer<ffi.Uint8>,
      ffi.Pointer<ffi.Uint8>,
    );
typedef _ProveWithdrawD =
    int Function(
      ffi.Pointer<ffi.Uint8>,
      ffi.Pointer<ffi.Uint8>,
      ffi.Pointer<ffi.Uint8>,
      int,
      int,
      ffi.Pointer<ffi.Uint8>,
      ffi.Pointer<ffi.Uint8>,
    );

// Transfer prove: secret, src, dst, aud, curCt, curBal, amount, seed,
// out(1856).
typedef _ProveTransferN =
    ffi.Int32 Function(
      ffi.Pointer<ffi.Uint8>,
      ffi.Pointer<ffi.Uint8>,
      ffi.Pointer<ffi.Uint8>,
      ffi.Pointer<ffi.Uint8>,
      ffi.Pointer<ffi.Uint8>,
      ffi.Uint64,
      ffi.Uint64,
      ffi.Pointer<ffi.Uint8>,
      ffi.Pointer<ffi.Uint8>,
    );
typedef _ProveTransferD =
    int Function(
      ffi.Pointer<ffi.Uint8>,
      ffi.Pointer<ffi.Uint8>,
      ffi.Pointer<ffi.Uint8>,
      ffi.Pointer<ffi.Uint8>,
      ffi.Pointer<ffi.Uint8>,
      int,
      int,
      ffi.Pointer<ffi.Uint8>,
      ffi.Pointer<ffi.Uint8>,
    );

// Fee prove: secret, src, dst, aud, auth, curCt, curBal, amount, rateU16,
// max, seed, out(2576).
typedef _ProveFeeN =
    ffi.Int32 Function(
      ffi.Pointer<ffi.Uint8>,
      ffi.Pointer<ffi.Uint8>,
      ffi.Pointer<ffi.Uint8>,
      ffi.Pointer<ffi.Uint8>,
      ffi.Pointer<ffi.Uint8>,
      ffi.Pointer<ffi.Uint8>,
      ffi.Uint64,
      ffi.Uint64,
      ffi.Uint16,
      ffi.Uint64,
      ffi.Pointer<ffi.Uint8>,
      ffi.Pointer<ffi.Uint8>,
    );
typedef _ProveFeeD =
    int Function(
      ffi.Pointer<ffi.Uint8>,
      ffi.Pointer<ffi.Uint8>,
      ffi.Pointer<ffi.Uint8>,
      ffi.Pointer<ffi.Uint8>,
      ffi.Pointer<ffi.Uint8>,
      ffi.Pointer<ffi.Uint8>,
      int,
      int,
      int,
      int,
      ffi.Pointer<ffi.Uint8>,
      ffi.Pointer<ffi.Uint8>,
    );
// AES-GCM-SIV encrypt: key(16), amount u64, nonce(12), out(36).
typedef _AeEncN =
    ffi.Int32 Function(
      ffi.Pointer<ffi.Uint8>,
      ffi.Uint64,
      ffi.Pointer<ffi.Uint8>,
      ffi.Pointer<ffi.Uint8>,
    );
typedef _AeEncD =
    int Function(
      ffi.Pointer<ffi.Uint8>,
      int,
      ffi.Pointer<ffi.Uint8>,
      ffi.Pointer<ffi.Uint8>,
    );

// AES-GCM-SIV decrypt: key(16), ae(36), out amount u64.
typedef _AeDecN =
    ffi.Int32 Function(
      ffi.Pointer<ffi.Uint8>,
      ffi.Pointer<ffi.Uint8>,
      ffi.Pointer<ffi.Uint64>,
    );
typedef _AeDecD =
    int Function(
      ffi.Pointer<ffi.Uint8>,
      ffi.Pointer<ffi.Uint8>,
      ffi.Pointer<ffi.Uint64>,
    );
