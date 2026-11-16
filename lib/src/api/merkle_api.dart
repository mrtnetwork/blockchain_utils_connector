import 'package:blockchain_utils_connector/src/bytes/bytes.dart';
import 'package:blockchain_utils_connector/src/error/bu_error.dart';

/// Frontier-model Merkle contexts (Sapling + Orchard wallet sync).
///
/// Model notes (mirror the Rust core docs): leaves append in order; subtrees
/// must be level-16 aligned at the tip; checkpoints cap at 100 (oldest
/// evicted); witnesses replay the leaf log; positions inside absorbed history
/// are unwitnessable.
abstract interface class BuMerkleApi {
  /// Sapling protocol tree.
  static const int sapling = 0;

  /// Orchard protocol tree.
  static const int orchard = 1;

  /// Ironwood pool (NU6.3 second slot): separate frontier sharing the
  /// Orchard node/hash type.
  static const int ironwood = 2;

  /// Create an empty wallet context. Returns 0 on internal error.
  BuResult<int> createContext();

  /// Drop a context.
  BuResult<void> closeContext(int id);

  /// Export a context blob (restorable via [insertChainState]).
  BuResult<BuBytes> getContext(int id);

  /// Restore a context from an exported blob (replaces state).
  BuResult<void> insertChainState(int id, {required List<int> blob});

  /// Append n = len/32 leaves to a protocol tree.
  BuResult<void> updateState(
    int id, {
    required int kind,
    required List<int> leaves,
  });

  /// Absorb one level-16 subtree root at [start] (must equal current size).
  BuResult<void> updateSubtree(
    int id, {
    required int kind,
    required int start,
    required BuBytes root32,
  });

  /// Merge checkpoints + contiguous subtrees from an exported merge blob.
  BuResult<void> mergeState(
    int id, {
    required int kind,
    required List<int> blob,
  });

  /// Snapshot both trees under [checkpoint] (evicts oldest beyond cap).
  BuResult<void> checkpoint(int id, int checkpointId);

  /// Witness [positions] at [checkpointId].
  BuResult<BuMerkleWitness> createWitness(
    int id, {
    required int kind,
    required int checkpointId,
    required List<int> positions,
  });
}

/// Merkle witness: shared anchor + per-position paths.
class BuMerkleWitness {
  const BuMerkleWitness({required this.anchor, required this.paths});
  final BuBytes anchor;
  final List<BuMerklePath> paths;
}

/// One witness path: leaf position + 32 sibling limbs (32 bytes each).
class BuMerklePath {
  const BuMerklePath({required this.position, required this.limbs});
  final int position;
  final BuBytes limbs;
}
