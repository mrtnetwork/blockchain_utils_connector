import 'package:blockchain_utils_connector/src/api/x25519_api.dart';
import 'package:blockchain_utils_connector/src/bytes/bytes.dart';
import 'package:blockchain_utils_connector/src/error/bu_error.dart';
import 'package:blockchain_utils_connector/src/platform/bindings.dart';

class DefaultX25519Api implements BuX25519Api {
  DefaultX25519Api(this._b);
  final BuPlatformBindings _b;
  BuBytes _as(List<int> x) => BuBytes.from(x);

  static BuError _map(int rc) => BuError.fromNativeCode(switch (rc) {
    0 => 7, // unreachable: callers check rc != 0 first
    1 => 1,
    2 => 9,
    3 => 10,
    _ => rc,
  });

  BuResult<BuBytes> _req32(List<int> x, String name) {
    if (x.length != 32) {
      return BuResult.err(
        BuError.length(what: name, expected: 32, actual: x.length),
      );
    }
    return BuResult.ok(_as(x));
  }

  @override
  BuResult<BuBytes> x25519({required List<int> scalar, required List<int> u}) {
    final sk = _req32(scalar, 'scalar');
    if (sk.isErr) {
      return sk;
    }
    final uu = _req32(u, 'u');
    if (uu.isErr) {
      return uu;
    }
    final out = BuBytes.zero(32);
    final rc = _b.x25519(sk.value!, uu.value!, out);
    return rc == 0 ? BuResult.ok(out) : BuResult.err(_map(rc));
  }

  @override
  BuResult<BuBytes> publicKey(List<int> privateKey) {
    final sk = _req32(privateKey, 'privateKey');
    if (sk.isErr) {
      return sk;
    }
    final out = BuBytes.zero(32);
    final rc = _b.x25519PublicKey(sk.value!, out);
    return rc == 0 ? BuResult.ok(out) : BuResult.err(_map(rc));
  }

  @override
  BuResult<BuBytes> diffieHellman({
    required List<int> privateKey,
    required List<int> peerPublic,
  }) {
    final sk = _req32(privateKey, 'privateKey');
    if (sk.isErr) {
      return sk;
    }
    final pk = _req32(peerPublic, 'peerPublic');
    if (pk.isErr) {
      return pk;
    }
    final out = BuBytes.zero(32);
    final rc = _b.x25519Dh(sk.value!, pk.value!, out);
    return rc == 0 ? BuResult.ok(out) : BuResult.err(_map(rc));
  }

  @override
  BuResult<BuBytes> fromEd25519PublicKey(List<int> ed25519Pk) {
    final pk = _req32(ed25519Pk, 'ed25519Pk');
    if (pk.isErr) {
      return pk;
    }
    final out = BuBytes.zero(32);
    final rc = _b.ed25519PkToX25519(pk.value!, out);
    return rc == 0 ? BuResult.ok(out) : BuResult.err(_map(rc));
  }

  @override
  BuResult<BuBytes> fromEd25519Seed(List<int> seed) {
    final s = _req32(seed, 'seed');
    if (s.isErr) {
      return s;
    }
    final out = BuBytes.zero(32);
    final rc = _b.ed25519SeedToX25519(s.value!, out);
    return rc == 0 ? BuResult.ok(out) : BuResult.err(_map(rc));
  }
}
