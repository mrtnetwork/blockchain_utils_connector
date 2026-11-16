import 'package:blockchain_utils_connector/src/cipher/stream_cipher.dart';
import 'package:blockchain_utils_connector/src/error/bu_error.dart';

abstract interface class BuStreamCipherApi {
  BuResult<BuStreamCipher> chacha20(List<int> key);
}
