/// Byte buffers for the connector: [BuBytes] and [SecretBytes].
///
/// ## Which type to use
///
/// - [BuBytes]: general-purpose byte buffer with explicit *owned vs view*
///   and *mutable vs immutable* semantics. Use for public values
///   (hashes, ciphertexts, points, proofs).
/// - [SecretBytes]: key material / secrets. Always copies on construction,
///   obscures bytes in memory through a pluggable [SecretTransform]
///   (XOR pad by default), is externally immutable (the only mutation is
///   [SecretBytes.zero]), compares in constant time, and auto-zeroes via a
///   [Finalizer] when garbage-collected without an explicit [SecretBytes.zero].
///
/// ## Ownership model ([BuBytes])
///
/// - *Owned* (`isOwned == true`): this instance controls the backing list
///   (it made a copy). Zeroing / resizing is safe.
/// - *View* (`isOwned == false`): the backing list belongs to someone else
///   ([BuBytes.from], [BuBytes.unsafe], [BuBytes.unsafeMutable]). Never zero
///   a view unless you own the source.
/// - *Immutable* (`isImmutable == true`): any write throws [BuError].
///   Immutability is enforced, not just advertised.
///
/// ## FFI / WASM boundary
///
/// Buffers crossing into native code are copied into short-lived native
/// allocations by the platform layers (`connector/io`, `connector/web`);
/// key bytes are wiped after the call. A [BuBytes] passed to a binding call
/// is never retained by native code, so no explicit disposal is needed for
/// the buffer itself — only long-lived native *handles* (hash contexts,
/// AES contexts, params/proving keys) need [SecretState.dispose]-style
/// cleanup, which the `native_*` wrappers automate with [Finalizer]s.
library;

import 'dart:collection';
import 'dart:math';
import 'dart:typed_data';

import 'package:blockchain_utils_connector/src/error/bu_error.dart';

/// Rule violations in [BuBytes] / [SecretBytes] throw [BuError].
///
/// Index-range problems still surface as native [RangeError]; everything else
/// (bad byte values, writes to immutable buffers, reads after
/// [SecretBytes.zero]) is a [BuError], optionally carrying machine-readable
/// [details].

/// Byte buffer with explicit owned-vs-view and mutable-vs-immutable semantics.
///
/// Extends [ListBase]`<int>` so it works everywhere a `List<int>` is
/// expected, with two additions: value equality is a constant-time byte
/// comparison ([SecretBytes.constantTimeEquals]), and secrets can be wiped
/// with [zero].
///
/// Construction always validates that every element is in `0..255`
/// (constant-time aggregated check in [_validateBytes]); violations throw
/// [BuError]. Use the named factories to pick the semantics you need —
/// the default `BuBytes(data)` is a *mutable owned copy*.
class BuBytes extends ListBase<int> {
  final List<int> _data;

  /// Whether writes throw [BuError]. Set once at construction.
  final bool isImmutable;

  /// Whether this instance owns its backing list (made a copy).
  /// Views (`false`) must not be zeroed unless the caller owns the source.
  final bool isOwned;

  BuBytes._(this._data, {required this.isImmutable, required this.isOwned});

  /// Mutable owned copy of [data] (validated, copied).
  ///
  /// The copy means later mutations of [data] never affect this buffer,
  /// and [zero] is safe. Prefer this for secrets that must be wiped.
  factory BuBytes(List<int> data) {
    final copy = List<int>.from(_validateBytes(data));
    return BuBytes._(copy, isImmutable: false, isOwned: true);
  }

  /// Immutable owned copy of [data] (validated, copied).
  ///
  /// Any write throws [BuError]. Use for values shared across code
  /// that must not change (digests used as map keys, test vectors).
  factory BuBytes.immutable(List<int> data) {
    final copy = List<int>.from(_validateBytes(data));
    return BuBytes._(copy, isImmutable: true, isOwned: true);
  }

  /// Alias of the default factory: mutable owned copy.
  factory BuBytes.owned(List<int> data) => BuBytes(data);

  /// Zero-copy view when [data] is a plain list, identity when already [BuBytes].
  ///
  /// No copy is made (`isOwned == false`): cheap, but writes go through to
  /// the source list and [zero] would wipe the caller's data. Only use when
  /// the source outlives this buffer and is never wiped underneath it.
  /// Returns [data] itself when it already is a [BuBytes].
  factory BuBytes.from(List<int> data) {
    if (data is BuBytes) {
      return data;
    }
    return BuBytes._(_validateBytes(data), isImmutable: false, isOwned: false);
  }

  /// Zero-copy mutable view over [data] (no validation, no copy).
  ///
  /// `const`-constructible for performance-sensitive paths. The caller keeps
  /// ownership: do not [zero] unless you own [data].
  const BuBytes.unsafeMutable(this._data)
    : isImmutable = false,
      isOwned = false;

  /// Zero-copy immutable view over [data] (no validation, no copy).
  ///
  /// `const`-constructible. Writes throw [BuError]; the caller keeps
  /// ownership of [data].
  const BuBytes.unsafe(this._data) : isOwned = false, isImmutable = true;

  /// Owned zero-filled buffer of [length] bytes.
  ///
  /// Set [immutable] to get a fixed (growable: false) buffer. The result is
  /// always owned, so [zero] is safe.
  factory BuBytes.zero(int length, {bool immutable = false}) {
    final bytes = List<int>.filled(length, 0, growable: !immutable);
    return BuBytes._(bytes, isImmutable: immutable, isOwned: true);
  }

  /// Owned empty buffer. Equivalent to `zero(0)`.
  factory BuBytes.empty({bool immutable = false}) =>
      BuBytes.zero(0, immutable: immutable);

  /// Owned buffer of [length] bytes filled with [fill] (`0` when omitted).
  factory BuBytes.fill(int length, [int? fill]) => BuBytes._(
    List<int>.filled(length, fill ?? 0),
    isImmutable: false,
    isOwned: true,
  );

  /// Owned concatenation of [bytes] in order.
  ///
  /// Every element is masked to a byte on the way in; the result is owned.
  factory BuBytes.concat(Iterable<List<int>> bytes, {bool immutable = false}) {
    final v = _validateBytes(bytes.expand((e) => e.toList()).toList());
    return BuBytes._(v, isImmutable: immutable, isOwned: true);
  }

  /// Owned buffer from arbitrary [data], masking each element to a byte.
  ///
  /// Unlike the validating factories, values are wrapped with `& 0xff`
  /// instead of throwing.
  factory BuBytes.toBytes(Iterable<int> data, {bool immutable = false}) {
    return BuBytes._(
      data.map((e) => e & 0xff).toList(),
      isImmutable: immutable,
      isOwned: true,
    );
  }

  /// Aggregated range check: returns [data] when every element fits in a
  /// byte, otherwise throws [BuError].
  ///
  /// The loop avoids branching on secret-adjacent values where cheap to do
  /// so (single aggregated `invalid` flag). [BuBytes] itself is also accepted
  /// (returned as-is for the `switch` — callers still copy).
  static List<int> _validateBytes(List<int> data) {
    switch (data) {
      case BuBytes():
        return data;
      case Uint8List():
        return data;
      case SecretBytes():
        return data;
    }
    int invalid = 0;
    for (int i = 0; i < data.length; i++) {
      int b = data[i];
      invalid |= (b >> 8);
    }
    if (invalid != 0) {
      throw BuError(DefaultErrorType.invalidArgument, 'Invalid byte');
    }
    return data;
  }

  /// Overwrites this buffer with zeros. Returns `false` (no-op) when
  /// immutable; never throws for immutable (use [forceZero] to attempt anyway).
  ///
  /// Views wipe the *shared* source — only call when you own it.
  bool zero() {
    if (isImmutable) {
      return false;
    }
    return forceZero();
  }

  /// Overwrites this buffer with zeros even if immutable, returning whether
  /// every byte was wiped. Backing lists that reject writes (fixed-length
  /// `Uint8List` slices obtained elsewhere) yield `false`.
  bool forceZero() {
    try {
      for (var i = 0; i < _data.length; i++) {
        _data[i] = 0;
      }
      return true;
    } catch (_) {
      return false;
    }
  }

  @override
  int get length => _data.length;

  @override
  set length(int newLength) {
    if (isImmutable) {
      throw BuError(DefaultErrorType.invalidState, 'immutable');
    }
    _data.length = newLength;
  }

  @override
  int operator [](int index) => _data[index];

  @override
  void operator []=(int index, int value) {
    if (isImmutable) {
      throw BuError(DefaultErrorType.invalidState, 'immutable');
    }
    if (value < 0 || value > 255) {
      throw BuError(DefaultErrorType.invalidArgument, 'Invalid byte value');
    }
    _data[index] = value;
  }

  @override
  void add(int element) {
    if (isImmutable) {
      throw BuError(DefaultErrorType.invalidState, 'immutable');
    }
    if (element < 0 || element > 255) {
      throw BuError(DefaultErrorType.invalidArgument, 'Invalid byte value');
    }
    _data.add(element);
  }

  /// Value equality: constant-time byte comparison against any [List<int>]
  /// (same length and every byte equal). Unlike [identical], two distinct
  /// buffers with the same contents compare equal.
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (other is! List<int>) {
      return false;
    }
    return SecretBytes.constantTimeEquals(this, other);
  }

  @override
  int get hashCode => Object.hashAll(_data);

  /// Owned sub-range copy (`isOwned == true`, mutable).
  @override
  BuBytes sublist(int start, [int? end]) {
    return BuBytes._(
      super.sublist(start, end),
      isImmutable: false,
      isOwned: true,
    );
  }

  /// Owned reversed copy.
  BuBytes reverse({bool isImmutable = false}) =>
      BuBytes._(reversed.toList(), isImmutable: isImmutable, isOwned: true);

  /// Owned copy of this buffer (fresh backing list).
  BuBytes cloneBytes({bool immutable = false}) {
    return BuBytes._(
      List<int>.from(_data),
      isImmutable: immutable,
      isOwned: true,
    );
  }

  @override
  String toString() => _data.toString();

  /// Owned copy as [BuBytes] (respects [growable]/[isImmutable]).
  @override
  BuBytes toList({bool growable = true, bool isImmutable = false}) {
    return BuBytes._(
      super.toList(growable: growable),
      isImmutable: isImmutable,
      isOwned: true,
    );
  }
}

/// -----------------------------------------------------------------------
/// SecretTransform: pluggable obscuring scheme for [SecretBytes].
///
/// `SecretBytes` never stores plaintext directly — every byte passes
/// through a `SecretTransform` on the way in ([obscure]) and out
/// ([reveal]). The transform owns whatever side-channel-resistant state
/// it needs (e.g. an XOR pad) via [generateState], and is responsible for
/// destroying that state in [wipeState].
///
/// Implementations should:
///  - Run in constant time with respect to the *value* of each byte
///    (branch only on things that are already public, like the index).
///  - Treat [generateState]'s output as sensitive: don't log it, don't
///    let it escape the `SecretBytes` instance that owns it.
///  - Make [reveal] the exact inverse of [obscure] for a given index and
///    state — `SecretBytes` assumes this holds and does not double-check.
///
/// `SecretBytes` defaults to [XorTransform] if none is supplied. Anyone
/// can implement this interface (e.g. to route through platform
/// secure-enclave primitives, a different masking scheme, etc.).
/// -----------------------------------------------------------------------
abstract class SecretTransform {
  /// Base for pluggable obscuring schemes (see class docs).
  const SecretTransform();

  /// Produce fresh, per-instance state sized for a secret of [length]
  /// bytes. Called once per `SecretBytes` instance. May return an empty
  /// list if the transform needs no state (see [NoneTransform]).
  List<int> generateState(int length);

  /// Turn plaintext [value] at [index] into its stored form, using
  /// [state] as produced by [generateState]. Must be constant-time in
  /// [value].
  int obscure(int index, int value, List<int> state);

  /// Recover the plaintext byte at [index] from its stored [transformed]
  /// form, using [state]. Must satisfy
  /// `reveal(i, obscure(i, v, s), s) == v` for all valid `i`, `v`, `s`.
  int reveal(int index, int transformed, List<int> state);

  /// Destroy [state] in place (e.g. zero it out). Called when the owning
  /// `SecretBytes` is zeroed. No-op for transforms with no state.
  void wipeState(List<int> state);
}

/// Default transform: masks each byte with a fresh, cryptographically
/// random pad byte generated once per `SecretBytes` instance. XOR is its
/// own inverse, so [obscure] and [reveal] share an implementation.
class XorTransform extends SecretTransform {
  /// Creates the default XOR-masking transform.
  const XorTransform();

  static final Random _rng = Random.secure();

  @override
  List<int> generateState(int length) =>
      List<int>.generate(length, (_) => _rng.nextInt(256));

  @override
  int obscure(int index, int value, List<int> state) => value ^ state[index];

  @override
  int reveal(int index, int transformed, List<int> state) =>
      transformed ^ state[index];

  @override
  void wipeState(List<int> state) {
    for (var i = 0; i < state.length; i++) {
      state[i] = 0;
    }
  }
}

/// Pass-through transform: stores bytes as-is, no masking, no state.
///
/// Useful when you want `SecretBytes`'s fixed-length/zeroing/no-hashCode
/// API (and the discipline that comes with it) without the cost of
/// masking — e.g. short-lived buffers that are already protected another
/// way, or testing. Prefer [XorTransform] (the default) for anything
/// that's actually sensitive.
class NoneTransform extends SecretTransform {
  /// Creates the pass-through transform.
  const NoneTransform();

  @override
  List<int> generateState(int length) => const [];

  @override
  int obscure(int index, int value, List<int> state) => value;

  @override
  int reveal(int index, int transformed, List<int> state) => transformed;

  @override
  void wipeState(List<int> state) {}
}

/// -----------------------------------------------------------------------
/// SecretBytes: for key material / other secrets. Always copies, always
/// constant-time-validates, obscured in memory via a pluggable
/// [SecretTransform] (XOR by default), zeroable, constant-time
/// comparable. All of *its own* rule violations throw `BytesError` too;
/// index-range issues still surface as native `RangeError`.
///
/// Externally immutable: once constructed, its content can never be
/// changed — no index assignment, no `add`, no `length=`. The *only*
/// mutation exposed is [zero], which destroys the secret in place rather
/// than replacing it with different content. Need a secret with
/// different bytes? Build a new `SecretBytes`.
///
/// Memory hygiene: [zero] wipes both the obscured bytes and the transform
/// state and detaches the [Finalizer]; if you forget [zero], the same wipe
/// still runs when the instance is garbage-collected (best-effort —
/// explicit [zero] is deterministic, finalization is not).
/// -----------------------------------------------------------------------
class SecretBytes extends ListBase<int> {
  final List<int> _transformed;
  final List<int> _state;
  final SecretTransform _transform;
  bool _zeroed = false;
  final int _length;

  static const SecretTransform _defaultTransform = XorTransform();

  /// Safety net: wipes the obscured bytes + transform state if the owner
  /// was never [zero]ed explicitly. Runs on GC; never resurrects the owner.
  static final Finalizer<_ZeroToken> _finalizer = Finalizer((token) {
    return token.zero();
  });

  /// Moves [secret] in, wiping the source list afterwards (when writable).
  ///
  /// The source is validated + obscured first, so a throw still leaves no
  /// plaintext behind in *this* instance; the source wipe is best-effort.
  factory SecretBytes.take(
    List<int> secret, {
    SecretTransform? transform = _defaultTransform,
  }) {
    return SecretBytes(secret, transform: transform, wipeSource: true);
  }

  /// Copies + constant-time-validates [secret] into transformed storage
  /// using [transform] (defaults to [XorTransform]).
  ///
  /// When [wipeSource] is true, the source list is zeroed after the copy
  /// (best-effort: unmodifiable sources are simply left alone).
  SecretBytes(
    List<int> secret, {
    bool wipeSource = false,
    SecretTransform? transform = _defaultTransform,
  }) : _length = secret.length,
       _transformed = List<int>.filled(secret.length, 0),
       _state = (transform ?? _defaultTransform).generateState(secret.length),
       _transform = transform ?? _defaultTransform {
    _validateAndObscureConstantTime(secret);
    if (wipeSource) {
      _tryZeroSource(secret);
    }
    _finalizer.attach(
      this,
      _ZeroToken(_transformed, _state, _transform),
      detach: this,
    );
  }
  // factory SecretBytes.fromString(String secret, {SecretTransform? transform}) {
  //   return SecretBytes(StringUtils.encode(secret), transform: transform);
  // }
  /// Zero-initialized secret of [length] bytes (obscured like any other).
  factory SecretBytes.zero(int length, {SecretTransform? transform}) {
    return SecretBytes(List<int>.filled(length, 0), transform: transform);
  }

  /// Generates fresh cryptographically random secret bytes directly.
  ///
  /// The intermediate list is moved (wiped) into the new instance, so no
  /// plaintext copy lingers in the caller's list.
  factory SecretBytes.random(int length, {SecretTransform? transform}) {
    final secret = List<int>.generate(
      length,
      (_) => Random.secure().nextInt(256),
    );
    return SecretBytes.take(secret, transform: transform ?? _defaultTransform);
  }

  /// Validates every byte is in `0..255` (single aggregated flag, no early
  /// exit on values) while obscuring into [_transformed]. On failure the
  /// partial storage is wiped and a [BuError] is thrown without
  /// revealing *where* the bad byte was.
  void _validateAndObscureConstantTime(List<int> secret) {
    var invalidMask = 0;
    for (var i = 0; i < secret.length; i++) {
      final b = secret[i];
      invalidMask |= (b < 0 || b > 255) ? 1 : 0;
      _transformed[i] = _transform.obscure(i, b, _state);
    }
    if (invalidMask != 0) {
      zero();
      // Deliberately no index/value here (unlike BuBytes._validate) — keeps
      // to the constant-time spirit by not revealing *where* the bad
      // byte was, even in error metadata.
      throw BuError(
        DefaultErrorType.invalidArgument,
        'Invalid byte value in secret: all values must be in range 0-255',
        details: {'reason': 'invalid-byte-range'},
      );
    }
  }

  /// Best-effort source wipe: unmodifiable sources throw and are ignored.
  static void _tryZeroSource(List<int> secret) {
    try {
      for (var i = 0; i < secret.length; i++) {
        secret[i] = 0;
      }
    } catch (_) {
      // secret was unmodifiable — nothing more we can do about it.
    }
  }

  /// Whether [zero] has run (explicitly or via finalization).
  bool get isZeroed => _zeroed;

  /// The transform this instance obscures/reveals bytes with.
  SecretTransform get transform => _transform;

  @override
  int get length => _length;

  @override
  set length(int newLength) =>
      throw BuError(
        DefaultErrorType.invalidState,
        'SecretBytes is immutable: cannot resize',
        details: {'operation': 'length='},
      );

  /// Reads the plaintext byte at [index] (revealed on the fly).
  ///
  /// Throws [BuError] after [zero], [RangeError] when out of range.
  @override
  int operator [](int index) {
    _checkAlive();
    RangeError.checkValidIndex(index, this, 'index', _length); // untouched
    return _transform.reveal(index, _transformed[index], _state);
  }

  /// Always throws: `SecretBytes` is externally immutable (see class docs).
  @override
  void operator []=(int index, int value) {
    _checkAlive();
    RangeError.checkValidIndex(index, this, 'index', _length); // untouched
    throw BuError(
      DefaultErrorType.invalidState,
      'SecretBytes is immutable: cannot replace bytes; construct a new '
      'SecretBytes instead',
      details: {'operation': '[]='},
    );
  }

  /// Always throws: `SecretBytes` has fixed length and no `add`.
  @override
  void add(int element) =>
      throw BuError(
        DefaultErrorType.invalidState,
        'SecretBytes is immutable: cannot add',
        details: {'operation': 'add'},
      );

  /// Overwrites the secret in memory with zeros. Idempotent.
  ///
  /// Wipes the obscured bytes *and* the transform state, marks [isZeroed],
  /// and detaches the [Finalizer] (no double-wipe on GC).
  void zero() {
    if (_zeroed) {
      return;
    }
    for (var i = 0; i < _transformed.length; i++) {
      _transformed[i] = 0;
    }
    _transform.wipeState(_state);
    _zeroed = true;
    _finalizer.detach(this);
  }

  /// Guards every read against use-after-[zero].
  void _checkAlive() {
    if (_zeroed) {
      throw BuError(
        DefaultErrorType.invalidState,
        'SecretBytes has been zeroed and can no longer be read or written',
        details: {'reason': 'zeroed'},
      );
    }
  }

  /// Safe read pattern: decode the plaintext once, hand it to [action],
  /// then zero that temporary buffer before returning either way.
  ///
  /// When [zero] is true, this instance is also zeroed after [action]
  /// returns — for one-shot secrets (e.g. splitting a KDF output).
  T useValue<T>(T Function(List<int> plaintext) action, {bool zero = false}) {
    _checkAlive();
    final plain = List<int>.generate(
      _length,
      (i) => _transform.reveal(i, _transformed[i], _state),
    );
    try {
      return action(plain);
    } finally {
      for (var i = 0; i < plain.length; i++) {
        plain[i] = 0;
      }
      if (zero) {
        this.zero();
      }
    }
  }

  /// Clones with a fresh copy of the secret. Reuses this instance's
  /// [transform] (and gets fresh state from it) unless [transform] is
  /// given explicitly.
  SecretBytes cloneBytes({SecretTransform? transform}) {
    _checkAlive();
    return useValue(
      (plain) => SecretBytes(
        List<int>.from(plain),
        transform: transform ?? _transform,
      ),
    );
  }

  /// Extracts the plaintext as an owned [BuBytes] (caller must [BuBytes.zero]
  /// it when done). This instance stays alive — see [takeBytes] for the
  /// consuming variant that also zeroes this secret in the same step.
  BuBytes toBytes({bool immutable = false}) {
    _checkAlive();
    final plain = List<int>.generate(
      _length,
      (i) => _transform.reveal(i, _transformed[i], _state),
    );
    return BuBytes._(plain, isImmutable: immutable, isOwned: true);
  }

  /// Constant-time equality. Defined only on `SecretBytes`.
  ///
  /// Short-circuits on length mismatch (lengths are not secret here);
  /// the byte loop itself is constant-time in the values.
  static bool constantTimeEquals(List<int> a, List<int> b) {
    if (a.length != b.length) {
      return false;
    }
    var diff = 0;
    for (var i = 0; i < a.length; i++) {
      diff |= a[i] ^ b[i];
    }
    return diff == 0;
  }

  /// Comparing a zeroed `SecretBytes` throws `BuError` — treated as a
  /// read.
  @override
  bool operator ==(Object other) {
    _checkAlive();
    if (other is! List<int>) {
      return false;
    }
    return constantTimeEquals(this, other);
  }

  /// Intentionally unusable: secrets must never be map keys or logged.
  /// Use `useValue()`/`==` instead.
  @override
  int get hashCode =>
      throw BuError(
        DefaultErrorType.invalidArgument,
        'SecretBytes intentionally has no hashCode — avoid Set/Map keys '
        'or logging it; use useValue()/== instead',
        details: {'reason': 'unhashable'},
      );

  /// Redacted debug string: length + zeroed/hidden (never the bytes).
  @override
  String toString() =>
      _zeroed
          ? 'SecretBytes($_length bytes, zeroed)'
          : 'SecretBytes($_length bytes, hidden)';

  /// Extracts the plaintext as an owned [BuBytes] and destroys this secret
  /// in the same step — after this call `isZeroed` is true and further
  /// reads throw. Prefer this over `toBytes()` followed by a separate
  /// `zero()` call: one step means there's no window where you're
  /// holding the extracted copy but forgot to zero the original.
  BuBytes takeBytes({bool immutable = false}) {
    _checkAlive();
    final plain = List<int>.generate(
      _length,
      (i) => _transform.reveal(i, _transformed[i], _state),
    );
    zero();
    return BuBytes._(plain, isImmutable: immutable, isOwned: true);
  }

  /// Splits this secret into two new `SecretBytes` at [index]: bytes
  /// `[0, index)` become the left half, `[index, length)` the right.
  /// Built for BIP32-style derivation — an HMAC-SHA512 output split into
  /// a key half and a chain-code half, each then handled as its own
  /// secret. The intermediate combined plaintext only ever exists inside
  /// one `useValue` scope and is wiped before this returns.
  ///
  /// Pass `consume: true` to also zero *this* instance once both halves
  /// are built — typical when the combined buffer was only ever an
  /// intermediate value with no further use.
  (SecretBytes, SecretBytes) splitAt(
    int index, {
    SecretTransform? leftTransform,
    SecretTransform? rightTransform,
    bool consume = false,
  }) {
    _checkAlive();
    RangeError.checkValidRange(0, index, _length);
    return useValue((plain) {
      final left = SecretBytes.take(
        plain.sublist(0, index),
        transform: leftTransform ?? _transform,
      );
      final right = SecretBytes.take(
        plain.sublist(index),
        transform: rightTransform ?? _transform,
      );
      return (left, right);
    }, zero: consume);
  }

  /// Combines this secret with [other] into one new `SecretBytes` (this
  /// instance's bytes first, then `other`'s) — e.g. building KDF input
  /// from multiple secret pieces. Both sides' plaintext exist only
  /// inside these nested `useValue` scopes and are wiped once the
  /// combined `SecretBytes` is built.
  SecretBytes concat(SecretBytes other, {SecretTransform? transform}) {
    _checkAlive();
    return useValue(
      (a) => other.useValue(
        (b) =>
            SecretBytes.take([...a, ...b], transform: transform ?? _transform),
      ),
    );
  }

  /// Constant-time-compares against another `SecretBytes` without either
  /// side ever being materialized into a plain array — reads flow
  /// through both instances' `[]` (and both transforms) on the fly.
  /// (Note: your existing static `constantTimeEquals(a, b)` already
  /// works fine if you pass two `SecretBytes` directly, since `List<int>`
  /// iteration calls `[]` — this is just a more discoverable name for
  /// that same safe path, for callers who'd otherwise reach for
  /// `toBytes()` first out of habit.)
  bool constantTimeEqualsSecret(SecretBytes other) =>
      constantTimeEquals(this, other);
}

/// Finalizer token for [SecretBytes]: owns the wipe-only references
/// (obscured bytes + transform state), never the owner, so the callback
/// cannot resurrect the secret. [zero] is idempotent and detach-safe.
class _ZeroToken {
  /// Creates a token over the owner's wipe-only state.
  _ZeroToken(this.transformed, this.state, this.transform);

  /// Obscured bytes of the (possibly dead) owner.
  final List<int> transformed;

  /// Transform state of the (possibly dead) owner.
  final List<int> state;

  /// Transform whose [SecretTransform.wipeState] destroys [state].
  final SecretTransform transform;

  /// Wipes [transformed] and [state]. Safe to call twice.
  void zero() {
    for (var i = 0; i < transformed.length; i++) {
      transformed[i] = 0;
    }
    transform.wipeState(state);
  }
}

/// Opt-in disposal for wrappers around long-lived native handles
/// (hash contexts, AES contexts, params/proving keys).
///
/// The `native_*` wrappers implement this via explicit `clean()` plus a
/// [Finalizer] safety net, so forgetting `dispose()` still releases the
/// native allocation (best-effort on GC timing) without double-free.
abstract mixin class SecretState {
  /// Releases the native allocation and wipes owned key material.
  /// Idempotent: safe to call twice.
  void dispose();
}
