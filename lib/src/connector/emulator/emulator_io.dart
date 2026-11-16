import 'dart:async';
import 'dart:io';
import 'dart:math';
import 'dart:typed_data';

import 'package:blockchain_utils_connector/blockchain_utils_connector.dart';

/// Well-known emulator ports (override per constructor).
abstract final class EmuPorts {
  static const int trezorUdp = 21324;
  static const int bitboxTcp = 15423;
  static const int speculosApdu = 9999;
}

/// Single-subscription socket reader (a `Socket` stream can only be
/// listened to once; this buffers across many fixed-size reads).
class _SockReader {
  _SockReader(Socket s) : _it = StreamIterator(s);

  final StreamIterator<Uint8List> _it;
  final _buf = <int>[];

  Future<List<int>> recv(
    int n, {
    Duration timeout = const Duration(seconds: 30),
  }) async {
    while (_buf.length < n) {
      final more = await _it.moveNext().timeout(timeout);
      if (!more) throw const SocketException('eof');
      _buf.addAll(_it.current);
    }
    final out = _buf.sublist(0, n);
    _buf.removeRange(0, n);
    return out;
  }
}

/// Trezor Model T emulator over UDP (`?` + 63-byte HID reports).
///
/// [exchange] takes the concatenated `?##` frame our codec builds,
/// re-chunks it into 64-byte UDP datagrams, and reassembles the reply
/// back into one concatenated frame for the codec to unframe.
class TrezorEmulatorTransport implements BuHwTransport {
  TrezorEmulatorTransport({
    String host = '127.0.0.1',
    int port = EmuPorts.trezorUdp,
  }) : _host = host,
       _port = port;

  final String _host;
  final int _port;

  @override
  Future<BuBytes> exchange(BuBytes request) async {
    if (request.isEmpty || request[0] != 0x3F) {
      throw BuError(
        DefaultErrorType.invalidArgument,
        'trezor emu: expected ?## frame',
      );
    }
    final stream = request.sublist(1);
    final socket = await RawDatagramSocket.bind(InternetAddress.anyIPv4, 0);
    try {
      socket.timeout(const Duration(seconds: 30));
      var off = 0;
      while (off < stream.length) {
        final piece = stream.sublist(
          off,
          off + 63 > stream.length ? stream.length : off + 63,
        );
        final dg = Uint8List(64);
        dg[0] = 0x3F;
        dg.setRange(1, 1 + piece.length, piece);
        socket.send(dg, InternetAddress(_host), _port);
        off += piece.length;
      }
      // First datagram carries the length at stream bytes 5..9
      // (frame layout after '?': '##' + be16(type) + be32(len)).
      // Single subscription: RawDatagramSocket events don't carry data;
      // each read event is followed by receive() calls.
      final got = <int>[];
      var needTotal = -1;
      await for (final ev in socket.timeout(const Duration(seconds: 30))) {
        if (ev != RawSocketEvent.read) continue;
        Datagram? dg;
        while ((dg = socket.receive()) != null) {
          if (dg!.data.length != 64 || dg.data[0] != 0x3F) continue;
          got.addAll(dg.data.sublist(1));
          if (needTotal < 0 && got.length >= 8) {
            final bodyLen =
                (got[4] << 24) | (got[5] << 16) | (got[6] << 8) | got[7];
            needTotal = 8 + bodyLen;
          }
          if (needTotal >= 0 && got.length >= needTotal) break;
        }
        if (needTotal >= 0 && got.length >= needTotal) break;
      }
      if (needTotal < 0 || got.length < needTotal) {
        throw const SocketException('trezor emu: short reply');
      }
      return BuBytes([0x3F, ...got.sublist(0, needTotal)]);
    } finally {
      socket.close();
    }
  }
}

/// BitBox02 simulator over TCP: U2F-HID reports + the HWW arbitration
/// layer this crate's session contract requires the backend to own
/// (`[REQ_NEW] + op`, `RETRY` polling, `ACK` strip). Returns the inner
/// OP reply (`[OP_STATUS] + payload`) for the session to check.
class BitBoxSimulatorTransport implements BuHwTransport {
  BitBoxSimulatorTransport({
    String host = '127.0.0.1',
    int port = EmuPorts.bitboxTcp,
  }) : _host = host,
       _port = port;

  final String _host;
  final int _port;
  Socket? _sock;
  _SockReader? _rd;
  final _rand = Random.secure();

  Future<Socket> _conn() async {
    final s = _sock;
    if (s != null) {
      return s;
    }
    final c = await Socket.connect(
      _host,
      _port,
      timeout: const Duration(seconds: 10),
    );
    c.setOption(SocketOption.tcpNoDelay, true);
    _sock = c;
    _rd = _SockReader(c);
    return c;
  }

  Future<List<int>> _recv(int n, Socket s) => _rd!.recv(n);

  Future<List<int>> _u2f(List<int> payload, int cid, Socket s) async {
    var idx = 0;
    var seq = 0;
    final first = payload.sublist(0, payload.length > 57 ? 57 : payload.length);
    final init = Uint8List(64);
    init.setRange(0, 4, _u32(cid));
    init[4] = 0xC1;
    init.setRange(5, 7, [(payload.length >> 8) & 0xFF, payload.length & 0xFF]);
    init.setRange(7, 7 + first.length, first);
    for (var i = 7 + first.length; i < 64; i++) {
      init[i] = 0xEE;
    }
    s.add(init);
    idx = first.length;
    while (idx < payload.length) {
      final chunk = payload.sublist(
        idx,
        idx + 59 > payload.length ? payload.length : idx + 59,
      );
      final cont = Uint8List(64);
      cont.setRange(0, 4, _u32(cid));
      cont[4] = seq;
      cont.setRange(5, 5 + chunk.length, chunk);
      for (var i = 5 + chunk.length; i < 64; i++) {
        cont[i] = 0xEE;
      }
      s.add(cont);
      seq++;
      idx += chunk.length;
    }
    await s.flush();
    List<int> rep = [];
    int? total;
    while (true) {
      final dg = await _recv(64, s);
      final rcid = (dg[0] << 24) | (dg[1] << 16) | (dg[2] << 8) | dg[3];
      if (rcid != cid) continue;
      if (total == null) {
        if (dg[4] != 0xC1) continue;
        total = (dg[5] << 8) | dg[6];
        rep.addAll(dg.sublist(7));
      } else {
        rep.addAll(dg.sublist(5));
      }
      if (rep.length >= total) {
        return rep.sublist(0, total);
      }
    }
  }

  static List<int> _u32(int v) => [
    (v >> 24) & 0xFF,
    (v >> 16) & 0xFF,
    (v >> 8) & 0xFF,
    v & 0xFF,
  ];

  @override
  Future<BuBytes> exchange(BuBytes request) async {
    if (request.isEmpty) {
      throw BuError(
        DefaultErrorType.invalidArgument,
        'bitbox emu: empty OP message',
      );
    }
    var cid = _rand.nextInt(0xFFFFFFFE) + 1;
    final s = await _conn();
    List<int> rsp;
    try {
      rsp = await _u2f([0x00, ...request], cid, s);
    } catch (_) {
      try {
        _sock?.destroy();
      } catch (_) {}
      _sock = null;
      _rd = null;
      rethrow;
    }
    var status = rsp[0];
    var inner = rsp.sublist(1);
    while (status == 1) {
      await Future<void>.delayed(const Duration(milliseconds: 200));
      cid = _rand.nextInt(0xFFFFFFFE) + 1;
      rsp = await _u2f([0x01], cid, s);
      status = rsp[0];
      inner = rsp.sublist(1);
    }
    if (status == 2) {
      throw BuError(DefaultErrorType.invalidState, 'bitbox emu: device busy');
    }
    if (status != 0) {
      throw BuError(
        DefaultErrorType.internal,
        'bitbox emu: HWW NACK ($status)',
      );
    }
    return BuBytes(inner);
  }

  /// Best-effort close (call between flows; the sim serves one client).
  Future<void> close() async {
    try {
      await _sock?.close();
    } catch (_) {}
    _sock = null;
  }
}

/// Ledger Speculos APDU server: length-prefixed raw APDUs. Note the
/// framing quirk: the 4-byte length counts DATA bytes, the 2 SW bytes
/// follow — always read N+2.
class SpeculosApduTransport implements BuHwTransport {
  SpeculosApduTransport({
    String host = '127.0.0.1',
    int port = EmuPorts.speculosApdu,
  }) : _host = host,
       _port = port;

  final String _host;
  final int _port;

  @override
  Future<BuBytes> exchange(BuBytes request) async {
    final s = await Socket.connect(
      _host,
      _port,
      timeout: const Duration(seconds: 10),
    );
    final rd = _SockReader(s);
    try {
      final n = request.length;
      s.add([
        (n >> 24) & 0xFF,
        (n >> 16) & 0xFF,
        (n >> 8) & 0xFF,
        n & 0xFF,
        ...request,
      ]);
      await s.flush();
      final lnBytes = await rd.recv(4);
      final ln =
          (lnBytes[0] << 24) |
          (lnBytes[1] << 16) |
          (lnBytes[2] << 8) |
          lnBytes[3];
      final body = await rd.recv(ln + 2, timeout: const Duration(seconds: 60));
      return BuBytes(body);
    } finally {
      try {
        await s.close();
      } catch (_) {}
    }
  }
}
