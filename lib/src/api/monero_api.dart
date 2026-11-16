import 'package:blockchain_utils_connector/src/bytes/bytes.dart';
import 'package:blockchain_utils_connector/src/error/bu_error.dart';

/// Monero RingCT API (Bulletproofs+).
abstract interface class BuMoneroApi {
  /// Verify a packed batch of Bulletproofs+ proofs.
  ///
  /// `packed` layout: `n: u32 LE` followed by `n` entries of
  /// `len: u32 LE | blob[len]` (see Rust `monero::bulletproofs_plus` docs).
  /// Returns `true` iff every proof is valid.
  BuResult<bool> bpPlusVerify(List<int> packed);

  /// Prove a Bulletproofs+ for `amountsLe` (each 8 bytes little-endian u64)
  /// with `gamma` masks (each 32 bytes) and a caller-supplied 32-byte `seed`
  /// driving the prover RNG (deterministic per seed; pass fresh randomness
  /// per proof). Returns one proof blob.
  BuResult<BuBytes> bpPlusProveAmounts({
    required List<List<int>> amountsLe,
    required List<List<int>> gamma,
    required List<int> seed,
  });

  /// Prove a Bulletproofs+ for raw bit-scalar vectors (`sv`, each 32 bytes)
  /// with `gamma` masks. Returns one proof blob.
  BuResult<BuBytes> bpPlusProveScalars({
    required List<List<int>> sv,
    required List<List<int>> gamma,
    required List<int> seed,
  });

  /// Batch output scan (fast unlock). Ports
  /// `onchain_crypto_c:monero_unlock_outputs_batch_compact`: per
  /// (account, output) derives `D = 8·v·R`, prefilters the view tag, and
  /// recomputes `P = B + Hs(D‖i)·G` for every subaddress spend key.
  ///
  /// Returns matches with derivation + derived key (needed downstream for
  /// amount decode and key images). Amount decode stays caller-side.
  BuResult<List<BuMoneroUnlockMatch>> unlockBatch({
    required List<BuMoneroScanAccount> accounts,
    required List<BuMoneroScanOutput> outputs,
  });
}

/// One account's scan keys: secret view key (32) + subaddress spend
/// pubkeys (each 32). Match `addressPos` indexes into [spendPubs].
class BuMoneroScanAccount {
  BuMoneroScanAccount({required List<int> viewSecret, required this.spendPubs})
    : viewSecret = BuBytes.from(viewSecret);
  final BuBytes viewSecret;
  final List<BuBytes> spendPubs;
}

/// One output's scan data: output key (32), tx pubkey (32), optional
/// per-output additional pubkey, optional view tag byte (null = absent,
/// e.g. pre-v0.18 outputs), and the real output index within its transaction
/// (null = use the output's position in the batch; only correct when
/// scanning a single transaction with no skipped outputs).
class BuMoneroScanOutput {
  BuMoneroScanOutput({
    required List<int> outKey,
    required List<int> txPub,
    List<int>? additionalPub,
    this.viewTag,
    this.outIndex,
  }) : outKey = BuBytes.from(outKey),
       txPub = BuBytes.from(txPub),
       additionalPub =
           additionalPub == null
               ? null
               : (additionalPub is BuBytes
                   ? additionalPub
                   : BuBytes.from(additionalPub));
  final BuBytes outKey;
  final BuBytes txPub;
  final BuBytes? additionalPub;
  final int? viewTag;
  final int? outIndex;
}

/// One matched output. `derivation` + `derivedPk` feed amount decode
/// and key-image computation downstream.
class BuMoneroUnlockMatch {
  BuMoneroUnlockMatch({
    required this.outIndex,
    required this.accountIndex,
    required this.addressPos,
    required this.derivation,
    required this.derivedPk,
  });
  final int outIndex;
  final int accountIndex;
  final int addressPos;
  final BuBytes derivation;
  final BuBytes derivedPk;

  /// Packed record length: 3×u32 LE + 32 + 32 = 76 bytes.
  static const recordLen = 76;
}

/// Parse packed 76-byte match records (native `bu_monero_unlock_batch` /
/// `moneroUnlockBatch` output). Throws [BuError] on bad length.
List<BuMoneroUnlockMatch> parseMoneroUnlockMatches(List<int> packed) {
  if (packed.length % BuMoneroUnlockMatch.recordLen != 0) {
    throw BuError(
      DefaultErrorType.invalidLength,
      'monero.unlockBatch: bad match blob',
    );
  }
  int u32(int o) =>
      packed[o] |
      (packed[o + 1] << 8) |
      (packed[o + 2] << 16) |
      (packed[o + 3] << 24);
  final out = <BuMoneroUnlockMatch>[];
  for (var o = 0; o < packed.length; o += BuMoneroUnlockMatch.recordLen) {
    out.add(
      BuMoneroUnlockMatch(
        outIndex: u32(o),
        accountIndex: u32(o + 4),
        addressPos: u32(o + 8),
        derivation: BuBytes(packed.sublist(o + 12, o + 44)),
        derivedPk: BuBytes(packed.sublist(o + 44, o + 76)),
      ),
    );
  }
  return out;
}
