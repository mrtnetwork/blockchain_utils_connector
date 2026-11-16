// ignore_for_file: library_private_types_in_public_api
// FFI typedefs are internal (never exported from blockchain_utils_connector.dart).
import 'dart:ffi' as ffi;

typedef _VersionN = ffi.Uint32 Function();
typedef _VersionD = int Function();
typedef _LoggingN = ffi.Int32 Function(ffi.Uint32, ffi.Uint32);
typedef _LoggingD = int Function(int, int);

/// ZK version / logging FFI symbols (`ffi::zkcodes`).
class BuZkCodesFfi {
  BuZkCodesFfi(ffi.DynamicLibrary lib)
    : version = lib.lookupFunction<_VersionN, _VersionD>('bu_zk_version'),
      enableLogging = lib.lookupFunction<_LoggingN, _LoggingD>(
        'bu_zk_enable_logging',
      ),
      buildVersion = lib.lookupFunction<_VersionN, _VersionD>(
        'bu_build_version',
      ),
      buildFeatures = lib.lookupFunction<_VersionN, _VersionD>(
        'bu_build_features',
      );

  final _VersionD version;
  final _LoggingD enableLogging;

  /// `bu_build_version` (backend interface version).
  final _VersionD buildVersion;

  /// `bu_build_features` (Cargo feature bitmask).
  final _VersionD buildFeatures;
}
