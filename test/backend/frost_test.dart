import 'package:blockchain_utils_connector/blockchain_utils_connector.dart';
import 'package:test/test.dart';

import '../test_utils.dart';

/// FROST reshare roundtrips + rejection contracts.
///
/// Runs on FFI and WASM: all vectors are inline data in this file, opened
/// through [openBu].
void runFrostSuite(Bu Function() openBu) {
  BuFrostApi apiOf() => openBu().frost;

  BuBytes secretBase(int b) => BuBytes(List<int>.filled(32, b));

  BuBytes ids123() => BuBytes([1, 0, 0, 0, 2, 0, 0, 0, 3, 0, 0, 0]);

  BuBytes threeSecrets() => BuBytes([
    ...List<int>.filled(32, 0x11),
    ...List<int>.filled(32, 0x22),
    ...List<int>.filled(32, 0x33),
  ]);

  BuBytes threeCoeffs() => BuBytes([
    ...List<int>.filled(32, 0x44),
    ...List<int>.filled(32, 0x55),
    ...List<int>.filled(32, 0x66),
  ]);

  test('frostK1Reshare happy path ', () {
    final api = apiOf();
    final ids = ids123();
    final secrets = threeSecrets();
    final coeffs = threeCoeffs();
    final res = api.frostK1Reshare(
      idsConcat: ids,
      secretsConcat: secrets,
      n: 3,
      coeffsConcat: coeffs,
      nCoeffs: 3,
      threshold: 2,
    );
    expect(res.isOk, isTrue, reason: '${res.error}');
    final out = res.value!;
    expect(out.sharesConcat.length, 96);
    expect(out.pubsConcat.length, 99);
    expect(out.group.length, 33);
    // Determinism: second call identical.
    final res2 = api.frostK1Reshare(
      idsConcat: ids,
      secretsConcat: secrets,
      n: 3,
      coeffsConcat: coeffs,
      nCoeffs: 3,
      threshold: 2,
    );
    expect(res2.isOk, isTrue, reason: '${res2.error}');
    expect(res2.value!.sharesConcat.toList(), out.sharesConcat.toList());
    expect(res2.value!.pubsConcat.toList(), out.pubsConcat.toList());
    expect(res2.value!.group.toList(), out.group.toList());
  });

  test('frostEdReshare happy path ', () {
    final api = apiOf();
    final ids = ids123();
    final secrets = threeSecrets();
    final coeffs = threeCoeffs();
    final res = api.frostEdReshare(
      idsConcat: ids,
      secretsConcat: secrets,
      n: 3,
      coeffsConcat: coeffs,
      nCoeffs: 3,
      threshold: 2,
    );
    expect(res.isOk, isTrue, reason: '${res.error}');
    final out = res.value!;
    expect(out.sharesConcat.length, 96);
    expect(out.pubsConcat.length, 96);
    expect(out.group.length, 32);
    // Determinism: second call identical.
    final res2 = api.frostEdReshare(
      idsConcat: ids,
      secretsConcat: secrets,
      n: 3,
      coeffsConcat: coeffs,
      nCoeffs: 3,
      threshold: 2,
    );
    expect(res2.isOk, isTrue, reason: '${res2.error}');
    expect(res2.value!.sharesConcat.toList(), out.sharesConcat.toList());
    expect(res2.value!.pubsConcat.toList(), out.pubsConcat.toList());
    expect(res2.value!.group.toList(), out.group.toList());
  });

  test('frostK1Reshare rejects bad threshold', () {
    final api = apiOf();
    final bad = api.frostK1Reshare(
      idsConcat: ids123(),
      secretsConcat: threeSecrets(),
      n: 3,
      coeffsConcat: threeCoeffs(),
      nCoeffs: 3,
      threshold: 1,
    );
    expect(bad.isErr, isTrue);
  });

  test('frostK1Reshare rejects bad coeffs length', () {
    final api = apiOf();
    final bad = api.frostK1Reshare(
      idsConcat: ids123(),
      secretsConcat: threeSecrets(),
      n: 3,
      coeffsConcat: secretBase(0x44),
      nCoeffs: 1,
      threshold: 2,
    );
    expect(bad.isErr, isTrue);
  });

  test('frostEdReshare rejects bad threshold', () {
    final api = apiOf();
    final bad = api.frostEdReshare(
      idsConcat: ids123(),
      secretsConcat: threeSecrets(),
      n: 3,
      coeffsConcat: threeCoeffs(),
      nCoeffs: 3,
      threshold: 1,
    );
    expect(bad.isErr, isTrue);
  });

  test('frostEdReshare rejects bad coeffs length', () {
    final api = apiOf();
    final bad = api.frostEdReshare(
      idsConcat: ids123(),
      secretsConcat: threeSecrets(),
      n: 3,
      coeffsConcat: secretBase(0x44),
      nCoeffs: 1,
      threshold: 2,
    );
    expect(bad.isErr, isTrue);
  });

  test('frostK1 2-of-3 threshold sign -> aggregate -> verify', () {
    final api = apiOf();
    final msg = BuBytes(List<int>.generate(32, (i) => i + 1));
    // Dealer: secret + 1 coeff (t=2), 3 members.
    final shard =
        api
            .frostK1Shard(
              secret32: secretBase(0x11),
              coeffsConcat: secretBase(0x44),
              nCoeffs: 1,
              max: 3,
            )
            .unwrapOrThrow();
    expect(shard.sharesConcat.length, 3 * 36);
    // Signers {1, 2}: first two 36-byte records (id:u32le || share:32).
    final shares2 = BuBytes(shard.sharesConcat.sublist(0, 72));
    final scalars =
        api
            .frostK1PrepareShares(sharesConcat: shares2, n: 2, threshold: 2)
            .unwrapOrThrow();
    final s1 = BuBytes(scalars.sublist(0, 32));
    final s2 = BuBytes(scalars.sublist(32, 64));
    // Group key + member pubs from the Feldman VSS commitment over the
    // full polynomial (secret ++ coeffs).
    final vss =
        api
            .frostK1VssCommit(
              coeffsConcat: BuBytes([...secretBase(0x11), ...secretBase(0x44)]),
              nCoeffs: 2,
            )
            .unwrapOrThrow();
    final info =
        api.frostK1GroupInfo(vssConcat: vss, nComms: 2, max: 3).unwrapOrThrow();
    final group = info.group;
    final pk1 = BuBytes(info.pksConcat.sublist(0, 33));
    final pk2 = BuBytes(info.pksConcat.sublist(33, 66));
    // Round 1: per-signer commits (fixed randomness).
    final n1 =
        api
            .frostK1Commit(
              secretShare32: s1,
              hidingRand32: secretBase(0xA1),
              bindingRand32: secretBase(0xA2),
            )
            .unwrapOrThrow();
    final n2 =
        api
            .frostK1Commit(
              secretShare32: s2,
              hidingRand32: secretBase(0xA3),
              bindingRand32: secretBase(0xA4),
            )
            .unwrapOrThrow();
    BuBytes rec(int id, BuFrostNonces n) => BuBytes([
      id & 0xFF,
      (id >> 8) & 0xFF,
      (id >> 16) & 0xFF,
      (id >> 24) & 0xFF,
      ...n.hidingCommitment,
      ...n.bindingCommitment,
    ]);
    final commitments = BuBytes([...rec(1, n1), ...rec(2, n2)]);
    final factors =
        api
            .frostK1BindingFactors(
              groupPk33: group,
              commitmentsConcat: commitments,
              n: 2,
              msg: msg,
            )
            .unwrapOrThrow();
    final r =
        api
            .frostK1GroupCommitment(
              commitmentsConcat: commitments,
              factorsConcat: factors,
              n: 2,
            )
            .unwrapOrThrow();
    expect(r, hasLength(33));
    // Round 2: signature shares + per-share verification.
    final sh1 =
        api
            .frostK1Sign(
              id: 1,
              secretShare32: s1,
              groupPk33: group,
              nonces: n1,
              commitmentsConcat: commitments,
              n: 2,
              msg: msg,
            )
            .unwrapOrThrow();
    final sh2 =
        api
            .frostK1Sign(
              id: 2,
              secretShare32: s2,
              groupPk33: group,
              nonces: n2,
              commitmentsConcat: commitments,
              n: 2,
              msg: msg,
            )
            .unwrapOrThrow();
    BuFrostCommitment commOf(int id, BuFrostNonces n) => BuFrostCommitment(
      id: id,
      hiding: n.hidingCommitment,
      binding: n.bindingCommitment,
    );
    expect(
      api
          .frostK1VerifyShare(
            id: 1,
            pkShare33: pk1,
            comm: commOf(1, n1),
            share32: sh1,
            commitmentsConcat: commitments,
            n: 2,
            groupPk33: group,
            msg: msg,
          )
          .unwrapOrThrow(),
      isTrue,
    );
    expect(
      api
          .frostK1VerifyShare(
            id: 2,
            pkShare33: pk2,
            comm: commOf(2, n2),
            share32: sh2,
            commitmentsConcat: commitments,
            n: 2,
            groupPk33: group,
            msg: msg,
          )
          .unwrapOrThrow(),
      isTrue,
    );
    // Aggregate + verify the joint signature.
    final agg =
        api
            .frostK1Aggregate(
              commitmentsConcat: commitments,
              n: 2,
              msg: msg,
              groupPk33: group,
              sharesConcat: BuBytes([...sh1, ...sh2]),
              nShares: 2,
            )
            .unwrapOrThrow();
    expect(agg.r, r);
    expect(
      api
          .frostK1Verify(r33: agg.r, z32: agg.z, groupPk33: group, msg: msg)
          .unwrapOrThrow(),
      isTrue,
    );
    expect(
      api
          .frostK1Verify(
            r33: agg.r,
            z32: agg.z,
            groupPk33: group,
            msg: BuBytes(List<int>.filled(32, 9)),
          )
          .unwrapOrThrow(),
      isFalse,
    );
  });
}

/// Standalone entry: `dart test test/backend/frost_test.dart` (VM, FFI backend).
void main() async {
  await ConnectorTestApi.ensureBackend();
  runFrostSuite(() => ConnectorTestApi.bu);
}
