import 'package:blockchain_utils_connector/src/bytes/bytes.dart';
import 'package:blockchain_utils_connector/src/error/bu_error.dart';

/// One FROST key share record: `[id:u32 LE][share:32]`.
class BuFrostShare {
  const BuFrostShare({required this.id, required this.share});
  final int id;
  final BuBytes share;
}

/// One FROST commitment record: `[id:u32 LE][hiding][binding]`
/// (33-byte points for secp256k1, 32-byte for Ed25519).
class BuFrostCommitment {
  const BuFrostCommitment({
    required this.id,
    required this.hiding,
    required this.binding,
  });
  final int id;
  final BuBytes hiding;
  final BuBytes binding;
}

/// One binding-factor record: `[id:u32 LE][rho:32]`.
class BuFrostFactor {
  const BuFrostFactor({required this.id, required this.rho});
  final int id;
  final BuBytes rho;
}

/// RFC 9591 FROST signing surface (both ciphersuites).
///
/// `k1` = FROST(secp256k1, SHA-256): points 33 bytes, signatures 65 bytes.
/// `ed` = FROST(Ed25519, SHA-512): points 32 bytes, signatures 64 bytes.
/// Identifiers are `u32` (`1..=MAX_PARTICIPANTS`).
abstract interface class BuFrostApi {
  // -- secp256k1 suite --
  /// Dealer shard: secret + coeffs → share records + full polynomial.
  BuResult<BuFrostShard> frostK1Shard({
    required BuBytes secret32,
    required BuBytes coeffsConcat,
    required int nCoeffs,
    required int max,
  });

  /// Combine share records → secret.
  BuResult<BuBytes> frostK1Combine(BuBytes sharesConcat, int n);

  /// Round-1 commit → hiding/binding scalars + commitments.
  BuResult<BuFrostNonces> frostK1Commit({
    required BuBytes secretShare32,
    required BuBytes hidingRand32,
    required BuBytes bindingRand32,
  });

  /// Binding factors for a commitment list.
  BuResult<BuBytes> frostK1BindingFactors({
    required BuBytes groupPk33,
    required BuBytes commitmentsConcat,
    required int n,
    required BuBytes msg,
  });

  /// Group commitment `R` (33 bytes).
  BuResult<BuBytes> frostK1GroupCommitment({
    required BuBytes commitmentsConcat,
    required BuBytes factorsConcat,
    required int n,
  });

  /// Round-2 signature share (32 bytes).
  BuResult<BuBytes> frostK1Sign({
    required int id,
    required BuBytes secretShare32,
    required BuBytes groupPk33,
    required BuFrostNonces nonces,
    required BuBytes commitmentsConcat,
    required int n,
    required BuBytes msg,
  });

  /// Aggregate shares → `(R, z)`.
  BuResult<BuFrostSignature> frostK1Aggregate({
    required BuBytes commitmentsConcat,
    required int n,
    required BuBytes msg,
    required BuBytes groupPk33,
    required BuBytes sharesConcat,
    required int nShares,
  });

  /// Verify one share.
  BuResult<bool> frostK1VerifyShare({
    required int id,
    required BuBytes pkShare33,
    required BuFrostCommitment comm,
    required BuBytes share32,
    required BuBytes commitmentsConcat,
    required int n,
    required BuBytes groupPk33,
    required BuBytes msg,
  });

  /// Verify a final `(R, z)` signature.
  BuResult<bool> frostK1Verify({
    required BuBytes r33,
    required BuBytes z32,
    required BuBytes groupPk33,
    required BuBytes msg,
  });

  /// Feldman VSS commitment: `nCoeffs` scalars → `nCoeffs` 33-byte points.
  BuResult<BuBytes> frostK1VssCommit({
    required BuBytes coeffsConcat,
    required int nCoeffs,
  });
  // -- threshold-quorum helpers (pure secret math lives in the backend) --
  /// Expand + additive-rescale `n` share records (`[id:u32][share:32]`)
  /// → `n` 32-byte signing scalars. `threshold`: 0 = additive rescale,
  /// else Shamir passthrough.
  BuResult<BuBytes> frostK1PrepareShares({
    required BuBytes sharesConcat,
    required int n,
    required int threshold,
  });

  /// Group key from member points: `ids` (`n` u32 LE) + `pubs`
  /// (`n` x 33 B). `threshold`: 0 = sum, else Lagrange at zero.
  BuResult<BuBytes> frostK1GroupFromMembers({
    required BuBytes idsConcat,
    required BuBytes pubsConcat,
    required int n,
    required int threshold,
  });

  /// Group key + `max` member keys from a VSS commitment (`nComms` points).
  BuResult<BuFrostGroupInfo> frostK1GroupInfo({
    required BuBytes vssConcat,
    required int nComms,
    required int max,
  });

  /// Reshare `n` secrets to a new threshold committee: `ids` (`n` u32 LE)
  /// + `secrets` (`n` x 32 B) + `coeffs` (`nCoeffs` x 32 B) →
  /// new shares + member pubs + group key.
  BuResult<BuFrostReshare> frostK1Reshare({
    required BuBytes idsConcat,
    required BuBytes secretsConcat,
    required int n,
    required BuBytes coeffsConcat,
    required int nCoeffs,
    required int threshold,
  });

  // -- Ed25519 suite (same shapes, 32-byte points / 64-byte sigs) --
  // `isScalar`: true (default) = 32-byte canonical scalars, false = RFC 8032
  // seeds expanded in the backend (SHA-512 + clamp). k1 has no flag:
  // key bytes already are the scalar.
  BuResult<BuFrostShard> frostEdShard({
    required BuBytes secret32,
    required BuBytes coeffsConcat,
    required int nCoeffs,
    required int max,
    bool isScalar = true,
  });
  BuResult<BuBytes> frostEdCombine(
    BuBytes sharesConcat,
    int n, {
    bool isScalar = true,
  });
  BuResult<BuFrostNonces> frostEdCommit({
    required BuBytes secretShare32,
    required BuBytes hidingRand32,
    required BuBytes bindingRand32,
    bool isScalar = true,
  });
  BuResult<BuBytes> frostEdBindingFactors({
    required BuBytes groupPk32,
    required BuBytes commitmentsConcat,
    required int n,
    required BuBytes msg,
  });
  BuResult<BuBytes> frostEdGroupCommitment({
    required BuBytes commitmentsConcat,
    required BuBytes factorsConcat,
    required int n,
  });
  BuResult<BuBytes> frostEdSign({
    required int id,
    required BuBytes secretShare32,
    required BuBytes groupPk32,
    required BuFrostNonces nonces,
    required BuBytes commitmentsConcat,
    required int n,
    required BuBytes msg,
    bool isScalar = true,
  });
  BuResult<BuFrostSignature> frostEdAggregate({
    required BuBytes commitmentsConcat,
    required int n,
    required BuBytes msg,
    required BuBytes groupPk32,
    required BuBytes sharesConcat,
    required int nShares,
  });
  BuResult<bool> frostEdVerifyShare({
    required int id,
    required BuBytes pkShare32,
    required BuFrostCommitment comm,
    required BuBytes share32,
    required BuBytes commitmentsConcat,
    required int n,
    required BuBytes groupPk32,
    required BuBytes msg,
  });
  BuResult<bool> frostEdVerify({
    required BuBytes r32,
    required BuBytes z32,
    required BuBytes groupPk32,
    required BuBytes msg,
  });

  /// Feldman VSS commitment: `nCoeffs` scalars → `nCoeffs` 32-byte points.
  BuResult<BuBytes> frostEdVssCommit({
    required BuBytes coeffsConcat,
    required int nCoeffs,
  });
  // -- threshold-quorum helpers (pure secret math lives in the backend) --
  /// Expand (`isScalar`: false = RFC 8032 seeds) + additive-rescale `n`
  /// share records → `n` 32-byte signing scalars. `threshold`: 0 =
  /// additive rescale, else Shamir passthrough.
  BuResult<BuBytes> frostEdPrepareShares({
    required BuBytes sharesConcat,
    required int n,
    required int threshold,
    bool isScalar = true,
  });

  /// Group key from member points: `ids` (`n` u32 LE) + `pubs`
  /// (`n` x 32 B). `threshold`: 0 = sum, else Lagrange at zero.
  BuResult<BuBytes> frostEdGroupFromMembers({
    required BuBytes idsConcat,
    required BuBytes pubsConcat,
    required int n,
    required int threshold,
  });

  /// Group key + `max` member keys from a VSS commitment (`nComms` points).
  BuResult<BuFrostGroupInfo> frostEdGroupInfo({
    required BuBytes vssConcat,
    required int nComms,
    required int max,
  });

  /// Reshare `n` secrets to a new threshold committee (Ed25519 suite).
  BuResult<BuFrostReshare> frostEdReshare({
    required BuBytes idsConcat,
    required BuBytes secretsConcat,
    required int n,
    required BuBytes coeffsConcat,
    required int nCoeffs,
    required int threshold,
  });
}

/// Dealer shard output: share records + full polynomial coefficients.
class BuFrostShard {
  const BuFrostShard({required this.sharesConcat, required this.polyConcat});

  /// `max` records of 36 bytes each.
  final BuBytes sharesConcat;

  /// `(1 + nCoeffs)` scalars of 32 bytes each.
  final BuBytes polyConcat;
}

/// Group info output: group key + member public keys.
class BuFrostGroupInfo {
  const BuFrostGroupInfo({required this.group, required this.pksConcat});

  /// Group public key (`elen` bytes).
  final BuBytes group;

  /// `max` concatenated member public keys (`elen` bytes each).
  final BuBytes pksConcat;
}

/// Reshare output: new secret shares + member pubs + group key.
class BuFrostReshare {
  const BuFrostReshare({
    required this.sharesConcat,
    required this.pubsConcat,
    required this.group,
  });

  /// `n` concatenated 32-byte secret shares.
  final BuBytes sharesConcat;

  /// `n` concatenated member public keys (33 bytes k1 / 32 bytes ed).
  final BuBytes pubsConcat;

  /// Group public key (33 bytes k1 / 32 bytes ed).
  final BuBytes group;
}

/// Round-1 nonce output.
class BuFrostNonces {
  const BuFrostNonces({
    required this.hiding,
    required this.binding,
    required this.hidingCommitment,
    required this.bindingCommitment,
  });
  final BuBytes hiding;
  final BuBytes binding;
  final BuBytes hidingCommitment;
  final BuBytes bindingCommitment;
}

/// Final FROST signature `(R, z)`.
class BuFrostSignature {
  const BuFrostSignature({required this.r, required this.z});
  final BuBytes r;
  final BuBytes z;
}
