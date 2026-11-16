import 'package:blockchain_utils_connector/src/api/stream_cipher_api.dart';
import 'package:blockchain_utils_connector/src/bytes/bytes.dart';
import 'package:blockchain_utils_connector/src/cipher/native_stream_cipher.dart';
import 'package:blockchain_utils_connector/src/cipher/stream_cipher.dart';
import 'package:blockchain_utils_connector/src/error/bu_error.dart';
import 'package:blockchain_utils_connector/src/platform/bindings.dart';

class DefaultStreamCipherApi implements BuStreamCipherApi {
  DefaultStreamCipherApi(this._b);
  final BuPlatformBindings _b;
  @override
  BuResult<BuStreamCipher> chacha20(List<int> key) =>
      BuNativeChaCha20.create(_b, BuBytes.from(key));
}
