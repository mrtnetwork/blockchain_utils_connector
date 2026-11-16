// ignore_for_file: library_private_types_in_public_api
// FFI typedefs are internal (never exported from blockchain_utils_connector.dart).
import 'dart:ffi' as ffi;

/// Native FF1 + X25519 symbols.
class BuFf1X25519Ffi {
  BuFf1X25519Ffi(ffi.DynamicLibrary lib)
    : ff1Encrypt = lib.lookupFunction<_Ff1N, _Ff1D>('bu_ff1_encrypt'),
      ff1Decrypt = lib.lookupFunction<_Ff1N, _Ff1D>('bu_ff1_decrypt'),
      ff1EncryptBinary = lib.lookupFunction<_Ff1BinN, _Ff1BinD>(
        'bu_ff1_encrypt_binary',
      ),
      ff1DecryptBinary = lib.lookupFunction<_Ff1BinN, _Ff1BinD>(
        'bu_ff1_decrypt_binary',
      ),
      x25519 = lib.lookupFunction<_X25519N, _X25519D>('bu_x25519'),
      x25519PublicKey = lib.lookupFunction<_X25519PkN, _X25519PkD>(
        'bu_x25519_public_key',
      ),
      x25519Dh = lib.lookupFunction<_X25519DhN, _X25519DhD>('bu_x25519_dh'),
      ed25519PkToX25519 = lib.lookupFunction<_X25519PkN, _X25519PkD>(
        'bu_ed25519_pk_to_x25519',
      ),
      ed25519SeedToX25519 = lib.lookupFunction<_X25519PkN, _X25519PkD>(
        'bu_ed25519_seed_to_x25519',
      );

  final _Ff1D ff1Encrypt;
  final _Ff1D ff1Decrypt;
  final _Ff1BinD ff1EncryptBinary;
  final _Ff1BinD ff1DecryptBinary;
  final _X25519D x25519;
  final _X25519PkD x25519PublicKey;
  final _X25519DhD x25519Dh;
  final _X25519PkD ed25519PkToX25519;
  final _X25519PkD ed25519SeedToX25519;
}

typedef _Ff1N =
    ffi.Int32 Function(
      ffi.Pointer<ffi.Uint8>,
      ffi.Size,
      ffi.Uint32,
      ffi.Pointer<ffi.Uint8>,
      ffi.Size,
      ffi.Pointer<ffi.Uint8>,
      ffi.Size,
      ffi.Pointer<ffi.Uint8>,
      ffi.Size,
    );
typedef _Ff1D =
    int Function(
      ffi.Pointer<ffi.Uint8>,
      int,
      int,
      ffi.Pointer<ffi.Uint8>,
      int,
      ffi.Pointer<ffi.Uint8>,
      int,
      ffi.Pointer<ffi.Uint8>,
      int,
    );

typedef _X25519N =
    ffi.Int32 Function(
      ffi.Pointer<ffi.Uint8>,
      ffi.Size,
      ffi.Pointer<ffi.Uint8>,
      ffi.Size,
      ffi.Pointer<ffi.Uint8>,
      ffi.Size,
    );
typedef _X25519D =
    int Function(
      ffi.Pointer<ffi.Uint8>,
      int,
      ffi.Pointer<ffi.Uint8>,
      int,
      ffi.Pointer<ffi.Uint8>,
      int,
    );

typedef _X25519PkN =
    ffi.Int32 Function(
      ffi.Pointer<ffi.Uint8>,
      ffi.Size,
      ffi.Pointer<ffi.Uint8>,
      ffi.Size,
    );
typedef _X25519PkD =
    int Function(ffi.Pointer<ffi.Uint8>, int, ffi.Pointer<ffi.Uint8>, int);

typedef _X25519DhN =
    ffi.Int32 Function(
      ffi.Pointer<ffi.Uint8>,
      ffi.Size,
      ffi.Pointer<ffi.Uint8>,
      ffi.Size,
      ffi.Pointer<ffi.Uint8>,
      ffi.Size,
    );
typedef _X25519DhD =
    int Function(
      ffi.Pointer<ffi.Uint8>,
      int,
      ffi.Pointer<ffi.Uint8>,
      int,
      ffi.Pointer<ffi.Uint8>,
      int,
    );

typedef _Ff1BinN =
    ffi.Int32 Function(
      ffi.Pointer<ffi.Uint8>,
      ffi.Size,
      ffi.Pointer<ffi.Uint8>,
      ffi.Size,
      ffi.Pointer<ffi.Uint8>,
      ffi.Size,
      ffi.Pointer<ffi.Uint8>,
      ffi.Size,
    );
typedef _Ff1BinD =
    int Function(
      ffi.Pointer<ffi.Uint8>,
      int,
      ffi.Pointer<ffi.Uint8>,
      int,
      ffi.Pointer<ffi.Uint8>,
      int,
      ffi.Pointer<ffi.Uint8>,
      int,
    );
