/// Phase-1 base error types. No serialization/deserialization here (last phase).
library;

import 'package:blockchain_utils_connector/src/serialization/serialization.dart';

/// Machine-readable error kind. Implemented by [DefaultErrorType] (core)
/// and per-chain enums (e.g. `MoneroErrorType`, `ZcashErrorType`).
/// `identifier` must be globally unique; core reserves 0-999.
abstract interface class BuErrorType implements SerializationIdentifier {
  String get errName;
  String get domain;
  @override
  int get id;
}

/// Core/shared errors. Chain-specific errors live in their own packages.
/// No duplicate names: anything reusable stays here.
enum DefaultErrorType implements BuErrorType {
  invalidArgument(30000),
  invalidState(30001),
  notFound(30002),
  castFailed(30003),
  invalidLength(30004),
  encodingError(30010),
  invalidChecksum(30011),
  badHex(30012),
  badBase64(30013),
  badBase58(30014),
  badBase32(30015),
  badBech32(30016),
  badSs58(30017),
  badUtf8(30018),
  badUuid(30019),
  badCbor(30020),
  badProto(30021),
  badLayout(30022),
  badJson(30023),
  badAmount(30024),
  badPublicKey(30030),
  badPrivateKey(30031),
  invalidScalar(30032),
  invalidPoint(30033),
  invalidKeyData(30034),
  invalidMnemonic(30035),
  invalidSeed(30036),
  invalidPath(30037),
  invalidAddress(30038),
  invalidAddressBytes(30039),
  crypto(30040),
  cryptoVerifyFailed(30041),
  unsupported(30042),
  internal(30043),
  network(30044),
  nullPointer(30045),
  invalidKey(30046),
  invalidNonce(30047),
  bufferTooSmall(30048),
  invalidSignature(30049),
  zeroScalar(30050),
  notInitialized(30051);

  @override
  String get domain => 'core';

  @override
  String get errName => name;

  @override
  final int id;
  const DefaultErrorType(this.id);

  @override
  bool isValid(int? tag) {
    return id == tag;
  }
}
