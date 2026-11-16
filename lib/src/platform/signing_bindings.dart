import 'package:blockchain_utils_connector/src/api/ed25519_signing_api.dart';
export '../api/ed25519_signing_api.dart' show BuEd25519Variant;
import 'package:blockchain_utils_connector/src/bytes/bytes.dart';

abstract interface class BuSigningBindings {
  int ecdsaK1PublicKey(BuBytes sk, BuBytes out33);
  int ecdsaK1Sign(BuBytes sk, BuBytes hash32, BuBytes out64);
  int ecdsaK1SignEx(BuBytes sk, BuBytes hash32, BuBytes? extra, BuBytes out64);
  int ecdsaK1Verify(BuBytes pk33, BuBytes hash32, BuBytes sig64);
  int ecdsaK1Recover(BuBytes hash32, BuBytes sig64, int recId, BuBytes out33);
  int ecdsaK1RecoveryId(
    BuBytes hash32,
    BuBytes sig64,
    BuBytes pk33,
    BuBytes outId1,
  );
  int schnorrPublicKey(BuBytes sk, BuBytes out32);
  int schnorrSign(BuBytes sk, BuBytes msg32, BuBytes? aux, BuBytes out64);

  /// BIP-340 with explicit 32-byte `aux` and optional 32-byte Taproot
  /// `tweak` (null = no tweak). Mirrors `bu_schnorr_sign_aux`.
  int schnorrSignAux(
    BuBytes sk,
    BuBytes msg,
    BuBytes? aux,
    BuBytes? tweak,
    BuBytes out64,
  );
  int schnorrVerify(BuBytes pk32, BuBytes msg32, BuBytes sig64);
  int schnorrTweakSecret(BuBytes sk, BuBytes tweak32, BuBytes out32);
  int schnorrTweakPublic(BuBytes xOnlyPk, BuBytes tweak32, BuBytes out32);
  int schnorrBchSign(BuBytes sk, BuBytes hash32, BuBytes? extra, BuBytes out64);
  int schnorrBchVerify(BuBytes pk, BuBytes hash32, BuBytes sig64);
  int ecdsaR1PublicKey(BuBytes sk, BuBytes out33);
  int ecdsaR1Sign(BuBytes sk, BuBytes hash32, BuBytes out64);
  int ecdsaR1SignEx(BuBytes sk, BuBytes hash32, BuBytes? extra, BuBytes out64);
  int ecdsaR1Verify(BuBytes pk33, BuBytes hash32, BuBytes sig64);
  int ecdsaR1Recover(BuBytes hash32, BuBytes sig64, int recId, BuBytes out33);
  int ecdsaR1RecoveryId(
    BuBytes hash32,
    BuBytes sig64,
    BuBytes pk33,
    BuBytes outId1,
  );
  int ed25519PublicKey(BuBytes sk, BuBytes out32);
  int ed25519Sign(BuBytes sk, BuBytes msg, BuBytes out64);
  int ed25519Verify(BuBytes pk32, BuBytes msg, BuBytes sig64);
  int ed25519PublicKeyVariant(
    BuEd25519Variant variant,
    BuBytes sk,
    BuBytes out32,
  );
  int ed25519SignVariant(
    BuEd25519Variant variant,
    BuBytes sk,
    BuBytes msg,
    BuBytes out64,
  );
  int ed25519VerifyVariant(
    BuEd25519Variant variant,
    BuBytes pk32,
    BuBytes msg,
    BuBytes sig64,
  );
  int blsPublicKeyG1(BuBytes sk, BuBytes out48);
  int blsPublicKeyG2(BuBytes sk, BuBytes out96);
  int blsSignMinPk(BuBytes sk, BuBytes msg, BuBytes? dst, BuBytes out96);
  int blsSignMinSig(BuBytes sk, BuBytes msg, BuBytes? dst, BuBytes out48);
  int blsVerifyMinPk(BuBytes pk48, BuBytes msg, BuBytes sig96, BuBytes? dst);
  int blsVerifyMinSig(BuBytes pk96, BuBytes msg, BuBytes sig48, BuBytes? dst);
  int blsAggregatePublicKeysG1(BuBytes pksConcat, BuBytes out48);
  int blsAggregatePublicKeysG2(BuBytes pksConcat, BuBytes out96);
  int blsAggregateSignaturesG1(BuBytes sigsConcat, BuBytes out48);
  int blsAggregateSignaturesG2(BuBytes sigsConcat, BuBytes out96);
  int blsFastAggregateVerifyMinPk(
    BuBytes apk48,
    BuBytes msg,
    BuBytes sig96,
    BuBytes? dst,
  );
  int blsFastAggregateVerifyMinSig(
    BuBytes apk96,
    BuBytes msg,
    BuBytes sig48,
    BuBytes? dst,
  );
  int blsAggregateVerifyMinPk(
    BuBytes pksConcat,
    BuBytes messagesBlob,
    int messageCount,
    BuBytes sig,
    BuBytes? dst,
  );
  int blsAggregateVerifyMinSig(
    BuBytes pksConcat,
    BuBytes messagesBlob,
    int messageCount,
    BuBytes sig,
    BuBytes? dst,
  );
  int blsBatchVerifyMinPk(
    BuBytes pksConcat,
    BuBytes messagesBlob,
    int messageCount,
    BuBytes sigsConcat,
    BuBytes? dst,
  );
  int blsBatchVerifyMinSig(
    BuBytes pksConcat,
    BuBytes messagesBlob,
    int messageCount,
    BuBytes sigsConcat,
    BuBytes? dst,
  );
  int mldsaKeygen(int level, BuBytes seed, BuBytes pkOut, BuBytes skOut);

  /// rnd may be empty → deterministic; context default empty (FIPS 204 pure).
  int mldsaSign(
    int level,
    BuBytes sk,
    BuBytes msg,
    BuBytes rnd,
    BuBytes context,
    BuBytes sigOut,
  );
  int mldsaVerify(
    int level,
    BuBytes pk,
    BuBytes msg,
    BuBytes sig,
    BuBytes context,
  );
  int mldsaPublicFromSecret(int level, BuBytes sk, BuBytes pkOut);

  // ---- MuSig2 (BIP-327) ----
  int musig2KeyAgg(BuBytes keysConcat, int nKeys, BuBytes out33);
  int musig2KeyAggTweak(
    BuBytes keysConcat,
    int nKeys,
    BuBytes tweaksConcat,
    int nTweaks,
    BuBytes out33,
  );
  int musig2NonceGen({
    required BuBytes? sk,
    required BuBytes publicKey,
    BuBytes? aggPubKey,
    BuBytes? msg,
    BuBytes? extra,
    required BuBytes rand,
    required BuBytes secnonceOut97,
    required BuBytes pubnonceOut66,
  });
  int musig2NonceAgg(BuBytes pubnoncesConcat, int n, BuBytes out66);
  int musig2PartialSign({
    required BuBytes secnonce,
    required BuBytes sk,
    required BuBytes keysConcat,
    required int nKeys,
    required BuBytes aggnonce,
    required BuBytes msg,
    BuBytes? tweaksConcat,
    int nTweaks = 0,
    required BuBytes out32,
  });
  int musig2PartialSigAgg({
    required BuBytes partialsConcat,
    required int nPartials,
    required BuBytes keysConcat,
    required int nKeys,
    required BuBytes aggnonce,
    required BuBytes msg,
    BuBytes? tweaksConcat,
    int nTweaks = 0,
    required BuBytes out64,
  });
  int musig2PartialSigVerify({
    required BuBytes partial,
    required BuBytes pubnonce,
    required BuBytes pk,
    required BuBytes keysConcat,
    required int nKeys,
    required BuBytes aggnonce,
    required BuBytes msg,
    BuBytes? tweaksConcat,
    int nTweaks = 0,
  });

  int musig2DeterministicSign({
    required BuBytes sk,
    required BuBytes aggother66,
    required BuBytes keysConcat,
    required int nKeys,
    required BuBytes msg,
    BuBytes? tweaksConcat,
    int nTweaks = 0,
    BuBytes? rand,
    required BuBytes pubnonceOut66,
    required BuBytes partialOut32,
  });

  /// 0 = valid, 4 = invalid sig, other = error
  int musig2VerifyAggregate({
    required BuBytes message,
    required BuBytes signature64,
    required BuBytes aggXOnly32,
  });

  // —— RedDSA (Jubjub / Pallas) ——
  int reddsaJubjubAuthPk(BuBytes sk, BuBytes pkOut32);
  int reddsaJubjubBindingPk(BuBytes sk, BuBytes pkOut32);
  int reddsaPallasAuthPk(BuBytes sk, BuBytes pkOut32);
  int reddsaPallasBindingPk(BuBytes sk, BuBytes pkOut32);

  /// rand80 empty → native global RNG fills 80 bytes.
  int reddsaJubjubAuthSign(
    BuBytes sk,
    BuBytes msg,
    BuBytes rand80,
    BuBytes sigOut64,
  );
  int reddsaJubjubAuthVerify(BuBytes pk, BuBytes msg, BuBytes sig64);
  int reddsaJubjubBindingSign(
    BuBytes sk,
    BuBytes msg,
    BuBytes rand80,
    BuBytes sigOut64,
  );
  int reddsaJubjubBindingVerify(BuBytes pk, BuBytes msg, BuBytes sig64);
  int reddsaPallasAuthSign(
    BuBytes sk,
    BuBytes msg,
    BuBytes rand80,
    BuBytes sigOut64,
  );
  int reddsaPallasAuthVerify(BuBytes pk, BuBytes msg, BuBytes sig64);
  int reddsaPallasBindingSign(
    BuBytes sk,
    BuBytes msg,
    BuBytes rand80,
    BuBytes sigOut64,
  );
  int reddsaPallasBindingVerify(BuBytes pk, BuBytes msg, BuBytes sig64);

  // —— sr25519 / Schnorrkel ——
  int sr25519PublicKey(BuBytes seed32, int uniform, BuBytes out32);
  int sr25519SecretFromSeed(BuBytes seed32, int uniform, BuBytes out64);
  int sr25519PublicKeyFromSecret(BuBytes sk64, BuBytes out32);
  int sr25519IsValidPublicKey(BuBytes pk32);
  int sr25519IsValidSecretKey(BuBytes sk64);
  int sr25519Sign({
    required BuBytes seedOrSk,
    required int fromSeed,
    required int uniform,
    BuBytes? context,
    required BuBytes message,
    required BuBytes nonce64,
    required BuBytes sigOut64,
  });
  int sr25519Verify({
    required BuBytes publicKey,
    BuBytes? context,
    required BuBytes message,
    required BuBytes signature64,
  });
  int sr25519ToEd25519Bytes(BuBytes sk64, BuBytes out64);
  int sr25519HardDerive({
    required BuBytes seedOrSk,
    required int fromSeed,
    required int uniform,
    required BuBytes chain32,
    BuBytes? message,
    required BuBytes out96,
  });
  int sr25519SoftDerive({
    required BuBytes seedOrSk,
    required int fromSeed,
    required int uniform,
    required BuBytes chain32,
    BuBytes? message,
    required BuBytes newNonce32,
    required BuBytes out96,
  });
  int sr25519DerivePublic({
    required BuBytes publicKey,
    required BuBytes chain32,
    BuBytes? message,
    required BuBytes out64,
  });
  int sr25519VrfHash({
    required BuBytes publicKey,
    BuBytes? context,
    required BuBytes message,
    required BuBytes out32,
  });
  int sr25519VrfInOut({
    required BuBytes seedOrSk,
    required int fromSeed,
    required int uniform,
    BuBytes? context,
    required BuBytes message,
    required BuBytes out64,
  });
  int sr25519DleqProve({
    required BuBytes seedOrSk,
    required int fromSeed,
    required int uniform,
    required BuBytes inout64,
    required BuBytes nonce64,
    required int kusama,
    BuBytes? extra,
    required BuBytes out64,
  });
  int sr25519DleqVerify({
    required BuBytes publicKey,
    required BuBytes inout64,
    required BuBytes proof64,
    required int kusama,
    BuBytes? extra,
  });
  int sr25519VrfSign({
    required BuBytes seedOrSk,
    required int fromSeed,
    required int uniform,
    BuBytes? context,
    required BuBytes message,
    required BuBytes nonce64,
    required int kusama,
    BuBytes? extra,
    required BuBytes out96,
  });
  int sr25519VrfVerify({
    required BuBytes publicKey,
    BuBytes? context,
    required BuBytes message,
    required BuBytes preOut32,
    required BuBytes proof64,
    required int kusama,
    BuBytes? extra,
  });

  // ---- FROST (RFC 9591, secp256k1 + Ed25519) ----
  // Share records 36 B `[id:u32 LE][share:32]`; k1 commitments 70 B,
  // ed commitments 68 B; factors 36 B; sig shares 32 B.
  // Returns 0 = ok, 2 = length, 3 = key, 4 = verify-fail, 6 = unsupported.
  int frostK1Shard(
    BuBytes secret32,
    BuBytes coeffsConcat,
    int nCoeffs,
    int max,
    BuBytes sharesOut,
    BuBytes polyOut,
  );
  int frostK1Combine(BuBytes sharesConcat, int n, BuBytes out32);
  int frostK1VssCommit(BuBytes coeffsConcat, int nCoeffs, BuBytes out);
  int frostK1VssVerify(
    int id,
    BuBytes share32,
    BuBytes commitmentConcat,
    int nComms,
  );
  int frostK1GroupInfo(
    BuBytes vssConcat,
    int nComms,
    int max,
    BuBytes groupOut,
    BuBytes pksOut,
  );
  int frostK1Commit(
    BuBytes secretShare32,
    BuBytes hidingRand32,
    BuBytes bindingRand32,
    BuBytes hidingOut32,
    BuBytes bindingOut32,
    BuBytes hidingCommOut,
    BuBytes bindingCommOut,
  );
  int frostK1BindingFactors(
    BuBytes groupPk,
    BuBytes commitmentsConcat,
    int n,
    BuBytes msg,
    BuBytes outFactors,
  );
  int frostK1GroupCommitment(
    BuBytes commitmentsConcat,
    BuBytes factorsConcat,
    int n,
    BuBytes out,
  );
  int frostK1Sign(
    int id,
    BuBytes secretShare32,
    BuBytes groupPk,
    BuBytes hidingNonce32,
    BuBytes bindingNonce32,
    BuBytes hidingComm,
    BuBytes bindingComm,
    BuBytes commitmentsConcat,
    int n,
    BuBytes msg,
    BuBytes out32,
  );
  int frostK1Aggregate(
    BuBytes commitmentsConcat,
    int n,
    BuBytes msg,
    BuBytes groupPk,
    BuBytes sharesConcat,
    int nShares,
    BuBytes rOut,
    BuBytes zOut,
  );
  int frostK1VerifyShare(
    int id,
    BuBytes pkShare,
    BuBytes commRecord,
    BuBytes share32,
    BuBytes commitmentsConcat,
    int n,
    BuBytes groupPk,
    BuBytes msg,
  );
  int frostK1Verify(BuBytes r, BuBytes z, BuBytes groupPk, BuBytes msg);
  int frostK1PrepareShares(
    BuBytes sharesConcat,
    int n,
    int threshold,
    BuBytes out,
  );
  int frostK1GroupFromMembers(
    BuBytes idsConcat,
    BuBytes pubsConcat,
    int n,
    int threshold,
    BuBytes groupOut,
  );
  int frostEdShard(
    BuBytes secret32,
    BuBytes coeffsConcat,
    int nCoeffs,
    int max,
    BuBytes sharesOut,
    BuBytes polyOut, {
    bool isScalar = true,
  });
  int frostEdCombine(
    BuBytes sharesConcat,
    int n,
    BuBytes out32, {
    bool isScalar = true,
  });
  int frostEdVssCommit(
    BuBytes coeffsConcat,
    int nCoeffs,
    BuBytes out, {
    bool isScalar = true,
  });
  int frostEdVssVerify(
    int id,
    BuBytes share32,
    BuBytes commitmentConcat,
    int nComms, {
    bool isScalar = true,
  });
  int frostEdGroupInfo(
    BuBytes vssConcat,
    int nComms,
    int max,
    BuBytes groupOut,
    BuBytes pksOut,
  );
  int frostEdCommit(
    BuBytes secretShare32,
    BuBytes hidingRand32,
    BuBytes bindingRand32,
    BuBytes hidingOut32,
    BuBytes bindingOut32,
    BuBytes hidingCommOut,
    BuBytes bindingCommOut, {
    bool isScalar = true,
  });
  int frostEdBindingFactors(
    BuBytes groupPk,
    BuBytes commitmentsConcat,
    int n,
    BuBytes msg,
    BuBytes outFactors,
  );
  int frostEdGroupCommitment(
    BuBytes commitmentsConcat,
    BuBytes factorsConcat,
    int n,
    BuBytes out,
  );
  int frostEdSign(
    int id,
    BuBytes secretShare32,
    BuBytes groupPk,
    BuBytes hidingNonce32,
    BuBytes bindingNonce32,
    BuBytes hidingComm,
    BuBytes bindingComm,
    BuBytes commitmentsConcat,
    int n,
    BuBytes msg,
    BuBytes out32, {
    bool isScalar = true,
  });
  int frostEdAggregate(
    BuBytes commitmentsConcat,
    int n,
    BuBytes msg,
    BuBytes groupPk,
    BuBytes sharesConcat,
    int nShares,
    BuBytes rOut,
    BuBytes zOut,
  );
  int frostEdVerifyShare(
    int id,
    BuBytes pkShare,
    BuBytes commRecord,
    BuBytes share32,
    BuBytes commitmentsConcat,
    int n,
    BuBytes groupPk,
    BuBytes msg,
  );
  int frostEdVerify(BuBytes r, BuBytes z, BuBytes groupPk, BuBytes msg);
  int frostEdPrepareShares(
    BuBytes sharesConcat,
    int n,
    int threshold,
    BuBytes out, {
    bool isScalar = true,
  });
  int frostEdGroupFromMembers(
    BuBytes idsConcat,
    BuBytes pubsConcat,
    int n,
    int threshold,
    BuBytes groupOut,
  );
  int frostK1Reshare(
    BuBytes idsConcat,
    BuBytes secretsConcat,
    int n,
    BuBytes coeffsConcat,
    int nCoeffs,
    int threshold,
    BuBytes sharesOut,
    BuBytes pubsOut,
    BuBytes groupOut,
  );
  int frostEdReshare(
    BuBytes idsConcat,
    BuBytes secretsConcat,
    int n,
    BuBytes coeffsConcat,
    int nCoeffs,
    int threshold,
    BuBytes sharesOut,
    BuBytes pubsOut,
    BuBytes groupOut,
  );

  // ---- DKLs23 threshold ECDSA ----
  // `curveId`: 0 = secp256k1, 1 = secp256r1. Shares blobs are framed
  // keyshare records; signatures are compact 64-byte `r || s`; hashes and
  // per-party seeds are 32 bytes. Returns 0 = ok, 2 = length, 3 = key,
  // 4 = verify-fail (dkls23Verify), 6 = unsupported.
  int dkls23Dkg({
    required int curveId,
    required BuBytes sid,
    required int n,
    required int t,
    required BuBytes seedsConcat,
    required List<BuBytes> outBlob,
  });
  int dkls23Sign({
    required int curveId,
    required BuBytes sid,
    required BuBytes msgHash32,
    required BuBytes sharesBlob,
    required BuBytes seedsConcat,
    required BuBytes out64,
  });
  int dkls23Refresh({
    required BuBytes sid,
    required BuBytes sharesBlob,
    required BuBytes seedsConcat,
    required List<BuBytes> outBlob,
  });
  int dkls23Verify({
    required int curveId,
    required BuBytes groupPk33,
    required BuBytes msgHash32,
    required BuBytes sig64,
  });
  int dkls23AggKeys({
    required int curveId,
    required BuBytes membersConcat,
    required int n,
    required BuBytes out33,
  });
  int dkls23ImportSecrets({
    required int curveId,
    required BuBytes secretsConcat,
    required int n,
    required List<BuBytes> outBlob,
  });
  int dkls23XOnly({
    required int curveId,
    required BuBytes groupPk33,
    required BuBytes out32,
  });
}
