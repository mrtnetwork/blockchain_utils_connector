import 'package:blockchain_utils_connector/src/bytes/bytes.dart';

class BuHashState {
  BuHashState(this.handle);
  final Object handle;
}

abstract class BuHash {
  int get getDigestLength;
  int get getBlockSize;
  BuHash update(List<int> data);
  BuHash reset();
  BuHash finish(List<int> out);
  BuBytes digest();
  void clean();
}

abstract class BuSerializableHash<STATE extends BuHashState> extends BuHash {
  STATE saveState();
  BuSerializableHash restoreState(STATE saved);
  void cleanSavedState(STATE saved);
}
