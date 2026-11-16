// ignore_for_file: library_private_types_in_public_api
// FFI typedefs are internal (never exported from blockchain_utils_connector.dart).
import 'dart:ffi' as ffi;

typedef _SizesN =
    ffi.Int32 Function(
      ffi.Uint32,
      ffi.Pointer<ffi.Size>,
      ffi.Pointer<ffi.Size>,
      ffi.Pointer<ffi.Size>,
    );
typedef _SizesD =
    int Function(
      int,
      ffi.Pointer<ffi.Size>,
      ffi.Pointer<ffi.Size>,
      ffi.Pointer<ffi.Size>,
    );

typedef _KeygenN =
    ffi.Int32 Function(
      ffi.Uint32,
      ffi.Pointer<ffi.Uint8>,
      ffi.Size,
      ffi.Pointer<ffi.Uint8>,
      ffi.Size,
      ffi.Pointer<ffi.Uint8>,
      ffi.Size,
    );
typedef _KeygenD =
    int Function(
      int,
      ffi.Pointer<ffi.Uint8>,
      int,
      ffi.Pointer<ffi.Uint8>,
      int,
      ffi.Pointer<ffi.Uint8>,
      int,
    );

typedef _SignN =
    ffi.Int32 Function(
      ffi.Uint32,
      ffi.Pointer<ffi.Uint8>,
      ffi.Size,
      ffi.Pointer<ffi.Uint8>,
      ffi.Size,
      ffi.Pointer<ffi.Uint8>,
      ffi.Size,
      ffi.Pointer<ffi.Uint8>,
      ffi.Size,
      ffi.Pointer<ffi.Uint8>,
      ffi.Size,
    );
typedef _SignD =
    int Function(
      int,
      ffi.Pointer<ffi.Uint8>,
      int,
      ffi.Pointer<ffi.Uint8>,
      int,
      ffi.Pointer<ffi.Uint8>,
      int,
      ffi.Pointer<ffi.Uint8>,
      int,
      ffi.Pointer<ffi.Uint8>,
      int,
    );

typedef _VerifyN =
    ffi.Int32 Function(
      ffi.Uint32,
      ffi.Pointer<ffi.Uint8>,
      ffi.Size,
      ffi.Pointer<ffi.Uint8>,
      ffi.Size,
      ffi.Pointer<ffi.Uint8>,
      ffi.Size,
      ffi.Pointer<ffi.Uint8>,
      ffi.Size,
    );
typedef _VerifyD =
    int Function(
      int,
      ffi.Pointer<ffi.Uint8>,
      int,
      ffi.Pointer<ffi.Uint8>,
      int,
      ffi.Pointer<ffi.Uint8>,
      int,
      ffi.Pointer<ffi.Uint8>,
      int,
    );

typedef _PkFromSkN =
    ffi.Int32 Function(
      ffi.Uint32,
      ffi.Pointer<ffi.Uint8>,
      ffi.Size,
      ffi.Pointer<ffi.Uint8>,
      ffi.Size,
    );
typedef _PkFromSkD =
    int Function(int, ffi.Pointer<ffi.Uint8>, int, ffi.Pointer<ffi.Uint8>, int);

/// Post-quantum FFI symbols (ML-DSA).
class BuPqFfi {
  BuPqFfi(ffi.DynamicLibrary lib)
    : mldsaSizes = lib.lookupFunction<_SizesN, _SizesD>('bu_mldsa_sizes'),
      mldsaKeygen = lib.lookupFunction<_KeygenN, _KeygenD>('bu_mldsa_keygen'),
      mldsaSign = lib.lookupFunction<_SignN, _SignD>('bu_mldsa_sign'),
      mldsaVerify = lib.lookupFunction<_VerifyN, _VerifyD>('bu_mldsa_verify'),
      mldsaPkFromSk = lib.lookupFunction<_PkFromSkN, _PkFromSkD>(
        'bu_mldsa_pk_from_sk',
      );

  final _SizesD mldsaSizes;
  final _KeygenD mldsaKeygen;
  final _SignD mldsaSign;
  final _VerifyD mldsaVerify;
  final _PkFromSkD mldsaPkFromSk;
}

typedef _RngSeedN = ffi.Int32 Function(ffi.Pointer<ffi.Uint8>, ffi.Size);
typedef _RngSeedD = int Function(ffi.Pointer<ffi.Uint8>, int);
typedef _RngIsN = ffi.Int32 Function();
typedef _RngIsD = int Function();
typedef _RngFillN = ffi.Int32 Function(ffi.Pointer<ffi.Uint8>, ffi.Size);
typedef _RngFillD = int Function(ffi.Pointer<ffi.Uint8>, int);

class BuRngFfi {
  BuRngFfi(ffi.DynamicLibrary lib)
    : seed = lib.lookupFunction<_RngSeedN, _RngSeedD>('bu_rng_seed'),
      isSeeded = lib.lookupFunction<_RngIsN, _RngIsD>('bu_rng_is_seeded'),
      fill = lib.lookupFunction<_RngFillN, _RngFillD>('bu_rng_fill');

  final _RngSeedD seed;
  final _RngIsD isSeeded;
  final _RngFillD fill;
}
