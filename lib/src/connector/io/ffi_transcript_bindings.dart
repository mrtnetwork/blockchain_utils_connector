// ignore_for_file: library_private_types_in_public_api
// FFI typedefs are internal (never exported from blockchain_utils_connector.dart).
import 'dart:ffi' as ffi;

/// Merlin transcript + Strobe context C bindings (`ffi::transcript`).
class BuTranscriptFfi {
  BuTranscriptFfi(ffi.DynamicLibrary lib)
    : merlinNew = lib.lookupFunction<_MerlinNewN, _MerlinNewD>('bu_merlin_new'),
      merlinAppend = lib.lookupFunction<_MerlinAppendN, _MerlinAppendD>(
        'bu_merlin_append',
      ),
      merlinChallenge = lib
          .lookupFunction<_MerlinChallengeN, _MerlinChallengeD>(
            'bu_merlin_challenge',
          ),
      merlinFork = lib.lookupFunction<_MerlinForkN, _MerlinForkD>(
        'bu_merlin_fork',
      ),
      merlinFree = lib.lookupFunction<_MerlinFreeN, _MerlinFreeD>(
        'bu_merlin_free',
      ),
      strobeNew = lib.lookupFunction<_MerlinNewN, _MerlinNewD>('bu_strobe_new'),
      strobeAd = lib.lookupFunction<_StrobeAdN, _StrobeAdD>('bu_strobe_ad'),
      strobeKey = lib.lookupFunction<_StrobeKeyN, _StrobeKeyD>('bu_strobe_key'),
      strobePrf = lib.lookupFunction<_StrobePrfN, _StrobePrfD>('bu_strobe_prf'),
      strobeFree = lib.lookupFunction<_MerlinFreeN, _MerlinFreeD>(
        'bu_strobe_free',
      );

  final _MerlinNewD merlinNew;
  final _MerlinAppendD merlinAppend;
  final _MerlinChallengeD merlinChallenge;
  final _MerlinForkD merlinFork;
  final _MerlinFreeD merlinFree;
  final _MerlinNewD strobeNew;
  final _StrobeAdD strobeAd;
  final _StrobeKeyD strobeKey;
  final _StrobePrfD strobePrf;
  final _MerlinFreeD strobeFree;
}

typedef _MerlinNewN =
    ffi.Pointer<ffi.Void> Function(ffi.Pointer<ffi.Uint8>, ffi.Size);
typedef _MerlinNewD =
    ffi.Pointer<ffi.Void> Function(ffi.Pointer<ffi.Uint8>, int);
typedef _MerlinAppendN =
    ffi.Int32 Function(
      ffi.Pointer<ffi.Void>,
      ffi.Pointer<ffi.Uint8>,
      ffi.Size,
      ffi.Pointer<ffi.Uint8>,
      ffi.Size,
    );
typedef _MerlinAppendD =
    int Function(
      ffi.Pointer<ffi.Void>,
      ffi.Pointer<ffi.Uint8>,
      int,
      ffi.Pointer<ffi.Uint8>,
      int,
    );
typedef _MerlinChallengeN =
    ffi.Int32 Function(
      ffi.Pointer<ffi.Void>,
      ffi.Pointer<ffi.Uint8>,
      ffi.Size,
      ffi.Pointer<ffi.Uint8>,
      ffi.Size,
    );
typedef _MerlinChallengeD =
    int Function(
      ffi.Pointer<ffi.Void>,
      ffi.Pointer<ffi.Uint8>,
      int,
      ffi.Pointer<ffi.Uint8>,
      int,
    );
typedef _MerlinForkN = ffi.Pointer<ffi.Void> Function(ffi.Pointer<ffi.Void>);
typedef _MerlinForkD = ffi.Pointer<ffi.Void> Function(ffi.Pointer<ffi.Void>);
typedef _MerlinFreeN = ffi.Void Function(ffi.Pointer<ffi.Void>);
typedef _MerlinFreeD = void Function(ffi.Pointer<ffi.Void>);
typedef _StrobeAdN =
    ffi.Int32 Function(
      ffi.Pointer<ffi.Void>,
      ffi.Uint8,
      ffi.Pointer<ffi.Uint8>,
      ffi.Size,
    );
typedef _StrobeAdD =
    int Function(ffi.Pointer<ffi.Void>, int, ffi.Pointer<ffi.Uint8>, int);
typedef _StrobeKeyN =
    ffi.Int32 Function(ffi.Pointer<ffi.Void>, ffi.Pointer<ffi.Uint8>, ffi.Size);
typedef _StrobeKeyD =
    int Function(ffi.Pointer<ffi.Void>, ffi.Pointer<ffi.Uint8>, int);
typedef _StrobePrfN =
    ffi.Int32 Function(ffi.Pointer<ffi.Void>, ffi.Pointer<ffi.Uint8>, ffi.Size);
typedef _StrobePrfD =
    int Function(ffi.Pointer<ffi.Void>, ffi.Pointer<ffi.Uint8>, int);
