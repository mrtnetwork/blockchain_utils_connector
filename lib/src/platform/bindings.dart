import 'package:blockchain_utils_connector/src/bytes/bytes.dart';
import 'package:blockchain_utils_connector/src/connector/bu_features.dart';
import 'package:blockchain_utils_connector/src/platform/curve_bindings.dart';
import 'package:blockchain_utils_connector/src/platform/signing_bindings.dart';

export 'curve_bindings.dart';
export 'signing_bindings.dart';

/// Single platform interface — implemented only in `connector/io` and `connector/web`.
abstract interface class BuPlatformBindings
    implements BuCurveBindings, BuSigningBindings {
  /// Transport of this backend (implemented per platform file).
  BuBackendKind get backendKind;
  Object hashNew(BuHashNativeConfig config);
  void hashUpdate(Object handle, BuBytes data);
  void hashReset(Object handle);
  void hashFinish(Object handle, BuBytes out);
  void hashFree(Object handle);
  void hashClean(Object handle);
  int hashDigestLen(Object handle);
  int hashBlockSize(Object handle);
  int hashAlgo(Object handle);
  Object hashSaveState(Object handle);
  void hashRestoreState(Object handle, Object state);
  void hashFreeState(Object state);

  void pbkdf2({
    required int prf,
    required BuBytes password,
    required BuBytes salt,
    required int iterations,
    required BuBytes out,
  });
  void scrypt({
    required BuBytes password,
    required BuBytes salt,
    required int n,
    required int r,
    required int p,
    required BuBytes out,
  });
  void hkdf({
    required int prf,
    required BuBytes ikm,
    BuBytes? salt,
    BuBytes? info,
    required BuBytes out,
  });

  void chacha20Poly1305Encrypt({
    required BuBytes key,
    required BuBytes nonce,
    required BuBytes plaintext,
    BuBytes? aad,
    required BuBytes out,
  });
  bool chacha20Poly1305Decrypt({
    required BuBytes key,
    required BuBytes nonce,
    required BuBytes ciphertext,
    BuBytes? aad,
    required BuBytes out,
  });
  void aesGcmEncrypt({
    required BuBytes key,
    required BuBytes nonce,
    required BuBytes plaintext,
    BuBytes? aad,
    required BuBytes out,
  });
  bool aesGcmDecrypt({
    required BuBytes key,
    required BuBytes nonce,
    required BuBytes ciphertext,
    BuBytes? aad,
    required BuBytes out,
  });

  /// XSalsa20-Poly1305 encrypt (NaCl secretbox, 32-byte [key], strict
  /// 24-byte [nonce]). Writes `TAG ‖ CIPHERTEXT` (authenticator first)
  /// into [out] (`plaintext.length + 16`). Throws [BuError] on failure.
  void xsalsa20Poly1305Encrypt({
    required BuBytes key,
    required BuBytes nonce,
    required BuBytes plaintext,
    required BuBytes out,
  });

  /// XSalsa20-Poly1305 decrypt (`TAG ‖ CIPHERTEXT` [sealed] → [out]).
  /// Returns false on authentication failure.
  bool xsalsa20Poly1305Decrypt({
    required BuBytes key,
    required BuBytes nonce,
    required BuBytes sealed,
    required BuBytes out,
  });

  /// NaCl `crypto_box_beforenm` → 32-byte transport key.
  /// Throws [BuError] on invalid keys or a zero shared secret.
  BuBytes salsaBoxBeforenm({
    required BuBytes peerPublicKey,
    required BuBytes secretKey,
  });

  /// NaCl `crypto_box_easy` detached encrypt (`TAG ‖ CIPHERTEXT` into
  /// [out]). Throws [BuError] on failure.
  void salsaBoxEncrypt({
    required BuBytes peerPublicKey,
    required BuBytes secretKey,
    required BuBytes nonce,
    required BuBytes plaintext,
    required BuBytes out,
  });

  /// NaCl `crypto_box_open_easy` detached decrypt ([sealed] → [out]).
  /// Returns false on authentication failure.
  bool salsaBoxDecrypt({
    required BuBytes peerPublicKey,
    required BuBytes secretKey,
    required BuBytes nonce,
    required BuBytes sealed,
    required BuBytes out,
  });

  Object aesNew(BuBytes key);
  void aesFree(Object handle);
  void aesEncryptBlock(Object handle, BuBytes src, BuBytes out);
  void aesDecryptBlock(Object handle, BuBytes src, BuBytes out);
  void aesCbcEncrypt({
    required BuBytes key,
    required BuBytes iv,
    required BuBytes data,
    required BuBytes out,
  });
  void aesCbcDecrypt({
    required BuBytes key,
    required BuBytes iv,
    required BuBytes data,
    required BuBytes out,
  });
  BuBytes aesEcbEncryptPadded({
    required BuBytes key,
    required BuBytes data,
    required int padding,
  });
  BuBytes? aesEcbDecryptPadded({
    required BuBytes key,
    required BuBytes data,
    required int padding,
  });
  void aesCtr({
    required BuBytes key,
    required BuBytes counter,
    required BuBytes data,
    required BuBytes out,
  });
  void chacha20Xor({
    required BuBytes key,
    required BuBytes nonce,
    required int counter,
    required BuBytes data,
    required BuBytes out,
  });
  void chacha20StreamXor({
    required BuBytes key,
    required BuBytes nonce,
    required BuBytes data,
    required BuBytes out,
    int nonceInplaceCounterLength = 0,
    int seekBytes = 0,
  });
  BuBytes keccakF1600(BuBytes state200);

  /// Seed global ChaCha20 once (exactly 32 bytes).
  /// Returns 0 = ok, 2 = already seeded, other = error.
  int rngSeed(BuBytes seed32);

  /// 1 if global RNG was seeded, else 0.
  int rngIsSeeded();

  /// Fill [out] from global ChaCha20 backend.
  int rngFill(BuBytes out);

  // —— Curve compression (strict validating decode + re-encode) ——
  /// Uncompressed point length for [curveId] (0 = unknown).
  int curvePointUncompressedLen(int curveId);

  /// Re-encode any accepted form as compressed into [out]. Returns 0.
  int curveCompress(int curveId, BuBytes point, BuBytes out);

  /// Re-encode any accepted form as uncompressed into [out]. Returns 0.
  int curveUncompress(int curveId, BuBytes point, BuBytes out);

  /// Validate any accepted point form and re-encode it as compressed into
  /// [out], rejecting the point at infinity. Returns 0, nonzero on error.
  int curveNormalizePubkey(int curveId, BuBytes point, BuBytes out);

  // —— Zcash / Orchard (Poseidon + Sinsemilla + Pedersen) ——
  int poseidonHashTwo(BuBytes a, BuBytes b, BuBytes out32);
  int poseidonHash(List<BuBytes> inputs, BuBytes out32);
  int poseidonPermute(BuBytes state96);
  // BN254 Poseidon (may be absent natively → implementations return 6).
  int poseidonBn254Hash(List<BuBytes> inputs, BuBytes out32);
  int sinsemillaHashBits(
    String domain,
    BuBytes packedBits,
    int bitLen,
    BuBytes out32,
  );
  int sinsemillaHashBitstring(String domain, String bits01, BuBytes out32);
  int sinsemillaCommit(
    String domain,
    BuBytes packedBits,
    int bitLen,
    BuBytes r32,
    BuBytes out32,
  );
  int sinsemillaShortCommit(
    String domain,
    BuBytes packedBits,
    int bitLen,
    BuBytes r32,
    BuBytes out32,
  );
  int pedersenHash(
    int personal,
    int layer,
    BuBytes packedBits,
    int bitLen,
    BuBytes out32,
  );
  int pedersenHashBitstring(
    int personal,
    int layer,
    String bits01,
    BuBytes out32,
  );

  // —— Groth16 / Sapling verify (BLS12-381 + BN254) ——
  /// Verify BLS12 Groth16 proof. Returns 0 on success (BU_G16_OK).
  int groth16VerifyBls({
    required BuBytes proof,
    required BuBytes vk,
    required BuBytes publicInputs,
  });

  /// Verify BN254 Groth16 proof (Sui/Aptos layout). Returns 0 on success.
  int groth16VerifyBn254({
    required BuBytes proof,
    required BuBytes vk,
    required BuBytes publicInputs,
  });

  /// BLS12-381 proof length (192). 0/negative when unsupported.
  int groth16BlsProofLen();

  /// BN254 proof length (256). 0/negative when unsupported.
  int groth16Bn254ProofLen();

  // —— ZK bridge ——
  /// ZK API version (Rust `ZK_API_VERSION`, currently 1).
  int zkVersion();

  /// Accepted no-op logging toggle. Returns 0 (`ZK_OK`).
  int zkEnableLogging(int enable, int mode);

  /// Backend interface version (`bu_build_version` / `backendVersion`).
  int backendVersion();

  /// Cargo feature bitmask (`bu_build_features` / `backendFeatures`).
  int backendFeatures();

  // —— Transcripts (Merlin / Strobe; opaque handles) ——
  /// Open a Merlin transcript over [label]. Returns the opaque handle.
  Object merlinNew(BuBytes label);

  /// `append_message(label, message)` on [handle].
  void merlinAppend(Object handle, BuBytes label, BuBytes message);

  /// `challenge_bytes(label)` into [out] (any length).
  void merlinChallenge(Object handle, BuBytes label, BuBytes out);

  /// Fork [handle] → fresh handle with identical state.
  Object merlinFork(Object handle);

  /// Close a Merlin handle. Idempotent at the Dart layer.
  void merlinFree(Object handle);

  /// Open a Strobe-128 context over [protocol]. Returns the opaque handle.
  Object strobeNew(BuBytes protocol);

  /// `key(data)` ratchet on [handle].
  void strobeKey(Object handle, BuBytes data);

  /// `ad(data)` on [handle] ([meta] selects meta-AD).
  void strobeAd(Object handle, bool meta, BuBytes data);

  /// `prf` into [out] (any non-empty length).
  void strobePrf(Object handle, BuBytes out);

  /// Close a Strobe handle. Idempotent at the Dart layer.
  void strobeFree(Object handle);

  // —— Sapling prover (opaque params handles) ——
  /// Load Spend params. Returns 0 and sets [outHandle] on success.
  int saplingSetSpendParams(BuBytes params, List<Object?> outHandle);

  /// Load Output params. Returns 0 and sets [outHandle] on success.
  int saplingSetOutputParams(BuBytes params, List<Object?> outHandle);

  /// Release a params handle.
  void saplingParamsFree(Object handle);

  /// Prove: writes 192-byte proof to [outProof] and 7/5×32 inputs to [outInputs].
  int saplingProve(
    Object handle,
    int kind,
    BuBytes witness,
    BuBytes outProof,
    BuBytes outInputs,
  );

  /// Verify proof + positional inputs under [handle]. Returns 0 on success.
  int saplingVerify({
    required Object handle,
    required int kind,
    required BuBytes proof,
    required BuBytes inputs,
  });

  // —— Orchard prover (opaque proving-key handles) ——
  /// Build a proving key for [version] (0/1/2). Sets [outPk] on success.
  int orchardPkNew(int version, List<Object?> outPk);

  /// Release a proving-key handle.
  void orchardPkFree(Object pk);

  /// Prove N packed circuits (`inputs` = n x 1716 bytes, `instances` =
  /// n x 320 bytes, `seed` = 32 bytes). Appends the proof to [outProof]
  /// (size-query handled internally; no caller pre-sizing needed).
  int orchardCreateProof(
    Object pk,
    BuBytes inputs,
    BuBytes instances,
    BuBytes seed,
    int version,
    int disableCrossAddress,
    List<BuBytes> outProof,
  );

  /// Verify [proof] against n×10×32 [instances] limbs. Returns 0 on success.
  int orchardVerifyProof({
    required Object pk,
    required BuBytes proof,
    required BuBytes instances,
    required int version,
    required int disableCrossAddress,
  });

  // —— Merkle contexts (u32 ids, ZK global codes) ——
  /// Create an empty wallet context. Returns the id, 0 on failure.
  int merkleCreateContext();

  /// Drop a context. Returns 0 (`ZK_OK`).
  int merkleCloseContext(int id);

  /// Export a context blob. Appends to [outBlob] (size-query internal).
  int merkleGetContext(int id, List<BuBytes> outBlob);

  /// Restore a context from an exported blob (replaces state).
  int merkleInsertChainState(int id, BuBytes blob);

  /// Append n = len/32 leaves to a protocol tree (kind 0/1).
  int merkleUpdateState(int id, int kind, BuBytes leaves);

  /// Absorb one level-16 subtree [root32] at [start].
  int merkleUpdateSubtree(int id, int kind, int start, BuBytes root32);

  /// Merge checkpoints + contiguous subtrees from a merge blob.
  int merkleMergeState(int id, int kind, BuBytes blob);

  /// Snapshot both trees under [checkpointId].
  int merkleCheckpoint(int id, int checkpointId);

  /// Witness packed u64le [positions] at [checkpointId]. Appends the raw
  /// `anchor[32] | npaths_u32 | paths[]` blob to [outWitness].
  int merkleCreateWitness(
    int id,
    int kind,
    int checkpointId,
    BuBytes positions,
    List<BuBytes> outWitness,
  );

  /// Sapling Spend: publicInputs must be 7×32 LE Fr.
  int saplingVerifySpend({
    required BuBytes proof,
    required BuBytes vk,
    required BuBytes publicInputs,
  });

  /// Sapling Output: publicInputs must be 5×32 LE Fr.
  int saplingVerifyOutput({
    required BuBytes proof,
    required BuBytes vk,
    required BuBytes publicInputs,
  });

  // —— FF1 (NIST SP 800-38G) flexible digits ——
  /// Encrypt digit array [pt] → [out] (same length). Digits in 0..radix-1.
  int ff1Encrypt({
    required BuBytes key,
    required int radix,
    required BuBytes pt,
    BuBytes? tweak,
    required BuBytes out,
  });

  /// Decrypt digit array [ct] → [out] (same length).
  int ff1Decrypt({
    required BuBytes key,
    required int radix,
    required BuBytes ct,
    BuBytes? tweak,
    required BuBytes out,
  });

  int ff1EncryptBinary({
    required BuBytes key,
    required BuBytes pt,
    BuBytes? tweak,
    required BuBytes out,
  });

  int ff1DecryptBinary({
    required BuBytes key,
    required BuBytes ct,
    BuBytes? tweak,
    required BuBytes out,
  });

  // —— X25519 ——
  /// X25519(k, u) → out32
  int x25519(BuBytes scalar32, BuBytes u32, BuBytes out32);

  /// public = X25519(private, 9)
  int x25519PublicKey(BuBytes private32, BuBytes out32);

  /// shared = X25519(private, peer_public)
  int x25519Dh(BuBytes private32, BuBytes peerPublic32, BuBytes out32);

  /// Ed25519 compressed pubkey → X25519
  int ed25519PkToX25519(BuBytes edPk32, BuBytes out32);

  /// Ed25519 seed → clamped X25519 secret
  int ed25519SeedToX25519(BuBytes seed32, BuBytes out32);

  // —— Hardware-wallet codecs (no transport; see BuHwApi) ——
  /// 1 = supports, 0 = no, 6 = native built without `hw`.
  int hwSupportsCoin(int device, int coin);

  /// 1 = QR/SD-only, 0 = USB, 6 = native built without `hw`.
  int hwIsAirgap(int device);

  /// Parse `"m/44'/0'/..."` into `<u32 LE>` in [out]. Returns bytes
  /// written or error code (both backends normalize to bytes).
  int hwParsePath(String path, BuBytes out);

  /// 0 = valid path for device+coin, else error code.
  int hwValidatePath(int device, int coin, BuBytes pathU32);

  /// USB request bytes into [out]. Returns written length or error code.
  int hwGetAddressRequest(int device, int coin, BuBytes pathU32, BuBytes out);

  /// USB response → pubkey/address bytes into [out].
  int hwParseAddressResponse(int device, BuBytes response, BuBytes out);

  /// Sign-request bytes into [out] (Ledger APDU / Trezor `SignMessage`
  /// frame). [payload] is the 32-byte sighash (Ledger) or message (Trezor).
  int hwSignRequest(
    int device,
    int coin,
    BuBytes pathU32,
    BuBytes payload,
    BuBytes out,
  );

  /// Sign response → signature bytes into [out].
  int hwParseSignResponse(int device, BuBytes response, BuBytes out);

  /// Open a Trezor `SignTx` session. Returns request bytes in [out].
  int hwSignTxStart(
    int device,
    int coin,
    int inputsCount,
    int outputsCount,
    BuBytes out,
  );

  /// One `TxRequest` → 8 bytes (`type LE32 || index LE32`,
  /// `0xFFFFFFFF` = absent) in [out]. Returns 0 or error code.
  int hwParseTxRequest(int device, BuBytes response, BuBytes out);

  /// `TXFINISHED` signature bytes into [out].
  int hwTxRequestSignature(int device, BuBytes response, BuBytes out);

  /// `TXFINISHED` serialized tx into [out].
  int hwTxRequestSerialized(int device, BuBytes response, BuBytes out);

  /// `TxRequest` prev-tx hash (32 bytes) into [out]; error when absent.
  int hwTxRequestTxHash(int device, BuBytes response, BuBytes out);

  /// `TxAck` for `TXMETA` into [out].
  int hwTxAckMeta(
    int version,
    int lockTime,
    int inputsCount,
    int outputsCount,
    BuBytes out,
  );

  /// `TxAck` for `TXINPUT` into [out] ([prevHash32], [pathU32] as u32 LE,
  /// [amountSat] = previous output value (required); [scriptSig] = original
  /// scriptSig for previous transactions' inputs (empty = omit, for the
  /// input being signed); [scriptType]: 0 SPENDADDRESS … 4 SPENDP2SHWITNESS,
  /// always encoded).
  int hwTxAckInput(
    BuBytes prevHash32,
    int prevIndex,
    BuBytes pathU32,
    int amountSat,
    BuBytes scriptSig,
    int scriptType,
    BuBytes out,
  );

  /// `TxAck` for `TXOUTPUT` (pay to [address], [amountSat], explicit
  /// [scriptType]) into [out].
  int hwTxAckOutput(String address, int amountSat, int scriptType, BuBytes out);

  /// `TxAck` for `TXOUTPUT` (change to [pathU32], explicit [scriptType]).
  int hwTxAckChange(
    BuBytes pathU32,
    int amountSat,
    int scriptType,
    BuBytes out,
  );

  /// `TxAck` for `TXOUTPUT` of a PREVIOUS transaction into [out]
  /// (`bin_outputs`: raw [scriptPubKey] + [amountSat]).
  int hwTxAckBinOutput(BuBytes scriptPubKey, int amountSat, BuBytes out);

  // —— BitBox02 session handles (stateful Noise_XX; I/O stays app-side) ——
  // Transport contract (firmware v9.28.0): the app owns U2F-HID reports +
  // the HWW arbitration layer ([REQ_NEW] + OP message, RETRY polling, ACK
  // strip) and hands this API OP payloads whose replies start with the
  // OP_STATUS byte. Codec frames below are plaintext (encrypt via session).
  /// Open initiator session from 32-B host static + ephemeral. Returns
  /// handle (>0) or error code. Fails instead of clobbering a live session.
  int hwBitBoxHsNew(BuBytes staticPriv32, BuBytes ephemeralPriv32);

  /// Write handshake m1 (32 B) into [out].
  int hwBitBoxHsM1(BuBytes out32);

  /// Ingest handshake m2 (96 B). 0 = ok. Any crypto error spends the
  /// session (reopen) — half-mixed state never survives.
  int hwBitBoxHsM2(BuBytes m2);

  /// Write handshake m3 (64 B) into [out].
  int hwBitBoxHsM3(BuBytes out64);

  /// Split into transport keys. 0 = ok.
  int hwBitBoxHsSplit();

  /// Encrypt one message (plaintext + 16-B tag) into [out].
  int hwBitBoxEncrypt(BuBytes plaintext, BuBytes out);

  /// Decrypt one message into [out].
  int hwBitBoxDecrypt(BuBytes ciphertext, BuBytes out);

  /// Handshake hash (32 B, pairing-code source) into [out32].
  int hwBitBoxHsHash(BuBytes out32);

  /// Close + wipe. Idempotent, always 0.
  int hwBitBoxFree();

  // —— BitBox02 HWW codec (plaintext frames; encrypt via the session) ——
  /// `Request{btc_pub}` bytes into [out]. [xpubType]: 0 TPUB … 4 VPUB.
  int hwBitBoxBtcPubRequest(
    int coin,
    BuBytes pathU32,
    int xpubType,
    bool display,
    BuBytes out,
  );

  /// `Response` → xpub UTF-8 bytes into [out].
  int hwBitBoxPubParse(BuBytes response, BuBytes out);

  // —— BitBox02 BTC signing (plaintext frames; encrypt via the session) ——
  /// `Request{btc_sign_init}` into [out].
  int hwBitBoxSignInit(
    int coin,
    BuBytes pathU32,
    int simpleType,
    int version,
    int inputsCount,
    int outputsCount,
    int locktime,
    BuBytes out,
  );

  /// `sign_next` → 8 bytes (`type LE32 || index LE32`) in [out].
  int hwBitBoxSignNextParse(BuBytes response, BuBytes out);

  /// `DONE` signature (64 B) into [out].
  int hwBitBoxSignNextSignature(BuBytes response, BuBytes out);

  /// `prev_index` (`0xFFFFFFFF` = absent, negative = error).
  int hwBitBoxSignNextPrevIndex(BuBytes response);

  /// `Request{btc_sign_input}` into [out].
  int hwBitBoxSignInput(
    BuBytes prevHash32,
    int prevIndex,
    int amountSat,
    int sequence,
    BuBytes pathU32,
    int scriptConfigIndex,
    BuBytes out,
  );

  /// `Request{btc_sign_output}` (external) into [out].
  int hwBitBoxSignOutput(
    int outputType,
    int amountSat,
    BuBytes payload,
    BuBytes out,
  );

  /// `Request{btc_sign_output}` (change) into [out].
  int hwBitBoxSignChange(
    BuBytes pathU32,
    int amountSat,
    int scriptConfigIndex,
    BuBytes out,
  );

  /// `Request{btc: BTCRequest{prevtx_init}}` into [out].
  int hwBitBoxSignPrevtxInit(
    int version,
    int inputsCount,
    int outputsCount,
    int locktime,
    BuBytes out,
  );

  /// `Request{btc: BTCRequest{prevtx_input}}` into [out].
  int hwBitBoxSignPrevtxInput(
    BuBytes prevHash32,
    int prevIndex,
    BuBytes scriptSig,
    int sequence,
    BuBytes out,
  );

  /// `Request{btc: BTCRequest{prevtx_output}}` into [out].
  int hwBitBoxSignPrevtxOutput(int amountSat, BuBytes script, BuBytes out);

  // —— Ledger app-bitcoin v2 (CLA 0xE1, verified live) ——
  /// `GET_MASTER_FINGERPRINT` request into [out].
  int hwLedgerFingerprint(BuBytes out);

  /// 4-byte fingerprint from `DATA || 0x9000` into [out].
  int hwLedgerFingerprintParse(BuBytes response, BuBytes out);

  // —— Trezor identity signing (SLIP-13; strings are UTF-8 text) ——
  /// `IdentityType` bytes into [out].
  int hwIdentityEncode(
    BuBytes proto,
    BuBytes user,
    BuBytes host,
    BuBytes port,
    BuBytes path,
    int index,
    BuBytes out,
  );

  /// Framed `SignIdentity` ([curve]: 0 omit, 1 secp256k1, 2 nist256p1).
  int hwSignIdentityRequest(
    BuBytes identity,
    BuBytes hidden,
    BuBytes visual,
    int curve,
    BuBytes out,
  );

  /// `SignedIdentity.address` UTF-8 into [out] (absent = error).
  int hwSignedIdentityAddress(BuBytes response, BuBytes out);

  /// `SignedIdentity.public_key` into [out].
  int hwSignedIdentityPubkey(BuBytes response, BuBytes out);

  /// `SignedIdentity.signature` into [out].
  int hwSignedIdentitySignature(BuBytes response, BuBytes out);

  /// Airgap QR string (UTF-8) into [out].
  int hwQrRequest(int device, int coin, BuBytes pathU32, BuBytes out);

  /// Single-part QR → payload bytes into [out].
  int hwQrParse(int device, String qr, BuBytes out);

  /// PSBT → 8-byte `inputs LE32 || outputs LE32` in [out]. 0 = ok.
  int hwPsbtCounts(BuBytes psbt, BuBytes out8);

  /// `ur:<type>/<body>` UTF-8 into [out].
  int hwUrEncode(String type, BuBytes payload, BuBytes out);

  /// UR → payload bytes into [out].
  int hwUrDecodePayload(String ur, BuBytes out);

  /// UR → type string UTF-8 into [out].
  int hwUrDecodeType(String ur, BuBytes out);

  /// Chunk [payload] into concatenated 64-byte HID reports in [out].
  int hwHidFrame(BuBytes payload, int channel, int tag, BuBytes out);

  /// Reassemble concatenated 64-byte [reports] into one payload in [out].
  int hwHidUnframe(BuBytes reports, int channel, int tag, BuBytes out);

  // —— Monero Bulletproofs+ ——
  /// Verify a packed batch. Returns 0 = valid, 1 = invalid equation,
  /// negative = malformed/error (Rust `BU_MONERO_*`).
  int moneroBpPlusVerify(BuBytes packed);

  /// Prove for `amountsLe` (each 8 bytes LE u64) with `gamma` masks (n×32).
  /// Appends one proof blob to [outBlob] (size-query internal).
  int moneroBpPlusProveAmounts({
    required List<BuBytes> amountsLe,
    required List<BuBytes> gamma,
    required BuBytes seed32,
    required List<BuBytes> outBlob,
  });

  /// Prove for raw bit-scalars `sv` (n×32) with `gamma` masks (n×32).
  /// Appends one proof blob to [outBlob] (size-query internal).
  int moneroBpPlusProveScalars({
    required List<BuBytes> sv,
    required List<BuBytes> gamma,
    required BuBytes seed32,
    required List<BuBytes> outBlob,
  });

  // —— Monero output scan (fast unlock) ——
  /// Batch scan. Packed inputs (all 32-byte keys raw, counts u32 LE,
  /// tags int32 LE with -1 = absent). Appends packed 76-byte match records
  /// (`out_idx|acc_idx|addr_pos` u32 LE + derivation[32] + derived_pk[32])
  /// to [outBlob] (size-query internal; zero matches = OK + empty).
  /// Returns 0 on success (Rust `BU_MONERO_*`).
  int moneroUnlockBatch({
    required BuBytes viewSecrets,
    required BuBytes spendPubs,
    required BuBytes spendCountsLe,
    required BuBytes outKeys,
    required BuBytes txPubs,
    required BuBytes additional,
    required BuBytes additionalPresent,
    required BuBytes viewTagsLe,
    required BuBytes outIndicesLe,
    required int outCount,
    required int accCount,
    required List<BuBytes> outBlob,
  });

  // —— Solana confidential-transfer ZK ——
  /// Validate a 32-byte ElGamal pubkey. 0 ok, 1 invalid, negative = error.
  int solanaZkValidatePubkey(BuBytes pubkey);

  /// Validate a 64-byte ElGamal ciphertext. 0 ok, 1 invalid, negative = error.
  int solanaZkValidateCiphertext(BuBytes ciphertext);

  /// Validate a 36-byte AES decryptable balance (nonce || ct || tag).
  int solanaZkValidateAe(BuBytes ae);

  /// AES-GCM-SIV encrypt u64 [amount] with 16-byte [key] and 12-byte
  /// [nonce12] into 36-byte [out36]. 0 ok, else error.
  int solanaZkAeEncrypt(
    BuBytes key16,
    int amount,
    BuBytes nonce12,
    BuBytes out36,
  );

  /// AES-GCM-SIV decrypt 36-byte [ae] with 16-byte [key] into 8-byte LE
  /// [outLe8]. 0 ok, 1 auth-failed, negative error.
  int solanaZkAeDecrypt(BuBytes key16, BuBytes ae, BuBytes outLe8);

  /// Derive `P = s^{-1} * H` into [out32] (32 bytes). 0 ok, else error.
  int solanaZkPubkeyFromSecret(BuBytes secret, BuBytes out32);

  /// Deterministic encrypt-with-opening into [out64] (64 bytes).
  int solanaZkEncryptWith(
    BuBytes pubkey,
    int amount,
    BuBytes opening,
    BuBytes out64,
  );

  /// Decrypt to u32 amount as 8-byte LE into [outLe8]. 0 ok, else error.
  int solanaZkDecryptU32(BuBytes secret, BuBytes ciphertext, BuBytes outLe8);

  /// Prove pubkey-validity into [out64]. 0 ok, else error.
  int solanaZkProvePubkeyValidity(
    BuBytes secret,
    BuBytes seed32,
    BuBytes out64,
  );

  /// Verify 64-byte pubkey-validity proof. 0 valid, 1 invalid, negative error.
  int solanaZkVerifyPubkeyValidity(BuBytes pubkey, BuBytes proof);

  /// Prove zero-ciphertext into [out96].
  int solanaZkProveZeroCiphertext(
    BuBytes secret,
    BuBytes pubkey,
    BuBytes ciphertext,
    BuBytes seed32,
    BuBytes out96,
  );

  /// Verify 96-byte zero-ciphertext proof. 0 valid, 1 invalid.
  int solanaZkVerifyZeroCiphertext(
    BuBytes pubkey,
    BuBytes ciphertext,
    BuBytes proof,
  );

  /// Prove ciphertext-commitment equality into [out192].
  int solanaZkProveEquality({
    required BuBytes secret,
    required BuBytes pubkey,
    required BuBytes ciphertext,
    required BuBytes commitment,
    required BuBytes opening,
    required int amount,
    required BuBytes seed32,
    required BuBytes out192,
  });

  /// Verify 192-byte equality proof. 0 valid, 1 invalid.
  int solanaZkVerifyEquality({
    required BuBytes pubkey,
    required BuBytes ciphertext,
    required BuBytes commitment,
    required BuBytes proof,
  });

  /// Prove ciphertext-ciphertext equality into [out224].
  int solanaZkProveCiphertextEquality({
    required BuBytes firstSecret,
    required BuBytes firstPubkey,
    required BuBytes secondPubkey,
    required BuBytes firstCiphertext,
    required BuBytes secondCiphertext,
    required BuBytes secondOpening,
    required int amount,
    required BuBytes seed32,
    required BuBytes out224,
  });

  /// Verify 224-byte ciphertext-equality proof. 0 valid, 1 invalid.
  int solanaZkVerifyCiphertextEquality({
    required BuBytes firstPubkey,
    required BuBytes secondPubkey,
    required BuBytes firstCiphertext,
    required BuBytes secondCiphertext,
    required BuBytes proof,
  });

  /// Prove 2-handle grouped validity into [out160].
  int solanaZkProveGroupedValidity2({
    required BuBytes firstPubkey,
    required BuBytes secondPubkey,
    required BuBytes grouped96,
    required int amount,
    required BuBytes opening,
    required BuBytes seed32,
    required BuBytes out160,
  });

  /// Verify 160-byte 2-handle proof. 0 valid, 1 invalid.
  int solanaZkVerifyGroupedValidity2({
    required BuBytes firstPubkey,
    required BuBytes secondPubkey,
    required BuBytes grouped96,
    required BuBytes proof,
  });

  /// Prove 3-handle grouped validity into [out192].
  int solanaZkProveGroupedValidity3({
    required BuBytes firstPubkey,
    required BuBytes secondPubkey,
    required BuBytes thirdPubkey,
    required BuBytes grouped128,
    required int amount,
    required BuBytes opening,
    required BuBytes seed32,
    required BuBytes out192,
  });

  /// Verify 192-byte 3-handle proof. 0 valid, 1 invalid.
  int solanaZkVerifyGroupedValidity3({
    required BuBytes firstPubkey,
    required BuBytes secondPubkey,
    required BuBytes thirdPubkey,
    required BuBytes grouped128,
    required BuBytes proof,
  });

  /// Prove batched 2-handle validity into [out160].
  int solanaZkProveBatchedGroupedValidity2({
    required BuBytes firstPubkey,
    required BuBytes secondPubkey,
    required BuBytes groupedLo96,
    required BuBytes groupedHi96,
    required int amountLo,
    required int amountHi,
    required BuBytes openingLo,
    required BuBytes openingHi,
    required BuBytes seed32,
    required BuBytes out160,
  });

  /// Verify 160-byte batched 2-handle proof. 0 valid, 1 invalid.
  int solanaZkVerifyBatchedGroupedValidity2({
    required BuBytes firstPubkey,
    required BuBytes secondPubkey,
    required BuBytes groupedLo96,
    required BuBytes groupedHi96,
    required BuBytes proof,
  });

  /// Prove batched 3-handle validity into [out192].
  int solanaZkProveBatchedGroupedValidity3({
    required BuBytes firstPubkey,
    required BuBytes secondPubkey,
    required BuBytes thirdPubkey,
    required BuBytes groupedLo128,
    required BuBytes groupedHi128,
    required int amountLo,
    required int amountHi,
    required BuBytes openingLo,
    required BuBytes openingHi,
    required BuBytes seed32,
    required BuBytes out192,
  });

  /// Verify 192-byte batched 3-handle proof. 0 valid, 1 invalid.
  int solanaZkVerifyBatchedGroupedValidity3({
    required BuBytes firstPubkey,
    required BuBytes secondPubkey,
    required BuBytes thirdPubkey,
    required BuBytes groupedLo128,
    required BuBytes groupedHi128,
    required BuBytes proof,
  });

  /// Prove percentage-with-cap into [out256].
  int solanaZkProvePercentageWithCap({
    required BuBytes percentageCommitment,
    required BuBytes percentageOpening,
    required int percentageAmount,
    required BuBytes deltaCommitment,
    required BuBytes deltaOpening,
    required int deltaAmount,
    required BuBytes claimedCommitment,
    required BuBytes claimedOpening,
    required int maxValue,
    required BuBytes seed32,
    required BuBytes out256,
  });

  /// Verify 256-byte percentage proof. 0 valid, 1 invalid.
  int solanaZkVerifyPercentageWithCap({
    required BuBytes percentageCommitment,
    required BuBytes deltaCommitment,
    required BuBytes claimedCommitment,
    required int maxValue,
    required BuBytes proof,
  });

  /// Prove batched range. Appends `proof || pod_c(256) || pod_b(8)` to
  /// [outBlob] (size-query internal).
  int solanaZkProveBatchedRange({
    required List<BuBytes> amountsLe,
    required List<BuBytes> openings,
    required BuBytes seed32,
    required List<BuBytes> outBlob,
  });

  /// Verify batched range against n×32 [commitments]. 0 valid, 1 invalid.
  int solanaZkVerifyBatchedRange({
    required BuBytes proof,
    required BuBytes commitments,
    required int n,
  });

  /// Prove withdraw bundle into [out1256] (fixed layout, see FFI docs).
  int solanaZkProveWithdraw({
    required BuBytes sourceSecret,
    required BuBytes sourcePubkey,
    required BuBytes currentCiphertext,
    required int currentBalance,
    required int withdrawAmount,
    required BuBytes seed32,
    required BuBytes out1256,
  });

  /// Prove transfer bundle into [out1896] (fixed layout, see FFI docs).
  int solanaZkProveTransfer({
    required BuBytes sourceSecret,
    required BuBytes sourcePubkey,
    required BuBytes destPubkey,
    required BuBytes auditorPubkey,
    required BuBytes currentCiphertext,
    required int currentBalance,
    required int transferAmount,
    required BuBytes seed32,
    required BuBytes out1896,
  });

  /// Prove transfer-with-fee bundle into [out2576] (fixed layout).
  int solanaZkProveTransferWithFee({
    required BuBytes sourceSecret,
    required BuBytes sourcePubkey,
    required BuBytes destPubkey,
    required BuBytes auditorPubkey,
    required BuBytes authorityPubkey,
    required BuBytes currentCiphertext,
    required int currentBalance,
    required int transferAmount,
    required int feeRateBasisPoints,
    required int maximumFee,
    required BuBytes seed32,
    required BuBytes out2576,
  });
}

class BuHashNativeConfig {
  const BuHashNativeConfig({
    required this.algo,
    this.digestLength = 0,
    this.hmac = false,
    this.key,
    this.salt,
    this.personal,
    this.seed = 0,
    this.fanout = 0,
    this.maxDepth = 0,
    this.leafSize = 0,
    this.nodeOffset = 0,
    this.nodeDepth = 0,
    this.innerDigestLength = 0,
    this.lastNode = false,
  });

  final int algo;
  final int digestLength;
  final bool hmac;
  final BuBytes? key;
  final BuBytes? salt;
  final BuBytes? personal;
  final int seed;
  final int fanout;
  final int maxDepth;
  final int leafSize;
  final int nodeOffset;
  final int nodeDepth;
  final int innerDigestLength;
  final bool lastNode;
}

abstract final class BuHashAlgo {
  // Must match Rust `BU_HASH_*` in connector/ffi/hash.rs
  static const sha256 = 1;
  static const sha224 = 2;
  static const sha512 = 3;
  static const sha384 = 4;
  static const sha512_256 = 5;
  static const sha1 = 6;
  static const ripemd160 = 7;
  static const md5 = 8;
  static const md4 = 9;
  static const keccak256 = 10;
  static const keccak224 = 11;
  static const keccak384 = 12;
  static const keccak512 = 13;
  static const sha3_256 = 14;
  static const sha3_512 = 15;
  static const shake128 = 16;
  static const shake256 = 17;
  static const sha3_224 = 18;
  static const sha3_384 = 19;
  static const blake2b = 20;
  static const blake2s = 21;
  static const xxh32 = 30;
  static const xxh64 = 31;
  static const xxh3_64 = 32;
  static const xxh3_128 = 33;
  static const xxh3_256 = 34;
  static const ripemd128 = 35;
  static const ripemd256 = 36;
  static const ripemd320 = 37;
}

abstract final class BuKdfPrf {
  static const sha256 = 1;
  static const sha512 = 2;
  static const sha384 = 3;
}
