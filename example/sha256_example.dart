// import 'dart:convert';
// import 'dart:typed_data';

// import 'package:blockchain_utils_connector/blockchain_utils_connector.dart';

// void main() {
//   final path = String.fromEnvironment('BU_NATIVE_LIB', defaultValue: '');
//   Connector.initIo(libraryPath: path.isEmpty ? null : path);

//   final h = Hash(HashConfig.sha256());
//   h.update(utf8.encode('abc'));
//   print(_hex(h.digest()));
//   h.clean();

//   final b2 = Hash(HashConfig.blake2b(digestLen: 32));
//   b2.update(utf8.encode('hi'));
//   print('blake2b-256: ${_hex(b2.digest())}');
//   b2.clean();
// }

// String _hex(Uint8List b) =>
//     b.map((e) => e.toRadixString(16).padLeft(2, '0')).join();
