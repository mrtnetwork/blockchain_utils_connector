// ignore_for_file: library_private_types_in_public_api
// FFI typedefs are internal (never exported from blockchain_utils_connector.dart).
import 'dart:ffi' as ffi;

typedef _CreateCtxN = ffi.Uint32 Function();
typedef _CreateCtxD = int Function();

typedef _CloseCtxN = ffi.Int32 Function(ffi.Uint32);
typedef _CloseCtxD = int Function(int);

typedef _GetCtxN =
    ffi.Int32 Function(
      ffi.Uint32,
      ffi.Pointer<ffi.Uint8>,
      ffi.Pointer<ffi.Size>,
    );
typedef _GetCtxD =
    int Function(int, ffi.Pointer<ffi.Uint8>, ffi.Pointer<ffi.Size>);

typedef _InsertN =
    ffi.Int32 Function(ffi.Uint32, ffi.Pointer<ffi.Uint8>, ffi.Size);
typedef _InsertD = int Function(int, ffi.Pointer<ffi.Uint8>, int);

typedef _UpdateStateN =
    ffi.Int32 Function(
      ffi.Uint32,
      ffi.Uint32,
      ffi.Pointer<ffi.Uint8>,
      ffi.Size,
    );
typedef _UpdateStateD = int Function(int, int, ffi.Pointer<ffi.Uint8>, int);

typedef _UpdateSubtreeN =
    ffi.Int32 Function(
      ffi.Uint32,
      ffi.Uint32,
      ffi.Uint64,
      ffi.Pointer<ffi.Uint8>,
      ffi.Size,
    );
typedef _UpdateSubtreeD =
    int Function(int, int, int, ffi.Pointer<ffi.Uint8>, int);

typedef _CheckpointN = ffi.Int32 Function(ffi.Uint32, ffi.Uint32);
typedef _CheckpointD = int Function(int, int);

typedef _CreateWitnessN =
    ffi.Int32 Function(
      ffi.Uint32,
      ffi.Uint32,
      ffi.Uint32,
      ffi.Pointer<ffi.Uint8>,
      ffi.Size,
      ffi.Pointer<ffi.Uint8>,
      ffi.Pointer<ffi.Size>,
    );
typedef _CreateWitnessD =
    int Function(
      int,
      int,
      int,
      ffi.Pointer<ffi.Uint8>,
      int,
      ffi.Pointer<ffi.Uint8>,
      ffi.Pointer<ffi.Size>,
    );

/// Frontier-model Merkle context FFI symbols
/// (`feature = "ffi,groth16-prover,halo2"`).
class BuMerkleFfi {
  BuMerkleFfi(ffi.DynamicLibrary lib)
    : createContext = lib.lookupFunction<_CreateCtxN, _CreateCtxD>(
        'bu_merkle_create_context',
      ),
      closeContext = lib.lookupFunction<_CloseCtxN, _CloseCtxD>(
        'bu_merkle_close_context',
      ),
      getContext = lib.lookupFunction<_GetCtxN, _GetCtxD>(
        'bu_merkle_get_context',
      ),
      insertChainState = lib.lookupFunction<_InsertN, _InsertD>(
        'bu_merkle_insert_chain_state',
      ),
      updateState = lib.lookupFunction<_UpdateStateN, _UpdateStateD>(
        'bu_merkle_update_state',
      ),
      updateSubtree = lib.lookupFunction<_UpdateSubtreeN, _UpdateSubtreeD>(
        'bu_merkle_update_subtree',
      ),
      mergeState = lib.lookupFunction<_UpdateStateN, _UpdateStateD>(
        'bu_merkle_merge_state',
      ),
      checkpoint = lib.lookupFunction<_CheckpointN, _CheckpointD>(
        'bu_merkle_checkpoint',
      ),
      createWitness = lib.lookupFunction<_CreateWitnessN, _CreateWitnessD>(
        'bu_merkle_create_witness',
      );

  final _CreateCtxD createContext;
  final _CloseCtxD closeContext;
  final _GetCtxD getContext;
  final _InsertD insertChainState;
  final _UpdateStateD updateState;
  final _UpdateSubtreeD updateSubtree;
  final _UpdateStateD mergeState;
  final _CheckpointD checkpoint;
  final _CreateWitnessD createWitness;
}
