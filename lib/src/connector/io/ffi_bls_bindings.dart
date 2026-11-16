// ignore_for_file: library_private_types_in_public_api
// FFI typedefs are internal (never exported from blockchain_utils_connector.dart).
import 'dart:ffi' as ffi;

/// Raw BLS12-381 FFI symbols.
class BuBlsFfi {
  BuBlsFfi._({
    required this.skToPkG1,
    required this.skToPkG2,
    required this.signMinPk,
    required this.signMinSig,
    required this.verifyMinPk,
    required this.verifyMinSig,
    required this.aggregatePksG1,
    required this.aggregatePksG2,
    required this.aggregateSigsG1,
    required this.aggregateSigsG2,
    required this.fastAggVerifyMinPk,
    required this.fastAggVerifyMinSig,
    required this.aggregateVerifyMinPk,
    required this.aggregateVerifyMinSig,
    required this.batchVerifyMinPk,
    required this.batchVerifyMinSig,
  });

  factory BuBlsFfi(ffi.DynamicLibrary lib) {
    return BuBlsFfi._(
      skToPkG1: lib.lookupFunction<_SkPkN, _SkPkD>('bu_bls_sk_to_pk_g1'),
      skToPkG2: lib.lookupFunction<_SkPkN, _SkPkD>('bu_bls_sk_to_pk_g2'),
      signMinPk: lib.lookupFunction<_SignN, _SignD>('bu_bls_sign_min_pk'),
      signMinSig: lib.lookupFunction<_SignN, _SignD>('bu_bls_sign_min_sig'),
      verifyMinPk: lib.lookupFunction<_VerifyN, _VerifyD>(
        'bu_bls_verify_min_pk',
      ),
      verifyMinSig: lib.lookupFunction<_VerifyN, _VerifyD>(
        'bu_bls_verify_min_sig',
      ),
      aggregatePksG1: lib.lookupFunction<_AggN, _AggD>(
        'bu_bls_aggregate_pks_g1',
      ),
      aggregatePksG2: lib.lookupFunction<_AggN, _AggD>(
        'bu_bls_aggregate_pks_g2',
      ),
      aggregateSigsG1: lib.lookupFunction<_AggN, _AggD>(
        'bu_bls_aggregate_sigs_g1',
      ),
      aggregateSigsG2: lib.lookupFunction<_AggN, _AggD>(
        'bu_bls_aggregate_sigs_g2',
      ),
      fastAggVerifyMinPk: lib.lookupFunction<_VerifyN, _VerifyD>(
        'bu_bls_fast_aggregate_verify_min_pk',
      ),
      fastAggVerifyMinSig: lib.lookupFunction<_VerifyN, _VerifyD>(
        'bu_bls_fast_aggregate_verify_min_sig',
      ),
      aggregateVerifyMinPk: lib.lookupFunction<_AggVerifyN, _AggVerifyD>(
        'bu_bls_aggregate_verify_min_pk',
      ),
      aggregateVerifyMinSig: lib.lookupFunction<_AggVerifyN, _AggVerifyD>(
        'bu_bls_aggregate_verify_min_sig',
      ),
      batchVerifyMinPk: lib.lookupFunction<_BatchVerifyN, _BatchVerifyD>(
        'bu_bls_batch_verify_min_pk',
      ),
      batchVerifyMinSig: lib.lookupFunction<_BatchVerifyN, _BatchVerifyD>(
        'bu_bls_batch_verify_min_sig',
      ),
    );
  }

  final _SkPkD skToPkG1;
  final _SkPkD skToPkG2;
  final _SignD signMinPk;
  final _SignD signMinSig;
  final _VerifyD verifyMinPk;
  final _VerifyD verifyMinSig;
  final _AggD aggregatePksG1;
  final _AggD aggregatePksG2;
  final _AggD aggregateSigsG1;
  final _AggD aggregateSigsG2;
  final _VerifyD fastAggVerifyMinPk;
  final _VerifyD fastAggVerifyMinSig;
  final _AggVerifyD aggregateVerifyMinPk;
  final _AggVerifyD aggregateVerifyMinSig;
  final _BatchVerifyD batchVerifyMinPk;
  final _BatchVerifyD batchVerifyMinSig;
}

typedef _SkPkN =
    ffi.Int32 Function(
      ffi.Pointer<ffi.Uint8>,
      ffi.Size,
      ffi.Pointer<ffi.Uint8>,
      ffi.Size,
    );
typedef _SkPkD =
    int Function(ffi.Pointer<ffi.Uint8>, int, ffi.Pointer<ffi.Uint8>, int);

typedef _SignN =
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
typedef _SignD =
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

typedef _AggN =
    ffi.Int32 Function(
      ffi.Pointer<ffi.Uint8>,
      ffi.Size,
      ffi.Pointer<ffi.Uint8>,
      ffi.Size,
    );
typedef _AggD =
    int Function(ffi.Pointer<ffi.Uint8>, int, ffi.Pointer<ffi.Uint8>, int);

typedef _AggVerifyN =
    ffi.Int32 Function(
      ffi.Pointer<ffi.Uint8>,
      ffi.Size,
      ffi.Pointer<ffi.Uint8>,
      ffi.Size,
      ffi.Size,
      ffi.Pointer<ffi.Uint8>,
      ffi.Size,
      ffi.Pointer<ffi.Uint8>,
      ffi.Size,
    );
typedef _AggVerifyD =
    int Function(
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

typedef _BatchVerifyN =
    ffi.Int32 Function(
      ffi.Pointer<ffi.Uint8>,
      ffi.Size,
      ffi.Pointer<ffi.Uint8>,
      ffi.Size,
      ffi.Size,
      ffi.Pointer<ffi.Uint8>,
      ffi.Size,
      ffi.Pointer<ffi.Uint8>,
      ffi.Size,
    );
typedef _BatchVerifyD =
    int Function(
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
