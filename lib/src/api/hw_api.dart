import 'dart:typed_data';

import 'package:blockchain_utils_connector/src/bytes/bytes.dart';
import 'package:blockchain_utils_connector/src/error/bu_error.dart';

/// Hardware-wallet devices. Ids must match Rust `BU_HW_*` in
/// `connector/ffi/hw.rs` (order of `DeviceKind::ALL`).
abstract final class BuHwDevice {
  static const ledgerNanoSPlus = 0;
  static const ledgerNanoX = 1;
  static const ledgerFlex = 2;
  static const ledgerStax = 3;
  static const trezorOne = 4;
  static const trezorModelT = 5;
  static const trezorSafe3 = 6;
  static const trezorSafe5 = 7;
  static const trezorSafe7 = 8;
  static const keepKey = 9;
  static const oneKey = 10;
  static const bitBox02 = 11;
  static const passport = 12;
  static const keystone3 = 13;
  static const keystonePro = 14;
  static const coldcardQr = 15;
  static const jadeQr = 16;
  static const count = 17;

  static const airgap = <int>{
    passport,
    keystone3,
    keystonePro,
    coldcardQr,
    jadeQr,
  };
}

/// Coins. Ids must match Rust `WELL_KNOWN_COINS` order in `hw/coin.rs`.
abstract final class BuHwCoin {
  static const btc = 0;
  static const btcSegwit = 1;
  static const btcTaproot = 2;
  static const eth = 3;
  static const trx = 4;
  static const xrp = 5;
  static const atom = 6;
  static const filSecp = 7;
  static const xtzTz1 = 8;
  static const xtzTz2 = 9;
  static const xtzTz3 = 10;
  static const sol = 11;
  static const apt = 12;
  static const suiEd = 13;
  static const near = 14;
  static const xlm = 15;
  static const dotSlip = 16;
  static const adaIcarus = 17;
  static const xmrSlip = 18;

  /// Zcash transparent only (t-addrs). Shielded is unsupported on all HW.
  static const zecTransparent = 19;

  /// Bitcoin testnet (SLIP44 1). Appended last — ids are wire-stable.
  static const btcTestnet = 20;
  static const count = 21;
}

/// HID framing constants (must match Rust `hw::hid`).
abstract final class BuHwHid {
  static const reportLen = 64;
  static const channelDefault = 0x0101;
  static const tagApdu = 0x05;

  /// Output capacity for framing [payloadLen] bytes.
  static int frameCap(int payloadLen) {
    if (payloadLen <= 57) {
      return 64;
    }
    return 64 * (1 + ((payloadLen - 57 + 58) ~/ 59));
  }
}

/// One USB device candidate.
class BuHwUsbId {
  const BuHwUsbId(this.vid, this.pid);
  final int vid;
  final int pid;
}

/// A discovered device. [path] is whatever the enumerator uses to reopen it
/// (hidapi path, WebHID device handle id, …). Presence in a listing means
/// "plugged in", not "speaks wallet protocol" — probe to confirm aliveness
/// (open + family status request + short timeout; any failure = skip it).
class BuHwDeviceInfo {
  BuHwDeviceInfo({required this.id, this.path, this.serial, this.product});
  final BuHwUsbId id;
  final String? path;
  final String? serial;
  final String? product;

  /// Family guess from vendor id (`ledger`/`trezor`/`bitbox`), else `null`.
  String? get familyGuess => BuHwKnownVids.familyFor(id.vid);
}

/// Known wallet vendor ids (PIDs vary per model/firmware — match on VID).
abstract final class BuHwKnownVids {
  static const ledger = 0x2C97;
  static const trezorOne = 0x534C;
  static const trezor = 0x1209;
  static const keepKey = 0x2B24;
  static const bitBox = 0x03EB;

  static String? familyFor(int vid) {
    return switch (vid) {
      ledger => 'ledger',
      trezorOne || trezor => 'trezor',
      keepKey => 'trezor',
      bitBox => 'bitbox',
      _ => null,
    };
  }

  static bool isCandidate(int vid) => familyFor(vid) != null;
}

/// Enumerates plugged-in USB candidates. Implemented by the app
/// (`hidapi`/`rusb` native, WebHID on web) — the connector only defines
/// the shape so probing code is portable.
abstract interface class BuHwDiscovery {
  Future<List<BuHwDeviceInfo>> list({
    Duration timeout = const Duration(seconds: 2),
  });
}

/// In-memory discovery for tests and app previews.
class BuStaticHwDiscovery implements BuHwDiscovery {
  BuStaticHwDiscovery(this.devices);
  final List<BuHwDeviceInfo> devices;

  @override
  Future<List<BuHwDeviceInfo>> list({
    Duration timeout = const Duration(seconds: 2),
  }) async {
    return List<BuHwDeviceInfo>.unmodifiable(devices);
  }
}

/// Encode u32 indexes as `<u32 LE>` bytes (native path wire format).
BuBytes u32sToLeBytes(List<int> indexes) {
  final b = ByteData(4 * indexes.length);
  for (var i = 0; i < indexes.length; i++) {
    b.setUint32(4 * i, indexes[i], Endian.little);
  }
  return BuBytes(b.buffer.asUint8List());
}

/// Decode `<u32 LE>` bytes back to indexes.
List<int> leBytesToU32s(List<int> bytes) {
  if (bytes.length % 4 != 0) {
    throw BuError(DefaultErrorType.invalidLength, 'hw.path: not u32 LE bytes');
  }
  final b = ByteData.sublistView(Uint8List.fromList(bytes));
  return List<int>.generate(
    b.lengthInBytes ~/ 4,
    (i) => b.getUint32(4 * i, Endian.little),
  );
}

// ---------------------------------------------------------------------------
// Pure-Dart base32 (lowercase, no padding) — same alphabet as Rust
// `hw::ur::encode_body/decode_body`. Used only by [BuUrAssembler] so QR
// reassembly never needs the native library.
// ---------------------------------------------------------------------------

const _b32Alphabet = 'abcdefghijklmnopqrstuvwxyz234567';

String buBase32EncodeNoPad(List<int> bytes) {
  final sb = StringBuffer();
  var acc = 0;
  var bits = 0;
  for (final byte in bytes) {
    acc = (acc << 8) | (byte & 0xFF);
    bits += 8;
    while (bits >= 5) {
      bits -= 5;
      sb.write(_b32Alphabet[(acc >> bits) & 31]);
    }
  }
  if (bits > 0) sb.write(_b32Alphabet[(acc << (5 - bits)) & 31]);
  return sb.toString();
}

BuBytes buBase32DecodeNoPad(String s) {
  int val(int c) {
    if (c >= 0x61 && c <= 0x7A) return c - 0x61; // a-z
    if (c >= 0x41 && c <= 0x5A) return c - 0x41; // A-Z
    if (c >= 0x32 && c <= 0x37) return c - 0x32 + 26; // 2-7
    throw BuError(DefaultErrorType.invalidArgument, 'hw.ur: bad base32 char');
  }

  final out = <int>[];
  var acc = 0;
  var bits = 0;
  for (final c in s.codeUnits) {
    acc = (acc << 5) | val(c);
    bits += 5;
    if (bits >= 8) {
      bits -= 8;
      out.add((acc >> bits) & 0xFF);
      acc &= (1 << bits) - 1;
    }
  }
  if (bits > 0 && acc != 0) {
    throw BuError(
      DefaultErrorType.invalidArgument,
      'hw.ur: bad base32 padding',
    );
  }
  return BuBytes(out);
}

/// Reassemble animated-QR multipart shards (`ur:type/seq-of-total/body`).
/// Feed in any order; duplicates ignored. Returns the concatenated payload
/// once complete, else `null`.
class BuUrAssembler {
  String? _type;
  var _total = 0;
  final _parts = <int, BuBytes>{};

  bool get isEmpty => _total == 0;

  BuBytes? feed(String shard) {
    final lower = shard.toLowerCase();
    if (!lower.startsWith('ur:')) {
      throw BuError(
        DefaultErrorType.invalidArgument,
        'hw.ur: missing ur: prefix',
      );
    }
    final rest = shard.substring(3);
    final segs = rest.split('/');
    if (segs.length != 2 && segs.length != 3) {
      throw BuError(DefaultErrorType.invalidArgument, 'hw.ur: bad envelope');
    }
    final type = segs[0].toLowerCase();
    final int seq;
    final int total;
    final String body;
    if (segs.length == 2) {
      throw BuError(
        DefaultErrorType.invalidArgument,
        'hw.ur: assembler needs multipart shards',
      );
    } else {
      final m = RegExp(r'^(\d+)-of-(\d+)$').firstMatch(segs[1]);
      if (m == null) {
        throw BuError(DefaultErrorType.invalidArgument, 'hw.ur: bad seq');
      }
      seq = int.parse(m.group(1)!);
      total = int.parse(m.group(2)!);
      body = segs[2];
      if (seq < 1 || total < 1 || seq > total) {
        throw BuError(DefaultErrorType.invalidArgument, 'hw.ur: bad seq range');
      }
    }
    if (_total == 0) {
      _type = type;
      _total = total;
    } else if (_type != type || _total != total) {
      throw BuError(DefaultErrorType.invalidArgument, 'hw.ur: mixed stream');
    }
    _parts.putIfAbsent(seq, () => buBase32DecodeNoPad(body));
    if (_parts.length == _total) {
      final out = <int>[];
      for (var i = 1; i <= _total; i++) {
        out.addAll(_parts[i]!);
      }
      return BuBytes(out);
    }
    return null;
  }
}

/// Byte transport — implemented by USB/BLE code, WebHID/WebUSB on web,
/// or [BuMockHwTransport] in tests. Codec stays in [BuHwApi]/Rust.
abstract interface class BuHwTransport {
  Future<BuBytes> exchange(BuBytes request);
}

/// Scripted transport: queues one response per [exchange], records requests.
class BuMockHwTransport implements BuHwTransport {
  BuMockHwTransport(List<List<int>> responses)
    : _responses = responses.map(BuBytes.new).toList();

  final List<BuBytes> _responses;
  final List<BuBytes> seen = [];

  int get remaining => _responses.length;

  @override
  Future<BuBytes> exchange(BuBytes request) async {
    seen.add(BuBytes(request));
    if (_responses.isEmpty) {
      throw BuError(DefaultErrorType.invalidState, 'hw.mock: script exhausted');
    }
    return _responses.removeAt(0);
  }
}

/// Hardware-wallet codec API over [BuPlatformBindings].
///
/// Transport-free: every method only builds/parses bytes. [executeGetAddress]
/// is the single orchestration entry point (needs a [BuHwTransport]).
abstract interface class BuHwApi {
  BuResult<bool> supportsCoin({required int device, required int coin});
  BuResult<bool> isAirgap({required int device});

  /// `"m/44'/0'/0'/0/0"` → `<u32 LE>` bytes for the other calls.
  BuResult<BuBytes> parsePath(String path);
  BuResult<void> validatePath({
    required int device,
    required int coin,
    required BuBytes pathU32,
  });

  /// USB request bytes (Ledger APDU / Trezor `?##` frame).
  BuResult<BuBytes> getAddressRequest({
    required int device,
    required int coin,
    required BuBytes pathU32,
  });

  /// USB response bytes → pubkey/address bytes.
  BuResult<BuBytes> parseAddressResponse({
    required int device,
    required BuBytes response,
  });

  // —— Ledger app-bitcoin v2 (CLA 0xE1, verified live) ——
  /// `GET_MASTER_FINGERPRINT` request bytes (no input, no UI).
  BuResult<BuBytes> ledgerFingerprint();

  /// 4-byte root fingerprint from `DATA || 0x9000`.
  BuResult<BuBytes> ledgerFingerprintParse({required BuBytes response});

  /// Sign-request bytes (Ledger APDU / Trezor `SignMessage` frame).
  /// [payload] is the 32-byte sighash (Ledger) or message (Trezor).
  BuResult<BuBytes> signRequest({
    required int device,
    required int coin,
    required BuBytes pathU32,
    required BuBytes payload,
  });

  /// Sign response bytes → signature bytes (DER for Ledger, 65-byte
  /// recoverable sig for Trezor).
  BuResult<BuBytes> parseSignResponse({
    required int device,
    required BuBytes response,
  });

  /// Airgap: show this string as QR.
  BuResult<String> qrRequest({
    required int device,
    required int coin,
    required BuBytes pathU32,
  });

  /// Airgap: scanned single-part QR → payload bytes.
  BuResult<BuBytes> qrParse({required int device, required String qr});

  /// PSBT bytes → `(inputs, outputs)`.
  BuResult<(int, int)> psbtCounts({required BuBytes psbt});

  /// `ur:<type>/<body>` (single-part).
  BuResult<String> urEncode({required String type, required BuBytes payload});
  BuResult<BuBytes> urDecodePayload(String ur);
  BuResult<String> urDecodeType(String ur);

  /// Build request → [transport.exchange] → parse. USB devices only.
  Future<BuResult<BuBytes>> executeGetAddress({
    required int device,
    required int coin,
    required BuBytes pathU32,
    required BuHwTransport transport,
  });

  /// Build sign request → [transport.exchange] → parse. USB devices only.
  Future<BuResult<BuBytes>> executeSign({
    required int device,
    required int coin,
    required BuBytes pathU32,
    required BuBytes payload,
    required BuHwTransport transport,
  });

  /// Open a Trezor `SignTx` session → USB request bytes.
  BuResult<BuBytes> signTxStart({
    required int device,
    required int coin,
    required int inputsCount,
    required int outputsCount,
  });

  /// One `TxRequest` → `(requestType, requestIndex)` (`requestIndex` is
  /// -1 when the device sent no index). TxRequest types per firmware:
  /// 0 input, 1 output, 2 meta, 3 finished, 4 extradata.
  BuResult<(int, int)> parseTxRequest({
    required int device,
    required BuBytes response,
  });

  /// `TXFINISHED` signature bytes.
  BuResult<BuBytes> txRequestSignature({
    required int device,
    required BuBytes response,
  });

  /// `TXFINISHED` consensus-serialized transaction.
  BuResult<BuBytes> txRequestSerialized({
    required int device,
    required BuBytes response,
  });

  /// `TxRequest` prev-tx hash (32 bytes); error when the request targets
  /// the current tx. Route prev-tx requests to previous-transaction data.
  BuResult<BuBytes> txRequestTxHash({
    required int device,
    required BuBytes response,
  });

  /// `TxAck` answering `TXMETA`.
  BuResult<BuBytes> txAckMeta({
    required int version,
    required int lockTime,
    required int inputsCount,
    required int outputsCount,
  });

  /// `TxAck` answering `TXINPUT` ([prevHash32] + change path as u32 LE +
  /// [amountSat] previous output value (required) + [scriptSig] original
  /// scriptSig for previous transactions' inputs (empty = omit, for the
  /// input being signed) + [scriptType] explicit input script type).
  BuResult<BuBytes> txAckInput({
    required BuBytes prevHash32,
    required int prevIndex,
    required BuBytes pathU32,
    required int amountSat,
    required BuBytes scriptSig,
    required int scriptType,
  });

  /// `TxAck` answering `TXOUTPUT` (pay to address, amount in sats,
  /// explicit [scriptType]).
  BuResult<BuBytes> txAckOutput({
    required String address,
    required int amountSat,
    required int scriptType,
  });

  /// `TxAck` answering `TXOUTPUT` (change back to path, explicit [scriptType]).
  BuResult<BuBytes> txAckChange({
    required BuBytes pathU32,
    required int amountSat,
    required int scriptType,
  });

  /// `TxAck` answering `TXOUTPUT` of a PREVIOUS transaction
  /// (`bin_outputs`: raw scriptPubKey + amount in sats).
  BuResult<BuBytes> txAckBinOutput({
    required BuBytes scriptPubKey,
    required int amountSat,
  });

  // —— BitBox02 session (stateful Noise_XX; I/O stays app-side) ——
  /// Open initiator session. Fails if one is already open.
  BuResult<void> bitboxHsNew({
    required BuBytes staticPriv32,
    required BuBytes ephemeralPriv32,
  });

  /// Handshake m1 (32 B). Any error spends the session (reopen).
  BuResult<BuBytes> bitboxHsM1();

  /// Ingest handshake m2. Any crypto error spends the session.
  BuResult<void> bitboxHsM2({required BuBytes m2});

  /// Handshake m3 (64 B).
  BuResult<BuBytes> bitboxHsM3();

  /// Split into transport keys.
  BuResult<void> bitboxHsSplit();

  /// Encrypt one message.
  BuResult<BuBytes> bitboxEncrypt({required BuBytes plaintext});

  /// Decrypt one message.
  BuResult<BuBytes> bitboxDecrypt({required BuBytes ciphertext});

  /// Handshake hash (pairing-code source).
  BuResult<BuBytes> bitboxHsHash();

  /// Close + wipe. Idempotent.
  BuResult<void> bitboxFree();

  /// `Request{btc_pub}` plaintext bytes (encrypt via the session).
  /// [xpubType]: 0 TPUB … 4 VPUB (default from path purpose app-side).
  BuResult<BuBytes> bitboxBtcPubRequest({
    required int coin,
    required BuBytes pathU32,
    required int xpubType,
    required bool display,
  });

  /// `Response` → xpub string.
  BuResult<String> bitboxPubParse({required BuBytes response});

  // —— BitBox02 BTC signing (plaintext frames; encrypt via the session) ——
  /// `Request{btc_sign_init}` bytes. [simpleType]: 0/1/2 (P2WPKH_P2SH,
  /// P2WPKH, P2TR); `version` must be 1 or 2.
  BuResult<BuBytes> bitboxSignInit({
    required int coin,
    required BuBytes pathU32,
    required int simpleType,
    required int version,
    required int inputsCount,
    required int outputsCount,
    required int locktime,
  });

  /// `sign_next` → `(requestType, index)` (`-1` = absent).
  BuResult<(int, int)> bitboxSignNextParse({required BuBytes response});

  /// `DONE` signature (64 B R||S).
  BuResult<BuBytes> bitboxSignNextSignature({required BuBytes response});

  /// `prev_index` for PREVTX_* (`-1` = absent: current-tx request).
  BuResult<int> bitboxSignNextPrevIndex({required BuBytes response});

  /// `Request{btc_sign_input}` bytes.
  BuResult<BuBytes> bitboxSignInput({
    required BuBytes prevHash32,
    required int prevIndex,
    required int amountSat,
    required int sequence,
    required BuBytes pathU32,
    required int scriptConfigIndex,
  });

  /// `Request{btc_sign_output}` bytes (external address).
  BuResult<BuBytes> bitboxSignOutput({
    required int outputType,
    required int amountSat,
    required BuBytes payload,
  });

  /// `Request{btc_sign_output}` bytes (change).
  BuResult<BuBytes> bitboxSignChange({
    required BuBytes pathU32,
    required int amountSat,
    required int scriptConfigIndex,
  });

  /// `Request{btc: BTCRequest{prevtx_init}}` bytes.
  BuResult<BuBytes> bitboxSignPrevtxInit({
    required int version,
    required int inputsCount,
    required int outputsCount,
    required int locktime,
  });

  /// `Request{btc: BTCRequest{prevtx_input}}` bytes.
  BuResult<BuBytes> bitboxSignPrevtxInput({
    required BuBytes prevHash32,
    required int prevIndex,
    required BuBytes scriptSig,
    required int sequence,
  });

  /// `Request{btc: BTCRequest{prevtx_output}}` bytes.
  BuResult<BuBytes> bitboxSignPrevtxOutput({
    required int amountSat,
    required BuBytes script,
  });

  // —— Trezor identity signing (SLIP-13; never for value transfer) ——
  /// `IdentityType` bytes ([proto] selects the namespace: ssh, gpg, …).
  BuResult<BuBytes> identityEncode({
    required String proto,
    String user = '',
    String host = '',
    String port = '',
    String path = '',
    int index = 0,
  });

  /// Framed `SignIdentity` ([curve]: 0 omit, 1 secp256k1, 2 nist256p1).
  BuResult<BuBytes> signIdentityRequest({
    required BuBytes identity,
    required BuBytes hidden,
    String visual = '',
    int curve = 0,
  });

  /// `SignedIdentity.address` string.
  BuResult<String> signedIdentityAddress({required BuBytes response});

  /// `SignedIdentity.public_key` bytes.
  BuResult<BuBytes> signedIdentityPubkey({required BuBytes response});

  /// `SignedIdentity.signature` bytes.
  BuResult<BuBytes> signedIdentitySignature({required BuBytes response});

  /// Chunk [payload] into concatenated 64-byte HID reports.
  BuResult<BuBytes> hidFrame({
    required BuBytes payload,
    int channel = BuHwHid.channelDefault,
    int tag = BuHwHid.tagApdu,
  });

  /// Reassemble concatenated 64-byte [reports] (length % 64 == 0).
  BuResult<BuBytes> hidUnframe({
    required BuBytes reports,
    int channel = BuHwHid.channelDefault,
    int tag = BuHwHid.tagApdu,
  });
}
