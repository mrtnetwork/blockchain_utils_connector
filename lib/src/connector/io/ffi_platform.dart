// ignore_for_file: library_private_types_in_public_api
// FFI typedefs are internal (never exported from blockchain_utils_connector.dart).
import 'dart:ffi' as ffi;
import 'package:blockchain_utils_connector/src/connector/io/io_alloc.dart';
import 'package:blockchain_utils_connector/src/bytes/bytes.dart';
import 'package:blockchain_utils_connector/src/error/bu_error.dart';
import 'package:blockchain_utils_connector/src/platform/bindings.dart';
import 'package:blockchain_utils_connector/src/connector/bu_features.dart';
import 'package:blockchain_utils_connector/src/connector/io/ffi_bindings.dart';
import 'package:blockchain_utils_connector/src/connector/io/ffi_curve_bindings.dart';
import 'package:blockchain_utils_connector/src/connector/io/ffi_signature_bindings.dart';
import 'package:blockchain_utils_connector/src/connector/io/ffi_bls_bindings.dart';
import 'package:blockchain_utils_connector/src/connector/io/ffi_musig2_bindings.dart';
import 'package:blockchain_utils_connector/src/connector/io/ffi_dkls23_bindings.dart';
import 'package:blockchain_utils_connector/src/connector/io/ffi_frost_bindings.dart';
import 'package:blockchain_utils_connector/src/connector/io/ffi_pq_bindings.dart';
import 'package:blockchain_utils_connector/src/connector/io/ffi_reddsa_bindings.dart';
import 'package:blockchain_utils_connector/src/connector/io/ffi_zcash_bindings.dart';
import 'package:blockchain_utils_connector/src/connector/io/ffi_groth16_bindings.dart';
import 'package:blockchain_utils_connector/src/connector/io/ffi_merkle_bindings.dart';
import 'package:blockchain_utils_connector/src/connector/io/ffi_orchard_bindings.dart';
import 'package:blockchain_utils_connector/src/connector/io/ffi_sapling_bindings.dart';
import 'package:blockchain_utils_connector/src/connector/io/ffi_zkcodes_bindings.dart';
import 'package:blockchain_utils_connector/src/connector/io/ffi_transcript_bindings.dart';
import 'package:blockchain_utils_connector/src/connector/io/ffi_ff1_x25519_bindings.dart';
import 'package:blockchain_utils_connector/src/connector/io/ffi_monero_bindings.dart';
import 'package:blockchain_utils_connector/src/connector/io/ffi_solana_zk_bindings.dart';
import 'package:blockchain_utils_connector/src/connector/io/ffi_sr25519_bindings.dart';
import 'package:blockchain_utils_connector/src/connector/io/ffi_hw_bindings.dart';

/// FFI platform — curve + signing wired (fixes Secp256r1 unsupported).
class FfiPlatformBindings implements BuPlatformBindings {
  FfiPlatformBindings(
    this._raw, {
    BuCurveFfi? curve,
    BuSignatureFfi? sig,
    BuBlsFfi? bls,
    BuMusig2Ffi? musig,
    BuDkls23Ffi? dkls23,
    BuFrostFfi? frost,
    BuPqFfi? pq,
    BuRngFfi? rng,
    BuReddsaFfi? reddsa,
    BuZcashFfi? zcash,
    BuFf1X25519Ffi? ff1x,
    FfiSr25519Bindings? sr25519,
    BuGroth16Ffi? g16,
    BuSaplingFfi? sapling,
    BuOrchardFfi? orchard,
    BuMerkleFfi? merkle,
    BuZkCodesFfi? zk,
    BuTranscriptFfi? transcript,
    BuMoneroFfi? monero,
    BuSolanaZkFfi? solanaZk,
    BuHwFfi? hw,
  }) : _curve = curve,
       _sig = sig,
       _bls = bls,
       _musig = musig,
       _dkls23 = dkls23,
       _frost = frost,
       _pq = pq,
       _rng = rng,
       _reddsa = reddsa,
       _zcash = zcash,
       _ff1x = ff1x,
       _sr25519 = sr25519,
       _g16 = g16,
       _sapling = sapling,
       _orchard = orchard,
       _merkle = merkle,
       _zk = zk,
       _tr = transcript,
       _monero = monero,
       _solanaZk = solanaZk,
       _hw = hw;
  final BuFfiBindings _raw;
  final BuCurveFfi? _curve;
  final BuSignatureFfi? _sig;
  final BuBlsFfi? _bls;
  final BuMusig2Ffi? _musig;
  final BuDkls23Ffi? _dkls23;
  final BuFrostFfi? _frost;
  final BuPqFfi? _pq;
  final BuRngFfi? _rng;
  final BuReddsaFfi? _reddsa;
  final BuZcashFfi? _zcash;
  final BuGroth16Ffi? _g16;
  final BuSaplingFfi? _sapling;
  final BuOrchardFfi? _orchard;
  final BuMerkleFfi? _merkle;
  final BuZkCodesFfi? _zk;
  final BuTranscriptFfi? _tr;
  final BuMoneroFfi? _monero;
  final BuSolanaZkFfi? _solanaZk;
  final BuHwFfi? _hw;
  final BuFf1X25519Ffi? _ff1x;
  final FfiSr25519Bindings? _sr25519;

  @override
  BuBackendKind get backendKind => BuBackendKind.ffi;

  factory FfiPlatformBindings.open([String? libraryPath]) {
    final lib = BuFfiBindings.open(libraryPath);
    BuSignatureFfi? sig;
    BuBlsFfi? bls;
    BuMusig2Ffi? musig;
    BuPqFfi? pq;
    BuRngFfi? rng;
    BuReddsaFfi? reddsa;
    try {
      sig = BuSignatureFfi(lib);
    } catch (_) {
      sig = null;
    }
    try {
      bls = BuBlsFfi(lib);
    } catch (_) {
      bls = null;
    }
    try {
      musig = BuMusig2Ffi(lib);
    } catch (_) {
      musig = null;
    }
    BuDkls23Ffi? dkls23;
    try {
      dkls23 = BuDkls23Ffi(lib);
    } catch (_) {
      dkls23 = null;
    }
    BuFrostFfi? frost;
    try {
      frost = BuFrostFfi(lib);
    } catch (_) {
      frost = null;
    }
    try {
      pq = BuPqFfi(lib);
    } catch (_) {
      pq = null;
    }
    try {
      rng = BuRngFfi(lib);
    } catch (_) {
      rng = null;
    }
    try {
      reddsa = BuReddsaFfi(lib);
    } catch (_) {
      reddsa = null;
    }
    BuZcashFfi? zcash;
    try {
      zcash = BuZcashFfi(lib);
    } catch (_) {
      zcash = null;
    }
    BuGroth16Ffi? g16;
    try {
      g16 = BuGroth16Ffi(lib);
    } catch (_) {
      g16 = null;
    }
    BuZkCodesFfi? zk;
    try {
      zk = BuZkCodesFfi(lib);
    } catch (_) {
      zk = null;
    }
    BuTranscriptFfi? transcript;
    try {
      transcript = BuTranscriptFfi(lib);
    } catch (_) {
      transcript = null;
    }
    BuSaplingFfi? sapling;
    try {
      sapling = BuSaplingFfi(lib);
    } catch (_) {
      sapling = null;
    }
    BuOrchardFfi? orchard;
    try {
      orchard = BuOrchardFfi(lib);
    } catch (_) {
      orchard = null;
    }
    BuMerkleFfi? merkle;
    try {
      merkle = BuMerkleFfi(lib);
    } catch (_) {
      merkle = null;
    }
    BuFf1X25519Ffi? ff1x;
    try {
      ff1x = BuFf1X25519Ffi(lib);
    } catch (_) {
      ff1x = null;
    }
    FfiSr25519Bindings? sr25519;
    try {
      sr25519 = FfiSr25519Bindings(lib);
    } catch (_) {
      sr25519 = null;
    }
    BuMoneroFfi? monero;
    try {
      monero = BuMoneroFfi(lib);
    } catch (_) {
      monero = null;
    }
    BuSolanaZkFfi? solanaZk;
    try {
      solanaZk = BuSolanaZkFfi(lib);
    } catch (_) {
      solanaZk = null;
    }
    BuHwFfi? hw;
    try {
      hw = BuHwFfi(lib);
    } catch (_) {
      hw = null;
    }
    return FfiPlatformBindings(
      BuFfiBindings(lib),
      curve: BuCurveFfi(lib),
      sig: sig,
      bls: bls,
      musig: musig,
      dkls23: dkls23,
      frost: frost,
      pq: pq,
      rng: rng,
      reddsa: reddsa,
      zcash: zcash,
      ff1x: ff1x,
      sr25519: sr25519,
      hw: hw,
      g16: g16,
      sapling: sapling,
      orchard: orchard,
      merkle: merkle,
      zk: zk,
      transcript: transcript,
      monero: monero,
      solanaZk: solanaZk,
    );
  }

  ffi.Pointer<ffi.Uint8> _cp(BuBytes d) {
    final p = ioCalloc<ffi.Uint8>(d.isEmpty ? 1 : d.length);
    for (var i = 0; i < d.length; i++) {
      p[i] = d[i];
    }
    return p;
  }

  void _zf(ffi.Pointer<ffi.Uint8> p, int n) {
    for (var i = 0; i < n; i++) {
      p[i] = 0;
    }
    ioFree(p);
  }

  int _u() => 6;

  @override
  Object hashNew(BuHashNativeConfig c) {
    final key = c.key;
    final salt = c.salt;
    final personal = c.personal;
    final kp = (key == null || key.isEmpty) ? ffi.nullptr : _cp(key);
    final sp = (salt == null || salt.isEmpty) ? ffi.nullptr : _cp(salt);
    final pp =
        (personal == null || personal.isEmpty) ? ffi.nullptr : _cp(personal);
    try {
      final h = _raw.hashNewSimple(
        c.algo,
        c.digestLength,
        c.hmac ? 1 : 0, // BU_HASH_FLAG_HMAC
        kp,
        key?.length ?? 0,
        sp,
        salt?.length ?? 0,
        pp,
        personal?.length ?? 0,
        c.seed,
        c.fanout & 0xff,
        c.maxDepth & 0xff,
        c.leafSize,
        c.nodeOffset,
        c.nodeDepth & 0xff,
        c.innerDigestLength & 0xff,
        c.lastNode ? 1 : 0,
      );
      if (h == ffi.nullptr) {
        throw BuError.unsupported;
      }
      return h;
    } finally {
      if (kp != ffi.nullptr) _zf(kp, key!.length);
      if (sp != ffi.nullptr) _zf(sp, salt!.length);
      if (pp != ffi.nullptr) _zf(pp, personal!.length);
    }
  }

  @override
  void hashUpdate(Object handle, BuBytes data) {
    if (data.isEmpty) return;
    final p = _cp(data);
    try {
      _raw.hashUpdate(handle as ffi.Pointer<ffi.Void>, p, data.length);
    } finally {
      ioFree(p);
    }
  }

  @override
  void hashReset(Object handle) {
    _raw.hashReset(handle as ffi.Pointer<ffi.Void>);
  }

  @override
  void hashFinish(Object handle, BuBytes out) {
    if (out.isEmpty) return;
    final o = ioCalloc<ffi.Uint8>(out.length);
    try {
      // Prefer finish_n so SHAKE/XOF and custom lengths work
      _raw.hashFinishN(handle as ffi.Pointer<ffi.Void>, o, out.length);
      for (var i = 0; i < out.length; i++) {
        out[i] = o[i];
      }
    } finally {
      ioFree(o);
    }
  }

  @override
  void hashFree(Object handle) {
    _raw.hashFree(handle as ffi.Pointer<ffi.Void>);
  }

  @override
  void hashClean(Object handle) {
    _raw.hashClean(handle as ffi.Pointer<ffi.Void>);
  }

  @override
  int hashDigestLen(Object handle) =>
      _raw.hashDigestLen(handle as ffi.Pointer<ffi.Void>);

  @override
  int hashBlockSize(Object handle) =>
      _raw.hashBlockSize(handle as ffi.Pointer<ffi.Void>);

  @override
  int hashAlgo(Object handle) => _raw.hashAlgo(handle as ffi.Pointer<ffi.Void>);

  @override
  Object hashSaveState(Object handle) {
    final s = _raw.hashSaveState(handle as ffi.Pointer<ffi.Void>);
    if (s == ffi.nullptr) throw BuError.internal;
    return s;
  }

  @override
  void hashRestoreState(Object handle, Object state) {
    final rc = _raw.hashRestoreState(
      handle as ffi.Pointer<ffi.Void>,
      state as ffi.Pointer<ffi.Void>,
    );
    if (rc != 0) {
      throw BuError(DefaultErrorType.internal, 'hash_restore_state: $rc');
    }
  }

  @override
  void hashFreeState(Object state) {
    _raw.hashFreeState(state as ffi.Pointer<ffi.Void>);
  }

  @override
  void pbkdf2({
    required int prf,
    required BuBytes password,
    required BuBytes salt,
    required int iterations,
    required BuBytes out,
  }) {
    final pw = _cp(password);
    final sa = _cp(salt);
    final o = ioCalloc<ffi.Uint8>(out.length);
    try {
      final rc = _raw.pbkdf2(
        prf,
        pw,
        password.length,
        sa,
        salt.length,
        iterations,
        o,
        out.length,
      );
      if (rc != 0) throw BuError.internal;
      for (var i = 0; i < out.length; i++) {
        out[i] = o[i];
      }
    } finally {
      _zf(pw, password.length);
      _zf(sa, salt.length);
      ioFree(o);
    }
  }

  @override
  void scrypt({
    required BuBytes password,
    required BuBytes salt,
    required int n,
    required int r,
    required int p,
    required BuBytes out,
  }) {
    final pw = _cp(password);
    final sa = _cp(salt);
    final o = ioCalloc<ffi.Uint8>(out.length);
    try {
      final rc = _raw.scrypt(
        pw,
        password.length,
        sa,
        salt.length,
        n,
        r,
        p,
        o,
        out.length,
      );
      if (rc != 0) throw BuError.internal;
      for (var i = 0; i < out.length; i++) {
        out[i] = o[i];
      }
    } finally {
      _zf(pw, password.length);
      _zf(sa, salt.length);
      ioFree(o);
    }
  }

  @override
  void hkdf({
    required int prf,
    required BuBytes ikm,
    BuBytes? salt,
    BuBytes? info,
    required BuBytes out,
  }) {
    final i = _cp(ikm);
    final s = (salt == null || salt.isEmpty) ? ffi.nullptr : _cp(salt);
    final n = (info == null || info.isEmpty) ? ffi.nullptr : _cp(info);
    final o = ioCalloc<ffi.Uint8>(out.length);
    try {
      final rc = _raw.hkdf(
        prf,
        i,
        ikm.length,
        s,
        salt?.length ?? 0,
        n,
        info?.length ?? 0,
        o,
        out.length,
      );
      if (rc != 0) throw BuError.internal;
      for (var j = 0; j < out.length; j++) {
        out[j] = o[j];
      }
    } finally {
      _zf(i, ikm.length);
      if (s != ffi.nullptr) ioFree(s);
      if (n != ffi.nullptr) ioFree(n);
      ioFree(o);
    }
  }

  BuError _aeadRc(int rc) {
    // Rust `BU_AEAD_ERR_*` codes (blockchain-utils/src/connector/ffi/aead.rs),
    // which do NOT match the generic numbering below:
    // 1 = null, 2 = output-buffer size, 3 = key, 4 = nonce, 5 = auth.
    // 0 is unreachable: callers check rc != 0 first.
    return BuError.fromNativeCode(switch (rc) {
      1 => 1,
      2 => 9,
      3 => 2,
      4 => 3,
      5 => 5,
      _ => rc,
    });
  }

  @override
  void chacha20Poly1305Encrypt({
    required BuBytes key,
    required BuBytes nonce,
    required BuBytes plaintext,
    BuBytes? aad,
    required BuBytes out,
  }) {
    final k = _cp(key);
    final n = _cp(nonce);
    final p = _cp(plaintext);
    final a = (aad == null || aad.isEmpty) ? ffi.nullptr : _cp(aad);
    final o = ioCalloc<ffi.Uint8>(out.length);
    try {
      final rc = _raw.chachaPolyEnc(
        k,
        key.length,
        n,
        nonce.length,
        p,
        plaintext.length,
        a,
        aad?.length ?? 0,
        o,
        out.length,
      );
      if (rc != 0) {
        throw BuError(_aeadRc(rc).type, 'chacha20poly1305_encrypt: $rc');
      }
      for (var i = 0; i < out.length; i++) {
        out[i] = o[i];
      }
    } finally {
      _zf(k, key.length);
      ioFree(n);
      ioFree(p);
      if (a != ffi.nullptr) ioFree(a);
      ioFree(o);
    }
  }

  @override
  bool chacha20Poly1305Decrypt({
    required BuBytes key,
    required BuBytes nonce,
    required BuBytes ciphertext,
    BuBytes? aad,
    required BuBytes out,
  }) {
    final k = _cp(key);
    final n = _cp(nonce);
    final c = _cp(ciphertext);
    final a = (aad == null || aad.isEmpty) ? ffi.nullptr : _cp(aad);
    final o = ioCalloc<ffi.Uint8>(out.isEmpty ? 1 : out.length);
    try {
      final rc = _raw.chachaPolyDec(
        k,
        key.length,
        n,
        nonce.length,
        c,
        ciphertext.length,
        a,
        aad?.length ?? 0,
        o,
        out.length,
      );
      if (rc != 0) {
        return false;
      }
      for (var i = 0; i < out.length; i++) {
        out[i] = o[i];
      }
      return true;
    } finally {
      _zf(k, key.length);
      ioFree(n);
      ioFree(c);
      if (a != ffi.nullptr) ioFree(a);
      ioFree(o);
    }
  }

  @override
  void aesGcmEncrypt({
    required BuBytes key,
    required BuBytes nonce,
    required BuBytes plaintext,
    BuBytes? aad,
    required BuBytes out,
  }) {
    final k = _cp(key);
    final n = _cp(nonce);
    final p = _cp(plaintext);
    final a = (aad == null || aad.isEmpty) ? ffi.nullptr : _cp(aad);
    final o = ioCalloc<ffi.Uint8>(out.length);
    try {
      final rc = _raw.aesGcmEnc(
        k,
        key.length,
        n,
        nonce.length,
        p,
        plaintext.length,
        a,
        aad?.length ?? 0,
        o,
        out.length,
      );
      if (rc != 0) {
        throw BuError(_aeadRc(rc).type, 'aes_gcm_encrypt: $rc');
      }
      for (var i = 0; i < out.length; i++) {
        out[i] = o[i];
      }
    } finally {
      _zf(k, key.length);
      ioFree(n);
      ioFree(p);
      if (a != ffi.nullptr) ioFree(a);
      ioFree(o);
    }
  }

  @override
  bool aesGcmDecrypt({
    required BuBytes key,
    required BuBytes nonce,
    required BuBytes ciphertext,
    BuBytes? aad,
    required BuBytes out,
  }) {
    final k = _cp(key);
    final n = _cp(nonce);
    final c = _cp(ciphertext);
    final a = (aad == null || aad.isEmpty) ? ffi.nullptr : _cp(aad);
    final o = ioCalloc<ffi.Uint8>(out.isEmpty ? 1 : out.length);
    try {
      final rc = _raw.aesGcmDec(
        k,
        key.length,
        n,
        nonce.length,
        c,
        ciphertext.length,
        a,
        aad?.length ?? 0,
        o,
        out.length,
      );
      if (rc != 0) {
        return false;
      }
      for (var i = 0; i < out.length; i++) {
        out[i] = o[i];
      }
      return true;
    } finally {
      _zf(k, key.length);
      ioFree(n);
      ioFree(c);
      if (a != ffi.nullptr) ioFree(a);
      ioFree(o);
    }
  }

  @override
  void xsalsa20Poly1305Encrypt({
    required BuBytes key,
    required BuBytes nonce,
    required BuBytes plaintext,
    required BuBytes out,
  }) {
    final k = _cp(key);
    final n = _cp(nonce);
    final p = _cp(plaintext);
    final o = ioCalloc<ffi.Uint8>(out.length);
    try {
      final rc = _raw.xsalsaEnc(
        k,
        key.length,
        n,
        nonce.length,
        p,
        plaintext.length,
        o,
        out.length,
      );
      if (rc != 0) {
        throw BuError(_aeadRc(rc).type, 'xsalsa20poly1305_encrypt: $rc');
      }
      for (var i = 0; i < out.length; i++) {
        out[i] = o[i];
      }
    } finally {
      _zf(k, key.length);
      ioFree(n);
      ioFree(p);
      ioFree(o);
    }
  }

  @override
  bool xsalsa20Poly1305Decrypt({
    required BuBytes key,
    required BuBytes nonce,
    required BuBytes sealed,
    required BuBytes out,
  }) {
    final k = _cp(key);
    final n = _cp(nonce);
    final c = _cp(sealed);
    final o = ioCalloc<ffi.Uint8>(out.isEmpty ? 1 : out.length);
    try {
      final rc = _raw.xsalsaDec(
        k,
        key.length,
        n,
        nonce.length,
        c,
        sealed.length,
        o,
        out.length,
      );
      if (rc != 0) {
        return false;
      }
      for (var i = 0; i < out.length; i++) {
        out[i] = o[i];
      }
      return true;
    } finally {
      _zf(k, key.length);
      ioFree(n);
      ioFree(c);
      ioFree(o);
    }
  }

  @override
  BuBytes salsaBoxBeforenm({
    required BuBytes peerPublicKey,
    required BuBytes secretKey,
  }) {
    final p = _cp(peerPublicKey);
    final s = _cp(secretKey);
    final o = ioCalloc<ffi.Uint8>(32);
    try {
      final rc = _raw.boxBeforenm(
        p,
        peerPublicKey.length,
        s,
        secretKey.length,
        o,
        32,
      );
      if (rc != 0) {
        throw BuError(_aeadRc(rc).type, 'salsabox_beforenm: $rc');
      }
      final out = BuBytes.zero(32);
      for (var i = 0; i < 32; i++) {
        out[i] = o[i];
      }
      return out;
    } finally {
      _zf(s, secretKey.length);
      ioFree(p);
      ioFree(o);
    }
  }

  @override
  void salsaBoxEncrypt({
    required BuBytes peerPublicKey,
    required BuBytes secretKey,
    required BuBytes nonce,
    required BuBytes plaintext,
    required BuBytes out,
  }) {
    final p = _cp(peerPublicKey);
    final s = _cp(secretKey);
    final n = _cp(nonce);
    final m = _cp(plaintext);
    final o = ioCalloc<ffi.Uint8>(out.length);
    try {
      final rc = _raw.boxEnc(
        p,
        peerPublicKey.length,
        s,
        secretKey.length,
        n,
        nonce.length,
        m,
        plaintext.length,
        o,
        out.length,
      );
      if (rc != 0) {
        throw BuError(_aeadRc(rc).type, 'salsabox_encrypt: $rc');
      }
      for (var i = 0; i < out.length; i++) {
        out[i] = o[i];
      }
    } finally {
      _zf(s, secretKey.length);
      ioFree(p);
      ioFree(n);
      ioFree(m);
      ioFree(o);
    }
  }

  @override
  bool salsaBoxDecrypt({
    required BuBytes peerPublicKey,
    required BuBytes secretKey,
    required BuBytes nonce,
    required BuBytes sealed,
    required BuBytes out,
  }) {
    final p = _cp(peerPublicKey);
    final s = _cp(secretKey);
    final n = _cp(nonce);
    final c = _cp(sealed);
    final o = ioCalloc<ffi.Uint8>(out.isEmpty ? 1 : out.length);
    try {
      final rc = _raw.boxDec(
        p,
        peerPublicKey.length,
        s,
        secretKey.length,
        n,
        nonce.length,
        c,
        sealed.length,
        o,
        out.length,
      );
      if (rc != 0) {
        return false;
      }
      for (var i = 0; i < out.length; i++) {
        out[i] = o[i];
      }
      return true;
    } finally {
      _zf(s, secretKey.length);
      ioFree(p);
      ioFree(n);
      ioFree(c);
      ioFree(o);
    }
  }

  @override
  Object aesNew(BuBytes key) {
    final k = _cp(key);
    try {
      final h = _raw.aesNew(k, key.length);
      if (h == ffi.nullptr) throw BuError.invalidKey;
      return h;
    } finally {
      _zf(k, key.length);
    }
  }

  @override
  void aesFree(Object handle) => _raw.aesFree(handle as ffi.Pointer<ffi.Void>);

  @override
  void aesEncryptBlock(Object handle, BuBytes src, BuBytes out) {
    final s = _cp(src);
    final o = ioCalloc<ffi.Uint8>(16);
    try {
      _raw.aesEncBlock(handle as ffi.Pointer<ffi.Void>, s, o);
      for (var i = 0; i < 16; i++) {
        out[i] = o[i];
      }
    } finally {
      ioFree(s);
      ioFree(o);
    }
  }

  @override
  void aesDecryptBlock(Object handle, BuBytes src, BuBytes out) {
    final s = _cp(src);
    final o = ioCalloc<ffi.Uint8>(16);
    try {
      _raw.aesDecBlock(handle as ffi.Pointer<ffi.Void>, s, o);
      for (var i = 0; i < 16; i++) {
        out[i] = o[i];
      }
    } finally {
      ioFree(s);
      ioFree(o);
    }
  }

  @override
  void aesCbcEncrypt({
    required BuBytes key,
    required BuBytes iv,
    required BuBytes data,
    required BuBytes out,
  }) {
    // Empty input is the identity (avoids calloc(0) which may return null).
    if (data.isEmpty) {
      return;
    }
    final k = _cp(key);
    final v = _cp(iv);
    final d = _cp(data);
    final o = ioCalloc<ffi.Uint8>(out.length);
    try {
      final rc = _raw.aesCbcEnc(
        k,
        key.length,
        v,
        iv.length,
        d,
        data.length,
        o,
        out.length,
      );
      if (rc != 0) {
        throw BuError(DefaultErrorType.internal, 'aes_cbc_encrypt: $rc');
      }
      for (var i = 0; i < out.length; i++) {
        out[i] = o[i];
      }
    } finally {
      _zf(k, key.length);
      ioFree(v);
      ioFree(d);
      ioFree(o);
    }
  }

  @override
  void aesCbcDecrypt({
    required BuBytes key,
    required BuBytes iv,
    required BuBytes data,
    required BuBytes out,
  }) {
    // Empty input is the identity (avoids calloc(0) which may return null).
    if (data.isEmpty) {
      return;
    }
    final k = _cp(key);
    final v = _cp(iv);
    final d = _cp(data);
    final o = ioCalloc<ffi.Uint8>(out.length);
    try {
      final rc = _raw.aesCbcDec(
        k,
        key.length,
        v,
        iv.length,
        d,
        data.length,
        o,
        out.length,
      );
      if (rc != 0) {
        throw BuError(DefaultErrorType.internal, 'aes_cbc_decrypt: $rc');
      }
      for (var i = 0; i < out.length; i++) {
        out[i] = o[i];
      }
    } finally {
      _zf(k, key.length);
      ioFree(v);
      ioFree(d);
      ioFree(o);
    }
  }

  @override
  BuBytes aesEcbEncryptPadded({
    required BuBytes key,
    required BuBytes data,
    required int padding,
  }) {
    // Worst-case pad to next full block
    final need = ((data.length + 16) ~/ 16) * 16;
    final k = _cp(key);
    final d = _cp(data);
    final o = ioCalloc<ffi.Uint8>(need == 0 ? 16 : need);
    try {
      final rc = _raw.aesEcbEncPad(
        k,
        key.length,
        d,
        data.length,
        padding,
        o,
        need == 0 ? 16 : need,
      );
      if (rc < 0) {
        throw BuError(DefaultErrorType.internal, 'aes_ecb_encrypt_padded: $rc');
      }
      final n = rc;
      final out = BuBytes.zero(n);
      for (var i = 0; i < n; i++) {
        out[i] = o[i];
      }
      return out;
    } finally {
      _zf(k, key.length);
      ioFree(d);
      ioFree(o);
    }
  }

  @override
  BuBytes? aesEcbDecryptPadded({
    required BuBytes key,
    required BuBytes data,
    required int padding,
  }) {
    final k = _cp(key);
    final d = _cp(data);
    final o = ioCalloc<ffi.Uint8>(data.isEmpty ? 1 : data.length);
    try {
      final rc = _raw.aesEcbDecPad(
        k,
        key.length,
        d,
        data.length,
        padding,
        o,
        data.length,
      );
      if (rc < 0) {
        return null;
      }
      final out = BuBytes.zero(rc);
      for (var i = 0; i < rc; i++) {
        out[i] = o[i];
      }
      return out;
    } finally {
      _zf(k, key.length);
      ioFree(d);
      ioFree(o);
    }
  }

  @override
  void aesCtr({
    required BuBytes key,
    required BuBytes counter,
    required BuBytes data,
    required BuBytes out,
  }) {
    final k = _cp(key);
    final c = _cp(counter);
    final d = _cp(data);
    final o = ioCalloc<ffi.Uint8>(out.isEmpty ? 1 : out.length);
    try {
      final rc = _raw.aesCtr(
        k,
        key.length,
        c,
        counter.length,
        d,
        data.length,
        o,
        out.length,
      );
      if (rc != 0) throw BuError(DefaultErrorType.internal, 'aes_ctr: $rc');
      for (var i = 0; i < out.length; i++) {
        out[i] = o[i];
      }
    } finally {
      _zf(k, key.length);
      ioFree(c);
      ioFree(d);
      ioFree(o);
    }
  }

  @override
  void chacha20Xor({
    required BuBytes key,
    required BuBytes nonce,
    required int counter,
    required BuBytes data,
    required BuBytes out,
  }) {
    final k = _cp(key);
    final n = _cp(nonce);
    final d = _cp(data);
    final o = ioCalloc<ffi.Uint8>(out.isEmpty ? 1 : out.length);
    try {
      final rc = _raw.chacha20Xor(
        k,
        key.length,
        n,
        nonce.length,
        counter,
        d,
        data.length,
        o,
        out.length,
      );
      if (rc != 0) {
        throw BuError(DefaultErrorType.invalidNonce, 'chacha20_xor: $rc');
      }
      for (var i = 0; i < out.length; i++) {
        out[i] = o[i];
      }
    } finally {
      _zf(k, key.length);
      ioFree(n);
      ioFree(d);
      ioFree(o);
    }
  }

  @override
  void chacha20StreamXor({
    required BuBytes key,
    required BuBytes nonce,
    required BuBytes data,
    required BuBytes out,
    int nonceInplaceCounterLength = 0,
    int seekBytes = 0,
  }) {
    final k = _cp(key);
    final n = _cp(nonce);
    final d = _cp(data);
    final o = ioCalloc<ffi.Uint8>(out.isEmpty ? 1 : out.length);
    try {
      final rc = _raw.chacha20StreamXor(
        k,
        key.length,
        n,
        nonce.length,
        d,
        data.length,
        o,
        out.length,
        nonceInplaceCounterLength,
        seekBytes,
      );
      if (rc != 0) {
        throw BuError(
          DefaultErrorType.invalidNonce,
          'chacha20_stream_xor: $rc',
        );
      }
      for (var i = 0; i < out.length; i++) {
        out[i] = o[i];
      }
    } finally {
      _zf(k, key.length);
      ioFree(n);
      ioFree(d);
      ioFree(o);
    }
  }

  @override
  BuBytes keccakF1600(BuBytes state200) {
    final s = _cp(state200);
    try {
      final rc = _raw.keccakF1600(s);
      if (rc != 0) throw BuError.internal;
      for (var i = 0; i < 200; i++) {
        state200[i] = s[i];
      }
      return state200;
    } finally {
      _zf(s, 200);
    }
  }

  @override
  int curvePointLen(int id) => _curve?.pointLen(id) ?? 0;
  @override
  int curvePointUncompressedLen(int id) => _curve?.pointLenUncomp(id) ?? 0;

  int _curveConvert(
    int Function(int, ffi.Pointer<ffi.Uint8>, int, ffi.Pointer<ffi.Uint8>, int)?
    f,
    int id,
    BuBytes point,
    BuBytes out,
  ) {
    if (f == null || out.isEmpty) {
      return _u();
    }
    final p = point.isEmpty ? ffi.nullptr : _cp(point);
    final o = _cp(out);
    try {
      final rc = f(id, p, point.length, o, out.length);
      if (rc == 0) {
        for (var i = 0; i < out.length; i++) {
          out[i] = o[i];
        }
      }
      return rc;
    } finally {
      if (p != ffi.nullptr) _zf(p, point.length);
      _zf(o, out.length);
    }
  }

  @override
  int curveCompress(int id, BuBytes point, BuBytes out) {
    final c = _curve;
    if (c == null) {
      return _u();
    }
    return _curveConvert(c.compress, id, point, out);
  }

  @override
  int curveUncompress(int id, BuBytes point, BuBytes out) {
    final c = _curve;
    if (c == null) {
      return _u();
    }
    return _curveConvert(c.uncompress, id, point, out);
  }

  @override
  int curveNormalizePubkey(int id, BuBytes point, BuBytes out) {
    final c = _curve;
    if (c == null) {
      return _u();
    }
    return _curveConvert(c.normalizePubkey, id, point, out);
  }

  @override
  int curveScalarLen(int id) => _curve?.scalarLen(id) ?? 0;
  @override
  int curveScCheck(int id, BuBytes scalar) {
    final c = _curve;
    if (c == null) {
      return 0;
    }
    final s = _cp(scalar);
    try {
      return c.scCheck(id, s, scalar.length);
    } finally {
      _zf(s, scalar.length);
    }
  }

  @override
  int curveGenerator(int id, BuBytes out) {
    final c = _curve;
    if (c == null) {
      return 6;
    }
    final o = ioCalloc<ffi.Uint8>(out.length);
    try {
      final rc = c.generator(id, o, out.length);
      if (rc == 0) {
        for (var i = 0; i < out.length; i++) {
          out[i] = o[i];
        }
      }
      return rc;
    } finally {
      ioFree(o);
    }
  }

  @override
  int curveIdentity(int id, BuBytes out) {
    final c = _curve;
    if (c == null) {
      return 6;
    }
    final o = ioCalloc<ffi.Uint8>(out.length);
    try {
      final rc = c.identity(id, o, out.length);
      if (rc == 0) {
        for (var i = 0; i < out.length; i++) {
          out[i] = o[i];
        }
      }
      return rc;
    } finally {
      ioFree(o);
    }
  }

  @override
  int curveAdd(int id, BuBytes a, BuBytes b, BuBytes out) {
    final c = _curve;
    if (c == null) {
      return 6;
    }
    final pa = _cp(a);
    final pb = _cp(b);
    final o = ioCalloc<ffi.Uint8>(out.length);
    try {
      final rc = c.add(id, pa, a.length, pb, b.length, o, out.length);
      if (rc == 0) {
        for (var i = 0; i < out.length; i++) {
          out[i] = o[i];
        }
      }
      return rc;
    } finally {
      ioFree(pa);
      ioFree(pb);
      ioFree(o);
    }
  }

  @override
  int curveSub(int id, BuBytes a, BuBytes b, BuBytes out) {
    final c = _curve;
    if (c == null) {
      return 6;
    }
    final pa = _cp(a);
    final pb = _cp(b);
    final o = ioCalloc<ffi.Uint8>(out.length);
    try {
      final rc = c.sub(id, pa, a.length, pb, b.length, o, out.length);
      if (rc == 0) {
        for (var i = 0; i < out.length; i++) {
          out[i] = o[i];
        }
      }
      return rc;
    } finally {
      ioFree(pa);
      ioFree(pb);
      ioFree(o);
    }
  }

  @override
  int curveNeg(int id, BuBytes point, BuBytes out) {
    final c = _curve;
    if (c == null) {
      return 6;
    }
    final p = _cp(point);
    final o = ioCalloc<ffi.Uint8>(out.length);
    try {
      final rc = c.neg(id, p, point.length, o, out.length);
      if (rc == 0) {
        for (var i = 0; i < out.length; i++) {
          out[i] = o[i];
        }
      }
      return rc;
    } finally {
      ioFree(p);
      ioFree(o);
    }
  }

  @override
  int curveMul(int id, BuBytes scalar, BuBytes point, BuBytes out) {
    final c = _curve;
    if (c == null) {
      return 6;
    }
    final s = _cp(scalar);
    final p = _cp(point);
    final o = ioCalloc<ffi.Uint8>(out.length);
    try {
      // Rust ABI: bu_curve_mul(curve, point, point_len, scalar, scalar_len, out, out_len)
      final rc = c.mul(id, p, point.length, s, scalar.length, o, out.length);
      if (rc == 0) {
        for (var i = 0; i < out.length; i++) {
          out[i] = o[i];
        }
      }
      return rc;
    } finally {
      _zf(s, scalar.length);
      ioFree(p);
      ioFree(o);
    }
  }

  @override
  int curveMulBase(int id, BuBytes scalar, BuBytes out) {
    final c = _curve;
    if (c == null) {
      return 6;
    }
    final s = _cp(scalar);
    final o = ioCalloc<ffi.Uint8>(out.length);
    try {
      final rc = c.mulBase(id, s, scalar.length, o, out.length);
      if (rc == 0) {
        for (var i = 0; i < out.length; i++) {
          out[i] = o[i];
        }
      }
      return rc;
    } finally {
      _zf(s, scalar.length);
      ioFree(o);
    }
  }

  @override
  int curveMulAdd(
    int id,
    BuBytes s1,
    BuBytes p1,
    BuBytes s2,
    BuBytes p2,
    BuBytes out,
  ) {
    final c = _curve;
    if (c == null) {
      return 6;
    }
    final a = _cp(s1);
    final b = _cp(p1);
    final d = _cp(s2);
    final e = _cp(p2);
    final o = ioCalloc<ffi.Uint8>(out.length);
    try {
      // Rust ABI: bu_curve_mul_add(curve, p1, p1_len, s1, s1_len, p2, p2_len, s2, s2_len, out, out_len)
      final rc = c.mulAdd(
        id,
        b,
        p1.length,
        a,
        s1.length,
        e,
        p2.length,
        d,
        s2.length,
        o,
        out.length,
      );
      if (rc == 0) {
        for (var i = 0; i < out.length; i++) {
          out[i] = o[i];
        }
      }
      return rc;
    } finally {
      _zf(a, s1.length);
      ioFree(b);
      _zf(d, s2.length);
      ioFree(e);
      ioFree(o);
    }
  }

  @override
  int curveGenerateSecret(int id, BuBytes seed, BuBytes out) {
    final c = _curve;
    if (c == null) {
      return 6;
    }
    final s = _cp(seed);
    final o = ioCalloc<ffi.Uint8>(out.length);
    try {
      final rc = c.generateSecret(id, s, seed.length, o, out.length);
      if (rc == 0) {
        for (var i = 0; i < out.length; i++) {
          out[i] = o[i];
        }
      }
      return rc;
    } finally {
      ioFree(s);
      _zf(o, out.length);
    }
  }

  /// 1 = infinity, 0 = not infinity, else a `BU_CURVE_ERR_*` code.
  /// (The FFI `1` also means null-pointer, but Dart never passes null, so
  /// `1` is unambiguous here. Missing backend → 6, as elsewhere.)
  @override
  int curveIsInfinity(int id, BuBytes point) {
    final c = _curve;
    if (c == null) {
      return 6;
    }
    final p = _cp(point);
    try {
      return c.isInfinity(id, p, point.length);
    } finally {
      ioFree(p);
    }
  }

  @override
  int curveScAdd(int id, BuBytes a, BuBytes b, BuBytes out) {
    final c = _curve;
    if (c == null) {
      return 6;
    }
    final pa = _cp(a);
    final pb = _cp(b);
    final o = ioCalloc<ffi.Uint8>(out.length);
    try {
      final rc = c.scAdd(id, pa, a.length, pb, b.length, o, out.length);
      if (rc == 0) {
        for (var i = 0; i < out.length; i++) {
          out[i] = o[i];
        }
      }
      return rc;
    } finally {
      _zf(pa, a.length);
      _zf(pb, b.length);
      _zf(o, out.length);
    }
  }

  @override
  int curveScSub(int id, BuBytes a, BuBytes b, BuBytes out) {
    final c = _curve;
    if (c == null) {
      return 6;
    }
    final pa = _cp(a);
    final pb = _cp(b);
    final o = ioCalloc<ffi.Uint8>(out.length);
    try {
      final rc = c.scSub(id, pa, a.length, pb, b.length, o, out.length);
      if (rc == 0) {
        for (var i = 0; i < out.length; i++) {
          out[i] = o[i];
        }
      }
      return rc;
    } finally {
      _zf(pa, a.length);
      _zf(pb, b.length);
      _zf(o, out.length);
    }
  }

  @override
  int curveScMul(int id, BuBytes a, BuBytes b, BuBytes out) {
    final c = _curve;
    if (c == null) {
      return 6;
    }
    final pa = _cp(a);
    final pb = _cp(b);
    final o = ioCalloc<ffi.Uint8>(out.length);
    try {
      final rc = c.scMul(id, pa, a.length, pb, b.length, o, out.length);
      if (rc == 0) {
        for (var i = 0; i < out.length; i++) {
          out[i] = o[i];
        }
      }
      return rc;
    } finally {
      _zf(pa, a.length);
      _zf(pb, b.length);
      _zf(o, out.length);
    }
  }

  @override
  int curveScNeg(int id, BuBytes s, BuBytes out) {
    final c = _curve;
    if (c == null) {
      return 6;
    }
    final p = _cp(s);
    final o = ioCalloc<ffi.Uint8>(out.length);
    try {
      final rc = c.scNeg(id, p, s.length, o, out.length);
      if (rc == 0) {
        for (var i = 0; i < out.length; i++) {
          out[i] = o[i];
        }
      }
      return rc;
    } finally {
      _zf(p, s.length);
      _zf(o, out.length);
    }
  }

  @override
  int curveScReduce(int id, BuBytes s, BuBytes out) {
    final c = _curve;
    if (c == null) {
      return 6;
    }
    final p = _cp(s);
    final o = ioCalloc<ffi.Uint8>(out.length);
    try {
      final rc = c.scReduce(id, p, s.length, o, out.length);
      if (rc == 0) {
        for (var i = 0; i < out.length; i++) {
          out[i] = o[i];
        }
      }
      return rc;
    } finally {
      _zf(p, s.length);
      _zf(o, out.length);
    }
  }

  @override
  int ed25519ScReduce32(BuBytes in32, BuBytes out32) {
    final c = _curve;
    if (c == null) {
      return 6;
    }
    final i = _cp(in32);
    final o = ioCalloc<ffi.Uint8>(32);
    try {
      final rc = c.ed25519ScReduce32(i, in32.length, o, 32);
      if (rc == 0) {
        for (var j = 0; j < 32; j++) {
          out32[j] = o[j];
        }
      }
      return rc;
    } finally {
      _zf(i, in32.length);
      _zf(o, 32);
    }
  }

  @override
  int ed25519ScReduce64(BuBytes in64, BuBytes out32) {
    final c = _curve;
    if (c == null) {
      return 6;
    }
    final i = _cp(in64);
    final o = ioCalloc<ffi.Uint8>(32);
    try {
      final rc = c.ed25519ScReduce64(i, in64.length, o, 32);
      if (rc == 0) {
        for (var j = 0; j < 32; j++) {
          out32[j] = o[j];
        }
      }
      return rc;
    } finally {
      _zf(i, in64.length);
      _zf(o, 32);
    }
  }

  @override
  int ed25519FromFeBytes(BuBytes fe32, BuBytes out32) {
    final c = _curve;
    if (c == null) {
      return 6;
    }
    final i = _cp(fe32);
    final o = ioCalloc<ffi.Uint8>(32);
    try {
      final rc = c.ed25519FromFeBytes(i, fe32.length, o, 32);
      if (rc == 0) {
        for (var j = 0; j < 32; j++) {
          out32[j] = o[j];
        }
      }
      return rc;
    } finally {
      _zf(i, fe32.length);
      _zf(o, 32);
    }
  }

  @override
  int ed25519FromFeBytesClearCofactor(BuBytes fe32, BuBytes out32) {
    final c = _curve;
    if (c == null) {
      return 6;
    }
    final i = _cp(fe32);
    final o = ioCalloc<ffi.Uint8>(32);
    try {
      final rc = c.ed25519FromFeBytesClearCofactor(i, fe32.length, o, 32);
      if (rc == 0) {
        for (var j = 0; j < 32; j++) {
          out32[j] = o[j];
        }
      }
      return rc;
    } finally {
      _zf(i, fe32.length);
      _zf(o, 32);
    }
  }

  @override
  int ed25519HashToEc(BuBytes data, BuBytes out32) {
    final c = _curve;
    if (c == null) {
      return 6;
    }
    final d = data.isEmpty ? ffi.nullptr : _cp(data);
    final o = ioCalloc<ffi.Uint8>(32);
    try {
      final rc = c.ed25519HashToEc(d, data.length, o, 32);
      if (rc == 0) {
        for (var j = 0; j < 32; j++) {
          out32[j] = o[j];
        }
      }
      return rc;
    } finally {
      if (d != ffi.nullptr) _zf(d, data.length);
      _zf(o, 32);
    }
  }

  @override
  int ed25519CheckKey(BuBytes pk32) {
    final c = _curve;
    if (c == null) {
      return 0;
    }
    final p = _cp(pk32);
    try {
      return c.ed25519CheckKey(p, pk32.length);
    } finally {
      _zf(p, pk32.length);
    }
  }

  @override
  int ed25519MulByCofactor(BuBytes point32, BuBytes out32) {
    final c = _curve;
    if (c == null) {
      return 6;
    }
    final i = _cp(point32);
    final o = ioCalloc<ffi.Uint8>(32);
    try {
      final rc = c.ed25519MulByCofactor(i, point32.length, o, 32);
      if (rc == 0) {
        for (var j = 0; j < 32; j++) {
          out32[j] = o[j];
        }
      }
      return rc;
    } finally {
      _zf(i, point32.length);
      _zf(o, 32);
    }
  }

  @override
  int ed25519ScalarmultKeyImage(BuBytes hp32, BuBytes a32, BuBytes out32) {
    final c = _curve;
    if (c == null) {
      return 6;
    }
    final hp = _cp(hp32);
    final a = _cp(a32);
    final o = ioCalloc<ffi.Uint8>(32);
    try {
      final rc = c.ed25519ScalarmultKeyImage(
        hp,
        hp32.length,
        a,
        a32.length,
        o,
        32,
      );
      if (rc == 0) {
        for (var j = 0; j < 32; j++) {
          out32[j] = o[j];
        }
      }
      return rc;
    } finally {
      _zf(hp, hp32.length);
      _zf(a, a32.length);
      _zf(o, 32);
    }
  }

  @override
  int ed25519Mul8Mult(BuBytes scalar32, BuBytes point32, BuBytes out32) {
    final c = _curve;
    if (c == null) {
      return 6;
    }
    final s = _cp(scalar32);
    final p = _cp(point32);
    final o = ioCalloc<ffi.Uint8>(32);
    try {
      final rc = c.ed25519Mul8Mult(
        s,
        scalar32.length,
        p,
        point32.length,
        o,
        32,
      );
      if (rc == 0) {
        for (var j = 0; j < 32; j++) {
          out32[j] = o[j];
        }
      }
      return rc;
    } finally {
      _zf(s, scalar32.length);
      _zf(p, point32.length);
      _zf(o, 32);
    }
  }

  @override
  int ed25519GeDsmPrecomp(BuBytes point32, BuBytes out256) {
    final c = _curve;
    if (c == null) {
      return 6;
    }
    final i = _cp(point32);
    final o = ioCalloc<ffi.Uint8>(256);
    try {
      final rc = c.ed25519GeDsmPrecomp(i, point32.length, o, 256);
      if (rc == 0) {
        for (var j = 0; j < 256; j++) {
          out256[j] = o[j];
        }
      }
      return rc;
    } finally {
      _zf(i, point32.length);
      _zf(o, 256);
    }
  }

  @override
  int ed25519GeDoubleScalarMultPrecomp(
    BuBytes a32,
    BuBytes aI256,
    BuBytes b32,
    BuBytes bI256,
    BuBytes out32,
  ) {
    final c = _curve;
    if (c == null) {
      return 6;
    }
    final a = _cp(a32);
    final ai = _cp(aI256);
    final b = _cp(b32);
    final bi = _cp(bI256);
    final o = ioCalloc<ffi.Uint8>(32);
    try {
      final rc = c.ed25519GeDoubleScalarMultPrecomp(a, ai, b, bi, o, 32);
      if (rc == 0) {
        for (var j = 0; j < 32; j++) {
          out32[j] = o[j];
        }
      }
      return rc;
    } finally {
      _zf(a, 32);
      _zf(ai, 256);
      _zf(b, 32);
      _zf(bi, 256);
      _zf(o, 32);
    }
  }

  @override
  int ed25519GeDoubleScalarMultBase(
    BuBytes a32,
    BuBytes gA32,
    BuBytes b32,
    BuBytes out32,
  ) {
    final c = _curve;
    if (c == null) {
      return 6;
    }
    final a = _cp(a32);
    final ga = _cp(gA32);
    final b = _cp(b32);
    final o = ioCalloc<ffi.Uint8>(32);
    try {
      final rc = c.ed25519GeDoubleScalarMultBase(a, ga, b, o, 32);
      if (rc == 0) {
        for (var j = 0; j < 32; j++) {
          out32[j] = o[j];
        }
      }
      return rc;
    } finally {
      _zf(a, 32);
      _zf(ga, 32);
      _zf(b, 32);
      _zf(o, 32);
    }
  }

  @override
  int ed25519GeTripleScalarMultBase(
    BuBytes a32,
    BuBytes b32,
    BuBytes bI256,
    BuBytes c32,
    BuBytes cI256,
    BuBytes out32,
  ) {
    final c = _curve;
    if (c == null) {
      return 6;
    }
    final a = _cp(a32);
    final b = _cp(b32);
    final bi = _cp(bI256);
    final cc = _cp(c32);
    final ci = _cp(cI256);
    final o = ioCalloc<ffi.Uint8>(32);
    try {
      final rc = c.ed25519GeTripleScalarMultBase(a, b, bi, cc, ci, o, 32);
      if (rc == 0) {
        for (var j = 0; j < 32; j++) {
          out32[j] = o[j];
        }
      }
      return rc;
    } finally {
      _zf(a, 32);
      _zf(b, 32);
      _zf(bi, 256);
      _zf(cc, 32);
      _zf(ci, 256);
      _zf(o, 32);
    }
  }

  @override
  int ed25519GeTripleScalarMultPrecomp(
    BuBytes a32,
    BuBytes aI256,
    BuBytes b32,
    BuBytes bI256,
    BuBytes c32,
    BuBytes cI256,
    BuBytes out32,
  ) {
    final c = _curve;
    if (c == null) {
      return 6;
    }
    final a = _cp(a32);
    final ai = _cp(aI256);
    final b = _cp(b32);
    final bi = _cp(bI256);
    final cc = _cp(c32);
    final ci = _cp(cI256);
    final o = ioCalloc<ffi.Uint8>(32);
    try {
      final rc = c.ed25519GeTripleScalarMultPrecomp(
        a,
        ai,
        b,
        bi,
        cc,
        ci,
        o,
        32,
      );
      if (rc == 0) {
        for (var j = 0; j < 32; j++) {
          out32[j] = o[j];
        }
      }
      return rc;
    } finally {
      _zf(a, 32);
      _zf(ai, 256);
      _zf(b, 32);
      _zf(bi, 256);
      _zf(cc, 32);
      _zf(ci, 256);
      _zf(o, 32);
    }
  }

  @override
  int jubjubScReduce64(BuBytes in64, BuBytes out32) {
    final c = _curve;
    if (c == null) {
      return 6;
    }
    final i = _cp(in64);
    final o = ioCalloc<ffi.Uint8>(32);
    try {
      final rc = c.jubjubScReduce64(i, in64.length, o, 32);
      if (rc == 0) {
        for (var j = 0; j < 32; j++) {
          out32[j] = o[j];
        }
      }
      return rc;
    } finally {
      _zf(i, in64.length);
      _zf(o, 32);
    }
  }

  @override
  int ristrettoFromEdwards(BuBytes ed32, BuBytes out32) {
    final c = _curve;
    if (c == null) {
      return 6;
    }
    final i = _cp(ed32);
    final o = ioCalloc<ffi.Uint8>(32);
    try {
      final rc = c.ristrettoFromEdwards(i, ed32.length, o, 32);
      if (rc == 0) {
        for (var j = 0; j < 32; j++) {
          out32[j] = o[j];
        }
      }
      return rc;
    } finally {
      _zf(i, ed32.length);
      _zf(o, 32);
    }
  }

  @override
  int ristrettoToEdwards(BuBytes ristretto32, BuBytes out32) {
    final c = _curve;
    if (c == null) {
      return 6;
    }
    final i = _cp(ristretto32);
    final o = ioCalloc<ffi.Uint8>(32);
    try {
      final rc = c.ristrettoToEdwards(i, ristretto32.length, o, 32);
      if (rc == 0) {
        for (var j = 0; j < 32; j++) {
          out32[j] = o[j];
        }
      }
      return rc;
    } finally {
      _zf(i, ristretto32.length);
      _zf(o, 32);
    }
  }

  @override
  int pallasScReduce64(BuBytes in64, BuBytes out32) {
    final c = _curve;
    if (c == null) {
      return 6;
    }
    final i = _cp(in64);
    final o = ioCalloc<ffi.Uint8>(32);
    try {
      final rc = c.pallasScReduce64(i, in64.length, o, 32);
      if (rc == 0) {
        for (var j = 0; j < 32; j++) {
          out32[j] = o[j];
        }
      }
      return rc;
    } finally {
      _zf(i, in64.length);
      _zf(o, 32);
    }
  }

  @override
  int vestaScReduce64(BuBytes in64, BuBytes out32) {
    final c = _curve;
    if (c == null) {
      return 6;
    }
    final i = _cp(in64);
    final o = ioCalloc<ffi.Uint8>(32);
    try {
      final rc = c.vestaScReduce64(i, in64.length, o, 32);
      if (rc == 0) {
        for (var j = 0; j < 32; j++) {
          out32[j] = o[j];
        }
      }
      return rc;
    } finally {
      _zf(i, in64.length);
      _zf(o, 32);
    }
  }

  @override
  int blsHashToG1(BuBytes msg, BuBytes dst, BuBytes out48) {
    final c = _curve;
    if (c == null) {
      return 6;
    }
    final m = _cp(msg);
    final d = _cp(dst);
    final o = ioCalloc<ffi.Uint8>(48);
    try {
      final rc = c.hashToG1(m, msg.length, d, dst.length, o, 48);
      if (rc == 0) {
        for (var i = 0; i < 48; i++) {
          out48[i] = o[i];
        }
      }
      return rc;
    } finally {
      ioFree(m);
      ioFree(d);
      ioFree(o);
    }
  }

  @override
  int blsHashToG2(BuBytes msg, BuBytes dst, BuBytes out96) {
    final c = _curve;
    if (c == null) {
      return 6;
    }
    final m = _cp(msg);
    final d = _cp(dst);
    final o = ioCalloc<ffi.Uint8>(96);
    try {
      final rc = c.hashToG2(m, msg.length, d, dst.length, o, 96);
      if (rc == 0) {
        for (var i = 0; i < 96; i++) {
          out96[i] = o[i];
        }
      }
      return rc;
    } finally {
      ioFree(m);
      ioFree(d);
      ioFree(o);
    }
  }

  @override
  @override
  int ed25519MulVartime(BuBytes scalar32, BuBytes point32, BuBytes out32) {
    final c = _curve;
    if (c == null) {
      return 6;
    }
    final s = _cp(scalar32);
    final p = _cp(point32);
    final o = ioCalloc<ffi.Uint8>(32);
    try {
      final rc = c.ed25519MulVartime(s, p, o);
      if (rc == 0) {
        for (var i = 0; i < 32; i++) {
          out32[i] = o[i];
        }
      }
      return rc;
    } finally {
      ioFree(s);
      ioFree(p);
      ioFree(o);
    }
  }

  @override
  int ed25519MulBaseVartime(BuBytes scalar32, BuBytes out32) {
    final c = _curve;
    if (c == null) {
      return 6;
    }
    final s = _cp(scalar32);
    final o = ioCalloc<ffi.Uint8>(32);
    try {
      final rc = c.ed25519MulBaseVartime(s, o);
      if (rc == 0) {
        for (var i = 0; i < 32; i++) {
          out32[i] = o[i];
        }
      }
      return rc;
    } finally {
      ioFree(s);
      ioFree(o);
    }
  }

  @override
  int ed25519MulAddVartime(
    BuBytes s1,
    BuBytes p1,
    BuBytes s2,
    BuBytes p2,
    BuBytes out32,
  ) {
    final c = _curve;
    if (c == null) {
      return 6;
    }
    final a = _cp(s1);
    final b = _cp(p1);
    final d = _cp(s2);
    final e = _cp(p2);
    final o = ioCalloc<ffi.Uint8>(32);
    try {
      final rc = c.ed25519MulAddVartime(a, b, d, e, o);
      if (rc == 0) {
        for (var i = 0; i < 32; i++) {
          out32[i] = o[i];
        }
      }
      return rc;
    } finally {
      ioFree(a);
      ioFree(b);
      ioFree(d);
      ioFree(e);
      ioFree(o);
    }
  }

  @override
  int ed25519AddVartime(BuBytes a32, BuBytes b32, BuBytes out32) {
    final c = _curve;
    if (c == null) {
      return 6;
    }
    final a = _cp(a32);
    final b = _cp(b32);
    final o = ioCalloc<ffi.Uint8>(32);
    try {
      final rc = c.ed25519AddVartime(a, b, o);
      if (rc == 0) {
        for (var i = 0; i < 32; i++) {
          out32[i] = o[i];
        }
      }
      return rc;
    } finally {
      ioFree(a);
      ioFree(b);
      ioFree(o);
    }
  }

  @override
  int ed25519SubVartime(BuBytes a32, BuBytes b32, BuBytes out32) {
    final c = _curve;
    if (c == null) {
      return 6;
    }
    final a = _cp(a32);
    final b = _cp(b32);
    final o = ioCalloc<ffi.Uint8>(32);
    try {
      final rc = c.ed25519SubVartime(a, b, o);
      if (rc == 0) {
        for (var i = 0; i < 32; i++) {
          out32[i] = o[i];
        }
      }
      return rc;
    } finally {
      ioFree(a);
      ioFree(b);
      ioFree(o);
    }
  }

  @override
  int ed25519NegVartime(BuBytes p32, BuBytes out32) {
    final c = _curve;
    if (c == null) {
      return 6;
    }
    final p = _cp(p32);
    final o = ioCalloc<ffi.Uint8>(32);
    try {
      final rc = c.ed25519NegVartime(p, o);
      if (rc == 0) {
        for (var i = 0; i < 32; i++) {
          out32[i] = o[i];
        }
      }
      return rc;
    } finally {
      ioFree(p);
      ioFree(o);
    }
  }

  @override
  int ed25519DoubleVartime(BuBytes p32, BuBytes out32) {
    final c = _curve;
    if (c == null) {
      return 6;
    }
    final p = _cp(p32);
    final o = ioCalloc<ffi.Uint8>(32);
    try {
      final rc = c.ed25519DoubleVartime(p, o);
      if (rc == 0) {
        for (var i = 0; i < 32; i++) {
          out32[i] = o[i];
        }
      }
      return rc;
    } finally {
      ioFree(p);
      ioFree(o);
    }
  }

  @override
  int pallasHashToCurve(BuBytes msg, BuBytes dst, BuBytes out) {
    final c = _curve;
    if (c == null) {
      return 6;
    }
    final m = _cp(msg);
    final d = _cp(dst);
    final o = ioCalloc<ffi.Uint8>(out.length);
    try {
      final rc = c.pallasHashToCurve(
        m,
        msg.length,
        d,
        dst.length,
        o,
        out.length,
      );
      if (rc == 0) {
        for (var i = 0; i < out.length; i++) {
          out[i] = o[i];
        }
      }
      return rc;
    } finally {
      ioFree(m);
      ioFree(d);
      ioFree(o);
    }
  }

  @override
  int pallasHashToCurvePasta(BuBytes domain, BuBytes msg, BuBytes out) {
    final c = _curve;
    if (c == null) {
      return 6;
    }
    final d = _cp(domain);
    final m = _cp(msg);
    final o = ioCalloc<ffi.Uint8>(out.length);
    try {
      // Rust: bu_pallas_hash_to_curve_pasta(domain, domain_len, msg, msg_len, out, out_len)
      final rc = c.pallasHashToCurvePasta(
        d,
        domain.length,
        m,
        msg.length,
        o,
        out.length,
      );
      if (rc == 0) {
        for (var i = 0; i < out.length; i++) {
          out[i] = o[i];
        }
      }
      return rc;
    } finally {
      ioFree(d);
      ioFree(m);
      ioFree(o);
    }
  }

  @override
  int vestaHashToCurve(BuBytes msg, BuBytes dst, BuBytes out) {
    final c = _curve;
    if (c == null) {
      return 6;
    }
    final m = _cp(msg);
    final d = _cp(dst);
    final o = ioCalloc<ffi.Uint8>(out.length);
    try {
      final rc = c.vestaHashToCurve(
        m,
        msg.length,
        d,
        dst.length,
        o,
        out.length,
      );
      if (rc == 0) {
        for (var i = 0; i < out.length; i++) {
          out[i] = o[i];
        }
      }
      return rc;
    } finally {
      ioFree(m);
      ioFree(d);
      ioFree(o);
    }
  }

  @override
  int ecdsaK1PublicKey(BuBytes sk, BuBytes out33) {
    final s = _sig;
    if (s == null) {
      return 6;
    }
    final a = _cp(sk);
    final o = ioCalloc<ffi.Uint8>(33);
    try {
      final rc = s.ecdsaK1PublicKey(a, sk.length, o, 33);
      if (rc == 0) {
        for (var i = 0; i < 33; i++) {
          out33[i] = o[i];
        }
      }
      return rc;
    } finally {
      _zf(a, sk.length);
      ioFree(o);
    }
  }

  @override
  int ecdsaK1Sign(BuBytes sk, BuBytes hash32, BuBytes out64) {
    final s = _sig;
    if (s == null) {
      return 6;
    }
    final a = _cp(sk);
    final h = _cp(hash32);
    final o = ioCalloc<ffi.Uint8>(64);
    try {
      final rc = s.ecdsaK1Sign(a, sk.length, h, hash32.length, o, 64);
      if (rc == 0) {
        for (var i = 0; i < 64; i++) {
          out64[i] = o[i];
        }
      }
      return rc;
    } finally {
      _zf(a, sk.length);
      ioFree(h);
      ioFree(o);
    }
  }

  @override
  int ecdsaK1SignEx(BuBytes sk, BuBytes hash32, BuBytes? extra, BuBytes out64) {
    final s = _sig;
    if (s == null) {
      return 6;
    }
    final a = _cp(sk);
    final h = _cp(hash32);
    final e = extra == null ? ffi.nullptr : _cp(extra);
    final el = extra?.length ?? 0;
    final o = ioCalloc<ffi.Uint8>(64);
    try {
      final rc = s.ecdsaK1SignEx(a, sk.length, h, hash32.length, e, el, o, 64);
      if (rc == 0) {
        for (var i = 0; i < 64; i++) {
          out64[i] = o[i];
        }
      }
      return rc;
    } finally {
      _zf(a, sk.length);
      ioFree(h);
      if (e != ffi.nullptr) _zf(e, el);
      ioFree(o);
    }
  }

  @override
  int ecdsaK1Verify(BuBytes pk33, BuBytes hash32, BuBytes sig64) {
    final s = _sig;
    if (s == null) {
      return 6;
    }
    final p = _cp(pk33);
    final h = _cp(hash32);
    final g = _cp(sig64);
    try {
      return s.ecdsaK1Verify(p, pk33.length, h, hash32.length, g, sig64.length);
    } finally {
      ioFree(p);
      ioFree(h);
      ioFree(g);
    }
  }

  @override
  int ecdsaK1Recover(BuBytes hash32, BuBytes sig64, int recId, BuBytes out33) {
    final s = _sig;
    if (s == null) {
      return 6;
    }
    final h = _cp(hash32);
    final g = _cp(sig64);
    final o = ioCalloc<ffi.Uint8>(33);
    try {
      final rc = s.ecdsaK1Recover(h, g, recId, o, 33);
      if (rc == 0) {
        for (var i = 0; i < 33; i++) {
          out33[i] = o[i];
        }
      }
      return rc;
    } finally {
      ioFree(h);
      ioFree(g);
      ioFree(o);
    }
  }

  @override
  int ecdsaK1RecoveryId(
    BuBytes hash32,
    BuBytes sig64,
    BuBytes pk33,
    BuBytes outId1,
  ) {
    final s = _sig;
    if (s == null) {
      return 6;
    }
    final h = _cp(hash32);
    final g = _cp(sig64);
    final o = ioCalloc<ffi.Uint8>(33);
    try {
      for (var id = 0; id < 4; id++) {
        if (s.ecdsaK1Recover(h, g, id, o, 33) != 0) continue;
        var match = true;
        for (var i = 0; i < 33; i++) {
          if (o[i] != pk33[i]) {
            match = false;
            break;
          }
        }
        if (match) {
          outId1[0] = id;
          return 0;
        }
      }
      return 7;
    } finally {
      ioFree(h);
      ioFree(g);
      ioFree(o);
    }
  }

  @override
  int schnorrPublicKey(BuBytes sk, BuBytes out32) {
    final s = _sig;
    if (s == null) {
      return 6;
    }
    final a = _cp(sk);
    final o = ioCalloc<ffi.Uint8>(32);
    try {
      final rc = s.schnorrPublicKey(a, sk.length, o, 32);
      if (rc == 0) {
        for (var i = 0; i < 32; i++) {
          out32[i] = o[i];
        }
      }
      return rc;
    } finally {
      _zf(a, sk.length);
      ioFree(o);
    }
  }

  @override
  int schnorrSign(BuBytes sk, BuBytes msg32, BuBytes? aux, BuBytes out64) {
    final s = _sig;
    if (s == null) {
      return 6;
    }
    final a = _cp(sk);
    final m = _cp(msg32);
    final o = ioCalloc<ffi.Uint8>(64);
    try {
      final int rc;
      if (aux != null && aux.length == 32) {
        final x = _cp(aux);
        try {
          rc = s.schnorrSignAux(
            a,
            sk.length,
            m,
            msg32.length,
            x,
            ffi.nullptr,
            o,
            64,
          );
        } finally {
          ioFree(x);
        }
      } else {
        rc = s.schnorrSign(a, sk.length, m, msg32.length, o, 64);
      }
      if (rc == 0) {
        for (var i = 0; i < 64; i++) {
          out64[i] = o[i];
        }
      }
      return rc;
    } finally {
      _zf(a, sk.length);
      ioFree(m);
      ioFree(o);
    }
  }

  @override
  int schnorrSignAux(
    BuBytes sk,
    BuBytes msg,
    BuBytes? aux,
    BuBytes? tweak,
    BuBytes out64,
  ) {
    final s = _sig;
    if (s == null) {
      return 6;
    }
    if (sk.length != 32 ||
        (aux != null && aux.length != 32) ||
        (tweak != null && tweak.length != 32)) {
      return 3;
    }
    final a = _cp(sk);
    final m = _cp(msg);
    final x = (aux == null || aux.isEmpty) ? ffi.nullptr : _cp(aux);
    final t = (tweak == null || tweak.isEmpty) ? ffi.nullptr : _cp(tweak);
    final o = ioCalloc<ffi.Uint8>(64);
    try {
      final rc = s.schnorrSignAux(a, sk.length, m, msg.length, x, t, o, 64);
      if (rc == 0) {
        for (var i = 0; i < 64; i++) {
          out64[i] = o[i];
        }
      }
      return rc;
    } finally {
      _zf(a, sk.length);
      ioFree(m);
      if (x != ffi.nullptr) _zf(x, 32);
      if (t != ffi.nullptr) _zf(t, 32);
      ioFree(o);
    }
  }

  @override
  int schnorrVerify(BuBytes pk32, BuBytes msg32, BuBytes sig64) {
    final s = _sig;
    if (s == null) {
      return 6;
    }
    final p = _cp(pk32);
    final m = _cp(msg32);
    final g = _cp(sig64);
    try {
      return s.schnorrVerify(p, pk32.length, m, msg32.length, g, sig64.length);
    } finally {
      ioFree(p);
      ioFree(m);
      ioFree(g);
    }
  }

  @override
  int schnorrTweakSecret(BuBytes sk, BuBytes tweak32, BuBytes out32) {
    final s = _sig;
    if (s == null) {
      return 6;
    }
    final a = _cp(sk);
    final tw = _cp(tweak32);
    final o = ioCalloc<ffi.Uint8>(32);
    try {
      final rc = s.schnorrTweakSecret(a, tw, o, 32);
      if (rc == 0) {
        for (var i = 0; i < 32; i++) {
          out32[i] = o[i];
        }
      }
      return rc;
    } finally {
      _zf(a, sk.length);
      ioFree(tw);
      _zf(o, 32);
    }
  }

  @override
  int ecdsaR1PublicKey(BuBytes sk, BuBytes out33) {
    final s = _sig;
    if (s == null) {
      return 6;
    }
    final a = _cp(sk);
    final o = ioCalloc<ffi.Uint8>(33);
    try {
      final rc = s.ecdsaR1PublicKey(a, sk.length, o, 33);
      if (rc == 0) {
        for (var i = 0; i < 33; i++) {
          out33[i] = o[i];
        }
      }
      return rc;
    } finally {
      _zf(a, sk.length);
      ioFree(o);
    }
  }

  @override
  int ecdsaR1Sign(BuBytes sk, BuBytes hash32, BuBytes out64) {
    final s = _sig;
    if (s == null) {
      return 6;
    }
    final a = _cp(sk);
    final h = _cp(hash32);
    final o = ioCalloc<ffi.Uint8>(64);
    try {
      final rc = s.ecdsaR1Sign(a, sk.length, h, hash32.length, o, 64);
      if (rc == 0) {
        for (var i = 0; i < 64; i++) {
          out64[i] = o[i];
        }
      }
      return rc;
    } finally {
      _zf(a, sk.length);
      ioFree(h);
      ioFree(o);
    }
  }

  @override
  int ecdsaR1SignEx(BuBytes sk, BuBytes hash32, BuBytes? extra, BuBytes out64) {
    final s = _sig;
    if (s == null) {
      return 6;
    }
    final a = _cp(sk);
    final h = _cp(hash32);
    final e = extra == null ? ffi.nullptr : _cp(extra);
    final el = extra?.length ?? 0;
    final o = ioCalloc<ffi.Uint8>(64);
    try {
      final rc = s.ecdsaR1SignEx(a, sk.length, h, hash32.length, e, el, o, 64);
      if (rc == 0) {
        for (var i = 0; i < 64; i++) {
          out64[i] = o[i];
        }
      }
      return rc;
    } finally {
      _zf(a, sk.length);
      ioFree(h);
      if (e != ffi.nullptr) _zf(e, el);
      ioFree(o);
    }
  }

  @override
  int ecdsaR1Verify(BuBytes pk33, BuBytes hash32, BuBytes sig64) {
    final s = _sig;
    if (s == null) {
      return 6;
    }
    final p = _cp(pk33);
    final h = _cp(hash32);
    final g = _cp(sig64);
    try {
      return s.ecdsaR1Verify(p, pk33.length, h, hash32.length, g, sig64.length);
    } finally {
      ioFree(p);
      ioFree(h);
      ioFree(g);
    }
  }

  @override
  int ecdsaR1Recover(BuBytes hash32, BuBytes sig64, int recId, BuBytes out33) {
    final s = _sig;
    if (s == null || s.ecdsaR1Recover == null) {
      return 6;
    }
    final h = _cp(hash32);
    final g = _cp(sig64);
    final o = ioCalloc<ffi.Uint8>(33);
    try {
      final rc = s.ecdsaR1Recover!(h, g, recId, o, 33);
      if (rc == 0) {
        for (var i = 0; i < 33; i++) {
          out33[i] = o[i];
        }
      }
      return rc;
    } finally {
      ioFree(h);
      ioFree(g);
      ioFree(o);
    }
  }

  @override
  int ecdsaR1RecoveryId(
    BuBytes hash32,
    BuBytes sig64,
    BuBytes pk33,
    BuBytes outId1,
  ) {
    final s = _sig;
    if (s == null || s.ecdsaR1RecoveryId == null) {
      return 6;
    }
    final h = _cp(hash32);
    final g = _cp(sig64);
    final p = _cp(pk33);
    final o = ioCalloc<ffi.Uint8>(1);
    try {
      final rc = s.ecdsaR1RecoveryId!(h, g, p, pk33.length, o);
      if (rc == 0) outId1[0] = o[0];
      return rc;
    } finally {
      ioFree(h);
      ioFree(g);
      ioFree(p);
      ioFree(o);
    }
  }

  @override
  int schnorrTweakPublic(BuBytes xOnlyPk, BuBytes tweak32, BuBytes out32) {
    final s = _sig;
    if (s == null) {
      return 6;
    }
    final p = _cp(xOnlyPk);
    final tw = _cp(tweak32);
    final o = ioCalloc<ffi.Uint8>(32);
    try {
      final rc = s.schnorrTweakPublic(p, tw, o, 32);
      if (rc == 0) {
        for (var i = 0; i < 32; i++) {
          out32[i] = o[i];
        }
      }
      return rc;
    } finally {
      ioFree(p);
      ioFree(tw);
      ioFree(o);
    }
  }

  @override
  int schnorrBchSign(
    BuBytes sk,
    BuBytes hash32,
    BuBytes? extra,
    BuBytes out64,
  ) {
    final s = _sig;
    if (s == null) {
      return 6;
    }
    final a = _cp(sk);
    final h = _cp(hash32);
    final e = extra == null ? ffi.nullptr : _cp(extra);
    final el = extra?.length ?? 0;
    final o = ioCalloc<ffi.Uint8>(64);
    try {
      final rc = s.schnorrBchSign(a, sk.length, h, hash32.length, e, el, o, 64);
      if (rc == 0) {
        for (var i = 0; i < 64; i++) {
          out64[i] = o[i];
        }
      }
      return rc;
    } finally {
      _zf(a, sk.length);
      ioFree(h);
      if (e != ffi.nullptr) _zf(e, el);
      ioFree(o);
    }
  }

  @override
  int schnorrBchVerify(BuBytes pk, BuBytes hash32, BuBytes sig64) {
    final s = _sig;
    if (s == null) {
      return 6;
    }
    final p = _cp(pk);
    final h = _cp(hash32);
    final g = _cp(sig64);
    try {
      return s.schnorrBchVerify(
        p,
        pk.length,
        h,
        hash32.length,
        g,
        sig64.length,
      );
    } finally {
      ioFree(p);
      ioFree(h);
      ioFree(g);
    }
  }

  @override
  int ed25519PublicKey(BuBytes sk, BuBytes out32) {
    final s = _sig;
    if (s == null) {
      return 6;
    }
    final a = _cp(sk);
    final o = ioCalloc<ffi.Uint8>(32);
    try {
      final rc = s.ed25519PublicKey(a, sk.length, o, 32);
      if (rc == 0) {
        for (var i = 0; i < 32; i++) {
          out32[i] = o[i];
        }
      }
      return rc;
    } finally {
      _zf(a, sk.length);
      ioFree(o);
    }
  }

  @override
  int ed25519Sign(BuBytes sk, BuBytes msg, BuBytes out64) {
    final s = _sig;
    if (s == null) {
      return 6;
    }
    final a = _cp(sk);
    final m = _cp(msg);
    final o = ioCalloc<ffi.Uint8>(64);
    try {
      final rc = s.ed25519Sign(a, sk.length, m, msg.length, o, 64);
      if (rc == 0) {
        for (var i = 0; i < 64; i++) {
          out64[i] = o[i];
        }
      }
      return rc;
    } finally {
      _zf(a, sk.length);
      ioFree(m);
      ioFree(o);
    }
  }

  @override
  int ed25519Verify(BuBytes pk32, BuBytes msg, BuBytes sig64) {
    final s = _sig;
    if (s == null) {
      return 6;
    }
    final p = _cp(pk32);
    final m = _cp(msg);
    final g = _cp(sig64);
    try {
      return s.ed25519Verify(p, pk32.length, m, msg.length, g, sig64.length);
    } finally {
      ioFree(p);
      ioFree(m);
      ioFree(g);
    }
  }

  @override
  int ed25519PublicKeyVariant(
    BuEd25519Variant variant,
    BuBytes sk,
    BuBytes out32,
  ) {
    final s = _sig;
    if (s == null) {
      return 6;
    }
    final a = _cp(sk);
    final o = ioCalloc<ffi.Uint8>(32);
    try {
      final rc = s.ed25519PublicKeyVariant(variant.id, a, sk.length, o, 32);
      if (rc == 0) {
        for (var i = 0; i < 32; i++) {
          out32[i] = o[i];
        }
      }
      return rc;
    } finally {
      _zf(a, sk.length);
      ioFree(o);
    }
  }

  @override
  int ed25519SignVariant(
    BuEd25519Variant variant,
    BuBytes sk,
    BuBytes msg,
    BuBytes out64,
  ) {
    final s = _sig;
    if (s == null) {
      return 6;
    }
    final a = _cp(sk);
    final m = _cp(msg);
    final o = ioCalloc<ffi.Uint8>(64);
    try {
      final rc = s.ed25519SignVariant(
        variant.id,
        a,
        sk.length,
        m,
        msg.length,
        o,
        64,
      );
      if (rc == 0) {
        for (var i = 0; i < 64; i++) {
          out64[i] = o[i];
        }
      }
      return rc;
    } finally {
      _zf(a, sk.length);
      ioFree(m);
      ioFree(o);
    }
  }

  @override
  int ed25519VerifyVariant(
    BuEd25519Variant variant,
    BuBytes pk32,
    BuBytes msg,
    BuBytes sig64,
  ) {
    final s = _sig;
    if (s == null) {
      return 6;
    }
    final p = _cp(pk32);
    final m = _cp(msg);
    final g = _cp(sig64);
    try {
      return s.ed25519VerifyVariant(
        variant.id,
        p,
        pk32.length,
        m,
        msg.length,
        g,
        sig64.length,
      );
    } finally {
      ioFree(p);
      ioFree(m);
      ioFree(g);
    }
  }

  @override
  int blsPublicKeyG1(BuBytes sk, BuBytes out48) {
    final b = _bls;
    if (b == null) {
      return 6;
    }
    final s = _cp(sk);
    final o = ioCalloc<ffi.Uint8>(48);
    try {
      final rc = b.skToPkG1(s, sk.length, o, 48);
      if (rc == 0) {
        for (var i = 0; i < 48; i++) {
          out48[i] = o[i];
        }
      }
      return rc;
    } finally {
      _zf(s, sk.length);
      ioFree(o);
    }
  }

  @override
  int blsPublicKeyG2(BuBytes sk, BuBytes out96) {
    final b = _bls;
    if (b == null) {
      return 6;
    }
    final s = _cp(sk);
    final o = ioCalloc<ffi.Uint8>(96);
    try {
      final rc = b.skToPkG2(s, sk.length, o, 96);
      if (rc == 0) {
        for (var i = 0; i < 96; i++) {
          out96[i] = o[i];
        }
      }
      return rc;
    } finally {
      _zf(s, sk.length);
      ioFree(o);
    }
  }

  @override
  int blsSignMinPk(BuBytes sk, BuBytes msg, BuBytes? dst, BuBytes out96) {
    final b = _bls;
    if (b == null) {
      return 6;
    }
    final s = _cp(sk);
    final m = _cp(msg);
    final d = (dst == null || dst.isEmpty) ? ffi.nullptr : _cp(dst);
    final dl = dst?.length ?? 0;
    final o = ioCalloc<ffi.Uint8>(96);
    try {
      final rc = b.signMinPk(s, sk.length, m, msg.length, d, dl, o, 96);
      if (rc == 0) {
        for (var i = 0; i < 96; i++) {
          out96[i] = o[i];
        }
      }
      return rc;
    } finally {
      _zf(s, sk.length);
      ioFree(m);
      if (d != ffi.nullptr) ioFree(d);
      ioFree(o);
    }
  }

  @override
  int blsSignMinSig(BuBytes sk, BuBytes msg, BuBytes? dst, BuBytes out48) {
    final b = _bls;
    if (b == null) {
      return 6;
    }
    final s = _cp(sk);
    final m = _cp(msg);
    final d = (dst == null || dst.isEmpty) ? ffi.nullptr : _cp(dst);
    final dl = dst?.length ?? 0;
    final o = ioCalloc<ffi.Uint8>(48);
    try {
      final rc = b.signMinSig(s, sk.length, m, msg.length, d, dl, o, 48);
      if (rc == 0) {
        for (var i = 0; i < 48; i++) {
          out48[i] = o[i];
        }
      }
      return rc;
    } finally {
      _zf(s, sk.length);
      ioFree(m);
      if (d != ffi.nullptr) ioFree(d);
      ioFree(o);
    }
  }

  @override
  int blsVerifyMinPk(BuBytes pk48, BuBytes msg, BuBytes sig96, BuBytes? dst) {
    final b = _bls;
    if (b == null) {
      return 6;
    }
    final p = _cp(pk48);
    final m = _cp(msg);
    final g = _cp(sig96);
    final d = (dst == null || dst.isEmpty) ? ffi.nullptr : _cp(dst);
    final dl = dst?.length ?? 0;
    try {
      return b.verifyMinPk(
        p,
        pk48.length,
        m,
        msg.length,
        g,
        sig96.length,
        d,
        dl,
      );
    } finally {
      ioFree(p);
      ioFree(m);
      ioFree(g);
      if (d != ffi.nullptr) ioFree(d);
    }
  }

  @override
  int blsVerifyMinSig(BuBytes pk96, BuBytes msg, BuBytes sig48, BuBytes? dst) {
    final b = _bls;
    if (b == null) {
      return 6;
    }
    final p = _cp(pk96);
    final m = _cp(msg);
    final g = _cp(sig48);
    final d = (dst == null || dst.isEmpty) ? ffi.nullptr : _cp(dst);
    final dl = dst?.length ?? 0;
    try {
      return b.verifyMinSig(
        p,
        pk96.length,
        m,
        msg.length,
        g,
        sig48.length,
        d,
        dl,
      );
    } finally {
      ioFree(p);
      ioFree(m);
      ioFree(g);
      if (d != ffi.nullptr) ioFree(d);
    }
  }

  @override
  int blsAggregatePublicKeysG1(BuBytes pksConcat, BuBytes out48) {
    final b = _bls;
    if (b == null) {
      return 6;
    }
    final p = _cp(pksConcat);
    final o = ioCalloc<ffi.Uint8>(48);
    try {
      final rc = b.aggregatePksG1(p, pksConcat.length, o, 48);
      if (rc == 0) {
        for (var i = 0; i < 48; i++) {
          out48[i] = o[i];
        }
      }
      return rc;
    } finally {
      ioFree(p);
      ioFree(o);
    }
  }

  @override
  int blsAggregatePublicKeysG2(BuBytes pksConcat, BuBytes out96) {
    final b = _bls;
    if (b == null) {
      return 6;
    }
    final p = _cp(pksConcat);
    final o = ioCalloc<ffi.Uint8>(96);
    try {
      final rc = b.aggregatePksG2(p, pksConcat.length, o, 96);
      if (rc == 0) {
        for (var i = 0; i < 96; i++) {
          out96[i] = o[i];
        }
      }
      return rc;
    } finally {
      ioFree(p);
      ioFree(o);
    }
  }

  @override
  int blsAggregateSignaturesG1(BuBytes sigsConcat, BuBytes out48) {
    final b = _bls;
    if (b == null) {
      return 6;
    }
    final p = _cp(sigsConcat);
    final o = ioCalloc<ffi.Uint8>(48);
    try {
      final rc = b.aggregateSigsG1(p, sigsConcat.length, o, 48);
      if (rc == 0) {
        for (var i = 0; i < 48; i++) {
          out48[i] = o[i];
        }
      }
      return rc;
    } finally {
      ioFree(p);
      ioFree(o);
    }
  }

  @override
  int blsAggregateSignaturesG2(BuBytes sigsConcat, BuBytes out96) {
    final b = _bls;
    if (b == null) {
      return 6;
    }
    final p = _cp(sigsConcat);
    final o = ioCalloc<ffi.Uint8>(96);
    try {
      final rc = b.aggregateSigsG2(p, sigsConcat.length, o, 96);
      if (rc == 0) {
        for (var i = 0; i < 96; i++) {
          out96[i] = o[i];
        }
      }
      return rc;
    } finally {
      ioFree(p);
      ioFree(o);
    }
  }

  @override
  int blsFastAggregateVerifyMinPk(
    BuBytes apk48,
    BuBytes msg,
    BuBytes sig96,
    BuBytes? dst,
  ) {
    final b = _bls;
    if (b == null) {
      return 6;
    }
    final p = _cp(apk48);
    final m = _cp(msg);
    final g = _cp(sig96);
    final d = (dst == null || dst.isEmpty) ? ffi.nullptr : _cp(dst);
    final dl = dst?.length ?? 0;
    try {
      return b.fastAggVerifyMinPk(
        p,
        apk48.length,
        m,
        msg.length,
        g,
        sig96.length,
        d,
        dl,
      );
    } finally {
      ioFree(p);
      ioFree(m);
      ioFree(g);
      if (d != ffi.nullptr) ioFree(d);
    }
  }

  @override
  int blsFastAggregateVerifyMinSig(
    BuBytes apk96,
    BuBytes msg,
    BuBytes sig48,
    BuBytes? dst,
  ) {
    final b = _bls;
    if (b == null) {
      return 6;
    }
    final p = _cp(apk96);
    final m = _cp(msg);
    final g = _cp(sig48);
    final d = (dst == null || dst.isEmpty) ? ffi.nullptr : _cp(dst);
    final dl = dst?.length ?? 0;
    try {
      return b.fastAggVerifyMinSig(
        p,
        apk96.length,
        m,
        msg.length,
        g,
        sig48.length,
        d,
        dl,
      );
    } finally {
      ioFree(p);
      ioFree(m);
      ioFree(g);
      if (d != ffi.nullptr) ioFree(d);
    }
  }

  @override
  int blsAggregateVerifyMinPk(
    BuBytes pksConcat,
    BuBytes messagesBlob,
    int messageCount,
    BuBytes sig,
    BuBytes? dst,
  ) {
    final b = _bls;
    if (b == null) {
      return 6;
    }
    final p = _cp(pksConcat);
    final m = _cp(messagesBlob);
    final g = _cp(sig);
    final d = (dst == null || dst.isEmpty) ? ffi.nullptr : _cp(dst);
    final dl = dst?.length ?? 0;
    try {
      return b.aggregateVerifyMinPk(
        p,
        pksConcat.length,
        m,
        messagesBlob.length,
        messageCount,
        g,
        sig.length,
        d,
        dl,
      );
    } finally {
      ioFree(p);
      ioFree(m);
      ioFree(g);
      if (d != ffi.nullptr) ioFree(d);
    }
  }

  @override
  int blsAggregateVerifyMinSig(
    BuBytes pksConcat,
    BuBytes messagesBlob,
    int messageCount,
    BuBytes sig,
    BuBytes? dst,
  ) {
    final b = _bls;
    if (b == null) {
      return 6;
    }
    final p = _cp(pksConcat);
    final m = _cp(messagesBlob);
    final g = _cp(sig);
    final d = (dst == null || dst.isEmpty) ? ffi.nullptr : _cp(dst);
    final dl = dst?.length ?? 0;
    try {
      return b.aggregateVerifyMinSig(
        p,
        pksConcat.length,
        m,
        messagesBlob.length,
        messageCount,
        g,
        sig.length,
        d,
        dl,
      );
    } finally {
      ioFree(p);
      ioFree(m);
      ioFree(g);
      if (d != ffi.nullptr) ioFree(d);
    }
  }

  @override
  int blsBatchVerifyMinPk(
    BuBytes pksConcat,
    BuBytes messagesBlob,
    int messageCount,
    BuBytes sigsConcat,
    BuBytes? dst,
  ) {
    final b = _bls;
    if (b == null) {
      return 6;
    }
    final p = _cp(pksConcat);
    final m = _cp(messagesBlob);
    final g = _cp(sigsConcat);
    final d = (dst == null || dst.isEmpty) ? ffi.nullptr : _cp(dst);
    final dl = dst?.length ?? 0;
    try {
      return b.batchVerifyMinPk(
        p,
        pksConcat.length,
        m,
        messagesBlob.length,
        messageCount,
        g,
        sigsConcat.length,
        d,
        dl,
      );
    } finally {
      ioFree(p);
      ioFree(m);
      ioFree(g);
      if (d != ffi.nullptr) ioFree(d);
    }
  }

  @override
  int blsBatchVerifyMinSig(
    BuBytes pksConcat,
    BuBytes messagesBlob,
    int messageCount,
    BuBytes sigsConcat,
    BuBytes? dst,
  ) {
    final b = _bls;
    if (b == null) {
      return 6;
    }
    final p = _cp(pksConcat);
    final m = _cp(messagesBlob);
    final g = _cp(sigsConcat);
    final d = (dst == null || dst.isEmpty) ? ffi.nullptr : _cp(dst);
    final dl = dst?.length ?? 0;
    try {
      return b.batchVerifyMinSig(
        p,
        pksConcat.length,
        m,
        messagesBlob.length,
        messageCount,
        g,
        sigsConcat.length,
        d,
        dl,
      );
    } finally {
      ioFree(p);
      ioFree(m);
      ioFree(g);
      if (d != ffi.nullptr) ioFree(d);
    }
  }

  @override
  int musig2KeyAgg(BuBytes keysConcat, int nKeys, BuBytes out33) {
    final m = _musig;
    if (m == null) {
      return 6;
    }
    final k = _cp(keysConcat);
    final o = ioCalloc<ffi.Uint8>(33);
    try {
      final rc = m.keyAgg(k, nKeys, o, 33);
      if (rc == 0) {
        for (var i = 0; i < 33; i++) {
          out33[i] = o[i];
        }
      }
      return rc;
    } finally {
      ioFree(k);
      ioFree(o);
    }
  }

  @override
  int musig2KeyAggTweak(
    BuBytes keysConcat,
    int nKeys,
    BuBytes tweaksConcat,
    int nTweaks,
    BuBytes out33,
  ) {
    final m = _musig;
    if (m == null) {
      return 6;
    }
    final k = _cp(keysConcat);
    final t = nTweaks == 0 ? ffi.nullptr : _cp(tweaksConcat);
    final o = ioCalloc<ffi.Uint8>(33);
    try {
      final rc = m.keyAggTweak(k, nKeys, t, nTweaks, o, 33);
      if (rc == 0) {
        for (var i = 0; i < 33; i++) {
          out33[i] = o[i];
        }
      }
      return rc;
    } finally {
      ioFree(k);
      if (t != ffi.nullptr) ioFree(t);
      ioFree(o);
    }
  }

  @override
  int musig2NonceGen({
    required BuBytes? sk,
    required BuBytes publicKey,
    BuBytes? aggPubKey,
    BuBytes? msg,
    BuBytes? extra,
    required BuBytes rand,
    required BuBytes secnonceOut97,
    required BuBytes pubnonceOut66,
  }) {
    final m = _musig;
    if (m == null) {
      return 6;
    }
    final s = (sk == null) ? ffi.nullptr : _cp(sk);
    final p = _cp(publicKey);
    final a = (aggPubKey == null) ? ffi.nullptr : _cp(aggPubKey);
    // BIP-327: msg null = absent (0x00); msg empty list = present empty (0x01||len0).
    final ms = msg == null ? ffi.nullptr : _cp(msg);
    final e = extra == null ? ffi.nullptr : _cp(extra);
    final r = _cp(rand);
    final so = ioCalloc<ffi.Uint8>(97);
    final po = ioCalloc<ffi.Uint8>(66);
    try {
      final rc = m.nonceGen(
        s,
        sk?.length ?? 0,
        p,
        publicKey.length,
        a,
        aggPubKey?.length ?? 0,
        ms,
        msg?.length ?? 0,
        e,
        extra?.length ?? 0,
        r,
        so,
        97,
        po,
        66,
      );
      if (rc == 0) {
        for (var i = 0; i < 97; i++) {
          secnonceOut97[i] = so[i];
        }
        for (var i = 0; i < 66; i++) {
          pubnonceOut66[i] = po[i];
        }
      }
      return rc;
    } finally {
      if (s != ffi.nullptr) _zf(s, sk!.length);
      ioFree(p);
      if (a != ffi.nullptr) ioFree(a);
      if (ms != ffi.nullptr) ioFree(ms);
      if (e != ffi.nullptr) ioFree(e);
      ioFree(r);
      ioFree(so);
      ioFree(po);
    }
  }

  @override
  @override
  int musig2VerifyAggregate({
    required BuBytes message,
    required BuBytes signature64,
    required BuBytes aggXOnly32,
  }) {
    final m = _musig;
    if (m == null) {
      return 6;
    }
    final msg = _cp(message);
    final sig = _cp(signature64);
    final x = _cp(aggXOnly32);
    try {
      return m.verifyAggregate(
        msg,
        message.length,
        sig,
        signature64.length,
        x,
        aggXOnly32.length,
      );
    } finally {
      ioFree(msg);
      ioFree(sig);
      ioFree(x);
    }
  }

  @override
  int musig2DeterministicSign({
    required BuBytes sk,
    required BuBytes aggother66,
    required BuBytes keysConcat,
    required int nKeys,
    required BuBytes msg,
    BuBytes? tweaksConcat,
    int nTweaks = 0,
    BuBytes? rand,
    required BuBytes pubnonceOut66,
    required BuBytes partialOut32,
  }) {
    final m = _musig;
    if (m == null) {
      return 6;
    }
    final s = _cp(sk);
    final o = _cp(aggother66);
    final k = _cp(keysConcat);
    final ms = _cp(msg);
    final tw = (tweaksConcat == null) ? ffi.nullptr : _cp(tweaksConcat);
    final r = (rand == null) ? ffi.nullptr : _cp(rand);
    final po = ioCalloc<ffi.Uint8>(66);
    final ps = ioCalloc<ffi.Uint8>(32);
    try {
      final rc = m.deterministicSign(
        s,
        o,
        k,
        nKeys,
        ms,
        msg.length,
        tw,
        nTweaks,
        r,
        po,
        ps,
      );
      if (rc == 0) {
        for (var i = 0; i < 66; i++) {
          pubnonceOut66[i] = po[i];
        }
        for (var i = 0; i < 32; i++) {
          partialOut32[i] = ps[i];
        }
      }
      return rc;
    } finally {
      _zf(s, sk.length);
      ioFree(o);
      ioFree(k);
      ioFree(ms);
      if (tw != ffi.nullptr) ioFree(tw);
      if (r != ffi.nullptr) ioFree(r);
      ioFree(po);
      ioFree(ps);
    }
  }

  @override
  int musig2NonceAgg(BuBytes pubnoncesConcat, int n, BuBytes out66) {
    final m = _musig;
    if (m == null) {
      return 6;
    }
    final p = _cp(pubnoncesConcat);
    final o = ioCalloc<ffi.Uint8>(66);
    try {
      final rc = m.nonceAgg(p, n, o, 66);
      if (rc == 0) {
        for (var i = 0; i < 66; i++) {
          out66[i] = o[i];
        }
      }
      return rc;
    } finally {
      ioFree(p);
      ioFree(o);
    }
  }

  // ---- DKLs23 threshold ECDSA ----
  @override
  int dkls23ImportSecrets({
    required int curveId,
    required BuBytes secretsConcat,
    required int n,
    required List<BuBytes> outBlob,
  }) {
    final m = _dkls23;
    if (m == null) {
      return 6;
    }
    final s = _cp(secretsConcat);
    final lp = ioCalloc<ffi.Size>()..value = 0;
    try {
      var rc = m.importSecrets(curveId, s, n, ffi.nullptr, lp, 0);
      if (rc != 2) return rc; // expect length probe
      final need = lp.value;
      final buf = ioCalloc<ffi.Uint8>(need == 0 ? 1 : need);
      try {
        lp.value = need;
        rc = m.importSecrets(curveId, s, n, buf, lp, need);
        if (rc == 0) {
          final got = lp.value;
          outBlob.add(BuBytes(List<int>.generate(got, (i) => buf[i])));
        }
        return rc;
      } finally {
        ioFree(buf);
      }
    } finally {
      ioFree(s);
      ioFree(lp);
    }
  }

  @override
  int dkls23Dkg({
    required int curveId,
    required BuBytes sid,
    required int n,
    required int t,
    required BuBytes seedsConcat,
    required List<BuBytes> outBlob,
  }) {
    final m = _dkls23;
    if (m == null) {
      return 6;
    }
    final s = _cp(sid);
    final sd = _cp(seedsConcat);
    final lp = ioCalloc<ffi.Size>()..value = 0;
    try {
      var rc = m.dkg(curveId, s, sid.length, n, t, sd, ffi.nullptr, lp, 0);
      if (rc != 2) return rc; // expect length probe
      final need = lp.value;
      final buf = ioCalloc<ffi.Uint8>(need == 0 ? 1 : need);
      try {
        lp.value = need;
        rc = m.dkg(curveId, s, sid.length, n, t, sd, buf, lp, need);
        if (rc == 0) {
          final got = lp.value;
          outBlob.add(BuBytes(List<int>.generate(got, (i) => buf[i])));
        }
        return rc;
      } finally {
        ioFree(buf);
      }
    } finally {
      ioFree(s);
      ioFree(sd);
      ioFree(lp);
    }
  }

  @override
  int dkls23Sign({
    required int curveId,
    required BuBytes sid,
    required BuBytes msgHash32,
    required BuBytes sharesBlob,
    required BuBytes seedsConcat,
    required BuBytes out64,
  }) {
    final m = _dkls23;
    if (m == null) {
      return 6;
    }
    final s = _cp(sid);
    final h = _cp(msgHash32);
    final sh = _cp(sharesBlob);
    final sd = _cp(seedsConcat);
    final o = ioCalloc<ffi.Uint8>(64);
    try {
      final rc = m.sign(
        curveId,
        s,
        sid.length,
        h,
        sh,
        sharesBlob.length,
        sd,
        o,
        64,
      );
      if (rc == 0) {
        for (var i = 0; i < 64; i++) {
          out64[i] = o[i];
        }
      }
      return rc;
    } finally {
      ioFree(s);
      ioFree(h);
      ioFree(sh);
      ioFree(sd);
      ioFree(o);
    }
  }

  @override
  int dkls23Refresh({
    required BuBytes sid,
    required BuBytes sharesBlob,
    required BuBytes seedsConcat,
    required List<BuBytes> outBlob,
  }) {
    final m = _dkls23;
    if (m == null) {
      return 6;
    }
    final s = _cp(sid);
    final sh = _cp(sharesBlob);
    final sd = _cp(seedsConcat);
    final lp = ioCalloc<ffi.Size>()..value = 0;
    try {
      var rc = m.refresh(
        s,
        sid.length,
        sh,
        sharesBlob.length,
        sd,
        ffi.nullptr,
        lp,
        0,
      );
      if (rc != 2) return rc; // expect length probe
      final need = lp.value;
      final buf = ioCalloc<ffi.Uint8>(need == 0 ? 1 : need);
      try {
        lp.value = need;
        rc = m.refresh(s, sid.length, sh, sharesBlob.length, sd, buf, lp, need);
        if (rc == 0) {
          final got = lp.value;
          outBlob.add(BuBytes(List<int>.generate(got, (i) => buf[i])));
        }
        return rc;
      } finally {
        ioFree(buf);
      }
    } finally {
      ioFree(s);
      ioFree(sh);
      ioFree(sd);
      ioFree(lp);
    }
  }

  @override
  int dkls23Verify({
    required int curveId,
    required BuBytes groupPk33,
    required BuBytes msgHash32,
    required BuBytes sig64,
  }) {
    final m = _dkls23;
    if (m == null) {
      return 6;
    }
    final g = _cp(groupPk33);
    final h = _cp(msgHash32);
    final sg = _cp(sig64);
    try {
      return m.verify(curveId, g, h, sg);
    } finally {
      ioFree(g);
      ioFree(h);
      ioFree(sg);
    }
  }

  @override
  int dkls23AggKeys({
    required int curveId,
    required BuBytes membersConcat,
    required int n,
    required BuBytes out33,
  }) {
    final m = _dkls23;
    if (m == null) {
      return 6;
    }
    final k = _cp(membersConcat);
    final o = ioCalloc<ffi.Uint8>(33);
    try {
      final rc = m.aggKeys(curveId, k, n, o, 33);
      if (rc == 0) {
        for (var i = 0; i < 33; i++) {
          out33[i] = o[i];
        }
      }
      return rc;
    } finally {
      ioFree(k);
      ioFree(o);
    }
  }

  @override
  int dkls23XOnly({
    required int curveId,
    required BuBytes groupPk33,
    required BuBytes out32,
  }) {
    final m = _dkls23;
    if (m == null) {
      return 6;
    }
    final g = _cp(groupPk33);
    final o = ioCalloc<ffi.Uint8>(32);
    try {
      final rc = m.xOnly(curveId, g, o, 32);
      if (rc == 0) {
        for (var i = 0; i < 32; i++) {
          out32[i] = o[i];
        }
      }
      return rc;
    } finally {
      ioFree(g);
      ioFree(o);
    }
  }

  @override
  int musig2PartialSign({
    required BuBytes secnonce,
    required BuBytes sk,
    required BuBytes keysConcat,
    required int nKeys,
    required BuBytes aggnonce,
    required BuBytes msg,
    BuBytes? tweaksConcat,
    int nTweaks = 0,
    required BuBytes out32,
  }) {
    final m = _musig;
    if (m == null) {
      return 6;
    }
    final sn = _cp(secnonce);
    final s = _cp(sk);
    final k = _cp(keysConcat);
    final a = _cp(aggnonce);
    final ms = _cp(msg);
    final t =
        (nTweaks == 0 || tweaksConcat == null)
            ? ffi.nullptr
            : _cp(tweaksConcat);
    final o = ioCalloc<ffi.Uint8>(32);
    try {
      final rc = m.partialSign(
        sn,
        secnonce.length,
        s,
        sk.length,
        k,
        nKeys,
        a,
        ms,
        msg.length,
        t,
        nTweaks,
        o,
        32,
      );
      if (rc == 0) {
        for (var i = 0; i < 32; i++) {
          out32[i] = o[i];
        }
      }
      return rc;
    } finally {
      ioFree(sn);
      _zf(s, sk.length);
      ioFree(k);
      ioFree(a);
      ioFree(ms);
      if (t != ffi.nullptr) ioFree(t);
      ioFree(o);
    }
  }

  @override
  int musig2PartialSigAgg({
    required BuBytes partialsConcat,
    required int nPartials,
    required BuBytes keysConcat,
    required int nKeys,
    required BuBytes aggnonce,
    required BuBytes msg,
    BuBytes? tweaksConcat,
    int nTweaks = 0,
    required BuBytes out64,
  }) {
    final m = _musig;
    if (m == null) {
      return 6;
    }
    final p = _cp(partialsConcat);
    final k = _cp(keysConcat);
    final a = _cp(aggnonce);
    final ms = _cp(msg);
    final t =
        (nTweaks == 0 || tweaksConcat == null)
            ? ffi.nullptr
            : _cp(tweaksConcat);
    final o = ioCalloc<ffi.Uint8>(64);
    try {
      final rc = m.partialSigAgg(
        p,
        nPartials,
        k,
        nKeys,
        a,
        ms,
        msg.length,
        t,
        nTweaks,
        o,
        64,
      );
      if (rc == 0) {
        for (var i = 0; i < 64; i++) {
          out64[i] = o[i];
        }
      }
      return rc;
    } finally {
      ioFree(p);
      ioFree(k);
      ioFree(a);
      ioFree(ms);
      if (t != ffi.nullptr) ioFree(t);
      ioFree(o);
    }
  }

  @override
  int musig2PartialSigVerify({
    required BuBytes partial,
    required BuBytes pubnonce,
    required BuBytes pk,
    required BuBytes keysConcat,
    required int nKeys,
    required BuBytes aggnonce,
    required BuBytes msg,
    BuBytes? tweaksConcat,
    int nTweaks = 0,
  }) {
    final m = _musig;
    if (m == null) {
      return 6;
    }
    final ps = _cp(partial);
    final pn = _cp(pubnonce);
    final p = _cp(pk);
    final k = _cp(keysConcat);
    final a = _cp(aggnonce);
    final ms = _cp(msg);
    final t =
        (nTweaks == 0 || tweaksConcat == null)
            ? ffi.nullptr
            : _cp(tweaksConcat);
    try {
      return m.partialSigVerify(
        ps,
        pn,
        p,
        k,
        nKeys,
        a,
        ms,
        msg.length,
        t,
        nTweaks,
      );
    } finally {
      ioFree(ps);
      ioFree(pn);
      ioFree(p);
      ioFree(k);
      ioFree(a);
      ioFree(ms);
      if (t != ffi.nullptr) ioFree(t);
    }
  }

  @override
  int mldsaKeygen(int level, BuBytes seed, BuBytes pkOut, BuBytes skOut) {
    final pq = _pq;
    if (pq == null) {
      return _u();
    }
    final sp = _cp(seed);
    final pp = _cp(pkOut);
    final kp = _cp(skOut);
    try {
      final rc = pq.mldsaKeygen(
        level,
        sp,
        seed.length,
        pp,
        pkOut.length,
        kp,
        skOut.length,
      );
      if (rc == 0) {
        for (var i = 0; i < pkOut.length; i++) {
          pkOut[i] = pp[i];
        }
        for (var i = 0; i < skOut.length; i++) {
          skOut[i] = kp[i];
        }
      }
      return rc;
    } finally {
      _zf(sp, seed.length);
      _zf(pp, pkOut.length);
      _zf(kp, skOut.length);
    }
  }

  @override
  int mldsaSign(
    int level,
    BuBytes sk,
    BuBytes msg,
    BuBytes rnd,
    BuBytes context,
    BuBytes sigOut,
  ) {
    final pq = _pq;
    if (pq == null) {
      return _u();
    }
    final skp = _cp(sk);
    final mp = _cp(msg);
    final rp = rnd.isEmpty ? ffi.nullptr : _cp(rnd);
    final cp = context.isEmpty ? ffi.nullptr : _cp(context);
    final sp = _cp(sigOut);
    try {
      final rc = pq.mldsaSign(
        level,
        skp,
        sk.length,
        mp,
        msg.length,
        rp,
        rnd.length,
        cp,
        context.length,
        sp,
        sigOut.length,
      );
      if (rc == 0) {
        for (var i = 0; i < sigOut.length; i++) {
          sigOut[i] = sp[i];
        }
      }
      return rc;
    } finally {
      _zf(skp, sk.length);
      _zf(mp, msg.length);
      if (rp != ffi.nullptr) _zf(rp, rnd.length);
      if (cp != ffi.nullptr) _zf(cp, context.length);
      _zf(sp, sigOut.length);
    }
  }

  @override
  int mldsaVerify(
    int level,
    BuBytes pk,
    BuBytes msg,
    BuBytes sig,
    BuBytes context,
  ) {
    final pq = _pq;
    if (pq == null) {
      return _u();
    }
    final pp = _cp(pk);
    final mp = _cp(msg);
    final sp = _cp(sig);
    final cp = context.isEmpty ? ffi.nullptr : _cp(context);
    try {
      return pq.mldsaVerify(
        level,
        pp,
        pk.length,
        mp,
        msg.length,
        sp,
        sig.length,
        cp,
        context.length,
      );
    } finally {
      _zf(pp, pk.length);
      _zf(mp, msg.length);
      _zf(sp, sig.length);
      if (cp != ffi.nullptr) _zf(cp, context.length);
    }
  }

  @override
  int mldsaPublicFromSecret(int level, BuBytes sk, BuBytes pkOut) {
    final pq = _pq;
    if (pq == null) {
      return _u();
    }
    final skp = _cp(sk);
    final pp = _cp(pkOut);
    try {
      final rc = pq.mldsaPkFromSk(level, skp, sk.length, pp, pkOut.length);
      if (rc == 0) {
        for (var i = 0; i < pkOut.length; i++) {
          pkOut[i] = pp[i];
        }
      }
      return rc;
    } finally {
      _zf(skp, sk.length);
      _zf(pp, pkOut.length);
    }
  }

  @override
  int rngSeed(BuBytes seed32) {
    final r = _rng;
    if (r == null) {
      return _u();
    }
    if (seed32.length != 32) {
      return 1;
    }
    final p = _cp(seed32);
    try {
      return r.seed(p, 32);
    } finally {
      _zf(p, 32);
    }
  }

  @override
  int rngIsSeeded() {
    final r = _rng;
    if (r == null) {
      return 0;
    }
    return r.isSeeded();
  }

  @override
  int rngFill(BuBytes out) {
    final r = _rng;
    if (r == null) {
      return _u();
    }
    if (out.isEmpty) {
      return 1;
    }
    final p = _cp(out);
    try {
      final rc = r.fill(p, out.length);
      if (rc == 0) {
        for (var i = 0; i < out.length; i++) {
          out[i] = p[i];
        }
      }
      return rc;
    } finally {
      _zf(p, out.length);
    }
  }

  // —— Hardware-wallet codecs (optional `hw` symbol group) ——

  /// Copy native bytes `[0, rc)` back into [out].
  int _hwTake(int rc, ffi.Pointer<ffi.Uint8> p, BuBytes out) {
    if (rc >= 0) {
      for (var i = 0; i < rc; i++) {
        out[i] = p[i];
      }
    }
    return rc;
  }

  @override
  int hwSupportsCoin(int device, int coin) {
    final h = _hw;
    if (h == null) {
      return _u();
    }
    return h.supportsCoin(device, coin);
  }

  @override
  int hwIsAirgap(int device) {
    final h = _hw;
    if (h == null) {
      return _u();
    }
    return h.isAirgap(device);
  }

  @override
  int hwParsePath(String path, BuBytes out) {
    final h = _hw;
    if (h == null) {
      return _u();
    }
    if (out.isEmpty) {
      return 1;
    }
    final dom = BuBytes(List<int>.from(path.codeUnits));
    final ip = _cp(dom);
    final op = _cp(out);
    try {
      final rc = h.parsePath(ip, dom.length, op, out.length);
      // Native returns the u32 COUNT but writes count*4 bytes (the web
      // backend returns bytes). Copy all written bytes and normalize the
      // return to bytes written. (Native guarantees count*4 <= out.length
      // on success, else it errors.)
      if (rc >= 0 && rc != 6) {
        for (var i = 0; i < rc * 4; i++) {
          out[i] = op[i];
        }
        return rc * 4;
      }
      return rc;
    } finally {
      _zf(ip, dom.length);
      _zf(op, out.length);
    }
  }

  @override
  int hwValidatePath(int device, int coin, BuBytes pathU32) {
    final h = _hw;
    if (h == null) {
      return _u();
    }
    final p = _cp(pathU32);
    try {
      return h.validatePath(device, coin, p, pathU32.length);
    } finally {
      _zf(p, pathU32.length);
    }
  }

  int _hwReq(
    int Function(
      int,
      int,
      ffi.Pointer<ffi.Uint8>,
      int,
      ffi.Pointer<ffi.Uint8>,
      int,
    )
    f,
    int device,
    int coin,
    BuBytes pathU32,
    BuBytes out,
  ) {
    if (out.isEmpty) {
      return 1;
    }
    final p = _cp(pathU32);
    final o = _cp(out);
    try {
      return _hwTake(f(device, coin, p, pathU32.length, o, out.length), o, out);
    } finally {
      _zf(p, pathU32.length);
      _zf(o, out.length);
    }
  }

  @override
  int hwGetAddressRequest(int device, int coin, BuBytes pathU32, BuBytes out) {
    final h = _hw;
    if (h == null) {
      return _u();
    }
    return _hwReq(h.getAddressRequest, device, coin, pathU32, out);
  }

  @override
  int hwParseAddressResponse(int device, BuBytes response, BuBytes out) {
    final h = _hw;
    if (h == null) {
      return _u();
    }
    if (out.isEmpty) {
      return 1;
    }
    final rp = response.isEmpty ? ffi.nullptr : _cp(response);
    final op = _cp(out);
    try {
      return _hwTake(
        h.parseAddressResponse(device, rp, response.length, op, out.length),
        op,
        out,
      );
    } finally {
      if (rp != ffi.nullptr) _zf(rp, response.length);
      _zf(op, out.length);
    }
  }

  @override
  int hwSignRequest(
    int device,
    int coin,
    BuBytes pathU32,
    BuBytes payload,
    BuBytes out,
  ) {
    final h = _hw;
    if (h == null) {
      return _u();
    }
    if (out.isEmpty) {
      return 1;
    }
    final p = _cp(pathU32);
    final m = payload.isEmpty ? ffi.nullptr : _cp(payload);
    final o = _cp(out);
    try {
      return _hwTake(
        h.signRequest(
          device,
          coin,
          p,
          pathU32.length,
          m,
          payload.length,
          o,
          out.length,
        ),
        o,
        out,
      );
    } finally {
      _zf(p, pathU32.length);
      if (m != ffi.nullptr) _zf(m, payload.length);
      _zf(o, out.length);
    }
  }

  @override
  int hwParseSignResponse(int device, BuBytes response, BuBytes out) {
    final h = _hw;
    if (h == null) {
      return _u();
    }
    if (out.isEmpty) {
      return 1;
    }
    final rp = response.isEmpty ? ffi.nullptr : _cp(response);
    final op = _cp(out);
    try {
      return _hwTake(
        h.parseSignResponse(device, rp, response.length, op, out.length),
        op,
        out,
      );
    } finally {
      if (rp != ffi.nullptr) _zf(rp, response.length);
      _zf(op, out.length);
    }
  }

  @override
  int hwSignTxStart(
    int device,
    int coin,
    int inputsCount,
    int outputsCount,
    BuBytes out,
  ) {
    final h = _hw;
    if (h == null) {
      return _u();
    }
    if (out.isEmpty) {
      return 1;
    }
    final op = _cp(out);
    try {
      return _hwTake(
        h.signTxStart(device, coin, inputsCount, outputsCount, op, out.length),
        op,
        out,
      );
    } finally {
      _zf(op, out.length);
    }
  }

  @override
  int hwParseTxRequest(int device, BuBytes response, BuBytes out) {
    final h = _hw;
    if (h == null) {
      return _u();
    }
    if (out.isEmpty) {
      return 1;
    }
    final rp = response.isEmpty ? ffi.nullptr : _cp(response);
    final op = _cp(out);
    try {
      return _hwTake(
        h.parseTxRequest(device, rp, response.length, op, out.length),
        op,
        out,
      );
    } finally {
      if (rp != ffi.nullptr) _zf(rp, response.length);
      _zf(op, out.length);
    }
  }

  @override
  int hwTxRequestSignature(int device, BuBytes response, BuBytes out) {
    final h = _hw;
    if (h == null) {
      return _u();
    }
    if (out.isEmpty) {
      return 1;
    }
    final rp = response.isEmpty ? ffi.nullptr : _cp(response);
    final op = _cp(out);
    try {
      return _hwTake(
        h.txRequestSignature(device, rp, response.length, op, out.length),
        op,
        out,
      );
    } finally {
      if (rp != ffi.nullptr) _zf(rp, response.length);
      _zf(op, out.length);
    }
  }

  @override
  int hwTxRequestSerialized(int device, BuBytes response, BuBytes out) {
    final h = _hw;
    if (h == null) {
      return _u();
    }
    if (out.isEmpty) {
      return 1;
    }
    final rp = response.isEmpty ? ffi.nullptr : _cp(response);
    final op = _cp(out);
    try {
      return _hwTake(
        h.txRequestSerialized(device, rp, response.length, op, out.length),
        op,
        out,
      );
    } finally {
      if (rp != ffi.nullptr) _zf(rp, response.length);
      _zf(op, out.length);
    }
  }

  @override
  int hwTxRequestTxHash(int device, BuBytes response, BuBytes out) {
    final h = _hw;
    if (h == null) {
      return _u();
    }
    if (out.isEmpty) {
      return 1;
    }
    final rp = response.isEmpty ? ffi.nullptr : _cp(response);
    final op = _cp(out);
    try {
      return _hwTake(
        h.txRequestTxHash(device, rp, response.length, op, out.length),
        op,
        out,
      );
    } finally {
      if (rp != ffi.nullptr) _zf(rp, response.length);
      _zf(op, out.length);
    }
  }

  @override
  int hwTxAckMeta(
    int version,
    int lockTime,
    int inputsCount,
    int outputsCount,
    BuBytes out,
  ) {
    final h = _hw;
    if (h == null) {
      return _u();
    }
    if (out.isEmpty) {
      return 1;
    }
    final op = _cp(out);
    try {
      return _hwTake(
        h.txAckMeta(
          version,
          lockTime,
          inputsCount,
          outputsCount,
          op,
          out.length,
        ),
        op,
        out,
      );
    } finally {
      _zf(op, out.length);
    }
  }

  @override
  int hwTxAckInput(
    BuBytes prevHash32,
    int prevIndex,
    BuBytes pathU32,
    int amountSat,
    BuBytes scriptSig,
    int scriptType,
    BuBytes out,
  ) {
    final h = _hw;
    if (h == null) {
      return _u();
    }
    if (out.isEmpty) {
      return 1;
    }
    if (amountSat < 0) {
      return 3;
    }
    final hp = _cp(prevHash32);
    final p = _cp(pathU32);
    final sp = scriptSig.isEmpty ? ffi.nullptr : _cp(scriptSig);
    final op = _cp(out);
    try {
      return _hwTake(
        h.txAckInput(
          hp,
          prevHash32.length,
          prevIndex,
          p,
          pathU32.length,
          amountSat,
          sp,
          scriptSig.length,
          scriptType,
          op,
          out.length,
        ),
        op,
        out,
      );
    } finally {
      _zf(hp, prevHash32.length);
      _zf(p, pathU32.length);
      if (sp != ffi.nullptr) _zf(sp, scriptSig.length);
      _zf(op, out.length);
    }
  }

  @override
  int hwTxAckOutput(
    String address,
    int amountSat,
    int scriptType,
    BuBytes out,
  ) {
    final h = _hw;
    if (h == null) {
      return _u();
    }
    if (out.isEmpty) {
      return 1;
    }
    if (amountSat < 0) {
      return 3;
    }
    final dom = BuBytes(List<int>.from(address.codeUnits));
    final ap = _cp(dom);
    final op = _cp(out);
    try {
      return _hwTake(
        h.txAckOutput(ap, dom.length, amountSat, scriptType, op, out.length),
        op,
        out,
      );
    } finally {
      _zf(ap, dom.length);
      _zf(op, out.length);
    }
  }

  @override
  int hwTxAckChange(
    BuBytes pathU32,
    int amountSat,
    int scriptType,
    BuBytes out,
  ) {
    final h = _hw;
    if (h == null) {
      return _u();
    }
    if (out.isEmpty) {
      return 1;
    }
    if (amountSat < 0) {
      return 3;
    }
    final p = _cp(pathU32);
    final op = _cp(out);
    try {
      return _hwTake(
        h.txAckChange(p, pathU32.length, amountSat, scriptType, op, out.length),
        op,
        out,
      );
    } finally {
      _zf(p, pathU32.length);
      _zf(op, out.length);
    }
  }

  @override
  int hwTxAckBinOutput(BuBytes scriptPubKey, int amountSat, BuBytes out) {
    final h = _hw;
    if (h == null) {
      return _u();
    }
    if (out.isEmpty) {
      return 1;
    }
    if (amountSat < 0) {
      return 3;
    }
    final sp = scriptPubKey.isEmpty ? ffi.nullptr : _cp(scriptPubKey);
    final op = _cp(out);
    try {
      return _hwTake(
        h.txAckBinOutput(sp, scriptPubKey.length, amountSat, op, out.length),
        op,
        out,
      );
    } finally {
      if (sp != ffi.nullptr) _zf(sp, scriptPubKey.length);
      _zf(op, out.length);
    }
  }

  @override
  int hwBitBoxHsNew(BuBytes staticPriv32, BuBytes ephemeralPriv32) {
    final h = _hw;
    if (h == null) {
      return _u();
    }
    if (staticPriv32.length != 32 || ephemeralPriv32.length != 32) {
      return 3;
    }
    final sp = _cp(staticPriv32);
    final ep = _cp(ephemeralPriv32);
    try {
      return h.bitboxHsNew(sp, 32, ep, 32);
    } finally {
      _zf(sp, 32);
      _zf(ep, 32);
    }
  }

  @override
  int hwBitBoxHsM1(BuBytes out32) {
    final h = _hw;
    if (h == null) {
      return _u();
    }
    if (out32.isEmpty) {
      return 1;
    }
    final op = _cp(out32);
    try {
      return _hwTake(h.bitboxHsM1(op, out32.length), op, out32);
    } finally {
      _zf(op, out32.length);
    }
  }

  @override
  int hwBitBoxHsM2(BuBytes m2) {
    final h = _hw;
    if (h == null) {
      return _u();
    }
    final mp = m2.isEmpty ? ffi.nullptr : _cp(m2);
    try {
      return h.bitboxHsM2(mp, m2.length);
    } finally {
      if (mp != ffi.nullptr) _zf(mp, m2.length);
    }
  }

  @override
  int hwBitBoxHsM3(BuBytes out64) {
    final h = _hw;
    if (h == null) {
      return _u();
    }
    if (out64.isEmpty) {
      return 1;
    }
    final op = _cp(out64);
    try {
      return _hwTake(h.bitboxHsM3(op, out64.length), op, out64);
    } finally {
      _zf(op, out64.length);
    }
  }

  @override
  int hwBitBoxHsSplit() {
    final h = _hw;
    if (h == null) {
      return _u();
    }
    return h.bitboxHsSplit();
  }

  @override
  int hwBitBoxEncrypt(BuBytes plaintext, BuBytes out) {
    final h = _hw;
    if (h == null) {
      return _u();
    }
    if (out.isEmpty) {
      return 1;
    }
    final pp = plaintext.isEmpty ? ffi.nullptr : _cp(plaintext);
    final op = _cp(out);
    try {
      return _hwTake(
        h.bitboxEncrypt(pp, plaintext.length, op, out.length),
        op,
        out,
      );
    } finally {
      if (pp != ffi.nullptr) _zf(pp, plaintext.length);
      _zf(op, out.length);
    }
  }

  @override
  int hwBitBoxDecrypt(BuBytes ciphertext, BuBytes out) {
    final h = _hw;
    if (h == null) {
      return _u();
    }
    if (out.isEmpty) {
      return 1;
    }
    final cp = ciphertext.isEmpty ? ffi.nullptr : _cp(ciphertext);
    final op = _cp(out);
    try {
      return _hwTake(
        h.bitboxDecrypt(cp, ciphertext.length, op, out.length),
        op,
        out,
      );
    } finally {
      if (cp != ffi.nullptr) _zf(cp, ciphertext.length);
      _zf(op, out.length);
    }
  }

  @override
  int hwBitBoxHsHash(BuBytes out32) {
    final h = _hw;
    if (h == null) {
      return _u();
    }
    if (out32.isEmpty) {
      return 1;
    }
    final op = _cp(out32);
    try {
      return _hwTake(h.bitboxHsHash(op, out32.length), op, out32);
    } finally {
      _zf(op, out32.length);
    }
  }

  @override
  int hwBitBoxFree() {
    final h = _hw;
    if (h == null) {
      return _u();
    }
    return h.bitboxFree();
  }

  @override
  int hwBitBoxBtcPubRequest(
    int coin,
    BuBytes pathU32,
    int xpubType,
    bool display,
    BuBytes out,
  ) {
    final h = _hw;
    if (h == null) {
      return _u();
    }
    if (out.isEmpty) {
      return 1;
    }
    final p = _cp(pathU32);
    final op = _cp(out);
    try {
      return _hwTake(
        h.bitboxBtcPubRequest(
          coin,
          p,
          pathU32.length,
          xpubType,
          display ? 1 : 0,
          op,
          out.length,
        ),
        op,
        out,
      );
    } finally {
      _zf(p, pathU32.length);
      _zf(op, out.length);
    }
  }

  @override
  int hwBitBoxPubParse(BuBytes response, BuBytes out) {
    final h = _hw;
    if (h == null) {
      return _u();
    }
    if (out.isEmpty) {
      return 1;
    }
    final rp = response.isEmpty ? ffi.nullptr : _cp(response);
    final op = _cp(out);
    try {
      return _hwTake(
        h.bitboxPubParse(rp, response.length, op, out.length),
        op,
        out,
      );
    } finally {
      if (rp != ffi.nullptr) _zf(rp, response.length);
      _zf(op, out.length);
    }
  }

  @override
  int hwBitBoxSignInit(
    int coin,
    BuBytes pathU32,
    int simpleType,
    int version,
    int inputsCount,
    int outputsCount,
    int locktime,
    BuBytes out,
  ) {
    final h = _hw;
    if (h == null) {
      return _u();
    }
    if (out.isEmpty) {
      return 1;
    }
    final p = _cp(pathU32);
    final op = _cp(out);
    try {
      return _hwTake(
        h.bitboxSignInit(
          coin,
          p,
          pathU32.length,
          simpleType,
          version,
          inputsCount,
          outputsCount,
          locktime,
          op,
          out.length,
        ),
        op,
        out,
      );
    } finally {
      _zf(p, pathU32.length);
      _zf(op, out.length);
    }
  }

  @override
  int hwBitBoxSignNextParse(BuBytes response, BuBytes out) {
    final h = _hw;
    if (h == null) {
      return _u();
    }
    if (out.isEmpty) {
      return 1;
    }
    final rp = response.isEmpty ? ffi.nullptr : _cp(response);
    final op = _cp(out);
    try {
      return _hwTake(
        h.bitboxSignNextParse(rp, response.length, op, out.length),
        op,
        out,
      );
    } finally {
      if (rp != ffi.nullptr) _zf(rp, response.length);
      _zf(op, out.length);
    }
  }

  @override
  int hwBitBoxSignNextSignature(BuBytes response, BuBytes out) {
    final h = _hw;
    if (h == null) {
      return _u();
    }
    if (out.isEmpty) {
      return 1;
    }
    final rp = response.isEmpty ? ffi.nullptr : _cp(response);
    final op = _cp(out);
    try {
      return _hwTake(
        h.bitboxSignNextSignature(rp, response.length, op, out.length),
        op,
        out,
      );
    } finally {
      if (rp != ffi.nullptr) _zf(rp, response.length);
      _zf(op, out.length);
    }
  }

  @override
  int hwBitBoxSignNextPrevIndex(BuBytes response) {
    final h = _hw;
    if (h == null) {
      return _u();
    }
    final rp = response.isEmpty ? ffi.nullptr : _cp(response);
    try {
      return h.bitboxSignNextPrevIndex(rp, response.length);
    } finally {
      if (rp != ffi.nullptr) _zf(rp, response.length);
    }
  }

  @override
  int hwBitBoxSignInput(
    BuBytes prevHash32,
    int prevIndex,
    int amountSat,
    int sequence,
    BuBytes pathU32,
    int scriptConfigIndex,
    BuBytes out,
  ) {
    final h = _hw;
    if (h == null) {
      return _u();
    }
    if (out.isEmpty) {
      return 1;
    }
    if (amountSat < 0) {
      return 3;
    }
    final hp = _cp(prevHash32);
    final p = _cp(pathU32);
    final op = _cp(out);
    try {
      return _hwTake(
        h.bitboxSignInput(
          hp,
          prevHash32.length,
          prevIndex,
          amountSat,
          sequence,
          p,
          pathU32.length,
          scriptConfigIndex,
          op,
          out.length,
        ),
        op,
        out,
      );
    } finally {
      _zf(hp, prevHash32.length);
      _zf(p, pathU32.length);
      _zf(op, out.length);
    }
  }

  @override
  int hwBitBoxSignOutput(
    int outputType,
    int amountSat,
    BuBytes payload,
    BuBytes out,
  ) {
    final h = _hw;
    if (h == null) {
      return _u();
    }
    if (out.isEmpty) {
      return 1;
    }
    if (amountSat < 0) {
      return 3;
    }
    final pp = payload.isEmpty ? ffi.nullptr : _cp(payload);
    final op = _cp(out);
    try {
      return _hwTake(
        h.bitboxSignOutput(
          outputType,
          amountSat,
          pp,
          payload.length,
          op,
          out.length,
        ),
        op,
        out,
      );
    } finally {
      if (pp != ffi.nullptr) _zf(pp, payload.length);
      _zf(op, out.length);
    }
  }

  @override
  int hwBitBoxSignChange(
    BuBytes pathU32,
    int amountSat,
    int scriptConfigIndex,
    BuBytes out,
  ) {
    final h = _hw;
    if (h == null) {
      return _u();
    }
    if (out.isEmpty) {
      return 1;
    }
    if (amountSat < 0) {
      return 3;
    }
    final p = _cp(pathU32);
    final op = _cp(out);
    try {
      return _hwTake(
        h.bitboxSignChange(
          p,
          pathU32.length,
          amountSat,
          scriptConfigIndex,
          op,
          out.length,
        ),
        op,
        out,
      );
    } finally {
      _zf(p, pathU32.length);
      _zf(op, out.length);
    }
  }

  @override
  int hwBitBoxSignPrevtxInit(
    int version,
    int inputsCount,
    int outputsCount,
    int locktime,
    BuBytes out,
  ) {
    final h = _hw;
    if (h == null) {
      return _u();
    }
    if (out.isEmpty) {
      return 1;
    }
    final op = _cp(out);
    try {
      return _hwTake(
        h.bitboxSignPrevtxInit(
          version,
          inputsCount,
          outputsCount,
          locktime,
          op,
          out.length,
        ),
        op,
        out,
      );
    } finally {
      _zf(op, out.length);
    }
  }

  @override
  int hwBitBoxSignPrevtxInput(
    BuBytes prevHash32,
    int prevIndex,
    BuBytes scriptSig,
    int sequence,
    BuBytes out,
  ) {
    final h = _hw;
    if (h == null) {
      return _u();
    }
    if (out.isEmpty) {
      return 1;
    }
    final hp = _cp(prevHash32);
    final sp = scriptSig.isEmpty ? ffi.nullptr : _cp(scriptSig);
    final op = _cp(out);
    try {
      return _hwTake(
        h.bitboxSignPrevtxInput(
          hp,
          prevHash32.length,
          prevIndex,
          sp,
          scriptSig.length,
          sequence,
          op,
          out.length,
        ),
        op,
        out,
      );
    } finally {
      _zf(hp, prevHash32.length);
      if (sp != ffi.nullptr) _zf(sp, scriptSig.length);
      _zf(op, out.length);
    }
  }

  @override
  int hwBitBoxSignPrevtxOutput(int amountSat, BuBytes script, BuBytes out) {
    final h = _hw;
    if (h == null) {
      return _u();
    }
    if (out.isEmpty) {
      return 1;
    }
    if (amountSat < 0) {
      return 3;
    }
    final sp = script.isEmpty ? ffi.nullptr : _cp(script);
    final op = _cp(out);
    try {
      return _hwTake(
        h.bitboxSignPrevtxOutput(amountSat, sp, script.length, op, out.length),
        op,
        out,
      );
    } finally {
      if (sp != ffi.nullptr) _zf(sp, script.length);
      _zf(op, out.length);
    }
  }

  @override
  int hwIdentityEncode(
    BuBytes proto,
    BuBytes user,
    BuBytes host,
    BuBytes port,
    BuBytes path,
    int index,
    BuBytes out,
  ) {
    final h = _hw;
    if (h == null) {
      return _u();
    }
    if (out.isEmpty) {
      return 1;
    }
    final pp = _cp(proto);
    final up = _cp(user);
    final hp = _cp(host);
    final pop = _cp(port);
    final pap = _cp(path);
    final op = _cp(out);
    try {
      return _hwTake(
        h.identityEncode(
          pp,
          proto.length,
          up,
          user.length,
          hp,
          host.length,
          pop,
          port.length,
          pap,
          path.length,
          index,
          op,
          out.length,
        ),
        op,
        out,
      );
    } finally {
      _zf(pp, proto.length);
      _zf(up, user.length);
      _zf(hp, host.length);
      _zf(pop, port.length);
      _zf(pap, path.length);
      _zf(op, out.length);
    }
  }

  @override
  int hwSignIdentityRequest(
    BuBytes identity,
    BuBytes hidden,
    BuBytes visual,
    int curve,
    BuBytes out,
  ) {
    final h = _hw;
    if (h == null) {
      return _u();
    }
    if (out.isEmpty) {
      return 1;
    }
    final ip = _cp(identity);
    final hp = hidden.isEmpty ? ffi.nullptr : _cp(hidden);
    final vp = visual.isEmpty ? ffi.nullptr : _cp(visual);
    final op = _cp(out);
    try {
      return _hwTake(
        h.signIdentityRequest(
          ip,
          identity.length,
          hp,
          hidden.length,
          vp,
          visual.length,
          curve,
          op,
          out.length,
        ),
        op,
        out,
      );
    } finally {
      _zf(ip, identity.length);
      if (hp != ffi.nullptr) _zf(hp, hidden.length);
      if (vp != ffi.nullptr) _zf(vp, visual.length);
      _zf(op, out.length);
    }
  }

  @override
  int hwSignedIdentityAddress(BuBytes response, BuBytes out) {
    final h = _hw;
    if (h == null) {
      return _u();
    }
    if (out.isEmpty) {
      return 1;
    }
    final rp = response.isEmpty ? ffi.nullptr : _cp(response);
    final op = _cp(out);
    try {
      return _hwTake(
        h.signedIdentityAddress(rp, response.length, op, out.length),
        op,
        out,
      );
    } finally {
      if (rp != ffi.nullptr) _zf(rp, response.length);
      _zf(op, out.length);
    }
  }

  @override
  int hwSignedIdentityPubkey(BuBytes response, BuBytes out) {
    final h = _hw;
    if (h == null) {
      return _u();
    }
    if (out.isEmpty) {
      return 1;
    }
    final rp = response.isEmpty ? ffi.nullptr : _cp(response);
    final op = _cp(out);
    try {
      return _hwTake(
        h.signedIdentityPubkey(rp, response.length, op, out.length),
        op,
        out,
      );
    } finally {
      if (rp != ffi.nullptr) _zf(rp, response.length);
      _zf(op, out.length);
    }
  }

  @override
  int hwSignedIdentitySignature(BuBytes response, BuBytes out) {
    final h = _hw;
    if (h == null) {
      return _u();
    }
    if (out.isEmpty) {
      return 1;
    }
    final rp = response.isEmpty ? ffi.nullptr : _cp(response);
    final op = _cp(out);
    try {
      return _hwTake(
        h.signedIdentitySignature(rp, response.length, op, out.length),
        op,
        out,
      );
    } finally {
      if (rp != ffi.nullptr) _zf(rp, response.length);
      _zf(op, out.length);
    }
  }

  @override
  int hwLedgerFingerprint(BuBytes out) {
    final h = _hw;
    if (h == null) {
      return _u();
    }
    if (out.isEmpty) {
      return 1;
    }
    final op = _cp(out);
    try {
      return _hwTake(h.ledgerFingerprint(op, out.length), op, out);
    } finally {
      _zf(op, out.length);
    }
  }

  @override
  int hwLedgerFingerprintParse(BuBytes response, BuBytes out) {
    final h = _hw;
    if (h == null) {
      return _u();
    }
    if (out.isEmpty) {
      return 1;
    }
    final rp = response.isEmpty ? ffi.nullptr : _cp(response);
    final op = _cp(out);
    try {
      return _hwTake(
        h.ledgerFingerprintParse(rp, response.length, op, out.length),
        op,
        out,
      );
    } finally {
      if (rp != ffi.nullptr) _zf(rp, response.length);
      _zf(op, out.length);
    }
  }

  @override
  int hwQrRequest(int device, int coin, BuBytes pathU32, BuBytes out) {
    final h = _hw;
    if (h == null) {
      return _u();
    }
    return _hwReq(h.qrRequest, device, coin, pathU32, out);
  }

  @override
  int hwQrParse(int device, String qr, BuBytes out) {
    final h = _hw;
    if (h == null) {
      return _u();
    }
    if (out.isEmpty) {
      return 1;
    }
    final dom = BuBytes(List<int>.from(qr.codeUnits));
    final qp = _cp(dom);
    final op = _cp(out);
    try {
      return _hwTake(
        h.qrParse(device, qp, dom.length, op, out.length),
        op,
        out,
      );
    } finally {
      _zf(qp, dom.length);
      _zf(op, out.length);
    }
  }

  @override
  int hwPsbtCounts(BuBytes psbt, BuBytes out8) {
    final h = _hw;
    if (h == null) {
      return _u();
    }
    if (out8.length < 8) {
      return 1;
    }
    final pp = _cp(psbt);
    final op = ioCalloc<ffi.Uint8>(8);
    try {
      final rc = h.psbtCounts(pp, psbt.length, op, 8);
      if (rc == 0) {
        for (var i = 0; i < 8; i++) {
          out8[i] = op[i];
        }
      }
      return rc;
    } finally {
      _zf(pp, psbt.length);
      ioFree(op);
    }
  }

  @override
  int hwUrEncode(String type, BuBytes payload, BuBytes out) {
    final h = _hw;
    if (h == null) {
      return _u();
    }
    if (out.isEmpty) {
      return 1;
    }
    final dom = BuBytes(List<int>.from(type.codeUnits));
    final tp = _cp(dom);
    final pp = payload.isEmpty ? ffi.nullptr : _cp(payload);
    final op = _cp(out);
    try {
      return _hwTake(
        h.urEncode(tp, dom.length, pp, payload.length, op, out.length),
        op,
        out,
      );
    } finally {
      _zf(tp, dom.length);
      if (pp != ffi.nullptr) _zf(pp, payload.length);
      _zf(op, out.length);
    }
  }

  int _hwUrDec(
    int Function(ffi.Pointer<ffi.Uint8>, int, ffi.Pointer<ffi.Uint8>, int) f,
    String ur,
    BuBytes out,
  ) {
    if (out.isEmpty) {
      return 1;
    }
    final dom = BuBytes(List<int>.from(ur.codeUnits));
    final up = _cp(dom);
    final op = _cp(out);
    try {
      return _hwTake(f(up, dom.length, op, out.length), op, out);
    } finally {
      _zf(up, dom.length);
      _zf(op, out.length);
    }
  }

  @override
  int hwUrDecodePayload(String ur, BuBytes out) {
    final h = _hw;
    if (h == null) {
      return _u();
    }
    return _hwUrDec(h.urDecodePayload, ur, out);
  }

  @override
  int hwUrDecodeType(String ur, BuBytes out) {
    final h = _hw;
    if (h == null) {
      return _u();
    }
    return _hwUrDec(h.urDecodeType, ur, out);
  }

  int _hwHid(
    int Function(
      ffi.Pointer<ffi.Uint8>,
      int,
      int,
      int,
      ffi.Pointer<ffi.Uint8>,
      int,
    )
    f,
    BuBytes input,
    int channel,
    int tag,
    BuBytes out,
  ) {
    if (out.isEmpty) {
      return 1;
    }
    final ip = input.isEmpty ? ffi.nullptr : _cp(input);
    final op = _cp(out);
    try {
      return _hwTake(
        f(ip, input.length, channel, tag, op, out.length),
        op,
        out,
      );
    } finally {
      if (ip != ffi.nullptr) _zf(ip, input.length);
      _zf(op, out.length);
    }
  }

  @override
  int hwHidFrame(BuBytes payload, int channel, int tag, BuBytes out) {
    final h = _hw;
    if (h == null) {
      return _u();
    }
    return _hwHid(h.hidFrame, payload, channel, tag, out);
  }

  @override
  int hwHidUnframe(BuBytes reports, int channel, int tag, BuBytes out) {
    final h = _hw;
    if (h == null) {
      return _u();
    }
    return _hwHid(h.hidUnframe, reports, channel, tag, out);
  }

  int _reddsaPk(
    int Function(ffi.Pointer<ffi.Uint8>, ffi.Pointer<ffi.Uint8>)? f,
    BuBytes sk,
    BuBytes pkOut,
  ) {
    if (f == null) {
      return _u();
    }
    final sp = _cp(sk);
    final pp = _cp(pkOut);
    try {
      final rc = f(sp, pp);
      if (rc == 0) {
        for (var i = 0; i < pkOut.length; i++) {
          pkOut[i] = pp[i];
        }
      }
      return rc;
    } finally {
      _zf(sp, sk.length);
      _zf(pp, pkOut.length);
    }
  }

  int _reddsaSign(
    int Function(
      ffi.Pointer<ffi.Uint8>,
      ffi.Pointer<ffi.Uint8>,
      int,
      ffi.Pointer<ffi.Uint8>,
      ffi.Pointer<ffi.Uint8>,
    )?
    f,
    BuBytes sk,
    BuBytes msg,
    BuBytes rand80,
    BuBytes sigOut,
  ) {
    if (f == null) {
      return _u();
    }
    final sp = _cp(sk);
    final mp = _cp(msg);
    final rp = rand80.isEmpty ? ffi.nullptr : _cp(rand80);
    final op = _cp(sigOut);
    try {
      final rc = f(sp, mp, msg.length, rp, op);
      if (rc == 0) {
        for (var i = 0; i < sigOut.length; i++) {
          sigOut[i] = op[i];
        }
      }
      return rc;
    } finally {
      _zf(sp, sk.length);
      _zf(mp, msg.length);
      if (rp != ffi.nullptr) _zf(rp, rand80.length);
      _zf(op, sigOut.length);
    }
  }

  int _reddsaVerify(
    int Function(
      ffi.Pointer<ffi.Uint8>,
      ffi.Pointer<ffi.Uint8>,
      int,
      ffi.Pointer<ffi.Uint8>,
    )?
    f,
    BuBytes pk,
    BuBytes msg,
    BuBytes sig,
  ) {
    if (f == null) {
      return _u();
    }
    final pp = _cp(pk);
    final mp = _cp(msg);
    final sp = _cp(sig);
    try {
      return f(pp, mp, msg.length, sp);
    } finally {
      _zf(pp, pk.length);
      _zf(mp, msg.length);
      _zf(sp, sig.length);
    }
  }

  @override
  int reddsaJubjubAuthPk(BuBytes sk, BuBytes pkOut32) =>
      _reddsaPk(_reddsa?.jubjubAuthPk, sk, pkOut32);
  @override
  int reddsaJubjubBindingPk(BuBytes sk, BuBytes pkOut32) =>
      _reddsaPk(_reddsa?.jubjubBindingPk, sk, pkOut32);
  @override
  int reddsaPallasAuthPk(BuBytes sk, BuBytes pkOut32) =>
      _reddsaPk(_reddsa?.pallasAuthPk, sk, pkOut32);
  @override
  int reddsaPallasBindingPk(BuBytes sk, BuBytes pkOut32) =>
      _reddsaPk(_reddsa?.pallasBindingPk, sk, pkOut32);

  @override
  int reddsaJubjubAuthSign(
    BuBytes sk,
    BuBytes msg,
    BuBytes rand80,
    BuBytes sigOut64,
  ) => _reddsaSign(_reddsa?.jubjubAuthSign, sk, msg, rand80, sigOut64);
  @override
  int reddsaJubjubAuthVerify(BuBytes pk, BuBytes msg, BuBytes sig64) =>
      _reddsaVerify(_reddsa?.jubjubAuthVerify, pk, msg, sig64);
  @override
  int reddsaJubjubBindingSign(
    BuBytes sk,
    BuBytes msg,
    BuBytes rand80,
    BuBytes sigOut64,
  ) => _reddsaSign(_reddsa?.jubjubBindingSign, sk, msg, rand80, sigOut64);
  @override
  int reddsaJubjubBindingVerify(BuBytes pk, BuBytes msg, BuBytes sig64) =>
      _reddsaVerify(_reddsa?.jubjubBindingVerify, pk, msg, sig64);
  @override
  int reddsaPallasAuthSign(
    BuBytes sk,
    BuBytes msg,
    BuBytes rand80,
    BuBytes sigOut64,
  ) => _reddsaSign(_reddsa?.pallasAuthSign, sk, msg, rand80, sigOut64);
  @override
  int reddsaPallasAuthVerify(BuBytes pk, BuBytes msg, BuBytes sig64) =>
      _reddsaVerify(_reddsa?.pallasAuthVerify, pk, msg, sig64);
  @override
  int reddsaPallasBindingSign(
    BuBytes sk,
    BuBytes msg,
    BuBytes rand80,
    BuBytes sigOut64,
  ) => _reddsaSign(_reddsa?.pallasBindingSign, sk, msg, rand80, sigOut64);
  @override
  int reddsaPallasBindingVerify(BuBytes pk, BuBytes msg, BuBytes sig64) =>
      _reddsaVerify(_reddsa?.pallasBindingVerify, pk, msg, sig64);

  @override
  int poseidonHashTwo(BuBytes a, BuBytes b, BuBytes out32) {
    final f = _zcash?.poseidonHashTwo;
    if (f == null) {
      return 6;
    }
    final ap = _cp(a);
    final bp = _cp(b);
    final o = ioCalloc<ffi.Uint8>(32);
    try {
      final rc = f(ap, a.length, bp, b.length, o, 32);
      if (rc == 0) {
        for (var i = 0; i < 32; i++) {
          out32[i] = o[i];
        }
      }
      return rc;
    } finally {
      _zf(ap, a.length);
      _zf(bp, b.length);
      ioFree(o);
    }
  }

  @override
  int poseidonHash(List<BuBytes> inputs, BuBytes out32) {
    final f = _zcash?.poseidonHash;
    if (f == null) {
      return 6;
    }
    final n = inputs.length;
    final packedLen = n * 32;
    final packed = ioCalloc<ffi.Uint8>(packedLen == 0 ? 1 : packedLen);
    final o = ioCalloc<ffi.Uint8>(32);
    try {
      for (var i = 0; i < n; i++) {
        final src = inputs[i];
        for (var j = 0; j < 32 && j < src.length; j++) {
          packed[i * 32 + j] = src[j];
        }
      }
      final rc = f(packed, packedLen, n, o, 32);
      if (rc == 0) {
        for (var i = 0; i < 32; i++) {
          out32[i] = o[i];
        }
      }
      return rc;
    } finally {
      ioFree(packed);
      ioFree(o);
    }
  }

  @override
  int poseidonBn254Hash(List<BuBytes> inputs, BuBytes out32) {
    // Null when the loaded library lacks the Rust `poseidon-bn254` feature.
    final f = _zcash?.poseidonBn254Hash;
    if (f == null) {
      return 6;
    }
    final n = inputs.length;
    final packedLen = n * 32;
    final packed = ioCalloc<ffi.Uint8>(packedLen == 0 ? 1 : packedLen);
    final o = ioCalloc<ffi.Uint8>(32);
    try {
      for (var i = 0; i < n; i++) {
        final src = inputs[i];
        for (var j = 0; j < 32 && j < src.length; j++) {
          packed[i * 32 + j] = src[j];
        }
      }
      final rc = f(packed, packedLen, n, o, 32);
      if (rc == 0) {
        for (var i = 0; i < 32; i++) {
          out32[i] = o[i];
        }
      }
      return rc;
    } finally {
      ioFree(packed);
      ioFree(o);
    }
  }

  @override
  int sinsemillaHashBits(
    String domain,
    BuBytes packedBits,
    int bitLen,
    BuBytes out32,
  ) {
    final f = _zcash?.sinsemillaHashBits;
    if (f == null) {
      return 6;
    }
    final dom = BuBytes(List<int>.from(domain.codeUnits));
    final dp = _cp(dom);
    final bp = packedBits.isEmpty ? ffi.nullptr : _cp(packedBits);
    final o = ioCalloc<ffi.Uint8>(32);
    try {
      final rc = f(dp, dom.length, bp, packedBits.length, bitLen, o, 32);
      if (rc == 0) {
        for (var i = 0; i < 32; i++) {
          out32[i] = o[i];
        }
      }
      return rc;
    } finally {
      _zf(dp, dom.length);
      if (bp != ffi.nullptr) _zf(bp, packedBits.length);
      ioFree(o);
    }
  }

  int _sinsCommit(
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
    )?
    f,
    String domain,
    BuBytes packedBits,
    int bitLen,
    BuBytes r32,
    BuBytes out32,
  ) {
    if (f == null) {
      return 6;
    }
    final dom = BuBytes(List<int>.from(domain.codeUnits));
    final dp = _cp(dom);
    final bp = packedBits.isEmpty ? ffi.nullptr : _cp(packedBits);
    final rp = _cp(r32);
    final o = ioCalloc<ffi.Uint8>(32);
    try {
      final rc = f(
        dp,
        dom.length,
        bp,
        packedBits.length,
        bitLen,
        rp,
        32,
        o,
        32,
      );
      if (rc == 0) {
        for (var i = 0; i < 32; i++) {
          out32[i] = o[i];
        }
      }
      return rc;
    } finally {
      _zf(dp, dom.length);
      if (bp != ffi.nullptr) _zf(bp, packedBits.length);
      _zf(rp, r32.length);
      ioFree(o);
    }
  }

  @override
  int sinsemillaCommit(
    String domain,
    BuBytes packedBits,
    int bitLen,
    BuBytes r32,
    BuBytes out32,
  ) => _sinsCommit(
    _zcash?.sinsemillaCommit,
    domain,
    packedBits,
    bitLen,
    r32,
    out32,
  );

  @override
  int sinsemillaShortCommit(
    String domain,
    BuBytes packedBits,
    int bitLen,
    BuBytes r32,
    BuBytes out32,
  ) => _sinsCommit(
    _zcash?.sinsemillaShortCommit,
    domain,
    packedBits,
    bitLen,
    r32,
    out32,
  );

  @override
  int poseidonPermute(BuBytes state96) {
    final f = _zcash?.poseidonPermute;
    if (f == null) {
      return 6;
    }
    if (state96.length < 96) {
      return 2;
    }
    final sp = _cp(state96);
    try {
      final rc = f(sp, state96.length);
      if (rc == 0) {
        for (var i = 0; i < 96; i++) {
          state96[i] = sp[i];
        }
      }
      return rc;
    } finally {
      ioFree(sp);
    }
  }

  @override
  int sinsemillaHashBitstring(String domain, String bits01, BuBytes out32) {
    final f = _zcash?.sinsemillaHashBitstring;
    if (f == null) {
      return 6;
    }
    final dom = BuBytes(List<int>.from(domain.codeUnits));
    final bits = BuBytes(List<int>.from(bits01.codeUnits));
    final dp = _cp(dom);
    final bp = bits.isEmpty ? ffi.nullptr : _cp(bits);
    final o = ioCalloc<ffi.Uint8>(32);
    try {
      final rc = f(dp, dom.length, bp, bits.length, o, 32);
      if (rc == 0) {
        for (var i = 0; i < 32; i++) {
          out32[i] = o[i];
        }
      }
      return rc;
    } finally {
      _zf(dp, dom.length);
      if (bp != ffi.nullptr) _zf(bp, bits.length);
      ioFree(o);
    }
  }

  @override
  int pedersenHash(
    int personal,
    int layer,
    BuBytes packedBits,
    int bitLen,
    BuBytes out32,
  ) {
    final f = _zcash?.pedersenHash;
    if (f == null) {
      return 6;
    }
    final bp = packedBits.isEmpty ? ffi.nullptr : _cp(packedBits);
    final o = ioCalloc<ffi.Uint8>(32);
    try {
      final rc = f(personal, layer, bp, packedBits.length, bitLen, o, 32);
      if (rc == 0) {
        for (var i = 0; i < 32; i++) {
          out32[i] = o[i];
        }
      }
      return rc;
    } finally {
      if (bp != ffi.nullptr) _zf(bp, packedBits.length);
      ioFree(o);
    }
  }

  @override
  int pedersenHashBitstring(
    int personal,
    int layer,
    String bits01,
    BuBytes out32,
  ) {
    final f = _zcash?.pedersenHashBitstring;
    if (f == null) {
      return 6;
    }
    final bits = BuBytes(List<int>.from(bits01.codeUnits));
    final bp = bits.isEmpty ? ffi.nullptr : _cp(bits);
    final o = ioCalloc<ffi.Uint8>(32);
    try {
      final rc = f(personal, layer, bp, bits.length, o, 32);
      if (rc == 0) {
        for (var i = 0; i < 32; i++) {
          out32[i] = o[i];
        }
      }
      return rc;
    } finally {
      if (bp != ffi.nullptr) _zf(bp, bits.length);
      ioFree(o);
    }
  }

  int _g16Verify(dynamic f, BuBytes proof, BuBytes vk, BuBytes publicInputs) {
    if (f == null) return 6; // BU_G16_ERR_INTERNAL / unsupported
    final pp = _cp(proof);
    final vp = _cp(vk);
    final ip = publicInputs.isEmpty ? ffi.nullptr : _cp(publicInputs);
    try {
      return f(pp, proof.length, vp, vk.length, ip, publicInputs.length);
    } finally {
      _zf(pp, proof.length);
      _zf(vp, vk.length);
      if (publicInputs.isNotEmpty) _zf(ip, publicInputs.length);
    }
  }

  @override
  int groth16VerifyBls({
    required BuBytes proof,
    required BuBytes vk,
    required BuBytes publicInputs,
  }) {
    final f = _g16?.verifyBls;
    return _g16Verify(f, proof, vk, publicInputs);
  }

  @override
  int groth16VerifyBn254({
    required BuBytes proof,
    required BuBytes vk,
    required BuBytes publicInputs,
  }) {
    final f = _g16?.verifyBn254;
    return _g16Verify(f, proof, vk, publicInputs);
  }

  @override
  int groth16BlsProofLen() {
    try {
      return _g16?.blsProofLen() ?? 192;
    } catch (_) {
      return 192;
    }
  }

  @override
  int groth16Bn254ProofLen() {
    try {
      return _g16?.bn254ProofLen() ?? 256;
    } catch (_) {
      return 256;
    }
  }

  @override
  int zkVersion() {
    try {
      return _zk?.version() ?? 1;
    } catch (_) {
      return 1;
    }
  }

  @override
  int zkEnableLogging(int enable, int mode) {
    final f = _zk?.enableLogging;
    if (f == null) {
      return 0;
    }
    try {
      return f(enable, mode);
    } catch (_) {
      return 0;
    }
  }

  @override
  int backendVersion() {
    try {
      return _zk?.buildVersion() ?? 0;
    } catch (_) {
      return 0;
    }
  }

  @override
  int backendFeatures() {
    try {
      return _zk?.buildFeatures() ?? 0;
    } catch (_) {
      return 0;
    }
  }

  void _trCheck(int rc, String ctx) {
    if (rc != 0) {
      // Rust BU_TR_*: 1 = null, 2 = buffer. Map onto the generic codes.
      if (rc == 1) {
        throw const BuError(
          DefaultErrorType.nullPointer,
          'transcript: null handle/pointer',
        );
      }
      throw BuError(DefaultErrorType.bufferTooSmall, 'transcript: $ctx rc=$rc');
    }
  }

  @override
  Object merlinNew(BuBytes label) {
    final t = _tr;
    if (t == null) {
      throw BuError.unsupported;
    }
    final l = _cp(label);
    try {
      final h = t.merlinNew(l, label.length);
      if (h == ffi.nullptr) {
        throw BuError.internal;
      }
      return h;
    } finally {
      ioFree(l);
    }
  }

  @override
  void merlinAppend(Object handle, BuBytes label, BuBytes message) {
    final t = _tr;
    if (t == null) {
      throw BuError.unsupported;
    }
    final l = _cp(label);
    final m = _cp(message);
    try {
      _trCheck(
        t.merlinAppend(
          handle as ffi.Pointer<ffi.Void>,
          l,
          label.length,
          m,
          message.length,
        ),
        'append',
      );
    } finally {
      ioFree(l);
      ioFree(m);
    }
  }

  @override
  void merlinChallenge(Object handle, BuBytes label, BuBytes out) {
    final t = _tr;
    if (t == null) {
      throw BuError.unsupported;
    }
    if (out.isEmpty) {
      throw BuError.invalidLength;
    }
    final l = _cp(label);
    final o = ioCalloc<ffi.Uint8>(out.length);
    try {
      _trCheck(
        t.merlinChallenge(
          handle as ffi.Pointer<ffi.Void>,
          l,
          label.length,
          o,
          out.length,
        ),
        'challenge',
      );
      for (var i = 0; i < out.length; i++) {
        out[i] = o[i];
      }
    } finally {
      ioFree(l);
      ioFree(o);
    }
  }

  @override
  Object merlinFork(Object handle) {
    final t = _tr;
    if (t == null) {
      throw BuError.unsupported;
    }
    final h = t.merlinFork(handle as ffi.Pointer<ffi.Void>);
    if (h == ffi.nullptr) {
      throw BuError.internal;
    }
    return h;
  }

  @override
  void merlinFree(Object handle) {
    final t = _tr;
    if (t == null) {
      return;
    }
    try {
      t.merlinFree(handle as ffi.Pointer<ffi.Void>);
    } catch (_) {
      // Free is idempotent at the Dart layer; ignore double-free races.
    }
  }

  @override
  Object strobeNew(BuBytes protocol) {
    final t = _tr;
    if (t == null) {
      throw BuError.unsupported;
    }
    final p = _cp(protocol);
    try {
      final h = t.strobeNew(p, protocol.length);
      if (h == ffi.nullptr) {
        throw BuError.internal;
      }
      return h;
    } finally {
      ioFree(p);
    }
  }

  @override
  void strobeKey(Object handle, BuBytes data) {
    final t = _tr;
    if (t == null) {
      throw BuError.unsupported;
    }
    final d = _cp(data);
    try {
      _trCheck(
        t.strobeKey(handle as ffi.Pointer<ffi.Void>, d, data.length),
        'key',
      );
    } finally {
      ioFree(d);
    }
  }

  @override
  void strobeAd(Object handle, bool meta, BuBytes data) {
    final t = _tr;
    if (t == null) {
      throw BuError.unsupported;
    }
    final d = _cp(data);
    try {
      _trCheck(
        t.strobeAd(
          handle as ffi.Pointer<ffi.Void>,
          meta ? 1 : 0,
          d,
          data.length,
        ),
        'ad',
      );
    } finally {
      ioFree(d);
    }
  }

  @override
  void strobePrf(Object handle, BuBytes out) {
    final t = _tr;
    if (t == null) {
      throw BuError.unsupported;
    }
    if (out.isEmpty) {
      throw BuError.invalidLength;
    }
    final o = ioCalloc<ffi.Uint8>(out.length);
    try {
      _trCheck(
        t.strobePrf(handle as ffi.Pointer<ffi.Void>, o, out.length),
        'prf',
      );
      for (var i = 0; i < out.length; i++) {
        out[i] = o[i];
      }
    } finally {
      ioFree(o);
    }
  }

  @override
  void strobeFree(Object handle) {
    final t = _tr;
    if (t == null) {
      return;
    }
    try {
      t.strobeFree(handle as ffi.Pointer<ffi.Void>);
    } catch (_) {
      // Free is idempotent at the Dart layer; ignore double-free races.
    }
  }

  int _saplingSetParams(
    int Function(
      ffi.Pointer<ffi.Uint8>,
      int,
      ffi.Pointer<ffi.Pointer<ffi.Void>>,
    )?
    f,
    BuBytes params,
    List<Object?> outHandle,
  ) {
    if (f == null) {
      return 6;
    }
    final pp = _cp(params);
    final hp = ioCalloc<ffi.Pointer<ffi.Void>>();
    try {
      final rc = f(pp, params.length, hp);
      if (rc == 0) {
        final h = hp.value;
        if (h == ffi.nullptr) {
          return 6;
        }
        outHandle[0] = h;
      }
      return rc;
    } finally {
      _zf(pp, params.length);
      ioFree(hp);
    }
  }

  @override
  int saplingSetSpendParams(BuBytes params, List<Object?> outHandle) =>
      _saplingSetParams(_sapling?.setSpendParams, params, outHandle);

  @override
  int saplingSetOutputParams(BuBytes params, List<Object?> outHandle) =>
      _saplingSetParams(_sapling?.setOutputParams, params, outHandle);

  @override
  void saplingParamsFree(Object handle) {
    final f = _sapling?.paramsFree;
    if (f == null) return;
    f(handle as ffi.Pointer<ffi.Void>);
  }

  @override
  int saplingProve(
    Object handle,
    int kind,
    BuBytes witness,
    BuBytes outProof,
    BuBytes outInputs,
  ) {
    final f = _sapling?.prove;
    if (f == null) {
      return 6;
    }
    final h = handle as ffi.Pointer<ffi.Void>;
    final wp = witness.isEmpty ? ffi.nullptr : _cp(witness);
    final pp = ioCalloc<ffi.Uint8>(outProof.isEmpty ? 1 : outProof.length);
    final ip = ioCalloc<ffi.Uint8>(outInputs.isEmpty ? 1 : outInputs.length);
    final pl = ioCalloc<ffi.Size>()..value = outProof.length;
    final il = ioCalloc<ffi.Size>()..value = outInputs.length;
    try {
      final rc = f(h, kind, wp, witness.length, pp, pl, ip, il);
      if (rc == 0) {
        final pn = pl.value;
        final inode = il.value;
        if (pn != outProof.length || inode != outInputs.length) {
          return 2;
        }
        for (var i = 0; i < outProof.length; i++) {
          outProof[i] = pp[i];
        }
        for (var i = 0; i < outInputs.length; i++) {
          outInputs[i] = ip[i];
        }
      }
      return rc;
    } finally {
      if (wp != ffi.nullptr) _zf(wp, witness.length);
      ioFree(pp);
      ioFree(ip);
      ioFree(pl);
      ioFree(il);
    }
  }

  @override
  int saplingVerify({
    required Object handle,
    required int kind,
    required BuBytes proof,
    required BuBytes inputs,
  }) {
    final f = _sapling?.verify;
    if (f == null) {
      return 6;
    }
    final h = handle as ffi.Pointer<ffi.Void>;
    final pp = _cp(proof);
    final ip = inputs.isEmpty ? ffi.nullptr : _cp(inputs);
    try {
      return f(h, kind, pp, proof.length, ip, inputs.length);
    } finally {
      _zf(pp, proof.length);
      if (ip != ffi.nullptr) _zf(ip, inputs.length);
    }
  }

  @override
  int orchardPkNew(int version, List<Object?> outPk) {
    final f = _orchard?.pkNewForVersion;
    if (f == null) {
      return 6;
    }
    final hp = ioCalloc<ffi.Pointer<ffi.Void>>();
    try {
      final rc = f(hp, version);
      if (rc == 0) {
        final h = hp.value;
        if (h == ffi.nullptr) {
          return 6;
        }
        outPk[0] = h;
      }
      return rc;
    } finally {
      ioFree(hp);
    }
  }

  @override
  void orchardPkFree(Object pk) {
    final f = _orchard?.pkFree;
    if (f == null) return;
    f(pk as ffi.Pointer<ffi.Void>);
  }

  @override
  int orchardCreateProof(
    Object pk,
    BuBytes inputs,
    BuBytes instances,
    BuBytes seed,
    int version,
    int disableCrossAddress,
    List<BuBytes> outProof,
  ) {
    final f = _orchard?.createProof;
    if (f == null) {
      return 6;
    }
    if (seed.length != 32) {
      return 2;
    }
    final h = pk as ffi.Pointer<ffi.Void>;
    final ip = _cp(inputs);
    final sp = _cp(instances);
    final dp = _cp(seed);
    final lp = ioCalloc<ffi.Size>()..value = 0;
    try {
      var rc = f(
        h,
        ip,
        inputs.length,
        sp,
        instances.length,
        version,
        disableCrossAddress,
        dp,
        ffi.nullptr,
        lp,
      );
      if (rc != 2) return rc; // expect LENGTH query
      final need = lp.value;
      if (need == 0) {
        return 6;
      }
      final op = ioCalloc<ffi.Uint8>(need);
      try {
        lp.value = need;
        rc = f(
          h,
          ip,
          inputs.length,
          sp,
          instances.length,
          version,
          disableCrossAddress,
          dp,
          op,
          lp,
        );
        if (rc == 0) {
          final got = lp.value;
          final bytes = List<int>.generate(got, (i) => op[i]);
          outProof.add(BuBytes(bytes));
        }
        return rc;
      } finally {
        ioFree(op);
      }
    } finally {
      _zf(ip, inputs.length);
      _zf(sp, instances.length);
      _zf(dp, seed.length);
      ioFree(lp);
    }
  }

  @override
  int orchardVerifyProof({
    required Object pk,
    required BuBytes proof,
    required BuBytes instances,
    required int version,
    required int disableCrossAddress,
  }) {
    final f = _orchard?.verifyProof;
    if (f == null) {
      return 6;
    }
    final h = pk as ffi.Pointer<ffi.Void>;
    final pp = _cp(proof);
    final ip = instances.isEmpty ? ffi.nullptr : _cp(instances);
    try {
      return f(
        h,
        pp,
        proof.length,
        ip,
        instances.length,
        version,
        disableCrossAddress,
      );
    } finally {
      _zf(pp, proof.length);
      if (ip != ffi.nullptr) _zf(ip, instances.length);
    }
  }

  /// Length-query helper: query [need] with a null buffer, then fetch.
  int _merkleFetch(
    int Function(ffi.Pointer<ffi.Uint8>, ffi.Pointer<ffi.Size>) query,
    List<BuBytes> out,
  ) {
    final lp = ioCalloc<ffi.Size>()..value = 0;
    try {
      var rc = query(ffi.nullptr, lp);
      if (rc != 3) return rc; // expect ZK_ERR_INPUT length-query
      final need = lp.value;
      if (need == 0) {
        return 6;
      }
      final buf = ioCalloc<ffi.Uint8>(need);
      try {
        lp.value = need;
        rc = query(buf, lp);
        if (rc == 0) {
          final got = lp.value;
          out.add(BuBytes(List<int>.generate(got, (i) => buf[i])));
        }
        return rc;
      } finally {
        ioFree(buf);
      }
    } finally {
      ioFree(lp);
    }
  }

  @override
  int merkleCreateContext() {
    final f = _merkle?.createContext;
    if (f == null) {
      return 0;
    }
    try {
      return f();
    } catch (_) {
      return 0;
    }
  }

  @override
  int merkleCloseContext(int id) => _merkle?.closeContext(id) ?? 8;

  @override
  int merkleGetContext(int id, List<BuBytes> outBlob) {
    final f = _merkle?.getContext;
    if (f == null) {
      return 8;
    }
    return _merkleFetch((buf, lp) => f(id, buf, lp), outBlob);
  }

  @override
  int merkleInsertChainState(int id, BuBytes blob) {
    final f = _merkle?.insertChainState;
    if (f == null) {
      return 8;
    }
    final bp = blob.isEmpty ? ffi.nullptr : _cp(blob);
    try {
      return f(id, bp, blob.length);
    } finally {
      if (bp != ffi.nullptr) _zf(bp, blob.length);
    }
  }

  @override
  int merkleUpdateState(int id, int kind, BuBytes leaves) {
    final f = _merkle?.updateState;
    if (f == null) {
      return 8;
    }
    final lp = leaves.isEmpty ? ffi.nullptr : _cp(leaves);
    try {
      return f(id, kind, lp, leaves.length);
    } finally {
      if (lp != ffi.nullptr) _zf(lp, leaves.length);
    }
  }

  @override
  int merkleUpdateSubtree(int id, int kind, int start, BuBytes root32) {
    final f = _merkle?.updateSubtree;
    if (f == null) {
      return 8;
    }
    final rp = _cp(root32);
    try {
      return f(id, kind, start, rp, root32.length);
    } finally {
      _zf(rp, root32.length);
    }
  }

  @override
  int merkleMergeState(int id, int kind, BuBytes blob) {
    final f = _merkle?.mergeState;
    if (f == null) {
      return 8;
    }
    final bp = blob.isEmpty ? ffi.nullptr : _cp(blob);
    try {
      return f(id, kind, bp, blob.length);
    } finally {
      if (bp != ffi.nullptr) _zf(bp, blob.length);
    }
  }

  @override
  int merkleCheckpoint(int id, int checkpointId) =>
      _merkle?.checkpoint(id, checkpointId) ?? 8;

  @override
  int merkleCreateWitness(
    int id,
    int kind,
    int checkpointId,
    BuBytes positions,
    List<BuBytes> outWitness,
  ) {
    final f = _merkle?.createWitness;
    if (f == null) {
      return 8;
    }
    final pp = positions.isEmpty ? ffi.nullptr : _cp(positions);
    final lp = ioCalloc<ffi.Size>()..value = 0;
    try {
      var rc = f(id, kind, checkpointId, pp, positions.length, ffi.nullptr, lp);
      if (rc != 3) return rc; // expect ZK_ERR_INPUT length-query
      final need = lp.value;
      if (need == 0) {
        return 6;
      }
      final buf = ioCalloc<ffi.Uint8>(need);
      try {
        lp.value = need;
        rc = f(id, kind, checkpointId, pp, positions.length, buf, lp);
        if (rc == 0) {
          final got = lp.value;
          outWitness.add(BuBytes(List<int>.generate(got, (i) => buf[i])));
        }
        return rc;
      } finally {
        ioFree(buf);
      }
    } finally {
      if (pp != ffi.nullptr) _zf(pp, positions.length);
      ioFree(lp);
    }
  }

  @override
  int saplingVerifySpend({
    required BuBytes proof,
    required BuBytes vk,
    required BuBytes publicInputs,
  }) {
    final f = _g16?.saplingVerifySpend;
    return _g16Verify(f, proof, vk, publicInputs);
  }

  @override
  int saplingVerifyOutput({
    required BuBytes proof,
    required BuBytes vk,
    required BuBytes publicInputs,
  }) {
    final f = _g16?.saplingVerifyOutput;
    return _g16Verify(f, proof, vk, publicInputs);
  }

  @override
  int ff1Encrypt({
    required BuBytes key,
    required int radix,
    required BuBytes pt,
    BuBytes? tweak,
    required BuBytes out,
  }) {
    final f = _ff1x?.ff1Encrypt;
    if (f == null) {
      return 6;
    }
    final kp = _cp(key);
    final pp = pt.isEmpty ? ffi.nullptr : _cp(pt);
    final tp = (tweak == null || tweak.isEmpty) ? ffi.nullptr : _cp(tweak);
    final o = ioCalloc<ffi.Uint8>(out.isEmpty ? 1 : out.length);
    try {
      final rc = f(
        kp,
        key.length,
        radix,
        pp,
        pt.length,
        tp,
        tweak?.length ?? 0,
        o,
        out.length,
      );
      if (rc == 0) {
        for (var i = 0; i < out.length; i++) {
          out[i] = o[i];
        }
      }
      return rc;
    } finally {
      _zf(kp, key.length);
      if (pp != ffi.nullptr) _zf(pp, pt.length);
      if (tp != ffi.nullptr) _zf(tp, tweak?.length ?? 0);
      ioFree(o);
    }
  }

  @override
  int ff1Decrypt({
    required BuBytes key,
    required int radix,
    required BuBytes ct,
    BuBytes? tweak,
    required BuBytes out,
  }) {
    final f = _ff1x?.ff1Decrypt;
    if (f == null) {
      return 6;
    }
    final kp = _cp(key);
    final cp = ct.isEmpty ? ffi.nullptr : _cp(ct);
    final tp = (tweak == null || tweak.isEmpty) ? ffi.nullptr : _cp(tweak);
    final o = ioCalloc<ffi.Uint8>(out.isEmpty ? 1 : out.length);
    try {
      final rc = f(
        kp,
        key.length,
        radix,
        cp,
        ct.length,
        tp,
        tweak?.length ?? 0,
        o,
        out.length,
      );
      if (rc == 0) {
        for (var i = 0; i < out.length; i++) {
          out[i] = o[i];
        }
      }
      return rc;
    } finally {
      _zf(kp, key.length);
      if (cp != ffi.nullptr) _zf(cp, ct.length);
      if (tp != ffi.nullptr) _zf(tp, tweak?.length ?? 0);
      ioFree(o);
    }
  }

  int _x32(
    int Function(ffi.Pointer<ffi.Uint8>, int, ffi.Pointer<ffi.Uint8>, int)? f,
    BuBytes a,
    BuBytes out32,
  ) {
    if (f == null) {
      return 6;
    }
    final ap = _cp(a);
    final o = ioCalloc<ffi.Uint8>(32);
    try {
      final rc = f(ap, a.length, o, 32);
      if (rc == 0) {
        for (var i = 0; i < 32; i++) {
          out32[i] = o[i];
        }
      }
      return rc;
    } finally {
      _zf(ap, a.length);
      _zf(o, 32);
    }
  }

  int _x32x32(
    int Function(
      ffi.Pointer<ffi.Uint8>,
      int,
      ffi.Pointer<ffi.Uint8>,
      int,
      ffi.Pointer<ffi.Uint8>,
      int,
    )?
    f,
    BuBytes a,
    BuBytes b,
    BuBytes out32,
  ) {
    if (f == null) {
      return 6;
    }
    final ap = _cp(a);
    final bp = _cp(b);
    final o = ioCalloc<ffi.Uint8>(32);
    try {
      final rc = f(ap, a.length, bp, b.length, o, 32);
      if (rc == 0) {
        for (var i = 0; i < 32; i++) {
          out32[i] = o[i];
        }
      }
      return rc;
    } finally {
      _zf(ap, a.length);
      _zf(bp, b.length);
      _zf(o, 32);
    }
  }

  @override
  int ff1EncryptBinary({
    required BuBytes key,
    required BuBytes pt,
    BuBytes? tweak,
    required BuBytes out,
  }) {
    final f = _ff1x?.ff1EncryptBinary;
    if (f == null) {
      return 6;
    }
    final kp = _cp(key);
    final pp = pt.isEmpty ? ffi.nullptr : _cp(pt);
    final tp = (tweak == null || tweak.isEmpty) ? ffi.nullptr : _cp(tweak);
    final o = ioCalloc<ffi.Uint8>(out.isEmpty ? 1 : out.length);
    try {
      final rc = f(
        kp,
        key.length,
        pp,
        pt.length,
        tp,
        tweak?.length ?? 0,
        o,
        out.length,
      );
      if (rc == 0) {
        for (var i = 0; i < out.length; i++) {
          out[i] = o[i];
        }
      }
      return rc;
    } finally {
      _zf(kp, key.length);
      if (pp != ffi.nullptr) _zf(pp, pt.length);
      if (tp != ffi.nullptr) _zf(tp, tweak?.length ?? 0);
      ioFree(o);
    }
  }

  @override
  int ff1DecryptBinary({
    required BuBytes key,
    required BuBytes ct,
    BuBytes? tweak,
    required BuBytes out,
  }) {
    final f = _ff1x?.ff1DecryptBinary;
    if (f == null) {
      return 6;
    }
    final kp = _cp(key);
    final cp = ct.isEmpty ? ffi.nullptr : _cp(ct);
    final tp = (tweak == null || tweak.isEmpty) ? ffi.nullptr : _cp(tweak);
    final o = ioCalloc<ffi.Uint8>(out.isEmpty ? 1 : out.length);
    try {
      final rc = f(
        kp,
        key.length,
        cp,
        ct.length,
        tp,
        tweak?.length ?? 0,
        o,
        out.length,
      );
      if (rc == 0) {
        for (var i = 0; i < out.length; i++) {
          out[i] = o[i];
        }
      }
      return rc;
    } finally {
      _zf(kp, key.length);
      if (cp != ffi.nullptr) _zf(cp, ct.length);
      if (tp != ffi.nullptr) _zf(tp, tweak?.length ?? 0);
      ioFree(o);
    }
  }

  @override
  int x25519(BuBytes scalar32, BuBytes u32, BuBytes out32) =>
      _x32x32(_ff1x?.x25519, scalar32, u32, out32);

  @override
  int x25519PublicKey(BuBytes private32, BuBytes out32) =>
      _x32(_ff1x?.x25519PublicKey, private32, out32);

  @override
  int x25519Dh(BuBytes private32, BuBytes peerPublic32, BuBytes out32) =>
      _x32x32(_ff1x?.x25519Dh, private32, peerPublic32, out32);

  @override
  int ed25519PkToX25519(BuBytes edPk32, BuBytes out32) =>
      _x32(_ff1x?.ed25519PkToX25519, edPk32, out32);

  @override
  int ed25519SeedToX25519(BuBytes seed32, BuBytes out32) =>
      _x32(_ff1x?.ed25519SeedToX25519, seed32, out32);

  // —— Monero Bulletproofs+ ——
  @override
  int moneroBpPlusVerify(BuBytes packed) {
    final f = _monero?.bpPlusVerify;
    if (f == null) {
      return -5;
    }
    if (packed.isEmpty) {
      return -2;
    }
    final p = _cp(packed);
    try {
      return f(p, packed.length);
    } finally {
      ioFree(p);
    }
  }

  int _moneroFetch(
    int Function(ffi.Pointer<ffi.Uint8>, ffi.Pointer<ffi.Size>) query,
    List<BuBytes> out,
  ) {
    final lp = ioCalloc<ffi.Size>()..value = 0;
    try {
      var rc = query(ffi.nullptr, lp);
      if (rc != -2) return rc; // expect BU_MONERO_ERR_LENGTH size-query
      final need = lp.value;
      if (need == 0) {
        return -5;
      }
      final buf = ioCalloc<ffi.Uint8>(need);
      try {
        lp.value = need;
        rc = query(buf, lp);
        if (rc == 0) {
          final got = lp.value;
          out.add(BuBytes(List<int>.generate(got, (i) => buf[i])));
        }
        return rc;
      } finally {
        ioFree(buf);
      }
    } finally {
      ioFree(lp);
    }
  }

  @override
  int moneroBpPlusProveAmounts({
    required List<BuBytes> amountsLe,
    required List<BuBytes> gamma,
    required BuBytes seed32,
    required List<BuBytes> outBlob,
  }) {
    final m = _monero;
    if (m == null) {
      return -5;
    }
    if (amountsLe.isEmpty || amountsLe.length > 16) {
      return -2;
    }
    if (gamma.length != amountsLe.length || seed32.length != 32) {
      return -2;
    }
    final af = BuBytes.zero(amountsLe.length * 8);
    for (var i = 0; i < amountsLe.length; i++) {
      if (amountsLe[i].length != 8) {
        return -2;
      }
      af.setRange(i * 8, (i + 1) * 8, amountsLe[i]);
    }
    final gflat = BuBytes.zero(amountsLe.length * 32);
    for (var i = 0; i < amountsLe.length; i++) {
      gflat.setRange(i * 32, (i + 1) * 32, gamma[i]);
    }
    // u64 LE values straight from the byte buffer (no Dart-int conversion,
    // so the full 0..2^64 range works).
    final n = amountsLe.length;
    final afp = _cp(af);
    final gp = _cp(gflat);
    final sp = _cp(seed32);
    try {
      return _moneroFetch(
        (buf, lp) =>
            m.bpPlusProveAmounts(afp.cast<ffi.Uint64>(), gp, n, sp, buf, lp),
        outBlob,
      );
    } finally {
      ioFree(afp);
      ioFree(gp);
      _zf(sp, seed32.length);
      for (var i = 0; i < gflat.length; i++) {
        gflat[i] = 0;
      }
      for (var i = 0; i < af.length; i++) {
        af[i] = 0;
      }
    }
  }

  @override
  int moneroBpPlusProveScalars({
    required List<BuBytes> sv,
    required List<BuBytes> gamma,
    required BuBytes seed32,
    required List<BuBytes> outBlob,
  }) {
    final m = _monero;
    if (m == null) {
      return -5;
    }
    if (sv.isEmpty || sv.length > 16) {
      return -2;
    }
    if (gamma.length != sv.length || seed32.length != 32) {
      return -2;
    }
    final sflat = BuBytes.zero(sv.length * 32);
    for (var i = 0; i < sv.length; i++) {
      sflat.setRange(i * 32, (i + 1) * 32, sv[i]);
    }
    final gflat = BuBytes.zero(sv.length * 32);
    for (var i = 0; i < sv.length; i++) {
      gflat.setRange(i * 32, (i + 1) * 32, gamma[i]);
    }
    final sfp = _cp(sflat);
    final gfp = _cp(gflat);
    final sep = _cp(seed32);
    try {
      return _moneroFetch(
        (buf, lp) => m.bpPlusProveScalars(sfp, gfp, sv.length, sep, buf, lp),
        outBlob,
      );
    } finally {
      ioFree(sfp);
      ioFree(gfp);
      _zf(sep, seed32.length);
      for (var i = 0; i < sflat.length; i++) {
        sflat[i] = 0;
      }
      for (var i = 0; i < gflat.length; i++) {
        gflat[i] = 0;
      }
    }
  }

  // —— Monero output scan (fast unlock) ——
  @override
  int moneroUnlockBatch({
    required BuBytes viewSecrets,
    required BuBytes spendPubs,
    required BuBytes spendCountsLe,
    required BuBytes outKeys,
    required BuBytes txPubs,
    required BuBytes additional,
    required BuBytes additionalPresent,
    required BuBytes viewTagsLe,
    required BuBytes outIndicesLe,
    required int outCount,
    required int accCount,
    required List<BuBytes> outBlob,
  }) {
    final m = _monero;
    if (m == null) {
      return -5;
    }
    if (outCount <= 0 || accCount <= 0) {
      return -2;
    }
    if (spendCountsLe.length != accCount * 4) {
      return -2;
    }
    ffi.Pointer<ffi.Uint8> cp(BuBytes b) => b.isEmpty ? ffi.nullptr : _cp(b);
    void zf(ffi.Pointer<ffi.Uint8> p, BuBytes b) {
      if (p != ffi.nullptr) _zf(p, b.isEmpty ? 1 : b.length);
    }

    final vp = cp(viewSecrets);
    final sp = cp(spendPubs);
    final sflat = BuBytes(spendCountsLe);
    final scp = ioCalloc<ffi.Uint32>(accCount);
    for (var i = 0; i < accCount; i++) {
      scp[i] =
          sflat[i * 4] |
          (sflat[i * 4 + 1] << 8) |
          (sflat[i * 4 + 2] << 16) |
          (sflat[i * 4 + 3] << 24);
    }
    final op = cp(outKeys);
    final tp = cp(txPubs);
    final ap = cp(additional);
    final mp = cp(additionalPresent);
    final tflat = BuBytes(viewTagsLe);
    final sint = tflat.isEmpty ? ffi.nullptr : ioCalloc<ffi.Int32>(outCount);
    if (sint != ffi.nullptr) {
      for (var i = 0; i < outCount; i++) {
        final u =
            tflat[i * 4] |
            (tflat[i * 4 + 1] << 8) |
            (tflat[i * 4 + 2] << 16) |
            (tflat[i * 4 + 3] << 24);
        sint[i] = u >= 0x80000000 ? u - 0x100000000 : u;
      }
    }
    final iflat = BuBytes(outIndicesLe);
    final ixp = iflat.isEmpty ? ffi.nullptr : ioCalloc<ffi.Uint32>(outCount);
    if (ixp != ffi.nullptr) {
      for (var i = 0; i < outCount; i++) {
        ixp[i] =
            iflat[i * 4] |
            (iflat[i * 4 + 1] << 8) |
            (iflat[i * 4 + 2] << 16) |
            (iflat[i * 4 + 3] << 24);
      }
    }
    try {
      final lp = ioCalloc<ffi.Size>()..value = 0;
      try {
        var rc = m.unlockBatch(
          vp,
          sp,
          scp,
          op,
          tp,
          ap,
          mp,
          sint,
          ixp,
          outCount,
          accCount,
          ffi.nullptr,
          lp,
        );
        if (rc != -2) return rc; // expect LENGTH size-query
        final need = lp.value;
        if (need == 0) return 0; // zero matches: valid empty result
        final buf = ioCalloc<ffi.Uint8>(need);
        try {
          lp.value = need;
          rc = m.unlockBatch(
            vp,
            sp,
            scp,
            op,
            tp,
            ap,
            mp,
            sint,
            ixp,
            outCount,
            accCount,
            buf,
            lp,
          );
          if (rc == 0) {
            final got = lp.value;
            outBlob.add(BuBytes(List<int>.generate(got, (i) => buf[i])));
          }
          return rc;
        } finally {
          ioFree(buf);
        }
      } finally {
        ioFree(lp);
      }
    } finally {
      zf(vp, viewSecrets);
      zf(sp, spendPubs);
      ioFree(scp);
      zf(op, outKeys);
      zf(tp, txPubs);
      zf(ap, additional);
      zf(mp, additionalPresent);
      if (sint != ffi.nullptr) ioFree(sint);
      if (ixp != ffi.nullptr) ioFree(ixp);
    }
  }

  // —— sr25519 ——
  @override
  int sr25519PublicKey(BuBytes seed32, int uniform, BuBytes out32) {
    final s = _sr25519;
    if (s == null) {
      return 6;
    }
    final i = _cp(seed32);
    final o = ioCalloc<ffi.Uint8>(32);
    try {
      final rc = s.publicKey(i, seed32.length, uniform, o, 32);
      if (rc == 0) {
        for (var j = 0; j < 32; j++) {
          out32[j] = o[j];
        }
      }
      return rc;
    } finally {
      ioFree(i);
      ioFree(o);
    }
  }

  @override
  int sr25519SecretFromSeed(BuBytes seed32, int uniform, BuBytes out64) {
    final s = _sr25519;
    if (s == null) {
      return 6;
    }
    final i = _cp(seed32);
    final o = ioCalloc<ffi.Uint8>(64);
    try {
      final rc = s.secretFromSeed(i, seed32.length, uniform, o, 64);
      if (rc == 0) {
        for (var j = 0; j < 64; j++) {
          out64[j] = o[j];
        }
      }
      return rc;
    } finally {
      _zf(i, seed32.length);
      _zf(o, 64);
    }
  }

  @override
  int sr25519PublicKeyFromSecret(BuBytes sk64, BuBytes out32) {
    final s = _sr25519;
    if (s == null) {
      return 6;
    }
    final i = _cp(sk64);
    final o = ioCalloc<ffi.Uint8>(32);
    try {
      final rc = s.publicKeyFromSecret(i, sk64.length, o, 32);
      if (rc == 0) {
        for (var j = 0; j < 32; j++) {
          out32[j] = o[j];
        }
      }
      return rc;
    } finally {
      ioFree(i);
      ioFree(o);
    }
  }

  @override
  int sr25519IsValidPublicKey(BuBytes pk32) {
    final s = _sr25519;
    if (s == null) {
      return 0;
    }
    final i = _cp(pk32);
    try {
      return s.isValidPublicKey(i, pk32.length);
    } finally {
      ioFree(i);
    }
  }

  @override
  int sr25519IsValidSecretKey(BuBytes sk64) {
    final s = _sr25519;
    if (s == null) {
      return 0;
    }
    final i = _cp(sk64);
    try {
      return s.isValidSecretKey(i, sk64.length);
    } finally {
      ioFree(i);
    }
  }

  @override
  int sr25519Sign({
    required BuBytes seedOrSk,
    required int fromSeed,
    required int uniform,
    BuBytes? context,
    required BuBytes message,
    required BuBytes nonce64,
    required BuBytes sigOut64,
  }) {
    final s = _sr25519;
    if (s == null) {
      return 6;
    }
    final sk = _cp(seedOrSk);
    final msg = message.isEmpty ? ffi.nullptr : _cp(message);
    final n = _cp(nonce64);
    final ctx =
        (context == null || context.isEmpty) ? ffi.nullptr : _cp(context);
    final o = ioCalloc<ffi.Uint8>(64);
    try {
      final rc = s.sign(
        sk,
        seedOrSk.length,
        fromSeed,
        uniform,
        ctx,
        context?.length ?? 0,
        msg,
        message.length,
        n,
        nonce64.length,
        o,
        64,
      );
      if (rc == 0) {
        for (var j = 0; j < 64; j++) {
          sigOut64[j] = o[j];
        }
      }
      return rc;
    } finally {
      ioFree(sk);
      if (msg != ffi.nullptr) ioFree(msg);
      ioFree(n);
      if (ctx != ffi.nullptr) ioFree(ctx);
      ioFree(o);
    }
  }

  @override
  int sr25519Verify({
    required BuBytes publicKey,
    BuBytes? context,
    required BuBytes message,
    required BuBytes signature64,
  }) {
    final s = _sr25519;
    if (s == null) {
      return 6;
    }
    final pk = _cp(publicKey);
    final msg = message.isEmpty ? ffi.nullptr : _cp(message);
    final sig = _cp(signature64);
    final ctx =
        (context == null || context.isEmpty) ? ffi.nullptr : _cp(context);
    try {
      return s.verify(
        pk,
        publicKey.length,
        ctx,
        context?.length ?? 0,
        msg,
        message.length,
        sig,
        signature64.length,
      );
    } finally {
      ioFree(pk);
      if (msg != ffi.nullptr) ioFree(msg);
      ioFree(sig);
      if (ctx != ffi.nullptr) ioFree(ctx);
    }
  }

  @override
  int sr25519ToEd25519Bytes(BuBytes sk64, BuBytes out64) {
    final s = _sr25519;
    if (s == null) {
      return 6;
    }
    final i = _cp(sk64);
    final o = ioCalloc<ffi.Uint8>(64);
    try {
      final rc = s.toEd25519(i, sk64.length, o, 64);
      if (rc == 0) {
        for (var j = 0; j < 64; j++) {
          out64[j] = o[j];
        }
      }
      return rc;
    } finally {
      ioFree(i);
      ioFree(o);
    }
  }

  @override
  int sr25519HardDerive({
    required BuBytes seedOrSk,
    required int fromSeed,
    required int uniform,
    required BuBytes chain32,
    BuBytes? message,
    required BuBytes out96,
  }) {
    final s = _sr25519;
    if (s == null) {
      return 6;
    }
    final sk = _cp(seedOrSk);
    final ch = _cp(chain32);
    final msg =
        (message == null || message.isEmpty) ? ffi.nullptr : _cp(message);
    final o = ioCalloc<ffi.Uint8>(96);
    try {
      final rc = s.hardDerive(
        sk,
        seedOrSk.length,
        fromSeed,
        uniform,
        ch,
        chain32.length,
        msg,
        message?.length ?? 0,
        o,
        96,
      );
      if (rc == 0) {
        for (var j = 0; j < 96; j++) {
          out96[j] = o[j];
        }
      }
      return rc;
    } finally {
      ioFree(sk);
      ioFree(ch);
      if (msg != ffi.nullptr) ioFree(msg);
      ioFree(o);
    }
  }

  @override
  int sr25519SoftDerive({
    required BuBytes seedOrSk,
    required int fromSeed,
    required int uniform,
    required BuBytes chain32,
    BuBytes? message,
    required BuBytes newNonce32,
    required BuBytes out96,
  }) {
    final s = _sr25519;
    if (s == null) {
      return 6;
    }
    final sk = _cp(seedOrSk);
    final ch = _cp(chain32);
    final nn = _cp(newNonce32);
    final msg =
        (message == null || message.isEmpty) ? ffi.nullptr : _cp(message);
    final o = ioCalloc<ffi.Uint8>(96);
    try {
      final rc = s.softDerive(
        sk,
        seedOrSk.length,
        fromSeed,
        uniform,
        ch,
        chain32.length,
        msg,
        message?.length ?? 0,
        nn,
        newNonce32.length,
        o,
        96,
      );
      if (rc == 0) {
        for (var j = 0; j < 96; j++) {
          out96[j] = o[j];
        }
      }
      return rc;
    } finally {
      ioFree(sk);
      ioFree(ch);
      ioFree(nn);
      if (msg != ffi.nullptr) ioFree(msg);
      ioFree(o);
    }
  }

  @override
  int sr25519DerivePublic({
    required BuBytes publicKey,
    required BuBytes chain32,
    BuBytes? message,
    required BuBytes out64,
  }) {
    final s = _sr25519;
    if (s == null) {
      return 6;
    }
    final pk = _cp(publicKey);
    final ch = _cp(chain32);
    final msg =
        (message == null || message.isEmpty) ? ffi.nullptr : _cp(message);
    final o = ioCalloc<ffi.Uint8>(64);
    try {
      final rc = s.derivePublic(
        pk,
        publicKey.length,
        ch,
        chain32.length,
        msg,
        message?.length ?? 0,
        o,
        64,
      );
      if (rc == 0) {
        for (var j = 0; j < 64; j++) {
          out64[j] = o[j];
        }
      }
      return rc;
    } finally {
      ioFree(pk);
      ioFree(ch);
      if (msg != ffi.nullptr) ioFree(msg);
      ioFree(o);
    }
  }

  @override
  int sr25519VrfHash({
    required BuBytes publicKey,
    BuBytes? context,
    required BuBytes message,
    required BuBytes out32,
  }) {
    final s = _sr25519;
    if (s == null) {
      return 6;
    }
    final pk = _cp(publicKey);
    final msg = message.isEmpty ? ffi.nullptr : _cp(message);
    final ctx =
        (context == null || context.isEmpty) ? ffi.nullptr : _cp(context);
    final o = ioCalloc<ffi.Uint8>(32);
    try {
      final rc = s.vrfHash(
        pk,
        publicKey.length,
        ctx,
        context?.length ?? 0,
        msg,
        message.length,
        o,
        32,
      );
      if (rc == 0) {
        for (var j = 0; j < 32; j++) {
          out32[j] = o[j];
        }
      }
      return rc;
    } finally {
      ioFree(pk);
      if (msg != ffi.nullptr) ioFree(msg);
      if (ctx != ffi.nullptr) ioFree(ctx);
      ioFree(o);
    }
  }

  @override
  int sr25519VrfInOut({
    required BuBytes seedOrSk,
    required int fromSeed,
    required int uniform,
    BuBytes? context,
    required BuBytes message,
    required BuBytes out64,
  }) {
    final s = _sr25519;
    if (s == null) {
      return 6;
    }
    final sk = _cp(seedOrSk);
    final msg = message.isEmpty ? ffi.nullptr : _cp(message);
    final ctx =
        (context == null || context.isEmpty) ? ffi.nullptr : _cp(context);
    final o = ioCalloc<ffi.Uint8>(64);
    try {
      final rc = s.vrfInOut(
        sk,
        seedOrSk.length,
        fromSeed,
        uniform,
        ctx,
        context?.length ?? 0,
        msg,
        message.length,
        o,
        64,
      );
      if (rc == 0) {
        for (var j = 0; j < 64; j++) {
          out64[j] = o[j];
        }
      }
      return rc;
    } finally {
      ioFree(sk);
      if (msg != ffi.nullptr) ioFree(msg);
      if (ctx != ffi.nullptr) ioFree(ctx);
      ioFree(o);
    }
  }

  @override
  int sr25519DleqProve({
    required BuBytes seedOrSk,
    required int fromSeed,
    required int uniform,
    required BuBytes inout64,
    required BuBytes nonce64,
    required int kusama,
    BuBytes? extra,
    required BuBytes out64,
  }) {
    final s = _sr25519;
    if (s == null) {
      return 6;
    }
    final sk = _cp(seedOrSk);
    final io = _cp(inout64);
    final n = _cp(nonce64);
    final ex = (extra == null || extra.isEmpty) ? ffi.nullptr : _cp(extra);
    final o = ioCalloc<ffi.Uint8>(64);
    try {
      final rc = s.dleqProve(
        sk,
        seedOrSk.length,
        fromSeed,
        uniform,
        io,
        inout64.length,
        n,
        nonce64.length,
        kusama,
        ex,
        extra?.length ?? 0,
        o,
        64,
      );
      if (rc == 0) {
        for (var j = 0; j < 64; j++) {
          out64[j] = o[j];
        }
      }
      return rc;
    } finally {
      ioFree(sk);
      ioFree(io);
      ioFree(n);
      if (ex != ffi.nullptr) ioFree(ex);
      ioFree(o);
    }
  }

  @override
  int sr25519DleqVerify({
    required BuBytes publicKey,
    required BuBytes inout64,
    required BuBytes proof64,
    required int kusama,
    BuBytes? extra,
  }) {
    final s = _sr25519;
    if (s == null) {
      return 6;
    }
    final pk = _cp(publicKey);
    final io = _cp(inout64);
    final pr = _cp(proof64);
    final ex = (extra == null || extra.isEmpty) ? ffi.nullptr : _cp(extra);
    try {
      return s.dleqVerify(
        pk,
        publicKey.length,
        io,
        inout64.length,
        pr,
        proof64.length,
        kusama,
        ex,
        extra?.length ?? 0,
      );
    } finally {
      ioFree(pk);
      ioFree(io);
      ioFree(pr);
      if (ex != ffi.nullptr) ioFree(ex);
    }
  }

  @override
  int sr25519VrfSign({
    required BuBytes seedOrSk,
    required int fromSeed,
    required int uniform,
    BuBytes? context,
    required BuBytes message,
    required BuBytes nonce64,
    required int kusama,
    BuBytes? extra,
    required BuBytes out96,
  }) {
    final s = _sr25519;
    if (s == null) {
      return 6;
    }
    final sk = _cp(seedOrSk);
    final msg = message.isEmpty ? ffi.nullptr : _cp(message);
    final ctx =
        (context == null || context.isEmpty) ? ffi.nullptr : _cp(context);
    final n = _cp(nonce64);
    final ex = (extra == null || extra.isEmpty) ? ffi.nullptr : _cp(extra);
    final o = ioCalloc<ffi.Uint8>(96);
    try {
      final rc = s.vrfSign(
        sk,
        seedOrSk.length,
        fromSeed,
        uniform,
        ctx,
        context?.length ?? 0,
        msg,
        message.length,
        n,
        nonce64.length,
        kusama,
        ex,
        extra?.length ?? 0,
        o,
        96,
      );
      if (rc == 0) {
        for (var i = 0; i < 96; i++) {
          out96[i] = o[i];
        }
      }
      return rc;
    } finally {
      _zf(sk, seedOrSk.length);
      if (msg != ffi.nullptr) ioFree(msg);
      if (ctx != ffi.nullptr) ioFree(ctx);
      if (ex != ffi.nullptr) ioFree(ex);
      _zf(n, nonce64.length);
      _zf(o, 96);
    }
  }

  @override
  int sr25519VrfVerify({
    required BuBytes publicKey,
    BuBytes? context,
    required BuBytes message,
    required BuBytes preOut32,
    required BuBytes proof64,
    required int kusama,
    BuBytes? extra,
  }) {
    final s = _sr25519;
    if (s == null) {
      return 6;
    }
    final pk = _cp(publicKey);
    final msg = message.isEmpty ? ffi.nullptr : _cp(message);
    final ctx =
        (context == null || context.isEmpty) ? ffi.nullptr : _cp(context);
    final pre = _cp(preOut32);
    final pr = _cp(proof64);
    final ex = (extra == null || extra.isEmpty) ? ffi.nullptr : _cp(extra);
    try {
      return s.vrfVerify(
        pk,
        publicKey.length,
        ctx,
        context?.length ?? 0,
        msg,
        message.length,
        pre,
        preOut32.length,
        pr,
        proof64.length,
        kusama,
        ex,
        extra?.length ?? 0,
      );
    } finally {
      ioFree(pk);
      if (msg != ffi.nullptr) ioFree(msg);
      if (ctx != ffi.nullptr) ioFree(ctx);
      if (ex != ffi.nullptr) ioFree(ex);
      ioFree(pre);
      ioFree(pr);
    }
  }

  // ---- FROST (RFC 9591) ----
  int _frostShard(
    int Function(
      ffi.Pointer<ffi.Uint8>,
      ffi.Pointer<ffi.Uint8>,
      int,
      int,
      ffi.Pointer<ffi.Uint8>,
      int,
      ffi.Pointer<ffi.Uint8>,
      int,
    )?
    f,
    BuBytes secret32,
    BuBytes coeffsConcat,
    int nCoeffs,
    int max,
    BuBytes sharesOut,
    BuBytes polyOut,
  ) {
    if (f == null) {
      return 6;
    }
    final s = _cp(secret32);
    final c = nCoeffs == 0 ? ffi.nullptr : _cp(coeffsConcat);
    final so = ioCalloc<ffi.Uint8>(max * 36);
    final po = ioCalloc<ffi.Uint8>((1 + nCoeffs) * 32);
    try {
      final rc = f(s, c, nCoeffs, max, so, max * 36, po, (1 + nCoeffs) * 32);
      if (rc == 0) {
        for (var i = 0; i < max * 36; i++) {
          sharesOut[i] = so[i];
        }
        for (var i = 0; i < (1 + nCoeffs) * 32; i++) {
          polyOut[i] = po[i];
        }
      }
      return rc;
    } finally {
      _zf(s, secret32.length);
      if (c != ffi.nullptr) ioFree(c);
      ioFree(so);
      ioFree(po);
    }
  }

  int _frostCombine(
    int Function(ffi.Pointer<ffi.Uint8>, int, ffi.Pointer<ffi.Uint8>, int)? f,
    BuBytes sharesConcat,
    int n,
    BuBytes out32,
  ) {
    if (f == null) {
      return 6;
    }
    final s = _cp(sharesConcat);
    final o = ioCalloc<ffi.Uint8>(32);
    try {
      final rc = f(s, n, o, 32);
      if (rc == 0) {
        for (var i = 0; i < 32; i++) {
          out32[i] = o[i];
        }
      }
      return rc;
    } finally {
      ioFree(s);
      ioFree(o);
    }
  }

  int _frostVssCommit(
    int Function(ffi.Pointer<ffi.Uint8>, int, ffi.Pointer<ffi.Uint8>, int)? f,
    BuBytes coeffsConcat,
    int nCoeffs,
    BuBytes out,
  ) {
    if (f == null) {
      return 6;
    }
    final c = _cp(coeffsConcat);
    final o = ioCalloc<ffi.Uint8>(out.isEmpty ? 1 : out.length);
    try {
      final rc = f(c, nCoeffs, o, out.length);
      if (rc == 0) {
        for (var i = 0; i < out.length; i++) {
          out[i] = o[i];
        }
      }
      return rc;
    } finally {
      ioFree(c);
      ioFree(o);
    }
  }

  int _frostVssVerify(
    int Function(int, ffi.Pointer<ffi.Uint8>, ffi.Pointer<ffi.Uint8>, int)? f,
    int id,
    BuBytes share32,
    BuBytes commitmentConcat,
    int nComms,
  ) {
    if (f == null) {
      return 6;
    }
    final s = _cp(share32);
    final c = _cp(commitmentConcat);
    try {
      return f(id, s, c, nComms);
    } finally {
      _zf(s, share32.length);
      ioFree(c);
    }
  }

  int _frostGroupInfo(
    int Function(
      ffi.Pointer<ffi.Uint8>,
      int,
      int,
      ffi.Pointer<ffi.Uint8>,
      ffi.Pointer<ffi.Uint8>,
      int,
    )?
    f,
    BuBytes vssConcat,
    int nComms,
    int max,
    BuBytes groupOut,
    BuBytes pksOut,
  ) {
    if (f == null) {
      return 6;
    }
    final v = _cp(vssConcat);
    final g = ioCalloc<ffi.Uint8>(groupOut.isEmpty ? 1 : groupOut.length);
    final p = ioCalloc<ffi.Uint8>(pksOut.isEmpty ? 1 : pksOut.length);
    try {
      final rc = f(v, nComms, max, g, p, pksOut.length);
      if (rc == 0) {
        for (var i = 0; i < groupOut.length; i++) {
          groupOut[i] = g[i];
        }
        for (var i = 0; i < pksOut.length; i++) {
          pksOut[i] = p[i];
        }
      }
      return rc;
    } finally {
      ioFree(v);
      ioFree(g);
      ioFree(p);
    }
  }

  int _frostPrepareShares(
    int Function(ffi.Pointer<ffi.Uint8>, int, int, ffi.Pointer<ffi.Uint8>, int)?
    f,
    BuBytes sharesConcat,
    int n,
    int threshold,
    BuBytes out,
  ) {
    if (f == null) {
      return 6;
    }
    final s = _cp(sharesConcat);
    final o = ioCalloc<ffi.Uint8>(n * 32 == 0 ? 1 : n * 32);
    try {
      final rc = f(s, n, threshold, o, n * 32);
      if (rc == 0) {
        for (var i = 0; i < n * 32; i++) {
          out[i] = o[i];
        }
      }
      return rc;
    } finally {
      ioFree(s);
      ioFree(o);
    }
  }

  int _frostGroupFromMembers(
    int Function(
      ffi.Pointer<ffi.Uint8>,
      ffi.Pointer<ffi.Uint8>,
      int,
      int,
      ffi.Pointer<ffi.Uint8>,
      int,
    )?
    f,
    BuBytes idsConcat,
    BuBytes pubsConcat,
    int n,
    int threshold,
    BuBytes groupOut,
  ) {
    if (f == null) {
      return 6;
    }
    final ids = _cp(idsConcat);
    final p = _cp(pubsConcat);
    final g = ioCalloc<ffi.Uint8>(groupOut.isEmpty ? 1 : groupOut.length);
    try {
      final rc = f(ids, p, n, threshold, g, groupOut.length);
      if (rc == 0) {
        for (var i = 0; i < groupOut.length; i++) {
          groupOut[i] = g[i];
        }
      }
      return rc;
    } finally {
      ioFree(ids);
      ioFree(p);
      ioFree(g);
    }
  }

  int _frostReshare(
    int Function(
      ffi.Pointer<ffi.Uint8>,
      ffi.Pointer<ffi.Uint8>,
      int,
      ffi.Pointer<ffi.Uint8>,
      int,
      int,
      ffi.Pointer<ffi.Uint8>,
      int,
      ffi.Pointer<ffi.Uint8>,
      int,
      ffi.Pointer<ffi.Uint8>,
      int,
    )?
    f,
    BuBytes idsConcat,
    BuBytes secretsConcat,
    int n,
    BuBytes coeffsConcat,
    int nCoeffs,
    int threshold,
    BuBytes sharesOut,
    BuBytes pubsOut,
    BuBytes groupOut,
  ) {
    if (f == null) {
      return 6;
    }
    final ids = _cp(idsConcat);
    final sec = _cp(secretsConcat);
    final co = nCoeffs == 0 ? ffi.nullptr : _cp(coeffsConcat);
    final sh = ioCalloc<ffi.Uint8>(sharesOut.isEmpty ? 1 : sharesOut.length);
    final pb = ioCalloc<ffi.Uint8>(pubsOut.isEmpty ? 1 : pubsOut.length);
    final g = ioCalloc<ffi.Uint8>(groupOut.isEmpty ? 1 : groupOut.length);
    try {
      final rc = f(
        ids,
        sec,
        n,
        co,
        nCoeffs,
        threshold,
        sh,
        sharesOut.length,
        pb,
        pubsOut.length,
        g,
        groupOut.length,
      );
      if (rc == 0) {
        for (var i = 0; i < sharesOut.length; i++) {
          sharesOut[i] = sh[i];
        }
        for (var i = 0; i < pubsOut.length; i++) {
          pubsOut[i] = pb[i];
        }
        for (var i = 0; i < groupOut.length; i++) {
          groupOut[i] = g[i];
        }
      }
      return rc;
    } finally {
      ioFree(ids);
      _zf(sec, secretsConcat.length);
      if (co != ffi.nullptr) ioFree(co);
      ioFree(sh);
      ioFree(pb);
      ioFree(g);
    }
  }

  int _frostCommit(
    int Function(
      ffi.Pointer<ffi.Uint8>,
      ffi.Pointer<ffi.Uint8>,
      ffi.Pointer<ffi.Uint8>,
      ffi.Pointer<ffi.Uint8>,
      ffi.Pointer<ffi.Uint8>,
      ffi.Pointer<ffi.Uint8>,
      ffi.Pointer<ffi.Uint8>,
    )?
    f,
    BuBytes secretShare32,
    BuBytes hidingRand32,
    BuBytes bindingRand32,
    BuBytes hidingOut32,
    BuBytes bindingOut32,
    BuBytes hidingCommOut,
    BuBytes bindingCommOut,
  ) {
    if (f == null) {
      return 6;
    }
    final s = _cp(secretShare32);
    final hr = _cp(hidingRand32);
    final br = _cp(bindingRand32);
    final ho = ioCalloc<ffi.Uint8>(32);
    final bo = ioCalloc<ffi.Uint8>(32);
    final hc = ioCalloc<ffi.Uint8>(hidingCommOut.length);
    final bc = ioCalloc<ffi.Uint8>(bindingCommOut.length);
    try {
      final rc = f(s, hr, br, ho, bo, hc, bc);
      if (rc == 0) {
        for (var i = 0; i < 32; i++) {
          hidingOut32[i] = ho[i];
        }
        for (var i = 0; i < 32; i++) {
          bindingOut32[i] = bo[i];
        }
        for (var i = 0; i < hidingCommOut.length; i++) {
          hidingCommOut[i] = hc[i];
        }
        for (var i = 0; i < bindingCommOut.length; i++) {
          bindingCommOut[i] = bc[i];
        }
      }
      return rc;
    } finally {
      _zf(s, secretShare32.length);
      _zf(hr, hidingRand32.length);
      _zf(br, bindingRand32.length);
      ioFree(ho);
      ioFree(bo);
      ioFree(hc);
      ioFree(bc);
    }
  }

  int _frostBindingFactors(
    int Function(
      ffi.Pointer<ffi.Uint8>,
      ffi.Pointer<ffi.Uint8>,
      int,
      ffi.Pointer<ffi.Uint8>,
      int,
      ffi.Pointer<ffi.Uint8>,
      int,
    )?
    f,
    BuBytes groupPk,
    BuBytes commitmentsConcat,
    int n,
    BuBytes msg,
    BuBytes outFactors,
  ) {
    if (f == null) {
      return 6;
    }
    final g = _cp(groupPk);
    final c = _cp(commitmentsConcat);
    final m = _cp(msg);
    final o = ioCalloc<ffi.Uint8>(n * 36);
    try {
      final rc = f(g, c, n, m, msg.length, o, n * 36);
      if (rc == 0) {
        for (var i = 0; i < n * 36; i++) {
          outFactors[i] = o[i];
        }
      }
      return rc;
    } finally {
      ioFree(g);
      ioFree(c);
      ioFree(m);
      ioFree(o);
    }
  }

  int _frostGroupCommitment(
    int Function(
      ffi.Pointer<ffi.Uint8>,
      ffi.Pointer<ffi.Uint8>,
      int,
      ffi.Pointer<ffi.Uint8>,
      int,
    )?
    f,
    BuBytes commitmentsConcat,
    BuBytes factorsConcat,
    int n,
    BuBytes out,
  ) {
    if (f == null) {
      return 6;
    }
    final c = _cp(commitmentsConcat);
    final fa = _cp(factorsConcat);
    final o = ioCalloc<ffi.Uint8>(out.length);
    try {
      final rc = f(c, fa, n, o, out.length);
      if (rc == 0) {
        for (var i = 0; i < out.length; i++) {
          out[i] = o[i];
        }
      }
      return rc;
    } finally {
      ioFree(c);
      ioFree(fa);
      ioFree(o);
    }
  }

  int _frostSign(
    int Function(
      int,
      ffi.Pointer<ffi.Uint8>,
      ffi.Pointer<ffi.Uint8>,
      ffi.Pointer<ffi.Uint8>,
      ffi.Pointer<ffi.Uint8>,
      ffi.Pointer<ffi.Uint8>,
      ffi.Pointer<ffi.Uint8>,
      ffi.Pointer<ffi.Uint8>,
      int,
      ffi.Pointer<ffi.Uint8>,
      int,
      ffi.Pointer<ffi.Uint8>,
      int,
    )?
    f,
    int id,
    BuBytes secretShare32,
    BuBytes groupPk,
    BuBytes hidingNonce32,
    BuBytes bindingNonce32,
    BuBytes hidingComm,
    BuBytes bindingComm,
    BuBytes commitmentsConcat,
    int n,
    BuBytes msg,
    BuBytes out32,
  ) {
    if (f == null) {
      return 6;
    }
    final s = _cp(secretShare32);
    final g = _cp(groupPk);
    final h = _cp(hidingNonce32);
    final b = _cp(bindingNonce32);
    final hc = _cp(hidingComm);
    final bc = _cp(bindingComm);
    final c = _cp(commitmentsConcat);
    final m = _cp(msg);
    final o = ioCalloc<ffi.Uint8>(32);
    try {
      final rc = f(id, s, g, h, b, hc, bc, c, n, m, msg.length, o, 32);
      if (rc == 0) {
        for (var i = 0; i < 32; i++) {
          out32[i] = o[i];
        }
      }
      return rc;
    } finally {
      _zf(s, secretShare32.length);
      ioFree(g);
      _zf(h, hidingNonce32.length);
      _zf(b, bindingNonce32.length);
      ioFree(hc);
      ioFree(bc);
      ioFree(c);
      ioFree(m);
      ioFree(o);
    }
  }

  int _frostAggregate(
    int Function(
      ffi.Pointer<ffi.Uint8>,
      int,
      ffi.Pointer<ffi.Uint8>,
      int,
      ffi.Pointer<ffi.Uint8>,
      ffi.Pointer<ffi.Uint8>,
      int,
      ffi.Pointer<ffi.Uint8>,
      ffi.Pointer<ffi.Uint8>,
    )?
    f,
    BuBytes commitmentsConcat,
    int n,
    BuBytes msg,
    BuBytes groupPk,
    BuBytes sharesConcat,
    int nShares,
    BuBytes rOut,
    BuBytes zOut,
  ) {
    if (f == null) {
      return 6;
    }
    final c = _cp(commitmentsConcat);
    final m = _cp(msg);
    final g = _cp(groupPk);
    final s = _cp(sharesConcat);
    final ro = ioCalloc<ffi.Uint8>(rOut.length);
    final zo = ioCalloc<ffi.Uint8>(32);
    try {
      final rc = f(c, n, m, msg.length, g, s, nShares, ro, zo);
      if (rc == 0) {
        for (var i = 0; i < rOut.length; i++) {
          rOut[i] = ro[i];
        }
        for (var i = 0; i < 32; i++) {
          zOut[i] = zo[i];
        }
      }
      return rc;
    } finally {
      ioFree(c);
      ioFree(m);
      ioFree(g);
      ioFree(s);
      ioFree(ro);
      ioFree(zo);
    }
  }

  int _frostVerifyShare(
    int Function(
      int,
      ffi.Pointer<ffi.Uint8>,
      ffi.Pointer<ffi.Uint8>,
      ffi.Pointer<ffi.Uint8>,
      ffi.Pointer<ffi.Uint8>,
      int,
      ffi.Pointer<ffi.Uint8>,
      ffi.Pointer<ffi.Uint8>,
      int,
    )?
    f,
    int id,
    BuBytes pkShare,
    BuBytes commRecord,
    BuBytes share32,
    BuBytes commitmentsConcat,
    int n,
    BuBytes groupPk,
    BuBytes msg,
  ) {
    if (f == null) {
      return 6;
    }
    final ps = _cp(pkShare);
    final cr = _cp(commRecord);
    final sh = _cp(share32);
    final c = _cp(commitmentsConcat);
    final g = _cp(groupPk);
    final m = _cp(msg);
    try {
      return f(id, ps, cr, sh, c, n, g, m, msg.length);
    } finally {
      ioFree(ps);
      ioFree(cr);
      ioFree(sh);
      ioFree(c);
      ioFree(g);
      ioFree(m);
    }
  }

  int _frostVerify(
    int Function(
      ffi.Pointer<ffi.Uint8>,
      ffi.Pointer<ffi.Uint8>,
      ffi.Pointer<ffi.Uint8>,
      ffi.Pointer<ffi.Uint8>,
      int,
    )?
    f,
    BuBytes r,
    BuBytes z,
    BuBytes groupPk,
    BuBytes msg,
  ) {
    if (f == null) {
      return 6;
    }
    final rr = _cp(r);
    final zz = _cp(z);
    final g = _cp(groupPk);
    final m = _cp(msg);
    try {
      return f(rr, zz, g, m, msg.length);
    } finally {
      ioFree(rr);
      ioFree(zz);
      ioFree(g);
      ioFree(m);
    }
  }

  @override
  int frostK1Shard(
    BuBytes secret32,
    BuBytes coeffsConcat,
    int nCoeffs,
    int max,
    BuBytes sharesOut,
    BuBytes polyOut,
  ) => _frostShard(
    _frost?.k1Shard,
    secret32,
    coeffsConcat,
    nCoeffs,
    max,
    sharesOut,
    polyOut,
  );

  @override
  int frostK1Combine(BuBytes sharesConcat, int n, BuBytes out32) =>
      _frostCombine(_frost?.k1Combine, sharesConcat, n, out32);

  @override
  int frostK1VssCommit(BuBytes coeffsConcat, int nCoeffs, BuBytes out) =>
      _frostVssCommit(_frost?.k1VssCommit, coeffsConcat, nCoeffs, out);

  @override
  int frostK1VssVerify(
    int id,
    BuBytes share32,
    BuBytes commitmentConcat,
    int nComms,
  ) => _frostVssVerify(
    _frost?.k1VssVerify,
    id,
    share32,
    commitmentConcat,
    nComms,
  );

  @override
  int frostK1GroupInfo(
    BuBytes vssConcat,
    int nComms,
    int max,
    BuBytes groupOut,
    BuBytes pksOut,
  ) => _frostGroupInfo(
    _frost?.k1GroupInfo,
    vssConcat,
    nComms,
    max,
    groupOut,
    pksOut,
  );

  @override
  int frostK1Commit(
    BuBytes secretShare32,
    BuBytes hidingRand32,
    BuBytes bindingRand32,
    BuBytes hidingOut32,
    BuBytes bindingOut32,
    BuBytes hidingCommOut,
    BuBytes bindingCommOut,
  ) => _frostCommit(
    _frost?.k1Commit,
    secretShare32,
    hidingRand32,
    bindingRand32,
    hidingOut32,
    bindingOut32,
    hidingCommOut,
    bindingCommOut,
  );

  @override
  int frostK1BindingFactors(
    BuBytes groupPk,
    BuBytes commitmentsConcat,
    int n,
    BuBytes msg,
    BuBytes outFactors,
  ) => _frostBindingFactors(
    _frost?.k1BindingFactors,
    groupPk,
    commitmentsConcat,
    n,
    msg,
    outFactors,
  );

  @override
  int frostK1GroupCommitment(
    BuBytes commitmentsConcat,
    BuBytes factorsConcat,
    int n,
    BuBytes out,
  ) => _frostGroupCommitment(
    _frost?.k1GroupCommitment,
    commitmentsConcat,
    factorsConcat,
    n,
    out,
  );

  @override
  int frostK1Sign(
    int id,
    BuBytes secretShare32,
    BuBytes groupPk,
    BuBytes hidingNonce32,
    BuBytes bindingNonce32,
    BuBytes hidingComm,
    BuBytes bindingComm,
    BuBytes commitmentsConcat,
    int n,
    BuBytes msg,
    BuBytes out32,
  ) => _frostSign(
    _frost?.k1Sign,
    id,
    secretShare32,
    groupPk,
    hidingNonce32,
    bindingNonce32,
    hidingComm,
    bindingComm,
    commitmentsConcat,
    n,
    msg,
    out32,
  );

  @override
  int frostK1Aggregate(
    BuBytes commitmentsConcat,
    int n,
    BuBytes msg,
    BuBytes groupPk,
    BuBytes sharesConcat,
    int nShares,
    BuBytes rOut,
    BuBytes zOut,
  ) => _frostAggregate(
    _frost?.k1Aggregate,
    commitmentsConcat,
    n,
    msg,
    groupPk,
    sharesConcat,
    nShares,
    rOut,
    zOut,
  );

  @override
  int frostK1VerifyShare(
    int id,
    BuBytes pkShare,
    BuBytes commRecord,
    BuBytes share32,
    BuBytes commitmentsConcat,
    int n,
    BuBytes groupPk,
    BuBytes msg,
  ) => _frostVerifyShare(
    _frost?.k1VerifyShare,
    id,
    pkShare,
    commRecord,
    share32,
    commitmentsConcat,
    n,
    groupPk,
    msg,
  );

  @override
  int frostK1Verify(BuBytes r, BuBytes z, BuBytes groupPk, BuBytes msg) =>
      _frostVerify(_frost?.k1Verify, r, z, groupPk, msg);

  @override
  int frostK1PrepareShares(
    BuBytes sharesConcat,
    int n,
    int threshold,
    BuBytes out,
  ) => _frostPrepareShares(
    _frost?.k1PrepareShares,
    sharesConcat,
    n,
    threshold,
    out,
  );

  @override
  int frostK1GroupFromMembers(
    BuBytes idsConcat,
    BuBytes pubsConcat,
    int n,
    int threshold,
    BuBytes groupOut,
  ) => _frostGroupFromMembers(
    _frost?.k1GroupFromMembers,
    idsConcat,
    pubsConcat,
    n,
    threshold,
    groupOut,
  );

  @override
  int frostK1Reshare(
    BuBytes idsConcat,
    BuBytes secretsConcat,
    int n,
    BuBytes coeffsConcat,
    int nCoeffs,
    int threshold,
    BuBytes sharesOut,
    BuBytes pubsOut,
    BuBytes groupOut,
  ) => _frostReshare(
    _frost?.k1Reshare,
    idsConcat,
    secretsConcat,
    n,
    coeffsConcat,
    nCoeffs,
    threshold,
    sharesOut,
    pubsOut,
    groupOut,
  );

  @override
  int frostEdShard(
    BuBytes secret32,
    BuBytes coeffsConcat,
    int nCoeffs,
    int max,
    BuBytes sharesOut,
    BuBytes polyOut, {
    bool isScalar = true,
  }) {
    final f = _frost?.edShard;
    if (f == null) {
      return 6;
    }
    final flag = isScalar ? 1 : 0;
    return _frostShard(
      (s, c, n, m, so, sl, po, pl) => f(s, c, n, m, so, sl, po, pl, flag),
      secret32,
      coeffsConcat,
      nCoeffs,
      max,
      sharesOut,
      polyOut,
    );
  }

  @override
  int frostEdCombine(
    BuBytes sharesConcat,
    int n,
    BuBytes out32, {
    bool isScalar = true,
  }) {
    final f = _frost?.edCombine;
    if (f == null) {
      return 6;
    }
    final flag = isScalar ? 1 : 0;
    return _frostCombine(
      (s, nn, o, ol) => f(s, nn, o, ol, flag),
      sharesConcat,
      n,
      out32,
    );
  }

  @override
  int frostEdVssCommit(
    BuBytes coeffsConcat,
    int nCoeffs,
    BuBytes out, {
    bool isScalar = true,
  }) {
    final f = _frost?.edVssCommit;
    if (f == null) {
      return 6;
    }
    final flag = isScalar ? 1 : 0;
    return _frostVssCommit(
      (c, nn, o, ol) => f(c, nn, o, ol, flag),
      coeffsConcat,
      nCoeffs,
      out,
    );
  }

  @override
  int frostEdVssVerify(
    int id,
    BuBytes share32,
    BuBytes commitmentConcat,
    int nComms, {
    bool isScalar = true,
  }) {
    final f = _frost?.edVssVerify;
    if (f == null) {
      return 6;
    }
    final flag = isScalar ? 1 : 0;
    return _frostVssVerify(
      (i, s, c, nn) => f(i, s, c, nn, flag),
      id,
      share32,
      commitmentConcat,
      nComms,
    );
  }

  @override
  int frostEdGroupInfo(
    BuBytes vssConcat,
    int nComms,
    int max,
    BuBytes groupOut,
    BuBytes pksOut,
  ) => _frostGroupInfo(
    _frost?.edGroupInfo,
    vssConcat,
    nComms,
    max,
    groupOut,
    pksOut,
  );

  @override
  int frostEdCommit(
    BuBytes secretShare32,
    BuBytes hidingRand32,
    BuBytes bindingRand32,
    BuBytes hidingOut32,
    BuBytes bindingOut32,
    BuBytes hidingCommOut,
    BuBytes bindingCommOut, {
    bool isScalar = true,
  }) {
    final f = _frost?.edCommit;
    if (f == null) {
      return 6;
    }
    final flag = isScalar ? 1 : 0;
    return _frostCommit(
      (s, hr, br, ho, bo, hc, bc) => f(s, hr, br, ho, bo, hc, bc, flag),
      secretShare32,
      hidingRand32,
      bindingRand32,
      hidingOut32,
      bindingOut32,
      hidingCommOut,
      bindingCommOut,
    );
  }

  @override
  int frostEdBindingFactors(
    BuBytes groupPk,
    BuBytes commitmentsConcat,
    int n,
    BuBytes msg,
    BuBytes outFactors,
  ) => _frostBindingFactors(
    _frost?.edBindingFactors,
    groupPk,
    commitmentsConcat,
    n,
    msg,
    outFactors,
  );

  @override
  int frostEdGroupCommitment(
    BuBytes commitmentsConcat,
    BuBytes factorsConcat,
    int n,
    BuBytes out,
  ) => _frostGroupCommitment(
    _frost?.edGroupCommitment,
    commitmentsConcat,
    factorsConcat,
    n,
    out,
  );

  @override
  int frostEdSign(
    int id,
    BuBytes secretShare32,
    BuBytes groupPk,
    BuBytes hidingNonce32,
    BuBytes bindingNonce32,
    BuBytes hidingComm,
    BuBytes bindingComm,
    BuBytes commitmentsConcat,
    int n,
    BuBytes msg,
    BuBytes out32, {
    bool isScalar = true,
  }) {
    final f = _frost?.edSign;
    if (f == null) {
      return 6;
    }
    final flag = isScalar ? 1 : 0;
    return _frostSign(
      (i, s, g, h, b, hc, bc, c, nn, m, ml, o, ol) =>
          f(i, s, g, h, b, hc, bc, c, nn, m, ml, o, ol, flag),
      id,
      secretShare32,
      groupPk,
      hidingNonce32,
      bindingNonce32,
      hidingComm,
      bindingComm,
      commitmentsConcat,
      n,
      msg,
      out32,
    );
  }

  @override
  int frostEdAggregate(
    BuBytes commitmentsConcat,
    int n,
    BuBytes msg,
    BuBytes groupPk,
    BuBytes sharesConcat,
    int nShares,
    BuBytes rOut,
    BuBytes zOut,
  ) => _frostAggregate(
    _frost?.edAggregate,
    commitmentsConcat,
    n,
    msg,
    groupPk,
    sharesConcat,
    nShares,
    rOut,
    zOut,
  );

  @override
  int frostEdVerifyShare(
    int id,
    BuBytes pkShare,
    BuBytes commRecord,
    BuBytes share32,
    BuBytes commitmentsConcat,
    int n,
    BuBytes groupPk,
    BuBytes msg,
  ) => _frostVerifyShare(
    _frost?.edVerifyShare,
    id,
    pkShare,
    commRecord,
    share32,
    commitmentsConcat,
    n,
    groupPk,
    msg,
  );

  @override
  int frostEdVerify(BuBytes r, BuBytes z, BuBytes groupPk, BuBytes msg) =>
      _frostVerify(_frost?.edVerify, r, z, groupPk, msg);

  @override
  int frostEdPrepareShares(
    BuBytes sharesConcat,
    int n,
    int threshold,
    BuBytes out, {
    bool isScalar = true,
  }) {
    final f = _frost?.edPrepareShares;
    if (f == null) {
      return 6;
    }
    final flag = isScalar ? 1 : 0;
    return _frostPrepareShares(
      (s, nn, t, o, ol) => f(s, nn, t, flag, o, ol),
      sharesConcat,
      n,
      threshold,
      out,
    );
  }

  @override
  int frostEdGroupFromMembers(
    BuBytes idsConcat,
    BuBytes pubsConcat,
    int n,
    int threshold,
    BuBytes groupOut,
  ) => _frostGroupFromMembers(
    _frost?.edGroupFromMembers,
    idsConcat,
    pubsConcat,
    n,
    threshold,
    groupOut,
  );

  @override
  int frostEdReshare(
    BuBytes idsConcat,
    BuBytes secretsConcat,
    int n,
    BuBytes coeffsConcat,
    int nCoeffs,
    int threshold,
    BuBytes sharesOut,
    BuBytes pubsOut,
    BuBytes groupOut,
  ) => _frostReshare(
    _frost?.edReshare,
    idsConcat,
    secretsConcat,
    n,
    coeffsConcat,
    nCoeffs,
    threshold,
    sharesOut,
    pubsOut,
    groupOut,
  );
  // —— Solana confidential-transfer ZK ——
  int _zk1(int Function(ffi.Pointer<ffi.Uint8>) f, BuBytes a, int len) {
    final z = _solanaZk;
    if (z == null) {
      return -6;
    }
    if (a.length != len) {
      return -2;
    }
    final ap = _cp(a);
    try {
      return f(ap);
    } finally {
      ioFree(ap);
    }
  }

  /// Generic fixed-output prover: copies [ins], calls [f] with native
  /// pointers plus output buffer, copies [need] bytes into [out] on success.
  int _zkProve(
    List<BuBytes> ins,
    List<int> lens,
    int Function(List<ffi.Pointer<ffi.Uint8>>, ffi.Pointer<ffi.Uint8>) f,
    BuBytes out,
    int need,
  ) {
    final z = _solanaZk;
    if (z == null) {
      return -6;
    }
    if (ins.length != lens.length || out.length != need) {
      return -2;
    }
    final ps = <ffi.Pointer<ffi.Uint8>>[];
    try {
      for (var i = 0; i < ins.length; i++) {
        if (ins[i].length != lens[i]) {
          return -2;
        }
        ps.add(_cp(ins[i]));
      }
      final o = ioCalloc<ffi.Uint8>(need);
      try {
        final rc = f(ps, o);
        if (rc == 0) {
          for (var i = 0; i < need; i++) {
            out[i] = o[i];
          }
        }
        return rc;
      } finally {
        ioFree(o);
      }
    } finally {
      for (final p in ps) {
        ioFree(p);
      }
    }
  }

  /// Generic verifier: copies [ins], calls [f], returns its code.
  int _zkVerify(
    List<BuBytes> ins,
    List<int> lens,
    int Function(List<ffi.Pointer<ffi.Uint8>>) f,
  ) {
    final z = _solanaZk;
    if (z == null) {
      return -6;
    }
    if (ins.length != lens.length) {
      return -2;
    }
    final ps = <ffi.Pointer<ffi.Uint8>>[];
    try {
      for (var i = 0; i < ins.length; i++) {
        if (ins[i].length != lens[i]) {
          return -2;
        }
        ps.add(_cp(ins[i]));
      }
      return f(ps);
    } finally {
      for (final p in ps) {
        ioFree(p);
      }
    }
  }

  @override
  int solanaZkValidatePubkey(BuBytes pubkey) {
    final z = _solanaZk;
    if (z == null) {
      return -6;
    }
    return _zk1(z.validatePubkey, pubkey, 32);
  }

  @override
  int solanaZkValidateCiphertext(BuBytes ciphertext) {
    final z = _solanaZk;
    if (z == null) {
      return -6;
    }
    return _zk1(z.validateCiphertext, ciphertext, 64);
  }

  @override
  int solanaZkValidateAe(BuBytes ae) {
    final z = _solanaZk;
    if (z == null) {
      return -6;
    }
    return _zk1(z.validateAe, ae, 36);
  }

  @override
  int solanaZkAeEncrypt(
    BuBytes key16,
    int amount,
    BuBytes nonce12,
    BuBytes out36,
  ) {
    final z = _solanaZk;
    if (z == null) {
      return -6;
    }
    if (key16.length != 16 || nonce12.length != 12 || out36.length != 36) {
      return -2;
    }
    if (amount < 0) {
      return -2;
    }
    final kp = _cp(key16);
    final np = _cp(nonce12);
    final o = ioCalloc<ffi.Uint8>(36);
    try {
      final rc = z.aeEncrypt(kp, amount, np, o);
      if (rc == 0) {
        for (var i = 0; i < 36; i++) {
          out36[i] = o[i];
        }
      }
      return rc;
    } finally {
      ioFree(kp);
      ioFree(np);
      ioFree(o);
    }
  }

  @override
  int solanaZkAeDecrypt(BuBytes key16, BuBytes ae, BuBytes outLe8) {
    final z = _solanaZk;
    if (z == null) {
      return -6;
    }
    if (key16.length != 16 || ae.length != 36 || outLe8.length != 8) {
      return -2;
    }
    final kp = _cp(key16);
    final ap = _cp(ae);
    final o = ioCalloc<ffi.Uint64>(1);
    try {
      final rc = z.aeDecrypt(kp, ap, o);
      if (rc == 0) {
        final v = o.value;
        for (var i = 0; i < 8; i++) {
          outLe8[i] = (v >> (8 * i)) & 0xff;
        }
      }
      return rc;
    } finally {
      ioFree(kp);
      ioFree(ap);
      ioFree(o);
    }
  }

  @override
  int solanaZkPubkeyFromSecret(BuBytes secret, BuBytes out32) {
    final z = _solanaZk;
    if (z == null) {
      return -6;
    }
    if (secret.length != 32 || out32.length != 32) {
      return -2;
    }
    final sp = _cp(secret);
    final o = ioCalloc<ffi.Uint8>(32);
    try {
      final rc = z.pubkeyFromSecret(sp, o);
      if (rc == 0) {
        for (var i = 0; i < 32; i++) {
          out32[i] = o[i];
        }
      }
      return rc;
    } finally {
      ioFree(sp);
      ioFree(o);
    }
  }

  @override
  int solanaZkEncryptWith(
    BuBytes pubkey,
    int amount,
    BuBytes opening,
    BuBytes out64,
  ) {
    final z = _solanaZk;
    if (z == null) {
      return -6;
    }
    if (pubkey.length != 32 || opening.length != 32 || out64.length != 64) {
      return -2;
    }
    if (amount < 0) {
      return -2;
    }
    final pp = _cp(pubkey);
    final op = _cp(opening);
    final o = ioCalloc<ffi.Uint8>(64);
    try {
      final rc = z.encryptWith(pp, amount, op, o);
      if (rc == 0) {
        for (var i = 0; i < 64; i++) {
          out64[i] = o[i];
        }
      }
      return rc;
    } finally {
      ioFree(pp);
      ioFree(op);
      ioFree(o);
    }
  }

  @override
  int solanaZkDecryptU32(BuBytes secret, BuBytes ciphertext, BuBytes outLe8) {
    final z = _solanaZk;
    if (z == null) {
      return -6;
    }
    if (secret.length != 32 || ciphertext.length != 64 || outLe8.length != 8) {
      return -2;
    }
    final sp = _cp(secret);
    final cp = _cp(ciphertext);
    final o = ioCalloc<ffi.Uint64>(1);
    try {
      final rc = z.decryptU32(sp, cp, o);
      if (rc == 0) {
        final v = o.value;
        for (var i = 0; i < 8; i++) {
          outLe8[i] = (v >> (8 * i)) & 0xff;
        }
      }
      return rc;
    } finally {
      ioFree(sp);
      ioFree(cp);
      ioFree(o);
    }
  }

  @override
  int solanaZkProvePubkeyValidity(
    BuBytes secret,
    BuBytes seed32,
    BuBytes out64,
  ) {
    final z = _solanaZk;
    if (z == null) {
      return -6;
    }
    return _zkProve(
      [secret, seed32],
      [32, 32],
      (ps, o) => z.provePubkeyValidity(ps[0], ps[1], o),
      out64,
      64,
    );
  }

  @override
  int solanaZkVerifyPubkeyValidity(BuBytes pubkey, BuBytes proof) {
    final z = _solanaZk;
    if (z == null) {
      return -6;
    }
    return _zkVerify(
      [pubkey, proof],
      [32, 64],
      (ps) => z.verifyPubkeyValidity(ps[0], ps[1]),
    );
  }

  @override
  int solanaZkProveZeroCiphertext(
    BuBytes secret,
    BuBytes pubkey,
    BuBytes ciphertext,
    BuBytes seed32,
    BuBytes out96,
  ) {
    final z = _solanaZk;
    if (z == null) {
      return -6;
    }
    return _zkProve(
      [secret, pubkey, ciphertext, seed32],
      [32, 32, 64, 32],
      (ps, o) => z.proveZeroCiphertext(ps[0], ps[1], ps[2], ps[3], o),
      out96,
      96,
    );
  }

  @override
  int solanaZkVerifyZeroCiphertext(
    BuBytes pubkey,
    BuBytes ciphertext,
    BuBytes proof,
  ) {
    final z = _solanaZk;
    if (z == null) {
      return -6;
    }
    return _zkVerify(
      [pubkey, ciphertext, proof],
      [32, 64, 96],
      (ps) => z.verifyZeroCiphertext(ps[0], ps[1], ps[2]),
    );
  }

  @override
  int solanaZkProveEquality({
    required BuBytes secret,
    required BuBytes pubkey,
    required BuBytes ciphertext,
    required BuBytes commitment,
    required BuBytes opening,
    required int amount,
    required BuBytes seed32,
    required BuBytes out192,
  }) {
    final z = _solanaZk;
    if (z == null) {
      return -6;
    }
    if (amount < 0) {
      return -2;
    }
    return _zkProve(
      [secret, pubkey, ciphertext, commitment, opening, seed32],
      [32, 32, 64, 32, 32, 32],
      (ps, o) =>
          z.proveEquality(ps[0], ps[1], ps[2], ps[3], ps[4], amount, ps[5], o),
      out192,
      192,
    );
  }

  @override
  int solanaZkVerifyEquality({
    required BuBytes pubkey,
    required BuBytes ciphertext,
    required BuBytes commitment,
    required BuBytes proof,
  }) {
    final z = _solanaZk;
    if (z == null) {
      return -6;
    }
    return _zkVerify(
      [pubkey, ciphertext, commitment, proof],
      [32, 64, 32, 192],
      (ps) => z.verifyEquality(ps[0], ps[1], ps[2], ps[3]),
    );
  }

  @override
  int solanaZkProveCiphertextEquality({
    required BuBytes firstSecret,
    required BuBytes firstPubkey,
    required BuBytes secondPubkey,
    required BuBytes firstCiphertext,
    required BuBytes secondCiphertext,
    required BuBytes secondOpening,
    required int amount,
    required BuBytes seed32,
    required BuBytes out224,
  }) {
    final z = _solanaZk;
    if (z == null) {
      return -6;
    }
    if (amount < 0) {
      return -2;
    }
    return _zkProve(
      [
        firstSecret,
        firstPubkey,
        secondPubkey,
        firstCiphertext,
        secondCiphertext,
        secondOpening,
        seed32,
      ],
      [32, 32, 32, 64, 64, 32, 32],
      (ps, o) => z.proveCiphertextEquality(
        ps[0],
        ps[1],
        ps[2],
        ps[3],
        ps[4],
        ps[5],
        amount,
        ps[6],
        o,
      ),
      out224,
      224,
    );
  }

  @override
  int solanaZkVerifyCiphertextEquality({
    required BuBytes firstPubkey,
    required BuBytes secondPubkey,
    required BuBytes firstCiphertext,
    required BuBytes secondCiphertext,
    required BuBytes proof,
  }) {
    final z = _solanaZk;
    if (z == null) {
      return -6;
    }
    return _zkVerify(
      [firstPubkey, secondPubkey, firstCiphertext, secondCiphertext, proof],
      [32, 32, 64, 64, 224],
      (ps) => z.verifyCiphertextEquality(ps[0], ps[1], ps[2], ps[3], ps[4]),
    );
  }

  @override
  int solanaZkProveGroupedValidity2({
    required BuBytes firstPubkey,
    required BuBytes secondPubkey,
    required BuBytes grouped96,
    required int amount,
    required BuBytes opening,
    required BuBytes seed32,
    required BuBytes out160,
  }) {
    final z = _solanaZk;
    if (z == null) {
      return -6;
    }
    if (amount < 0) {
      return -2;
    }
    return _zkProve(
      [firstPubkey, secondPubkey, grouped96, opening, seed32],
      [32, 32, 96, 32, 32],
      (ps, o) =>
          z.proveGroupedValidity2(ps[0], ps[1], ps[2], amount, ps[3], ps[4], o),
      out160,
      160,
    );
  }

  @override
  int solanaZkVerifyGroupedValidity2({
    required BuBytes firstPubkey,
    required BuBytes secondPubkey,
    required BuBytes grouped96,
    required BuBytes proof,
  }) {
    final z = _solanaZk;
    if (z == null) {
      return -6;
    }
    return _zkVerify(
      [firstPubkey, secondPubkey, grouped96, proof],
      [32, 32, 96, 160],
      (ps) => z.verifyGroupedValidity2(ps[0], ps[1], ps[2], ps[3]),
    );
  }

  @override
  int solanaZkProveGroupedValidity3({
    required BuBytes firstPubkey,
    required BuBytes secondPubkey,
    required BuBytes thirdPubkey,
    required BuBytes grouped128,
    required int amount,
    required BuBytes opening,
    required BuBytes seed32,
    required BuBytes out192,
  }) {
    final z = _solanaZk;
    if (z == null) {
      return -6;
    }
    if (amount < 0) {
      return -2;
    }
    return _zkProve(
      [firstPubkey, secondPubkey, thirdPubkey, grouped128, opening, seed32],
      [32, 32, 32, 128, 32, 32],
      (ps, o) => z.proveGroupedValidity3(
        ps[0],
        ps[1],
        ps[2],
        ps[3],
        amount,
        ps[4],
        ps[5],
        o,
      ),
      out192,
      192,
    );
  }

  @override
  int solanaZkVerifyGroupedValidity3({
    required BuBytes firstPubkey,
    required BuBytes secondPubkey,
    required BuBytes thirdPubkey,
    required BuBytes grouped128,
    required BuBytes proof,
  }) {
    final z = _solanaZk;
    if (z == null) {
      return -6;
    }
    return _zkVerify(
      [firstPubkey, secondPubkey, thirdPubkey, grouped128, proof],
      [32, 32, 32, 128, 192],
      (ps) => z.verifyGroupedValidity3(ps[0], ps[1], ps[2], ps[3], ps[4]),
    );
  }

  @override
  int solanaZkProveBatchedGroupedValidity2({
    required BuBytes firstPubkey,
    required BuBytes secondPubkey,
    required BuBytes groupedLo96,
    required BuBytes groupedHi96,
    required int amountLo,
    required int amountHi,
    required BuBytes openingLo,
    required BuBytes openingHi,
    required BuBytes seed32,
    required BuBytes out160,
  }) {
    final z = _solanaZk;
    if (z == null) {
      return -6;
    }
    if (amountLo < 0 || amountHi < 0) {
      return -2;
    }
    return _zkProve(
      [
        firstPubkey,
        secondPubkey,
        groupedLo96,
        groupedHi96,
        openingLo,
        openingHi,
        seed32,
      ],
      [32, 32, 96, 96, 32, 32, 32],
      (ps, o) => z.proveBatchedGroupedValidity2(
        ps[0],
        ps[1],
        ps[2],
        ps[3],
        amountLo,
        amountHi,
        ps[4],
        ps[5],
        ps[6],
        o,
      ),
      out160,
      160,
    );
  }

  @override
  int solanaZkVerifyBatchedGroupedValidity2({
    required BuBytes firstPubkey,
    required BuBytes secondPubkey,
    required BuBytes groupedLo96,
    required BuBytes groupedHi96,
    required BuBytes proof,
  }) {
    final z = _solanaZk;
    if (z == null) {
      return -6;
    }
    return _zkVerify(
      [firstPubkey, secondPubkey, groupedLo96, groupedHi96, proof],
      [32, 32, 96, 96, 160],
      (ps) =>
          z.verifyBatchedGroupedValidity2(ps[0], ps[1], ps[2], ps[3], ps[4]),
    );
  }

  @override
  int solanaZkProveBatchedGroupedValidity3({
    required BuBytes firstPubkey,
    required BuBytes secondPubkey,
    required BuBytes thirdPubkey,
    required BuBytes groupedLo128,
    required BuBytes groupedHi128,
    required int amountLo,
    required int amountHi,
    required BuBytes openingLo,
    required BuBytes openingHi,
    required BuBytes seed32,
    required BuBytes out192,
  }) {
    final z = _solanaZk;
    if (z == null) {
      return -6;
    }
    if (amountLo < 0 || amountHi < 0) {
      return -2;
    }
    return _zkProve(
      [
        firstPubkey,
        secondPubkey,
        thirdPubkey,
        groupedLo128,
        groupedHi128,
        openingLo,
        openingHi,
        seed32,
      ],
      [32, 32, 32, 128, 128, 32, 32, 32],
      (ps, o) => z.proveBatchedGroupedValidity3(
        ps[0],
        ps[1],
        ps[2],
        ps[3],
        ps[4],
        amountLo,
        amountHi,
        ps[5],
        ps[6],
        ps[7],
        o,
      ),
      out192,
      192,
    );
  }

  @override
  int solanaZkVerifyBatchedGroupedValidity3({
    required BuBytes firstPubkey,
    required BuBytes secondPubkey,
    required BuBytes thirdPubkey,
    required BuBytes groupedLo128,
    required BuBytes groupedHi128,
    required BuBytes proof,
  }) {
    final z = _solanaZk;
    if (z == null) {
      return -6;
    }
    return _zkVerify(
      [
        firstPubkey,
        secondPubkey,
        thirdPubkey,
        groupedLo128,
        groupedHi128,
        proof,
      ],
      [32, 32, 32, 128, 128, 192],
      (ps) => z.verifyBatchedGroupedValidity3(
        ps[0],
        ps[1],
        ps[2],
        ps[3],
        ps[4],
        ps[5],
      ),
    );
  }

  @override
  int solanaZkProvePercentageWithCap({
    required BuBytes percentageCommitment,
    required BuBytes percentageOpening,
    required int percentageAmount,
    required BuBytes deltaCommitment,
    required BuBytes deltaOpening,
    required int deltaAmount,
    required BuBytes claimedCommitment,
    required BuBytes claimedOpening,
    required int maxValue,
    required BuBytes seed32,
    required BuBytes out256,
  }) {
    final z = _solanaZk;
    if (z == null) {
      return -6;
    }
    if (percentageAmount < 0 || deltaAmount < 0 || maxValue < 0) {
      return -2;
    }
    return _zkProve(
      [
        percentageCommitment,
        percentageOpening,
        deltaCommitment,
        deltaOpening,
        claimedCommitment,
        claimedOpening,
        seed32,
      ],
      [32, 32, 32, 32, 32, 32, 32],
      (ps, o) => z.provePercentageWithCap(
        ps[0],
        ps[1],
        percentageAmount,
        ps[2],
        ps[3],
        deltaAmount,
        ps[4],
        ps[5],
        maxValue,
        ps[6],
        o,
      ),
      out256,
      256,
    );
  }

  @override
  int solanaZkVerifyPercentageWithCap({
    required BuBytes percentageCommitment,
    required BuBytes deltaCommitment,
    required BuBytes claimedCommitment,
    required int maxValue,
    required BuBytes proof,
  }) {
    final z = _solanaZk;
    if (z == null) {
      return -6;
    }
    if (maxValue < 0) {
      return -2;
    }
    return _zkVerify(
      [percentageCommitment, deltaCommitment, claimedCommitment, proof],
      [32, 32, 32, 256],
      (ps) => z.verifyPercentageWithCap(ps[0], ps[1], ps[2], maxValue, ps[3]),
    );
  }

  @override
  int solanaZkProveBatchedRange({
    required List<BuBytes> amountsLe,
    required List<BuBytes> openings,
    required BuBytes seed32,
    required List<BuBytes> outBlob,
  }) {
    final z = _solanaZk;
    if (z == null) {
      return -6;
    }
    if (amountsLe.isEmpty || amountsLe.length > 16) {
      return -2;
    }
    if (openings.length != amountsLe.length || seed32.length != 32) {
      return -2;
    }
    final n = amountsLe.length;
    final af = BuBytes.zero(n * 8);
    for (var i = 0; i < n; i++) {
      if (amountsLe[i].length != 8) {
        return -2;
      }
      af.setRange(i * 8, (i + 1) * 8, amountsLe[i]);
    }
    final of = BuBytes.zero(n * 32);
    for (var i = 0; i < n; i++) {
      if (openings[i].length != 32) {
        return -2;
      }
      of.setRange(i * 32, (i + 1) * 32, openings[i]);
    }
    final ap = _cp(af);
    final op = _cp(of);
    final sp = _cp(seed32);
    try {
      return _rangeFetch(
        (buf, lp) => z.proveBatchedRange(ap, op, n, sp, buf, lp),
        outBlob,
      );
    } finally {
      ioFree(ap);
      ioFree(op);
      ioFree(sp);
    }
  }

  int _rangeFetch(
    int Function(ffi.Pointer<ffi.Uint8>, ffi.Pointer<ffi.Size>) query,
    List<BuBytes> out,
  ) {
    final lp = ioCalloc<ffi.Size>()..value = 0;
    try {
      var rc = query(ffi.nullptr, lp);
      if (rc != -2) {
        return rc;
      }
      final need = lp.value;
      if (need == 0) {
        return -5;
      }
      final buf = ioCalloc<ffi.Uint8>(need);
      try {
        lp.value = need;
        rc = query(buf, lp);
        if (rc == 0) {
          final got = lp.value;
          out.add(BuBytes(List<int>.generate(got, (i) => buf[i])));
        }
        return rc;
      } finally {
        ioFree(buf);
      }
    } finally {
      ioFree(lp);
    }
  }

  @override
  int solanaZkVerifyBatchedRange({
    required BuBytes proof,
    required BuBytes commitments,
    required int n,
  }) {
    final z = _solanaZk;
    if (z == null) {
      return -6;
    }
    if (n <= 0 || n > 16 || commitments.length != n * 32) {
      return -2;
    }
    if (proof.isEmpty) {
      return -2;
    }
    final pp = _cp(proof);
    final cp = _cp(commitments);
    try {
      return z.verifyBatchedRange(pp, proof.length, cp, n);
    } finally {
      ioFree(pp);
      ioFree(cp);
    }
  }

  @override
  int solanaZkProveWithdraw({
    required BuBytes sourceSecret,
    required BuBytes sourcePubkey,
    required BuBytes currentCiphertext,
    required int currentBalance,
    required int withdrawAmount,
    required BuBytes seed32,
    required BuBytes out1256,
  }) {
    final z = _solanaZk;
    if (z == null) {
      return -6;
    }
    if (currentBalance < 0 || withdrawAmount < 0) {
      return -2;
    }
    return _zkProve(
      [sourceSecret, sourcePubkey, currentCiphertext, seed32],
      [32, 32, 64, 32],
      (ps, o) => z.proveWithdraw(
        ps[0],
        ps[1],
        ps[2],
        currentBalance,
        withdrawAmount,
        ps[3],
        o,
      ),
      out1256,
      1256,
    );
  }

  @override
  int solanaZkProveTransfer({
    required BuBytes sourceSecret,
    required BuBytes sourcePubkey,
    required BuBytes destPubkey,
    required BuBytes auditorPubkey,
    required BuBytes currentCiphertext,
    required int currentBalance,
    required int transferAmount,
    required BuBytes seed32,
    required BuBytes out1896,
  }) {
    final z = _solanaZk;
    if (z == null) {
      return -6;
    }
    if (currentBalance < 0 || transferAmount < 0) {
      return -2;
    }
    return _zkProve(
      [
        sourceSecret,
        sourcePubkey,
        destPubkey,
        auditorPubkey,
        currentCiphertext,
        seed32,
      ],
      [32, 32, 32, 32, 64, 32],
      (ps, o) => z.proveTransfer(
        ps[0],
        ps[1],
        ps[2],
        ps[3],
        ps[4],
        currentBalance,
        transferAmount,
        ps[5],
        o,
      ),
      out1896,
      1896,
    );
  }

  @override
  int solanaZkProveTransferWithFee({
    required BuBytes sourceSecret,
    required BuBytes sourcePubkey,
    required BuBytes destPubkey,
    required BuBytes auditorPubkey,
    required BuBytes authorityPubkey,
    required BuBytes currentCiphertext,
    required int currentBalance,
    required int transferAmount,
    required int feeRateBasisPoints,
    required int maximumFee,
    required BuBytes seed32,
    required BuBytes out2576,
  }) {
    final z = _solanaZk;
    if (z == null) {
      return -6;
    }
    if (currentBalance < 0 ||
        transferAmount < 0 ||
        feeRateBasisPoints < 0 ||
        maximumFee < 0) {
      return -2;
    }
    return _zkProve(
      [
        sourceSecret,
        sourcePubkey,
        destPubkey,
        auditorPubkey,
        authorityPubkey,
        currentCiphertext,
        seed32,
      ],
      [32, 32, 32, 32, 32, 64, 32],
      (ps, o) => z.proveTransferWithFee(
        ps[0],
        ps[1],
        ps[2],
        ps[3],
        ps[4],
        ps[5],
        currentBalance,
        transferAmount,
        feeRateBasisPoints,
        maximumFee,
        ps[6],
        o,
      ),
      out2576,
      2576,
    );
  }
}
