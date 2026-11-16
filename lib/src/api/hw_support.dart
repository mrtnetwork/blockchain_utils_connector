/// Hardware-wallet capability declarations.
///
/// A device either supports a coin or it doesn't — but that is the wrong
/// granularity. Support varies *within* a coin by address/script variant
/// (BTC `p2pkh` vs `p2wpkh`: BitBox02 does the second, never the first) or
/// by curve (XRPL `secp256k1` vs `ed25519`: Ledger does both via its
/// `ed25519` flag, Trezor only the first). Hence the key of every table
/// here is `(coin, variant)`, never just the coin:
///
/// ```dart
/// Map<String, List<HwVariantSupport>> hwSupport = {
///   'p2wpkh': [HwVariantSupport(device: BuHwKind.bitBox02, ...)],
/// };
/// ```
///
/// A flat `List<HwVariantSupport>` per coin cannot express any of that: one
/// entry would have to claim "Trezor supports bitcoin" while hiding that it
/// holds per script type, or duplicate the coin per variant. The map keeps
/// one row per coin and one honest answer per variant. Missing key =
/// `unknown` (never shipped as supported).
library;

/// Device kind with its wire-stable int id (mirrors [BuHwDevice] ids;
/// order append-only, never reorder).
enum BuHwKind {
  ledgerNanoSPlus(0),
  ledgerNanoX(1),
  ledgerFlex(2),
  ledgerStax(3),
  trezorOne(4),
  trezorModelT(5),
  trezorSafe3(6),
  trezorSafe5(7),
  trezorSafe7(8),
  keepKey(9),
  oneKey(10),
  bitBox02(11),
  passport(12),
  keystone3(13),
  keystonePro(14),
  coldcardQr(15),
  jadeQr(16);

  const BuHwKind(this.id);

  /// Wire-stable int id (matches `BuHwDevice.*` constants).
  final int id;

  /// Lookup by id; `null` for unknown ids (never throw in UI paths).
  static BuHwKind? fromId(int id) {
    for (final k in BuHwKind.values) {
      if (k.id == id) {
        return k;
      }
    }
    return null;
  }
}

/// How far a (device, coin-variant) pair has gotten. Ordered so `max`
/// collapses "best device for this variant": a definite answer beats no
/// answer (`impossible` > `unknown`), a built codec beats claims.
enum HwReadiness {
  /// Not yet checked on a live device/emulator. Shippable: UI shows
  /// "not verified", never a dead Sign button.
  unknown,

  /// Structurally impossible (BitBox02 + anything outside BTC/LTC/ETH/ADA;
  /// Trezor + ALGO/HBAR). Only a firmware release changes this.
  impossible,

  /// Firmware can do it, our codec cannot yet. "Coming soon" with [why].
  needsAppWork,

  /// Codec exists AND a live proof ran (banked in `latest.md`). The only
  /// state allowed to enable a real Sign button.
  ready,
}

/// One support claim: which device, for which variant, how proven.
class HwVariantSupport {
  const HwVariantSupport({
    required this.device,
    required this.variant,
    required this.readiness,
    this.models = '',
    this.why = '',
  });

  /// The device (typed; [BuHwKind.id] matches `BuHwDevice` ids).
  final BuHwKind device;

  /// Address/script variant this claim is about (`'p2pkh' | 'p2wpkh' |
  /// 'p2sh' | 'p2tr'` for UTXO coins, curve name for the rest).
  final String variant;

  /// How far this pair has gotten.
  final HwReadiness readiness;

  /// Model constraints, e.g. "Safe 3/5/7 (not One)", "Model T only".
  /// Empty = every model of that family.
  final String models;

  /// Provenance — ALWAYS filled: "live-proven 2026-10-06",
  /// "trezor.io/coins", "needs Speculos proof", ...
  final String why;
}

/// Resolver: support entries for one variant key. Missing/empty table
/// yields `[]` (caller treats as `unknown`, never as supported).
List<HwVariantSupport> hwFor(List<HwVariantSupport>? table, String variant) {
  if (table == null) {
    return const [];
  }
  return table.where((s) => s.variant == variant).toList();
}

/// Best readiness in a support list (for "can anything sign this?" checks).
/// Empty list → [HwReadiness.unknown].
HwReadiness hwBest(List<HwVariantSupport> supports) {
  var best = HwReadiness.unknown;
  for (final s in supports) {
    if (s.readiness.index > best.index) best = s.readiness;
  }
  return best;
}
