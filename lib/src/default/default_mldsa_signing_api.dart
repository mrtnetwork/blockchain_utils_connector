import 'package:blockchain_utils_connector/src/api/mldsa_signing_api.dart';
import 'package:blockchain_utils_connector/src/bytes/bytes.dart';
import 'package:blockchain_utils_connector/src/error/bu_error.dart';
import 'package:blockchain_utils_connector/src/platform/bindings.dart';

class DefaultMlDsaSigningApi implements BuMlDsaSigningApi {
  DefaultMlDsaSigningApi(this._b);
  final BuPlatformBindings _b;

  static const _levels = {44, 65, 87};

  /// level → (pkLen, skLen, sigLen)
  static const Map<int, (int, int, int)> _sizeTable = {
    44: (1312, 2560, 2420),
    65: (1952, 4032, 3309),
    87: (2592, 4896, 4627),
  };

  BuResult<(int, int, int)> _sizes(int level) {
    final s = _sizeTable[level];
    if (s == null) {
      return BuResult.err(
        BuError.argument(
          'ML-DSA level must be 44, 65, or 87',
          details: {'level': '$level'},
        ),
      );
    }
    return BuResult.ok(s);
  }

  int? _levelFromSk(BuBytes sk) {
    for (final e in _sizeTable.entries) {
      if (e.value.$2 == sk.length) {
        return e.key;
      }
    }
    return null;
  }

  int? _levelFromPk(BuBytes pk) {
    for (final e in _sizeTable.entries) {
      if (e.value.$1 == pk.length) {
        return e.key;
      }
    }
    return null;
  }

  BuResult<int> _resolveLevel({int? level, BuBytes? sk, BuBytes? pk}) {
    if (level != null) {
      if (!_levels.contains(level)) {
        return BuResult.err(
          BuError.argument(
            'ML-DSA level must be 44, 65, or 87',
            details: {'level': '$level'},
          ),
        );
      }
      return BuResult.ok(level);
    }
    if (sk != null) {
      final l = _levelFromSk(sk);
      if (l != null) {
        return BuResult.ok(l);
      }
    }
    if (pk != null) {
      final l = _levelFromPk(pk);
      if (l != null) {
        return BuResult.ok(l);
      }
    }
    return BuResult.err(
      BuError.argument(
        'ML-DSA level is required when it cannot be inferred from key length',
      ),
    );
  }

  /// null → empty so native uses global RNG; non-null must be 32 bytes for keygen/rnd.
  ///
  /// NOTE: both native backends reject caller-absent `rnd` (no silent
  /// fallback randomness), so null here is filled from the seeded global
  /// ChaCha backend instead of being forwarded as empty.
  BuResult<BuBytes> _seed32OrEmpty(BuBytes? seed, {required String ctx}) {
    if (seed == null || seed.isEmpty) {
      return BuResult.ok(BuBytes.empty());
    }
    if (seed.length != 32) {
      return BuResult.err(
        BuError.length(
          what: 'ML-DSA seed/rnd',
          expected: 32,
          actual: seed.length,
        ),
      );
    }
    return BuResult.ok(seed);
  }

  @override
  BuResult<(BuBytes, BuBytes)> keygen({required int level, BuBytes? seed}) {
    final sz = _sizes(level);
    if (sz.isErr) {
      return BuResult.err(sz.error!);
    }
    final seedR = _seed32OrEmpty(seed, ctx: 'mlDsa.keygen');
    if (seedR.isErr) {
      return BuResult.err(seedR.error!);
    }
    final (pkLen, skLen, _) = sz.value!;
    final pk = BuBytes.zero(pkLen);
    final sk = BuBytes.zero(skLen);
    final rc = _b.mldsaKeygen(level, seedR.value!, pk, sk);
    if (rc != 0) {
      return BuResult.err(BuError.fromNativeCode(rc));
    }
    return BuResult.ok((pk, sk));
  }

  @override
  BuResult<BuBytes> publicKeyFromSecret({int? level, required BuBytes sk}) {
    final lev = _resolveLevel(level: level, sk: sk);
    if (lev.isErr) {
      return BuResult.err(lev.error!);
    }
    final sz = _sizes(lev.value!);
    if (sz.isErr) {
      return BuResult.err(sz.error!);
    }
    final (pkLen, skLen, _) = sz.value!;
    if (sk.length != skLen) {
      return BuResult.err(
        BuError.length(
          what: 'ML-DSA secret key',
          expected: skLen,
          actual: sk.length,
        ),
      );
    }
    final pk = BuBytes.zero(pkLen);
    final rc = _b.mldsaPublicFromSecret(lev.value!, sk, pk);
    if (rc != 0) {
      return BuResult.err(BuError.fromNativeCode(rc));
    }
    return BuResult.ok(pk);
  }

  @override
  BuResult<BuBytes> sign({
    int? level,
    required BuBytes sk,
    required BuBytes message,
    BuBytes? rnd,
    BuBytes? context,
  }) {
    final lev = _resolveLevel(level: level, sk: sk);
    if (lev.isErr) {
      return BuResult.err(lev.error!);
    }
    final sz = _sizes(lev.value!);
    if (sz.isErr) {
      return BuResult.err(sz.error!);
    }
    final (_, skLen, sigLen) = sz.value!;
    if (sk.length != skLen) {
      return BuResult.err(
        BuError.length(
          what: 'ML-DSA secret key',
          expected: skLen,
          actual: sk.length,
        ),
      );
    }
    final rndR = _seed32OrEmpty(rnd, ctx: 'mlDsa.sign');
    BuBytes rndB;
    if (rnd == null || rnd.isEmpty) {
      // Both native backends reject caller-absent `rnd` (no silent
      // fallback randomness): fill from the seeded global ChaCha backend.
      rndB = BuBytes.zero(32);
      if (_b.rngFill(rndB) != 0) {
        return BuResult.err(BuError.fromNativeCode(11));
      }
    } else {
      if (rndR.isErr) {
        return BuResult.err(rndR.error!);
      }
      rndB = rndR.value!;
    }
    final ctx = context ?? BuBytes.empty();
    if (ctx.length > 255) {
      return BuResult.err(
        BuError.argument(
          'ML-DSA context must be ≤ 255 bytes',
          details: {'length': '${ctx.length}'},
        ),
      );
    }
    final sig = BuBytes.zero(sigLen);
    final rc = _b.mldsaSign(lev.value!, sk, message, rndB, ctx, sig);
    if (rc != 0) {
      return BuResult.err(BuError.fromNativeCode(rc));
    }
    return BuResult.ok(sig);
  }

  @override
  BuResult<bool> verify({
    int? level,
    required BuBytes pk,
    required BuBytes message,
    required BuBytes signature,
    BuBytes? context,
  }) {
    final lev = _resolveLevel(level: level, pk: pk);
    if (lev.isErr) {
      return BuResult.err(lev.error!);
    }
    final sz = _sizes(lev.value!);
    if (sz.isErr) {
      return BuResult.err(sz.error!);
    }
    final (pkLen, _, sigLen) = sz.value!;
    if (pk.length != pkLen) {
      return BuResult.err(
        BuError.length(
          what: 'ML-DSA public key',
          expected: pkLen,
          actual: pk.length,
        ),
      );
    }
    if (signature.length != sigLen) {
      return BuResult.err(
        BuError.length(
          what: 'ML-DSA signature',
          expected: sigLen,
          actual: signature.length,
        ),
      );
    }
    final ctx = context ?? BuBytes.empty();
    if (ctx.length > 255) {
      return BuResult.err(
        BuError.argument(
          'ML-DSA context must be ≤ 255 bytes',
          details: {'length': '${ctx.length}'},
        ),
      );
    }
    final rc = _b.mldsaVerify(lev.value!, pk, message, signature, ctx);
    if (rc == 0) {
      return BuResult.ok(true);
    }
    if (rc == 14 || rc == 5 || rc == 1) {
      return BuResult.ok(false);
    }
    return BuResult.err(BuError.fromNativeCode(rc));
  }

  @override
  bool isValidPublicKey(List<int> publicKey, {int? level}) {
    final pk = BuBytes.from(publicKey);
    final l = _resolveLevel(level: level, pk: pk);
    if (l.isErr) {
      return false;
    }
    final sizes = _sizeTable[l.value!];
    return sizes != null && pk.length == sizes.$1;
  }

  @override
  bool isValidSecretKey(List<int> secret, {int? level}) {
    final sk = BuBytes.from(secret);
    final l = _resolveLevel(level: level, sk: sk);
    if (l.isErr) {
      return false;
    }
    final sizes = _sizeTable[l.value!];
    return sizes != null && sk.length == sizes.$2;
  }
}
