import 'package:blockchain_utils_connector/src/api/merkle_api.dart';
import 'package:blockchain_utils_connector/src/bytes/bytes.dart';
import 'package:blockchain_utils_connector/src/error/bu_error.dart';
import 'package:blockchain_utils_connector/src/platform/bindings.dart';

class DefaultMerkleApi implements BuMerkleApi {
  DefaultMerkleApi(this._b);
  final BuPlatformBindings _b;
  static const _tag = 'merkle';

  static const _depth = 32;
  static const _pathLen = 8 + _depth * 32;

  static BuError _map(int rc) => BuError.fromNativeCode(switch (rc) {
    // Global ZK codes: 0 ok, 1 key, 2 encoding, 3 input, 4 proof,
    // 5 witness, 6 merkle, 7 internal, 8 missing, 9 hash.
    // 0 is unreachable: callers check rc != 0 first.
    0 => 7,
    1 => 2,
    2 => 12,
    3 => 10,
    4 => 14,
    5 => 8,
    6 => 7,
    7 => 7,
    8 => 11,
    9 => 7,
    _ => rc,
  });

  BuBytes _as(List<int> x) => BuBytes.from(x);

  bool _badKind(int k) =>
      k != BuMerkleApi.sapling &&
      k != BuMerkleApi.orchard &&
      k != BuMerkleApi.ironwood;

  @override
  BuResult<int> createContext() {
    final id = _b.merkleCreateContext();
    if (id == 0) {
      return BuResult.err(
        BuError(DefaultErrorType.internal, '$_tag.createContext'),
      );
    }
    return BuResult.ok(id);
  }

  @override
  BuResult<void> closeContext(int id) {
    final rc = _b.merkleCloseContext(id);
    if (rc != 0) {
      return BuResult.err(_map(rc));
    }
    return BuResult.ok(null);
  }

  @override
  BuResult<BuBytes> getContext(int id) {
    final out = <BuBytes>[];
    final rc = _b.merkleGetContext(id, out);
    if (rc != 0 || out.isEmpty) {
      return BuResult.err(_map(rc));
    }
    return BuResult.ok(out[0]);
  }

  @override
  BuResult<void> insertChainState(int id, {required List<int> blob}) {
    if (blob.isEmpty) {
      return BuResult.err(BuError.invalidArgument);
    }
    final rc = _b.merkleInsertChainState(id, _as(blob));
    if (rc != 0) {
      return BuResult.err(_map(rc));
    }
    return BuResult.ok(null);
  }

  @override
  BuResult<void> updateState(
    int id, {
    required int kind,
    required List<int> leaves,
  }) {
    if (_badKind(kind)) return BuResult.err(BuError.invalidArgument);
    if (leaves.isEmpty || leaves.length % 32 != 0) {
      return BuResult.err(
        BuError.length(what: 'leaves', expected: 32, actual: leaves.length),
      );
    }
    final rc = _b.merkleUpdateState(id, kind, _as(leaves));
    if (rc != 0) {
      return BuResult.err(_map(rc));
    }
    return BuResult.ok(null);
  }

  @override
  BuResult<void> updateSubtree(
    int id, {
    required int kind,
    required int start,
    required BuBytes root32,
  }) {
    if (_badKind(kind)) return BuResult.err(BuError.invalidArgument);
    if (root32.length != 32 || start < 0) {
      return BuResult.err(BuError.invalidArgument);
    }
    final rc = _b.merkleUpdateSubtree(id, kind, start, root32);
    if (rc != 0) {
      return BuResult.err(_map(rc));
    }
    return BuResult.ok(null);
  }

  @override
  BuResult<void> mergeState(
    int id, {
    required int kind,
    required List<int> blob,
  }) {
    if (_badKind(kind)) return BuResult.err(BuError.invalidArgument);
    if (blob.isEmpty) {
      return BuResult.err(BuError.invalidArgument);
    }
    final rc = _b.merkleMergeState(id, kind, _as(blob));
    if (rc != 0) {
      return BuResult.err(_map(rc));
    }
    return BuResult.ok(null);
  }

  @override
  BuResult<void> checkpoint(int id, int checkpointId) {
    if (checkpointId < 0) {
      return BuResult.err(BuError.invalidArgument);
    }
    final rc = _b.merkleCheckpoint(id, checkpointId);
    if (rc != 0) {
      return BuResult.err(_map(rc));
    }
    return BuResult.ok(null);
  }

  @override
  BuResult<BuMerkleWitness> createWitness(
    int id, {
    required int kind,
    required int checkpointId,
    required List<int> positions,
  }) {
    if (_badKind(kind)) return BuResult.err(BuError.invalidArgument);
    if (positions.isEmpty) {
      return BuResult.err(BuError.invalidArgument);
    }
    final packed = BuBytes.zero(positions.length * 8);
    for (var i = 0; i < positions.length; i++) {
      final p = positions[i];
      if (p < 0) {
        return BuResult.err(BuError.invalidArgument);
      }
      for (var j = 0; j < 8; j++) {
        packed[i * 8 + j] = (p >> (8 * j)) & 0xff;
      }
    }
    final out = <BuBytes>[];
    final rc = _b.merkleCreateWitness(id, kind, checkpointId, packed, out);
    if (rc != 0 || out.isEmpty) {
      return BuResult.err(_map(rc));
    }
    return _parseWitness(out[0], positions.length);
  }

  BuResult<BuMerkleWitness> _parseWitness(BuBytes raw, int npos) {
    if (raw.length < 36) {
      return BuResult.err(
        BuError.length(
          what: 'witness',
          expected: 36 + npos * _pathLen,
          actual: raw.length,
        ),
      );
    }
    final anchor = BuBytes(List<int>.from(raw.sublist(0, 32)));
    final npaths = raw[32] | (raw[33] << 8) | (raw[34] << 16) | (raw[35] << 24);
    if (npaths != npos || raw.length != 36 + npaths * _pathLen) {
      return BuResult.err(
        BuError.length(what: 'witness.paths', expected: npos, actual: npaths),
      );
    }
    final paths = <BuMerklePath>[];
    var off = 36;
    for (var i = 0; i < npaths; i++) {
      // Exact u64 decode on VM and web (see solana LE64 note).
      var posLo = 0;
      var posHi = 0;
      for (var j = 0; j < 4; j++) {
        posLo += (raw[off + j] & 0xFF) * (1 << (8 * j));
        posHi += (raw[off + 4 + j] & 0xFF) * (1 << (8 * j));
      }
      final pos = posLo + posHi * 0x100000000;
      final limbs = BuBytes(
        List<int>.from(raw.sublist(off + 8, off + _pathLen)),
      );
      paths.add(BuMerklePath(position: pos, limbs: limbs));
      off += _pathLen;
    }
    return BuResult.ok(BuMerkleWitness(anchor: anchor, paths: paths));
  }
}
