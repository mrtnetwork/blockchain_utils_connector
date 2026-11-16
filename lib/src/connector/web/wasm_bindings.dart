import 'dart:js_interop';

/// JS interop for the `BuWasm` global produced by wasm-bindgen glue.
@JS('BuWasm')
extension type BuWasmJS._(JSObject _) implements JSObject {
  // ---- Hash ----
  external static int hashNew(
    int algo,
    int digestLength,
    JSUint8Array? key,
    JSUint8Array? salt,
    JSUint8Array? personal,
    double seed,
    int fanout,
    int maxDepth,
    int leafSize,
    double nodeOffset,
    int nodeDepth,
    int innerDigestLength,
    bool lastNode,
    bool hmac,
  );
  external static void hashUpdate(int handle, JSUint8Array data);
  external static void hashReset(int handle);
  external static JSUint8Array hashFinish(int handle);
  external static JSUint8Array hashFinishN(int handle, int outLen);
  external static void hashClean(int handle);
  external static void hashFree(int handle);
  external static int hashDigestLen(int handle);
  external static int hashBlockSize(int handle);
  external static int hashAlgo(int handle);
  external static int hashSaveState(int handle);
  external static int hashRestoreState(int handle, int state);
  external static void hashFreeState(int state);
  external static JSUint8Array keccakF1600(JSUint8Array state200);

  // ---- KDF ----
  external static JSUint8Array pbkdf2(
    int prf,
    JSUint8Array password,
    JSUint8Array salt,
    int iterations,
    int length,
  );
  external static JSUint8Array scrypt(
    JSUint8Array password,
    JSUint8Array salt,
    int n,
    int r,
    int p,
    int length,
  );
  external static JSUint8Array hkdf(
    int prf,
    JSUint8Array ikm,
    JSUint8Array? salt,
    JSUint8Array? info,
    int length,
  );

  // ---- AEAD ----
  external static JSUint8Array chacha20Poly1305Encrypt(
    JSUint8Array key,
    JSUint8Array nonce,
    JSUint8Array plaintext,
    JSUint8Array? aad,
    int outLen,
  );
  external static JSUint8Array? chacha20Poly1305Decrypt(
    JSUint8Array key,
    JSUint8Array nonce,
    JSUint8Array ciphertext,
    JSUint8Array? aad,
    int outLen,
  );
  external static JSUint8Array aesGcmEncrypt(
    JSUint8Array key,
    JSUint8Array nonce,
    JSUint8Array plaintext,
    JSUint8Array? aad,
    int outLen,
  );
  external static JSUint8Array? aesGcmDecrypt(
    JSUint8Array key,
    JSUint8Array nonce,
    JSUint8Array ciphertext,
    JSUint8Array? aad,
    int outLen,
  );
  external static JSUint8Array xsalsa20Poly1305Encrypt(
    JSUint8Array key,
    JSUint8Array nonce,
    JSUint8Array plaintext,
    int outLen,
  );
  external static JSUint8Array? xsalsa20Poly1305Decrypt(
    JSUint8Array key,
    JSUint8Array nonce,
    JSUint8Array sealed,
    int outLen,
  );
  external static JSUint8Array salsaBoxBeforenm(
    JSUint8Array peerPublicKey,
    JSUint8Array secretKey,
  );
  external static JSUint8Array salsaBoxEncrypt(
    JSUint8Array peerPublicKey,
    JSUint8Array secretKey,
    JSUint8Array nonce,
    JSUint8Array plaintext,
    int outLen,
  );
  external static JSUint8Array? salsaBoxDecrypt(
    JSUint8Array peerPublicKey,
    JSUint8Array secretKey,
    JSUint8Array nonce,
    JSUint8Array sealed,
    int outLen,
  );

  // ---- Block / stream cipher ----
  external static int aesNew(JSUint8Array key);
  external static void aesFree(int handle);
  external static JSUint8Array aesEncryptBlock(int handle, JSUint8Array src);
  external static JSUint8Array aesDecryptBlock(int handle, JSUint8Array src);
  external static JSUint8Array aesCbcEncrypt(
    JSUint8Array key,
    JSUint8Array iv,
    JSUint8Array plaintext,
  );
  external static JSUint8Array aesCbcDecrypt(
    JSUint8Array key,
    JSUint8Array iv,
    JSUint8Array ciphertext,
  );
  external static JSUint8Array aesCtr(
    JSUint8Array key,
    JSUint8Array counter,
    JSUint8Array data,
  );
  external static JSUint8Array aesEcbEncryptPadded(
    JSUint8Array key,
    JSUint8Array data,
    int padding,
  );
  external static JSUint8Array? aesEcbDecryptPadded(
    JSUint8Array key,
    JSUint8Array data,
    int padding,
  );
  external static JSUint8Array chacha20Xor(
    JSUint8Array key,
    JSUint8Array nonce,
    int counter,
    JSUint8Array data,
  );
  external static JSUint8Array chacha20StreamXor(
    JSUint8Array key,
    JSUint8Array nonce,
    JSUint8Array data,
    int counterLen,
    int seek,
  );

  // ---- Curve helpers ----
  external static JSUint8Array ed25519ScReduce32(JSUint8Array scalar32);
  external static JSUint8Array ed25519ScReduce64(JSUint8Array scalar64);
  external static JSUint8Array ed25519FromFeBytes(JSUint8Array fe32);
  external static JSUint8Array ed25519FromFeBytesClearCofactor(
    JSUint8Array fe32,
  );
  external static JSUint8Array jubjubScReduce64(JSUint8Array scalar64);
  external static JSUint8Array ristrettoFromEdwards(JSUint8Array ed32);
  external static JSUint8Array ristrettoToEdwards(JSUint8Array ristretto32);
  external static JSUint8Array pallasScReduce64(JSUint8Array scalar64);
  external static JSUint8Array vestaScReduce64(JSUint8Array scalar64);
  external static JSUint8Array pallasHashToCurve(
    JSUint8Array msg,
    JSUint8Array dst,
  );
  external static JSUint8Array pallasHashToCurvePasta(
    JSUint8Array domain,
    JSUint8Array msg,
  );
  external static JSUint8Array vestaHashToCurve(
    JSUint8Array msg,
    JSUint8Array dst,
  );
  external static JSUint8Array ed25519MulBase(JSUint8Array scalar);
  external static JSUint8Array secp256k1MulBase(JSUint8Array scalar);

  // ---- Signing ----
  external static JSUint8Array ed25519PublicKey(JSUint8Array sk);
  external static JSUint8Array ed25519Sign(JSUint8Array sk, JSUint8Array msg);
  external static bool ed25519Verify(
    JSUint8Array pk,
    JSUint8Array msg,
    JSUint8Array sig,
  );

  // ---- Ed25519 variants (0 = ed25519, 1 = blake2b, 2 = kholaw, 3 = monero) ----
  external static JSUint8Array ed25519PublicKeyVariant(
    int variant,
    JSUint8Array sk,
  );
  external static JSUint8Array ed25519SignVariant(
    int variant,
    JSUint8Array sk,
    JSUint8Array msg,
  );
  external static bool ed25519VerifyVariant(
    int variant,
    JSUint8Array pk,
    JSUint8Array msg,
    JSUint8Array sig,
  );

  external static JSUint8Array ecdsaK1PublicKey(JSUint8Array sk);
  external static JSUint8Array ecdsaK1Sign(JSUint8Array sk, JSUint8Array hash);
  external static JSUint8Array ecdsaK1SignEx(
    JSUint8Array sk,
    JSUint8Array hash,
    JSUint8Array? extra,
  );
  external static bool ecdsaK1Verify(
    JSUint8Array pk,
    JSUint8Array hash,
    JSUint8Array sig,
  );
  external static JSUint8Array ecdsaK1Recover(
    JSUint8Array hash,
    JSUint8Array sig,
    int recId,
  );

  external static int ecdsaK1RecoveryId(
    JSUint8Array hash32,
    JSUint8Array sig64,
    JSUint8Array pk33,
  );
  external static JSUint8Array ecdsaR1PublicKey(JSUint8Array sk);
  external static JSUint8Array ecdsaR1Sign(JSUint8Array sk, JSUint8Array hash);
  external static JSUint8Array ecdsaR1SignEx(
    JSUint8Array sk,
    JSUint8Array hash,
    JSUint8Array? extra,
  );
  external static bool ecdsaR1Verify(
    JSUint8Array pk,
    JSUint8Array hash,
    JSUint8Array sig,
  );
  external static JSUint8Array ecdsaR1Recover(
    JSUint8Array hash,
    JSUint8Array sig,
    int recId,
  );

  external static JSUint8Array schnorrTweakSecret(
    JSUint8Array sk,
    JSUint8Array tweak32,
  );
  external static JSUint8Array schnorrTweakPublic(
    JSUint8Array pk,
    JSUint8Array tweak32,
  );
  external static JSUint8Array schnorrBchSign(
    JSUint8Array sk,
    JSUint8Array hash32,
    JSUint8Array? extra,
  );
  external static bool schnorrBchVerify(
    JSUint8Array pk,
    JSUint8Array hash32,
    JSUint8Array sig64,
  );
  external static JSUint8Array schnorrPublicKey(JSUint8Array sk);
  external static JSUint8Array schnorrSign(
    JSUint8Array sk,
    JSUint8Array msg,
    JSUint8Array? aux,
  );
  external static bool schnorrVerify(
    JSUint8Array pk,
    JSUint8Array msg,
    JSUint8Array sig,
  );

  // ---- BLS ----
  external static JSUint8Array blsSkToPkG1(JSUint8Array sk);
  external static JSUint8Array blsSkToPkG2(JSUint8Array sk);
  external static JSUint8Array blsSignMinPk(
    JSUint8Array sk,
    JSUint8Array msg,
    JSUint8Array? dst,
  );
  external static JSUint8Array blsSignMinSig(
    JSUint8Array sk,
    JSUint8Array msg,
    JSUint8Array? dst,
  );
  external static bool blsVerifyMinPk(
    JSUint8Array pk,
    JSUint8Array msg,
    JSUint8Array sig,
    JSUint8Array? dst,
  );
  external static bool blsVerifyMinSig(
    JSUint8Array pk,
    JSUint8Array msg,
    JSUint8Array sig,
    JSUint8Array? dst,
  );
  external static JSUint8Array blsAggregatePksG1(JSUint8Array pks);
  external static JSUint8Array blsAggregatePksG2(JSUint8Array pks);
  external static JSUint8Array blsAggregateSigsG1(JSUint8Array sigs);
  external static JSUint8Array blsAggregateSigsG2(JSUint8Array sigs);
  external static bool blsAggregateVerifyMinPk(
    JSUint8Array pksConcat,
    JSUint8Array messagesBlob,
    int messageCount,
    JSUint8Array sig,
    JSUint8Array dst,
  );
  external static bool blsAggregateVerifyMinSig(
    JSUint8Array pksConcat,
    JSUint8Array messagesBlob,
    int messageCount,
    JSUint8Array sig,
    JSUint8Array dst,
  );
  external static bool blsBatchVerifyMinPk(
    JSUint8Array pksConcat,
    JSUint8Array messagesBlob,
    int messageCount,
    JSUint8Array sigsConcat,
    JSUint8Array dst,
  );
  external static bool blsBatchVerifyMinSig(
    JSUint8Array pksConcat,
    JSUint8Array messagesBlob,
    int messageCount,
    JSUint8Array sigsConcat,
    JSUint8Array dst,
  );
  external static bool blsFastAggregateVerifyMinPk(
    JSUint8Array apk,
    JSUint8Array msg,
    JSUint8Array sig,
    JSUint8Array? dst,
  );
  external static bool blsFastAggregateVerifyMinSig(
    JSUint8Array apk,
    JSUint8Array msg,
    JSUint8Array sig,
    JSUint8Array? dst,
  );

  // ---- MuSig2 ----
  external static JSUint8Array musig2KeyAgg(JSUint8Array keys, int nKeys);
  external static JSUint8Array musig2KeyAggTweak(
    JSUint8Array keysConcat,
    int nKeys,
    JSUint8Array tweaksConcat,
    int nTweaks,
  );
  external static bool musig2PartialSigVerify(
    JSUint8Array partial32,
    JSUint8Array pubnonce66,
    JSUint8Array pk33,
    JSUint8Array keysConcat,
    int nKeys,
    JSUint8Array aggnonce,
    JSUint8Array msg,
    JSUint8Array? tweaksConcat,
    int nTweaks,
  );
  external static bool musig2VerifyAggregate(
    JSUint8Array msg,
    JSUint8Array sig,
    JSUint8Array aggXOnly,
  );
  external static JSUint8Array musig2NonceGen(
    JSUint8Array sk,
    JSUint8Array? pk,
    JSUint8Array? msg,
    JSUint8Array rand,
  );
  external static JSUint8Array musig2NonceAgg(JSUint8Array pubnonces, int n);
  external static JSUint8Array musig2PartialSign(
    JSUint8Array secnonce,
    JSUint8Array sk,
    JSUint8Array keys,
    int nKeys,
    JSUint8Array aggnonce,
    JSUint8Array msg,
    JSUint8Array? tweaks,
    int nTweaks,
  );
  external static JSUint8Array musig2PartialSigAgg(
    JSUint8Array partials,
    int nPartials,
    JSUint8Array keys,
    int nKeys,
    JSUint8Array aggnonce,
    JSUint8Array msg,
    JSUint8Array? tweaks,
    int nTweaks,
  );

  // ---- DKLs23 threshold ECDSA ----
  external static JSUint8Array dkls23ImportSecrets(
    int curve,
    JSUint8Array secrets,
    int n,
  );
  external static JSUint8Array dkls23Dkg(
    int curve,
    JSUint8Array sid,
    int n,
    int t,
    JSUint8Array seeds,
  );
  external static JSUint8Array dkls23Sign(
    int curve,
    JSUint8Array sid,
    JSUint8Array msgHash,
    JSUint8Array sharesBlob,
    JSUint8Array seeds,
  );
  external static JSUint8Array dkls23Refresh(
    JSUint8Array sid,
    JSUint8Array sharesBlob,
    JSUint8Array seeds,
  );
  external static bool dkls23Verify(
    int curve,
    JSUint8Array groupPk,
    JSUint8Array msgHash,
    JSUint8Array sig,
  );
  external static JSUint8Array dkls23AggPublicKeys(
    int curve,
    JSUint8Array members,
    int n,
  );
  external static JSUint8Array dkls23XOnly(int curve, JSUint8Array groupPk);

  // ---- PQ ----
  external static JSUint8Array mldsaKeygen(int level, JSUint8Array seed);
  external static JSUint8Array mldsaSign(
    int level,
    JSUint8Array sk,
    JSUint8Array msg,
    JSUint8Array? rnd,
    JSUint8Array? ctx,
  );
  external static bool mldsaVerify(
    int level,
    JSUint8Array pk,
    JSUint8Array msg,
    JSUint8Array sig,
    JSUint8Array? ctx,
  );
  external static JSUint8Array mldsaPkFromSk(int level, JSUint8Array sk);

  // ---- RNG ----
  external static bool rngSeed(JSUint8Array seed32);
  external static bool rngIsSeeded();
  external static JSUint8Array rngFill(int len);

  // ---- Generic curve arithmetic (mirrors bu_curve_*) ----
  external static int curvePointLen(int curveId);
  external static int curveScalarLen(int curveId);
  external static bool curveScCheck(int curveId, JSUint8Array scalar);
  external static JSUint8Array curveGenerator(int curveId);
  external static JSUint8Array curveIdentity(int curveId);
  external static JSUint8Array curveAdd(
    int curveId,
    JSUint8Array a,
    JSUint8Array b,
  );
  external static JSUint8Array curveSub(
    int curveId,
    JSUint8Array a,
    JSUint8Array b,
  );
  external static JSUint8Array curveNeg(int curveId, JSUint8Array a);
  external static JSUint8Array curveMul(
    int curveId,
    JSUint8Array scalar,
    JSUint8Array point,
  );
  external static JSUint8Array curveMulBase(int curveId, JSUint8Array scalar);
  external static JSUint8Array curveMulAdd(
    int curveId,
    JSUint8Array s1,
    JSUint8Array p1,
    JSUint8Array s2,
    JSUint8Array p2,
  );
  external static JSUint8Array curveScAdd(
    int curveId,
    JSUint8Array a,
    JSUint8Array b,
  );
  external static JSUint8Array curveScSub(
    int curveId,
    JSUint8Array a,
    JSUint8Array b,
  );
  external static JSUint8Array curveScMul(
    int curveId,
    JSUint8Array a,
    JSUint8Array b,
  );
  external static JSUint8Array curveScNeg(int curveId, JSUint8Array s);
  external static JSUint8Array curveScReduce(int curveId, JSUint8Array s);
  external static int curvePointUncompressedLen(int curveId);
  external static JSUint8Array curveCompress(int curveId, JSUint8Array point);
  external static JSUint8Array curveNormalizePubkey(
    int curveId,
    JSUint8Array point,
  );
  external static JSUint8Array curveUncompress(int curveId, JSUint8Array point);

  // ---- Hardware-wallet codecs (needs `--features wasm,hw`) ----
  external static int hwDeviceCount();
  external static int hwCoinCount();
  external static bool hwSupportsCoin(int dev, int coin);
  external static bool hwIsAirgap(int dev);
  external static JSUint8Array hwParsePath(String path);
  external static void hwValidatePath(int dev, int coin, JSUint8Array pathLe);
  external static JSUint8Array hwGetAddressRequest(
    int dev,
    int coin,
    JSUint8Array pathLe,
  );
  external static JSUint8Array hwParseAddressResponse(
    int dev,
    JSUint8Array resp,
  );
  external static JSUint8Array hwSignRequest(
    int dev,
    int coin,
    JSUint8Array pathLe,
    JSUint8Array payload,
  );
  external static JSUint8Array hwParseSignResponse(int dev, JSUint8Array resp);
  external static JSUint8Array hwSignTxStart(
    int dev,
    int coin,
    int inputsCount,
    int outputsCount,
  );
  external static JSUint8Array hwParseTxRequest(int dev, JSUint8Array resp);
  external static JSUint8Array hwTxRequestSignature(int dev, JSUint8Array resp);
  external static JSUint8Array hwTxRequestSerialized(
    int dev,
    JSUint8Array resp,
  );
  external static JSUint8Array hwTxRequestTxHash(int dev, JSUint8Array resp);
  external static JSUint8Array hwTxAckMeta(
    int version,
    int lockTime,
    int inputsCount,
    int outputsCount,
  );
  external static JSUint8Array hwTxAckInput(
    JSUint8Array prevHash32,
    int prevIndex,
    JSUint8Array pathLe,
    int amountHi,
    int amountLo,
    JSUint8Array scriptSig,
    int scriptType,
  );
  external static JSUint8Array hwTxAckOutput(
    String address,
    int amountHi,
    int amountLo,
    int scriptType,
  );
  external static JSUint8Array hwTxAckChange(
    JSUint8Array pathLe,
    int amountHi,
    int amountLo,
    int scriptType,
  );
  external static JSUint8Array hwTxAckBinOutput(
    JSUint8Array scriptPubKey,
    int amountHi,
    int amountLo,
  );
  external static void hwBitBoxHsNew(
    JSUint8Array staticPriv32,
    JSUint8Array ephemeralPriv32,
  );
  external static JSUint8Array hwBitBoxHsM1();
  external static void hwBitBoxHsM2(JSUint8Array m2);
  external static JSUint8Array hwBitBoxHsM3();
  external static void hwBitBoxHsSplit();
  external static JSUint8Array hwBitBoxEncrypt(JSUint8Array plaintext);
  external static JSUint8Array hwBitBoxDecrypt(JSUint8Array ciphertext);
  external static JSUint8Array hwBitBoxHsHash();
  external static void hwBitBoxFree();
  external static JSUint8Array hwBitBoxBtcPubRequest(
    int coin,
    JSUint8Array pathLe,
    int xpubType,
    bool display,
  );
  external static String hwBitBoxPubParse(JSUint8Array resp);
  external static JSUint8Array hwBitBoxSignInit(
    int coin,
    JSUint8Array pathLe,
    int simpleType,
    int version,
    int inputsCount,
    int outputsCount,
    int locktime,
  );
  external static JSUint8Array hwBitBoxSignNextParse(JSUint8Array resp);
  external static JSUint8Array hwBitBoxSignNextSignature(JSUint8Array resp);
  external static JSUint8Array hwBitBoxSignNextPrevIndex(JSUint8Array resp);
  external static JSUint8Array hwBitBoxSignInput(
    JSUint8Array prevHash32,
    int prevIndex,
    int amountHi,
    int amountLo,
    int sequence,
    JSUint8Array pathLe,
    int scriptConfigIndex,
  );
  external static JSUint8Array hwBitBoxSignOutput(
    int outputType,
    int amountHi,
    int amountLo,
    JSUint8Array payload,
  );
  external static JSUint8Array hwBitBoxSignChange(
    JSUint8Array pathLe,
    int amountHi,
    int amountLo,
    int scriptConfigIndex,
  );
  external static JSUint8Array hwBitBoxSignPrevtxInit(
    int version,
    int inputsCount,
    int outputsCount,
    int locktime,
  );
  external static JSUint8Array hwBitBoxSignPrevtxInput(
    JSUint8Array prevHash32,
    int prevIndex,
    JSUint8Array scriptSig,
    int sequence,
  );
  external static JSUint8Array hwBitBoxSignPrevtxOutput(
    int amountHi,
    int amountLo,
    JSUint8Array script,
  );
  external static JSUint8Array hwIdentityEncode(
    String proto,
    String user,
    String host,
    String port,
    String path,
    int index,
  );
  external static JSUint8Array hwSignIdentityRequest(
    JSUint8Array identity,
    JSUint8Array hidden,
    String visual,
    String curve,
  );
  external static String hwSignedIdentityAddress(JSUint8Array resp);
  external static JSUint8Array hwSignedIdentityPubkey(JSUint8Array resp);
  external static JSUint8Array hwSignedIdentitySignature(JSUint8Array resp);
  external static JSUint8Array hwLedgerFingerprint();
  external static JSUint8Array hwLedgerFingerprintParse(JSUint8Array resp);
  external static String hwQrRequest(int dev, int coin, JSUint8Array pathLe);
  external static JSUint8Array hwQrParse(int dev, String qr);
  external static JSUint8Array hwPsbtCounts(JSUint8Array raw);
  external static String hwUrEncode(String type, JSUint8Array payload);
  external static JSUint8Array hwUrDecodePayload(String ur);
  external static String hwUrDecodeType(String ur);
  external static JSUint8Array hwHidFrame(
    JSUint8Array payload,
    int channel,
    int tag,
  );
  external static JSUint8Array hwHidUnframe(
    JSUint8Array reports,
    int channel,
    int tag,
  );

  // ---- RedDSA ----
  external static JSUint8Array reddsaJubjubAuthPk(JSUint8Array sk);
  external static JSUint8Array reddsaJubjubBindingPk(JSUint8Array sk);
  external static JSUint8Array reddsaPallasAuthPk(JSUint8Array sk);
  external static JSUint8Array reddsaPallasBindingPk(JSUint8Array sk);
  external static JSUint8Array reddsaJubjubAuthSign(
    JSUint8Array sk,
    JSUint8Array msg,
    JSUint8Array? rand80,
  );
  external static bool reddsaJubjubAuthVerify(
    JSUint8Array pk,
    JSUint8Array msg,
    JSUint8Array sig,
  );
  external static JSUint8Array reddsaJubjubBindingSign(
    JSUint8Array sk,
    JSUint8Array msg,
    JSUint8Array? rand80,
  );
  external static bool reddsaJubjubBindingVerify(
    JSUint8Array pk,
    JSUint8Array msg,
    JSUint8Array sig,
  );
  external static JSUint8Array reddsaPallasAuthSign(
    JSUint8Array sk,
    JSUint8Array msg,
    JSUint8Array? rand80,
  );
  external static bool reddsaPallasAuthVerify(
    JSUint8Array pk,
    JSUint8Array msg,
    JSUint8Array sig,
  );
  external static JSUint8Array reddsaPallasBindingSign(
    JSUint8Array sk,
    JSUint8Array msg,
    JSUint8Array? rand80,
  );
  external static bool reddsaPallasBindingVerify(
    JSUint8Array pk,
    JSUint8Array msg,
    JSUint8Array sig,
  );

  // ---- Monero Ed25519 ----
  external static JSUint8Array ed25519HashToEc(JSUint8Array data);
  external static JSUint8Array ed25519MulVartime(
    JSUint8Array scalar,
    JSUint8Array point,
  );
  external static JSUint8Array ed25519MulBaseVartime(JSUint8Array scalar);
  external static JSUint8Array ed25519MulAddVartime(
    JSUint8Array s1,
    JSUint8Array p1,
    JSUint8Array s2,
    JSUint8Array p2,
  );
  external static JSUint8Array ed25519AddVartime(
    JSUint8Array a,
    JSUint8Array b,
  );
  external static JSUint8Array ed25519SubVartime(
    JSUint8Array a,
    JSUint8Array b,
  );
  external static JSUint8Array ed25519NegVartime(JSUint8Array p);
  external static JSUint8Array ed25519DoubleVartime(JSUint8Array p);
  external static bool ed25519CheckKey(JSUint8Array pk32);
  external static JSUint8Array ed25519MulByCofactor(JSUint8Array point32);
  external static JSUint8Array ed25519ScalarmultKeyImage(
    JSUint8Array hp32,
    JSUint8Array a32,
  );
  external static JSUint8Array ed25519Mul8Mult(
    JSUint8Array s32,
    JSUint8Array p32,
  );
  external static JSUint8Array ed25519GeDsmPrecomp(JSUint8Array point32);
  external static JSUint8Array ed25519GeDoubleScalarMultPrecomp(
    JSUint8Array a32,
    JSUint8Array aI256,
    JSUint8Array b32,
    JSUint8Array bI256,
  );
  external static JSUint8Array ed25519GeDoubleScalarMultBase(
    JSUint8Array a32,
    JSUint8Array gA32,
    JSUint8Array b32,
  );
  external static JSUint8Array ed25519GeTripleScalarMultBase(
    JSUint8Array a32,
    JSUint8Array b32,
    JSUint8Array bI256,
    JSUint8Array c32,
    JSUint8Array cI256,
  );
  external static JSUint8Array ed25519GeTripleScalarMultPrecomp(
    JSUint8Array a32,
    JSUint8Array aI256,
    JSUint8Array b32,
    JSUint8Array bI256,
    JSUint8Array c32,
    JSUint8Array cI256,
  );

  // ---- X25519 ----
  external static JSUint8Array x25519(JSUint8Array k, JSUint8Array u);
  external static JSUint8Array x25519PublicKey(JSUint8Array privateKey);
  external static JSUint8Array x25519Dh(
    JSUint8Array privateKey,
    JSUint8Array peer,
  );
  external static JSUint8Array ed25519PkToX25519(JSUint8Array edPk);
  external static JSUint8Array ed25519SeedToX25519(JSUint8Array seed);

  // ---- FF1 ----
  external static JSUint8Array ff1Encrypt(
    JSUint8Array key,
    int radix,
    JSUint8Array pt,
    JSUint8Array tweak,
  );
  external static JSUint8Array ff1Decrypt(
    JSUint8Array key,
    int radix,
    JSUint8Array ct,
    JSUint8Array tweak,
  );
  external static JSUint8Array ff1EncryptBinary(
    JSUint8Array key,
    JSUint8Array pt,
    JSUint8Array tweak,
  );
  external static JSUint8Array ff1DecryptBinary(
    JSUint8Array key,
    JSUint8Array ct,
    JSUint8Array tweak,
  );

  // ---- Zcash ----
  external static JSUint8Array poseidonHashTwo(JSUint8Array a, JSUint8Array b);
  external static JSUint8Array poseidonHash(JSUint8Array inputs);
  external static JSUint8Array poseidonPermute(JSUint8Array state96);
  // Only present in wasm builds with the Rust `poseidon-bn254` feature;
  // the platform wrapper maps a missing export to rc 6.
  external static JSUint8Array poseidonBn254Hash(JSUint8Array inputs);
  external static JSUint8Array sinsemillaHashBits(
    JSUint8Array domain,
    JSUint8Array packedBits,
    int bitLen,
  );
  external static JSUint8Array sinsemillaHashBitstring(
    JSUint8Array domain,
    JSUint8Array bits01,
  );
  external static JSUint8Array sinsemillaCommit(
    JSUint8Array domain,
    JSUint8Array packedBits,
    int bitLen,
    JSUint8Array r32,
  );
  external static JSUint8Array sinsemillaShortCommit(
    JSUint8Array domain,
    JSUint8Array packedBits,
    int bitLen,
    JSUint8Array r32,
  );
  external static JSUint8Array pedersenHash(
    int personal,
    int layer,
    JSUint8Array packedBits,
    int bitLen,
  );
  external static JSUint8Array pedersenHashBitstring(
    int personal,
    int layer,
    JSUint8Array bits01,
  );

  // ---- Groth16 ----
  external static bool groth16VerifyBls(
    JSUint8Array proof,
    JSUint8Array vk,
    JSUint8Array inputs,
  );
  external static bool groth16VerifyBn254(
    JSUint8Array proof,
    JSUint8Array vk,
    JSUint8Array inputs,
  );
  external static int groth16BlsProofLen();
  external static int groth16Bn254ProofLen();

  // ---- ZK bridge ----
  external static int zkVersion();
  external static int zkEnableLogging(int enable, int mode);

  // ---- Backend build introspection (mirrors FFI bu_build_*) ----
  external static int backendVersion();
  external static int backendFeatures();

  // ---- Sapling prover ----
  external static int saplingSetSpendParams(JSUint8Array params);
  external static int saplingSetOutputParams(JSUint8Array params);
  external static void saplingParamsFree(int handle);
  external static JSUint8Array saplingProve(
    int handle,
    int kind,
    JSUint8Array witness,
  );
  external static bool saplingVerify(
    int handle,
    int kind,
    JSUint8Array proof,
    JSUint8Array inputs,
  );

  // ---- Orchard prover ----
  external static int orchardPkNew(int version);
  external static void orchardPkFree(int handle);

  /// arg order was (inputs, instances, seed, version, flag)
  /// but the Rust export takes (inputs, instances, version, flag, seed) —
  /// seed-last like FFI. The scramble made every wasm prove fail.
  external static JSUint8Array orchardCreateProof(
    int handle,
    JSUint8Array inputs,
    JSUint8Array instances,
    int version,
    int disableCrossAddress,
    JSUint8Array seed,
  );
  external static bool orchardVerifyProof(
    int handle,
    JSUint8Array proof,
    JSUint8Array instances,
    int version,
    int disableCrossAddress,
  );

  // ---- Merkle contexts ----
  external static int merkleCreateContext();
  external static bool merkleCloseContext(int id);
  external static JSUint8Array merkleGetContext(int id);
  external static void merkleInsertChainState(int id, JSUint8Array blob);
  external static void merkleUpdateState(int id, int kind, JSUint8Array leaves);
  external static void merkleUpdateSubtree(
    int id,
    int kind,
    int start,
    JSUint8Array root32,
  );
  external static void merkleMergeState(int id, int kind, JSUint8Array blob);
  external static void merkleCheckpoint(int id, int checkpointId);
  external static JSUint8Array merkleCreateWitness(
    int id,
    int kind,
    int checkpointId,
    JSUint8Array positions,
  );

  // ---- Monero Bulletproofs+ ----
  external static bool moneroBpPlusVerify(JSUint8Array packed);
  external static JSUint8Array moneroBpPlusProveAmounts(
    JSUint8Array amountsLe,
    JSUint8Array gamma,
    JSUint8Array seed32,
  );
  external static JSUint8Array moneroBpPlusProveScalars(
    JSUint8Array sv,
    JSUint8Array gamma,
    JSUint8Array seed32,
  );

  // ---- Monero output scan (fast unlock) ----
  external static JSUint8Array moneroUnlockBatch(
    JSUint8Array viewSecs,
    JSUint8Array spendPubs,
    JSUint8Array spendCountsLe,
    JSUint8Array outKeys,
    JSUint8Array txPubs,
    JSUint8Array additional,
    JSUint8Array additionalPresent,
    JSUint8Array viewTagsLe,
    JSUint8Array outIndicesLe,
    int outCount,
    int accCount,
  );

  // ---- MuSig2 det ----
  external static JSUint8Array musig2DeterministicSign(
    JSUint8Array sk,
    JSUint8Array aggother,
    JSUint8Array keys,
    int nKeys,
    JSUint8Array msg,
    JSUint8Array tweaks,
    int nTweaks,
    JSUint8Array? rand,
  );

  // ---- sr25519 ----
  external static JSUint8Array sr25519PublicKey(
    JSUint8Array seed,
    bool uniform,
  );
  external static JSUint8Array sr25519SecretFromSeed(
    JSUint8Array seed,
    bool uniform,
  );
  external static JSUint8Array sr25519PublicKeyFromSecret(JSUint8Array sk);
  external static bool sr25519IsValidPublicKey(JSUint8Array pk);
  external static bool sr25519IsValidSecretKey(JSUint8Array sk);
  external static JSUint8Array sr25519Sign(
    JSUint8Array seedOrSk,
    bool fromSeed,
    bool uniform,
    JSUint8Array ctx,
    JSUint8Array msg,
    JSUint8Array nonce64,
  );
  external static bool sr25519Verify(
    JSUint8Array pk,
    JSUint8Array ctx,
    JSUint8Array msg,
    JSUint8Array sig,
  );
  external static JSUint8Array sr25519ToEd25519Bytes(JSUint8Array sk);
  external static JSUint8Array sr25519HardDerive(
    JSUint8Array seedOrSk,
    bool fromSeed,
    bool uniform,
    JSUint8Array chain,
    JSUint8Array msg,
  );
  external static JSUint8Array sr25519SoftDerive(
    JSUint8Array seedOrSk,
    bool fromSeed,
    bool uniform,
    JSUint8Array chain,
    JSUint8Array msg,
    JSUint8Array newNonce,
  );
  external static JSUint8Array sr25519DerivePublic(
    JSUint8Array pk,
    JSUint8Array chain,
    JSUint8Array msg,
  );
  external static JSUint8Array sr25519VrfHash(
    JSUint8Array pk,
    JSUint8Array ctx,
    JSUint8Array msg,
  );
  external static JSUint8Array sr25519VrfInOut(
    JSUint8Array seedOrSk,
    bool fromSeed,
    bool uniform,
    JSUint8Array ctx,
    JSUint8Array msg,
  );
  external static JSUint8Array sr25519DleqProve(
    JSUint8Array seedOrSk,
    bool fromSeed,
    bool uniform,
    JSUint8Array inout64,
    JSUint8Array nonce64,
    bool kusama, [
    JSUint8Array? extra,
  ]);
  external static bool sr25519DleqVerify(
    JSUint8Array pk,
    JSUint8Array inout64,
    JSUint8Array proof64,
    bool kusama, [
    JSUint8Array? extra,
  ]);
  external static JSUint8Array sr25519VrfSign(
    JSUint8Array seedOrSk,
    bool fromSeed,
    bool uniform,
    JSUint8Array ctx,
    JSUint8Array msg,
    JSUint8Array nonce64,
    bool kusama, [
    JSUint8Array? extra,
  ]);
  external static bool sr25519VrfVerify(
    JSUint8Array pk,
    JSUint8Array ctx,
    JSUint8Array msg,
    JSUint8Array preout32,
    JSUint8Array proof64,
    bool kusama, [
    JSUint8Array? extra,
  ]);

  // ---- FROST (RFC 9591) ----
  // Shard returns `shares(max*36) ++ poly((1+nCoeffs)*32)`.
  external static JSUint8Array frostK1Shard(
    JSUint8Array secret,
    JSUint8Array coeffs,
    int nCoeffs,
    int max,
  );
  external static JSUint8Array frostK1Combine(JSUint8Array shares, int n);
  // Commit returns `hiding(32) ++ binding(32) ++ hc(33) ++ bc(33)` (130 B).
  external static JSUint8Array frostK1Commit(
    JSUint8Array secretShare,
    JSUint8Array hidingRand,
    JSUint8Array bindingRand,
  );
  external static JSUint8Array frostK1BindingFactors(
    JSUint8Array groupPk,
    JSUint8Array commitments,
    int n,
    JSUint8Array msg,
  );
  external static JSUint8Array frostK1GroupCommitment(
    JSUint8Array commitments,
    JSUint8Array factors,
    int n,
  );
  // Nonces passed as the 130-byte commit blob; returns 32-byte share.
  external static JSUint8Array frostK1Sign(
    int id,
    JSUint8Array secretShare,
    JSUint8Array groupPk,
    JSUint8Array nonces130,
    JSUint8Array commitments,
    int n,
    JSUint8Array msg,
  );
  // Aggregate returns `R(33) ++ z(32)` (65 B).
  external static JSUint8Array frostK1Aggregate(
    JSUint8Array commitments,
    int n,
    JSUint8Array msg,
    JSUint8Array groupPk,
    JSUint8Array shares,
    int nShares,
  );
  external static bool frostK1VerifyShare(
    int id,
    JSUint8Array pkShare,
    JSUint8Array comm,
    JSUint8Array share,
    JSUint8Array commitments,
    int n,
    JSUint8Array groupPk,
    JSUint8Array msg,
  );
  // Verify takes the 65-byte `R ++ z` blob.
  external static bool frostK1Verify(
    JSUint8Array sig,
    JSUint8Array groupPk,
    JSUint8Array msg,
  );
  external static JSUint8Array frostK1PrepareShares(
    JSUint8Array shares,
    int n,
    int threshold,
  );
  external static JSUint8Array frostK1GroupFromMembers(
    JSUint8Array ids,
    JSUint8Array pubs,
    int n,
    int threshold,
  );
  // Reshare returns `shares(n*32) ++ pubs(n*elen) ++ group(elen)`.
  external static JSUint8Array frostK1Reshare(
    JSUint8Array ids,
    JSUint8Array secrets,
    int n,
    JSUint8Array coeffs,
    int nCoeffs,
    int threshold,
  );
  external static JSUint8Array frostEdReshare(
    JSUint8Array ids,
    JSUint8Array secrets,
    int n,
    JSUint8Array coeffs,
    int nCoeffs,
    int threshold,
  );
  external static JSUint8Array frostEdShard(
    JSUint8Array secret,
    JSUint8Array coeffs,
    int nCoeffs,
    int max,
    bool isScalar,
  );
  external static JSUint8Array frostEdCombine(
    JSUint8Array shares,
    int n,
    bool isScalar,
  );
  // Commit returns `hiding(32) ++ binding(32) ++ hc(32) ++ bc(32)` (128 B).
  external static JSUint8Array frostEdCommit(
    JSUint8Array secretShare,
    JSUint8Array hidingRand,
    JSUint8Array bindingRand,
    bool isScalar,
  );
  external static JSUint8Array frostEdBindingFactors(
    JSUint8Array groupPk,
    JSUint8Array commitments,
    int n,
    JSUint8Array msg,
  );
  external static JSUint8Array frostEdGroupCommitment(
    JSUint8Array commitments,
    JSUint8Array factors,
    int n,
  );
  external static JSUint8Array frostEdSign(
    int id,
    JSUint8Array secretShare,
    JSUint8Array groupPk,
    JSUint8Array nonces128,
    JSUint8Array commitments,
    int n,
    JSUint8Array msg,
    bool isScalar,
  );
  // Aggregate returns `R(32) ++ z(32)` (64 B).
  external static JSUint8Array frostEdAggregate(
    JSUint8Array commitments,
    int n,
    JSUint8Array msg,
    JSUint8Array groupPk,
    JSUint8Array shares,
    int nShares,
  );
  external static bool frostEdVerifyShare(
    int id,
    JSUint8Array pkShare,
    JSUint8Array comm,
    JSUint8Array share,
    JSUint8Array commitments,
    int n,
    JSUint8Array groupPk,
    JSUint8Array msg,
  );
  // Verify takes the 64-byte `R ++ z` blob.
  external static bool frostEdVerify(
    JSUint8Array sig,
    JSUint8Array groupPk,
    JSUint8Array msg,
  );
  external static JSUint8Array frostEdPrepareShares(
    JSUint8Array shares,
    int n,
    int threshold,
    bool isScalar,
  );
  external static JSUint8Array frostEdGroupFromMembers(
    JSUint8Array ids,
    JSUint8Array pubs,
    int n,
    int threshold,
  );

  // ---- FROST VSS / group info ----
  // VssCommit returns `nCoeffs*33` (k1) / `nCoeffs*32` (ed) points.
  external static JSUint8Array frostK1VssCommit(
    JSUint8Array coeffs,
    int nCoeffs,
  );
  external static bool frostK1VssVerify(
    int id,
    JSUint8Array share,
    JSUint8Array commitment,
    int nComms,
  );
  // GroupInfo returns `group(33) ++ pks(max*33)`.
  external static JSUint8Array frostK1GroupInfo(
    JSUint8Array vss,
    int nComms,
    int max,
  );
  external static JSUint8Array frostEdVssCommit(
    JSUint8Array coeffs,
    int nCoeffs,
    bool isScalar,
  );
  external static bool frostEdVssVerify(
    int id,
    JSUint8Array share,
    JSUint8Array commitment,
    int nComms,
    bool isScalar,
  );
  // GroupInfo returns `group(32) ++ pks(max*32)`.
  external static JSUint8Array frostEdGroupInfo(
    JSUint8Array vss,
    int nComms,
    int max,
  );

  // ---- Solana confidential-transfer ZK ----
  //
  // Amounts cross as f64 (exact for all in-range values; on-chain amounts
  // are far below 2^53). `decrypt`-style calls return f64 and the platform
  // layer encodes LE bytes into the caller's out-buffer.
  external static bool solanaZkValidatePubkey(JSUint8Array pubkey);
  external static bool solanaZkValidateCiphertext(JSUint8Array ciphertext);
  external static JSUint8Array solanaZkPubkeyFromSecret(JSUint8Array secret);
  external static JSUint8Array solanaZkEncryptWith(
    JSUint8Array pubkey,
    double amount,
    JSUint8Array opening,
  );
  external static double solanaZkDecryptU32(
    JSUint8Array secret,
    JSUint8Array ciphertext,
  );
  external static JSUint8Array solanaZkProvePubkeyValidity(
    JSUint8Array secret,
    JSUint8Array seed,
  );
  external static bool solanaZkVerifyPubkeyValidity(
    JSUint8Array pubkey,
    JSUint8Array proof,
  );
  external static JSUint8Array solanaZkProveZeroCiphertext(
    JSUint8Array secret,
    JSUint8Array pubkey,
    JSUint8Array ciphertext,
    JSUint8Array seed,
  );
  external static bool solanaZkVerifyZeroCiphertext(
    JSUint8Array pubkey,
    JSUint8Array ciphertext,
    JSUint8Array proof,
  );
  external static JSUint8Array solanaZkProveEquality(
    JSUint8Array secret,
    JSUint8Array pubkey,
    JSUint8Array ciphertext,
    JSUint8Array commitment,
    JSUint8Array opening,
    double amount,
    JSUint8Array seed,
  );
  external static bool solanaZkVerifyEquality(
    JSUint8Array pubkey,
    JSUint8Array ciphertext,
    JSUint8Array commitment,
    JSUint8Array proof,
  );
  external static JSUint8Array solanaZkProveCiphertextEquality(
    JSUint8Array firstSecret,
    JSUint8Array firstPubkey,
    JSUint8Array secondPubkey,
    JSUint8Array firstCiphertext,
    JSUint8Array secondCiphertext,
    JSUint8Array secondOpening,
    double amount,
    JSUint8Array seed,
  );
  external static bool solanaZkVerifyCiphertextEquality(
    JSUint8Array firstPubkey,
    JSUint8Array secondPubkey,
    JSUint8Array firstCiphertext,
    JSUint8Array secondCiphertext,
    JSUint8Array proof,
  );
  external static JSUint8Array solanaZkProveGroupedValidity2(
    JSUint8Array firstPubkey,
    JSUint8Array secondPubkey,
    JSUint8Array grouped,
    double amount,
    JSUint8Array opening,
    JSUint8Array seed,
  );
  external static bool solanaZkVerifyGroupedValidity2(
    JSUint8Array firstPubkey,
    JSUint8Array secondPubkey,
    JSUint8Array grouped,
    JSUint8Array proof,
  );
  external static JSUint8Array solanaZkProveGroupedValidity3(
    JSUint8Array firstPubkey,
    JSUint8Array secondPubkey,
    JSUint8Array thirdPubkey,
    JSUint8Array grouped,
    double amount,
    JSUint8Array opening,
    JSUint8Array seed,
  );
  external static bool solanaZkVerifyGroupedValidity3(
    JSUint8Array firstPubkey,
    JSUint8Array secondPubkey,
    JSUint8Array thirdPubkey,
    JSUint8Array grouped,
    JSUint8Array proof,
  );
  external static JSUint8Array solanaZkProvePercentageWithCap(
    JSUint8Array percentageCommitment,
    JSUint8Array percentageOpening,
    double percentageAmount,
    JSUint8Array deltaCommitment,
    JSUint8Array deltaOpening,
    double deltaAmount,
    JSUint8Array claimedCommitment,
    JSUint8Array claimedOpening,
    double maxValue,
    JSUint8Array seed,
  );
  external static bool solanaZkVerifyPercentageWithCap(
    JSUint8Array percentageCommitment,
    JSUint8Array deltaCommitment,
    JSUint8Array claimedCommitment,
    double maxValue,
    JSUint8Array proof,
  );
  external static JSUint8Array solanaZkProveBatchedRange(
    JSUint8Array amounts,
    JSUint8Array openings,
    JSUint8Array seed,
  );
  external static bool solanaZkVerifyBatchedRange(
    JSUint8Array proof,
    JSUint8Array commitments,
    int n,
  );
  external static JSUint8Array solanaZkProveBatchedGroupedValidity2(
    JSUint8Array firstPubkey,
    JSUint8Array secondPubkey,
    JSUint8Array groupedLo,
    JSUint8Array groupedHi,
    double amountLo,
    double amountHi,
    JSUint8Array openingLo,
    JSUint8Array openingHi,
    JSUint8Array seed,
  );
  external static bool solanaZkVerifyBatchedGroupedValidity2(
    JSUint8Array firstPubkey,
    JSUint8Array secondPubkey,
    JSUint8Array groupedLo,
    JSUint8Array groupedHi,
    JSUint8Array proof,
  );
  external static JSUint8Array solanaZkProveBatchedGroupedValidity3(
    JSUint8Array firstPubkey,
    JSUint8Array secondPubkey,
    JSUint8Array thirdPubkey,
    JSUint8Array groupedLo,
    JSUint8Array groupedHi,
    double amountLo,
    double amountHi,
    JSUint8Array openingLo,
    JSUint8Array openingHi,
    JSUint8Array seed,
  );
  external static bool solanaZkVerifyBatchedGroupedValidity3(
    JSUint8Array firstPubkey,
    JSUint8Array secondPubkey,
    JSUint8Array thirdPubkey,
    JSUint8Array groupedLo,
    JSUint8Array groupedHi,
    JSUint8Array proof,
  );
  external static JSUint8Array solanaZkProveWithdraw(
    JSUint8Array sourceSecret,
    JSUint8Array sourcePubkey,
    JSUint8Array currentCiphertext,
    double currentBalance,
    double withdrawAmount,
    JSUint8Array seed,
  );
  external static JSUint8Array solanaZkProveTransfer(
    JSUint8Array sourceSecret,
    JSUint8Array sourcePubkey,
    JSUint8Array destPubkey,
    JSUint8Array auditorPubkey,
    JSUint8Array currentCiphertext,
    double currentBalance,
    double transferAmount,
    JSUint8Array seed,
  );
  external static JSUint8Array solanaZkProveTransferWithFee(
    JSUint8Array sourceSecret,
    JSUint8Array sourcePubkey,
    JSUint8Array destPubkey,
    JSUint8Array auditorPubkey,
    JSUint8Array authorityPubkey,
    JSUint8Array currentCiphertext,
    double currentBalance,
    double transferAmount,
    double feeRateBasisPoints,
    double maximumFee,
    JSUint8Array seed,
  );
  external static JSUint8Array solanaZkAeEncrypt(
    JSUint8Array key,
    double amount,
    JSUint8Array nonce,
  );
  external static double solanaZkAeDecrypt(JSUint8Array key, JSUint8Array ae);
  external static bool solanaZkValidateAe(JSUint8Array ae);

  // ---- Curve extras (parity with FFI bu_curve_*) ----
  external static bool curveIsInfinity(int curveId, JSUint8Array point);
  external static JSUint8Array curveGenerateSecret(
    int curveId,
    JSUint8Array seed,
  );
  external static JSUint8Array blsHashToG1(JSUint8Array msg, JSUint8Array dst);
  external static JSUint8Array blsHashToG2(JSUint8Array msg, JSUint8Array dst);

  // ---- Signing extras ----
  external static int ecdsaR1RecoveryId(
    JSUint8Array hash32,
    JSUint8Array sig64,
    JSUint8Array pk33,
  );
  external static JSUint8Array schnorrSignAux(
    JSUint8Array sk,
    JSUint8Array msg,
    JSUint8Array? aux,
    JSUint8Array? tweak,
  );

  // ---- Transcripts (Merlin / Strobe), integer handles ----
  external static int merlinNew(JSUint8Array label);
  external static void merlinAppend(
    int handle,
    JSUint8Array label,
    JSUint8Array message,
  );
  external static JSUint8Array merlinChallenge(
    int handle,
    JSUint8Array label,
    int len,
  );
  external static int merlinFork(int handle);
  external static void merlinFree(int handle);
  external static int strobeNew(JSUint8Array protocol);
  external static void strobeKey(int handle, JSUint8Array data);
  external static void strobeAd(int handle, bool meta, JSUint8Array data);
  external static JSUint8Array strobePrf(int handle, int len);
  external static void strobeFree(int handle);
}
