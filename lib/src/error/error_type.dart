/// Phase-1 base error types. No serialization/deserialization here (last phase).
library;

/// Machine-readable error kind. Implemented by [DefaultErrorType] (core)
/// and per-chain enums (e.g. `MoneroErrorType`, `ZcashErrorType`).
/// `identifier` must be globally unique; core reserves 0-999.
abstract interface class BuErrorType {
  String get errName;
  String get domain;
  int get identifier;
}

/// Core/shared errors. Chain-specific errors live in their own packages.
/// No duplicate names: anything reusable stays here.
enum DefaultErrorType implements BuErrorType {
  invalidArgument(1000),
  invalidState(1001),
  notFound(1002),
  castFailed(1003),
  invalidLength(1004),
  encodingError(1010),
  invalidChecksum(1011),
  badHex(1012),
  badBase64(1013),
  badBase58(1014),
  badBase32(1015),
  badBech32(1016),
  badSs58(1017),
  badUtf8(1018),
  badUuid(1019),
  badCbor(1020),
  badProto(1021),
  badLayout(1022),
  badJson(1023),
  badAmount(1024),
  badPublicKey(1030),
  badPrivateKey(1031),
  invalidScalar(1032),
  invalidPoint(1033),
  invalidKeyData(1034),
  invalidMnemonic(1035),
  invalidSeed(1036),
  invalidPath(1037),
  invalidAddress(1038),
  invalidAddressBytes(1039),
  crypto(1040),
  cryptoVerifyFailed(1041),
  unsupported(1042),
  internal(1043),
  network(1044),
  nullPointer(1045),
  invalidKey(1046),
  invalidNonce(1047),
  bufferTooSmall(1048),
  invalidSignature(1049),
  zeroScalar(1050),
  notInitialized(1051);

  @override
  String get domain => 'core';

  @override
  String get errName => name;

  @override
  final int identifier;
  const DefaultErrorType(this.identifier);
}
