// ignore_for_file: library_private_types_in_public_api
// FFI typedefs are internal (never exported from blockchain_utils_connector.dart).
import 'dart:ffi' as ffi;

class BuSignatureFfi {
  BuSignatureFfi._({
    required this.ecdsaK1PublicKey,
    required this.ecdsaK1Sign,
    required this.ecdsaK1SignEx,
    required this.ecdsaK1Verify,
    required this.ecdsaK1Recover,
    required this.schnorrPublicKey,
    required this.schnorrSign,
    required this.schnorrVerify,
    required this.schnorrSignAux,
    required this.schnorrTweakSecret,
    required this.schnorrTweakPublic,
    required this.schnorrBchSign,
    required this.schnorrBchVerify,
    required this.ecdsaR1PublicKey,
    required this.ecdsaR1Sign,
    required this.ecdsaR1SignEx,
    required this.ecdsaR1Verify,
    required this.ecdsaR1Recover,
    required this.ecdsaR1RecoveryId,
    required this.ed25519PublicKey,
    required this.ed25519Sign,
    required this.ed25519Verify,
    required this.ed25519PublicKeyVariant,
    required this.ed25519SignVariant,
    required this.ed25519VerifyVariant,
  });

  factory BuSignatureFfi(ffi.DynamicLibrary lib) {
    _RecoverD? r1Recover;
    _R1RecIdD? r1RecId;
    try {
      r1Recover = lib.lookupFunction<_RecoverN, _RecoverD>(
        'bu_ecdsa_r1_recover',
      );
    } catch (_) {}
    try {
      r1RecId = lib.lookupFunction<_R1RecIdN, _R1RecIdD>(
        'bu_ecdsa_r1_recovery_id',
      );
    } catch (_) {}
    return BuSignatureFfi._(
      ecdsaK1PublicKey: lib.lookupFunction<_PkN, _PkD>(
        'bu_ecdsa_k1_public_key',
      ),
      ecdsaK1Sign: lib.lookupFunction<_SignHashN, _SignHashD>(
        'bu_ecdsa_k1_sign',
      ),
      ecdsaK1SignEx: lib.lookupFunction<_SignExN, _SignExD>(
        'bu_ecdsa_k1_sign_ex',
      ),
      ecdsaK1Verify: lib.lookupFunction<_VerifyN, _VerifyD>(
        'bu_ecdsa_k1_verify',
      ),
      ecdsaK1Recover: lib.lookupFunction<_RecoverN, _RecoverD>(
        'bu_ecdsa_k1_recover',
      ),
      schnorrPublicKey: lib.lookupFunction<_Pk32N, _Pk32D>(
        'bu_schnorr_public_key',
      ),
      schnorrSign: lib.lookupFunction<_SchnorrSignN, _SchnorrSignD>(
        'bu_schnorr_sign',
      ),
      schnorrVerify: lib.lookupFunction<_SchnorrVerifyN, _SchnorrVerifyD>(
        'bu_schnorr_verify',
      ),
      schnorrSignAux: lib.lookupFunction<_SchnorrSignAuxN, _SchnorrSignAuxD>(
        'bu_schnorr_sign_aux',
      ),
      schnorrTweakSecret: lib.lookupFunction<_TweakN, _TweakD>(
        'bu_schnorr_tweak_secret',
      ),
      schnorrTweakPublic: lib.lookupFunction<_TweakN, _TweakD>(
        'bu_schnorr_tweak_public',
      ),
      schnorrBchSign: lib.lookupFunction<_SignExN, _SignExD>(
        'bu_schnorr_bch_sign',
      ),
      schnorrBchVerify: lib.lookupFunction<_VerifyN, _VerifyD>(
        'bu_schnorr_bch_verify',
      ),
      ecdsaR1PublicKey: lib.lookupFunction<_PkN, _PkD>(
        'bu_ecdsa_r1_public_key',
      ),
      ecdsaR1Sign: lib.lookupFunction<_SignHashN, _SignHashD>(
        'bu_ecdsa_r1_sign',
      ),
      ecdsaR1SignEx: lib.lookupFunction<_SignExN, _SignExD>(
        'bu_ecdsa_r1_sign_ex',
      ),
      ecdsaR1Verify: lib.lookupFunction<_VerifyN, _VerifyD>(
        'bu_ecdsa_r1_verify',
      ),
      ecdsaR1Recover: r1Recover,
      ecdsaR1RecoveryId: r1RecId,
      ed25519PublicKey: lib.lookupFunction<_Pk32N, _Pk32D>(
        'bu_ed25519_public_key',
      ),
      ed25519Sign: lib.lookupFunction<_SchnorrSignN, _SchnorrSignD>(
        'bu_ed25519_sign',
      ),
      ed25519Verify: lib.lookupFunction<_SchnorrVerifyN, _SchnorrVerifyD>(
        'bu_ed25519_verify',
      ),
      ed25519PublicKeyVariant: lib.lookupFunction<_EdVariantPkN, _EdVariantPkD>(
        'bu_ed25519_public_key_variant',
      ),
      ed25519SignVariant: lib.lookupFunction<_EdVariantSignN, _EdVariantSignD>(
        'bu_ed25519_sign_variant',
      ),
      ed25519VerifyVariant: lib
          .lookupFunction<_EdVariantVerifyN, _EdVariantVerifyD>(
            'bu_ed25519_verify_variant',
          ),
    );
  }

  final _PkD ecdsaK1PublicKey;
  final _SignHashD ecdsaK1Sign;
  final _SignExD ecdsaK1SignEx;
  final _VerifyD ecdsaK1Verify;
  final _RecoverD ecdsaK1Recover;
  final _Pk32D schnorrPublicKey;
  final _SchnorrSignD schnorrSign;
  final _SchnorrVerifyD schnorrVerify;
  final _SchnorrSignAuxD schnorrSignAux;
  final _TweakD schnorrTweakSecret;
  final _TweakD schnorrTweakPublic;
  final _SignExD schnorrBchSign;
  final _VerifyD schnorrBchVerify;
  final _PkD ecdsaR1PublicKey;
  final _SignHashD ecdsaR1Sign;
  final _SignExD ecdsaR1SignEx;
  final _VerifyD ecdsaR1Verify;
  final _RecoverD? ecdsaR1Recover;
  final _R1RecIdD? ecdsaR1RecoveryId;
  final _Pk32D ed25519PublicKey;
  final _SchnorrSignD ed25519Sign;
  final _SchnorrVerifyD ed25519Verify;
  final _EdVariantPkD ed25519PublicKeyVariant;
  final _EdVariantSignD ed25519SignVariant;
  final _EdVariantVerifyD ed25519VerifyVariant;
}

typedef _PkN =
    ffi.Int32 Function(
      ffi.Pointer<ffi.Uint8>,
      ffi.Size,
      ffi.Pointer<ffi.Uint8>,
      ffi.Size,
    );
typedef _PkD =
    int Function(ffi.Pointer<ffi.Uint8>, int, ffi.Pointer<ffi.Uint8>, int);
typedef _Pk32N =
    ffi.Int32 Function(
      ffi.Pointer<ffi.Uint8>,
      ffi.Size,
      ffi.Pointer<ffi.Uint8>,
      ffi.Size,
    );
typedef _Pk32D =
    int Function(ffi.Pointer<ffi.Uint8>, int, ffi.Pointer<ffi.Uint8>, int);
typedef _SignHashN =
    ffi.Int32 Function(
      ffi.Pointer<ffi.Uint8>,
      ffi.Size,
      ffi.Pointer<ffi.Uint8>,
      ffi.Size,
      ffi.Pointer<ffi.Uint8>,
      ffi.Size,
    );
typedef _SignHashD =
    int Function(
      ffi.Pointer<ffi.Uint8>,
      int,
      ffi.Pointer<ffi.Uint8>,
      int,
      ffi.Pointer<ffi.Uint8>,
      int,
    );
typedef _SignExN =
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
typedef _SignExD =
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
typedef _RecoverN =
    ffi.Int32 Function(
      ffi.Pointer<ffi.Uint8>,
      ffi.Pointer<ffi.Uint8>,
      ffi.Uint8,
      ffi.Pointer<ffi.Uint8>,
      ffi.Size,
    );
typedef _RecoverD =
    int Function(
      ffi.Pointer<ffi.Uint8>,
      ffi.Pointer<ffi.Uint8>,
      int,
      ffi.Pointer<ffi.Uint8>,
      int,
    );
typedef _SchnorrSignN =
    ffi.Int32 Function(
      ffi.Pointer<ffi.Uint8>,
      ffi.Size,
      ffi.Pointer<ffi.Uint8>,
      ffi.Size,
      ffi.Pointer<ffi.Uint8>,
      ffi.Size,
    );
typedef _SchnorrSignD =
    int Function(
      ffi.Pointer<ffi.Uint8>,
      int,
      ffi.Pointer<ffi.Uint8>,
      int,
      ffi.Pointer<ffi.Uint8>,
      int,
    );
typedef _SchnorrVerifyN =
    ffi.Int32 Function(
      ffi.Pointer<ffi.Uint8>,
      ffi.Size,
      ffi.Pointer<ffi.Uint8>,
      ffi.Size,
      ffi.Pointer<ffi.Uint8>,
      ffi.Size,
    );
typedef _SchnorrVerifyD =
    int Function(
      ffi.Pointer<ffi.Uint8>,
      int,
      ffi.Pointer<ffi.Uint8>,
      int,
      ffi.Pointer<ffi.Uint8>,
      int,
    );
typedef _EdVariantPkN =
    ffi.Int32 Function(
      ffi.Uint8,
      ffi.Pointer<ffi.Uint8>,
      ffi.Size,
      ffi.Pointer<ffi.Uint8>,
      ffi.Size,
    );
typedef _EdVariantPkD =
    int Function(int, ffi.Pointer<ffi.Uint8>, int, ffi.Pointer<ffi.Uint8>, int);
typedef _EdVariantSignN =
    ffi.Int32 Function(
      ffi.Uint8,
      ffi.Pointer<ffi.Uint8>,
      ffi.Size,
      ffi.Pointer<ffi.Uint8>,
      ffi.Size,
      ffi.Pointer<ffi.Uint8>,
      ffi.Size,
    );
typedef _EdVariantSignD =
    int Function(
      int,
      ffi.Pointer<ffi.Uint8>,
      int,
      ffi.Pointer<ffi.Uint8>,
      int,
      ffi.Pointer<ffi.Uint8>,
      int,
    );
typedef _EdVariantVerifyN =
    ffi.Int32 Function(
      ffi.Uint8,
      ffi.Pointer<ffi.Uint8>,
      ffi.Size,
      ffi.Pointer<ffi.Uint8>,
      ffi.Size,
      ffi.Pointer<ffi.Uint8>,
      ffi.Size,
    );
typedef _EdVariantVerifyD =
    int Function(
      int,
      ffi.Pointer<ffi.Uint8>,
      int,
      ffi.Pointer<ffi.Uint8>,
      int,
      ffi.Pointer<ffi.Uint8>,
      int,
    );
typedef _SchnorrSignAuxN =
    ffi.Int32 Function(
      ffi.Pointer<ffi.Uint8>,
      ffi.Size,
      ffi.Pointer<ffi.Uint8>,
      ffi.Size,
      ffi.Pointer<ffi.Uint8>,
      ffi.Pointer<ffi.Uint8>,
      ffi.Pointer<ffi.Uint8>,
      ffi.Size,
    );
typedef _SchnorrSignAuxD =
    int Function(
      ffi.Pointer<ffi.Uint8>,
      int,
      ffi.Pointer<ffi.Uint8>,
      int,
      ffi.Pointer<ffi.Uint8>,
      ffi.Pointer<ffi.Uint8>,
      ffi.Pointer<ffi.Uint8>,
      int,
    );
typedef _TweakN =
    ffi.Int32 Function(
      ffi.Pointer<ffi.Uint8>,
      ffi.Pointer<ffi.Uint8>,
      ffi.Pointer<ffi.Uint8>,
      ffi.Size,
    );
typedef _TweakD =
    int Function(
      ffi.Pointer<ffi.Uint8>,
      ffi.Pointer<ffi.Uint8>,
      ffi.Pointer<ffi.Uint8>,
      int,
    );
typedef _R1RecIdN =
    ffi.Int32 Function(
      ffi.Pointer<ffi.Uint8>,
      ffi.Pointer<ffi.Uint8>,
      ffi.Pointer<ffi.Uint8>,
      ffi.Size,
      ffi.Pointer<ffi.Uint8>,
    );
typedef _R1RecIdD =
    int Function(
      ffi.Pointer<ffi.Uint8>,
      ffi.Pointer<ffi.Uint8>,
      ffi.Pointer<ffi.Uint8>,
      int,
      ffi.Pointer<ffi.Uint8>,
    );
