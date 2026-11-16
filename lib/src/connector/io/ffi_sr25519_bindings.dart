// ignore_for_file: library_private_types_in_public_api
// FFI typedefs are internal (never exported from blockchain_utils_connector.dart).
import 'dart:ffi' as ffi;

/// Lazy-loaded sr25519 FFI symbols.
class FfiSr25519Bindings {
  FfiSr25519Bindings(ffi.DynamicLibrary lib)
    : publicKey = lib.lookupFunction<_PkN, _PkD>('bu_sr25519_public_key'),
      secretFromSeed = lib.lookupFunction<_PkN, _PkD>(
        'bu_sr25519_secret_from_seed',
      ),
      publicKeyFromSecret = lib.lookupFunction<_PkSecN, _PkSecD>(
        'bu_sr25519_public_key_from_secret',
      ),
      isValidPublicKey = lib.lookupFunction<_ValidN, _ValidD>(
        'bu_sr25519_is_valid_public_key',
      ),
      isValidSecretKey = lib.lookupFunction<_ValidN, _ValidD>(
        'bu_sr25519_is_valid_secret_key',
      ),
      sign = lib.lookupFunction<_SignN, _SignD>('bu_sr25519_sign'),
      verify = lib.lookupFunction<_VerifyN, _VerifyD>('bu_sr25519_verify'),
      toEd25519 = lib.lookupFunction<_ToEdN, _ToEdD>(
        'bu_sr25519_to_ed25519_bytes',
      ),
      hardDerive = lib.lookupFunction<_HardN, _HardD>('bu_sr25519_hard_derive'),
      softDerive = lib.lookupFunction<_SoftN, _SoftD>('bu_sr25519_soft_derive'),
      derivePublic = lib.lookupFunction<_DerPubN, _DerPubD>(
        'bu_sr25519_derive_public',
      ),
      vrfHash = lib.lookupFunction<_VrfHashN, _VrfHashD>('bu_sr25519_vrf_hash'),
      vrfInOut = lib.lookupFunction<_VrfIoN, _VrfIoD>('bu_sr25519_vrf_in_out'),
      dleqProve = lib.lookupFunction<_DleqProveN, _DleqProveD>(
        'bu_sr25519_dleq_prove',
      ),
      dleqVerify = lib.lookupFunction<_DleqVerN, _DleqVerD>(
        'bu_sr25519_dleq_verify',
      ),
      vrfSign = lib.lookupFunction<_VrfSignN, _VrfSignD>('bu_sr25519_vrf_sign'),
      vrfVerify = lib.lookupFunction<_VrfVerN, _VrfVerD>(
        'bu_sr25519_vrf_verify',
      );

  final _PkD publicKey;
  final _PkD secretFromSeed;
  final _PkSecD publicKeyFromSecret;
  final _ValidD isValidPublicKey;
  final _ValidD isValidSecretKey;
  final _SignD sign;
  final _VerifyD verify;
  final _ToEdD toEd25519;
  final _HardD hardDerive;
  final _SoftD softDerive;
  final _DerPubD derivePublic;
  final _VrfHashD vrfHash;
  final _VrfIoD vrfInOut;
  final _DleqProveD dleqProve;
  final _DleqVerD dleqVerify;
  final _VrfSignD vrfSign;
  final _VrfVerD vrfVerify;
}

typedef _PkN =
    ffi.Int32 Function(
      ffi.Pointer<ffi.Uint8>,
      ffi.Size,
      ffi.Int32,
      ffi.Pointer<ffi.Uint8>,
      ffi.Size,
    );
typedef _PkD =
    int Function(ffi.Pointer<ffi.Uint8>, int, int, ffi.Pointer<ffi.Uint8>, int);
typedef _PkSecN =
    ffi.Int32 Function(
      ffi.Pointer<ffi.Uint8>,
      ffi.Size,
      ffi.Pointer<ffi.Uint8>,
      ffi.Size,
    );
typedef _PkSecD =
    int Function(ffi.Pointer<ffi.Uint8>, int, ffi.Pointer<ffi.Uint8>, int);
typedef _ValidN = ffi.Int32 Function(ffi.Pointer<ffi.Uint8>, ffi.Size);
typedef _ValidD = int Function(ffi.Pointer<ffi.Uint8>, int);
typedef _SignN =
    ffi.Int32 Function(
      ffi.Pointer<ffi.Uint8>,
      ffi.Size,
      ffi.Int32,
      ffi.Int32,
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
      ffi.Pointer<ffi.Uint8>,
      int,
      int,
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
      ffi.Pointer<ffi.Uint8>,
      int,
      ffi.Pointer<ffi.Uint8>,
      int,
      ffi.Pointer<ffi.Uint8>,
      int,
      ffi.Pointer<ffi.Uint8>,
      int,
    );
typedef _ToEdN =
    ffi.Int32 Function(
      ffi.Pointer<ffi.Uint8>,
      ffi.Size,
      ffi.Pointer<ffi.Uint8>,
      ffi.Size,
    );
typedef _ToEdD =
    int Function(ffi.Pointer<ffi.Uint8>, int, ffi.Pointer<ffi.Uint8>, int);
typedef _HardN =
    ffi.Int32 Function(
      ffi.Pointer<ffi.Uint8>,
      ffi.Size,
      ffi.Int32,
      ffi.Int32,
      ffi.Pointer<ffi.Uint8>,
      ffi.Size,
      ffi.Pointer<ffi.Uint8>,
      ffi.Size,
      ffi.Pointer<ffi.Uint8>,
      ffi.Size,
    );
typedef _HardD =
    int Function(
      ffi.Pointer<ffi.Uint8>,
      int,
      int,
      int,
      ffi.Pointer<ffi.Uint8>,
      int,
      ffi.Pointer<ffi.Uint8>,
      int,
      ffi.Pointer<ffi.Uint8>,
      int,
    );
typedef _SoftN =
    ffi.Int32 Function(
      ffi.Pointer<ffi.Uint8>,
      ffi.Size,
      ffi.Int32,
      ffi.Int32,
      ffi.Pointer<ffi.Uint8>,
      ffi.Size,
      ffi.Pointer<ffi.Uint8>,
      ffi.Size,
      ffi.Pointer<ffi.Uint8>,
      ffi.Size,
      ffi.Pointer<ffi.Uint8>,
      ffi.Size,
    );
typedef _SoftD =
    int Function(
      ffi.Pointer<ffi.Uint8>,
      int,
      int,
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
typedef _DerPubN =
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
typedef _DerPubD =
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
typedef _VrfHashN =
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
typedef _VrfHashD =
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
typedef _VrfIoN =
    ffi.Int32 Function(
      ffi.Pointer<ffi.Uint8>,
      ffi.Size,
      ffi.Int32,
      ffi.Int32,
      ffi.Pointer<ffi.Uint8>,
      ffi.Size,
      ffi.Pointer<ffi.Uint8>,
      ffi.Size,
      ffi.Pointer<ffi.Uint8>,
      ffi.Size,
    );
typedef _VrfIoD =
    int Function(
      ffi.Pointer<ffi.Uint8>,
      int,
      int,
      int,
      ffi.Pointer<ffi.Uint8>,
      int,
      ffi.Pointer<ffi.Uint8>,
      int,
      ffi.Pointer<ffi.Uint8>,
      int,
    );
typedef _DleqProveN =
    ffi.Int32 Function(
      ffi.Pointer<ffi.Uint8>,
      ffi.Size,
      ffi.Int32,
      ffi.Int32,
      ffi.Pointer<ffi.Uint8>,
      ffi.Size,
      ffi.Pointer<ffi.Uint8>,
      ffi.Size,
      ffi.Int32,
      ffi.Pointer<ffi.Uint8>,
      ffi.Size,
      ffi.Pointer<ffi.Uint8>,
      ffi.Size,
    );
typedef _DleqProveD =
    int Function(
      ffi.Pointer<ffi.Uint8>,
      int,
      int,
      int,
      ffi.Pointer<ffi.Uint8>,
      int,
      ffi.Pointer<ffi.Uint8>,
      int,
      int,
      ffi.Pointer<ffi.Uint8>,
      int,
      ffi.Pointer<ffi.Uint8>,
      int,
    );
typedef _DleqVerN =
    ffi.Int32 Function(
      ffi.Pointer<ffi.Uint8>,
      ffi.Size,
      ffi.Pointer<ffi.Uint8>,
      ffi.Size,
      ffi.Pointer<ffi.Uint8>,
      ffi.Size,
      ffi.Int32,
      ffi.Pointer<ffi.Uint8>,
      ffi.Size,
    );
typedef _DleqVerD =
    int Function(
      ffi.Pointer<ffi.Uint8>,
      int,
      ffi.Pointer<ffi.Uint8>,
      int,
      ffi.Pointer<ffi.Uint8>,
      int,
      int,
      ffi.Pointer<ffi.Uint8>,
      int,
    );
typedef _VrfSignN =
    ffi.Int32 Function(
      ffi.Pointer<ffi.Uint8>,
      ffi.Size,
      ffi.Int32,
      ffi.Int32,
      ffi.Pointer<ffi.Uint8>,
      ffi.Size,
      ffi.Pointer<ffi.Uint8>,
      ffi.Size,
      ffi.Pointer<ffi.Uint8>,
      ffi.Size,
      ffi.Int32,
      ffi.Pointer<ffi.Uint8>,
      ffi.Size,
      ffi.Pointer<ffi.Uint8>,
      ffi.Size,
    );
typedef _VrfSignD =
    int Function(
      ffi.Pointer<ffi.Uint8>,
      int,
      int,
      int,
      ffi.Pointer<ffi.Uint8>,
      int,
      ffi.Pointer<ffi.Uint8>,
      int,
      ffi.Pointer<ffi.Uint8>,
      int,
      int,
      ffi.Pointer<ffi.Uint8>,
      int,
      ffi.Pointer<ffi.Uint8>,
      int,
    );
typedef _VrfVerN =
    ffi.Int32 Function(
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
      ffi.Int32,
      ffi.Pointer<ffi.Uint8>,
      ffi.Size,
    );
typedef _VrfVerD =
    int Function(
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
      int,
      ffi.Pointer<ffi.Uint8>,
      int,
    );
