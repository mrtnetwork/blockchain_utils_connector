// VM entry: FFI backend (default). Backend via environment
// (see test/test_backend.dart):
//   dart test test/connector_backend_test.dart
//   BU_BACKEND=ffi [BU_LIB_PATH=...] [BU_BUILD=ffi] dart test test/
import 'package:test/test.dart';

import 'backend_suite.dart';
import 'test_utils.dart';
import 'unit/bytes_test.dart';

void main() async {
  // Builds the FFI library with cargo first when BU_BUILD=ffi|all|1.
  await ConnectorTestApi.ensureBackend();
  final bu = ConnectorTestApi.bu;
  runBytesUnitSuite();
  runBackendSuite(() => bu);

  test('backend is FFI on VM', () {
    expect(ConnectorTestApi.bu, same(bu));
  });
}
