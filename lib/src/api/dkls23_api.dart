import 'package:blockchain_utils_connector/src/bytes/bytes.dart';
import 'package:blockchain_utils_connector/src/error/bu_error.dart';

/// DKLs23 threshold ECDSA curve selector (matches the native `curve` id:
/// `0` = secp256k1, `1` = secp256r1).
enum BuDkls23Curve {
  secp256k1(0),
  secp256r1(1);

  const BuDkls23Curve(this.id);
  final int id;
}

/// DKLs23 threshold ECDSA surface.
///
/// Shares cross the boundary as framed blobs of fixed-size keyshare
/// records (`frame([share, …])`, see the native codec): DKG and refresh
/// return such blobs, sign consumes one. Signatures are compact
/// `r(32) || s(32)` (64 bytes, low-S); message hashes and per-party
/// seeds are 32 bytes.
abstract interface class BuDkls23Api {
  /// Full DKG ceremony (`n` parties, threshold `t`) from `n` 32-byte
  /// seeds → framed shares blob.
  BuResult<BuBytes> dkg({
    required BuDkls23Curve curve,
    required BuBytes sid,
    required int n,
    required int t,
    required BuBytes seeds,
  });

  /// Threshold-sign a 32-byte message hash with a framed shares blob
  /// (any `>= t` subset; per-share seeds aligned by position) → 64-byte
  /// compact signature.
  BuResult<BuBytes> sign({
    required BuDkls23Curve curve,
    required BuBytes sid,
    required BuBytes msgHash32,
    required BuBytes sharesBlob,
    required BuBytes seeds,
  });

  /// Rotate shares (group key unchanged) → framed shares blob.
  BuResult<BuBytes> refresh({
    required BuBytes sid,
    required BuBytes sharesBlob,
    required BuBytes seeds,
  });

  /// Verify a compact signature against a 33-byte group key.
  BuResult<bool> verify({
    required BuDkls23Curve curve,
    required BuBytes groupPk33,
    required BuBytes msgHash32,
    required BuBytes sig64,
  });

  /// Aggregate member public keys (`n` × 33 bytes) → group key (33 bytes).
  BuResult<BuBytes> aggKeys({
    required BuDkls23Curve curve,
    required BuBytes membersConcat,
    required int n,
  });

  /// X-only form of a group key → 32 bytes.
  BuResult<BuBytes> xOnly({
    required BuDkls23Curve curve,
    required BuBytes groupPk33,
  });

  /// Import existing secrets as an additive n-of-n quorum (no DKG):
  /// `n` × 32-byte secrets → framed shares blob.
  BuResult<BuBytes> importSecrets({
    required BuDkls23Curve curve,
    required BuBytes secretsConcat,
    required int n,
  });
}
