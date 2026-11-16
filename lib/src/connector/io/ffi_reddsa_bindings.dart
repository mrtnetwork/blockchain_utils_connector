// ignore_for_file: library_private_types_in_public_api
// FFI typedefs are internal (never exported from blockchain_utils_connector.dart).
import 'dart:ffi' as ffi;

typedef _PkN =
    ffi.Int32 Function(ffi.Pointer<ffi.Uint8>, ffi.Pointer<ffi.Uint8>);
typedef _PkD = int Function(ffi.Pointer<ffi.Uint8>, ffi.Pointer<ffi.Uint8>);

typedef _SignN =
    ffi.Int32 Function(
      ffi.Pointer<ffi.Uint8>,
      ffi.Pointer<ffi.Uint8>,
      ffi.Size,
      ffi.Pointer<ffi.Uint8>,
      ffi.Pointer<ffi.Uint8>,
    );
typedef _SignD =
    int Function(
      ffi.Pointer<ffi.Uint8>,
      ffi.Pointer<ffi.Uint8>,
      int,
      ffi.Pointer<ffi.Uint8>,
      ffi.Pointer<ffi.Uint8>,
    );

typedef _VerifyN =
    ffi.Int32 Function(
      ffi.Pointer<ffi.Uint8>,
      ffi.Pointer<ffi.Uint8>,
      ffi.Size,
      ffi.Pointer<ffi.Uint8>,
    );
typedef _VerifyD =
    int Function(
      ffi.Pointer<ffi.Uint8>,
      ffi.Pointer<ffi.Uint8>,
      int,
      ffi.Pointer<ffi.Uint8>,
    );

class BuReddsaFfi {
  BuReddsaFfi(ffi.DynamicLibrary lib)
    : jubjubAuthPk = lib.lookupFunction<_PkN, _PkD>('bu_reddsa_jubjub_auth_pk'),
      jubjubBindingPk = lib.lookupFunction<_PkN, _PkD>(
        'bu_reddsa_jubjub_binding_pk',
      ),
      pallasAuthPk = lib.lookupFunction<_PkN, _PkD>('bu_reddsa_pallas_auth_pk'),
      pallasBindingPk = lib.lookupFunction<_PkN, _PkD>(
        'bu_reddsa_pallas_binding_pk',
      ),
      jubjubAuthSign = lib.lookupFunction<_SignN, _SignD>(
        'bu_reddsa_jubjub_auth_sign',
      ),
      jubjubAuthVerify = lib.lookupFunction<_VerifyN, _VerifyD>(
        'bu_reddsa_jubjub_auth_verify',
      ),
      jubjubBindingSign = lib.lookupFunction<_SignN, _SignD>(
        'bu_reddsa_jubjub_binding_sign',
      ),
      jubjubBindingVerify = lib.lookupFunction<_VerifyN, _VerifyD>(
        'bu_reddsa_jubjub_binding_verify',
      ),
      pallasAuthSign = lib.lookupFunction<_SignN, _SignD>(
        'bu_reddsa_pallas_auth_sign',
      ),
      pallasAuthVerify = lib.lookupFunction<_VerifyN, _VerifyD>(
        'bu_reddsa_pallas_auth_verify',
      ),
      pallasBindingSign = lib.lookupFunction<_SignN, _SignD>(
        'bu_reddsa_pallas_binding_sign',
      ),
      pallasBindingVerify = lib.lookupFunction<_VerifyN, _VerifyD>(
        'bu_reddsa_pallas_binding_verify',
      );

  final _PkD jubjubAuthPk;
  final _PkD jubjubBindingPk;
  final _PkD pallasAuthPk;
  final _PkD pallasBindingPk;
  final _SignD jubjubAuthSign;
  final _VerifyD jubjubAuthVerify;
  final _SignD jubjubBindingSign;
  final _VerifyD jubjubBindingVerify;
  final _SignD pallasAuthSign;
  final _VerifyD pallasAuthVerify;
  final _SignD pallasBindingSign;
  final _VerifyD pallasBindingVerify;
}
