import 'package:blockchain_utils_connector/src/bytes/bytes.dart';

class BuBlake2Config {
  const BuBlake2Config({
    this.key,
    this.salt,
    this.personalization,
    this.fanout = 1,
    this.maxDepth = 1,
    this.leafSize = 0,
    this.nodeOffset = 0,
    this.nodeDepth = 0,
    this.innerDigestLength = 0,
    this.lastNode = false,
  });

  final BuBytes? key;
  final BuBytes? salt;
  final BuBytes? personalization;
  final int fanout;
  final int maxDepth;
  final int leafSize;
  final int nodeOffset;
  final int nodeDepth;
  final int innerDigestLength;
  final bool lastNode;
}
