// ignore_for_file: library_private_types_in_public_api
// FFI typedefs are internal (never exported from blockchain_utils_connector.dart).
import 'dart:ffi' as ffi;

typedef _PkNewN =
    ffi.Int32 Function(ffi.Pointer<ffi.Pointer<ffi.Void>>, ffi.Uint32);
typedef _PkNewD = int Function(ffi.Pointer<ffi.Pointer<ffi.Void>>, int);

typedef _PkFreeN = ffi.Void Function(ffi.Pointer<ffi.Void>);
typedef _PkFreeD = void Function(ffi.Pointer<ffi.Void>);

typedef _CreateProofN =
    ffi.Int32 Function(
      ffi.Pointer<ffi.Void>,
      ffi.Pointer<ffi.Uint8>,
      ffi.Size,
      ffi.Pointer<ffi.Uint8>,
      ffi.Size,
      ffi.Uint32,
      ffi.Uint32,
      ffi.Pointer<ffi.Uint8>,
      ffi.Pointer<ffi.Uint8>,
      ffi.Pointer<ffi.Size>,
    );
typedef _CreateProofD =
    int Function(
      ffi.Pointer<ffi.Void>,
      ffi.Pointer<ffi.Uint8>,
      int,
      ffi.Pointer<ffi.Uint8>,
      int,
      int,
      int,
      ffi.Pointer<ffi.Uint8>,
      ffi.Pointer<ffi.Uint8>,
      ffi.Pointer<ffi.Size>,
    );

typedef _VerifyProofN =
    ffi.Int32 Function(
      ffi.Pointer<ffi.Void>,
      ffi.Pointer<ffi.Uint8>,
      ffi.Size,
      ffi.Pointer<ffi.Uint8>,
      ffi.Size,
      ffi.Uint32,
      ffi.Uint32,
    );
typedef _VerifyProofD =
    int Function(
      ffi.Pointer<ffi.Void>,
      ffi.Pointer<ffi.Uint8>,
      int,
      ffi.Pointer<ffi.Uint8>,
      int,
      int,
      int,
    );

/// Orchard Action FFI symbols (`ffi` + `orchard-halo2`).
class BuOrchardFfi {
  BuOrchardFfi(ffi.DynamicLibrary lib)
    : pkNewForVersion = lib.lookupFunction<_PkNewN, _PkNewD>(
        'bu_orchard_pk_new_for_version',
      ),
      pkFree = lib.lookupFunction<_PkFreeN, _PkFreeD>('bu_orchard_pk_free'),
      createProof = lib.lookupFunction<_CreateProofN, _CreateProofD>(
        'bu_orchard_create_proof',
      ),
      verifyProof = lib.lookupFunction<_VerifyProofN, _VerifyProofD>(
        'bu_orchard_verify_proof',
      );

  final _PkNewD pkNewForVersion;
  final _PkFreeD pkFree;
  final _CreateProofD createProof;
  final _VerifyProofD verifyProof;
}
