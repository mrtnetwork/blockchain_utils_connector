// ignore_for_file: library_private_types_in_public_api
// FFI typedefs are internal (never exported from blockchain_utils_connector.dart).
import 'dart:ffi' as ffi;
import 'dart:io' show File, Platform;

import 'package:blockchain_utils_connector/src/error/bu_error.dart';

/// Low-level hash / KDF / cipher C bindings.
class BuFfiBindings {
  BuFfiBindings(ffi.DynamicLibrary lib)
    : hashNew = lib.lookupFunction<_HashNewN, _HashNewD>('bu_hash_new'),
      hashNewSimple = lib.lookupFunction<_HashNewSimpleN, _HashNewSimpleD>(
        'bu_hash_new_simple',
      ),
      hashUpdate = lib.lookupFunction<_HashUpdateN, _HashUpdateD>(
        'bu_hash_update',
      ),
      hashReset = lib.lookupFunction<_HashPtrN, _HashPtrD>('bu_hash_reset'),
      hashFinish = lib.lookupFunction<_HashFinishN, _HashFinishD>(
        'bu_hash_finish',
      ),
      hashFinishN = lib.lookupFunction<_HashFinishNN, _HashFinishND>(
        'bu_hash_finish_n',
      ),
      hashFree = lib.lookupFunction<_HashPtrN, _HashPtrD>('bu_hash_free'),
      hashClean = lib.lookupFunction<_HashPtrN, _HashPtrD>('bu_hash_clean'),
      hashDigestLen = lib.lookupFunction<_HashLenN, _HashLenD>(
        'bu_hash_digest_len',
      ),
      hashBlockSize = lib.lookupFunction<_HashLenN, _HashLenD>(
        'bu_hash_block_size',
      ),
      hashAlgo = lib.lookupFunction<_HashLenN, _HashLenD>('bu_hash_algo'),
      hashSaveState = lib.lookupFunction<_HashSaveN, _HashSaveD>(
        'bu_hash_save_state',
      ),
      hashRestoreState = lib.lookupFunction<_HashRestoreN, _HashRestoreD>(
        'bu_hash_restore_state',
      ),
      hashFreeState = lib.lookupFunction<_HashFreeStateN, _HashFreeStateD>(
        'bu_hash_free_state',
      ),
      pbkdf2 = lib.lookupFunction<_PbkdfN, _PbkdfD>('bu_pbkdf2'),
      scrypt = lib.lookupFunction<_ScryptN, _ScryptD>('bu_scrypt'),
      hkdf = lib.lookupFunction<_HkdfN, _HkdfD>('bu_hkdf'),
      chachaPolyEnc = lib.lookupFunction<_AeadN, _AeadD>(
        'bu_chacha20poly1305_encrypt',
      ),
      chachaPolyDec = lib.lookupFunction<_AeadDecN, _AeadDecD>(
        'bu_chacha20poly1305_decrypt',
      ),
      aesGcmEnc = lib.lookupFunction<_AeadN, _AeadD>('bu_aes_gcm_encrypt'),
      aesGcmDec = lib.lookupFunction<_AeadDecN, _AeadDecD>(
        'bu_aes_gcm_decrypt',
      ),
      xsalsaEnc = lib.lookupFunction<_XsalsaN, _XsalsaD>(
        'bu_xsalsa20poly1305_encrypt',
      ),
      xsalsaDec = lib.lookupFunction<_XsalsaN, _XsalsaD>(
        'bu_xsalsa20poly1305_decrypt',
      ),
      boxBeforenm = lib.lookupFunction<_BoxKdfN, _BoxKdfD>(
        'bu_salsabox_beforenm',
      ),
      boxEnc = lib.lookupFunction<_AeadN, _AeadD>('bu_salsabox_encrypt'),
      boxDec = lib.lookupFunction<_AeadDecN, _AeadDecD>('bu_salsabox_decrypt'),
      aesNew = lib.lookupFunction<_AesNewN, _AesNewD>('bu_aes_new'),
      aesFree = lib.lookupFunction<_AesFreeN, _AesFreeD>('bu_aes_free'),
      aesEncBlock = lib.lookupFunction<_AesBlockN, _AesBlockD>(
        'bu_aes_encrypt_block',
      ),
      aesDecBlock = lib.lookupFunction<_AesBlockN, _AesBlockD>(
        'bu_aes_decrypt_block',
      ),
      aesCbcEnc = lib.lookupFunction<_AesCbcN, _AesCbcD>('bu_aes_cbc_encrypt'),
      aesCbcDec = lib.lookupFunction<_AesCbcN, _AesCbcD>('bu_aes_cbc_decrypt'),
      aesEcbEncPad = lib.lookupFunction<_AesEcbN, _AesEcbD>(
        'bu_aes_ecb_encrypt_padded',
      ),
      aesEcbDecPad = lib.lookupFunction<_AesEcbDecN, _AesEcbDecD>(
        'bu_aes_ecb_decrypt_padded',
      ),
      aesCtr = lib.lookupFunction<_AesCtrN, _AesCtrD>('bu_aes_ctr'),
      chacha20Xor = lib.lookupFunction<_ChaChaXorN, _ChaChaXorD>(
        'bu_chacha20_xor',
      ),
      chacha20StreamXor = lib.lookupFunction<_ChaChaStreamN, _ChaChaStreamD>(
        'bu_chacha20_stream_xor',
      ),
      keccakF1600 = lib.lookupFunction<_KeccakN, _KeccakD>('bu_keccak_f1600');

  static ffi.DynamicLibrary open([String? path]) {
    if (path != null && path.isNotEmpty) {
      // Bare filenames (no directory part) go through linker search, like
      // the platform defaults below. Anything with a directory part must
      // be absolute: CWD-relative paths resolve against the process working
      // directory, which an attacker may influence (library hijacking).
      if (!File(path).isAbsolute &&
          (path.contains('/') || path.contains('\\'))) {
        throw BuError(
          DefaultErrorType.invalidArgument,
          'must be absolute: relative library paths can be hijacked '
          '(bare filenames use linker search).',
          details: {'path': path},
        );
      }
      return ffi.DynamicLibrary.open(path);
    }
    final fromRuntimeEnv = Platform.environment['BU_LIB_PATH'] ?? '';
    if (fromRuntimeEnv.isNotEmpty) {
      return ffi.DynamicLibrary.open(fromRuntimeEnv);
    }
    final fromEnv = String.fromEnvironment('BU_LIB_PATH', defaultValue: '');
    if (fromEnv.isNotEmpty) {
      return ffi.DynamicLibrary.open(fromEnv);
    }
    if (Platform.isMacOS) {
      return ffi.DynamicLibrary.open('libblockchain_utils.dylib');
    }
    if (Platform.isWindows) {
      return ffi.DynamicLibrary.open('blockchain_utils.dll');
    }
    return ffi.DynamicLibrary.open('libblockchain_utils.so');
  }

  final _HashNewD hashNew;
  final _HashNewSimpleD hashNewSimple;
  final _HashUpdateD hashUpdate;
  final _HashPtrD hashReset;
  final _HashFinishD hashFinish;
  final _HashFinishND hashFinishN;
  final _HashPtrD hashFree;
  final _HashPtrD hashClean;
  final _HashLenD hashDigestLen;
  final _HashLenD hashBlockSize;
  final _HashLenD hashAlgo;
  final _HashSaveD hashSaveState;
  final _HashRestoreD hashRestoreState;
  final _HashFreeStateD hashFreeState;
  final _PbkdfD pbkdf2;
  final _ScryptD scrypt;
  final _HkdfD hkdf;
  final _AeadD chachaPolyEnc;
  final _AeadDecD chachaPolyDec;
  final _AeadD aesGcmEnc;
  final _AeadDecD aesGcmDec;
  final _XsalsaD xsalsaEnc;
  final _XsalsaD xsalsaDec;
  final _BoxKdfD boxBeforenm;
  final _AeadD boxEnc;
  final _AeadDecD boxDec;
  final _AesNewD aesNew;
  final _AesFreeD aesFree;
  final _AesBlockD aesEncBlock;
  final _AesBlockD aesDecBlock;
  final _AesCbcD aesCbcEnc;
  final _AesCbcD aesCbcDec;
  final _AesEcbD aesEcbEncPad;
  final _AesEcbDecD aesEcbDecPad;
  final _AesCtrD aesCtr;
  final _ChaChaXorD chacha20Xor;
  final _ChaChaStreamD chacha20StreamXor;
  final _KeccakD keccakF1600;
}

// Opaque config struct laid out by caller as bytes — simplified: hashNew takes pointer.
typedef _HashNewN = ffi.Pointer<ffi.Void> Function(ffi.Pointer<ffi.Uint8>);
typedef _HashNewD = ffi.Pointer<ffi.Void> Function(ffi.Pointer<ffi.Uint8>);
typedef _HashUpdateN =
    ffi.Void Function(ffi.Pointer<ffi.Void>, ffi.Pointer<ffi.Uint8>, ffi.Size);
typedef _HashUpdateD =
    void Function(ffi.Pointer<ffi.Void>, ffi.Pointer<ffi.Uint8>, int);
typedef _HashPtrN = ffi.Void Function(ffi.Pointer<ffi.Void>);
typedef _HashPtrD = void Function(ffi.Pointer<ffi.Void>);
typedef _HashFinishN =
    ffi.Void Function(ffi.Pointer<ffi.Void>, ffi.Pointer<ffi.Uint8>);
typedef _HashFinishD =
    void Function(ffi.Pointer<ffi.Void>, ffi.Pointer<ffi.Uint8>);
typedef _HashFinishNN =
    ffi.Void Function(ffi.Pointer<ffi.Void>, ffi.Pointer<ffi.Uint8>, ffi.Size);
typedef _HashFinishND =
    void Function(ffi.Pointer<ffi.Void>, ffi.Pointer<ffi.Uint8>, int);
typedef _HashLenN = ffi.Size Function(ffi.Pointer<ffi.Void>);
typedef _HashLenD = int Function(ffi.Pointer<ffi.Void>);
typedef _HashSaveN = ffi.Pointer<ffi.Void> Function(ffi.Pointer<ffi.Void>);
typedef _HashSaveD = ffi.Pointer<ffi.Void> Function(ffi.Pointer<ffi.Void>);
typedef _HashRestoreN =
    ffi.Int32 Function(ffi.Pointer<ffi.Void>, ffi.Pointer<ffi.Void>);
typedef _HashRestoreD =
    int Function(ffi.Pointer<ffi.Void>, ffi.Pointer<ffi.Void>);
typedef _HashFreeStateN = ffi.Void Function(ffi.Pointer<ffi.Void>);
typedef _HashFreeStateD = void Function(ffi.Pointer<ffi.Void>);

typedef _PbkdfN =
    ffi.Int32 Function(
      ffi.Uint32,
      ffi.Pointer<ffi.Uint8>,
      ffi.Size,
      ffi.Pointer<ffi.Uint8>,
      ffi.Size,
      ffi.Uint32,
      ffi.Pointer<ffi.Uint8>,
      ffi.Size,
    );
typedef _PbkdfD =
    int Function(
      int,
      ffi.Pointer<ffi.Uint8>,
      int,
      ffi.Pointer<ffi.Uint8>,
      int,
      int,
      ffi.Pointer<ffi.Uint8>,
      int,
    );
typedef _ScryptN =
    ffi.Int32 Function(
      ffi.Pointer<ffi.Uint8>,
      ffi.Size,
      ffi.Pointer<ffi.Uint8>,
      ffi.Size,
      ffi.Uint32,
      ffi.Uint32,
      ffi.Uint32,
      ffi.Pointer<ffi.Uint8>,
      ffi.Size,
    );
typedef _ScryptD =
    int Function(
      ffi.Pointer<ffi.Uint8>,
      int,
      ffi.Pointer<ffi.Uint8>,
      int,
      int,
      int,
      int,
      ffi.Pointer<ffi.Uint8>,
      int,
    );
typedef _HkdfN =
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
    );
typedef _HkdfD =
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
    );

typedef _AeadN =
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
    );
typedef _AeadD =
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
    );
typedef _AeadDecN =
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
    );
typedef _AeadDecD =
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
    );
// XSalsa20-Poly1305 (no AAD): key,keylen, nonce,noncelen, pt,ptlen, out,outlen.
typedef _XsalsaN =
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
typedef _XsalsaD =
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
// SalsaBox beforenm: peer,peerlen, sk,sklen, out,outlen.
typedef _BoxKdfN =
    ffi.Int32 Function(
      ffi.Pointer<ffi.Uint8>,
      ffi.Size,
      ffi.Pointer<ffi.Uint8>,
      ffi.Size,
      ffi.Pointer<ffi.Uint8>,
      ffi.Size,
    );
typedef _BoxKdfD =
    int Function(
      ffi.Pointer<ffi.Uint8>,
      int,
      ffi.Pointer<ffi.Uint8>,
      int,
      ffi.Pointer<ffi.Uint8>,
      int,
    );

typedef _AesNewN =
    ffi.Pointer<ffi.Void> Function(ffi.Pointer<ffi.Uint8>, ffi.Size);
typedef _AesNewD = ffi.Pointer<ffi.Void> Function(ffi.Pointer<ffi.Uint8>, int);
typedef _AesFreeN = ffi.Void Function(ffi.Pointer<ffi.Void>);
typedef _AesFreeD = void Function(ffi.Pointer<ffi.Void>);
typedef _AesBlockN =
    ffi.Void Function(
      ffi.Pointer<ffi.Void>,
      ffi.Pointer<ffi.Uint8>,
      ffi.Pointer<ffi.Uint8>,
    );
typedef _AesBlockD =
    void Function(
      ffi.Pointer<ffi.Void>,
      ffi.Pointer<ffi.Uint8>,
      ffi.Pointer<ffi.Uint8>,
    );
typedef _AesCbcN =
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
typedef _AesCbcD =
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
typedef _AesEcbN =
    ffi.Int32 Function(
      ffi.Pointer<ffi.Uint8>,
      ffi.Size,
      ffi.Pointer<ffi.Uint8>,
      ffi.Size,
      ffi.Uint8,
      ffi.Pointer<ffi.Uint8>,
      ffi.Size,
    );
typedef _AesEcbD =
    int Function(
      ffi.Pointer<ffi.Uint8>,
      int,
      ffi.Pointer<ffi.Uint8>,
      int,
      int,
      ffi.Pointer<ffi.Uint8>,
      int,
    );
typedef _AesEcbDecN =
    ffi.Int32 Function(
      ffi.Pointer<ffi.Uint8>,
      ffi.Size,
      ffi.Pointer<ffi.Uint8>,
      ffi.Size,
      ffi.Uint8,
      ffi.Pointer<ffi.Uint8>,
      ffi.Size,
    );
typedef _AesEcbDecD =
    int Function(
      ffi.Pointer<ffi.Uint8>,
      int,
      ffi.Pointer<ffi.Uint8>,
      int,
      int,
      ffi.Pointer<ffi.Uint8>,
      int,
    );
typedef _AesCtrN =
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
typedef _AesCtrD =
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
typedef _ChaChaXorN =
    ffi.Int32 Function(
      ffi.Pointer<ffi.Uint8>,
      ffi.Size,
      ffi.Pointer<ffi.Uint8>,
      ffi.Size,
      ffi.Uint32,
      ffi.Pointer<ffi.Uint8>,
      ffi.Size,
      ffi.Pointer<ffi.Uint8>,
      ffi.Size,
    );
typedef _ChaChaXorD =
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
typedef _ChaChaStreamN =
    ffi.Int32 Function(
      ffi.Pointer<ffi.Uint8>,
      ffi.Size,
      ffi.Pointer<ffi.Uint8>,
      ffi.Size,
      ffi.Pointer<ffi.Uint8>,
      ffi.Size,
      ffi.Pointer<ffi.Uint8>,
      ffi.Size,
      ffi.Size,
      ffi.Size,
    );
typedef _ChaChaStreamD =
    int Function(
      ffi.Pointer<ffi.Uint8>,
      int,
      ffi.Pointer<ffi.Uint8>,
      int,
      ffi.Pointer<ffi.Uint8>,
      int,
      ffi.Pointer<ffi.Uint8>,
      int,
      int,
      int,
    );
typedef _KeccakN = ffi.Int32 Function(ffi.Pointer<ffi.Uint8>);
typedef _KeccakD = int Function(ffi.Pointer<ffi.Uint8>);

typedef _HashNewSimpleN =
    ffi.Pointer<ffi.Void> Function(
      ffi.Uint32,
      ffi.Uint32,
      ffi.Uint32,
      ffi.Pointer<ffi.Uint8>,
      ffi.Size,
      ffi.Pointer<ffi.Uint8>,
      ffi.Size,
      ffi.Pointer<ffi.Uint8>,
      ffi.Size,
      ffi.Uint64,
      ffi.Uint8,
      ffi.Uint8,
      ffi.Uint32,
      ffi.Uint64,
      ffi.Uint8,
      ffi.Uint8,
      ffi.Uint8,
    );
typedef _HashNewSimpleD =
    ffi.Pointer<ffi.Void> Function(
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
      int,
      int,
      int,
      int,
      int,
      int,
      int,
    );
