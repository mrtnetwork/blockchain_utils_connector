import 'package:blockchain_utils_connector/src/api/block_cipher_api.dart';
import 'package:blockchain_utils_connector/src/bytes/bytes.dart';
import 'package:blockchain_utils_connector/src/cipher/block_cipher.dart';
import 'package:blockchain_utils_connector/src/cipher/native_block_cipher.dart';
import 'package:blockchain_utils_connector/src/error/bu_error.dart';
import 'package:blockchain_utils_connector/src/platform/bindings.dart';

class DefaultBlockCipherApi implements BuBlockCipherApi {
  DefaultBlockCipherApi(this._b);
  final BuPlatformBindings _b;
  @override
  BuResult<BuBlockCipher> aes(List<int> key) =>
      BuNativeAes.create(_b, BuBytes.from(key));
  @override
  BuResult<BuBlockCipherCbc> aesCbc(List<int> aesKey, List<int> iv) =>
      BuNativeAesCbc.create(_b, BuBytes.from(aesKey), BuBytes.from(iv));
  @override
  BuResult<BuAesEcb> aesEcb(
    List<int> key, {
    BuPaddingAlgorithm padding = BuPaddingAlgorithm.pkcs7,
  }) => BuNativeAesEcb.create(_b, BuBytes.from(key), padding);
  @override
  BuResult<BuAesCtr> aesCtr(List<int> key, List<int> iv) =>
      BuNativeAesCtr.create(_b, BuBytes.from(key), BuBytes.from(iv));
}
