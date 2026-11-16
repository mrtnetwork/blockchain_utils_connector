// ignore_for_file: library_private_types_in_public_api
// FFI typedefs are internal (never exported from blockchain_utils_connector.dart).
import 'dart:ffi' as ffi;

typedef _Poseidon2N =
    ffi.Int32 Function(
      ffi.Pointer<ffi.Uint8>,
      ffi.Size,
      ffi.Pointer<ffi.Uint8>,
      ffi.Size,
      ffi.Pointer<ffi.Uint8>,
      ffi.Size,
    );
typedef _Poseidon2D =
    int Function(
      ffi.Pointer<ffi.Uint8>,
      int,
      ffi.Pointer<ffi.Uint8>,
      int,
      ffi.Pointer<ffi.Uint8>,
      int,
    );

typedef _PoseidonN =
    ffi.Int32 Function(
      ffi.Pointer<ffi.Uint8>,
      ffi.Size,
      ffi.Size,
      ffi.Pointer<ffi.Uint8>,
      ffi.Size,
    );
typedef _PoseidonD =
    int Function(ffi.Pointer<ffi.Uint8>, int, int, ffi.Pointer<ffi.Uint8>, int);

// Same shape as [_PoseidonN]/[_PoseidonD]; the symbol only exists in
// native builds with the Rust `poseidon-bn254` feature, so it is
// looked up optionally (see [BuZcashFfi.poseidonBn254Hash]).
typedef _PoseidonBn254N =
    ffi.Int32 Function(
      ffi.Pointer<ffi.Uint8>,
      ffi.Size,
      ffi.Size,
      ffi.Pointer<ffi.Uint8>,
      ffi.Size,
    );
typedef _PoseidonBn254D =
    int Function(ffi.Pointer<ffi.Uint8>, int, int, ffi.Pointer<ffi.Uint8>, int);

typedef _SinsHashN =
    ffi.Int32 Function(
      ffi.Pointer<ffi.Uint8>,
      ffi.Size,
      ffi.Pointer<ffi.Uint8>,
      ffi.Size,
      ffi.Size,
      ffi.Pointer<ffi.Uint8>,
      ffi.Size,
    );
typedef _SinsHashD =
    int Function(
      ffi.Pointer<ffi.Uint8>,
      int,
      ffi.Pointer<ffi.Uint8>,
      int,
      int,
      ffi.Pointer<ffi.Uint8>,
      int,
    );

typedef _SinsCommitN =
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
typedef _SinsCommitD =
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

typedef _PermuteN = ffi.Int32 Function(ffi.Pointer<ffi.Uint8>, ffi.Size);
typedef _PermuteD = int Function(ffi.Pointer<ffi.Uint8>, int);

typedef _SinsBitstringN =
    ffi.Int32 Function(
      ffi.Pointer<ffi.Uint8>,
      ffi.Size,
      ffi.Pointer<ffi.Uint8>,
      ffi.Size,
      ffi.Pointer<ffi.Uint8>,
      ffi.Size,
    );
typedef _SinsBitstringD =
    int Function(
      ffi.Pointer<ffi.Uint8>,
      int,
      ffi.Pointer<ffi.Uint8>,
      int,
      ffi.Pointer<ffi.Uint8>,
      int,
    );

typedef _PedersenN =
    ffi.Int32 Function(
      ffi.Uint32,
      ffi.Uint8,
      ffi.Pointer<ffi.Uint8>,
      ffi.Size,
      ffi.Size,
      ffi.Pointer<ffi.Uint8>,
      ffi.Size,
    );
typedef _PedersenD =
    int Function(
      int,
      int,
      ffi.Pointer<ffi.Uint8>,
      int,
      int,
      ffi.Pointer<ffi.Uint8>,
      int,
    );

typedef _PedersenStrN =
    ffi.Int32 Function(
      ffi.Uint32,
      ffi.Uint8,
      ffi.Pointer<ffi.Uint8>,
      ffi.Size,
      ffi.Pointer<ffi.Uint8>,
      ffi.Size,
    );
typedef _PedersenStrD =
    int Function(
      int,
      int,
      ffi.Pointer<ffi.Uint8>,
      int,
      ffi.Pointer<ffi.Uint8>,
      int,
    );

class BuZcashFfi {
  /// Looks up `bu_poseidon_bn254_hash` without throwing when the loaded
  /// library was built without the Rust `poseidon-bn254` feature.
  /// (Kept as a concrete-typedef call: `lookupFunction` needs static
  /// function types, so this cannot go through a generic helper.)
  static _PoseidonBn254D? _lookupBn254(ffi.DynamicLibrary lib) {
    try {
      return lib.lookupFunction<_PoseidonBn254N, _PoseidonBn254D>(
        'bu_poseidon_bn254_hash',
      );
    } catch (_) {
      return null;
    }
  }

  BuZcashFfi(ffi.DynamicLibrary lib)
    : poseidonHashTwo = lib.lookupFunction<_Poseidon2N, _Poseidon2D>(
        'bu_poseidon_hash_two',
      ),
      poseidonHash = lib.lookupFunction<_PoseidonN, _PoseidonD>(
        'bu_poseidon_hash',
      ),
      sinsemillaHashBits = lib.lookupFunction<_SinsHashN, _SinsHashD>(
        'bu_sinsemilla_hash_bits',
      ),
      sinsemillaCommit = lib.lookupFunction<_SinsCommitN, _SinsCommitD>(
        'bu_sinsemilla_commit',
      ),
      sinsemillaShortCommit = lib.lookupFunction<_SinsCommitN, _SinsCommitD>(
        'bu_sinsemilla_short_commit',
      ),
      poseidonPermute = lib.lookupFunction<_PermuteN, _PermuteD>(
        'bu_poseidon_permute',
      ),
      sinsemillaHashBitstring = lib
          .lookupFunction<_SinsBitstringN, _SinsBitstringD>(
            'bu_sinsemilla_hash_bitstring',
          ),
      pedersenHash = lib.lookupFunction<_PedersenN, _PedersenD>(
        'bu_pedersen_hash',
      ),
      pedersenHashBitstring = lib.lookupFunction<_PedersenStrN, _PedersenStrD>(
        'bu_pedersen_hash_bitstring',
      ),
      poseidonBn254Hash = _lookupBn254(lib);

  /// `bu_poseidon_bn254_hash`, or `null` when the loaded library was built
  /// without the Rust `poseidon-bn254` feature. Kept nullable (instead of a
  /// required lookup) so [BuZcashFfi] stays constructible with any library.
  final _PoseidonBn254D? poseidonBn254Hash;

  final _Poseidon2D poseidonHashTwo;
  final _PoseidonD poseidonHash;
  final _SinsHashD sinsemillaHashBits;
  final _SinsCommitD sinsemillaCommit;
  final _SinsCommitD sinsemillaShortCommit;
  final _PermuteD poseidonPermute;
  final _SinsBitstringD sinsemillaHashBitstring;
  final _PedersenD pedersenHash;
  final _PedersenStrD pedersenHashBitstring;
}
