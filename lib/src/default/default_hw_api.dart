import 'dart:convert';

import 'package:blockchain_utils_connector/src/api/hw_api.dart';
import 'package:blockchain_utils_connector/src/bytes/bytes.dart';
import 'package:blockchain_utils_connector/src/error/bu_error.dart';
import 'package:blockchain_utils_connector/src/platform/bindings.dart';

BuBytes _utf8(String s) => BuBytes(utf8.encode(s));

class DefaultHwApi implements BuHwApi {
  DefaultHwApi(this._b);
  final BuPlatformBindings _b;
  static const _tag = 'hw';

  BuError _mapRc(int rc, String op) {
    if (rc == -4 || rc == -5 || rc == 6) {
      return BuError(
        DefaultErrorType.unsupported,
        '$_tag.$op: unsupported (native built without hw?)',
      );
    }
    if (rc == -2) {
      return BuError(
        DefaultErrorType.bufferTooSmall,
        '$_tag.$op: buffer too small',
      );
    }
    return BuError(
      DefaultErrorType.invalidArgument,
      '$_tag.$op: invalid input (rc=$rc)',
    );
  }

  BuResult<BuBytes> _take(int rc, BuBytes out) {
    if (rc < 0 || rc == 6) {
      return BuResult.err(_mapRc(rc, 'call'));
    }
    return BuResult.ok(BuBytes(out.sublist(0, rc)));
  }

  @override
  BuResult<bool> supportsCoin({required int device, required int coin}) {
    final rc = _b.hwSupportsCoin(device, coin);
    if (rc == 1) {
      return BuResult.ok(true);
    }
    if (rc == 0) {
      return BuResult.ok(false);
    }
    return BuResult.err(_mapRc(rc, 'supportsCoin'));
  }

  @override
  BuResult<bool> isAirgap({required int device}) {
    final rc = _b.hwIsAirgap(device);
    if (rc == 1) {
      return BuResult.ok(true);
    }
    if (rc == 0) {
      return BuResult.ok(false);
    }
    return BuResult.err(_mapRc(rc, 'isAirgap'));
  }

  @override
  BuResult<BuBytes> parsePath(String path) {
    final out = BuBytes.zero(4 * (path.length + 1));
    final rc = _b.hwParsePath(path, out);
    return _take(rc, out);
  }

  @override
  BuResult<void> validatePath({
    required int device,
    required int coin,
    required BuBytes pathU32,
  }) {
    final rc = _b.hwValidatePath(device, coin, pathU32);
    if (rc == 0) {
      return BuResult.ok(null);
    }
    return BuResult.err(_mapRc(rc, 'validatePath'));
  }

  @override
  BuResult<BuBytes> getAddressRequest({
    required int device,
    required int coin,
    required BuBytes pathU32,
  }) {
    final out = BuBytes.zero(2048);
    final rc = _b.hwGetAddressRequest(device, coin, pathU32, out);
    return _take(rc, out);
  }

  @override
  BuResult<BuBytes> parseAddressResponse({
    required int device,
    required BuBytes response,
  }) {
    final out = BuBytes.zero(response.length + 16);
    final rc = _b.hwParseAddressResponse(device, response, out);
    return _take(rc, out);
  }

  @override
  BuResult<BuBytes> ledgerFingerprint() {
    final out = BuBytes.zero(16);
    final rc = _b.hwLedgerFingerprint(out);
    return _take(rc, out);
  }

  @override
  BuResult<BuBytes> ledgerFingerprintParse({required BuBytes response}) {
    final out = BuBytes.zero(16);
    final rc = _b.hwLedgerFingerprintParse(response, out);
    return _take(rc, out);
  }

  @override
  BuResult<BuBytes> signRequest({
    required int device,
    required int coin,
    required BuBytes pathU32,
    required BuBytes payload,
  }) {
    final out = BuBytes.zero(2048);
    final rc = _b.hwSignRequest(device, coin, pathU32, payload, out);
    return _take(rc, out);
  }

  @override
  BuResult<BuBytes> parseSignResponse({
    required int device,
    required BuBytes response,
  }) {
    final out = BuBytes.zero(response.length + 16);
    final rc = _b.hwParseSignResponse(device, response, out);
    return _take(rc, out);
  }

  @override
  BuResult<String> qrRequest({
    required int device,
    required int coin,
    required BuBytes pathU32,
  }) {
    final out = BuBytes.zero(256);
    final rc = _b.hwQrRequest(device, coin, pathU32, out);
    if (rc < 0 || rc == 6) {
      return BuResult.err(_mapRc(rc, 'qrRequest'));
    }
    return BuResult.ok(String.fromCharCodes(out.sublist(0, rc)));
  }

  @override
  BuResult<BuBytes> qrParse({required int device, required String qr}) {
    final out = BuBytes.zero(qr.length);
    final rc = _b.hwQrParse(device, qr, out);
    return _take(rc, out);
  }

  @override
  BuResult<(int, int)> psbtCounts({required BuBytes psbt}) {
    final out = BuBytes.zero(8);
    final rc = _b.hwPsbtCounts(psbt, out);
    if (rc != 0) {
      return BuResult.err(_mapRc(rc, 'psbtCounts'));
    }
    final n = leBytesToU32s(out);
    return BuResult.ok((n[0], n[1]));
  }

  @override
  BuResult<String> urEncode({required String type, required BuBytes payload}) {
    final out = BuBytes.zero(type.length + 16 + (payload.length * 8) ~/ 5);
    final rc = _b.hwUrEncode(type, payload, out);
    if (rc < 0 || rc == 6) {
      return BuResult.err(_mapRc(rc, 'urEncode'));
    }
    return BuResult.ok(String.fromCharCodes(out.sublist(0, rc)));
  }

  @override
  BuResult<BuBytes> urDecodePayload(String ur) {
    final out = BuBytes.zero(ur.length);
    final rc = _b.hwUrDecodePayload(ur, out);
    return _take(rc, out);
  }

  @override
  BuResult<String> urDecodeType(String ur) {
    final out = BuBytes.zero(ur.length);
    final rc = _b.hwUrDecodeType(ur, out);
    if (rc < 0 || rc == 6) {
      return BuResult.err(_mapRc(rc, 'urDecodeType'));
    }
    return BuResult.ok(String.fromCharCodes(out.sublist(0, rc)));
  }

  @override
  BuResult<BuBytes> hidFrame({
    required BuBytes payload,
    int channel = BuHwHid.channelDefault,
    int tag = BuHwHid.tagApdu,
  }) {
    final out = BuBytes.zero(BuHwHid.frameCap(payload.length));
    final rc = _b.hwHidFrame(payload, channel, tag, out);
    return _take(rc, out);
  }

  @override
  BuResult<BuBytes> hidUnframe({
    required BuBytes reports,
    int channel = BuHwHid.channelDefault,
    int tag = BuHwHid.tagApdu,
  }) {
    if (reports.length % BuHwHid.reportLen != 0) {
      return BuResult.err(
        BuError.length(what: 'reports', expected: 0, actual: reports.length),
      );
    }
    final out = BuBytes.zero(reports.length);
    final rc = _b.hwHidUnframe(reports, channel, tag, out);
    return _take(rc, out);
  }

  @override
  Future<BuResult<BuBytes>> executeGetAddress({
    required int device,
    required int coin,
    required BuBytes pathU32,
    required BuHwTransport transport,
  }) async {
    final req = getAddressRequest(device: device, coin: coin, pathU32: pathU32);
    if (req.isErr) {
      return BuResult.err(req.error!);
    }
    final BuBytes resp;
    try {
      resp = await transport.exchange(req.value!);
    } on BuError catch (e) {
      return BuResult.err(e);
    } catch (e) {
      return BuResult.err(
        BuError(
          DefaultErrorType.internal,
          '$_tag.executeGetAddress: transport threw $e',
        ),
      );
    }
    return parseAddressResponse(device: device, response: resp);
  }

  @override
  Future<BuResult<BuBytes>> executeSign({
    required int device,
    required int coin,
    required BuBytes pathU32,
    required BuBytes payload,
    required BuHwTransport transport,
  }) async {
    final req = signRequest(
      device: device,
      coin: coin,
      pathU32: pathU32,
      payload: payload,
    );
    if (req.isErr) {
      return BuResult.err(req.error!);
    }
    final BuBytes resp;
    try {
      resp = await transport.exchange(req.value!);
    } on BuError catch (e) {
      return BuResult.err(e);
    } catch (e) {
      return BuResult.err(
        BuError(
          DefaultErrorType.internal,
          '$_tag.executeSign: transport threw $e',
        ),
      );
    }
    return parseSignResponse(device: device, response: resp);
  }

  @override
  BuResult<BuBytes> signTxStart({
    required int device,
    required int coin,
    required int inputsCount,
    required int outputsCount,
  }) {
    final out = BuBytes.zero(512);
    final rc = _b.hwSignTxStart(device, coin, inputsCount, outputsCount, out);
    return _take(rc, out);
  }

  @override
  BuResult<(int, int)> parseTxRequest({
    required int device,
    required BuBytes response,
  }) {
    final out = BuBytes.zero(8);
    final rc = _b.hwParseTxRequest(device, response, out);
    if (rc != 8) {
      return BuResult.err(_mapRc(rc, 'parseTxRequest'));
    }
    final type = out[0] | (out[1] << 8) | (out[2] << 16) | (out[3] << 24);
    final index = out[4] | (out[5] << 8) | (out[6] << 16) | (out[7] << 24);
    return BuResult.ok((type, index == 0xFFFFFFFF ? -1 : index));
  }

  @override
  BuResult<BuBytes> txRequestSignature({
    required int device,
    required BuBytes response,
  }) {
    final out = BuBytes.zero(response.length + 16);
    final rc = _b.hwTxRequestSignature(device, response, out);
    return _take(rc, out);
  }

  @override
  BuResult<BuBytes> txRequestSerialized({
    required int device,
    required BuBytes response,
  }) {
    final out = BuBytes.zero(response.length + 16);
    final rc = _b.hwTxRequestSerialized(device, response, out);
    return _take(rc, out);
  }

  @override
  BuResult<BuBytes> txRequestTxHash({
    required int device,
    required BuBytes response,
  }) {
    final out = BuBytes.zero(64);
    final rc = _b.hwTxRequestTxHash(device, response, out);
    return _take(rc, out);
  }

  @override
  BuResult<BuBytes> txAckMeta({
    required int version,
    required int lockTime,
    required int inputsCount,
    required int outputsCount,
  }) {
    final out = BuBytes.zero(512);
    final rc = _b.hwTxAckMeta(
      version,
      lockTime,
      inputsCount,
      outputsCount,
      out,
    );
    return _take(rc, out);
  }

  @override
  BuResult<BuBytes> txAckInput({
    required BuBytes prevHash32,
    required int prevIndex,
    required BuBytes pathU32,
    required int amountSat,
    required BuBytes scriptSig,
    required int scriptType,
  }) {
    if (amountSat < 0) {
      return BuResult.err(
        BuError(
          DefaultErrorType.invalidArgument,
          'hw.txAckInput: negative amount',
        ),
      );
    }
    final out = BuBytes.zero(2048);
    final rc = _b.hwTxAckInput(
      prevHash32,
      prevIndex,
      pathU32,
      amountSat,
      scriptSig,
      scriptType,
      out,
    );
    return _take(rc, out);
  }

  BuResult<BuBytes> _txAckAmount(
    String op,
    int amountSat,
    int Function(BuBytes) call,
  ) {
    if (amountSat < 0) {
      return BuResult.err(
        BuError(DefaultErrorType.invalidArgument, 'hw.$op: negative amount'),
      );
    }
    final out = BuBytes.zero(2048);
    return _take(call(out), out);
  }

  @override
  BuResult<BuBytes> txAckOutput({
    required String address,
    required int amountSat,
    required int scriptType,
  }) {
    return _txAckAmount(
      'txAckOutput',
      amountSat,
      (out) => _b.hwTxAckOutput(address, amountSat, scriptType, out),
    );
  }

  @override
  BuResult<BuBytes> txAckChange({
    required BuBytes pathU32,
    required int amountSat,
    required int scriptType,
  }) {
    return _txAckAmount(
      'txAckChange',
      amountSat,
      (out) => _b.hwTxAckChange(pathU32, amountSat, scriptType, out),
    );
  }

  @override
  BuResult<BuBytes> txAckBinOutput({
    required BuBytes scriptPubKey,
    required int amountSat,
  }) {
    return _txAckAmount(
      'txAckBinOutput',
      amountSat,
      (out) => _b.hwTxAckBinOutput(scriptPubKey, amountSat, out),
    );
  }

  @override
  BuResult<void> bitboxHsNew({
    required BuBytes staticPriv32,
    required BuBytes ephemeralPriv32,
  }) {
    // Native returns the slot handle (1) on success; any other value
    // (including positive guard codes like 3) is an error.
    final rc = _b.hwBitBoxHsNew(staticPriv32, ephemeralPriv32);
    if (rc != 1) {
      return BuResult.err(_mapRc(rc, 'bitboxHsNew'));
    }
    return BuResult.ok(null);
  }

  @override
  BuResult<BuBytes> bitboxHsM1() {
    final out = BuBytes.zero(64);
    final rc = _b.hwBitBoxHsM1(out);
    return _take(rc, out);
  }

  @override
  BuResult<void> bitboxHsM2({required BuBytes m2}) {
    final rc = _b.hwBitBoxHsM2(m2);
    if (rc != 0) {
      return BuResult.err(_mapRc(rc, 'bitboxHsM2'));
    }
    return BuResult.ok(null);
  }

  @override
  BuResult<BuBytes> bitboxHsM3() {
    final out = BuBytes.zero(128);
    final rc = _b.hwBitBoxHsM3(out);
    return _take(rc, out);
  }

  @override
  BuResult<void> bitboxHsSplit() {
    final rc = _b.hwBitBoxHsSplit();
    if (rc != 0) {
      return BuResult.err(_mapRc(rc, 'bitboxHsSplit'));
    }
    return BuResult.ok(null);
  }

  @override
  BuResult<BuBytes> bitboxEncrypt({required BuBytes plaintext}) {
    final out = BuBytes.zero(plaintext.length + 32);
    final rc = _b.hwBitBoxEncrypt(plaintext, out);
    return _take(rc, out);
  }

  @override
  BuResult<BuBytes> bitboxDecrypt({required BuBytes ciphertext}) {
    final out = BuBytes.zero(ciphertext.length);
    final rc = _b.hwBitBoxDecrypt(ciphertext, out);
    return _take(rc, out);
  }

  @override
  BuResult<BuBytes> bitboxHsHash() {
    final out = BuBytes.zero(32);
    final rc = _b.hwBitBoxHsHash(out);
    return _take(rc, out);
  }

  @override
  BuResult<void> bitboxFree() {
    final rc = _b.hwBitBoxFree();
    if (rc != 0) {
      return BuResult.err(_mapRc(rc, 'bitboxFree'));
    }
    return BuResult.ok(null);
  }

  @override
  BuResult<BuBytes> bitboxBtcPubRequest({
    required int coin,
    required BuBytes pathU32,
    required int xpubType,
    required bool display,
  }) {
    final out = BuBytes.zero(512);
    final rc = _b.hwBitBoxBtcPubRequest(coin, pathU32, xpubType, display, out);
    return _take(rc, out);
  }

  @override
  BuResult<String> bitboxPubParse({required BuBytes response}) {
    final out = BuBytes.zero(response.length + 16);
    final rc = _b.hwBitBoxPubParse(response, out);
    if (rc < 0 || rc == 6) {
      return BuResult.err(_mapRc(rc, 'bitboxPubParse'));
    }
    return BuResult.ok(String.fromCharCodes(out.sublist(0, rc)));
  }

  @override
  BuResult<BuBytes> bitboxSignInit({
    required int coin,
    required BuBytes pathU32,
    required int simpleType,
    required int version,
    required int inputsCount,
    required int outputsCount,
    required int locktime,
  }) {
    final out = BuBytes.zero(512);
    final rc = _b.hwBitBoxSignInit(
      coin,
      pathU32,
      simpleType,
      version,
      inputsCount,
      outputsCount,
      locktime,
      out,
    );
    return _take(rc, out);
  }

  @override
  BuResult<(int, int)> bitboxSignNextParse({required BuBytes response}) {
    final out = BuBytes.zero(8);
    final rc = _b.hwBitBoxSignNextParse(response, out);
    if (rc != 8) {
      return BuResult.err(_mapRc(rc, 'bitboxSignNextParse'));
    }
    final type = out[0] | (out[1] << 8) | (out[2] << 16) | (out[3] << 24);
    final index = out[4] | (out[5] << 8) | (out[6] << 16) | (out[7] << 24);
    return BuResult.ok((type, index == 0xFFFFFFFF ? -1 : index));
  }

  @override
  BuResult<BuBytes> bitboxSignNextSignature({required BuBytes response}) {
    final out = BuBytes.zero(response.length + 16);
    final rc = _b.hwBitBoxSignNextSignature(response, out);
    return _take(rc, out);
  }

  @override
  BuResult<int> bitboxSignNextPrevIndex({required BuBytes response}) {
    final rc = _b.hwBitBoxSignNextPrevIndex(response);
    if (rc < 0) {
      return BuResult.err(_mapRc(rc, 'bitboxSignNextPrevIndex'));
    }
    return BuResult.ok(rc == 0xFFFFFFFF ? -1 : rc);
  }

  @override
  BuResult<BuBytes> bitboxSignInput({
    required BuBytes prevHash32,
    required int prevIndex,
    required int amountSat,
    required int sequence,
    required BuBytes pathU32,
    required int scriptConfigIndex,
  }) {
    if (amountSat < 0) {
      return BuResult.err(
        BuError(
          DefaultErrorType.invalidArgument,
          'hw.bitboxSignInput: negative amount',
        ),
      );
    }
    final out = BuBytes.zero(2048);
    final rc = _b.hwBitBoxSignInput(
      prevHash32,
      prevIndex,
      amountSat,
      sequence,
      pathU32,
      scriptConfigIndex,
      out,
    );
    return _take(rc, out);
  }

  @override
  BuResult<BuBytes> bitboxSignOutput({
    required int outputType,
    required int amountSat,
    required BuBytes payload,
  }) {
    if (amountSat < 0) {
      return BuResult.err(
        BuError(
          DefaultErrorType.invalidArgument,
          'hw.bitboxSignOutput: negative amount',
        ),
      );
    }
    final out = BuBytes.zero(2048);
    final rc = _b.hwBitBoxSignOutput(outputType, amountSat, payload, out);
    return _take(rc, out);
  }

  @override
  BuResult<BuBytes> bitboxSignChange({
    required BuBytes pathU32,
    required int amountSat,
    required int scriptConfigIndex,
  }) {
    if (amountSat < 0) {
      return BuResult.err(
        BuError(
          DefaultErrorType.invalidArgument,
          'hw.bitboxSignChange: negative amount',
        ),
      );
    }
    final out = BuBytes.zero(2048);
    final rc = _b.hwBitBoxSignChange(
      pathU32,
      amountSat,
      scriptConfigIndex,
      out,
    );
    return _take(rc, out);
  }

  @override
  BuResult<BuBytes> bitboxSignPrevtxInit({
    required int version,
    required int inputsCount,
    required int outputsCount,
    required int locktime,
  }) {
    final out = BuBytes.zero(64);
    final rc = _b.hwBitBoxSignPrevtxInit(
      version,
      inputsCount,
      outputsCount,
      locktime,
      out,
    );
    return _take(rc, out);
  }

  @override
  BuResult<BuBytes> bitboxSignPrevtxInput({
    required BuBytes prevHash32,
    required int prevIndex,
    required BuBytes scriptSig,
    required int sequence,
  }) {
    final out = BuBytes.zero(2048);
    final rc = _b.hwBitBoxSignPrevtxInput(
      prevHash32,
      prevIndex,
      scriptSig,
      sequence,
      out,
    );
    return _take(rc, out);
  }

  @override
  BuResult<BuBytes> bitboxSignPrevtxOutput({
    required int amountSat,
    required BuBytes script,
  }) {
    if (amountSat < 0) {
      return BuResult.err(
        BuError(
          DefaultErrorType.invalidArgument,
          'hw.bitboxSignPrevtxOutput: negative amount',
        ),
      );
    }
    final out = BuBytes.zero(2048);
    final rc = _b.hwBitBoxSignPrevtxOutput(amountSat, script, out);
    return _take(rc, out);
  }

  @override
  BuResult<BuBytes> identityEncode({
    required String proto,
    String user = '',
    String host = '',
    String port = '',
    String path = '',
    int index = 0,
  }) {
    final out = BuBytes.zero(1536);
    final rc = _b.hwIdentityEncode(
      _utf8(proto),
      _utf8(user),
      _utf8(host),
      _utf8(port),
      _utf8(path),
      index,
      out,
    );
    return _take(rc, out);
  }

  @override
  BuResult<BuBytes> signIdentityRequest({
    required BuBytes identity,
    required BuBytes hidden,
    String visual = '',
    int curve = 0,
  }) {
    final out = BuBytes.zero(2048);
    final rc = _b.hwSignIdentityRequest(
      identity,
      hidden,
      _utf8(visual),
      curve,
      out,
    );
    return _take(rc, out);
  }

  @override
  BuResult<String> signedIdentityAddress({required BuBytes response}) {
    final out = BuBytes.zero(256);
    final rc = _b.hwSignedIdentityAddress(response, out);
    if (rc < 0 || rc == 6) {
      return BuResult.err(_mapRc(rc, 'signedIdentityAddress'));
    }
    return BuResult.ok(String.fromCharCodes(out.sublist(0, rc)));
  }

  @override
  BuResult<BuBytes> signedIdentityPubkey({required BuBytes response}) {
    final out = BuBytes.zero(128);
    final rc = _b.hwSignedIdentityPubkey(response, out);
    return _take(rc, out);
  }

  @override
  BuResult<BuBytes> signedIdentitySignature({required BuBytes response}) {
    final out = BuBytes.zero(128);
    final rc = _b.hwSignedIdentitySignature(response, out);
    return _take(rc, out);
  }
}
