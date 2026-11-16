import 'package:blockchain_utils_connector/src/bytes/bytes.dart';
import 'package:blockchain_utils_connector/src/error/bu_error.dart';

class BuEcdsaSignature {
  const BuEcdsaSignature({required this.r, required this.s, this.recoveryId});
  final BuBytes r;
  final BuBytes s;
  final int? recoveryId;

  BuBytes get compact {
    final o = BuBytes.zero(64);
    for (var i = 0; i < 32; i++) {
      o[i] = r[i];
      o[32 + i] = s[i];
    }
    return o;
  }

  factory BuEcdsaSignature.fromCompact(BuBytes c, {int? recoveryId}) {
    if (c.length != 64) {
      throw BuError.length(
        what: 'compact signature',
        expected: 64,
        actual: c.length,
      );
    }
    final r = BuBytes.zero(32);
    final s = BuBytes.zero(32);
    for (var i = 0; i < 32; i++) {
      r[i] = c[i];
      s[i] = c[32 + i];
    }
    return BuEcdsaSignature(r: r, s: s, recoveryId: recoveryId);
  }
}

class BuSecp256k1SignParams {
  const BuSecp256k1SignParams({required this.digest, this.extraEntropy});
  final BuBytes digest;
  final BuBytes? extraEntropy;
}

class BuSecp256k1Bip340Params {
  const BuSecp256k1Bip340Params({
    required this.digest,
    this.aux,
    this.tapTweakHash,
  });
  final BuBytes digest;
  final BuBytes? aux;
  final BuBytes? tapTweakHash;
}

abstract interface class BuSecp256k1SigningApi {
  /// True if public key is valid (33 compressed, 65 uncompressed, or 32 x-only).
  bool isValidPublicKey(List<int> publicKey, {bool xOnly = false});

  /// True if 32-byte secret is in [1, n-1].
  bool isValidSecretKey(List<int> secret);

  BuResult<BuBytes> publicKey(BuBytes sk);
  BuResult<BuBytes> xOnlyPublicKey(BuBytes sk);
  BuResult<BuEcdsaSignature> signEcdsa(
    BuBytes sk,
    BuSecp256k1SignParams params,
  );
  BuResult<bool> verifyEcdsa({
    required BuBytes pk,
    required BuBytes digest,
    required BuEcdsaSignature signature,
  });
  BuResult<BuBytes> recoverEcdsa({
    required BuBytes digest,
    required BuEcdsaSignature signature,
  });
  BuResult<(BuBytes, int)> recoverEcdsaAny({
    required BuBytes digest,
    required BuBytes compactSig,
  });
  BuResult<BuEcdsaSignature> signBip340(
    BuBytes sk,
    BuSecp256k1Bip340Params params,
  );
  BuResult<bool> verifyBip340({
    required BuBytes xOnlyPk,
    required BuBytes messageOrDigest,
    required BuEcdsaSignature signature,
  });
  BuResult<BuBytes> tweakSecret(BuBytes sk, BuBytes tweak32);
  BuResult<BuBytes> tweakPublicXOnly(BuBytes xOnlyPk, BuBytes tweak32);
  BuResult<BuEcdsaSignature> signSchnorr(
    BuBytes sk,
    BuSecp256k1SignParams params,
  );
  BuResult<bool> verifySchnorr({
    required BuBytes pk,
    required BuBytes digest,
    required BuEcdsaSignature signature,
  });
  BuResult<BuBytes> bitcoinMessageHash(BuBytes message);
  BuResult<BuEcdsaSignature> signBitcoinMessage({
    required BuBytes sk,
    required BuBytes message,
    String messagePrefix = '\x18Bitcoin Signed Message:\n',
  });
  BuResult<bool> verifyBitcoinMessage({
    required BuBytes pk,
    required BuBytes message,
    required BuEcdsaSignature signature,
    String messagePrefix = '\x18Bitcoin Signed Message:\n',
  });
  BuResult<BuBytes> recoverBitcoinMessagePublicKey({
    required BuBytes message,
    required BuEcdsaSignature signature,
    String messagePrefix = '\x18Bitcoin Signed Message:\n',
  });

  /// Alias used by blockchain_utils wrappers (Bitcoin signed message).
  BuResult<BuEcdsaSignature> signMessageSignature({
    required BuBytes sk,
    required BuBytes message,
    String messagePrefix = '\x18Bitcoin Signed Message:\n',
  });

  /// Alias used by blockchain_utils wrappers (Bitcoin signed message).
  BuResult<bool> verifyMessageSignature({
    required BuBytes pk,
    required BuBytes message,
    required BuEcdsaSignature signature,
    String messagePrefix = '\x18Bitcoin Signed Message:\n',
  });

  /// Validate any accepted public-key form and return its canonical
  /// compressed base encoding, rejecting the point at infinity.
  BuResult<BuBytes> normalizePublicKey(List<int> publicKey);
}
