// ignore_for_file: library_private_types_in_public_api
// FFI typedefs are internal (never exported from blockchain_utils_connector.dart).
import 'dart:ffi' as ffi;

/// Native Monero Bulletproofs+ symbols.
class BuMoneroFfi {
  BuMoneroFfi(ffi.DynamicLibrary lib)
    : bpPlusVerify = lib.lookupFunction<_VerifyN, _VerifyD>(
        'bu_monero_bp_plus_verify',
      ),
      bpPlusProveAmounts = lib.lookupFunction<_ProveAmountsN, _ProveAmountsD>(
        'bu_monero_bp_plus_prove_amounts',
      ),
      bpPlusProveScalars = lib.lookupFunction<_ProveScalarsN, _ProveScalarsD>(
        'bu_monero_bp_plus_prove_scalars',
      ),
      unlockBatch = lib.lookupFunction<_UnlockN, _UnlockD>(
        'bu_monero_unlock_batch',
      );

  final _VerifyD bpPlusVerify;
  final _ProveAmountsD bpPlusProveAmounts;
  final _ProveScalarsD bpPlusProveScalars;
  final _UnlockD unlockBatch;
}

typedef _VerifyN = ffi.Int32 Function(ffi.Pointer<ffi.Uint8>, ffi.Size);
typedef _VerifyD = int Function(ffi.Pointer<ffi.Uint8>, int);

typedef _ProveAmountsN =
    ffi.Int32 Function(
      ffi.Pointer<ffi.Uint64>,
      ffi.Pointer<ffi.Uint8>,
      ffi.Size,
      ffi.Pointer<ffi.Uint8>,
      ffi.Pointer<ffi.Uint8>,
      ffi.Pointer<ffi.Size>,
    );
typedef _ProveAmountsD =
    int Function(
      ffi.Pointer<ffi.Uint64>,
      ffi.Pointer<ffi.Uint8>,
      int,
      ffi.Pointer<ffi.Uint8>,
      ffi.Pointer<ffi.Uint8>,
      ffi.Pointer<ffi.Size>,
    );

typedef _ProveScalarsN =
    ffi.Int32 Function(
      ffi.Pointer<ffi.Uint8>,
      ffi.Pointer<ffi.Uint8>,
      ffi.Size,
      ffi.Pointer<ffi.Uint8>,
      ffi.Pointer<ffi.Uint8>,
      ffi.Pointer<ffi.Size>,
    );
typedef _ProveScalarsD =
    int Function(
      ffi.Pointer<ffi.Uint8>,
      ffi.Pointer<ffi.Uint8>,
      int,
      ffi.Pointer<ffi.Uint8>,
      ffi.Pointer<ffi.Uint8>,
      ffi.Pointer<ffi.Size>,
    );

typedef _UnlockN =
    ffi.Int32 Function(
      ffi.Pointer<ffi.Uint8>,
      ffi.Pointer<ffi.Uint8>,
      ffi.Pointer<ffi.Uint32>,
      ffi.Pointer<ffi.Uint8>,
      ffi.Pointer<ffi.Uint8>,
      ffi.Pointer<ffi.Uint8>,
      ffi.Pointer<ffi.Uint8>,
      ffi.Pointer<ffi.Int32>,
      ffi.Pointer<ffi.Uint32>,
      ffi.Uint32,
      ffi.Uint32,
      ffi.Pointer<ffi.Uint8>,
      ffi.Pointer<ffi.Size>,
    );
typedef _UnlockD =
    int Function(
      ffi.Pointer<ffi.Uint8>,
      ffi.Pointer<ffi.Uint8>,
      ffi.Pointer<ffi.Uint32>,
      ffi.Pointer<ffi.Uint8>,
      ffi.Pointer<ffi.Uint8>,
      ffi.Pointer<ffi.Uint8>,
      ffi.Pointer<ffi.Uint8>,
      ffi.Pointer<ffi.Int32>,
      ffi.Pointer<ffi.Uint32>,
      int,
      int,
      ffi.Pointer<ffi.Uint8>,
      ffi.Pointer<ffi.Size>,
    );
