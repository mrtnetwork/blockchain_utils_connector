import 'package:blockchain_utils_connector/src/connector/bu.dart';

Bu initIo({String? libraryPath}) {
  return Bu.init(BuConfig(libraryPath: libraryPath));
}
