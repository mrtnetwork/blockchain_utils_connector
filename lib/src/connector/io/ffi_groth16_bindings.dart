// ignore_for_file: library_private_types_in_public_api
// FFI typedefs are internal (never exported from blockchain_utils_connector.dart).
import 'dart:ffi' as ffi;

typedef _VerifyN =
    ffi.Int32 Function(
      ffi.Pointer<ffi.Uint8>,
      ffi.Size,
      ffi.Pointer<ffi.Uint8>,
      ffi.Size,
      ffi.Pointer<ffi.Uint8>,
      ffi.Size,
    );
typedef _VerifyD =
    int Function(
      ffi.Pointer<ffi.Uint8>,
      int,
      ffi.Pointer<ffi.Uint8>,
      int,
      ffi.Pointer<ffi.Uint8>,
      int,
    );

typedef _LenN = ffi.Size Function();
typedef _LenD = int Function();

/// Groth16 / Sapling verify FFI symbols (`feature = "ffi,groth16"`).
class BuGroth16Ffi {
  BuGroth16Ffi(ffi.DynamicLibrary lib)
    : verifyBls = lib.lookupFunction<_VerifyN, _VerifyD>(
        'bu_groth16_verify_bls',
      ),
      verifyBn254 = lib.lookupFunction<_VerifyN, _VerifyD>(
        'bu_groth16_verify_bn254',
      ),
      blsProofLen = lib.lookupFunction<_LenN, _LenD>(
        'bu_groth16_bls_proof_len',
      ),
      bn254ProofLen = lib.lookupFunction<_LenN, _LenD>(
        'bu_groth16_bn254_proof_len',
      ),
      saplingVerifySpend = lib.lookupFunction<_VerifyN, _VerifyD>(
        'bu_sapling_verify_spend',
      ),
      saplingVerifyOutput = lib.lookupFunction<_VerifyN, _VerifyD>(
        'bu_sapling_verify_output',
      );

  final _VerifyD verifyBls;
  final _VerifyD verifyBn254;
  final _LenD blsProofLen;
  final _LenD bn254ProofLen;
  final _VerifyD saplingVerifySpend;
  final _VerifyD saplingVerifyOutput;
}
