import 'package:blockchain_utils_connector/src/bytes/bytes.dart';
import 'package:blockchain_utils_connector/src/error/bu_error.dart';

/// MuSig2 secret/public nonce pair (secnonce 97 bytes, pubnonce 66 bytes).
class BuMusig2Nonce {
  const BuMusig2Nonce({required this.secnonce, required this.pubnonce});
  final BuBytes secnonce;
  final BuBytes pubnonce;
}

/// Optional key aggregation tweak.
class BuMusig2Tweak {
  const BuMusig2Tweak({required this.tweak32, this.isXOnly = true});
  final BuBytes tweak32;
  final bool isXOnly;
}

/// BIP-327 MuSig2 surface matching Dart `MuSig2` / `Musig2Context`.
abstract interface class BuMusig2Api {
  /// True if 33-byte compressed or 32-byte x-only public key is valid.
  bool isValidPublicKey(List<int> publicKey, {bool xOnly = false});

  /// True if 32-byte secret is in [1, n-1].
  bool isValidSecretKey(List<int> secret);

  /// Sort compressed public keys (lexicographic).
  BuResult<List<BuBytes>> sortPublicKeys(List<BuBytes> keys);

  /// Aggregate public keys → 33-byte compressed Q.
  BuResult<BuBytes> keyAgg(List<BuBytes> keys);

  /// Aggregate public keys with optional tweaks → 33-byte compressed Q.
  BuResult<BuBytes> keyAggAndTweak({
    required List<BuBytes> keys,
    List<BuMusig2Tweak> tweaks = const [],
  });

  /// Generate nonce pair. `publicKey` is required (33-byte compressed).
  /// `rand` is required (32-byte caller-provided CSPRNG output).
  BuResult<BuMusig2Nonce> nonceGenerate({
    required BuBytes publicKey,
    BuBytes? sk,
    BuBytes? aggPubKey,
    BuBytes? msg,
    BuBytes? extra,
    required BuBytes rand,
  });

  /// Aggregate public nonces (each 66 bytes) → 66-byte aggnonce.
  BuResult<BuBytes> nonceAgg(List<BuBytes> pubnonces);

  /// Partial signature (32 bytes).
  BuResult<BuBytes> partialSign({
    required BuBytes secnonce,
    required BuBytes sk,
    required List<BuBytes> publicKeys,
    required BuBytes aggnonce,
    required BuBytes msg,
    List<BuMusig2Tweak> tweaks = const [],
  });

  /// Aggregate partials → BIP-340 64-byte signature.
  BuResult<BuBytes> partialSigAgg({
    required List<BuBytes> partials,
    required List<BuBytes> publicKeys,
    required BuBytes aggnonce,
    required BuBytes msg,
    List<BuMusig2Tweak> tweaks = const [],
  });

  /// Verify one participant's partial signature.
  BuResult<bool> partialSigVerify({
    required BuBytes partial,
    required BuBytes pubnonce,
    required BuBytes pk,
    required List<BuBytes> publicKeys,
    required BuBytes aggnonce,
    required BuBytes msg,
    List<BuMusig2Tweak> tweaks = const [],
  });

  /// BIP-327 DeterministicSign → pubnonce (66) + partial (32).
  BuResult<BuMusig2DeterministicSignature> deterministicSign({
    required BuBytes sk,
    required BuBytes aggotherNonce66,
    required List<BuBytes> publicKeys,
    required BuBytes msg,
    List<BuMusig2Tweak> tweaks = const [],
    BuBytes? rand,
  });

  /// BIP-340 verify of a MuSig2 aggregate signature vs x-only aggregate key.
  BuResult<bool> verifyAggregate({
    required BuBytes message,
    required BuBytes signature64,
    required BuBytes aggXOnly32,
  });
}

/// Result of BIP-327 DeterministicSign.
class BuMusig2DeterministicSignature {
  const BuMusig2DeterministicSignature({
    required this.pubnonce,
    required this.partial,
  });
  final BuBytes pubnonce;
  final BuBytes partial;
}
