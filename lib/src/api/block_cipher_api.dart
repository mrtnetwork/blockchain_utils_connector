import 'package:blockchain_utils_connector/src/cipher/block_cipher.dart';
import 'package:blockchain_utils_connector/src/error/bu_error.dart';

abstract interface class BuBlockCipherApi {
  BuResult<BuBlockCipher> aes(List<int> key);
  BuResult<BuBlockCipherCbc> aesCbc(List<int> aesKey, List<int> iv);
  BuResult<BuAesEcb> aesEcb(
    List<int> key, {
    BuPaddingAlgorithm padding = BuPaddingAlgorithm.pkcs7,
  });
  BuResult<BuAesCtr> aesCtr(List<int> key, List<int> iv);
}
