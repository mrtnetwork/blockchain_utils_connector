import 'package:blockchain_utils_connector/src/api/monero_api.dart';
import 'package:blockchain_utils_connector/src/bytes/bytes.dart';
import 'package:blockchain_utils_connector/src/error/bu_error.dart';
import 'package:blockchain_utils_connector/src/platform/bindings.dart';

class DefaultMoneroApi implements BuMoneroApi {
  DefaultMoneroApi(this._b);
  final BuPlatformBindings _b;
  static const _tag = 'monero';

  BuBytes _as(List<int> x) => BuBytes.from(x);

  static BuError _map(int rc) => BuError.fromNativeCode(switch (rc) {
    // Rust BU_MONERO_*: 0 ok, 1 invalid-equation, -1 null, -2 length,
    // -3 parse, -4 crypto, -5 internal.
    // 0 is unreachable: callers check rc first.
    0 => 7,
    1 => 14,
    -1 => 1,
    -2 => 9,
    -3 => 4,
    -4 => 10,
    _ => 7,
  });

  BuResult<List<BuBytes>> _reqKeys(
    List<List<int>> xs,
    String name,
    int n,
    int len,
  ) {
    if (xs.length != n) {
      return BuResult.err(
        BuError.length(what: name, expected: n, actual: xs.length),
      );
    }
    final out = <BuBytes>[];
    for (final x in xs) {
      if (x.length != len) {
        return BuResult.err(
          BuError.length(what: name, expected: len, actual: x.length),
        );
      }
      out.add(_as(x));
    }
    return BuResult.ok(out);
  }

  BuResult<BuBytes> _req32(List<int> x, String name) {
    if (x.length != 32) {
      return BuResult.err(
        BuError.length(what: name, expected: 32, actual: x.length),
      );
    }
    return BuResult.ok(_as(x));
  }

  @override
  BuResult<bool> bpPlusVerify(List<int> packed) {
    if (packed.isEmpty) {
      return BuResult.err(BuError.invalidArgument);
    }
    final rc = _b.moneroBpPlusVerify(_as(packed));
    if (rc == 0) {
      return BuResult.ok(true);
    }
    if (rc == 1) {
      return BuResult.ok(false);
    }
    return BuResult.err(_map(rc));
  }

  @override
  BuResult<BuBytes> bpPlusProveAmounts({
    required List<List<int>> amountsLe,
    required List<List<int>> gamma,
    required List<int> seed,
  }) {
    if (amountsLe.isEmpty || amountsLe.length > 16) {
      return BuResult.err(BuError.invalidArgument);
    }
    final as = _reqKeys(amountsLe, 'amountsLe', amountsLe.length, 8);
    if (as.isErr) {
      return BuResult.err(as.error!);
    }
    final gs = _reqKeys(gamma, 'gamma', amountsLe.length, 32);
    if (gs.isErr) {
      return BuResult.err(gs.error!);
    }
    final sd = _req32(seed, 'seed');
    if (sd.isErr) {
      return BuResult.err(sd.error!);
    }
    final out = <BuBytes>[];
    final rc = _b.moneroBpPlusProveAmounts(
      amountsLe: as.value!,
      gamma: gs.value!,
      seed32: sd.value!,
      outBlob: out,
    );
    if (rc != 0 || out.isEmpty) {
      return BuResult.err(_map(rc));
    }
    return BuResult.ok(out[0]);
  }

  @override
  BuResult<List<BuMoneroUnlockMatch>> unlockBatch({
    required List<BuMoneroScanAccount> accounts,
    required List<BuMoneroScanOutput> outputs,
  }) {
    const ctx = '$_tag.unlockBatch';
    if (accounts.isEmpty || outputs.isEmpty) {
      return BuResult.err(
        BuError(
          DefaultErrorType.invalidArgument,
          '$ctx: need ≥1 account and ≥1 output',
        ),
      );
    }
    final views = <BuBytes>[];
    final counts = <int>[];
    final spends = <BuBytes>[];
    for (final a in accounts) {
      if (a.viewSecret.length != 32 || a.spendPubs.isEmpty) {
        return BuResult.err(
          BuError(DefaultErrorType.invalidLength, '$ctx: bad account keys'),
        );
      }
      views.add(a.viewSecret);
      counts.add(a.spendPubs.length);
      for (final s in a.spendPubs) {
        if (s.length != 32) {
          return BuResult.err(
            BuError.length(what: 'spendPubs', expected: 32, actual: s.length),
          );
        }
        spends.add(s);
      }
    }
    final outKeys = <BuBytes>[];
    final txPubs = <BuBytes>[];
    final adds = <BuBytes>[];
    final present = <int>[];
    final tags = <int>[];
    final indices = <int>[];
    var anyAdd = false;
    var anyTag = false;
    for (var i = 0; i < outputs.length; i++) {
      final o = outputs[i];
      if (o.outKey.length != 32 || o.txPub.length != 32) {
        return BuResult.err(
          BuError(DefaultErrorType.invalidLength, '$ctx: bad output keys'),
        );
      }
      if (o.viewTag != null && (o.viewTag! < 0 || o.viewTag! > 255)) {
        return BuResult.err(
          BuError(DefaultErrorType.invalidArgument, '$ctx: bad view tag'),
        );
      }
      final idx = o.outIndex ?? i;
      if (idx < 0 || idx > 0xFFFFFFFF) {
        return BuResult.err(
          BuError(DefaultErrorType.invalidArgument, '$ctx: bad output index'),
        );
      }
      if (o.additionalPub != null && o.additionalPub!.length != 32) {
        return BuResult.err(
          BuError.length(
            what: 'additionalPub',
            expected: 32,
            actual: o.additionalPub!.length,
          ),
        );
      }
      outKeys.add(o.outKey);
      txPubs.add(o.txPub);
      adds.add(o.additionalPub ?? BuBytes.zero(32));
      present.add(o.additionalPub == null ? 0 : 1);
      tags.add(o.viewTag ?? -1);
      indices.add(idx);
      anyAdd = anyAdd || o.additionalPub != null;
      anyTag = anyTag || o.viewTag != null;
    }
    BuBytes u32s(List<int> vs) {
      final b = BuBytes.zero(4 * vs.length);
      for (var i = 0; i < vs.length; i++) {
        final v = vs[i];
        b[i * 4] = v & 0xFF;
        b[i * 4 + 1] = (v >> 8) & 0xFF;
        b[i * 4 + 2] = (v >> 16) & 0xFF;
        b[i * 4 + 3] = (v >> 24) & 0xFF;
      }
      return b;
    }

    BuBytes i32s(List<int> vs) {
      return u32s(vs.map((v) => v & 0xFFFFFFFF).toList());
    }

    final out = <BuBytes>[];
    final rc = _b.moneroUnlockBatch(
      viewSecrets: BuBytes.concat(views),
      spendPubs: BuBytes.concat(spends),
      spendCountsLe: u32s(counts),
      outKeys: BuBytes.concat(outKeys),
      txPubs: BuBytes.concat(txPubs),
      additional: anyAdd ? BuBytes.concat(adds) : BuBytes.empty(),
      additionalPresent: anyAdd ? BuBytes(present) : BuBytes.empty(),
      viewTagsLe: anyTag ? i32s(tags) : BuBytes.empty(),
      outIndicesLe: u32s(indices),
      outCount: outputs.length,
      accCount: accounts.length,
      outBlob: out,
    );
    if (rc != 0 || out.isEmpty) {
      // No matches is a valid empty result, not an error: native returns
      // OK with a zero-length blob. Distinguish via rc only.
      if (rc == 0) {
        return BuResult.ok(const []);
      }
      return BuResult.err(_map(rc));
    }
    try {
      return BuResult.ok(parseMoneroUnlockMatches(out[0]));
    } on BuError catch (e) {
      return BuResult.err(e);
    }
  }

  @override
  BuResult<BuBytes> bpPlusProveScalars({
    required List<List<int>> sv,
    required List<List<int>> gamma,
    required List<int> seed,
  }) {
    if (sv.isEmpty || sv.length > 16) {
      return BuResult.err(BuError.invalidArgument);
    }
    final ss = _reqKeys(sv, 'sv', sv.length, 32);
    if (ss.isErr) {
      return BuResult.err(ss.error!);
    }
    final gs = _reqKeys(gamma, 'gamma', sv.length, 32);
    if (gs.isErr) {
      return BuResult.err(gs.error!);
    }
    final sd = _req32(seed, 'seed');
    if (sd.isErr) {
      return BuResult.err(sd.error!);
    }
    final out = <BuBytes>[];
    final rc = _b.moneroBpPlusProveScalars(
      sv: ss.value!,
      gamma: gs.value!,
      seed32: sd.value!,
      outBlob: out,
    );
    if (rc != 0 || out.isEmpty) {
      return BuResult.err(_map(rc));
    }
    return BuResult.ok(out[0]);
  }
}
