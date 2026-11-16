import 'package:blockchain_utils_connector/src/api/curve_api.dart';
import 'package:blockchain_utils_connector/src/api/curve_id.dart';
import 'package:blockchain_utils_connector/src/bytes/bytes.dart';
import 'package:blockchain_utils_connector/src/error/bu_error.dart';
import 'package:blockchain_utils_connector/src/platform/bindings.dart';

class DefaultCurveApi implements BuCurveApi {
  DefaultCurveApi(this.bindings, this.curveId);
  final BuPlatformBindings bindings;
  BuPlatformBindings get _b => bindings;
  @override
  final int curveId;

  BuBytes _asBytes(List<int> data) => BuBytes.from(data);
  BuResult<BuBytes> _map(int rc, BuBytes out) {
    if (rc == 0) {
      return BuResult.ok(out);
    }
    // Curve FFI codes (must not use generic fromCode — 3 is invalid point, not nonce)
    final err = switch (rc) {
      1 => BuError(
        DefaultErrorType.nullPointer,
        'null pointer in native curve call',
      ),
      2 => BuError.argument('invalid or unsupported curve id'),
      3 => BuError.point(),
      4 => BuError.scalar(),
      5 => BuError(
        DefaultErrorType.bufferTooSmall,
        'output buffer is too small',
      ),
      6 => BuError.unsupportedAlgo(),
      _ => BuError.internalErr(message: 'curve operation failed'),
    };
    return BuResult.err(err);
  }

  BuResult<void> _needScalar(List<int> s, String ctx) {
    final e = BuValidate.length(s, scalarLen, what: 'scalar');
    if (e != null) {
      return BuResult.err(e);
    }
    return BuResult.ok(null);
  }

  BuResult<void> _needPoint(List<int> p, String ctx) {
    final e = BuValidate.length(p, pointLen, what: 'point');
    if (e != null) {
      return BuResult.err(e);
    }
    return BuResult.ok(null);
  }

  @override
  int get pointLen => _b.curvePointLen(curveId);
  @override
  int get scalarLen => _b.curveScalarLen(curveId);
  @override
  bool scCheck(List<int> scalarBytes) =>
      _b.curveScCheck(curveId, _asBytes(scalarBytes)) == 1;

  @override
  BuResult<BuBytes> multBase(List<int> scalar) {
    final v = _needScalar(scalar, 'multBase');
    if (v.isErr) {
      return BuResult.err(v.error!);
    }
    final out = BuBytes.zero(pointLen);
    return _map(_b.curveMulBase(curveId, _asBytes(scalar), out), out);
  }

  @override
  BuResult<BuBytes> mult(List<int> scalar, List<int> point) {
    final vs = _needScalar(scalar, 'mult');
    if (vs.isErr) {
      return BuResult.err(vs.error!);
    }
    final vp = _needPoint(point, 'mult');
    if (vp.isErr) {
      return BuResult.err(vp.error!);
    }
    final out = BuBytes.zero(pointLen);
    return _map(
      _b.curveMul(curveId, _asBytes(scalar), _asBytes(point), out),
      out,
    );
  }

  @override
  BuResult<BuBytes> add(List<int> a, List<int> b) {
    final out = BuBytes.zero(pointLen);
    return _map(_b.curveAdd(curveId, _asBytes(a), _asBytes(b), out), out);
  }

  @override
  BuResult<BuBytes> sub(List<int> a, List<int> b) {
    final out = BuBytes.zero(pointLen);
    return _map(_b.curveSub(curveId, _asBytes(a), _asBytes(b), out), out);
  }

  @override
  BuResult<BuBytes> neg(List<int> point) {
    final out = BuBytes.zero(pointLen);
    return _map(_b.curveNeg(curveId, _asBytes(point), out), out);
  }

  @override
  BuResult<BuBytes> scAdd(List<int> a, List<int> b) {
    final out = BuBytes.zero(scalarLen);
    return _map(_b.curveScAdd(curveId, _asBytes(a), _asBytes(b), out), out);
  }

  @override
  BuResult<BuBytes> scSub(List<int> a, List<int> b) {
    final out = BuBytes.zero(scalarLen);
    return _map(_b.curveScSub(curveId, _asBytes(a), _asBytes(b), out), out);
  }

  @override
  BuResult<BuBytes> scMul(List<int> a, List<int> b) {
    final out = BuBytes.zero(scalarLen);
    return _map(_b.curveScMul(curveId, _asBytes(a), _asBytes(b), out), out);
  }

  @override
  BuResult<BuBytes> scNeg(List<int> s) {
    final out = BuBytes.zero(scalarLen);
    return _map(_b.curveScNeg(curveId, _asBytes(s), out), out);
  }

  @override
  BuResult<BuBytes> scReduce(List<int> s) {
    final out = BuBytes.zero(scalarLen);
    return _map(_b.curveScReduce(curveId, _asBytes(s), out), out);
  }

  @override
  BuResult<BuBytes> generator() {
    final out = BuBytes.zero(pointLen);
    return _map(_b.curveGenerator(curveId, out), out);
  }

  @override
  BuResult<BuBytes> identity() {
    final out = BuBytes.zero(pointLen);
    return _map(_b.curveIdentity(curveId, out), out);
  }

  @override
  int get uncompressedLen => _b.curvePointUncompressedLen(curveId);
  @override
  BuResult<BuBytes> compress(List<int> point) {
    final out = BuBytes.zero(pointLen);
    return _map(_b.curveCompress(curveId, _asBytes(point), out), out);
  }

  @override
  BuResult<BuBytes> uncompress(List<int> point) {
    final n = uncompressedLen;
    if (n <= 0) {
      return BuResult.err(
        BuError(DefaultErrorType.unsupported, 'uncompressed length unknown'),
      );
    }
    final out = BuBytes.zero(n);
    return _map(_b.curveUncompress(curveId, _asBytes(point), out), out);
  }

  @override
  BuResult<BuBytes> normalizePublicKey(List<int> point) {
    final out = BuBytes.zero(pointLen);
    return _map(_b.curveNormalizePubkey(curveId, _asBytes(point), out), out);
  }

  @override
  BuResult<BuBytes> generateSecret(List<int> seed) {
    final out = BuBytes.zero(scalarLen);
    return _map(_b.curveGenerateSecret(curveId, _asBytes(seed), out), out);
  }

  @override
  BuResult<BuBytes> mulAdd(
    List<int> s1,
    List<int> p1,
    List<int> s2,
    List<int> p2,
  ) {
    final out = BuBytes.zero(pointLen);
    return _map(
      _b.curveMulAdd(
        curveId,
        _asBytes(s1),
        _asBytes(p1),
        _asBytes(s2),
        _asBytes(p2),
        out,
      ),
      out,
    );
  }
}

class DefaultSecp256k1CurveApi extends DefaultCurveApi
    implements BuSecp256k1CurveApi {
  DefaultSecp256k1CurveApi(BuPlatformBindings b)
    : super(b, BuCurveId.secp256k1);
}

class DefaultSecp256r1CurveApi extends DefaultCurveApi
    implements BuSecp256r1CurveApi {
  DefaultSecp256r1CurveApi(BuPlatformBindings b)
    : super(b, BuCurveId.secp256r1);
}

class DefaultEd25519CurveApi extends DefaultCurveApi
    implements BuEd25519CurveApi {
  DefaultEd25519CurveApi(BuPlatformBindings b) : super(b, BuCurveId.ed25519);
  @override
  BuResult<BuBytes> scReduce32(List<int> scalar32) {
    final out = BuBytes.zero(32);
    final rc = _b.ed25519ScReduce32(_asBytes(scalar32), out);
    return rc == 0
        ? BuResult.ok(out)
        : BuResult.err(BuError.fromNativeCode(rc));
  }

  @override
  BuResult<BuBytes> scReduce64(List<int> scalar64) {
    final out = BuBytes.zero(32);
    final rc = _b.ed25519ScReduce64(_asBytes(scalar64), out);
    return rc == 0
        ? BuResult.ok(out)
        : BuResult.err(BuError.fromNativeCode(rc));
  }

  @override
  BuResult<BuBytes> fromFeBytes(List<int> fe32) {
    if (fe32.length != 32) {
      return BuResult.err(
        BuError(
          DefaultErrorType.invalidLength,
          'ed25519.fromFeBytes expects 32 bytes, got ${fe32.length}',
        ),
      );
    }
    final out = BuBytes.zero(32);
    final rc = _b.ed25519FromFeBytes(_asBytes(fe32), out);
    return rc == 0
        ? BuResult.ok(out)
        : BuResult.err(
          BuError.fromNativeCode(rc, details: {'op': 'ed25519.fromFeBytes'}),
        );
  }

  @override
  BuResult<BuBytes> fromFeBytesClearCofactor(List<int> fe32) {
    if (fe32.length != 32) {
      return BuResult.err(
        BuError(
          DefaultErrorType.invalidLength,
          'ed25519.fromFeBytesClearCofactor expects 32 bytes, got ${fe32.length}',
        ),
      );
    }
    final out = BuBytes.zero(32);
    final rc = _b.ed25519FromFeBytesClearCofactor(_asBytes(fe32), out);
    return rc == 0
        ? BuResult.ok(out)
        : BuResult.err(
          BuError.fromNativeCode(
            rc,
            details: {'op': 'ed25519.fromFeBytesClearCofactor'},
          ),
        );
  }

  @override
  BuResult<BuBytes> hashToEc(List<int> data) {
    final out = BuBytes.zero(32);
    final rc = _b.ed25519HashToEc(_asBytes(data), out);
    return rc == 0
        ? BuResult.ok(out)
        : BuResult.err(
          BuError.fromNativeCode(rc, details: {'op': 'ed25519.hashToEc'}),
        );
  }

  @override
  bool checkKey(List<int> pk32) {
    if (pk32.length != 32) {
      return false;
    }
    return _b.ed25519CheckKey(_asBytes(pk32)) == 1;
  }

  @override
  BuResult<BuBytes> mulByCofactor(List<int> point32) {
    if (point32.length != 32) {
      return BuResult.err(
        BuError(DefaultErrorType.invalidLength, 'mulByCofactor'),
      );
    }
    final out = BuBytes.zero(32);
    final rc = _b.ed25519MulByCofactor(_asBytes(point32), out);
    return rc == 0
        ? BuResult.ok(out)
        : BuResult.err(
          BuError.fromNativeCode(rc, details: {'op': 'mulByCofactor'}),
        );
  }

  @override
  BuResult<BuBytes> scalarmultKeyImage(List<int> hp32, List<int> a32) {
    if (hp32.length != 32 || a32.length != 32) {
      return BuResult.err(
        BuError(DefaultErrorType.invalidLength, 'scalarmultKeyImage'),
      );
    }
    final out = BuBytes.zero(32);
    final rc = _b.ed25519ScalarmultKeyImage(_asBytes(hp32), _asBytes(a32), out);
    return rc == 0
        ? BuResult.ok(out)
        : BuResult.err(
          BuError.fromNativeCode(rc, details: {'op': 'scalarmultKeyImage'}),
        );
  }

  @override
  BuResult<BuBytes> mul8Mult(List<int> scalar32, List<int> point32) {
    if (scalar32.length != 32 || point32.length != 32) {
      return BuResult.err(BuError(DefaultErrorType.invalidLength, 'mul8Mult'));
    }
    final out = BuBytes.zero(32);
    final rc = _b.ed25519Mul8Mult(_asBytes(scalar32), _asBytes(point32), out);
    return rc == 0
        ? BuResult.ok(out)
        : BuResult.err(BuError.fromNativeCode(rc, details: {'op': 'mul8Mult'}));
  }

  @override
  BuResult<BuBytes> geDsmPrecomp(List<int> point32) {
    if (point32.length != 32) {
      return BuResult.err(
        BuError(DefaultErrorType.invalidLength, 'geDsmPrecomp'),
      );
    }
    final out = BuBytes.zero(256);
    final rc = _b.ed25519GeDsmPrecomp(_asBytes(point32), out);
    return rc == 0
        ? BuResult.ok(out)
        : BuResult.err(
          BuError.fromNativeCode(rc, details: {'op': 'geDsmPrecomp'}),
        );
  }

  @override
  BuResult<BuBytes> geDoubleScalarMultPrecomp(
    List<int> a32,
    List<int> aI256,
    List<int> b32,
    List<int> bI256,
  ) {
    final out = BuBytes.zero(32);
    final rc = _b.ed25519GeDoubleScalarMultPrecomp(
      _asBytes(a32),
      _asBytes(aI256),
      _asBytes(b32),
      _asBytes(bI256),
      out,
    );
    return rc == 0
        ? BuResult.ok(out)
        : BuResult.err(
          BuError.fromNativeCode(
            rc,
            details: {'op': 'geDoubleScalarMultPrecomp'},
          ),
        );
  }

  @override
  BuResult<BuBytes> geDoubleScalarMultBase(
    List<int> a32,
    List<int> gA32,
    List<int> b32,
  ) {
    final out = BuBytes.zero(32);
    final rc = _b.ed25519GeDoubleScalarMultBase(
      _asBytes(a32),
      _asBytes(gA32),
      _asBytes(b32),
      out,
    );
    return rc == 0
        ? BuResult.ok(out)
        : BuResult.err(
          BuError.fromNativeCode(rc, details: {'op': 'geDoubleScalarMultBase'}),
        );
  }

  @override
  BuResult<BuBytes> geTripleScalarMultBase(
    List<int> a32,
    List<int> b32,
    List<int> bI256,
    List<int> c32,
    List<int> cI256,
  ) {
    final out = BuBytes.zero(32);
    final rc = _b.ed25519GeTripleScalarMultBase(
      _asBytes(a32),
      _asBytes(b32),
      _asBytes(bI256),
      _asBytes(c32),
      _asBytes(cI256),
      out,
    );
    return rc == 0
        ? BuResult.ok(out)
        : BuResult.err(
          BuError.fromNativeCode(rc, details: {'op': 'geTripleScalarMultBase'}),
        );
  }

  @override
  BuResult<BuBytes> geTripleScalarMultPrecomp(
    List<int> a32,
    List<int> aI256,
    List<int> b32,
    List<int> bI256,
    List<int> c32,
    List<int> cI256,
  ) {
    final out = BuBytes.zero(32);
    final rc = _b.ed25519GeTripleScalarMultPrecomp(
      _asBytes(a32),
      _asBytes(aI256),
      _asBytes(b32),
      _asBytes(bI256),
      _asBytes(c32),
      _asBytes(cI256),
      out,
    );
    return rc == 0
        ? BuResult.ok(out)
        : BuResult.err(
          BuError.fromNativeCode(
            rc,
            details: {'op': 'geTripleScalarMultPrecomp'},
          ),
        );
  }

  BuResult<BuBytes> _vt32(int rc, BuBytes out, String tag) =>
      rc == 0
          ? BuResult.ok(out)
          : BuResult.err(BuError.fromNativeCode(rc, details: {'op': tag}));

  @override
  BuResult<BuBytes> mulVartime(List<int> scalar, List<int> point) {
    if (scalar.length != 32 || point.length != 32) {
      return BuResult.err(
        BuError(DefaultErrorType.invalidLength, 'mulVartime'),
      );
    }
    final out = BuBytes.zero(32);
    return _vt32(
      _b.ed25519MulVartime(_asBytes(scalar), _asBytes(point), out),
      out,
      'mulVartime',
    );
  }

  @override
  BuResult<BuBytes> mulBaseVartime(List<int> scalar) {
    if (scalar.length != 32) {
      return BuResult.err(
        BuError(DefaultErrorType.invalidLength, 'mulBaseVartime'),
      );
    }
    final out = BuBytes.zero(32);
    return _vt32(
      _b.ed25519MulBaseVartime(_asBytes(scalar), out),
      out,
      'mulBaseVartime',
    );
  }

  @override
  BuResult<BuBytes> mulAddVartime(
    List<int> s1,
    List<int> p1,
    List<int> s2,
    List<int> p2,
  ) {
    if ([s1, p1, s2, p2].any((e) => e.length != 32)) {
      return BuResult.err(
        BuError(DefaultErrorType.invalidLength, 'mulAddVartime'),
      );
    }
    final out = BuBytes.zero(32);
    return _vt32(
      _b.ed25519MulAddVartime(
        _asBytes(s1),
        _asBytes(p1),
        _asBytes(s2),
        _asBytes(p2),
        out,
      ),
      out,
      'mulAddVartime',
    );
  }

  @override
  BuResult<BuBytes> addVartime(List<int> a, List<int> b) {
    if (a.length != 32 || b.length != 32) {
      return BuResult.err(
        BuError(DefaultErrorType.invalidLength, 'addVartime'),
      );
    }
    final out = BuBytes.zero(32);
    return _vt32(
      _b.ed25519AddVartime(_asBytes(a), _asBytes(b), out),
      out,
      'addVartime',
    );
  }

  @override
  BuResult<BuBytes> subVartime(List<int> a, List<int> b) {
    if (a.length != 32 || b.length != 32) {
      return BuResult.err(
        BuError(DefaultErrorType.invalidLength, 'subVartime'),
      );
    }
    final out = BuBytes.zero(32);
    return _vt32(
      _b.ed25519SubVartime(_asBytes(a), _asBytes(b), out),
      out,
      'subVartime',
    );
  }

  @override
  BuResult<BuBytes> negVartime(List<int> point) {
    if (point.length != 32) {
      return BuResult.err(
        BuError(DefaultErrorType.invalidLength, 'negVartime'),
      );
    }
    final out = BuBytes.zero(32);
    return _vt32(_b.ed25519NegVartime(_asBytes(point), out), out, 'negVartime');
  }

  @override
  BuResult<BuBytes> doubleVartime(List<int> point) {
    if (point.length != 32) {
      return BuResult.err(
        BuError(DefaultErrorType.invalidLength, 'doubleVartime'),
      );
    }
    final out = BuBytes.zero(32);
    return _vt32(
      _b.ed25519DoubleVartime(_asBytes(point), out),
      out,
      'doubleVartime',
    );
  }
}

class DefaultRistrettoCurveApi extends DefaultCurveApi
    implements BuRistrettoCurveApi {
  DefaultRistrettoCurveApi(BuPlatformBindings b)
    : super(b, BuCurveId.ristretto);

  @override
  BuResult<BuBytes> pointFromEdwardBytes(List<int> edwards32) {
    if (edwards32.length != 32) {
      return BuResult.err(
        BuError(
          DefaultErrorType.invalidLength,
          'ristretto.pointFromEdwardBytes expects 32 bytes',
        ),
      );
    }
    final out = BuBytes.zero(32);
    final rc = _b.ristrettoFromEdwards(_asBytes(edwards32), out);
    return rc == 0
        ? BuResult.ok(out)
        : BuResult.err(
          BuError.fromNativeCode(
            rc,
            details: {'op': 'ristretto.pointFromEdwardBytes'},
          ),
        );
  }

  @override
  BuResult<BuBytes> toEdwardBytes(List<int> ristretto32) {
    if (ristretto32.length != 32) {
      return BuResult.err(
        BuError(
          DefaultErrorType.invalidLength,
          'ristretto.toEdwardBytes expects 32 bytes',
        ),
      );
    }
    final out = BuBytes.zero(32);
    final rc = _b.ristrettoToEdwards(_asBytes(ristretto32), out);
    return rc == 0
        ? BuResult.ok(out)
        : BuResult.err(
          BuError.fromNativeCode(
            rc,
            details: {'op': 'ristretto.toEdwardBytes'},
          ),
        );
  }

  /// sr25519 / Ristretto scalar reduce of a 64-byte LE integer mod L (Ed25519 order).
  @override
  BuResult<BuBytes> scReduce64(List<int> scalar64) {
    if (scalar64.length != 64) {
      return BuResult.err(
        BuError(
          DefaultErrorType.invalidLength,
          'ristretto.scReduce64 expects 64 bytes, got ${scalar64.length}',
        ),
      );
    }
    final out = BuBytes.zero(32);
    final rc = _b.ed25519ScReduce64(_asBytes(scalar64), out);
    return rc == 0
        ? BuResult.ok(out)
        : BuResult.err(
          BuError.fromNativeCode(rc, details: {'op': 'ristretto.scReduce64'}),
        );
  }
}

class DefaultG1CurveApi extends DefaultCurveApi
    implements BuG1ProjectiveCurveApi {
  DefaultG1CurveApi(BuPlatformBindings b) : super(b, BuCurveId.bls12G1);
  @override
  BuResult<BuBytes> hashToG1(List<int> msg, {List<int>? dst}) {
    final out = BuBytes.zero(48);
    final rc = _b.blsHashToG1(
      _asBytes(msg),
      dst == null ? BuBytes.empty() : _asBytes(dst),
      out,
    );
    return rc == 0
        ? BuResult.ok(out)
        : BuResult.err(BuError.fromNativeCode(rc));
  }
}

class DefaultG2CurveApi extends DefaultCurveApi
    implements BuG2ProjectiveCurveApi {
  DefaultG2CurveApi(BuPlatformBindings b) : super(b, BuCurveId.bls12G2);
  @override
  BuResult<BuBytes> hashToG2(List<int> msg, {List<int>? dst}) {
    final out = BuBytes.zero(96);
    final rc = _b.blsHashToG2(
      _asBytes(msg),
      dst == null ? BuBytes.empty() : _asBytes(dst),
      out,
    );
    return rc == 0
        ? BuResult.ok(out)
        : BuResult.err(BuError.fromNativeCode(rc));
  }
}

class DefaultBn254G1CurveApi extends DefaultCurveApi
    implements BuBn254G1CurveApi {
  DefaultBn254G1CurveApi(BuPlatformBindings b) : super(b, BuCurveId.bn254G1);
}

class DefaultBn254G2CurveApi extends DefaultCurveApi
    implements BuBn254G2CurveApi {
  DefaultBn254G2CurveApi(BuPlatformBindings b) : super(b, BuCurveId.bn254G2);
}

class DefaultCurvesApi implements BuCurvesApi {
  DefaultCurvesApi(this._b);
  final BuPlatformBindings _b;
  @override
  BuSecp256k1CurveApi secp256k1() => DefaultSecp256k1CurveApi(_b);
  @override
  BuSecp256r1CurveApi secp256r1() => DefaultSecp256r1CurveApi(_b);
  @override
  BuEd25519CurveApi ed25519() => DefaultEd25519CurveApi(_b);
  @override
  BuRistrettoCurveApi ristretto() => DefaultRistrettoCurveApi(_b);
  @override
  BuJubjubCurveApi jubjub() => _Jubjub(_b);
  @override
  BuG1ProjectiveCurveApi g1() => DefaultG1CurveApi(_b);
  @override
  BuG2ProjectiveCurveApi g2() => DefaultG2CurveApi(_b);
  @override
  BuBn254G1CurveApi bn254G1() => DefaultBn254G1CurveApi(_b);
  @override
  BuBn254G2CurveApi bn254G2() => DefaultBn254G2CurveApi(_b);
  @override
  BuPallasCurveApi pallas() => _Pallas(_b);
  @override
  BuVestaCurveApi vesta() => _Vesta(_b);
  @override
  BuPallasIsoCurveApi pallasIso() => _PallasIso(_b);
  @override
  BuVestaIsoCurveApi vestaIso() => _VestaIso(_b);
}

class _Jubjub extends DefaultCurveApi implements BuJubjubCurveApi {
  _Jubjub(BuPlatformBindings b) : super(b, BuCurveId.jubjub);
  @override
  BuResult<BuBytes> scReduce64(List<int> scalar64) {
    if (scalar64.length != 64) {
      return BuResult.err(
        BuError(
          DefaultErrorType.invalidLength,
          'jubjub.scReduce64 expects 64 bytes',
        ),
      );
    }
    final out = BuBytes.zero(32);
    final rc = _b.jubjubScReduce64(_asBytes(scalar64), out);
    return rc == 0
        ? BuResult.ok(out)
        : BuResult.err(
          BuError.fromNativeCode(rc, details: {'op': 'jubjub.scReduce64'}),
        );
  }
}

class _Pallas extends DefaultCurveApi implements BuPallasCurveApi {
  _Pallas(BuPlatformBindings b) : super(b, BuCurveId.pallas);
  @override
  BuResult<BuBytes> scReduce64(List<int> scalar64) {
    if (scalar64.length != 64) {
      return BuResult.err(
        BuError(
          DefaultErrorType.invalidLength,
          'pallas.scReduce64 expects 64 bytes',
        ),
      );
    }
    final out = BuBytes.zero(32);
    final rc = _b.pallasScReduce64(_asBytes(scalar64), out);
    return rc == 0
        ? BuResult.ok(out)
        : BuResult.err(
          BuError.fromNativeCode(rc, details: {'op': 'pallas.scReduce64'}),
        );
  }

  @override
  BuResult<BuBytes> hashToCurve(List<int> msg, {List<int>? dst}) {
    final out = BuBytes.zero(pointLen);
    final rc = _b.pallasHashToCurve(
      _asBytes(msg),
      dst == null ? BuBytes.empty() : _asBytes(dst),
      out,
    );
    return rc == 0
        ? BuResult.ok(out)
        : BuResult.err(BuError.fromNativeCode(rc));
  }

  @override
  BuResult<BuBytes> hashToCurvePasta(List<int> msg, {List<int>? personal}) {
    // Rust FFI: (domain_prefix, message). `personal` is the domain prefix
    // (e.g. UTF-8 of "z.cash:Orchard-gd"), `msg` is the message body.
    final out = BuBytes.zero(pointLen);
    final domain = personal == null ? BuBytes.empty() : _asBytes(personal);
    final rc = _b.pallasHashToCurvePasta(domain, _asBytes(msg), out);
    if (rc == 0) {
      return BuResult.ok(out);
    }
    // Map curve FFI codes (do not use the generic numbering — 3 is invalidPoint, not nonce)
    final code = switch (rc) {
      1 => DefaultErrorType.nullPointer,
      2 => DefaultErrorType.invalidArgument, // invalid curve id
      3 => DefaultErrorType.invalidPoint, // bad UTF-8 domain or point
      4 => DefaultErrorType.invalidScalar,
      5 => DefaultErrorType.bufferTooSmall,
      6 => DefaultErrorType.unsupported,
      _ => DefaultErrorType.internal,
    };
    return BuResult.err(BuError(code, 'pallas.hashToCurvePasta'));
  }
}

class _Vesta extends DefaultCurveApi implements BuVestaCurveApi {
  _Vesta(BuPlatformBindings b) : super(b, BuCurveId.vesta);
  @override
  BuResult<BuBytes> scReduce64(List<int> scalar64) {
    if (scalar64.length != 64) {
      return BuResult.err(
        BuError(
          DefaultErrorType.invalidLength,
          'vesta.scReduce64 expects 64 bytes',
        ),
      );
    }
    final out = BuBytes.zero(32);
    final rc = _b.vestaScReduce64(_asBytes(scalar64), out);
    return rc == 0
        ? BuResult.ok(out)
        : BuResult.err(
          BuError.fromNativeCode(rc, details: {'op': 'vesta.scReduce64'}),
        );
  }

  @override
  BuResult<BuBytes> hashToCurve(List<int> msg, {List<int>? dst}) {
    final out = BuBytes.zero(pointLen);
    final rc = _b.vestaHashToCurve(
      _asBytes(msg),
      dst == null ? BuBytes.empty() : _asBytes(dst),
      out,
    );
    return rc == 0
        ? BuResult.ok(out)
        : BuResult.err(BuError.fromNativeCode(rc));
  }
}

class _PallasIso extends DefaultCurveApi implements BuPallasIsoCurveApi {
  _PallasIso(BuPlatformBindings b) : super(b, BuCurveId.pallas);
  @override
  BuResult<BuBytes> hashToCurve(List<int> msg, {List<int>? dst}) {
    final out = BuBytes.zero(pointLen);
    final rc = _b.pallasHashToCurve(
      _asBytes(msg),
      dst == null ? BuBytes.empty() : _asBytes(dst),
      out,
    );
    return rc == 0
        ? BuResult.ok(out)
        : BuResult.err(BuError.fromNativeCode(rc));
  }
}

class _VestaIso extends DefaultCurveApi implements BuVestaIsoCurveApi {
  _VestaIso(BuPlatformBindings b) : super(b, BuCurveId.vesta);
  @override
  BuResult<BuBytes> hashToCurve(List<int> msg, {List<int>? dst}) {
    final out = BuBytes.zero(pointLen);
    final rc = _b.vestaHashToCurve(
      _asBytes(msg),
      dst == null ? BuBytes.empty() : _asBytes(dst),
      out,
    );
    return rc == 0
        ? BuResult.ok(out)
        : BuResult.err(BuError.fromNativeCode(rc));
  }
}
