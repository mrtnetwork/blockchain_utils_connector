// ignore_for_file: library_private_types_in_public_api
// FFI typedefs are internal (never exported from blockchain_utils_connector.dart).
import 'dart:ffi' as ffi;

/// Native `bu_hw_*` symbols (built with `--features ffi,hw`).
/// Looked up as an optional group — missing symbols mean an older/no-hw
/// native library, surfaced as code 6 (`unsupported`) by the platform layer.
typedef _U32FnN = ffi.Uint32 Function();
typedef _U32FnD = int Function();
typedef _DevCoinN = ffi.Int32 Function(ffi.Uint32, ffi.Uint32);
typedef _DevCoinD = int Function(int, int);
typedef _DevN = ffi.Int32 Function(ffi.Uint32);
typedef _DevD = int Function(int);
typedef _ParsePathN =
    ffi.Int32 Function(
      ffi.Pointer<ffi.Uint8>,
      ffi.Size,
      ffi.Pointer<ffi.Uint8>,
      ffi.Size,
    );
typedef _ParsePathD =
    int Function(ffi.Pointer<ffi.Uint8>, int, ffi.Pointer<ffi.Uint8>, int);
typedef _ValidateN =
    ffi.Int32 Function(
      ffi.Uint32,
      ffi.Uint32,
      ffi.Pointer<ffi.Uint8>,
      ffi.Size,
    );
typedef _ValidateD = int Function(int, int, ffi.Pointer<ffi.Uint8>, int);
typedef _ReqN =
    ffi.Int32 Function(
      ffi.Uint32,
      ffi.Uint32,
      ffi.Pointer<ffi.Uint8>,
      ffi.Size,
      ffi.Pointer<ffi.Uint8>,
      ffi.Size,
    );
typedef _ReqD =
    int Function(
      int,
      int,
      ffi.Pointer<ffi.Uint8>,
      int,
      ffi.Pointer<ffi.Uint8>,
      int,
    );
typedef _RespN =
    ffi.Int32 Function(
      ffi.Uint32,
      ffi.Pointer<ffi.Uint8>,
      ffi.Size,
      ffi.Pointer<ffi.Uint8>,
      ffi.Size,
    );
typedef _RespD =
    int Function(int, ffi.Pointer<ffi.Uint8>, int, ffi.Pointer<ffi.Uint8>, int);
typedef _SignReqN =
    ffi.Int32 Function(
      ffi.Uint32,
      ffi.Uint32,
      ffi.Pointer<ffi.Uint8>,
      ffi.Size,
      ffi.Pointer<ffi.Uint8>,
      ffi.Size,
      ffi.Pointer<ffi.Uint8>,
      ffi.Size,
    );
typedef _SignReqD =
    int Function(
      int,
      int,
      ffi.Pointer<ffi.Uint8>,
      int,
      ffi.Pointer<ffi.Uint8>,
      int,
      ffi.Pointer<ffi.Uint8>,
      int,
    );
typedef _QrParseN =
    ffi.Int32 Function(
      ffi.Uint32,
      ffi.Pointer<ffi.Uint8>,
      ffi.Size,
      ffi.Pointer<ffi.Uint8>,
      ffi.Size,
    );
typedef _QrParseD =
    int Function(int, ffi.Pointer<ffi.Uint8>, int, ffi.Pointer<ffi.Uint8>, int);
typedef _PsbtN =
    ffi.Int32 Function(
      ffi.Pointer<ffi.Uint8>,
      ffi.Size,
      ffi.Pointer<ffi.Uint8>,
      ffi.Size,
    );
typedef _PsbtD =
    int Function(ffi.Pointer<ffi.Uint8>, int, ffi.Pointer<ffi.Uint8>, int);
typedef _UrEncN =
    ffi.Int32 Function(
      ffi.Pointer<ffi.Uint8>,
      ffi.Size,
      ffi.Pointer<ffi.Uint8>,
      ffi.Size,
      ffi.Pointer<ffi.Uint8>,
      ffi.Size,
    );
typedef _UrEncD =
    int Function(
      ffi.Pointer<ffi.Uint8>,
      int,
      ffi.Pointer<ffi.Uint8>,
      int,
      ffi.Pointer<ffi.Uint8>,
      int,
    );
typedef _UrDecN =
    ffi.Int32 Function(
      ffi.Pointer<ffi.Uint8>,
      ffi.Size,
      ffi.Pointer<ffi.Uint8>,
      ffi.Size,
    );
typedef _UrDecD =
    int Function(ffi.Pointer<ffi.Uint8>, int, ffi.Pointer<ffi.Uint8>, int);
typedef _HidN =
    ffi.Int32 Function(
      ffi.Pointer<ffi.Uint8>,
      ffi.Size,
      ffi.Uint32,
      ffi.Uint32,
      ffi.Pointer<ffi.Uint8>,
      ffi.Size,
    );
typedef _HidD =
    int Function(
      ffi.Pointer<ffi.Uint8>,
      int,
      int,
      int,
      ffi.Pointer<ffi.Uint8>,
      int,
    );
typedef _SignTxStartN =
    ffi.Int32 Function(
      ffi.Uint32,
      ffi.Uint32,
      ffi.Uint32,
      ffi.Uint32,
      ffi.Pointer<ffi.Uint8>,
      ffi.Size,
    );
typedef _SignTxStartD =
    int Function(int, int, int, int, ffi.Pointer<ffi.Uint8>, int);
typedef _AckMetaN =
    ffi.Int32 Function(
      ffi.Uint32,
      ffi.Uint32,
      ffi.Uint32,
      ffi.Uint32,
      ffi.Pointer<ffi.Uint8>,
      ffi.Size,
    );
typedef _AckMetaD =
    int Function(int, int, int, int, ffi.Pointer<ffi.Uint8>, int);
typedef _AckInputN =
    ffi.Int32 Function(
      ffi.Pointer<ffi.Uint8>,
      ffi.Size,
      ffi.Uint32,
      ffi.Pointer<ffi.Uint8>,
      ffi.Size,
      ffi.Uint64,
      ffi.Pointer<ffi.Uint8>,
      ffi.Size,
      ffi.Uint32,
      ffi.Pointer<ffi.Uint8>,
      ffi.Size,
    );
typedef _AckInputD =
    int Function(
      ffi.Pointer<ffi.Uint8>,
      int,
      int,
      ffi.Pointer<ffi.Uint8>,
      int,
      int,
      ffi.Pointer<ffi.Uint8>,
      int,
      int,
      ffi.Pointer<ffi.Uint8>,
      int,
    );
typedef _AckAmountN =
    ffi.Int32 Function(
      ffi.Pointer<ffi.Uint8>,
      ffi.Size,
      ffi.Uint64,
      ffi.Pointer<ffi.Uint8>,
      ffi.Size,
    );
typedef _AckAmountD =
    int Function(ffi.Pointer<ffi.Uint8>, int, int, ffi.Pointer<ffi.Uint8>, int);
typedef _TxAckOutN =
    ffi.Int32 Function(
      ffi.Pointer<ffi.Uint8>,
      ffi.Size,
      ffi.Uint64,
      ffi.Uint32,
      ffi.Pointer<ffi.Uint8>,
      ffi.Size,
    );
typedef _TxAckOutD =
    int Function(
      ffi.Pointer<ffi.Uint8>,
      int,
      int,
      int,
      ffi.Pointer<ffi.Uint8>,
      int,
    );
typedef _TxAckChangeN =
    ffi.Int32 Function(
      ffi.Pointer<ffi.Uint8>,
      ffi.Size,
      ffi.Uint64,
      ffi.Uint32,
      ffi.Pointer<ffi.Uint8>,
      ffi.Size,
    );
typedef _TxAckChangeD =
    int Function(
      ffi.Pointer<ffi.Uint8>,
      int,
      int,
      int,
      ffi.Pointer<ffi.Uint8>,
      int,
    );
typedef _BbChangeN =
    ffi.Int32 Function(
      ffi.Pointer<ffi.Uint8>,
      ffi.Size,
      ffi.Uint64,
      ffi.Uint32,
      ffi.Pointer<ffi.Uint8>,
      ffi.Size,
    );
typedef _BbChangeD =
    int Function(
      ffi.Pointer<ffi.Uint8>,
      int,
      int,
      int,
      ffi.Pointer<ffi.Uint8>,
      int,
    );
typedef _KeysNewN =
    ffi.Int32 Function(
      ffi.Pointer<ffi.Uint8>,
      ffi.Size,
      ffi.Pointer<ffi.Uint8>,
      ffi.Size,
    );
typedef _KeysNewD =
    int Function(ffi.Pointer<ffi.Uint8>, int, ffi.Pointer<ffi.Uint8>, int);
typedef _OutN = ffi.Int32 Function(ffi.Pointer<ffi.Uint8>, ffi.Size);
typedef _OutD = int Function(ffi.Pointer<ffi.Uint8>, int);
typedef _InN = ffi.Int32 Function(ffi.Pointer<ffi.Uint8>, ffi.Size);
typedef _InD = int Function(ffi.Pointer<ffi.Uint8>, int);
typedef _ZeroN = ffi.Int32 Function();
typedef _ZeroD = int Function();
typedef _MsgN =
    ffi.Int32 Function(
      ffi.Pointer<ffi.Uint8>,
      ffi.Size,
      ffi.Pointer<ffi.Uint8>,
      ffi.Size,
    );
typedef _MsgD =
    int Function(ffi.Pointer<ffi.Uint8>, int, ffi.Pointer<ffi.Uint8>, int);
typedef _BtcPubReqN =
    ffi.Int32 Function(
      ffi.Uint32,
      ffi.Pointer<ffi.Uint8>,
      ffi.Size,
      ffi.Uint32,
      ffi.Uint32,
      ffi.Pointer<ffi.Uint8>,
      ffi.Size,
    );
typedef _BtcPubReqD =
    int Function(
      int,
      ffi.Pointer<ffi.Uint8>,
      int,
      int,
      int,
      ffi.Pointer<ffi.Uint8>,
      int,
    );
typedef _SignInitN =
    ffi.Int32 Function(
      ffi.Uint32,
      ffi.Pointer<ffi.Uint8>,
      ffi.Size,
      ffi.Uint32,
      ffi.Uint32,
      ffi.Uint32,
      ffi.Uint32,
      ffi.Uint32,
      ffi.Pointer<ffi.Uint8>,
      ffi.Size,
    );
typedef _SignInitD =
    int Function(
      int,
      ffi.Pointer<ffi.Uint8>,
      int,
      int,
      int,
      int,
      int,
      int,
      ffi.Pointer<ffi.Uint8>,
      int,
    );
typedef _SignInN =
    ffi.Int32 Function(
      ffi.Pointer<ffi.Uint8>,
      ffi.Size,
      ffi.Uint32,
      ffi.Uint64,
      ffi.Uint32,
      ffi.Pointer<ffi.Uint8>,
      ffi.Size,
      ffi.Uint32,
      ffi.Pointer<ffi.Uint8>,
      ffi.Size,
    );
typedef _SignInD =
    int Function(
      ffi.Pointer<ffi.Uint8>,
      int,
      int,
      int,
      int,
      ffi.Pointer<ffi.Uint8>,
      int,
      int,
      ffi.Pointer<ffi.Uint8>,
      int,
    );
typedef _BbParseN = ffi.Int64 Function(ffi.Pointer<ffi.Uint8>, ffi.Size);
typedef _BbParseD = int Function(ffi.Pointer<ffi.Uint8>, int);
typedef _BbOutN =
    ffi.Int32 Function(
      ffi.Uint32,
      ffi.Uint64,
      ffi.Pointer<ffi.Uint8>,
      ffi.Size,
      ffi.Pointer<ffi.Uint8>,
      ffi.Size,
    );
typedef _BbOutD =
    int Function(
      int,
      int,
      ffi.Pointer<ffi.Uint8>,
      int,
      ffi.Pointer<ffi.Uint8>,
      int,
    );
typedef _BbPrevInitN =
    ffi.Int32 Function(
      ffi.Uint32,
      ffi.Uint32,
      ffi.Uint32,
      ffi.Uint32,
      ffi.Pointer<ffi.Uint8>,
      ffi.Size,
    );
typedef _BbPrevInitD =
    int Function(int, int, int, int, ffi.Pointer<ffi.Uint8>, int);
typedef _BbPrevInN =
    ffi.Int32 Function(
      ffi.Pointer<ffi.Uint8>,
      ffi.Size,
      ffi.Uint32,
      ffi.Pointer<ffi.Uint8>,
      ffi.Size,
      ffi.Uint32,
      ffi.Pointer<ffi.Uint8>,
      ffi.Size,
    );
typedef _BbPrevInD =
    int Function(
      ffi.Pointer<ffi.Uint8>,
      int,
      int,
      ffi.Pointer<ffi.Uint8>,
      int,
      int,
      ffi.Pointer<ffi.Uint8>,
      int,
    );
typedef _BbPrevOutN =
    ffi.Int32 Function(
      ffi.Uint64,
      ffi.Pointer<ffi.Uint8>,
      ffi.Size,
      ffi.Pointer<ffi.Uint8>,
      ffi.Size,
    );
typedef _BbPrevOutD =
    int Function(int, ffi.Pointer<ffi.Uint8>, int, ffi.Pointer<ffi.Uint8>, int);
typedef _IdEncodeN =
    ffi.Int32 Function(
      ffi.Pointer<ffi.Uint8>,
      ffi.Size,
      ffi.Pointer<ffi.Uint8>,
      ffi.Size,
      ffi.Pointer<ffi.Uint8>,
      ffi.Size,
      ffi.Pointer<ffi.Uint8>,
      ffi.Size,
      ffi.Pointer<ffi.Uint8>,
      ffi.Size,
      ffi.Uint32,
      ffi.Pointer<ffi.Uint8>,
      ffi.Size,
    );
typedef _IdEncodeD =
    int Function(
      ffi.Pointer<ffi.Uint8>,
      int,
      ffi.Pointer<ffi.Uint8>,
      int,
      ffi.Pointer<ffi.Uint8>,
      int,
      ffi.Pointer<ffi.Uint8>,
      int,
      ffi.Pointer<ffi.Uint8>,
      int,
      int,
      ffi.Pointer<ffi.Uint8>,
      int,
    );
typedef _IdReqN =
    ffi.Int32 Function(
      ffi.Pointer<ffi.Uint8>,
      ffi.Size,
      ffi.Pointer<ffi.Uint8>,
      ffi.Size,
      ffi.Pointer<ffi.Uint8>,
      ffi.Size,
      ffi.Uint32,
      ffi.Pointer<ffi.Uint8>,
      ffi.Size,
    );
typedef _IdReqD =
    int Function(
      ffi.Pointer<ffi.Uint8>,
      int,
      ffi.Pointer<ffi.Uint8>,
      int,
      ffi.Pointer<ffi.Uint8>,
      int,
      int,
      ffi.Pointer<ffi.Uint8>,
      int,
    );

class BuHwFfi {
  BuHwFfi(ffi.DynamicLibrary lib)
    : deviceCount = lib.lookupFunction<_U32FnN, _U32FnD>('bu_hw_device_count'),
      coinCount = lib.lookupFunction<_U32FnN, _U32FnD>('bu_hw_coin_count'),
      supportsCoin = lib.lookupFunction<_DevCoinN, _DevCoinD>(
        'bu_hw_supports_coin',
      ),
      isAirgap = lib.lookupFunction<_DevN, _DevD>('bu_hw_is_airgap'),
      parsePath = lib.lookupFunction<_ParsePathN, _ParsePathD>(
        'bu_hw_parse_path',
      ),
      validatePath = lib.lookupFunction<_ValidateN, _ValidateD>(
        'bu_hw_validate_path',
      ),
      getAddressRequest = lib.lookupFunction<_ReqN, _ReqD>(
        'bu_hw_get_address_request',
      ),
      parseAddressResponse = lib.lookupFunction<_RespN, _RespD>(
        'bu_hw_parse_address_response',
      ),
      signRequest = lib.lookupFunction<_SignReqN, _SignReqD>(
        'bu_hw_sign_request',
      ),
      parseSignResponse = lib.lookupFunction<_RespN, _RespD>(
        'bu_hw_parse_sign_response',
      ),
      qrRequest = lib.lookupFunction<_ReqN, _ReqD>('bu_hw_qr_request'),
      qrParse = lib.lookupFunction<_QrParseN, _QrParseD>('bu_hw_qr_parse'),
      psbtCounts = lib.lookupFunction<_PsbtN, _PsbtD>('bu_hw_psbt_counts'),
      urEncode = lib.lookupFunction<_UrEncN, _UrEncD>('bu_hw_ur_encode'),
      urDecodePayload = lib.lookupFunction<_UrDecN, _UrDecD>(
        'bu_hw_ur_decode_payload',
      ),
      urDecodeType = lib.lookupFunction<_UrDecN, _UrDecD>(
        'bu_hw_ur_decode_type',
      ),
      hidFrame = lib.lookupFunction<_HidN, _HidD>('bu_hw_hid_frame'),
      hidUnframe = lib.lookupFunction<_HidN, _HidD>('bu_hw_hid_unframe'),
      signTxStart = lib.lookupFunction<_SignTxStartN, _SignTxStartD>(
        'bu_hw_sign_tx_start',
      ),
      parseTxRequest = lib.lookupFunction<_RespN, _RespD>(
        'bu_hw_parse_tx_request',
      ),
      txRequestSignature = lib.lookupFunction<_RespN, _RespD>(
        'bu_hw_tx_request_signature',
      ),
      txRequestSerialized = lib.lookupFunction<_RespN, _RespD>(
        'bu_hw_tx_request_serialized',
      ),
      txRequestTxHash = lib.lookupFunction<_RespN, _RespD>(
        'bu_hw_tx_request_txhash',
      ),
      txAckMeta = lib.lookupFunction<_AckMetaN, _AckMetaD>('bu_hw_tx_ack_meta'),
      txAckInput = lib.lookupFunction<_AckInputN, _AckInputD>(
        'bu_hw_tx_ack_input',
      ),
      txAckOutput = lib.lookupFunction<_TxAckOutN, _TxAckOutD>(
        'bu_hw_tx_ack_output',
      ),
      txAckChange = lib.lookupFunction<_TxAckChangeN, _TxAckChangeD>(
        'bu_hw_tx_ack_change',
      ),
      txAckBinOutput = lib.lookupFunction<_AckAmountN, _AckAmountD>(
        'bu_hw_tx_ack_bin_output',
      ),
      bitboxHsNew = lib.lookupFunction<_KeysNewN, _KeysNewD>(
        'bu_hw_bitbox_hs_new',
      ),
      bitboxHsM1 = lib.lookupFunction<_OutN, _OutD>('bu_hw_bitbox_hs_m1'),
      bitboxHsM2 = lib.lookupFunction<_InN, _InD>('bu_hw_bitbox_hs_m2'),
      bitboxHsM3 = lib.lookupFunction<_OutN, _OutD>('bu_hw_bitbox_hs_m3'),
      bitboxHsSplit = lib.lookupFunction<_ZeroN, _ZeroD>(
        'bu_hw_bitbox_hs_split',
      ),
      bitboxEncrypt = lib.lookupFunction<_MsgN, _MsgD>('bu_hw_bitbox_encrypt'),
      bitboxDecrypt = lib.lookupFunction<_MsgN, _MsgD>('bu_hw_bitbox_decrypt'),
      bitboxHsHash = lib.lookupFunction<_OutN, _OutD>('bu_hw_bitbox_hs_hash'),
      bitboxFree = lib.lookupFunction<_ZeroN, _ZeroD>('bu_hw_bitbox_free'),
      bitboxBtcPubRequest = lib.lookupFunction<_BtcPubReqN, _BtcPubReqD>(
        'bu_hw_bitbox_btc_pub_request',
      ),
      bitboxPubParse = lib.lookupFunction<_PsbtN, _PsbtD>(
        'bu_hw_bitbox_pub_parse',
      ),
      bitboxSignInit = lib.lookupFunction<_SignInitN, _SignInitD>(
        'bu_hw_bitbox_sign_init',
      ),
      bitboxSignNextParse = lib.lookupFunction<_PsbtN, _PsbtD>(
        'bu_hw_bitbox_sign_next_parse',
      ),
      bitboxSignNextSignature = lib.lookupFunction<_PsbtN, _PsbtD>(
        'bu_hw_bitbox_sign_next_signature',
      ),
      bitboxSignNextPrevIndex = lib.lookupFunction<_BbParseN, _BbParseD>(
        'bu_hw_bitbox_sign_next_prev_index',
      ),
      bitboxSignInput = lib.lookupFunction<_SignInN, _SignInD>(
        'bu_hw_bitbox_sign_input',
      ),
      bitboxSignOutput = lib.lookupFunction<_BbOutN, _BbOutD>(
        'bu_hw_bitbox_sign_output',
      ),
      bitboxSignChange = lib.lookupFunction<_BbChangeN, _BbChangeD>(
        'bu_hw_bitbox_sign_change',
      ),
      bitboxSignPrevtxInit = lib.lookupFunction<_BbPrevInitN, _BbPrevInitD>(
        'bu_hw_bitbox_sign_prevtx_init',
      ),
      bitboxSignPrevtxInput = lib.lookupFunction<_BbPrevInN, _BbPrevInD>(
        'bu_hw_bitbox_sign_prevtx_input',
      ),
      bitboxSignPrevtxOutput = lib.lookupFunction<_BbPrevOutN, _BbPrevOutD>(
        'bu_hw_bitbox_sign_prevtx_output',
      ),
      identityEncode = lib.lookupFunction<_IdEncodeN, _IdEncodeD>(
        'bu_hw_identity_encode',
      ),
      signIdentityRequest = lib.lookupFunction<_IdReqN, _IdReqD>(
        'bu_hw_sign_identity_request',
      ),
      signedIdentityAddress = lib.lookupFunction<_PsbtN, _PsbtD>(
        'bu_hw_signed_identity_address',
      ),
      signedIdentityPubkey = lib.lookupFunction<_PsbtN, _PsbtD>(
        'bu_hw_signed_identity_pubkey',
      ),
      signedIdentitySignature = lib.lookupFunction<_PsbtN, _PsbtD>(
        'bu_hw_signed_identity_signature',
      ),
      ledgerFingerprint = lib.lookupFunction<_OutN, _OutD>(
        'bu_hw_ledger_fingerprint_request',
      ),
      ledgerFingerprintParse = lib.lookupFunction<_PsbtN, _PsbtD>(
        'bu_hw_ledger_fingerprint_parse',
      );

  final _U32FnD deviceCount;
  final _U32FnD coinCount;
  final _DevCoinD supportsCoin;
  final _DevD isAirgap;
  final _ParsePathD parsePath;
  final _ValidateD validatePath;
  final _ReqD getAddressRequest;
  final _RespD parseAddressResponse;
  final _SignReqD signRequest;
  final _RespD parseSignResponse;
  final _ReqD qrRequest;
  final _QrParseD qrParse;
  final _PsbtD psbtCounts;
  final _UrEncD urEncode;
  final _UrDecD urDecodePayload;
  final _UrDecD urDecodeType;
  final _HidD hidFrame;
  final _HidD hidUnframe;
  final _SignTxStartD signTxStart;
  final _RespD parseTxRequest;
  final _RespD txRequestSignature;
  final _RespD txRequestSerialized;
  final _RespD txRequestTxHash;
  final _AckMetaD txAckMeta;
  final _AckInputD txAckInput;
  final _TxAckOutD txAckOutput;
  final _TxAckChangeD txAckChange;
  final _AckAmountD txAckBinOutput;
  final _KeysNewD bitboxHsNew;
  final _OutD bitboxHsM1;
  final _InD bitboxHsM2;
  final _OutD bitboxHsM3;
  final _ZeroD bitboxHsSplit;
  final _MsgD bitboxEncrypt;
  final _MsgD bitboxDecrypt;
  final _OutD bitboxHsHash;
  final _ZeroD bitboxFree;
  final _BtcPubReqD bitboxBtcPubRequest;
  final _PsbtD bitboxPubParse;
  final _SignInitD bitboxSignInit;
  final _PsbtD bitboxSignNextParse;
  final _PsbtD bitboxSignNextSignature;
  final _BbParseD bitboxSignNextPrevIndex;
  final _SignInD bitboxSignInput;
  final _BbOutD bitboxSignOutput;
  final _BbChangeD bitboxSignChange;
  final _BbPrevInitD bitboxSignPrevtxInit;
  final _BbPrevInD bitboxSignPrevtxInput;
  final _BbPrevOutD bitboxSignPrevtxOutput;
  final _IdEncodeD identityEncode;
  final _IdReqD signIdentityRequest;
  final _PsbtD signedIdentityAddress;
  final _PsbtD signedIdentityPubkey;
  final _PsbtD signedIdentitySignature;
  final _OutD ledgerFingerprint;
  final _PsbtD ledgerFingerprintParse;
}
