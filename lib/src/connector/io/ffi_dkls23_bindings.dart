// ignore_for_file: library_private_types_in_public_api
// FFI typedefs are internal (never exported from blockchain_utils_connector.dart).
import 'dart:ffi' as ffi;

class BuDkls23Ffi {
  BuDkls23Ffi._({
    required this.importSecrets,
    required this.dkg,
    required this.sign,
    required this.refresh,
    required this.verify,
    required this.aggKeys,
    required this.xOnly,
  });

  factory BuDkls23Ffi(ffi.DynamicLibrary lib) {
    return BuDkls23Ffi._(
      importSecrets: lib.lookupFunction<_ImportN, _ImportD>(
        'bu_dkls23_import_secrets',
      ),
      dkg: lib.lookupFunction<_DkgN, _DkgD>('bu_dkls23_dkg'),
      sign: lib.lookupFunction<_SignN, _SignD>('bu_dkls23_sign'),
      refresh: lib.lookupFunction<_RefreshN, _RefreshD>('bu_dkls23_refresh'),
      verify: lib.lookupFunction<_VerifyN, _VerifyD>('bu_dkls23_verify'),
      aggKeys: lib.lookupFunction<_AggKeysN, _AggKeysD>('bu_dkls23_agg_keys'),
      xOnly: lib.lookupFunction<_XOnlyN, _XOnlyD>('bu_dkls23_x_only'),
    );
  }

  final _ImportD importSecrets;
  final _DkgD dkg;
  final _SignD sign;
  final _RefreshD refresh;
  final _VerifyD verify;
  final _AggKeysD aggKeys;
  final _XOnlyD xOnly;
}

typedef _ImportN =
    ffi.Int32 Function(
      ffi.Uint32, // curve
      ffi.Pointer<ffi.Uint8>, // secrets
      ffi.Size, // n
      ffi.Pointer<ffi.Uint8>, // out
      ffi.Pointer<ffi.Size>, // out_len
      ffi.Size, // out_cap
    );
typedef _ImportD =
    int Function(
      int,
      ffi.Pointer<ffi.Uint8>,
      int,
      ffi.Pointer<ffi.Uint8>,
      ffi.Pointer<ffi.Size>,
      int,
    );

typedef _DkgN =
    ffi.Int32 Function(
      ffi.Uint32, // curve
      ffi.Pointer<ffi.Uint8>, // sid
      ffi.Size, // sid_len
      ffi.Size, // n
      ffi.Size, // t
      ffi.Pointer<ffi.Uint8>, // seeds
      ffi.Pointer<ffi.Uint8>, // out
      ffi.Pointer<ffi.Size>, // out_len
      ffi.Size, // out_cap
    );
typedef _DkgD =
    int Function(
      int,
      ffi.Pointer<ffi.Uint8>,
      int,
      int,
      int,
      ffi.Pointer<ffi.Uint8>,
      ffi.Pointer<ffi.Uint8>,
      ffi.Pointer<ffi.Size>,
      int,
    );

typedef _SignN =
    ffi.Int32 Function(
      ffi.Uint32, // curve
      ffi.Pointer<ffi.Uint8>, // sid
      ffi.Size, // sid_len
      ffi.Pointer<ffi.Uint8>, // msg_hash
      ffi.Pointer<ffi.Uint8>, // shares_blob
      ffi.Size, // shares_blob_len
      ffi.Pointer<ffi.Uint8>, // seeds
      ffi.Pointer<ffi.Uint8>, // sig_out
      ffi.Size, // sig_len
    );
typedef _SignD =
    int Function(
      int,
      ffi.Pointer<ffi.Uint8>,
      int,
      ffi.Pointer<ffi.Uint8>,
      ffi.Pointer<ffi.Uint8>,
      int,
      ffi.Pointer<ffi.Uint8>,
      ffi.Pointer<ffi.Uint8>,
      int,
    );

typedef _RefreshN =
    ffi.Int32 Function(
      ffi.Pointer<ffi.Uint8>, // sid
      ffi.Size, // sid_len
      ffi.Pointer<ffi.Uint8>, // shares_blob
      ffi.Size, // shares_blob_len
      ffi.Pointer<ffi.Uint8>, // seeds
      ffi.Pointer<ffi.Uint8>, // out
      ffi.Pointer<ffi.Size>, // out_len
      ffi.Size, // out_cap
    );
typedef _RefreshD =
    int Function(
      ffi.Pointer<ffi.Uint8>,
      int,
      ffi.Pointer<ffi.Uint8>,
      int,
      ffi.Pointer<ffi.Uint8>,
      ffi.Pointer<ffi.Uint8>,
      ffi.Pointer<ffi.Size>,
      int,
    );

typedef _VerifyN =
    ffi.Int32 Function(
      ffi.Uint32, // curve
      ffi.Pointer<ffi.Uint8>, // group_pk
      ffi.Pointer<ffi.Uint8>, // msg_hash
      ffi.Pointer<ffi.Uint8>, // sig
    );
typedef _VerifyD =
    int Function(
      int,
      ffi.Pointer<ffi.Uint8>,
      ffi.Pointer<ffi.Uint8>,
      ffi.Pointer<ffi.Uint8>,
    );

typedef _AggKeysN =
    ffi.Int32 Function(
      ffi.Uint32, // curve
      ffi.Pointer<ffi.Uint8>, // members
      ffi.Size, // n
      ffi.Pointer<ffi.Uint8>, // agg_out
      ffi.Size, // agg_len
    );
typedef _AggKeysD =
    int Function(int, ffi.Pointer<ffi.Uint8>, int, ffi.Pointer<ffi.Uint8>, int);

typedef _XOnlyN =
    ffi.Int32 Function(
      ffi.Uint32, // curve
      ffi.Pointer<ffi.Uint8>, // group_pk
      ffi.Pointer<ffi.Uint8>, // x_out
      ffi.Size, // x_len
    );
typedef _XOnlyD =
    int Function(int, ffi.Pointer<ffi.Uint8>, ffi.Pointer<ffi.Uint8>, int);
