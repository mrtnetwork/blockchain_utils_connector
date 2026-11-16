import 'package:blockchain_utils_connector/src/bytes/bytes.dart';

abstract class BuAead {
  int get nonceLength;
  int get tagLength;
  BuBytes encrypt(
    List<int> nonce,
    List<int> plaintext, {
    List<int>? associatedData,
    List<int>? dst,
  });
  BuBytes? decrypt(
    List<int> nonce,
    List<int> ciphertext, {
    List<int>? associatedData,
    List<int>? dst,
  });
  void clean();
}
