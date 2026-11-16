// ignore_for_file: library_private_types_in_public_api
// FFI typedefs are internal (never exported from blockchain_utils_connector.dart).
import 'dart:ffi' as ffi;

typedef _SetParamsN =
    ffi.Int32 Function(
      ffi.Pointer<ffi.Uint8>,
      ffi.Size,
      ffi.Pointer<ffi.Pointer<ffi.Void>>,
    );
typedef _SetParamsD =
    int Function(
      ffi.Pointer<ffi.Uint8>,
      int,
      ffi.Pointer<ffi.Pointer<ffi.Void>>,
    );

typedef _ParamsFreeN = ffi.Void Function(ffi.Pointer<ffi.Void>);
typedef _ParamsFreeD = void Function(ffi.Pointer<ffi.Void>);

typedef _ProveN =
    ffi.Int32 Function(
      ffi.Pointer<ffi.Void>,
      ffi.Uint32,
      ffi.Pointer<ffi.Uint8>,
      ffi.Size,
      ffi.Pointer<ffi.Uint8>,
      ffi.Pointer<ffi.Size>,
      ffi.Pointer<ffi.Uint8>,
      ffi.Pointer<ffi.Size>,
    );
typedef _ProveD =
    int Function(
      ffi.Pointer<ffi.Void>,
      int,
      ffi.Pointer<ffi.Uint8>,
      int,
      ffi.Pointer<ffi.Uint8>,
      ffi.Pointer<ffi.Size>,
      ffi.Pointer<ffi.Uint8>,
      ffi.Pointer<ffi.Size>,
    );

typedef _VerifyN =
    ffi.Int32 Function(
      ffi.Pointer<ffi.Void>,
      ffi.Uint32,
      ffi.Pointer<ffi.Uint8>,
      ffi.Size,
      ffi.Pointer<ffi.Uint8>,
      ffi.Size,
    );
typedef _VerifyD =
    int Function(
      ffi.Pointer<ffi.Void>,
      int,
      ffi.Pointer<ffi.Uint8>,
      int,
      ffi.Pointer<ffi.Uint8>,
      int,
    );

/// Sapling Groth16 FFI symbols (`feature = "ffi,groth16-prover"`).
class BuSaplingFfi {
  BuSaplingFfi(ffi.DynamicLibrary lib)
    : setSpendParams = lib.lookupFunction<_SetParamsN, _SetParamsD>(
        'bu_sapling_set_spend_params',
      ),
      setOutputParams = lib.lookupFunction<_SetParamsN, _SetParamsD>(
        'bu_sapling_set_output_params',
      ),
      paramsFree = lib.lookupFunction<_ParamsFreeN, _ParamsFreeD>(
        'bu_sapling_params_free',
      ),
      prove = lib.lookupFunction<_ProveN, _ProveD>('bu_sapling_prove'),
      verify = lib.lookupFunction<_VerifyN, _VerifyD>('bu_sapling_verify');

  final _SetParamsD setSpendParams;
  final _SetParamsD setOutputParams;
  final _ParamsFreeD paramsFree;
  final _ProveD prove;
  final _VerifyD verify;
}
