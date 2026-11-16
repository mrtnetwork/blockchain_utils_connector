import 'package:blockchain_utils_connector/src/bytes/bytes.dart';
import 'package:blockchain_utils_connector/src/error/error_type.dart';

export 'error_type.dart';

/// Sole exception type for the blockchain_utils connector.
///
/// Public APIs must **only** throw or return [BuError] / [BuResult.err].
/// A [BuError] is just a code, a message and string-only details.
class BuError implements Exception {
  const BuError(this.type, this.message, {this.details});

  final BuErrorType type;

  final String message;

  /// Extra fields for debugging. Values are strings only.
  final Map<String, String?>? details;

  @override
  String toString() => 'BuError(${type.domain}.${type.errName}: $message)';

  // —— Factories with human-readable messages ——

  static BuError argument(String message, {Map<String, String?>? details}) =>
      BuError(DefaultErrorType.invalidArgument, message, details: details);

  static BuError length({
    required String what,
    required int expected,
    required int actual,
  }) => BuError(
    DefaultErrorType.invalidLength,
    '$what must be $expected bytes, got $actual',
    details: {'expected': '$expected', 'actual': '$actual'},
  );

  static BuError lengthOneOf({
    required String what,
    required List<int> allowed,
    required int actual,
  }) => BuError(
    DefaultErrorType.invalidLength,
    '$what must be one of $allowed bytes, got $actual',
    details: {'allowed': allowed.join(','), 'actual': '$actual'},
  );

  static BuError key({
    String message = 'invalid key material',
    Map<String, String?>? details,
  }) => BuError(DefaultErrorType.invalidKey, message, details: details);

  static BuError point({
    String message = 'point is not on the curve or is malformed',
  }) => BuError(DefaultErrorType.invalidPoint, message);

  static BuError scalar({
    String message = 'invalid scalar',
    bool zero = false,
  }) => BuError(
    zero ? DefaultErrorType.zeroScalar : DefaultErrorType.invalidScalar,
    zero ? 'scalar must be non-zero' : message,
  );

  static BuError nonce({
    String message = 'invalid nonce or IV',
    Map<String, String?>? details,
  }) => BuError(DefaultErrorType.invalidNonce, message, details: details);

  static BuError state({
    String message = 'object is cleaned or cannot be used again',
  }) => BuError(DefaultErrorType.invalidState, message);

  static BuError notInit() => const BuError(
    DefaultErrorType.notInitialized,
    'connector is not initialized; call Bu.init first',
  );

  static BuError unsupportedAlgo({
    String message = 'unsupported algorithm or configuration',
  }) => BuError(DefaultErrorType.unsupported, message);

  static BuError auth() => const BuError(
    DefaultErrorType.cryptoVerifyFailed,
    'authentication tag verification failed',
  );

  static BuError verify() => const BuError(
    DefaultErrorType.cryptoVerifyFailed,
    'signature verification failed',
  );

  static BuError internalErr({
    String message = 'internal cryptographic error',
  }) => BuError(DefaultErrorType.internal, message);

  // Named constants (backward compatible)
  static const invalidKey = BuError(
    DefaultErrorType.invalidKey,
    'invalid key material',
  );
  static const invalidNonce = BuError(
    DefaultErrorType.invalidNonce,
    'invalid nonce or IV',
  );
  static const invalidLength = BuError(
    DefaultErrorType.invalidLength,
    'invalid byte length',
  );
  static const authFailed = BuError(
    DefaultErrorType.cryptoVerifyFailed,
    'authentication tag verification failed',
  );
  static const unsupported = BuError(
    DefaultErrorType.unsupported,
    'unsupported algorithm or configuration',
  );
  static const internal = BuError(
    DefaultErrorType.internal,
    'internal cryptographic error',
  );
  static const invalidState = BuError(
    DefaultErrorType.invalidState,
    'object is cleaned or in an invalid state',
  );
  static const notInitialized = BuError(
    DefaultErrorType.notInitialized,
    'connector is not initialized; call Bu.init first',
  );
  static const bufferTooSmall = BuError(
    DefaultErrorType.bufferTooSmall,
    'output buffer is too small',
  );
  static const invalidArgument = BuError(
    DefaultErrorType.invalidArgument,
    'invalid argument',
  );
  static const invalidPoint = BuError(
    DefaultErrorType.invalidPoint,
    'invalid elliptic-curve point',
  );
  static const invalidScalar = BuError(
    DefaultErrorType.invalidScalar,
    'invalid scalar',
  );

  /// Generic native return-code numbering (Rust FFI):
  /// 1 null, 2 key, 3 nonce, 4 length, 5 auth, 6 unsupported, 7 internal,
  /// 8 state, 9 buffer size, 10 argument, 11 not initialized, 12 point,
  /// 13 scalar, 14 verify, 15 zero scalar, 16 signature.
  /// Modules with their own numbering translate to these ints first.
  /// Never forwards opaque Rust strings.
  static BuError fromNativeCode(int rc, {Map<String, String?>? details}) =>
      switch (rc) {
        1 => BuError(
          DefaultErrorType.nullPointer,
          'native call received a null pointer',
          details: details,
        ),
        2 => BuError(
          DefaultErrorType.invalidKey,
          'native rejected the key material',
          details: details,
        ),
        3 => BuError(
          DefaultErrorType.invalidNonce,
          'native rejected the nonce or IV',
          details: details,
        ),
        4 => BuError(
          DefaultErrorType.invalidLength,
          'native reported invalid buffer length',
          details: details,
        ),
        5 => BuError(
          DefaultErrorType.cryptoVerifyFailed,
          'authentication tag verification failed',
          details: details,
        ),
        6 => BuError(
          DefaultErrorType.unsupported,
          'algorithm not available in this native build',
          details: details,
        ),
        7 => BuError(
          DefaultErrorType.internal,
          'native cryptographic operation failed',
          details: details,
        ),
        8 => BuError(
          DefaultErrorType.invalidState,
          'native object is in an invalid state',
          details: details,
        ),
        9 => BuError(
          DefaultErrorType.bufferTooSmall,
          'native output buffer is too small',
          details: details,
        ),
        10 => BuError(
          DefaultErrorType.invalidArgument,
          'native rejected an argument',
          details: details,
        ),
        11 => BuError(
          DefaultErrorType.notInitialized,
          'native library is not initialized',
          details: details,
        ),
        12 => BuError(
          DefaultErrorType.invalidPoint,
          'native rejected the curve point',
          details: details,
        ),
        13 => BuError(
          DefaultErrorType.invalidScalar,
          'native rejected the scalar',
          details: details,
        ),
        14 => BuError(
          DefaultErrorType.cryptoVerifyFailed,
          'signature verification failed',
          details: details,
        ),
        15 => BuError(
          DefaultErrorType.zeroScalar,
          'scalar must be non-zero',
          details: details,
        ),
        16 => BuError(
          DefaultErrorType.invalidSignature,
          'invalid signature encoding',
          details: details,
        ),
        _ => BuError(
          DefaultErrorType.internal,
          'native cryptographic operation failed',
          details: details,
        ),
      };
}

/// Result type that never unwraps into [StateError] — only [BuError].
class BuResult<T> {
  const BuResult._(this._value, this._error);
  factory BuResult.ok(T value) => BuResult._(value, null);
  factory BuResult.err(BuError error) => BuResult._(null, error);
  factory BuResult.errCode(BuErrorType type, String message) =>
      BuResult.err(BuError(type, message));

  final T? _value;
  final BuError? _error;

  bool get isOk => _error == null;
  bool get isErr => _error != null;
  T? get value => _value;
  BuError? get error => _error;

  /// Throws [BuError] only (never [StateError]).
  T unwrapOrThrow() {
    final e = _error;
    if (e != null) {
      throw e;
    }
    return _value as T;
  }

  /// Same as [unwrapOrThrow]; kept for call-site compatibility.
  T unwrapOrThrowCryptoError() => unwrapOrThrow();

  BuResult<E> map<E>(E Function(T) fn) {
    if (isErr) {
      return BuResult<E>.err(error!);
    }
    return BuResult<E>.ok(fn(value as T));
  }
}

/// Hard validation helpers for public APIs (argument errors only).
class BuValidate {
  BuValidate._();

  static BuError? length(List<int> data, int expected, {required String what}) {
    if (data.length != expected) {
      return BuError.length(
        what: what,
        expected: expected,
        actual: data.length,
      );
    }
    return null;
  }

  static BuError? lengthOneOf(
    List<int> data,
    List<int> allowed, {
    required String what,
  }) {
    if (!allowed.contains(data.length)) {
      return BuError.lengthOneOf(
        what: what,
        allowed: allowed,
        actual: data.length,
      );
    }
    return null;
  }

  static BuError? nonEmpty(List<int> data, {required String what}) {
    if (data.isEmpty) {
      return BuError.argument('$what must not be empty');
    }
    return null;
  }

  static BuError? positive(int n, {required String what}) {
    if (n <= 0) {
      return BuError.argument(
        '$what must be positive, got $n',
        details: {'value': '$n'},
      );
    }
    return null;
  }

  /// AES key: 16 / 24 / 32.
  static BuError? aesKey(List<int> key) =>
      lengthOneOf(key, const [16, 24, 32], what: 'AES key');

  static BuError? chachaKey(List<int> key) =>
      length(key, 32, what: 'ChaCha20 key');

  static BuError? nonce(List<int> n, int expected) =>
      length(n, expected, what: 'nonce');

  static BuError? iv16(List<int> iv) => length(iv, 16, what: 'IV');

  static BuError? scalar32(List<int> s) => length(s, 32, what: 'scalar');

  static BuError? digest32(List<int> d) => length(d, 32, what: 'digest');

  static BuError? signature64(List<int> s) => length(s, 64, what: 'signature');

  static BuError? compressedPoint33(List<int> p) =>
      length(p, 33, what: 'compressed point');

  static BuError? xOnly32(List<int> p) =>
      length(p, 32, what: 'x-only public key');

  static BuResult<void> all(List<BuError?> checks) {
    for (final e in checks) {
      if (e != null) {
        return BuResult.err(e);
      }
    }
    return BuResult.ok(null);
  }

  /// Map native rc: 0 → ok, else [BuError.fromNativeCode].
  static BuResult<void> nativeRc(int rc) {
    if (rc == 0) {
      return BuResult.ok(null);
    }
    return BuResult.err(BuError.fromNativeCode(rc));
  }

  /// Bytes as [BuBytes] without cloning when already [BuBytes].
  static BuBytes asBytes(List<int> data) {
    if (data is BuBytes) {
      return data;
    }
    return BuBytes.from(data);
  }
}
