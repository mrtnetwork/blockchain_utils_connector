import 'package:blockchain_utils_connector/src/bytes/bytes.dart';

export 'padding.dart';

abstract class BuBlockCipher {
  int get blockSize;
  BuBytes encryptBlock(List<int> src, [List<int>? dst]);
  BuBytes decryptBlock(List<int> src, [List<int>? dst]);
  void clean();
}

abstract class BuBlockCipherCbc {
  BuBytes encrypt(List<int> data, [List<int>? dst]);
  BuBytes decrypt(List<int> data, [List<int>? dst]);
  void clean();
}

abstract class BuAesEcb {
  BuBytes encrypt(List<int> data);
  BuBytes? decrypt(List<int> data);
  void clean();
}

abstract class BuAesCtr {
  void process(List<int> data, List<int> out);
  void clean();
}
