import 'package:blockchain_utils_connector/blockchain_utils_connector.dart';

/// Well-known emulator ports (override per constructor).
abstract final class EmuPorts {
  static const int trezorUdp = 21324;
  static const int bitboxTcp = 15423;
  static const int speculosApdu = 9999;
}

/// Stub used on web (no `dart:io`): every constructor throws.
class TrezorEmulatorTransport implements BuHwTransport {
  TrezorEmulatorTransport({String host = '127.0.0.1', int port = 21324}) {
    throw BuError(
      DefaultErrorType.unsupported,
      'emulator transports need dart:io',
    );
  }

  @override
  Future<BuBytes> exchange(BuBytes request) {
    throw BuError(
      DefaultErrorType.unsupported,
      'emulator transports need dart:io',
    );
  }
}

/// Stub used on web (no `dart:io`): every constructor throws.
class BitBoxSimulatorTransport implements BuHwTransport {
  BitBoxSimulatorTransport({String host = '127.0.0.1', int port = 15423}) {
    throw BuError(
      DefaultErrorType.unsupported,
      'emulator transports need dart:io',
    );
  }

  @override
  Future<BuBytes> exchange(BuBytes request) {
    throw BuError(
      DefaultErrorType.unsupported,
      'emulator transports need dart:io',
    );
  }

  /// Best-effort close (call between flows; the sim serves one client).
  Future<void> close() async {}
}

/// Stub used on web (no `dart:io`): every constructor throws.
class SpeculosApduTransport implements BuHwTransport {
  SpeculosApduTransport({String host = '127.0.0.1', int port = 9999}) {
    throw BuError(
      DefaultErrorType.unsupported,
      'emulator transports need dart:io',
    );
  }

  @override
  Future<BuBytes> exchange(BuBytes request) {
    throw BuError(
      DefaultErrorType.unsupported,
      'emulator transports need dart:io',
    );
  }
}
