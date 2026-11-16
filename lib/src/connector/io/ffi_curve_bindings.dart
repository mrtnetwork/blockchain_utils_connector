// ignore_for_file: library_private_types_in_public_api
// FFI typedefs are internal (never exported from blockchain_utils_connector.dart).
import 'dart:ffi' as ffi;

class BuCurveFfi {
  BuCurveFfi(ffi.DynamicLibrary lib)
    : pointLen = lib.lookupFunction<_LenN, _LenD>('bu_curve_point_len'),
      scalarLen = lib.lookupFunction<_LenN, _LenD>('bu_curve_scalar_len'),
      generator = lib.lookupFunction<_GenN, _GenD>('bu_curve_generator'),
      identity = lib.lookupFunction<_GenN, _GenD>('bu_curve_identity'),
      add = lib.lookupFunction<_BinN, _BinD>('bu_curve_add'),
      sub = lib.lookupFunction<_BinN, _BinD>('bu_curve_sub'),
      neg = lib.lookupFunction<_UnaryN, _UnaryD>('bu_curve_neg'),
      mul = lib.lookupFunction<_MulN, _MulD>('bu_curve_mul'),
      mulBase = lib.lookupFunction<_MulBaseN, _MulBaseD>('bu_curve_mul_base'),
      mulAdd = lib.lookupFunction<_MulAddN, _MulAddD>('bu_curve_mul_add'),
      generateSecret = lib.lookupFunction<_GenSecN, _GenSecD>(
        'bu_curve_generate_secret',
      ),
      scCheck = lib.lookupFunction<_ScCheckN, _ScCheckD>('bu_curve_sc_check'),
      scAdd = lib.lookupFunction<_BinN, _BinD>('bu_curve_sc_add'),
      scSub = lib.lookupFunction<_BinN, _BinD>('bu_curve_sc_sub'),
      scMul = lib.lookupFunction<_BinN, _BinD>('bu_curve_sc_mul'),
      scNeg = lib.lookupFunction<_UnaryN, _UnaryD>('bu_curve_sc_neg'),
      scReduce = lib.lookupFunction<_UnaryN, _UnaryD>('bu_curve_sc_reduce'),
      ed25519ScReduce32 = lib.lookupFunction<_EdScN, _EdScD>(
        'bu_ed25519_sc_reduce32',
      ),
      ed25519ScReduce64 = lib.lookupFunction<_EdScN, _EdScD>(
        'bu_ed25519_sc_reduce64',
      ),
      ed25519FromFeBytes = lib.lookupFunction<_EdScN, _EdScD>(
        'bu_ed25519_from_fe_bytes',
      ),
      ed25519FromFeBytesClearCofactor = lib.lookupFunction<_EdScN, _EdScD>(
        'bu_ed25519_from_fe_bytes_clear_cofactor',
      ),
      ed25519HashToEc = lib.lookupFunction<_EdScN, _EdScD>(
        'bu_ed25519_hash_to_ec',
      ),
      ed25519CheckKey = lib.lookupFunction<_EdCheckN, _EdCheckD>(
        'bu_ed25519_check_key',
      ),
      ed25519MulByCofactor = lib.lookupFunction<_EdScN, _EdScD>(
        'bu_ed25519_mul_by_cofactor',
      ),
      ed25519ScalarmultKeyImage = lib.lookupFunction<_EdKeyImgN, _EdKeyImgD>(
        'bu_ed25519_scalarmult_key_image',
      ),
      ed25519Mul8Mult = lib.lookupFunction<_EdKeyImgN, _EdKeyImgD>(
        'bu_ed25519_mul8_mult',
      ),
      ed25519GeDsmPrecomp = lib.lookupFunction<_EdScN, _EdScD>(
        'bu_ed25519_ge_dsm_precomp',
      ),
      ed25519GeDoubleScalarMultPrecomp = lib
          .lookupFunction<_EdDsmPreN, _EdDsmPreD>(
            'bu_ed25519_ge_double_scalar_mult_precomp',
          ),
      ed25519GeDoubleScalarMultBase = lib
          .lookupFunction<_EdDsmBaseN, _EdDsmBaseD>(
            'bu_ed25519_ge_double_scalar_mult_base',
          ),
      ed25519GeTripleScalarMultBase = lib
          .lookupFunction<_EdTsmBaseN, _EdTsmBaseD>(
            'bu_ed25519_ge_triple_scalar_mult_base',
          ),
      ed25519GeTripleScalarMultPrecomp = lib
          .lookupFunction<_EdTsmPreN, _EdTsmPreD>(
            'bu_ed25519_ge_triple_scalar_mult_precomp',
          ),
      jubjubScReduce64 = lib.lookupFunction<_EdScN, _EdScD>(
        'bu_jubjub_sc_reduce64',
      ),
      pallasScReduce64 = lib.lookupFunction<_EdScN, _EdScD>(
        'bu_pallas_sc_reduce64',
      ),
      vestaScReduce64 = lib.lookupFunction<_EdScN, _EdScD>(
        'bu_vesta_sc_reduce64',
      ),
      hashToG1 = lib.lookupFunction<_HashToN, _HashToD>('bu_bls_hash_to_g1'),
      hashToG2 = lib.lookupFunction<_HashToN, _HashToD>('bu_bls_hash_to_g2'),
      pallasHashToCurve = lib.lookupFunction<_HashToN, _HashToD>(
        'bu_pallas_hash_to_curve',
      ),
      pallasHashToCurvePasta = lib.lookupFunction<_HashToN, _HashToD>(
        'bu_pallas_hash_to_curve_pasta',
      ),
      vestaHashToCurve = lib.lookupFunction<_HashToN, _HashToD>(
        'bu_vesta_hash_to_curve',
      ),
      ed25519MulVartime = lib.lookupFunction<_EdVtMulN, _EdVtMulD>(
        'bu_ed25519_mul_vartime',
      ),
      ed25519MulBaseVartime = lib.lookupFunction<_EdVtBaseN, _EdVtBaseD>(
        'bu_ed25519_mul_base_vartime',
      ),
      ed25519MulAddVartime = lib.lookupFunction<_EdVtMulAddN, _EdVtMulAddD>(
        'bu_ed25519_mul_add_vartime',
      ),
      ed25519AddVartime = lib.lookupFunction<_EdVtBinN, _EdVtBinD>(
        'bu_ed25519_add_vartime',
      ),
      ed25519SubVartime = lib.lookupFunction<_EdVtBinN, _EdVtBinD>(
        'bu_ed25519_sub_vartime',
      ),
      ed25519NegVartime = lib.lookupFunction<_EdVtUnaryN, _EdVtUnaryD>(
        'bu_ed25519_neg_vartime',
      ),
      ed25519DoubleVartime = lib.lookupFunction<_EdVtUnaryN, _EdVtUnaryD>(
        'bu_ed25519_double_vartime',
      ),
      ristrettoFromEdwards = lib.lookupFunction<_EdScN, _EdScD>(
        'bu_ristretto_from_edwards',
      ),
      ristrettoToEdwards = lib.lookupFunction<_EdScN, _EdScD>(
        'bu_ristretto_to_edwards',
      ),
      pointLenUncomp = lib.lookupFunction<_LenN, _LenD>(
        'bu_curve_point_len_uncomp',
      ),
      compress = lib.lookupFunction<_UnaryN, _UnaryD>('bu_curve_compress'),
      uncompress = lib.lookupFunction<_UnaryN, _UnaryD>('bu_curve_uncompress'),
      normalizePubkey = lib.lookupFunction<_UnaryN, _UnaryD>(
        'bu_curve_normalize_pubkey',
      ),
      isInfinity = lib.lookupFunction<_IsInfN, _IsInfD>('bu_curve_is_infinity');

  final _LenD pointLen;
  final _LenD scalarLen;
  final _GenD generator;
  final _GenD identity;
  final _BinD add;
  final _BinD sub;
  final _UnaryD neg;
  final _MulD mul;
  final _MulBaseD mulBase;
  final _MulAddD mulAdd;
  final _GenSecD generateSecret;
  final _ScCheckD scCheck;
  final _BinD scAdd;
  final _BinD scSub;
  final _BinD scMul;
  final _UnaryD scNeg;
  final _UnaryD scReduce;
  final _EdScD ed25519ScReduce32;
  final _EdScD ed25519ScReduce64;
  final _EdScD ed25519FromFeBytes;
  final _EdScD ed25519FromFeBytesClearCofactor;
  final _EdScD ed25519HashToEc;
  final _EdCheckD ed25519CheckKey;
  final _EdScD ed25519MulByCofactor;
  final _EdKeyImgD ed25519ScalarmultKeyImage;
  final _EdKeyImgD ed25519Mul8Mult;
  final _EdScD ed25519GeDsmPrecomp;
  final _EdDsmPreD ed25519GeDoubleScalarMultPrecomp;
  final _EdDsmBaseD ed25519GeDoubleScalarMultBase;
  final _EdTsmBaseD ed25519GeTripleScalarMultBase;
  final _EdTsmPreD ed25519GeTripleScalarMultPrecomp;
  final _EdScD jubjubScReduce64;
  final _EdScD pallasScReduce64;
  final _EdScD vestaScReduce64;
  final _HashToD hashToG1;
  final _HashToD hashToG2;
  final _HashToD pallasHashToCurve;
  final _HashToD pallasHashToCurvePasta;
  final _HashToD vestaHashToCurve;
  final _EdVtMulD ed25519MulVartime;
  final _EdVtBaseD ed25519MulBaseVartime;
  final _EdVtMulAddD ed25519MulAddVartime;
  final _EdVtBinD ed25519AddVartime;
  final _EdVtBinD ed25519SubVartime;
  final _EdVtUnaryD ed25519NegVartime;
  final _EdVtUnaryD ed25519DoubleVartime;
  final _EdScD ristrettoFromEdwards;
  final _EdScD ristrettoToEdwards;
  final _LenD pointLenUncomp;
  final _UnaryD compress;
  final _UnaryD uncompress;
  final _UnaryD normalizePubkey;
  final _IsInfD isInfinity;
}

typedef _IsInfN =
    ffi.Int32 Function(ffi.Uint32, ffi.Pointer<ffi.Uint8>, ffi.Size);
typedef _IsInfD = int Function(int, ffi.Pointer<ffi.Uint8>, int);

typedef _LenN = ffi.Size Function(ffi.Uint32);
typedef _LenD = int Function(int);
typedef _GenN =
    ffi.Int32 Function(ffi.Uint32, ffi.Pointer<ffi.Uint8>, ffi.Size);
typedef _GenD = int Function(int, ffi.Pointer<ffi.Uint8>, int);
typedef _UnaryN =
    ffi.Int32 Function(
      ffi.Uint32,
      ffi.Pointer<ffi.Uint8>,
      ffi.Size,
      ffi.Pointer<ffi.Uint8>,
      ffi.Size,
    );
typedef _UnaryD =
    int Function(int, ffi.Pointer<ffi.Uint8>, int, ffi.Pointer<ffi.Uint8>, int);
typedef _BinN =
    ffi.Int32 Function(
      ffi.Uint32,
      ffi.Pointer<ffi.Uint8>,
      ffi.Size,
      ffi.Pointer<ffi.Uint8>,
      ffi.Size,
      ffi.Pointer<ffi.Uint8>,
      ffi.Size,
    );
typedef _BinD =
    int Function(
      int,
      ffi.Pointer<ffi.Uint8>,
      int,
      ffi.Pointer<ffi.Uint8>,
      int,
      ffi.Pointer<ffi.Uint8>,
      int,
    );
typedef _MulN =
    ffi.Int32 Function(
      ffi.Uint32,
      ffi.Pointer<ffi.Uint8>,
      ffi.Size,
      ffi.Pointer<ffi.Uint8>,
      ffi.Size,
      ffi.Pointer<ffi.Uint8>,
      ffi.Size,
    );
typedef _MulD =
    int Function(
      int,
      ffi.Pointer<ffi.Uint8>,
      int,
      ffi.Pointer<ffi.Uint8>,
      int,
      ffi.Pointer<ffi.Uint8>,
      int,
    );
typedef _MulBaseN =
    ffi.Int32 Function(
      ffi.Uint32,
      ffi.Pointer<ffi.Uint8>,
      ffi.Size,
      ffi.Pointer<ffi.Uint8>,
      ffi.Size,
    );
typedef _MulBaseD =
    int Function(int, ffi.Pointer<ffi.Uint8>, int, ffi.Pointer<ffi.Uint8>, int);
typedef _MulAddN =
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
typedef _MulAddD =
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
typedef _GenSecN =
    ffi.Int32 Function(
      ffi.Uint32,
      ffi.Pointer<ffi.Uint8>,
      ffi.Size,
      ffi.Pointer<ffi.Uint8>,
      ffi.Size,
    );
typedef _GenSecD =
    int Function(int, ffi.Pointer<ffi.Uint8>, int, ffi.Pointer<ffi.Uint8>, int);
typedef _ScCheckN =
    ffi.Int32 Function(ffi.Uint32, ffi.Pointer<ffi.Uint8>, ffi.Size);
typedef _ScCheckD = int Function(int, ffi.Pointer<ffi.Uint8>, int);
typedef _HashToN =
    ffi.Int32 Function(
      ffi.Pointer<ffi.Uint8>,
      ffi.Size,
      ffi.Pointer<ffi.Uint8>,
      ffi.Size,
      ffi.Pointer<ffi.Uint8>,
      ffi.Size,
    );
typedef _HashToD =
    int Function(
      ffi.Pointer<ffi.Uint8>,
      int,
      ffi.Pointer<ffi.Uint8>,
      int,
      ffi.Pointer<ffi.Uint8>,
      int,
    );
typedef _EdScN =
    ffi.Int32 Function(
      ffi.Pointer<ffi.Uint8>,
      ffi.Size,
      ffi.Pointer<ffi.Uint8>,
      ffi.Size,
    );
typedef _EdScD =
    int Function(ffi.Pointer<ffi.Uint8>, int, ffi.Pointer<ffi.Uint8>, int);

typedef _EdCheckN = ffi.Int32 Function(ffi.Pointer<ffi.Uint8>, ffi.Size);
typedef _EdCheckD = int Function(ffi.Pointer<ffi.Uint8>, int);
typedef _EdKeyImgN =
    ffi.Int32 Function(
      ffi.Pointer<ffi.Uint8>,
      ffi.Size,
      ffi.Pointer<ffi.Uint8>,
      ffi.Size,
      ffi.Pointer<ffi.Uint8>,
      ffi.Size,
    );
typedef _EdKeyImgD =
    int Function(
      ffi.Pointer<ffi.Uint8>,
      int,
      ffi.Pointer<ffi.Uint8>,
      int,
      ffi.Pointer<ffi.Uint8>,
      int,
    );
typedef _EdDsmPreN =
    ffi.Int32 Function(
      ffi.Pointer<ffi.Uint8>,
      ffi.Pointer<ffi.Uint8>,
      ffi.Pointer<ffi.Uint8>,
      ffi.Pointer<ffi.Uint8>,
      ffi.Pointer<ffi.Uint8>,
      ffi.Size,
    );
typedef _EdDsmPreD =
    int Function(
      ffi.Pointer<ffi.Uint8>,
      ffi.Pointer<ffi.Uint8>,
      ffi.Pointer<ffi.Uint8>,
      ffi.Pointer<ffi.Uint8>,
      ffi.Pointer<ffi.Uint8>,
      int,
    );
typedef _EdDsmBaseN =
    ffi.Int32 Function(
      ffi.Pointer<ffi.Uint8>,
      ffi.Pointer<ffi.Uint8>,
      ffi.Pointer<ffi.Uint8>,
      ffi.Pointer<ffi.Uint8>,
      ffi.Size,
    );
typedef _EdDsmBaseD =
    int Function(
      ffi.Pointer<ffi.Uint8>,
      ffi.Pointer<ffi.Uint8>,
      ffi.Pointer<ffi.Uint8>,
      ffi.Pointer<ffi.Uint8>,
      int,
    );
typedef _EdTsmBaseN =
    ffi.Int32 Function(
      ffi.Pointer<ffi.Uint8>,
      ffi.Pointer<ffi.Uint8>,
      ffi.Pointer<ffi.Uint8>,
      ffi.Pointer<ffi.Uint8>,
      ffi.Pointer<ffi.Uint8>,
      ffi.Pointer<ffi.Uint8>,
      ffi.Size,
    );
typedef _EdTsmBaseD =
    int Function(
      ffi.Pointer<ffi.Uint8>,
      ffi.Pointer<ffi.Uint8>,
      ffi.Pointer<ffi.Uint8>,
      ffi.Pointer<ffi.Uint8>,
      ffi.Pointer<ffi.Uint8>,
      ffi.Pointer<ffi.Uint8>,
      int,
    );
typedef _EdTsmPreN =
    ffi.Int32 Function(
      ffi.Pointer<ffi.Uint8>,
      ffi.Pointer<ffi.Uint8>,
      ffi.Pointer<ffi.Uint8>,
      ffi.Pointer<ffi.Uint8>,
      ffi.Pointer<ffi.Uint8>,
      ffi.Pointer<ffi.Uint8>,
      ffi.Pointer<ffi.Uint8>,
      ffi.Size,
    );
typedef _EdTsmPreD =
    int Function(
      ffi.Pointer<ffi.Uint8>,
      ffi.Pointer<ffi.Uint8>,
      ffi.Pointer<ffi.Uint8>,
      ffi.Pointer<ffi.Uint8>,
      ffi.Pointer<ffi.Uint8>,
      ffi.Pointer<ffi.Uint8>,
      ffi.Pointer<ffi.Uint8>,
      int,
    );

typedef _EdVtMulN =
    ffi.Int32 Function(
      ffi.Pointer<ffi.Uint8>,
      ffi.Pointer<ffi.Uint8>,
      ffi.Pointer<ffi.Uint8>,
    );
typedef _EdVtMulD =
    int Function(
      ffi.Pointer<ffi.Uint8>,
      ffi.Pointer<ffi.Uint8>,
      ffi.Pointer<ffi.Uint8>,
    );
typedef _EdVtBaseN =
    ffi.Int32 Function(ffi.Pointer<ffi.Uint8>, ffi.Pointer<ffi.Uint8>);
typedef _EdVtBaseD =
    int Function(ffi.Pointer<ffi.Uint8>, ffi.Pointer<ffi.Uint8>);
typedef _EdVtMulAddN =
    ffi.Int32 Function(
      ffi.Pointer<ffi.Uint8>,
      ffi.Pointer<ffi.Uint8>,
      ffi.Pointer<ffi.Uint8>,
      ffi.Pointer<ffi.Uint8>,
      ffi.Pointer<ffi.Uint8>,
    );
typedef _EdVtMulAddD =
    int Function(
      ffi.Pointer<ffi.Uint8>,
      ffi.Pointer<ffi.Uint8>,
      ffi.Pointer<ffi.Uint8>,
      ffi.Pointer<ffi.Uint8>,
      ffi.Pointer<ffi.Uint8>,
    );
typedef _EdVtBinN =
    ffi.Int32 Function(
      ffi.Pointer<ffi.Uint8>,
      ffi.Pointer<ffi.Uint8>,
      ffi.Pointer<ffi.Uint8>,
    );
typedef _EdVtBinD =
    int Function(
      ffi.Pointer<ffi.Uint8>,
      ffi.Pointer<ffi.Uint8>,
      ffi.Pointer<ffi.Uint8>,
    );
typedef _EdVtUnaryN =
    ffi.Int32 Function(ffi.Pointer<ffi.Uint8>, ffi.Pointer<ffi.Uint8>);
typedef _EdVtUnaryD =
    int Function(ffi.Pointer<ffi.Uint8>, ffi.Pointer<ffi.Uint8>);
