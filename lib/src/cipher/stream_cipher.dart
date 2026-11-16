import 'package:blockchain_utils_connector/src/bytes/bytes.dart';

abstract class BuStreamCipher {
  BuBytes process(
    List<int> data, {
    required List<int> nonce,
    int nonceInplaceCounterLength = 0,
    int seekBytes = 0,
    List<int>? dst,
  });
  void clean();
}
