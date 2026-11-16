import 'package:blockchain_utils_connector/src/api/orchard_api.dart';
import 'package:blockchain_utils_connector/src/bytes/bytes.dart';
import 'package:blockchain_utils_connector/src/error/bu_error.dart';
import 'package:blockchain_utils_connector/src/platform/bindings.dart';

class DefaultOrchardApi implements BuOrchardApi {
  DefaultOrchardApi(this._b);
  final BuPlatformBindings _b;
  static BuError _map(int rc) => BuError.fromNativeCode(switch (rc) {
    0 => 7, // unreachable: callers check rc != 0 first
    1 => 1,
    2 => 4,
    3 => 10,
    4 => 7,
    5 => 5,
    6 => 7,
    _ => rc,
  });

  BuBytes _as(List<int> x) => BuBytes.from(x);

  bool _badVersion(int v) =>
      v != BuOrchardApi.versionInsecure &&
      v != BuOrchardApi.versionFixed &&
      v != BuOrchardApi.versionNu63;

  @override
  BuResult<Object> pkNew({required int version}) {
    if (_badVersion(version)) return BuResult.err(BuError.invalidArgument);
    final out = <Object?>[null];
    final rc = _b.orchardPkNew(version, out);
    if (rc != 0 || out[0] == null) {
      return BuResult.err(_map(rc));
    }
    return BuResult.ok(out[0]!);
  }

  @override
  void pkFree(Object pk) => _b.orchardPkFree(pk);

  @override
  BuResult<BuBytes> createProof({
    required Object pk,
    required List<int> inputs,
    required List<int> instances,
    required List<int> seed,
    required int version,
    bool disableCrossAddress = false,
  }) {
    if (_badVersion(version)) return BuResult.err(BuError.invalidArgument);
    if (disableCrossAddress && version != BuOrchardApi.versionNu63) {
      return BuResult.err(BuError.invalidArgument);
    }
    if (inputs.isEmpty || inputs.length % BuOrchardApi.packedInputLen != 0) {
      return BuResult.err(
        BuError.length(
          what: 'inputs',
          expected: BuOrchardApi.packedInputLen,
          actual: inputs.length,
        ),
      );
    }
    final n = inputs.length ~/ BuOrchardApi.packedInputLen;
    if (instances.length != n * BuOrchardApi.instanceRows * 32) {
      return BuResult.err(
        BuError.length(
          what: 'instances',
          expected: n * BuOrchardApi.instanceRows * 32,
          actual: instances.length,
        ),
      );
    }
    if (seed.length != 32) {
      return BuResult.err(
        BuError.length(what: 'seed', expected: 32, actual: seed.length),
      );
    }
    final out = <BuBytes>[];
    final rc = _b.orchardCreateProof(
      pk,
      _as(inputs),
      _as(instances),
      _as(seed),
      version,
      disableCrossAddress ? 1 : 0,
      out,
    );
    if (rc != 0 || out.isEmpty) {
      return BuResult.err(_map(rc));
    }
    return BuResult.ok(out[0]);
  }

  @override
  BuResult<void> verifyProof({
    required Object pk,
    required BuBytes proof,
    required BuBytes instances,
    required int version,
    bool disableCrossAddress = false,
  }) {
    if (_badVersion(version)) return BuResult.err(BuError.invalidArgument);
    if (disableCrossAddress && version != BuOrchardApi.versionNu63) {
      return BuResult.err(BuError.invalidArgument);
    }
    if (proof.isEmpty) {
      return BuResult.err(BuError.invalidArgument);
    }
    if (instances.isEmpty ||
        instances.length % (BuOrchardApi.instanceRows * 32) != 0) {
      return BuResult.err(
        BuError.length(
          what: 'instances',
          expected: BuOrchardApi.instanceRows * 32,
          actual: instances.length,
        ),
      );
    }
    final rc = _b.orchardVerifyProof(
      pk: pk,
      proof: proof,
      instances: instances,
      version: version,
      disableCrossAddress: disableCrossAddress ? 1 : 0,
    );
    if (rc != 0) {
      return BuResult.err(_map(rc));
    }
    return BuResult.ok(null);
  }
}
