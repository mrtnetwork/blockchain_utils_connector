// ignore_for_file: library_private_types_in_public_api
// FFI typedefs are internal (never exported from blockchain_utils_connector.dart).
import 'dart:ffi' as ffi;

class BuMusig2Ffi {
  BuMusig2Ffi._({
    required this.keyAgg,
    required this.keyAggTweak,
    required this.nonceGen,
    required this.nonceAgg,
    required this.partialSign,
    required this.partialSigAgg,
    required this.partialSigVerify,
    required this.deterministicSign,
    required this.verifyAggregate,
  });

  factory BuMusig2Ffi(ffi.DynamicLibrary lib) {
    return BuMusig2Ffi._(
      keyAgg: lib.lookupFunction<_KeyAggN, _KeyAggD>('bu_musig2_key_agg'),
      keyAggTweak: lib.lookupFunction<_KeyAggTweakN, _KeyAggTweakD>(
        'bu_musig2_key_agg_tweak',
      ),
      nonceGen: lib.lookupFunction<_NonceGenN, _NonceGenD>(
        'bu_musig2_nonce_gen',
      ),
      nonceAgg: lib.lookupFunction<_NonceAggN, _NonceAggD>(
        'bu_musig2_nonce_agg',
      ),
      partialSign: lib.lookupFunction<_PartialSignN, _PartialSignD>(
        'bu_musig2_partial_sign',
      ),
      partialSigAgg: lib.lookupFunction<_PartialAggN, _PartialAggD>(
        'bu_musig2_partial_sig_agg',
      ),
      partialSigVerify: lib.lookupFunction<_PartialVerifyN, _PartialVerifyD>(
        'bu_musig2_partial_sig_verify',
      ),
      deterministicSign: lib.lookupFunction<_DetSignN, _DetSignD>(
        'bu_musig2_deterministic_sign',
      ),
      verifyAggregate: lib.lookupFunction<_VerifyAggN, _VerifyAggD>(
        'bu_musig2_verify_aggregate',
      ),
    );
  }

  final _KeyAggD keyAgg;
  final _KeyAggTweakD keyAggTweak;
  final _NonceGenD nonceGen;
  final _NonceAggD nonceAgg;
  final _PartialSignD partialSign;
  final _PartialAggD partialSigAgg;
  final _PartialVerifyD partialSigVerify;
  final _DetSignD deterministicSign;
  final _VerifyAggD verifyAggregate;
}

typedef _KeyAggN =
    ffi.Int32 Function(
      ffi.Pointer<ffi.Uint8>,
      ffi.Size,
      ffi.Pointer<ffi.Uint8>,
      ffi.Size,
    );
typedef _KeyAggD =
    int Function(ffi.Pointer<ffi.Uint8>, int, ffi.Pointer<ffi.Uint8>, int);

typedef _KeyAggTweakN =
    ffi.Int32 Function(
      ffi.Pointer<ffi.Uint8>,
      ffi.Size,
      ffi.Pointer<ffi.Uint8>,
      ffi.Size,
      ffi.Pointer<ffi.Uint8>,
      ffi.Size,
    );
typedef _KeyAggTweakD =
    int Function(
      ffi.Pointer<ffi.Uint8>,
      int,
      ffi.Pointer<ffi.Uint8>,
      int,
      ffi.Pointer<ffi.Uint8>,
      int,
    );

typedef _NonceGenN =
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
      ffi.Pointer<ffi.Uint8>,
      ffi.Pointer<ffi.Uint8>,
      ffi.Size,
      ffi.Pointer<ffi.Uint8>,
      ffi.Size,
    );
typedef _NonceGenD =
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
      ffi.Pointer<ffi.Uint8>,
      ffi.Pointer<ffi.Uint8>,
      int,
      ffi.Pointer<ffi.Uint8>,
      int,
    );

typedef _NonceAggN =
    ffi.Int32 Function(
      ffi.Pointer<ffi.Uint8>,
      ffi.Size,
      ffi.Pointer<ffi.Uint8>,
      ffi.Size,
    );
typedef _NonceAggD =
    int Function(ffi.Pointer<ffi.Uint8>, int, ffi.Pointer<ffi.Uint8>, int);

typedef _PartialSignN =
    ffi.Int32 Function(
      ffi.Pointer<ffi.Uint8>,
      ffi.Size,
      ffi.Pointer<ffi.Uint8>,
      ffi.Size,
      ffi.Pointer<ffi.Uint8>,
      ffi.Size,
      ffi.Pointer<ffi.Uint8>,
      ffi.Pointer<ffi.Uint8>,
      ffi.Size,
      ffi.Pointer<ffi.Uint8>,
      ffi.Size,
      ffi.Pointer<ffi.Uint8>,
      ffi.Size,
    );
typedef _PartialSignD =
    int Function(
      ffi.Pointer<ffi.Uint8>,
      int,
      ffi.Pointer<ffi.Uint8>,
      int,
      ffi.Pointer<ffi.Uint8>,
      int,
      ffi.Pointer<ffi.Uint8>,
      ffi.Pointer<ffi.Uint8>,
      int,
      ffi.Pointer<ffi.Uint8>,
      int,
      ffi.Pointer<ffi.Uint8>,
      int,
    );

typedef _PartialAggN =
    ffi.Int32 Function(
      ffi.Pointer<ffi.Uint8>,
      ffi.Size,
      ffi.Pointer<ffi.Uint8>,
      ffi.Size,
      ffi.Pointer<ffi.Uint8>,
      ffi.Pointer<ffi.Uint8>,
      ffi.Size,
      ffi.Pointer<ffi.Uint8>,
      ffi.Size,
      ffi.Pointer<ffi.Uint8>,
      ffi.Size,
    );
typedef _PartialAggD =
    int Function(
      ffi.Pointer<ffi.Uint8>,
      int,
      ffi.Pointer<ffi.Uint8>,
      int,
      ffi.Pointer<ffi.Uint8>,
      ffi.Pointer<ffi.Uint8>,
      int,
      ffi.Pointer<ffi.Uint8>,
      int,
      ffi.Pointer<ffi.Uint8>,
      int,
    );

typedef _PartialVerifyN =
    ffi.Int32 Function(
      ffi.Pointer<ffi.Uint8>,
      ffi.Pointer<ffi.Uint8>,
      ffi.Pointer<ffi.Uint8>,
      ffi.Pointer<ffi.Uint8>,
      ffi.Size,
      ffi.Pointer<ffi.Uint8>,
      ffi.Pointer<ffi.Uint8>,
      ffi.Size,
      ffi.Pointer<ffi.Uint8>,
      ffi.Size,
    );
typedef _PartialVerifyD =
    int Function(
      ffi.Pointer<ffi.Uint8>,
      ffi.Pointer<ffi.Uint8>,
      ffi.Pointer<ffi.Uint8>,
      ffi.Pointer<ffi.Uint8>,
      int,
      ffi.Pointer<ffi.Uint8>,
      ffi.Pointer<ffi.Uint8>,
      int,
      ffi.Pointer<ffi.Uint8>,
      int,
    );

typedef _DetSignN =
    ffi.Int32 Function(
      ffi.Pointer<ffi.Uint8>, // sk
      ffi.Pointer<ffi.Uint8>, // aggother
      ffi.Pointer<ffi.Uint8>, // keys
      ffi.Size, // n_keys
      ffi.Pointer<ffi.Uint8>, // msg
      ffi.Size, // msg_len
      ffi.Pointer<ffi.Uint8>, // tweaks
      ffi.Size, // n_tweaks
      ffi.Pointer<ffi.Uint8>, // rand
      ffi.Pointer<ffi.Uint8>, // pubnonce_out
      ffi.Pointer<ffi.Uint8>, // partial_out
    );
typedef _DetSignD =
    int Function(
      ffi.Pointer<ffi.Uint8>,
      ffi.Pointer<ffi.Uint8>,
      ffi.Pointer<ffi.Uint8>,
      int,
      ffi.Pointer<ffi.Uint8>,
      int,
      ffi.Pointer<ffi.Uint8>,
      int,
      ffi.Pointer<ffi.Uint8>,
      ffi.Pointer<ffi.Uint8>,
      ffi.Pointer<ffi.Uint8>,
    );

typedef _VerifyAggN =
    ffi.Int32 Function(
      ffi.Pointer<ffi.Uint8>,
      ffi.Size,
      ffi.Pointer<ffi.Uint8>,
      ffi.Size,
      ffi.Pointer<ffi.Uint8>,
      ffi.Size,
    );
typedef _VerifyAggD =
    int Function(
      ffi.Pointer<ffi.Uint8>,
      int,
      ffi.Pointer<ffi.Uint8>,
      int,
      ffi.Pointer<ffi.Uint8>,
      int,
    );
