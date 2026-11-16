import 'dart:js_interop';
import 'dart:js_interop_unsafe';
import 'dart:typed_data';

import 'package:blockchain_utils_connector/src/bytes/bytes.dart';
import 'package:blockchain_utils_connector/src/error/bu_error.dart';
import 'package:blockchain_utils_connector/src/platform/bindings.dart';
import 'package:blockchain_utils_connector/src/connector/bu_features.dart';
import 'package:blockchain_utils_connector/src/connector/web/wasm_bindings.dart';

JSUint8Array _toJs(BuBytes data) =>
    Uint8List.fromList(List<int>.from(data)).toJS;
BuBytes _fromJs(JSUint8Array arr) => BuBytes(arr.toDart);

void _copyInto(BuBytes out, BuBytes src) {
  final n = out.length < src.length ? out.length : src.length;
  for (var i = 0; i < n; i++) {
    out[i] = src[i];
  }
}

int _okCopy(BuBytes out, JSUint8Array js) {
  final r = _fromJs(js);
  _copyInto(out, r);
  return 0;
}

class WasmPlatformBindings implements BuPlatformBindings {
  WasmPlatformBindings._();

  factory WasmPlatformBindings.attach() => WasmPlatformBindings._();

  @override
  BuBackendKind get backendKind => BuBackendKind.wasm;

  /// Injects the wasm-bindgen glue `<script>` (unless `BuWasm` is
  /// already present), instantiates the module, and publishes it as
  /// `globalThis.BuWasm` + `globalThis.__bu_ready`.
  ///
  /// No `eval` is used (CSP `unsafe-eval`-safe): the Dart side only reads
  /// real `globalThis` properties (`BuWasm`, `__bu_ready`, `__bu_error`).
  /// The `wasm_bindgen` lexical binding created by the `no-modules` glue
  /// (`let wasm_bindgen`) is captured by the companion `bu_shim.js`
  /// (same directory as the glue), which instantiates the module and
  /// publishes `BuWasm`/`__bu_ready`.
  ///
  /// Web only. [glueUrl] defaults to `wasm_assets/bu.js` (relative to the
  /// page, e.g. served by `dart test` from `test/wasm_assets/`). [moduleUrl]
  /// overrides the `.wasm` location; `null` auto-locates `<glue>_bg.wasm`
  /// next to the glue script. Pages that preload the glue (plus optionally
  /// `bu_shim.js`, which also honors `globalThis.__bu_wasm_url`) via
  /// `<script>` tags return immediately once `__bu_ready` is set. Throws
  /// [StateError] on `__bu_error` or after [timeout].
  ///
  /// Node/worker (no DOM): script injection is impossible, so the glue +
  /// shim must be preloaded (`import './bu.js'` / `importScripts(glueUrl)`)
  /// with an explicit [moduleUrl]; this only waits for `BuWasm`/`__bu_ready`.
  static Future<void> ensureLoaded({
    String? glueUrl,
    String? moduleUrl,
    Duration timeout = const Duration(minutes: 2),
  }) async {
    final g = globalContext;
    // Real globalThis properties only — never the glue's `let wasm_bindgen`
    // lexical binding (unreadable via getProperty; probing it needed `eval`).
    bool ready() =>
        (g.getProperty('__bu_ready'.toJS) as JSBoolean?)?.toDart == true;
    String? failure() =>
        (g.getProperty('__bu_error'.toJS) as JSString?)?.toDart;
    void failIfAny() {
      final err = failure();
      if (err != null) {
        throw BuError(
          DefaultErrorType.invalidState,
          'BuWasm bootstrap failed: $err',
        );
      }
    }

    bool hasBuWasm() => g.hasProperty('BuWasm'.toJS).toDart;

    if (ready()) return;
    failIfAny();
    if (hasBuWasm()) {
      g.setProperty('__bu_ready'.toJS, true.toJS);
      return;
    }
    final glue = glueUrl ?? 'wasm_assets/bu.js';
    if (moduleUrl != null) {
      g.setProperty('__bu_wasm_url'.toJS, moduleUrl.toJS);
    }
    final hasDom = g.hasProperty('document'.toJS).toDart;
    if (!hasDom) {
      throw BuError(
        DefaultErrorType.invalidState,
        'BuWasm glue not preloaded and no DOM to inject it (Node/worker): '
        'preload bu.js + bu_shim.js first (e.g. importScripts("$glue")) '
        'with an explicit moduleUrl, then await ensureLoaded.',
      );
    }
    void injectScript(String src, void Function()? onError) {
      final document = g.getProperty('document'.toJS) as JSObject;
      final script =
          document.callMethod('createElement'.toJS, 'script'.toJS) as JSObject;
      script.setProperty('type'.toJS, 'text/javascript'.toJS);
      // Dynamically inserted scripts default to async: without this the
      // small shim would execute before the large glue finishes loading.
      // async=false preserves insertion order (glue, then shim).
      script.setProperty('async'.toJS, false.toJS);
      script.setProperty('src'.toJS, src.toJS);
      if (onError != null) {
        script.setProperty(
          'onerror'.toJS,
          ((JSAny _) {
            onError();
          }).toJS,
        );
      }
      (document.getProperty('head'.toJS) as JSObject).callMethod(
        'appendChild'.toJS,
        script,
      );
    }

    // Companion shim publishes BuWasm/__bu_ready (external script: no eval,
    // no inline code, CSP-safe). Derived from the glue URL unless the page
    // already provides it.
    String shimUrlFor(String glueSrc) {
      final idx = glueSrc.lastIndexOf('/');
      final dir = idx < 0 ? '' : glueSrc.substring(0, idx + 1);
      return '${dir}bu_shim.js';
    }

    if (!g.hasProperty('__bu_shim_loading'.toJS).toDart) {
      g.setProperty('__bu_shim_loading'.toJS, true.toJS);
      // Fresh bootstrap attempt: drop any stale error from an earlier run
      // on this page so failIfAny only sees this attempt's outcome.
      g.setProperty('__bu_error'.toJS, null);
      injectScript(glue, () {
        g.setProperty(
          '__bu_error'.toJS,
          'failed to load glue script $glue'.toJS,
        );
      });
      final shim = shimUrlFor(glue);
      injectScript(shim, () {
        g.setProperty(
          '__bu_error'.toJS,
          'failed to load BuWasm shim $shim (host bu_shim.js next to bu.js)'
              .toJS,
        );
      });
    }
    final deadline = DateTime.now().add(timeout);
    // Wait for the shim (`BuWasm` global / `__bu_ready`), not the glue's
    // lexical `wasm_bindgen` binding.
    while (!ready() && !hasBuWasm()) {
      failIfAny();
      if (DateTime.now().isAfter(deadline)) {
        throw BuError(
          DefaultErrorType.invalidState,
          'Timed out waiting for BuWasm ($glue + bu_shim.js).',
        );
      }
      await Future<void>.delayed(const Duration(milliseconds: 100));
    }
    failIfAny();
    g.setProperty('__bu_ready'.toJS, true.toJS);
  }

  // ---- Hash ----
  @override
  Object hashNew(BuHashNativeConfig config) {
    // Explicit positional config (no JS objects, no js-sys on the Rust side).
    // Integers cross as f64: exact for all in-range values (nodeOffset < 2^48).
    return BuWasmJS.hashNew(
      config.algo,
      config.digestLength,
      config.key == null ? null : _toJs(config.key!),
      config.salt == null ? null : _toJs(config.salt!),
      config.personal == null ? null : _toJs(config.personal!),
      config.seed.toDouble(),
      config.fanout,
      config.maxDepth,
      config.leafSize,
      config.nodeOffset.toDouble(),
      config.nodeDepth,
      config.innerDigestLength,
      config.lastNode,
      config.hmac,
    );
  }

  @override
  void hashUpdate(Object handle, BuBytes data) =>
      BuWasmJS.hashUpdate(handle as int, _toJs(data));
  @override
  void hashReset(Object handle) => BuWasmJS.hashReset(handle as int);
  @override
  void hashClean(Object handle) => BuWasmJS.hashClean(handle as int);
  @override
  void hashFinish(Object handle, BuBytes out) {
    final r = _fromJs(BuWasmJS.hashFinishN(handle as int, out.length));
    _copyInto(out, r);
  }

  @override
  void hashFree(Object handle) => BuWasmJS.hashFree(handle as int);
  @override
  int hashDigestLen(Object handle) => BuWasmJS.hashDigestLen(handle as int);
  @override
  int hashBlockSize(Object handle) => BuWasmJS.hashBlockSize(handle as int);
  @override
  int hashAlgo(Object handle) => BuWasmJS.hashAlgo(handle as int);
  @override
  Object hashSaveState(Object handle) => BuWasmJS.hashSaveState(handle as int);
  @override
  void hashRestoreState(Object handle, Object state) {
    // Rust rejects unknown handles and algo/digest/hmac mismatches by
    // throwing; surface those as BuError like the FFI rc path does.
    try {
      BuWasmJS.hashRestoreState(handle as int, state as int);
    } catch (e) {
      throw BuError.state(message: '$e');
    }
  }

  @override
  void hashFreeState(Object state) => BuWasmJS.hashFreeState(state as int);

  @override
  void pbkdf2({
    required int prf,
    required BuBytes password,
    required BuBytes salt,
    required int iterations,
    required BuBytes out,
  }) {
    final r = _fromJs(
      BuWasmJS.pbkdf2(
        prf,
        _toJs(password),
        _toJs(salt),
        iterations,
        out.length,
      ),
    );
    _copyInto(out, r);
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
    final res = _fromJs(
      BuWasmJS.scrypt(_toJs(password), _toJs(salt), n, r, p, out.length),
    );
    _copyInto(out, res);
  }

  @override
  void hkdf({
    required int prf,
    required BuBytes ikm,
    BuBytes? salt,
    BuBytes? info,
    required BuBytes out,
  }) {
    final res = _fromJs(
      BuWasmJS.hkdf(
        prf,
        _toJs(ikm),
        salt == null ? null : _toJs(salt),
        info == null ? null : _toJs(info),
        out.length,
      ),
    );
    // The glue returns an empty array on native failure: never silently
    // emit zeroed key material — fail loudly instead.
    if (res.length != out.length) throw BuError.internal;
    _copyInto(out, res);
  }

  @override
  BuBytes keccakF1600(BuBytes state200) {
    final r = _fromJs(BuWasmJS.keccakF1600(_toJs(state200)));
    _copyInto(state200, r);
    return state200;
  }

  // ---- AEAD ----
  @override
  void chacha20Poly1305Encrypt({
    required BuBytes key,
    required BuBytes nonce,
    required BuBytes plaintext,
    BuBytes? aad,
    required BuBytes out,
  }) {
    final r = _fromJs(
      BuWasmJS.chacha20Poly1305Encrypt(
        _toJs(key),
        _toJs(nonce),
        _toJs(plaintext),
        aad == null ? null : _toJs(aad),
        out.length,
      ),
    );
    _copyInto(out, r);
  }

  @override
  bool chacha20Poly1305Decrypt({
    required BuBytes key,
    required BuBytes nonce,
    required BuBytes ciphertext,
    BuBytes? aad,
    required BuBytes out,
  }) {
    try {
      final r = BuWasmJS.chacha20Poly1305Decrypt(
        _toJs(key),
        _toJs(nonce),
        _toJs(ciphertext),
        aad == null ? null : _toJs(aad),
        out.length,
      );
      if (r == null) {
        return false;
      }
      _copyInto(out, _fromJs(r));
      return true;
    } catch (_) {
      return false;
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
    final r = _fromJs(
      BuWasmJS.aesGcmEncrypt(
        _toJs(key),
        _toJs(nonce),
        _toJs(plaintext),
        aad == null ? null : _toJs(aad),
        out.length,
      ),
    );
    _copyInto(out, r);
  }

  @override
  bool aesGcmDecrypt({
    required BuBytes key,
    required BuBytes nonce,
    required BuBytes ciphertext,
    BuBytes? aad,
    required BuBytes out,
  }) {
    try {
      final r = BuWasmJS.aesGcmDecrypt(
        _toJs(key),
        _toJs(nonce),
        _toJs(ciphertext),
        aad == null ? null : _toJs(aad),
        out.length,
      );
      if (r == null) {
        return false;
      }
      _copyInto(out, _fromJs(r));
      return true;
    } catch (_) {
      return false;
    }
  }

  @override
  void xsalsa20Poly1305Encrypt({
    required BuBytes key,
    required BuBytes nonce,
    required BuBytes plaintext,
    required BuBytes out,
  }) {
    if (key.length != 32) throw BuError.invalidKey;
    if (nonce.length != 24) throw BuError.invalidNonce;
    final r = _fromJs(
      BuWasmJS.xsalsa20Poly1305Encrypt(
        _toJs(key),
        _toJs(nonce),
        _toJs(plaintext),
        out.length,
      ),
    );
    // The glue returns an empty array on native failure: never silently
    // emit a zeroed tag — fail loudly instead.
    if (r.length != out.length) throw BuError.internal;
    _copyInto(out, r);
  }

  @override
  bool xsalsa20Poly1305Decrypt({
    required BuBytes key,
    required BuBytes nonce,
    required BuBytes sealed,
    required BuBytes out,
  }) {
    try {
      final r = BuWasmJS.xsalsa20Poly1305Decrypt(
        _toJs(key),
        _toJs(nonce),
        _toJs(sealed),
        out.length,
      );
      if (r == null) {
        return false;
      }
      _copyInto(out, _fromJs(r));
      return true;
    } catch (_) {
      return false;
    }
  }

  @override
  BuBytes salsaBoxBeforenm({
    required BuBytes peerPublicKey,
    required BuBytes secretKey,
  }) {
    final r = _fromJs(
      BuWasmJS.salsaBoxBeforenm(_toJs(peerPublicKey), _toJs(secretKey)),
    );
    if (r.length != 32) throw BuError.invalidKey;
    return r;
  }

  @override
  void salsaBoxEncrypt({
    required BuBytes peerPublicKey,
    required BuBytes secretKey,
    required BuBytes nonce,
    required BuBytes plaintext,
    required BuBytes out,
  }) {
    if (peerPublicKey.length != 32 || secretKey.length != 32) {
      throw BuError.invalidKey;
    }
    if (nonce.length != 24) throw BuError.invalidNonce;
    final r = _fromJs(
      BuWasmJS.salsaBoxEncrypt(
        _toJs(peerPublicKey),
        _toJs(secretKey),
        _toJs(nonce),
        _toJs(plaintext),
        out.length,
      ),
    );
    if (r.length != out.length) throw BuError.internal;
    _copyInto(out, r);
  }

  @override
  bool salsaBoxDecrypt({
    required BuBytes peerPublicKey,
    required BuBytes secretKey,
    required BuBytes nonce,
    required BuBytes sealed,
    required BuBytes out,
  }) {
    try {
      final r = BuWasmJS.salsaBoxDecrypt(
        _toJs(peerPublicKey),
        _toJs(secretKey),
        _toJs(nonce),
        _toJs(sealed),
        out.length,
      );
      if (r == null) {
        return false;
      }
      _copyInto(out, _fromJs(r));
      return true;
    } catch (_) {
      return false;
    }
  }

  // ---- Block / stream ----
  @override
  Object aesNew(BuBytes key) => BuWasmJS.aesNew(_toJs(key));
  @override
  void aesFree(Object handle) => BuWasmJS.aesFree(handle as int);
  @override
  void aesEncryptBlock(Object handle, BuBytes src, BuBytes out) {
    final r = _fromJs(BuWasmJS.aesEncryptBlock(handle as int, _toJs(src)));
    _copyInto(out, r);
  }

  @override
  void aesDecryptBlock(Object handle, BuBytes src, BuBytes out) {
    final r = _fromJs(BuWasmJS.aesDecryptBlock(handle as int, _toJs(src)));
    _copyInto(out, r);
  }

  @override
  void aesCbcEncrypt({
    required BuBytes key,
    required BuBytes iv,
    required BuBytes data,
    required BuBytes out,
  }) {
    final r = _fromJs(
      BuWasmJS.aesCbcEncrypt(_toJs(key), _toJs(iv), _toJs(data)),
    );
    _copyInto(out, r);
  }

  @override
  void aesCbcDecrypt({
    required BuBytes key,
    required BuBytes iv,
    required BuBytes data,
    required BuBytes out,
  }) {
    final r = _fromJs(
      BuWasmJS.aesCbcDecrypt(_toJs(key), _toJs(iv), _toJs(data)),
    );
    _copyInto(out, r);
  }

  @override
  void aesCtr({
    required BuBytes key,
    required BuBytes counter,
    required BuBytes data,
    required BuBytes out,
  }) {
    final r = _fromJs(BuWasmJS.aesCtr(_toJs(key), _toJs(counter), _toJs(data)));
    _copyInto(out, r);
  }

  @override
  BuBytes aesEcbEncryptPadded({
    required BuBytes key,
    required BuBytes data,
    required int padding,
  }) => _fromJs(BuWasmJS.aesEcbEncryptPadded(_toJs(key), _toJs(data), padding));
  @override
  BuBytes? aesEcbDecryptPadded({
    required BuBytes key,
    required BuBytes data,
    required int padding,
  }) {
    // The glue throws on padding failure (FFI returns null): normalize to
    // null so both backends agree.
    try {
      final r = BuWasmJS.aesEcbDecryptPadded(_toJs(key), _toJs(data), padding);
      return r == null ? null : _fromJs(r);
    } catch (_) {
      return null;
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
    final r = _fromJs(
      BuWasmJS.chacha20Xor(_toJs(key), _toJs(nonce), counter, _toJs(data)),
    );
    _copyInto(out, r);
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
    final r = _fromJs(
      BuWasmJS.chacha20StreamXor(
        _toJs(key),
        _toJs(nonce),
        _toJs(data),
        nonceInplaceCounterLength,
        seekBytes,
      ),
    );
    _copyInto(out, r);
  }

  // ---- Curves (lengths from the module: single source of truth) ----
  @override
  int curvePointLen(int curveId) {
    try {
      return BuWasmJS.curvePointLen(curveId);
    } catch (_) {
      return 0;
    }
  }

  @override
  int curveScalarLen(int curveId) {
    try {
      return BuWasmJS.curveScalarLen(curveId);
    } catch (_) {
      return 0;
    }
  }

  @override
  int curveScCheck(int curveId, BuBytes scalar) {
    try {
      return BuWasmJS.curveScCheck(curveId, _toJs(scalar)) ? 1 : 0;
    } catch (_) {
      return 0;
    }
  }

  @override
  int curveGenerator(int curveId, BuBytes out) {
    try {
      return _okCopy(out, BuWasmJS.curveGenerator(curveId));
    } catch (_) {
      return 6;
    }
  }

  @override
  int curveIdentity(int curveId, BuBytes out) {
    try {
      return _okCopy(out, BuWasmJS.curveIdentity(curveId));
    } catch (_) {
      return 6;
    }
  }

  @override
  int curveAdd(int curveId, BuBytes a, BuBytes b, BuBytes out) {
    try {
      return _okCopy(out, BuWasmJS.curveAdd(curveId, _toJs(a), _toJs(b)));
    } catch (_) {
      return 6;
    }
  }

  @override
  int curveSub(int curveId, BuBytes a, BuBytes b, BuBytes out) {
    try {
      return _okCopy(out, BuWasmJS.curveSub(curveId, _toJs(a), _toJs(b)));
    } catch (_) {
      return 6;
    }
  }

  @override
  int curveNeg(int curveId, BuBytes point, BuBytes out) {
    try {
      return _okCopy(out, BuWasmJS.curveNeg(curveId, _toJs(point)));
    } catch (_) {
      return 6;
    }
  }

  @override
  int curveMul(int curveId, BuBytes scalar, BuBytes point, BuBytes out) {
    try {
      return _okCopy(
        out,
        BuWasmJS.curveMul(curveId, _toJs(scalar), _toJs(point)),
      );
    } catch (_) {
      return 6;
    }
  }

  @override
  int curveMulBase(int curveId, BuBytes scalar, BuBytes out) {
    try {
      return _okCopy(out, BuWasmJS.curveMulBase(curveId, _toJs(scalar)));
    } catch (_) {
      return 6;
    }
  }

  @override
  int curveMulAdd(
    int curveId,
    BuBytes s1,
    BuBytes p1,
    BuBytes s2,
    BuBytes p2,
    BuBytes out,
  ) {
    try {
      return _okCopy(
        out,
        BuWasmJS.curveMulAdd(
          curveId,
          _toJs(s1),
          _toJs(p1),
          _toJs(s2),
          _toJs(p2),
        ),
      );
    } catch (_) {
      return 6;
    }
  }

  @override
  int curveGenerateSecret(int curveId, BuBytes seed, BuBytes out) {
    try {
      return _okCopy(out, BuWasmJS.curveGenerateSecret(curveId, _toJs(seed)));
    } catch (_) {
      return 6;
    }
  }

  @override
  int curveIsInfinity(int curveId, BuBytes point) {
    try {
      return BuWasmJS.curveIsInfinity(curveId, _toJs(point)) ? 1 : 0;
    } catch (_) {
      return 6;
    }
  }

  @override
  int curveScAdd(int curveId, BuBytes a, BuBytes b, BuBytes out) {
    try {
      return _okCopy(out, BuWasmJS.curveScAdd(curveId, _toJs(a), _toJs(b)));
    } catch (_) {
      return 6;
    }
  }

  @override
  int curveScSub(int curveId, BuBytes a, BuBytes b, BuBytes out) {
    try {
      return _okCopy(out, BuWasmJS.curveScSub(curveId, _toJs(a), _toJs(b)));
    } catch (_) {
      return 6;
    }
  }

  @override
  int curveScMul(int curveId, BuBytes a, BuBytes b, BuBytes out) {
    try {
      return _okCopy(out, BuWasmJS.curveScMul(curveId, _toJs(a), _toJs(b)));
    } catch (_) {
      return 6;
    }
  }

  @override
  int curveScNeg(int curveId, BuBytes s, BuBytes out) {
    try {
      return _okCopy(out, BuWasmJS.curveScNeg(curveId, _toJs(s)));
    } catch (_) {
      return 6;
    }
  }

  @override
  int curveScReduce(int curveId, BuBytes s, BuBytes out) {
    try {
      return _okCopy(out, BuWasmJS.curveScReduce(curveId, _toJs(s)));
    } catch (_) {
      return 6;
    }
  }

  @override
  int blsHashToG1(BuBytes msg, BuBytes dst, BuBytes out48) {
    try {
      return _okCopy(out48, BuWasmJS.blsHashToG1(_toJs(msg), _toJs(dst)));
    } catch (_) {
      return 6;
    }
  }

  @override
  int blsHashToG2(BuBytes msg, BuBytes dst, BuBytes out96) {
    try {
      return _okCopy(out96, BuWasmJS.blsHashToG2(_toJs(msg), _toJs(dst)));
    } catch (_) {
      return 6;
    }
  }

  @override
  int pallasHashToCurve(BuBytes msg, BuBytes dst, BuBytes out) {
    try {
      return _okCopy(out, BuWasmJS.pallasHashToCurve(_toJs(msg), _toJs(dst)));
    } catch (_) {
      return 6;
    }
  }

  @override
  int vestaHashToCurve(BuBytes msg, BuBytes dst, BuBytes out) {
    try {
      return _okCopy(out, BuWasmJS.vestaHashToCurve(_toJs(msg), _toJs(dst)));
    } catch (_) {
      return 6;
    }
  }

  @override
  int ed25519ScReduce32(BuBytes in32, BuBytes out32) {
    try {
      return _okCopy(out32, BuWasmJS.ed25519ScReduce32(_toJs(in32)));
    } catch (_) {
      return 6;
    }
  }

  @override
  int ed25519ScReduce64(BuBytes in64, BuBytes out32) {
    try {
      return _okCopy(out32, BuWasmJS.ed25519ScReduce64(_toJs(in64)));
    } catch (_) {
      return 6;
    }
  }

  @override
  int ed25519FromFeBytes(BuBytes fe32, BuBytes out32) {
    try {
      return _okCopy(out32, BuWasmJS.ed25519FromFeBytes(_toJs(fe32)));
    } catch (_) {
      return 6;
    }
  }

  @override
  int ed25519FromFeBytesClearCofactor(BuBytes fe32, BuBytes out32) {
    try {
      return _okCopy(
        out32,
        BuWasmJS.ed25519FromFeBytesClearCofactor(_toJs(fe32)),
      );
    } catch (_) {
      return 6;
    }
  }

  @override
  int ed25519HashToEc(BuBytes data, BuBytes out32) {
    try {
      return _okCopy(out32, BuWasmJS.ed25519HashToEc(_toJs(data)));
    } catch (_) {
      return 6;
    }
  }

  @override
  int ed25519CheckKey(BuBytes pk32) {
    try {
      return BuWasmJS.ed25519CheckKey(_toJs(pk32)) ? 1 : 0;
    } catch (_) {
      return 0;
    }
  }

  @override
  int ed25519MulByCofactor(BuBytes point32, BuBytes out32) {
    try {
      return _okCopy(out32, BuWasmJS.ed25519MulByCofactor(_toJs(point32)));
    } catch (_) {
      return 6;
    }
  }

  @override
  int ed25519ScalarmultKeyImage(BuBytes hp32, BuBytes a32, BuBytes out32) {
    try {
      return _okCopy(
        out32,
        BuWasmJS.ed25519ScalarmultKeyImage(_toJs(hp32), _toJs(a32)),
      );
    } catch (_) {
      return 6;
    }
  }

  @override
  int ed25519Mul8Mult(BuBytes scalar32, BuBytes point32, BuBytes out32) {
    try {
      return _okCopy(
        out32,
        BuWasmJS.ed25519Mul8Mult(_toJs(scalar32), _toJs(point32)),
      );
    } catch (_) {
      return 6;
    }
  }

  @override
  int ed25519GeDsmPrecomp(BuBytes point32, BuBytes out256) {
    try {
      return _okCopy(out256, BuWasmJS.ed25519GeDsmPrecomp(_toJs(point32)));
    } catch (_) {
      return 6;
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
    try {
      return _okCopy(
        out32,
        BuWasmJS.ed25519GeDoubleScalarMultPrecomp(
          _toJs(a32),
          _toJs(aI256),
          _toJs(b32),
          _toJs(bI256),
        ),
      );
    } catch (_) {
      return 6;
    }
  }

  @override
  int ed25519GeDoubleScalarMultBase(
    BuBytes a32,
    BuBytes gA32,
    BuBytes b32,
    BuBytes out32,
  ) {
    try {
      return _okCopy(
        out32,
        BuWasmJS.ed25519GeDoubleScalarMultBase(
          _toJs(a32),
          _toJs(gA32),
          _toJs(b32),
        ),
      );
    } catch (_) {
      return 6;
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
    try {
      return _okCopy(
        out32,
        BuWasmJS.ed25519GeTripleScalarMultBase(
          _toJs(a32),
          _toJs(b32),
          _toJs(bI256),
          _toJs(c32),
          _toJs(cI256),
        ),
      );
    } catch (_) {
      return 6;
    }
  }

  @override
  @override
  int ed25519MulVartime(BuBytes scalar32, BuBytes point32, BuBytes out32) {
    try {
      return _okCopy(
        out32,
        BuWasmJS.ed25519MulVartime(_toJs(scalar32), _toJs(point32)),
      );
    } catch (_) {
      return 6;
    }
  }

  @override
  int ed25519MulBaseVartime(BuBytes scalar32, BuBytes out32) {
    try {
      return _okCopy(out32, BuWasmJS.ed25519MulBaseVartime(_toJs(scalar32)));
    } catch (_) {
      return 6;
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
    try {
      return _okCopy(
        out32,
        BuWasmJS.ed25519MulAddVartime(
          _toJs(s1),
          _toJs(p1),
          _toJs(s2),
          _toJs(p2),
        ),
      );
    } catch (_) {
      return 6;
    }
  }

  @override
  int ed25519AddVartime(BuBytes a32, BuBytes b32, BuBytes out32) {
    try {
      return _okCopy(out32, BuWasmJS.ed25519AddVartime(_toJs(a32), _toJs(b32)));
    } catch (_) {
      return 6;
    }
  }

  @override
  int ed25519SubVartime(BuBytes a32, BuBytes b32, BuBytes out32) {
    try {
      return _okCopy(out32, BuWasmJS.ed25519SubVartime(_toJs(a32), _toJs(b32)));
    } catch (_) {
      return 6;
    }
  }

  @override
  int ed25519NegVartime(BuBytes p32, BuBytes out32) {
    try {
      return _okCopy(out32, BuWasmJS.ed25519NegVartime(_toJs(p32)));
    } catch (_) {
      return 6;
    }
  }

  @override
  int ed25519DoubleVartime(BuBytes p32, BuBytes out32) {
    try {
      return _okCopy(out32, BuWasmJS.ed25519DoubleVartime(_toJs(p32)));
    } catch (_) {
      return 6;
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
    try {
      return _okCopy(
        out32,
        BuWasmJS.ed25519GeTripleScalarMultPrecomp(
          _toJs(a32),
          _toJs(aI256),
          _toJs(b32),
          _toJs(bI256),
          _toJs(c32),
          _toJs(cI256),
        ),
      );
    } catch (_) {
      return 6;
    }
  }

  @override
  int jubjubScReduce64(BuBytes in64, BuBytes out32) {
    try {
      return _okCopy(out32, BuWasmJS.jubjubScReduce64(_toJs(in64)));
    } catch (_) {
      return 6;
    }
  }

  @override
  int ristrettoFromEdwards(BuBytes ed32, BuBytes out32) {
    try {
      return _okCopy(out32, BuWasmJS.ristrettoFromEdwards(_toJs(ed32)));
    } catch (_) {
      return 3;
    }
  }

  @override
  int ristrettoToEdwards(BuBytes ristretto32, BuBytes out32) {
    try {
      return _okCopy(out32, BuWasmJS.ristrettoToEdwards(_toJs(ristretto32)));
    } catch (_) {
      return 3;
    }
  }

  @override
  int pallasScReduce64(BuBytes in64, BuBytes out32) {
    try {
      return _okCopy(out32, BuWasmJS.pallasScReduce64(_toJs(in64)));
    } catch (_) {
      return 6;
    }
  }

  @override
  int vestaScReduce64(BuBytes in64, BuBytes out32) {
    try {
      return _okCopy(out32, BuWasmJS.vestaScReduce64(_toJs(in64)));
    } catch (_) {
      return 6;
    }
  }

  @override
  int pallasHashToCurvePasta(BuBytes domain, BuBytes msg, BuBytes out) {
    try {
      return _okCopy(
        out,
        BuWasmJS.pallasHashToCurvePasta(_toJs(domain), _toJs(msg)),
      );
    } catch (_) {
      return 6;
    }
  }

  // ---- Signing ----
  @override
  int ecdsaK1PublicKey(BuBytes sk, BuBytes out33) {
    try {
      return _okCopy(out33, BuWasmJS.ecdsaK1PublicKey(_toJs(sk)));
    } catch (_) {
      return 6;
    }
  }

  @override
  int ecdsaK1Sign(BuBytes sk, BuBytes hash32, BuBytes out64) {
    try {
      return _okCopy(out64, BuWasmJS.ecdsaK1Sign(_toJs(sk), _toJs(hash32)));
    } catch (_) {
      return 6;
    }
  }

  @override
  int ecdsaK1SignEx(BuBytes sk, BuBytes hash32, BuBytes? extra, BuBytes out64) {
    try {
      return _okCopy(
        out64,
        BuWasmJS.ecdsaK1SignEx(
          _toJs(sk),
          _toJs(hash32),
          extra == null ? null : _toJs(extra),
        ),
      );
    } catch (_) {
      return 6;
    }
  }

  @override
  int ecdsaK1Verify(BuBytes pk33, BuBytes hash32, BuBytes sig64) {
    try {
      return BuWasmJS.ecdsaK1Verify(_toJs(pk33), _toJs(hash32), _toJs(sig64))
          ? 0
          : 1;
    } catch (_) {
      return 6;
    }
  }

  @override
  int ecdsaK1Recover(BuBytes hash32, BuBytes sig64, int recId, BuBytes out33) {
    try {
      return _okCopy(
        out33,
        BuWasmJS.ecdsaK1Recover(_toJs(hash32), _toJs(sig64), recId),
      );
    } catch (_) {
      return 6;
    }
  }

  @override
  int ecdsaK1RecoveryId(
    BuBytes hash32,
    BuBytes sig64,
    BuBytes pk33,
    BuBytes outId1,
  ) {
    try {
      final id = BuWasmJS.ecdsaK1RecoveryId(
        _toJs(hash32),
        _toJs(sig64),
        _toJs(pk33),
      );
      if (outId1.isEmpty) {
        return 1;
      }
      outId1[0] = id;
      return 0;
    } catch (_) {
      return 6;
    }
  }

  @override
  int schnorrPublicKey(BuBytes sk, BuBytes out32) {
    try {
      return _okCopy(out32, BuWasmJS.schnorrPublicKey(_toJs(sk)));
    } catch (_) {
      return 6;
    }
  }

  @override
  int schnorrSign(BuBytes sk, BuBytes msg32, BuBytes? aux, BuBytes out64) {
    try {
      return _okCopy(
        out64,
        BuWasmJS.schnorrSign(
          _toJs(sk),
          _toJs(msg32),
          aux == null ? null : _toJs(aux),
        ),
      );
    } catch (_) {
      return 6;
    }
  }

  @override
  int schnorrVerify(BuBytes pk32, BuBytes msg32, BuBytes sig64) {
    try {
      return BuWasmJS.schnorrVerify(_toJs(pk32), _toJs(msg32), _toJs(sig64))
          ? 0
          : 1;
    } catch (_) {
      return 6;
    }
  }

  @override
  int schnorrTweakSecret(BuBytes sk, BuBytes tweak32, BuBytes out32) {
    try {
      return _okCopy(
        out32,
        BuWasmJS.schnorrTweakSecret(_toJs(sk), _toJs(tweak32)),
      );
    } catch (_) {
      return 6;
    }
  }

  @override
  int schnorrTweakPublic(BuBytes pk, BuBytes tweak32, BuBytes out32) {
    try {
      return _okCopy(
        out32,
        BuWasmJS.schnorrTweakPublic(_toJs(pk), _toJs(tweak32)),
      );
    } catch (_) {
      return 6;
    }
  }

  @override
  int schnorrBchSign(
    BuBytes sk,
    BuBytes hash32,
    BuBytes? extra,
    BuBytes out64,
  ) {
    try {
      return _okCopy(
        out64,
        BuWasmJS.schnorrBchSign(
          _toJs(sk),
          _toJs(hash32),
          extra == null ? null : _toJs(extra),
        ),
      );
    } catch (_) {
      return 6;
    }
  }

  @override
  int schnorrBchVerify(BuBytes pk, BuBytes hash32, BuBytes sig64) {
    try {
      return BuWasmJS.schnorrBchVerify(_toJs(pk), _toJs(hash32), _toJs(sig64))
          ? 0
          : 1;
    } catch (_) {
      return 6;
    }
  }

  @override
  int ecdsaR1PublicKey(BuBytes sk, BuBytes out33) {
    try {
      return _okCopy(out33, BuWasmJS.ecdsaR1PublicKey(_toJs(sk)));
    } catch (_) {
      return 6;
    }
  }

  @override
  int ecdsaR1Sign(BuBytes sk, BuBytes hash32, BuBytes out64) {
    try {
      return _okCopy(out64, BuWasmJS.ecdsaR1Sign(_toJs(sk), _toJs(hash32)));
    } catch (_) {
      return 6;
    }
  }

  @override
  int ecdsaR1SignEx(BuBytes sk, BuBytes hash32, BuBytes? extra, BuBytes out64) {
    try {
      return _okCopy(
        out64,
        BuWasmJS.ecdsaR1SignEx(
          _toJs(sk),
          _toJs(hash32),
          extra == null ? null : _toJs(extra),
        ),
      );
    } catch (_) {
      return 6;
    }
  }

  @override
  int ecdsaR1Verify(BuBytes pk33, BuBytes hash32, BuBytes sig64) {
    try {
      return BuWasmJS.ecdsaR1Verify(_toJs(pk33), _toJs(hash32), _toJs(sig64))
          ? 0
          : 1;
    } catch (_) {
      return 6;
    }
  }

  @override
  int ecdsaR1Recover(BuBytes hash32, BuBytes sig64, int recId, BuBytes out33) {
    try {
      return _okCopy(
        out33,
        BuWasmJS.ecdsaR1Recover(_toJs(hash32), _toJs(sig64), recId),
      );
    } catch (_) {
      return 6;
    }
  }

  @override
  int ecdsaR1RecoveryId(
    BuBytes hash32,
    BuBytes sig64,
    BuBytes pk33,
    BuBytes outId1,
  ) {
    try {
      final id = BuWasmJS.ecdsaR1RecoveryId(
        _toJs(hash32),
        _toJs(sig64),
        _toJs(pk33),
      );
      if (outId1.isEmpty) {
        return 1;
      }
      outId1[0] = id;
      return 0;
    } catch (_) {
      return 6;
    }
  }

  @override
  int ed25519PublicKey(BuBytes sk, BuBytes out32) {
    try {
      return _okCopy(out32, BuWasmJS.ed25519PublicKey(_toJs(sk)));
    } catch (_) {
      return 6;
    }
  }

  @override
  int ed25519Sign(BuBytes sk, BuBytes msg, BuBytes out64) {
    try {
      return _okCopy(out64, BuWasmJS.ed25519Sign(_toJs(sk), _toJs(msg)));
    } catch (_) {
      return 6;
    }
  }

  @override
  int ed25519Verify(BuBytes pk32, BuBytes msg, BuBytes sig64) {
    try {
      return BuWasmJS.ed25519Verify(_toJs(pk32), _toJs(msg), _toJs(sig64))
          ? 0
          : 1;
    } catch (_) {
      return 6;
    }
  }

  // WASM JS glue exposes plain ed25519 only; variants stay unsupported here.
  @override
  int ed25519PublicKeyVariant(
    BuEd25519Variant variant,
    BuBytes sk,
    BuBytes out32,
  ) {
    try {
      return _okCopy(
        out32,
        BuWasmJS.ed25519PublicKeyVariant(variant.id, _toJs(sk)),
      );
    } catch (_) {
      return 6;
    }
  }

  @override
  int ed25519SignVariant(
    BuEd25519Variant variant,
    BuBytes sk,
    BuBytes msg,
    BuBytes out64,
  ) {
    try {
      return _okCopy(
        out64,
        BuWasmJS.ed25519SignVariant(variant.id, _toJs(sk), _toJs(msg)),
      );
    } catch (_) {
      return 6;
    }
  }

  @override
  int ed25519VerifyVariant(
    BuEd25519Variant variant,
    BuBytes pk32,
    BuBytes msg,
    BuBytes sig64,
  ) {
    try {
      return BuWasmJS.ed25519VerifyVariant(
            variant.id,
            _toJs(pk32),
            _toJs(msg),
            _toJs(sig64),
          )
          ? 0
          : 1;
    } catch (_) {
      return 6;
    }
  }

  // ---- BLS ----
  @override
  int blsPublicKeyG1(BuBytes sk, BuBytes out48) {
    try {
      return _okCopy(out48, BuWasmJS.blsSkToPkG1(_toJs(sk)));
    } catch (_) {
      return 6;
    }
  }

  @override
  int blsPublicKeyG2(BuBytes sk, BuBytes out96) {
    try {
      return _okCopy(out96, BuWasmJS.blsSkToPkG2(_toJs(sk)));
    } catch (_) {
      return 6;
    }
  }

  @override
  int blsSignMinPk(BuBytes sk, BuBytes msg, BuBytes? dst, BuBytes out96) {
    try {
      return _okCopy(
        out96,
        BuWasmJS.blsSignMinPk(
          _toJs(sk),
          _toJs(msg),
          _toJs(dst ?? BuBytes.zero(0)),
        ),
      );
    } catch (_) {
      return 6;
    }
  }

  @override
  int blsSignMinSig(BuBytes sk, BuBytes msg, BuBytes? dst, BuBytes out48) {
    try {
      return _okCopy(
        out48,
        BuWasmJS.blsSignMinSig(
          _toJs(sk),
          _toJs(msg),
          _toJs(dst ?? BuBytes.zero(0)),
        ),
      );
    } catch (_) {
      return 6;
    }
  }

  @override
  int blsVerifyMinPk(BuBytes pk48, BuBytes msg, BuBytes sig96, BuBytes? dst) {
    try {
      return BuWasmJS.blsVerifyMinPk(
            _toJs(pk48),
            _toJs(msg),
            _toJs(sig96),
            _toJs(dst ?? BuBytes.zero(0)),
          )
          ? 0
          : 1;
    } catch (_) {
      return 6;
    }
  }

  @override
  int blsVerifyMinSig(BuBytes pk96, BuBytes msg, BuBytes sig48, BuBytes? dst) {
    try {
      return BuWasmJS.blsVerifyMinSig(
            _toJs(pk96),
            _toJs(msg),
            _toJs(sig48),
            _toJs(dst ?? BuBytes.zero(0)),
          )
          ? 0
          : 1;
    } catch (_) {
      return 6;
    }
  }

  @override
  int blsAggregatePublicKeysG1(BuBytes pksConcat, BuBytes out48) {
    try {
      return _okCopy(out48, BuWasmJS.blsAggregatePksG1(_toJs(pksConcat)));
    } catch (_) {
      return 6;
    }
  }

  @override
  int blsAggregatePublicKeysG2(BuBytes pksConcat, BuBytes out96) {
    try {
      return _okCopy(out96, BuWasmJS.blsAggregatePksG2(_toJs(pksConcat)));
    } catch (_) {
      return 6;
    }
  }

  @override
  int blsAggregateSignaturesG1(BuBytes sigsConcat, BuBytes out48) {
    try {
      return _okCopy(out48, BuWasmJS.blsAggregateSigsG1(_toJs(sigsConcat)));
    } catch (_) {
      return 6;
    }
  }

  @override
  int blsAggregateSignaturesG2(BuBytes sigsConcat, BuBytes out96) {
    try {
      return _okCopy(out96, BuWasmJS.blsAggregateSigsG2(_toJs(sigsConcat)));
    } catch (_) {
      return 6;
    }
  }

  @override
  int blsFastAggregateVerifyMinPk(
    BuBytes apk48,
    BuBytes msg,
    BuBytes sig96,
    BuBytes? dst,
  ) {
    try {
      return BuWasmJS.blsFastAggregateVerifyMinPk(
            _toJs(apk48),
            _toJs(msg),
            _toJs(sig96),
            _toJs(dst ?? BuBytes.zero(0)),
          )
          ? 0
          : 1;
    } catch (_) {
      return 6;
    }
  }

  @override
  int blsFastAggregateVerifyMinSig(
    BuBytes apk96,
    BuBytes msg,
    BuBytes sig48,
    BuBytes? dst,
  ) {
    try {
      return BuWasmJS.blsFastAggregateVerifyMinSig(
            _toJs(apk96),
            _toJs(msg),
            _toJs(sig48),
            _toJs(dst ?? BuBytes.zero(0)),
          )
          ? 0
          : 1;
    } catch (_) {
      return 6;
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
    try {
      return BuWasmJS.blsAggregateVerifyMinPk(
            _toJs(pksConcat),
            _toJs(messagesBlob),
            messageCount,
            _toJs(sig),
            _toJs(dst ?? BuBytes.zero(0)),
          )
          ? 0
          : 1;
    } catch (_) {
      return 6;
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
    try {
      return BuWasmJS.blsAggregateVerifyMinSig(
            _toJs(pksConcat),
            _toJs(messagesBlob),
            messageCount,
            _toJs(sig),
            _toJs(dst ?? BuBytes.zero(0)),
          )
          ? 0
          : 1;
    } catch (_) {
      return 6;
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
    try {
      return BuWasmJS.blsBatchVerifyMinPk(
            _toJs(pksConcat),
            _toJs(messagesBlob),
            messageCount,
            _toJs(sigsConcat),
            _toJs(dst ?? BuBytes.zero(0)),
          )
          ? 0
          : 1;
    } catch (_) {
      return 6;
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
    try {
      return BuWasmJS.blsBatchVerifyMinSig(
            _toJs(pksConcat),
            _toJs(messagesBlob),
            messageCount,
            _toJs(sigsConcat),
            _toJs(dst ?? BuBytes.zero(0)),
          )
          ? 0
          : 1;
    } catch (_) {
      return 6;
    }
  }

  // ---- MuSig2 ----
  @override
  int musig2KeyAgg(BuBytes keysConcat, int nKeys, BuBytes out33) {
    try {
      return _okCopy(out33, BuWasmJS.musig2KeyAgg(_toJs(keysConcat), nKeys));
    } catch (_) {
      return 6;
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
    try {
      return _okCopy(
        out33,
        BuWasmJS.musig2KeyAggTweak(
          _toJs(keysConcat),
          nKeys,
          _toJs(tweaksConcat),
          nTweaks,
        ),
      );
    } catch (_) {
      return 6;
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
    try {
      // Flat secnonce(97) ++ pubnonce(66); split by the out-buffer lengths.
      final flat = _fromJs(
        BuWasmJS.musig2NonceGen(
          sk == null ? _toJs(BuBytes.zero(32)) : _toJs(sk),
          _toJs(publicKey),
          msg == null ? null : _toJs(msg),
          _toJs(rand),
        ),
      );
      if (flat.length != secnonceOut97.length + pubnonceOut66.length) {
        return 6;
      }
      _copyInto(
        secnonceOut97,
        BuBytes.from(flat.sublist(0, secnonceOut97.length)),
      );
      _copyInto(
        pubnonceOut66,
        BuBytes.from(flat.sublist(secnonceOut97.length)),
      );
      return 0;
    } catch (_) {
      return 6;
    }
  }

  @override
  @override
  int musig2VerifyAggregate({
    required BuBytes message,
    required BuBytes signature64,
    required BuBytes aggXOnly32,
  }) {
    try {
      final ok = BuWasmJS.musig2VerifyAggregate(
        _toJs(message),
        _toJs(signature64),
        _toJs(aggXOnly32),
      );
      return ok ? 0 : 4;
    } catch (_) {
      return 6;
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
    try {
      final blob = BuWasmJS.dkls23ImportSecrets(
        curveId,
        _toJs(secretsConcat),
        n,
      );
      outBlob.add(_fromJs(blob));
      return 0;
    } catch (_) {
      return 6;
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
    try {
      final blob = BuWasmJS.dkls23Dkg(
        curveId,
        _toJs(sid),
        n,
        t,
        _toJs(seedsConcat),
      );
      outBlob.add(_fromJs(blob));
      return 0;
    } catch (_) {
      return 6;
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
    try {
      return _okCopy(
        out64,
        BuWasmJS.dkls23Sign(
          curveId,
          _toJs(sid),
          _toJs(msgHash32),
          _toJs(sharesBlob),
          _toJs(seedsConcat),
        ),
      );
    } catch (_) {
      return 6;
    }
  }

  @override
  int dkls23Refresh({
    required BuBytes sid,
    required BuBytes sharesBlob,
    required BuBytes seedsConcat,
    required List<BuBytes> outBlob,
  }) {
    try {
      final blob = BuWasmJS.dkls23Refresh(
        _toJs(sid),
        _toJs(sharesBlob),
        _toJs(seedsConcat),
      );
      outBlob.add(_fromJs(blob));
      return 0;
    } catch (_) {
      return 6;
    }
  }

  @override
  int dkls23Verify({
    required int curveId,
    required BuBytes groupPk33,
    required BuBytes msgHash32,
    required BuBytes sig64,
  }) {
    try {
      final ok = BuWasmJS.dkls23Verify(
        curveId,
        _toJs(groupPk33),
        _toJs(msgHash32),
        _toJs(sig64),
      );
      return ok ? 0 : 4;
    } catch (_) {
      return 6;
    }
  }

  @override
  int dkls23AggKeys({
    required int curveId,
    required BuBytes membersConcat,
    required int n,
    required BuBytes out33,
  }) {
    try {
      return _okCopy(
        out33,
        BuWasmJS.dkls23AggPublicKeys(curveId, _toJs(membersConcat), n),
      );
    } catch (_) {
      return 6;
    }
  }

  @override
  int dkls23XOnly({
    required int curveId,
    required BuBytes groupPk33,
    required BuBytes out32,
  }) {
    try {
      return _okCopy(out32, BuWasmJS.dkls23XOnly(curveId, _toJs(groupPk33)));
    } catch (_) {
      return 6;
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
    try {
      final tw = tweaksConcat ?? BuBytes.zero(0);
      final r = rand; // nullable JS
      final combined = BuWasmJS.musig2DeterministicSign(
        _toJs(sk),
        _toJs(aggother66),
        _toJs(keysConcat),
        nKeys,
        _toJs(msg),
        _toJs(tw),
        nTweaks,
        r == null ? null : _toJs(r),
      );
      // 98 bytes: pubnonce 66 + partial 32
      final bytes = _fromJs(combined);
      if (bytes.length < 98) {
        return 6;
      }
      for (var i = 0; i < 66; i++) {
        pubnonceOut66[i] = bytes[i];
      }
      for (var i = 0; i < 32; i++) {
        partialOut32[i] = bytes[66 + i];
      }
      return 0;
    } catch (_) {
      return 6;
    }
  }

  @override
  int musig2NonceAgg(BuBytes pubnoncesConcat, int n, BuBytes out66) {
    try {
      return _okCopy(out66, BuWasmJS.musig2NonceAgg(_toJs(pubnoncesConcat), n));
    } catch (_) {
      return 6;
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
    try {
      return _okCopy(
        out32,
        BuWasmJS.musig2PartialSign(
          _toJs(secnonce),
          _toJs(sk),
          _toJs(keysConcat),
          nKeys,
          _toJs(aggnonce),
          _toJs(msg),
          tweaksConcat == null ? null : _toJs(tweaksConcat),
          nTweaks,
        ),
      );
    } catch (_) {
      return 6;
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
    try {
      return _okCopy(
        out64,
        BuWasmJS.musig2PartialSigAgg(
          _toJs(partialsConcat),
          nPartials,
          _toJs(keysConcat),
          nKeys,
          _toJs(aggnonce),
          _toJs(msg),
          tweaksConcat == null ? null : _toJs(tweaksConcat),
          nTweaks,
        ),
      );
    } catch (_) {
      return 6;
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
    try {
      return BuWasmJS.musig2PartialSigVerify(
            _toJs(partial),
            _toJs(pubnonce),
            _toJs(pk),
            _toJs(keysConcat),
            nKeys,
            _toJs(aggnonce),
            _toJs(msg),
            tweaksConcat == null ? null : _toJs(tweaksConcat),
            nTweaks,
          )
          ? 0
          : 4;
    } catch (_) {
      return 6;
    }
  }

  // ---- PQ ----
  @override
  int mldsaKeygen(int level, BuBytes seed, BuBytes pkOut, BuBytes skOut) {
    try {
      // Flat pk ++ sk; split by the out-buffer lengths.
      final flat = _fromJs(BuWasmJS.mldsaKeygen(level, _toJs(seed)));
      if (flat.length != pkOut.length + skOut.length) {
        return 6;
      }
      _copyInto(pkOut, BuBytes.from(flat.sublist(0, pkOut.length)));
      _copyInto(skOut, BuBytes.from(flat.sublist(pkOut.length)));
      return 0;
    } catch (_) {
      return 6;
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
    try {
      return _okCopy(
        sigOut,
        BuWasmJS.mldsaSign(
          level,
          _toJs(sk),
          _toJs(msg),
          rnd.isEmpty ? null : _toJs(rnd),
          context.isEmpty ? null : _toJs(context),
        ),
      );
    } catch (_) {
      return 6;
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
    try {
      return BuWasmJS.mldsaVerify(
            level,
            _toJs(pk),
            _toJs(msg),
            _toJs(sig),
            context.isEmpty ? null : _toJs(context),
          )
          ? 0
          : 5;
    } catch (_) {
      return 6;
    }
  }

  @override
  int mldsaPublicFromSecret(int level, BuBytes sk, BuBytes pkOut) {
    try {
      final pk = _fromJs(BuWasmJS.mldsaPkFromSk(level, _toJs(sk)));
      if (pk.length != pkOut.length) {
        return 6;
      }
      _copyInto(pkOut, pk);
      return 0;
    } catch (_) {
      return 6;
    }
  }

  @override
  int rngSeed(BuBytes seed32) {
    if (seed32.length != 32) {
      return 1;
    }
    return BuWasmJS.rngSeed(_toJs(seed32)) ? 0 : 2;
  }

  @override
  int rngIsSeeded() => BuWasmJS.rngIsSeeded() ? 1 : 0;

  @override
  int rngFill(BuBytes out) {
    if (out.isEmpty) {
      return 1;
    }
    final r = _fromJs(BuWasmJS.rngFill(out.length));
    _copyInto(out, r);
    return 0;
  }

  // —— Generic curve compression ——
  @override
  int curvePointUncompressedLen(int curveId) {
    try {
      return BuWasmJS.curvePointUncompressedLen(curveId);
    } catch (_) {
      return 0;
    }
  }

  int _curveConvert(JSUint8Array Function() call, BuBytes out) {
    try {
      final r = _fromJs(call());
      if (r.length != out.length) {
        return 2;
      }
      _copyInto(out, r);
      return 0;
    } catch (_) {
      return 6;
    }
  }

  @override
  int curveCompress(int curveId, BuBytes point, BuBytes out) {
    return _curveConvert(
      () => BuWasmJS.curveCompress(curveId, _toJs(point)),
      out,
    );
  }

  @override
  int curveUncompress(int curveId, BuBytes point, BuBytes out) {
    return _curveConvert(
      () => BuWasmJS.curveUncompress(curveId, _toJs(point)),
      out,
    );
  }

  @override
  int curveNormalizePubkey(int curveId, BuBytes point, BuBytes out) {
    return _curveConvert(
      () => BuWasmJS.curveNormalizePubkey(curveId, _toJs(point)),
      out,
    );
  }

  // —— Hardware-wallet codecs (throws → 6, same as missing native) ——

  int _hwTake(BuBytes out, JSUint8Array js) {
    final r = _fromJs(js);
    if (r.length > out.length) {
      return 2;
    }
    _copyInto(out, r);
    return r.length;
  }

  int _hwTakeStr(BuBytes out, String s) {
    final units = s.codeUnits;
    if (units.length > out.length) {
      return 2;
    }
    for (var i = 0; i < units.length; i++) {
      out[i] = units[i] & 0xFF;
    }
    return units.length;
  }

  static String _jsStr(BuBytes b) => String.fromCharCodes(b);

  static String _idCurve(int c) {
    if (c == 1) {
      return 'secp256k1';
    }
    if (c == 2) {
      return 'nist256p1';
    }
    return '';
  }

  @override
  int hwSupportsCoin(int device, int coin) {
    try {
      return BuWasmJS.hwSupportsCoin(device, coin) ? 1 : 0;
    } catch (_) {
      return 6;
    }
  }

  @override
  int hwIsAirgap(int device) {
    try {
      return BuWasmJS.hwIsAirgap(device) ? 1 : 0;
    } catch (_) {
      return 6;
    }
  }

  @override
  int hwParsePath(String path, BuBytes out) {
    try {
      return _hwTake(out, BuWasmJS.hwParsePath(path));
    } catch (_) {
      return 6;
    }
  }

  @override
  int hwValidatePath(int device, int coin, BuBytes pathU32) {
    try {
      BuWasmJS.hwValidatePath(device, coin, _toJs(pathU32));
      return 0;
    } catch (_) {
      return 6;
    }
  }

  @override
  int hwGetAddressRequest(int device, int coin, BuBytes pathU32, BuBytes out) {
    try {
      return _hwTake(
        out,
        BuWasmJS.hwGetAddressRequest(device, coin, _toJs(pathU32)),
      );
    } catch (_) {
      return 6;
    }
  }

  @override
  int hwParseAddressResponse(int device, BuBytes response, BuBytes out) {
    try {
      return _hwTake(
        out,
        BuWasmJS.hwParseAddressResponse(device, _toJs(response)),
      );
    } catch (_) {
      return 6;
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
    try {
      return _hwTake(
        out,
        BuWasmJS.hwSignRequest(device, coin, _toJs(pathU32), _toJs(payload)),
      );
    } catch (_) {
      return 6;
    }
  }

  @override
  int hwParseSignResponse(int device, BuBytes response, BuBytes out) {
    try {
      return _hwTake(
        out,
        BuWasmJS.hwParseSignResponse(device, _toJs(response)),
      );
    } catch (_) {
      return 6;
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
    try {
      return _hwTake(
        out,
        BuWasmJS.hwSignTxStart(device, coin, inputsCount, outputsCount),
      );
    } catch (_) {
      return 6;
    }
  }

  @override
  int hwParseTxRequest(int device, BuBytes response, BuBytes out) {
    try {
      return _hwTake(out, BuWasmJS.hwParseTxRequest(device, _toJs(response)));
    } catch (_) {
      return 6;
    }
  }

  @override
  int hwTxRequestSignature(int device, BuBytes response, BuBytes out) {
    try {
      return _hwTake(
        out,
        BuWasmJS.hwTxRequestSignature(device, _toJs(response)),
      );
    } catch (_) {
      return 6;
    }
  }

  @override
  int hwTxRequestSerialized(int device, BuBytes response, BuBytes out) {
    try {
      return _hwTake(
        out,
        BuWasmJS.hwTxRequestSerialized(device, _toJs(response)),
      );
    } catch (_) {
      return 6;
    }
  }

  @override
  int hwTxRequestTxHash(int device, BuBytes response, BuBytes out) {
    try {
      return _hwTake(out, BuWasmJS.hwTxRequestTxHash(device, _toJs(response)));
    } catch (_) {
      return 6;
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
    try {
      return _hwTake(
        out,
        BuWasmJS.hwTxAckMeta(version, lockTime, inputsCount, outputsCount),
      );
    } catch (_) {
      return 6;
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
    try {
      return _hwTake(
        out,
        BuWasmJS.hwTxAckInput(
          _toJs(prevHash32),
          prevIndex,
          _toJs(pathU32),
          (amountSat >> 32) & 0xFFFFFFFF,
          amountSat & 0xFFFFFFFF,
          _toJs(scriptSig),
          scriptType,
        ),
      );
    } catch (_) {
      return 6;
    }
  }

  @override
  int hwTxAckOutput(
    String address,
    int amountSat,
    int scriptType,
    BuBytes out,
  ) {
    try {
      return _hwTake(
        out,
        BuWasmJS.hwTxAckOutput(
          address,
          (amountSat >> 32) & 0xFFFFFFFF,
          amountSat & 0xFFFFFFFF,
          scriptType,
        ),
      );
    } catch (_) {
      return 6;
    }
  }

  @override
  int hwTxAckChange(
    BuBytes pathU32,
    int amountSat,
    int scriptType,
    BuBytes out,
  ) {
    try {
      return _hwTake(
        out,
        BuWasmJS.hwTxAckChange(
          _toJs(pathU32),
          (amountSat >> 32) & 0xFFFFFFFF,
          amountSat & 0xFFFFFFFF,
          scriptType,
        ),
      );
    } catch (_) {
      return 6;
    }
  }

  @override
  int hwTxAckBinOutput(BuBytes scriptPubKey, int amountSat, BuBytes out) {
    try {
      return _hwTake(
        out,
        BuWasmJS.hwTxAckBinOutput(
          _toJs(scriptPubKey),
          (amountSat >> 32) & 0xFFFFFFFF,
          amountSat & 0xFFFFFFFF,
        ),
      );
    } catch (_) {
      return 6;
    }
  }

  @override
  int hwBitBoxHsNew(BuBytes staticPriv32, BuBytes ephemeralPriv32) {
    // WASM keeps the session in process-global slot 1 like the FFI
    // backend (void return): success reports the slot handle, throws map
    // to 6 — matching what `DefaultHwApi.bitboxHsNew` expects.
    try {
      BuWasmJS.hwBitBoxHsNew(_toJs(staticPriv32), _toJs(ephemeralPriv32));
      return 1;
    } catch (_) {
      return 6;
    }
  }

  @override
  int hwBitBoxHsM1(BuBytes out32) {
    try {
      return _hwTake(out32, BuWasmJS.hwBitBoxHsM1());
    } catch (_) {
      return 6;
    }
  }

  @override
  int hwBitBoxHsM2(BuBytes m2) {
    try {
      BuWasmJS.hwBitBoxHsM2(_toJs(m2));
      return 0;
    } catch (_) {
      return 6;
    }
  }

  @override
  int hwBitBoxHsM3(BuBytes out64) {
    try {
      return _hwTake(out64, BuWasmJS.hwBitBoxHsM3());
    } catch (_) {
      return 6;
    }
  }

  @override
  int hwBitBoxHsSplit() {
    try {
      BuWasmJS.hwBitBoxHsSplit();
      return 0;
    } catch (_) {
      return 6;
    }
  }

  @override
  int hwBitBoxEncrypt(BuBytes plaintext, BuBytes out) {
    try {
      return _hwTake(out, BuWasmJS.hwBitBoxEncrypt(_toJs(plaintext)));
    } catch (_) {
      return 6;
    }
  }

  @override
  int hwBitBoxDecrypt(BuBytes ciphertext, BuBytes out) {
    try {
      return _hwTake(out, BuWasmJS.hwBitBoxDecrypt(_toJs(ciphertext)));
    } catch (_) {
      return 6;
    }
  }

  @override
  int hwBitBoxHsHash(BuBytes out32) {
    try {
      return _hwTake(out32, BuWasmJS.hwBitBoxHsHash());
    } catch (_) {
      return 6;
    }
  }

  @override
  int hwBitBoxFree() {
    try {
      BuWasmJS.hwBitBoxFree();
      return 0;
    } catch (_) {
      return 6;
    }
  }

  @override
  int hwBitBoxBtcPubRequest(
    int coin,
    BuBytes pathU32,
    int xpubType,
    bool display,
    BuBytes out,
  ) {
    try {
      return _hwTake(
        out,
        BuWasmJS.hwBitBoxBtcPubRequest(coin, _toJs(pathU32), xpubType, display),
      );
    } catch (_) {
      return 6;
    }
  }

  @override
  int hwBitBoxPubParse(BuBytes response, BuBytes out) {
    try {
      return _hwTakeStr(out, BuWasmJS.hwBitBoxPubParse(_toJs(response)));
    } catch (_) {
      return 6;
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
    try {
      return _hwTake(
        out,
        BuWasmJS.hwBitBoxSignInit(
          coin,
          _toJs(pathU32),
          simpleType,
          version,
          inputsCount,
          outputsCount,
          locktime,
        ),
      );
    } catch (_) {
      return 6;
    }
  }

  @override
  int hwBitBoxSignNextParse(BuBytes response, BuBytes out) {
    try {
      return _hwTake(out, BuWasmJS.hwBitBoxSignNextParse(_toJs(response)));
    } catch (_) {
      return 6;
    }
  }

  @override
  int hwBitBoxSignNextSignature(BuBytes response, BuBytes out) {
    try {
      return _hwTake(out, BuWasmJS.hwBitBoxSignNextSignature(_toJs(response)));
    } catch (_) {
      return 6;
    }
  }

  @override
  int hwBitBoxSignNextPrevIndex(BuBytes response) {
    // -7 on host failure (never a valid index: those are 0..0xFFFFFFFF).
    try {
      final tmp = BuBytes.zero(4);
      final rc = _hwTake(
        tmp,
        BuWasmJS.hwBitBoxSignNextPrevIndex(_toJs(response)),
      );
      if (rc != 4) {
        return -7;
      }
      return tmp[0] | (tmp[1] << 8) | (tmp[2] << 16) | (tmp[3] << 24);
    } catch (_) {
      return -7;
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
    try {
      return _hwTake(
        out,
        BuWasmJS.hwBitBoxSignInput(
          _toJs(prevHash32),
          prevIndex,
          (amountSat >> 32) & 0xFFFFFFFF,
          amountSat & 0xFFFFFFFF,
          sequence,
          _toJs(pathU32),
          scriptConfigIndex,
        ),
      );
    } catch (_) {
      return 6;
    }
  }

  @override
  int hwBitBoxSignOutput(
    int outputType,
    int amountSat,
    BuBytes payload,
    BuBytes out,
  ) {
    try {
      return _hwTake(
        out,
        BuWasmJS.hwBitBoxSignOutput(
          outputType,
          (amountSat >> 32) & 0xFFFFFFFF,
          amountSat & 0xFFFFFFFF,
          _toJs(payload),
        ),
      );
    } catch (_) {
      return 6;
    }
  }

  @override
  int hwBitBoxSignChange(
    BuBytes pathU32,
    int amountSat,
    int scriptConfigIndex,
    BuBytes out,
  ) {
    try {
      return _hwTake(
        out,
        BuWasmJS.hwBitBoxSignChange(
          _toJs(pathU32),
          (amountSat >> 32) & 0xFFFFFFFF,
          amountSat & 0xFFFFFFFF,
          scriptConfigIndex,
        ),
      );
    } catch (_) {
      return 6;
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
    try {
      return _hwTake(
        out,
        BuWasmJS.hwBitBoxSignPrevtxInit(
          version,
          inputsCount,
          outputsCount,
          locktime,
        ),
      );
    } catch (_) {
      return 6;
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
    try {
      return _hwTake(
        out,
        BuWasmJS.hwBitBoxSignPrevtxInput(
          _toJs(prevHash32),
          prevIndex,
          _toJs(scriptSig),
          sequence,
        ),
      );
    } catch (_) {
      return 6;
    }
  }

  @override
  int hwBitBoxSignPrevtxOutput(int amountSat, BuBytes script, BuBytes out) {
    try {
      return _hwTake(
        out,
        BuWasmJS.hwBitBoxSignPrevtxOutput(
          (amountSat >> 32) & 0xFFFFFFFF,
          amountSat & 0xFFFFFFFF,
          _toJs(script),
        ),
      );
    } catch (_) {
      return 6;
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
    try {
      return _hwTake(
        out,
        BuWasmJS.hwIdentityEncode(
          _jsStr(proto),
          _jsStr(user),
          _jsStr(host),
          _jsStr(port),
          _jsStr(path),
          index,
        ),
      );
    } catch (_) {
      return 6;
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
    try {
      return _hwTake(
        out,
        BuWasmJS.hwSignIdentityRequest(
          _toJs(identity),
          _toJs(hidden),
          _jsStr(visual),
          _idCurve(curve),
        ),
      );
    } catch (_) {
      return 6;
    }
  }

  @override
  int hwSignedIdentityAddress(BuBytes response, BuBytes out) {
    try {
      return _hwTakeStr(out, BuWasmJS.hwSignedIdentityAddress(_toJs(response)));
    } catch (_) {
      return 6;
    }
  }

  @override
  int hwSignedIdentityPubkey(BuBytes response, BuBytes out) {
    try {
      return _hwTake(out, BuWasmJS.hwSignedIdentityPubkey(_toJs(response)));
    } catch (_) {
      return 6;
    }
  }

  @override
  int hwSignedIdentitySignature(BuBytes response, BuBytes out) {
    try {
      return _hwTake(out, BuWasmJS.hwSignedIdentitySignature(_toJs(response)));
    } catch (_) {
      return 6;
    }
  }

  @override
  int hwLedgerFingerprint(BuBytes out) {
    try {
      return _hwTake(out, BuWasmJS.hwLedgerFingerprint());
    } catch (_) {
      return 6;
    }
  }

  @override
  int hwLedgerFingerprintParse(BuBytes response, BuBytes out) {
    try {
      return _hwTake(out, BuWasmJS.hwLedgerFingerprintParse(_toJs(response)));
    } catch (_) {
      return 6;
    }
  }

  @override
  int hwQrRequest(int device, int coin, BuBytes pathU32, BuBytes out) {
    try {
      return _hwTakeStr(
        out,
        BuWasmJS.hwQrRequest(device, coin, _toJs(pathU32)),
      );
    } catch (_) {
      return 6;
    }
  }

  @override
  int hwQrParse(int device, String qr, BuBytes out) {
    try {
      return _hwTake(out, BuWasmJS.hwQrParse(device, qr));
    } catch (_) {
      return 6;
    }
  }

  @override
  int hwPsbtCounts(BuBytes psbt, BuBytes out8) {
    try {
      final r = _fromJs(BuWasmJS.hwPsbtCounts(_toJs(psbt)));
      if (out8.length < 8 || r.length != 8) {
        return 2;
      }
      _copyInto(out8, r);
      return 0;
    } catch (_) {
      return 6;
    }
  }

  @override
  int hwUrEncode(String type, BuBytes payload, BuBytes out) {
    try {
      return _hwTakeStr(out, BuWasmJS.hwUrEncode(type, _toJs(payload)));
    } catch (_) {
      return 6;
    }
  }

  @override
  int hwUrDecodePayload(String ur, BuBytes out) {
    try {
      return _hwTake(out, BuWasmJS.hwUrDecodePayload(ur));
    } catch (_) {
      return 6;
    }
  }

  @override
  int hwUrDecodeType(String ur, BuBytes out) {
    try {
      return _hwTakeStr(out, BuWasmJS.hwUrDecodeType(ur));
    } catch (_) {
      return 6;
    }
  }

  @override
  int hwHidFrame(BuBytes payload, int channel, int tag, BuBytes out) {
    try {
      return _hwTake(out, BuWasmJS.hwHidFrame(_toJs(payload), channel, tag));
    } catch (_) {
      return 6;
    }
  }

  @override
  int hwHidUnframe(BuBytes reports, int channel, int tag, BuBytes out) {
    try {
      return _hwTake(out, BuWasmJS.hwHidUnframe(_toJs(reports), channel, tag));
    } catch (_) {
      return 6;
    }
  }

  int _reddsaPk(
    JSUint8Array Function(JSUint8Array) f,
    BuBytes sk,
    BuBytes pkOut,
  ) {
    if (sk.length != 32 || pkOut.length < 32) {
      return 1;
    }
    try {
      return _okCopy(pkOut, f(_toJs(sk)));
    } catch (_) {
      return 1;
    }
  }

  int _reddsaSign(
    JSUint8Array Function(JSUint8Array, JSUint8Array, JSUint8Array?) f,
    BuBytes sk,
    BuBytes msg,
    BuBytes rand80,
    BuBytes sigOut,
  ) {
    if (sk.length != 32 || sigOut.length < 64) {
      return 1;
    }
    try {
      final r = rand80.isEmpty ? null : _toJs(rand80);
      return _okCopy(sigOut, f(_toJs(sk), _toJs(msg), r));
    } catch (_) {
      return 1;
    }
  }

  int _reddsaVerify(
    bool Function(JSUint8Array, JSUint8Array, JSUint8Array) f,
    BuBytes pk,
    BuBytes msg,
    BuBytes sig,
  ) {
    if (pk.length != 32 || sig.length != 64) {
      return 1;
    }
    try {
      return f(_toJs(pk), _toJs(msg), _toJs(sig)) ? 0 : 14;
    } catch (_) {
      return 1;
    }
  }

  @override
  int reddsaJubjubAuthPk(BuBytes sk, BuBytes pkOut32) =>
      _reddsaPk((a) => BuWasmJS.reddsaJubjubAuthPk(a), sk, pkOut32);
  @override
  int reddsaJubjubBindingPk(BuBytes sk, BuBytes pkOut32) =>
      _reddsaPk((a) => BuWasmJS.reddsaJubjubBindingPk(a), sk, pkOut32);
  @override
  int reddsaPallasAuthPk(BuBytes sk, BuBytes pkOut32) =>
      _reddsaPk((a) => BuWasmJS.reddsaPallasAuthPk(a), sk, pkOut32);
  @override
  int reddsaPallasBindingPk(BuBytes sk, BuBytes pkOut32) =>
      _reddsaPk((a) => BuWasmJS.reddsaPallasBindingPk(a), sk, pkOut32);

  @override
  int reddsaJubjubAuthSign(
    BuBytes sk,
    BuBytes msg,
    BuBytes rand80,
    BuBytes sigOut64,
  ) => _reddsaSign(
    (a, b, c) => BuWasmJS.reddsaJubjubAuthSign(a, b, c),
    sk,
    msg,
    rand80,
    sigOut64,
  );
  @override
  int reddsaJubjubAuthVerify(BuBytes pk, BuBytes msg, BuBytes sig64) =>
      _reddsaVerify(
        (a, b, c) => BuWasmJS.reddsaJubjubAuthVerify(a, b, c),
        pk,
        msg,
        sig64,
      );
  @override
  int reddsaJubjubBindingSign(
    BuBytes sk,
    BuBytes msg,
    BuBytes rand80,
    BuBytes sigOut64,
  ) => _reddsaSign(
    (a, b, c) => BuWasmJS.reddsaJubjubBindingSign(a, b, c),
    sk,
    msg,
    rand80,
    sigOut64,
  );
  @override
  int reddsaJubjubBindingVerify(BuBytes pk, BuBytes msg, BuBytes sig64) =>
      _reddsaVerify(
        (a, b, c) => BuWasmJS.reddsaJubjubBindingVerify(a, b, c),
        pk,
        msg,
        sig64,
      );
  @override
  int reddsaPallasAuthSign(
    BuBytes sk,
    BuBytes msg,
    BuBytes rand80,
    BuBytes sigOut64,
  ) => _reddsaSign(
    (a, b, c) => BuWasmJS.reddsaPallasAuthSign(a, b, c),
    sk,
    msg,
    rand80,
    sigOut64,
  );
  @override
  int reddsaPallasAuthVerify(BuBytes pk, BuBytes msg, BuBytes sig64) =>
      _reddsaVerify(
        (a, b, c) => BuWasmJS.reddsaPallasAuthVerify(a, b, c),
        pk,
        msg,
        sig64,
      );
  @override
  int reddsaPallasBindingSign(
    BuBytes sk,
    BuBytes msg,
    BuBytes rand80,
    BuBytes sigOut64,
  ) => _reddsaSign(
    (a, b, c) => BuWasmJS.reddsaPallasBindingSign(a, b, c),
    sk,
    msg,
    rand80,
    sigOut64,
  );
  @override
  int reddsaPallasBindingVerify(BuBytes pk, BuBytes msg, BuBytes sig64) =>
      _reddsaVerify(
        (a, b, c) => BuWasmJS.reddsaPallasBindingVerify(a, b, c),
        pk,
        msg,
        sig64,
      );
  @override
  int poseidonHashTwo(BuBytes a, BuBytes b, BuBytes out32) {
    try {
      return _okCopy(out32, BuWasmJS.poseidonHashTwo(_toJs(a), _toJs(b)));
    } catch (_) {
      return 6;
    }
  }

  @override
  int poseidonHash(List<BuBytes> inputs, BuBytes out32) {
    try {
      final n = inputs.length;
      final flat = BuBytes.zero(n * 32);
      for (var i = 0; i < n; i++) {
        final src = inputs[i];
        for (var j = 0; j < 32 && j < src.length; j++) {
          flat[i * 32 + j] = src[j];
        }
      }
      return _okCopy(out32, BuWasmJS.poseidonHash(_toJs(flat)));
    } catch (_) {
      return 6;
    }
  }

  @override
  int poseidonBn254Hash(List<BuBytes> inputs, BuBytes out32) {
    try {
      final n = inputs.length;
      final flat = BuBytes.zero(n * 32);
      for (var i = 0; i < n; i++) {
        final src = inputs[i];
        for (var j = 0; j < 32 && j < src.length; j++) {
          flat[i * 32 + j] = src[j];
        }
      }
      return _okCopy(out32, BuWasmJS.poseidonBn254Hash(_toJs(flat)));
    } catch (_) {
      return 6;
    }
  }

  @override
  int sinsemillaHashBits(
    String domain,
    BuBytes packedBits,
    int bitLen,
    BuBytes out32,
  ) {
    try {
      final dom = BuBytes(List<int>.from(domain.codeUnits));
      return _okCopy(
        out32,
        BuWasmJS.sinsemillaHashBits(_toJs(dom), _toJs(packedBits), bitLen),
      );
    } catch (_) {
      return 6;
    }
  }

  @override
  int sinsemillaCommit(
    String domain,
    BuBytes packedBits,
    int bitLen,
    BuBytes r32,
    BuBytes out32,
  ) {
    try {
      final dom = BuBytes(List<int>.from(domain.codeUnits));
      return _okCopy(
        out32,
        BuWasmJS.sinsemillaCommit(
          _toJs(dom),
          _toJs(packedBits),
          bitLen,
          _toJs(r32),
        ),
      );
    } catch (_) {
      return 6;
    }
  }

  @override
  int sinsemillaShortCommit(
    String domain,
    BuBytes packedBits,
    int bitLen,
    BuBytes r32,
    BuBytes out32,
  ) {
    try {
      final dom = BuBytes(List<int>.from(domain.codeUnits));
      return _okCopy(
        out32,
        BuWasmJS.sinsemillaShortCommit(
          _toJs(dom),
          _toJs(packedBits),
          bitLen,
          _toJs(r32),
        ),
      );
    } catch (_) {
      return 6;
    }
  }

  @override
  int poseidonPermute(BuBytes state96) {
    try {
      if (state96.length < 96) {
        return 2;
      }
      return _okCopy(state96, BuWasmJS.poseidonPermute(_toJs(state96)));
    } catch (_) {
      return 6;
    }
  }

  @override
  int sinsemillaHashBitstring(String domain, String bits01, BuBytes out32) {
    try {
      final dom = BuBytes(List<int>.from(domain.codeUnits));
      final bits = BuBytes(List<int>.from(bits01.codeUnits));
      return _okCopy(
        out32,
        BuWasmJS.sinsemillaHashBitstring(_toJs(dom), _toJs(bits)),
      );
    } catch (_) {
      return 6;
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
    try {
      return _okCopy(
        out32,
        BuWasmJS.pedersenHash(personal, layer, _toJs(packedBits), bitLen),
      );
    } catch (_) {
      return 6;
    }
  }

  @override
  int pedersenHashBitstring(
    int personal,
    int layer,
    String bits01,
    BuBytes out32,
  ) {
    try {
      final bits = BuBytes(List<int>.from(bits01.codeUnits));
      return _okCopy(
        out32,
        BuWasmJS.pedersenHashBitstring(personal, layer, _toJs(bits)),
      );
    } catch (_) {
      return 6;
    }
  }

  @override
  int groth16VerifyBls({
    required BuBytes proof,
    required BuBytes vk,
    required BuBytes publicInputs,
  }) {
    try {
      return BuWasmJS.groth16VerifyBls(
            _toJs(proof),
            _toJs(vk),
            _toJs(publicInputs),
          )
          ? 0
          : 5;
    } catch (_) {
      return 6;
    }
  }

  @override
  int groth16VerifyBn254({
    required BuBytes proof,
    required BuBytes vk,
    required BuBytes publicInputs,
  }) {
    try {
      return BuWasmJS.groth16VerifyBn254(
            _toJs(proof),
            _toJs(vk),
            _toJs(publicInputs),
          )
          ? 0
          : 5;
    } catch (_) {
      return 6;
    }
  }

  @override
  int groth16BlsProofLen() {
    try {
      return BuWasmJS.groth16BlsProofLen();
    } catch (_) {
      return 192;
    }
  }

  @override
  int groth16Bn254ProofLen() {
    try {
      return BuWasmJS.groth16Bn254ProofLen();
    } catch (_) {
      return 256;
    }
  }

  @override
  int zkVersion() {
    try {
      return BuWasmJS.zkVersion();
    } catch (_) {
      return 1;
    }
  }

  @override
  int zkEnableLogging(int enable, int mode) {
    try {
      return BuWasmJS.zkEnableLogging(enable, mode);
    } catch (_) {
      return 0;
    }
  }

  @override
  int backendVersion() {
    try {
      return BuWasmJS.backendVersion();
    } catch (_) {
      return 0;
    }
  }

  @override
  int backendFeatures() {
    try {
      return BuWasmJS.backendFeatures();
    } catch (_) {
      return 0;
    }
  }

  @override
  int saplingSetSpendParams(BuBytes params, List<Object?> outHandle) {
    try {
      outHandle[0] = BuWasmJS.saplingSetSpendParams(_toJs(params));
      return 0;
    } catch (_) {
      return 3;
    }
  }

  @override
  int saplingSetOutputParams(BuBytes params, List<Object?> outHandle) {
    try {
      outHandle[0] = BuWasmJS.saplingSetOutputParams(_toJs(params));
      return 0;
    } catch (_) {
      return 3;
    }
  }

  @override
  void saplingParamsFree(Object handle) {
    try {
      BuWasmJS.saplingParamsFree(handle as int);
    } catch (_) {}
  }

  @override
  int saplingProve(
    Object handle,
    int kind,
    BuBytes witness,
    BuBytes outProof,
    BuBytes outInputs,
  ) {
    try {
      final packed = _fromJs(
        BuWasmJS.saplingProve(handle as int, kind, _toJs(witness)),
      );
      if (packed.length < 4) {
        return 2;
      }
      final proofLen =
          packed[0] | (packed[1] << 8) | (packed[2] << 16) | (packed[3] << 24);
      if (packed.length < 4 + proofLen) {
        return 2;
      }
      if (proofLen != outProof.length) {
        return 2;
      }
      final inputs = packed.sublist(4 + proofLen);
      if (inputs.length != outInputs.length) {
        return 2;
      }
      _copyInto(outProof, BuBytes.from(packed.sublist(4, 4 + proofLen)));
      _copyInto(outInputs, BuBytes.from(inputs));
      return 0;
    } catch (_) {
      return 6;
    }
  }

  @override
  int saplingVerify({
    required Object handle,
    required int kind,
    required BuBytes proof,
    required BuBytes inputs,
  }) {
    try {
      final ok = BuWasmJS.saplingVerify(
        handle as int,
        kind,
        _toJs(proof),
        _toJs(inputs),
      );
      return ok ? 0 : 5;
    } catch (_) {
      return 6;
    }
  }

  @override
  int orchardPkNew(int version, List<Object?> outPk) {
    try {
      outPk[0] = BuWasmJS.orchardPkNew(version);
      return 0;
    } catch (_) {
      return 3;
    }
  }

  @override
  void orchardPkFree(Object pk) {
    try {
      BuWasmJS.orchardPkFree(pk as int);
    } catch (_) {}
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
    try {
      final proof = _fromJs(
        BuWasmJS.orchardCreateProof(
          pk as int,
          _toJs(inputs),
          _toJs(instances),
          version,
          disableCrossAddress,
          _toJs(seed),
        ),
      );
      outProof.add(proof);
      return 0;
    } catch (_) {
      return 6;
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
    try {
      final ok = BuWasmJS.orchardVerifyProof(
        pk as int,
        _toJs(proof),
        _toJs(instances),
        version,
        disableCrossAddress,
      );
      return ok ? 0 : 5;
    } catch (_) {
      return 6;
    }
  }

  @override
  int merkleCreateContext() {
    try {
      final id = BuWasmJS.merkleCreateContext();
      return id == 0 ? 0 : id;
    } catch (_) {
      return 0;
    }
  }

  @override
  int merkleCloseContext(int id) {
    try {
      return BuWasmJS.merkleCloseContext(id) ? 0 : 8;
    } catch (_) {
      return 8;
    }
  }

  @override
  int merkleGetContext(int id, List<BuBytes> outBlob) {
    try {
      outBlob.add(_fromJs(BuWasmJS.merkleGetContext(id)));
      return 0;
    } catch (_) {
      return 8;
    }
  }

  // ---- Monero Bulletproofs+ ----
  @override
  int moneroBpPlusVerify(BuBytes packed) {
    try {
      return BuWasmJS.moneroBpPlusVerify(_toJs(packed)) ? 0 : 1;
    } catch (_) {
      return -3;
    }
  }

  @override
  int moneroBpPlusProveAmounts({
    required List<BuBytes> amountsLe,
    required List<BuBytes> gamma,
    required BuBytes seed32,
    required List<BuBytes> outBlob,
  }) {
    try {
      final a = Uint8List(amountsLe.length * 8);
      for (var i = 0; i < amountsLe.length; i++) {
        a.setRange(i * 8, (i + 1) * 8, amountsLe[i]);
      }
      final g = Uint8List(gamma.length * 32);
      for (var i = 0; i < gamma.length; i++) {
        g.setRange(i * 32, (i + 1) * 32, gamma[i]);
      }
      outBlob.add(
        _fromJs(
          BuWasmJS.moneroBpPlusProveAmounts(a.toJS, g.toJS, _toJs(seed32)),
        ),
      );
      return 0;
    } catch (_) {
      return -5;
    }
  }

  @override
  int moneroBpPlusProveScalars({
    required List<BuBytes> sv,
    required List<BuBytes> gamma,
    required BuBytes seed32,
    required List<BuBytes> outBlob,
  }) {
    try {
      final s = Uint8List(sv.length * 32);
      for (var i = 0; i < sv.length; i++) {
        s.setRange(i * 32, (i + 1) * 32, sv[i]);
      }
      final g = Uint8List(gamma.length * 32);
      for (var i = 0; i < gamma.length; i++) {
        g.setRange(i * 32, (i + 1) * 32, gamma[i]);
      }
      outBlob.add(
        _fromJs(
          BuWasmJS.moneroBpPlusProveScalars(s.toJS, g.toJS, _toJs(seed32)),
        ),
      );
      return 0;
    } catch (_) {
      return -5;
    }
  }

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
    try {
      outBlob.add(
        _fromJs(
          BuWasmJS.moneroUnlockBatch(
            _toJs(viewSecrets),
            _toJs(spendPubs),
            _toJs(spendCountsLe),
            _toJs(outKeys),
            _toJs(txPubs),
            _toJs(additional),
            _toJs(additionalPresent),
            _toJs(viewTagsLe),
            _toJs(outIndicesLe),
            outCount,
            accCount,
          ),
        ),
      );
      return 0;
    } catch (_) {
      return -5;
    }
  }

  @override
  int merkleInsertChainState(int id, BuBytes blob) {
    try {
      BuWasmJS.merkleInsertChainState(id, _toJs(blob));
      return 0;
    } catch (_) {
      return 3;
    }
  }

  @override
  int merkleUpdateState(int id, int kind, BuBytes leaves) {
    try {
      BuWasmJS.merkleUpdateState(id, kind, _toJs(leaves));
      return 0;
    } catch (_) {
      return 3;
    }
  }

  @override
  int merkleUpdateSubtree(int id, int kind, int start, BuBytes root32) {
    try {
      BuWasmJS.merkleUpdateSubtree(id, kind, start, _toJs(root32));
      return 0;
    } catch (_) {
      return 3;
    }
  }

  @override
  int merkleMergeState(int id, int kind, BuBytes blob) {
    try {
      BuWasmJS.merkleMergeState(id, kind, _toJs(blob));
      return 0;
    } catch (_) {
      return 3;
    }
  }

  @override
  int merkleCheckpoint(int id, int checkpointId) {
    try {
      BuWasmJS.merkleCheckpoint(id, checkpointId);
      return 0;
    } catch (_) {
      return 8;
    }
  }

  @override
  int merkleCreateWitness(
    int id,
    int kind,
    int checkpointId,
    BuBytes positions,
    List<BuBytes> outWitness,
  ) {
    try {
      outWitness.add(
        _fromJs(
          BuWasmJS.merkleCreateWitness(
            id,
            kind,
            checkpointId,
            _toJs(positions),
          ),
        ),
      );
      return 0;
    } catch (_) {
      return 8;
    }
  }

  @override
  int saplingVerifySpend({
    required BuBytes proof,
    required BuBytes vk,
    required BuBytes publicInputs,
  }) => 6;

  @override
  int saplingVerifyOutput({
    required BuBytes proof,
    required BuBytes vk,
    required BuBytes publicInputs,
  }) => 6;

  @override
  int ff1Encrypt({
    required BuBytes key,
    required int radix,
    required BuBytes pt,
    BuBytes? tweak,
    required BuBytes out,
  }) {
    try {
      final tw = tweak ?? BuBytes.zero(0);
      return _okCopy(
        out,
        BuWasmJS.ff1Encrypt(_toJs(key), radix, _toJs(pt), _toJs(tw)),
      );
    } catch (_) {
      return 6;
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
    try {
      final tw = tweak ?? BuBytes.zero(0);
      return _okCopy(
        out,
        BuWasmJS.ff1Decrypt(_toJs(key), radix, _toJs(ct), _toJs(tw)),
      );
    } catch (_) {
      return 6;
    }
  }

  @override
  int ff1EncryptBinary({
    required BuBytes key,
    required BuBytes pt,
    BuBytes? tweak,
    required BuBytes out,
  }) {
    try {
      final tw = tweak ?? BuBytes.zero(0);
      return _okCopy(
        out,
        BuWasmJS.ff1EncryptBinary(_toJs(key), _toJs(pt), _toJs(tw)),
      );
    } catch (_) {
      return 6;
    }
  }

  @override
  int ff1DecryptBinary({
    required BuBytes key,
    required BuBytes ct,
    BuBytes? tweak,
    required BuBytes out,
  }) {
    try {
      final tw = tweak ?? BuBytes.zero(0);
      return _okCopy(
        out,
        BuWasmJS.ff1DecryptBinary(_toJs(key), _toJs(ct), _toJs(tw)),
      );
    } catch (_) {
      return 6;
    }
  }

  @override
  int x25519(BuBytes scalar32, BuBytes u32, BuBytes out32) {
    try {
      return _okCopy(out32, BuWasmJS.x25519(_toJs(scalar32), _toJs(u32)));
    } catch (_) {
      return 6;
    }
  }

  @override
  int x25519PublicKey(BuBytes private32, BuBytes out32) {
    try {
      return _okCopy(out32, BuWasmJS.x25519PublicKey(_toJs(private32)));
    } catch (_) {
      return 6;
    }
  }

  @override
  int x25519Dh(BuBytes private32, BuBytes peerPublic32, BuBytes out32) {
    try {
      return _okCopy(
        out32,
        BuWasmJS.x25519Dh(_toJs(private32), _toJs(peerPublic32)),
      );
    } catch (_) {
      return 6;
    }
  }

  @override
  int ed25519PkToX25519(BuBytes edPk32, BuBytes out32) {
    try {
      return _okCopy(out32, BuWasmJS.ed25519PkToX25519(_toJs(edPk32)));
    } catch (_) {
      return 6;
    }
  }

  @override
  int ed25519SeedToX25519(BuBytes seed32, BuBytes out32) {
    try {
      return _okCopy(out32, BuWasmJS.ed25519SeedToX25519(_toJs(seed32)));
    } catch (_) {
      return 6;
    }
  }

  BuBytes _emptyCtx(BuBytes? c) => c ?? BuBytes.zero(0);

  @override
  int sr25519PublicKey(BuBytes seed32, int uniform, BuBytes out32) {
    try {
      return _okCopy(
        out32,
        BuWasmJS.sr25519PublicKey(_toJs(seed32), uniform != 0),
      );
    } catch (_) {
      return 6;
    }
  }

  @override
  int sr25519SecretFromSeed(BuBytes seed32, int uniform, BuBytes out64) {
    try {
      return _okCopy(
        out64,
        BuWasmJS.sr25519SecretFromSeed(_toJs(seed32), uniform != 0),
      );
    } catch (_) {
      return 6;
    }
  }

  @override
  int sr25519PublicKeyFromSecret(BuBytes sk64, BuBytes out32) {
    try {
      return _okCopy(out32, BuWasmJS.sr25519PublicKeyFromSecret(_toJs(sk64)));
    } catch (_) {
      return 6;
    }
  }

  @override
  int sr25519IsValidPublicKey(BuBytes pk32) {
    try {
      return BuWasmJS.sr25519IsValidPublicKey(_toJs(pk32)) ? 1 : 0;
    } catch (_) {
      return 0;
    }
  }

  @override
  int sr25519IsValidSecretKey(BuBytes sk64) {
    try {
      return BuWasmJS.sr25519IsValidSecretKey(_toJs(sk64)) ? 1 : 0;
    } catch (_) {
      return 0;
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
    try {
      return _okCopy(
        sigOut64,
        BuWasmJS.sr25519Sign(
          _toJs(seedOrSk),
          fromSeed != 0,
          uniform != 0,
          _toJs(_emptyCtx(context)),
          _toJs(message),
          _toJs(nonce64),
        ),
      );
    } catch (_) {
      return 6;
    }
  }

  @override
  int sr25519Verify({
    required BuBytes publicKey,
    BuBytes? context,
    required BuBytes message,
    required BuBytes signature64,
  }) {
    try {
      return BuWasmJS.sr25519Verify(
            _toJs(publicKey),
            _toJs(_emptyCtx(context)),
            _toJs(message),
            _toJs(signature64),
          )
          ? 0
          : 4;
    } catch (_) {
      return 6;
    }
  }

  @override
  int sr25519ToEd25519Bytes(BuBytes sk64, BuBytes out64) {
    try {
      return _okCopy(out64, BuWasmJS.sr25519ToEd25519Bytes(_toJs(sk64)));
    } catch (_) {
      return 6;
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
    try {
      return _okCopy(
        out96,
        BuWasmJS.sr25519HardDerive(
          _toJs(seedOrSk),
          fromSeed != 0,
          uniform != 0,
          _toJs(chain32),
          _toJs(message ?? BuBytes.zero(0)),
        ),
      );
    } catch (_) {
      return 6;
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
    try {
      return _okCopy(
        out96,
        BuWasmJS.sr25519SoftDerive(
          _toJs(seedOrSk),
          fromSeed != 0,
          uniform != 0,
          _toJs(chain32),
          _toJs(message ?? BuBytes.zero(0)),
          _toJs(newNonce32),
        ),
      );
    } catch (_) {
      return 6;
    }
  }

  @override
  int sr25519DerivePublic({
    required BuBytes publicKey,
    required BuBytes chain32,
    BuBytes? message,
    required BuBytes out64,
  }) {
    try {
      return _okCopy(
        out64,
        BuWasmJS.sr25519DerivePublic(
          _toJs(publicKey),
          _toJs(chain32),
          _toJs(message ?? BuBytes.zero(0)),
        ),
      );
    } catch (_) {
      return 6;
    }
  }

  @override
  int sr25519VrfHash({
    required BuBytes publicKey,
    BuBytes? context,
    required BuBytes message,
    required BuBytes out32,
  }) {
    try {
      return _okCopy(
        out32,
        BuWasmJS.sr25519VrfHash(
          _toJs(publicKey),
          _toJs(_emptyCtx(context)),
          _toJs(message),
        ),
      );
    } catch (_) {
      return 6;
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
    try {
      return _okCopy(
        out64,
        BuWasmJS.sr25519VrfInOut(
          _toJs(seedOrSk),
          fromSeed != 0,
          uniform != 0,
          _toJs(_emptyCtx(context)),
          _toJs(message),
        ),
      );
    } catch (_) {
      return 6;
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
    try {
      return _okCopy(
        out64,
        BuWasmJS.sr25519DleqProve(
          _toJs(seedOrSk),
          fromSeed != 0,
          uniform != 0,
          _toJs(inout64),
          _toJs(nonce64),
          kusama != 0,
          extra == null || extra.isEmpty ? null : _toJs(extra),
        ),
      );
    } catch (_) {
      return 6;
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
    try {
      return BuWasmJS.sr25519DleqVerify(
            _toJs(publicKey),
            _toJs(inout64),
            _toJs(proof64),
            kusama != 0,
            extra == null || extra.isEmpty ? null : _toJs(extra),
          )
          ? 0
          : 4;
    } catch (_) {
      return 6;
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
    try {
      return _okCopy(
        out96,
        BuWasmJS.sr25519VrfSign(
          _toJs(seedOrSk),
          fromSeed != 0,
          uniform != 0,
          _toJs(_emptyCtx(context)),
          _toJs(message),
          _toJs(nonce64),
          kusama != 0,
          extra == null ? null : _toJs(extra),
        ),
      );
    } catch (_) {
      return 6;
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
    try {
      final ok = BuWasmJS.sr25519VrfVerify(
        _toJs(publicKey),
        _toJs(_emptyCtx(context)),
        _toJs(message),
        _toJs(preOut32),
        _toJs(proof64),
        kusama != 0,
        extra == null ? null : _toJs(extra),
      );
      return ok ? 0 : 4;
    } catch (_) {
      return 6;
    }
  }

  // ---- FROST (RFC 9591) ----
  // WASM returns flat blobs; split by the out-buffer lengths.
  int _split2(BuBytes a, BuBytes b, BuBytes flat) {
    if (flat.length != a.length + b.length) {
      return 6;
    }
    _copyInto(a, BuBytes.from(flat.sublist(0, a.length)));
    _copyInto(b, BuBytes.from(flat.sublist(a.length)));
    return 0;
  }

  /// Split a flat WASM blob across [outs] in order. Returns 6 on length
  /// mismatch (never partial-copies).
  int _splitFlat(List<BuBytes> outs, BuBytes flat) {
    var need = 0;
    for (final o in outs) {
      need += o.length;
    }
    if (flat.length != need) {
      return 6;
    }
    var off = 0;
    for (final o in outs) {
      _copyInto(o, BuBytes.from(flat.sublist(off, off + o.length)));
      off += o.length;
    }
    return 0;
  }

  @override
  int frostK1Shard(
    BuBytes secret32,
    BuBytes coeffsConcat,
    int nCoeffs,
    int max,
    BuBytes sharesOut,
    BuBytes polyOut,
  ) {
    try {
      final flat = _fromJs(
        BuWasmJS.frostK1Shard(
          _toJs(secret32),
          _toJs(coeffsConcat),
          nCoeffs,
          max,
        ),
      );
      return _split2(sharesOut, polyOut, flat);
    } catch (_) {
      return 6;
    }
  }

  @override
  int frostK1Combine(BuBytes sharesConcat, int n, BuBytes out32) {
    try {
      return _okCopy(out32, BuWasmJS.frostK1Combine(_toJs(sharesConcat), n));
    } catch (_) {
      return 6;
    }
  }

  @override
  int frostK1VssCommit(BuBytes coeffsConcat, int nCoeffs, BuBytes out) {
    try {
      return _okCopy(
        out,
        BuWasmJS.frostK1VssCommit(_toJs(coeffsConcat), nCoeffs),
      );
    } catch (_) {
      return 6;
    }
  }

  @override
  int frostK1VssVerify(
    int id,
    BuBytes share32,
    BuBytes commitmentConcat,
    int nComms,
  ) {
    try {
      return BuWasmJS.frostK1VssVerify(
            id,
            _toJs(share32),
            _toJs(commitmentConcat),
            nComms,
          )
          ? 0
          : 4;
    } catch (_) {
      return 6;
    }
  }

  @override
  int frostK1GroupInfo(
    BuBytes vssConcat,
    int nComms,
    int max,
    BuBytes groupOut,
    BuBytes pksOut,
  ) {
    try {
      final flat = _fromJs(
        BuWasmJS.frostK1GroupInfo(_toJs(vssConcat), nComms, max),
      );
      return _split2(groupOut, pksOut, flat);
    } catch (_) {
      return 6;
    }
  }

  @override
  int frostK1Commit(
    BuBytes secretShare32,
    BuBytes hidingRand32,
    BuBytes bindingRand32,
    BuBytes hidingOut32,
    BuBytes bindingOut32,
    BuBytes hidingCommOut,
    BuBytes bindingCommOut,
  ) {
    try {
      final flat = _fromJs(
        BuWasmJS.frostK1Commit(
          _toJs(secretShare32),
          _toJs(hidingRand32),
          _toJs(bindingRand32),
        ),
      );
      // hiding(32) ++ binding(32) ++ hc(33) ++ bc(33).
      if (flat.length != 130) {
        return 6;
      }
      _copyInto(hidingOut32, BuBytes.from(flat.sublist(0, 32)));
      _copyInto(bindingOut32, BuBytes.from(flat.sublist(32, 64)));
      _copyInto(hidingCommOut, BuBytes.from(flat.sublist(64, 97)));
      _copyInto(bindingCommOut, BuBytes.from(flat.sublist(97, 130)));
      return 0;
    } catch (_) {
      return 6;
    }
  }

  @override
  int frostK1BindingFactors(
    BuBytes groupPk,
    BuBytes commitmentsConcat,
    int n,
    BuBytes msg,
    BuBytes outFactors,
  ) {
    try {
      return _okCopy(
        outFactors,
        BuWasmJS.frostK1BindingFactors(
          _toJs(groupPk),
          _toJs(commitmentsConcat),
          n,
          _toJs(msg),
        ),
      );
    } catch (_) {
      return 6;
    }
  }

  @override
  int frostK1GroupCommitment(
    BuBytes commitmentsConcat,
    BuBytes factorsConcat,
    int n,
    BuBytes out,
  ) {
    try {
      return _okCopy(
        out,
        BuWasmJS.frostK1GroupCommitment(
          _toJs(commitmentsConcat),
          _toJs(factorsConcat),
          n,
        ),
      );
    } catch (_) {
      return 6;
    }
  }

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
  ) {
    try {
      final nonces = BuBytes.concat([
        hidingNonce32,
        bindingNonce32,
        hidingComm,
        bindingComm,
      ]);
      return _okCopy(
        out32,
        BuWasmJS.frostK1Sign(
          id,
          _toJs(secretShare32),
          _toJs(groupPk),
          _toJs(nonces),
          _toJs(commitmentsConcat),
          n,
          _toJs(msg),
        ),
      );
    } catch (_) {
      return 6;
    }
  }

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
  ) {
    try {
      final flat = _fromJs(
        BuWasmJS.frostK1Aggregate(
          _toJs(commitmentsConcat),
          n,
          _toJs(msg),
          _toJs(groupPk),
          _toJs(sharesConcat),
          nShares,
        ),
      );
      return _split2(rOut, zOut, flat);
    } catch (_) {
      return 6;
    }
  }

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
  ) {
    try {
      return BuWasmJS.frostK1VerifyShare(
            id,
            _toJs(pkShare),
            _toJs(commRecord),
            _toJs(share32),
            _toJs(commitmentsConcat),
            n,
            _toJs(groupPk),
            _toJs(msg),
          )
          ? 0
          : 4;
    } catch (_) {
      return 6;
    }
  }

  @override
  int frostK1Verify(BuBytes r, BuBytes z, BuBytes groupPk, BuBytes msg) {
    try {
      final sig = BuBytes.concat([r, z]);
      return BuWasmJS.frostK1Verify(_toJs(sig), _toJs(groupPk), _toJs(msg))
          ? 0
          : 4;
    } catch (_) {
      return 6;
    }
  }

  @override
  int frostK1PrepareShares(
    BuBytes sharesConcat,
    int n,
    int threshold,
    BuBytes out,
  ) {
    try {
      return _okCopy(
        out,
        BuWasmJS.frostK1PrepareShares(_toJs(sharesConcat), n, threshold),
      );
    } catch (_) {
      return 6;
    }
  }

  @override
  int frostK1GroupFromMembers(
    BuBytes idsConcat,
    BuBytes pubsConcat,
    int n,
    int threshold,
    BuBytes groupOut,
  ) {
    try {
      return _okCopy(
        groupOut,
        BuWasmJS.frostK1GroupFromMembers(
          _toJs(idsConcat),
          _toJs(pubsConcat),
          n,
          threshold,
        ),
      );
    } catch (_) {
      return 6;
    }
  }

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
  ) {
    try {
      final flat = _fromJs(
        BuWasmJS.frostK1Reshare(
          _toJs(idsConcat),
          _toJs(secretsConcat),
          n,
          _toJs(coeffsConcat),
          nCoeffs,
          threshold,
        ),
      );
      return _splitFlat([sharesOut, pubsOut, groupOut], flat);
    } catch (_) {
      return 6;
    }
  }

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
    try {
      final flat = _fromJs(
        BuWasmJS.frostEdShard(
          _toJs(secret32),
          _toJs(coeffsConcat),
          nCoeffs,
          max,
          isScalar,
        ),
      );
      return _split2(sharesOut, polyOut, flat);
    } catch (_) {
      return 6;
    }
  }

  @override
  int frostEdCombine(
    BuBytes sharesConcat,
    int n,
    BuBytes out32, {
    bool isScalar = true,
  }) {
    try {
      return _okCopy(
        out32,
        BuWasmJS.frostEdCombine(_toJs(sharesConcat), n, isScalar),
      );
    } catch (_) {
      return 6;
    }
  }

  @override
  int frostEdVssCommit(
    BuBytes coeffsConcat,
    int nCoeffs,
    BuBytes out, {
    bool isScalar = true,
  }) {
    try {
      return _okCopy(
        out,
        BuWasmJS.frostEdVssCommit(_toJs(coeffsConcat), nCoeffs, isScalar),
      );
    } catch (_) {
      return 6;
    }
  }

  @override
  int frostEdVssVerify(
    int id,
    BuBytes share32,
    BuBytes commitmentConcat,
    int nComms, {
    bool isScalar = true,
  }) {
    try {
      return BuWasmJS.frostEdVssVerify(
            id,
            _toJs(share32),
            _toJs(commitmentConcat),
            nComms,
            isScalar,
          )
          ? 0
          : 4;
    } catch (_) {
      return 6;
    }
  }

  @override
  int frostEdGroupInfo(
    BuBytes vssConcat,
    int nComms,
    int max,
    BuBytes groupOut,
    BuBytes pksOut,
  ) {
    try {
      final flat = _fromJs(
        BuWasmJS.frostEdGroupInfo(_toJs(vssConcat), nComms, max),
      );
      return _split2(groupOut, pksOut, flat);
    } catch (_) {
      return 6;
    }
  }

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
    try {
      final flat = _fromJs(
        BuWasmJS.frostEdCommit(
          _toJs(secretShare32),
          _toJs(hidingRand32),
          _toJs(bindingRand32),
          isScalar,
        ),
      );
      // hiding(32) ++ binding(32) ++ hc(32) ++ bc(32).
      if (flat.length != 128) {
        return 6;
      }
      _copyInto(hidingOut32, BuBytes.from(flat.sublist(0, 32)));
      _copyInto(bindingOut32, BuBytes.from(flat.sublist(32, 64)));
      _copyInto(hidingCommOut, BuBytes.from(flat.sublist(64, 96)));
      _copyInto(bindingCommOut, BuBytes.from(flat.sublist(96, 128)));
      return 0;
    } catch (_) {
      return 6;
    }
  }

  @override
  int frostEdBindingFactors(
    BuBytes groupPk,
    BuBytes commitmentsConcat,
    int n,
    BuBytes msg,
    BuBytes outFactors,
  ) {
    try {
      return _okCopy(
        outFactors,
        BuWasmJS.frostEdBindingFactors(
          _toJs(groupPk),
          _toJs(commitmentsConcat),
          n,
          _toJs(msg),
        ),
      );
    } catch (_) {
      return 6;
    }
  }

  @override
  int frostEdGroupCommitment(
    BuBytes commitmentsConcat,
    BuBytes factorsConcat,
    int n,
    BuBytes out,
  ) {
    try {
      return _okCopy(
        out,
        BuWasmJS.frostEdGroupCommitment(
          _toJs(commitmentsConcat),
          _toJs(factorsConcat),
          n,
        ),
      );
    } catch (_) {
      return 6;
    }
  }

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
    try {
      final nonces = BuBytes.concat([
        hidingNonce32,
        bindingNonce32,
        hidingComm,
        bindingComm,
      ]);
      return _okCopy(
        out32,
        BuWasmJS.frostEdSign(
          id,
          _toJs(secretShare32),
          _toJs(groupPk),
          _toJs(nonces),
          _toJs(commitmentsConcat),
          n,
          _toJs(msg),
          isScalar,
        ),
      );
    } catch (_) {
      return 6;
    }
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
  ) {
    try {
      final flat = _fromJs(
        BuWasmJS.frostEdAggregate(
          _toJs(commitmentsConcat),
          n,
          _toJs(msg),
          _toJs(groupPk),
          _toJs(sharesConcat),
          nShares,
        ),
      );
      return _split2(rOut, zOut, flat);
    } catch (_) {
      return 6;
    }
  }

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
  ) {
    try {
      return BuWasmJS.frostEdVerifyShare(
            id,
            _toJs(pkShare),
            _toJs(commRecord),
            _toJs(share32),
            _toJs(commitmentsConcat),
            n,
            _toJs(groupPk),
            _toJs(msg),
          )
          ? 0
          : 4;
    } catch (_) {
      return 6;
    }
  }

  @override
  int frostEdVerify(BuBytes r, BuBytes z, BuBytes groupPk, BuBytes msg) {
    try {
      final sig = BuBytes.concat([r, z]);
      return BuWasmJS.frostEdVerify(_toJs(sig), _toJs(groupPk), _toJs(msg))
          ? 0
          : 4;
    } catch (_) {
      return 6;
    }
  }

  @override
  int frostEdPrepareShares(
    BuBytes sharesConcat,
    int n,
    int threshold,
    BuBytes out, {
    bool isScalar = true,
  }) {
    try {
      return _okCopy(
        out,
        BuWasmJS.frostEdPrepareShares(
          _toJs(sharesConcat),
          n,
          threshold,
          isScalar,
        ),
      );
    } catch (_) {
      return 6;
    }
  }

  @override
  int frostEdGroupFromMembers(
    BuBytes idsConcat,
    BuBytes pubsConcat,
    int n,
    int threshold,
    BuBytes groupOut,
  ) {
    try {
      return _okCopy(
        groupOut,
        BuWasmJS.frostEdGroupFromMembers(
          _toJs(idsConcat),
          _toJs(pubsConcat),
          n,
          threshold,
        ),
      );
    } catch (_) {
      return 6;
    }
  }

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
  ) {
    try {
      final flat = _fromJs(
        BuWasmJS.frostEdReshare(
          _toJs(idsConcat),
          _toJs(secretsConcat),
          n,
          _toJs(coeffsConcat),
          nCoeffs,
          threshold,
        ),
      );
      return _splitFlat([sharesOut, pubsOut, groupOut], flat);
    } catch (_) {
      return 6;
    }
  }

  // —— Solana confidential-transfer ZK ——
  @override
  int solanaZkValidatePubkey(BuBytes pubkey) {
    try {
      return BuWasmJS.solanaZkValidatePubkey(_toJs(pubkey)) ? 0 : 1;
    } catch (_) {
      return 6;
    }
  }

  @override
  int solanaZkValidateCiphertext(BuBytes ciphertext) {
    try {
      return BuWasmJS.solanaZkValidateCiphertext(_toJs(ciphertext)) ? 0 : 1;
    } catch (_) {
      return 6;
    }
  }

  @override
  int solanaZkValidateAe(BuBytes ae) {
    try {
      return BuWasmJS.solanaZkValidateAe(_toJs(ae)) ? 0 : 1;
    } catch (_) {
      return 6;
    }
  }

  @override
  int solanaZkAeEncrypt(
    BuBytes key16,
    int amount,
    BuBytes nonce12,
    BuBytes out36,
  ) {
    try {
      return _okCopy(
        out36,
        BuWasmJS.solanaZkAeEncrypt(
          _toJs(key16),
          amount.toDouble(),
          _toJs(nonce12),
        ),
      );
    } catch (_) {
      return 6;
    }
  }

  // Exact on VM (64-bit) and web (f64 < 2^53): JS masks shift counts to
  // 5 bits, so `>> 32` would alias low bytes. Division is exact instead.
  void _writeLe64(BuBytes out, int v) {
    var hi = v ~/ 0x100000000;
    var lo = v - hi * 0x100000000;
    for (var i = 0; i < 4 && i < out.length; i++) {
      out[i] = lo & 0xFF;
      lo >>= 8;
    }
    for (var i = 4; i < 8 && i < out.length; i++) {
      out[i] = hi & 0xFF;
      hi >>= 8;
    }
  }

  @override
  int solanaZkAeDecrypt(BuBytes key16, BuBytes ae, BuBytes outLe8) {
    try {
      final v = BuWasmJS.solanaZkAeDecrypt(_toJs(key16), _toJs(ae)).toInt();
      _writeLe64(outLe8, v);
      return 0;
    } catch (_) {
      return 6;
    }
  }

  @override
  int solanaZkPubkeyFromSecret(BuBytes secret, BuBytes out32) {
    try {
      return _okCopy(out32, BuWasmJS.solanaZkPubkeyFromSecret(_toJs(secret)));
    } catch (_) {
      return 6;
    }
  }

  @override
  int solanaZkEncryptWith(
    BuBytes pubkey,
    int amount,
    BuBytes opening,
    BuBytes out64,
  ) {
    try {
      return _okCopy(
        out64,
        BuWasmJS.solanaZkEncryptWith(
          _toJs(pubkey),
          amount.toDouble(),
          _toJs(opening),
        ),
      );
    } catch (_) {
      return 6;
    }
  }

  @override
  int solanaZkDecryptU32(BuBytes secret, BuBytes ciphertext, BuBytes outLe8) {
    try {
      final v =
          BuWasmJS.solanaZkDecryptU32(_toJs(secret), _toJs(ciphertext)).toInt();
      _writeLe64(outLe8, v);
      return 0;
    } catch (_) {
      return 6;
    }
  }

  @override
  int solanaZkProvePubkeyValidity(
    BuBytes secret,
    BuBytes seed32,
    BuBytes out64,
  ) {
    try {
      return _okCopy(
        out64,
        BuWasmJS.solanaZkProvePubkeyValidity(_toJs(secret), _toJs(seed32)),
      );
    } catch (_) {
      return 6;
    }
  }

  @override
  int solanaZkVerifyPubkeyValidity(BuBytes pubkey, BuBytes proof) {
    try {
      return BuWasmJS.solanaZkVerifyPubkeyValidity(_toJs(pubkey), _toJs(proof))
          ? 0
          : 1;
    } catch (_) {
      return 6;
    }
  }

  @override
  int solanaZkProveZeroCiphertext(
    BuBytes secret,
    BuBytes pubkey,
    BuBytes ciphertext,
    BuBytes seed32,
    BuBytes out96,
  ) {
    try {
      return _okCopy(
        out96,
        BuWasmJS.solanaZkProveZeroCiphertext(
          _toJs(secret),
          _toJs(pubkey),
          _toJs(ciphertext),
          _toJs(seed32),
        ),
      );
    } catch (_) {
      return 6;
    }
  }

  @override
  int solanaZkVerifyZeroCiphertext(
    BuBytes pubkey,
    BuBytes ciphertext,
    BuBytes proof,
  ) {
    try {
      return BuWasmJS.solanaZkVerifyZeroCiphertext(
            _toJs(pubkey),
            _toJs(ciphertext),
            _toJs(proof),
          )
          ? 0
          : 1;
    } catch (_) {
      return 6;
    }
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
    try {
      return _okCopy(
        out192,
        BuWasmJS.solanaZkProveEquality(
          _toJs(secret),
          _toJs(pubkey),
          _toJs(ciphertext),
          _toJs(commitment),
          _toJs(opening),
          amount.toDouble(),
          _toJs(seed32),
        ),
      );
    } catch (_) {
      return 6;
    }
  }

  @override
  int solanaZkVerifyEquality({
    required BuBytes pubkey,
    required BuBytes ciphertext,
    required BuBytes commitment,
    required BuBytes proof,
  }) {
    try {
      return BuWasmJS.solanaZkVerifyEquality(
            _toJs(pubkey),
            _toJs(ciphertext),
            _toJs(commitment),
            _toJs(proof),
          )
          ? 0
          : 1;
    } catch (_) {
      return 6;
    }
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
    try {
      return _okCopy(
        out224,
        BuWasmJS.solanaZkProveCiphertextEquality(
          _toJs(firstSecret),
          _toJs(firstPubkey),
          _toJs(secondPubkey),
          _toJs(firstCiphertext),
          _toJs(secondCiphertext),
          _toJs(secondOpening),
          amount.toDouble(),
          _toJs(seed32),
        ),
      );
    } catch (_) {
      return 6;
    }
  }

  @override
  int solanaZkVerifyCiphertextEquality({
    required BuBytes firstPubkey,
    required BuBytes secondPubkey,
    required BuBytes firstCiphertext,
    required BuBytes secondCiphertext,
    required BuBytes proof,
  }) {
    try {
      return BuWasmJS.solanaZkVerifyCiphertextEquality(
            _toJs(firstPubkey),
            _toJs(secondPubkey),
            _toJs(firstCiphertext),
            _toJs(secondCiphertext),
            _toJs(proof),
          )
          ? 0
          : 1;
    } catch (_) {
      return 6;
    }
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
    try {
      return _okCopy(
        out160,
        BuWasmJS.solanaZkProveGroupedValidity2(
          _toJs(firstPubkey),
          _toJs(secondPubkey),
          _toJs(grouped96),
          amount.toDouble(),
          _toJs(opening),
          _toJs(seed32),
        ),
      );
    } catch (_) {
      return 6;
    }
  }

  @override
  int solanaZkVerifyGroupedValidity2({
    required BuBytes firstPubkey,
    required BuBytes secondPubkey,
    required BuBytes grouped96,
    required BuBytes proof,
  }) {
    try {
      return BuWasmJS.solanaZkVerifyGroupedValidity2(
            _toJs(firstPubkey),
            _toJs(secondPubkey),
            _toJs(grouped96),
            _toJs(proof),
          )
          ? 0
          : 1;
    } catch (_) {
      return 6;
    }
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
    try {
      return _okCopy(
        out192,
        BuWasmJS.solanaZkProveGroupedValidity3(
          _toJs(firstPubkey),
          _toJs(secondPubkey),
          _toJs(thirdPubkey),
          _toJs(grouped128),
          amount.toDouble(),
          _toJs(opening),
          _toJs(seed32),
        ),
      );
    } catch (_) {
      return 6;
    }
  }

  @override
  int solanaZkVerifyGroupedValidity3({
    required BuBytes firstPubkey,
    required BuBytes secondPubkey,
    required BuBytes thirdPubkey,
    required BuBytes grouped128,
    required BuBytes proof,
  }) {
    try {
      return BuWasmJS.solanaZkVerifyGroupedValidity3(
            _toJs(firstPubkey),
            _toJs(secondPubkey),
            _toJs(thirdPubkey),
            _toJs(grouped128),
            _toJs(proof),
          )
          ? 0
          : 1;
    } catch (_) {
      return 6;
    }
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
    try {
      return _okCopy(
        out160,
        BuWasmJS.solanaZkProveBatchedGroupedValidity2(
          _toJs(firstPubkey),
          _toJs(secondPubkey),
          _toJs(groupedLo96),
          _toJs(groupedHi96),
          amountLo.toDouble(),
          amountHi.toDouble(),
          _toJs(openingLo),
          _toJs(openingHi),
          _toJs(seed32),
        ),
      );
    } catch (_) {
      return 6;
    }
  }

  @override
  int solanaZkVerifyBatchedGroupedValidity2({
    required BuBytes firstPubkey,
    required BuBytes secondPubkey,
    required BuBytes groupedLo96,
    required BuBytes groupedHi96,
    required BuBytes proof,
  }) {
    try {
      return BuWasmJS.solanaZkVerifyBatchedGroupedValidity2(
            _toJs(firstPubkey),
            _toJs(secondPubkey),
            _toJs(groupedLo96),
            _toJs(groupedHi96),
            _toJs(proof),
          )
          ? 0
          : 1;
    } catch (_) {
      return 6;
    }
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
    try {
      return _okCopy(
        out192,
        BuWasmJS.solanaZkProveBatchedGroupedValidity3(
          _toJs(firstPubkey),
          _toJs(secondPubkey),
          _toJs(thirdPubkey),
          _toJs(groupedLo128),
          _toJs(groupedHi128),
          amountLo.toDouble(),
          amountHi.toDouble(),
          _toJs(openingLo),
          _toJs(openingHi),
          _toJs(seed32),
        ),
      );
    } catch (_) {
      return 6;
    }
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
    try {
      return BuWasmJS.solanaZkVerifyBatchedGroupedValidity3(
            _toJs(firstPubkey),
            _toJs(secondPubkey),
            _toJs(thirdPubkey),
            _toJs(groupedLo128),
            _toJs(groupedHi128),
            _toJs(proof),
          )
          ? 0
          : 1;
    } catch (_) {
      return 6;
    }
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
    try {
      return _okCopy(
        out256,
        BuWasmJS.solanaZkProvePercentageWithCap(
          _toJs(percentageCommitment),
          _toJs(percentageOpening),
          percentageAmount.toDouble(),
          _toJs(deltaCommitment),
          _toJs(deltaOpening),
          deltaAmount.toDouble(),
          _toJs(claimedCommitment),
          _toJs(claimedOpening),
          maxValue.toDouble(),
          _toJs(seed32),
        ),
      );
    } catch (_) {
      return 6;
    }
  }

  @override
  int solanaZkVerifyPercentageWithCap({
    required BuBytes percentageCommitment,
    required BuBytes deltaCommitment,
    required BuBytes claimedCommitment,
    required int maxValue,
    required BuBytes proof,
  }) {
    try {
      return BuWasmJS.solanaZkVerifyPercentageWithCap(
            _toJs(percentageCommitment),
            _toJs(deltaCommitment),
            _toJs(claimedCommitment),
            maxValue.toDouble(),
            _toJs(proof),
          )
          ? 0
          : 1;
    } catch (_) {
      return 6;
    }
  }

  @override
  int solanaZkProveBatchedRange({
    required List<BuBytes> amountsLe,
    required List<BuBytes> openings,
    required BuBytes seed32,
    required List<BuBytes> outBlob,
  }) {
    try {
      final amounts = BuBytes.concat(amountsLe);
      final ops = BuBytes.concat(openings);
      outBlob.add(
        _fromJs(
          BuWasmJS.solanaZkProveBatchedRange(
            _toJs(amounts),
            _toJs(ops),
            _toJs(seed32),
          ),
        ),
      );
      return 0;
    } catch (_) {
      return 6;
    }
  }

  @override
  int solanaZkVerifyBatchedRange({
    required BuBytes proof,
    required BuBytes commitments,
    required int n,
  }) {
    try {
      return BuWasmJS.solanaZkVerifyBatchedRange(
            _toJs(proof),
            _toJs(commitments),
            n,
          )
          ? 0
          : 1;
    } catch (_) {
      return 6;
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
    try {
      return _okCopy(
        out1256,
        BuWasmJS.solanaZkProveWithdraw(
          _toJs(sourceSecret),
          _toJs(sourcePubkey),
          _toJs(currentCiphertext),
          currentBalance.toDouble(),
          withdrawAmount.toDouble(),
          _toJs(seed32),
        ),
      );
    } catch (_) {
      return 6;
    }
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
    try {
      return _okCopy(
        out1896,
        BuWasmJS.solanaZkProveTransfer(
          _toJs(sourceSecret),
          _toJs(sourcePubkey),
          _toJs(destPubkey),
          _toJs(auditorPubkey),
          _toJs(currentCiphertext),
          currentBalance.toDouble(),
          transferAmount.toDouble(),
          _toJs(seed32),
        ),
      );
    } catch (_) {
      return 6;
    }
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
    try {
      return _okCopy(
        out2576,
        BuWasmJS.solanaZkProveTransferWithFee(
          _toJs(sourceSecret),
          _toJs(sourcePubkey),
          _toJs(destPubkey),
          _toJs(auditorPubkey),
          _toJs(authorityPubkey),
          _toJs(currentCiphertext),
          currentBalance.toDouble(),
          transferAmount.toDouble(),
          feeRateBasisPoints.toDouble(),
          maximumFee.toDouble(),
          _toJs(seed32),
        ),
      );
    } catch (_) {
      return 6;
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
    try {
      return _okCopy(
        out64,
        BuWasmJS.schnorrSignAux(
          _toJs(sk),
          _toJs(msg),
          aux == null ? null : _toJs(aux),
          tweak == null ? null : _toJs(tweak),
        ),
      );
    } catch (_) {
      return 6;
    }
  }

  // ---- Transcripts (Merlin / Strobe), integer handles ----
  @override
  Object merlinNew(BuBytes label) {
    return BuWasmJS.merlinNew(_toJs(label));
  }

  @override
  void merlinAppend(Object handle, BuBytes label, BuBytes message) {
    BuWasmJS.merlinAppend(handle as int, _toJs(label), _toJs(message));
  }

  @override
  void merlinChallenge(Object handle, BuBytes label, BuBytes out) {
    final r = _fromJs(
      BuWasmJS.merlinChallenge(handle as int, _toJs(label), out.length),
    );
    _copyInto(out, r);
  }

  @override
  Object merlinFork(Object handle) {
    return BuWasmJS.merlinFork(handle as int);
  }

  @override
  void merlinFree(Object handle) {
    try {
      BuWasmJS.merlinFree(handle as int);
    } catch (_) {
      // Free is idempotent at the Dart layer; ignore double-free races.
    }
  }

  @override
  Object strobeNew(BuBytes protocol) {
    return BuWasmJS.strobeNew(_toJs(protocol));
  }

  @override
  void strobeKey(Object handle, BuBytes data) {
    BuWasmJS.strobeKey(handle as int, _toJs(data));
  }

  @override
  void strobeAd(Object handle, bool meta, BuBytes data) {
    BuWasmJS.strobeAd(handle as int, meta, _toJs(data));
  }

  @override
  void strobePrf(Object handle, BuBytes out) {
    if (out.isEmpty) {
      throw BuError.invalidLength;
    }
    final r = _fromJs(BuWasmJS.strobePrf(handle as int, out.length));
    _copyInto(out, r);
  }

  @override
  void strobeFree(Object handle) {
    try {
      BuWasmJS.strobeFree(handle as int);
    } catch (_) {
      // Free is idempotent at the Dart layer; ignore double-free races.
    }
  }
}
