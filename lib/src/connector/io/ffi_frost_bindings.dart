// ignore_for_file: library_private_types_in_public_api
// FFI typedefs are internal (never exported from blockchain_utils_connector.dart).
import 'dart:ffi' as ffi;

class BuFrostFfi {
  BuFrostFfi._({
    required this.k1Shard,
    required this.k1Combine,
    required this.k1PrepareShares,
    required this.k1GroupFromMembers,
    required this.k1VssCommit,
    required this.k1VssVerify,
    required this.k1GroupInfo,
    required this.k1Commit,
    required this.k1BindingFactors,
    required this.k1GroupCommitment,
    required this.k1Sign,
    required this.k1Aggregate,
    required this.k1VerifyShare,
    required this.k1Verify,
    required this.edShard,
    required this.edCombine,
    required this.edPrepareShares,
    required this.edGroupFromMembers,
    required this.edVssCommit,
    required this.edVssVerify,
    required this.edGroupInfo,
    required this.edCommit,
    required this.edBindingFactors,
    required this.edGroupCommitment,
    required this.edSign,
    required this.edAggregate,
    required this.edVerifyShare,
    required this.edVerify,
    required this.k1Reshare,
    required this.edReshare,
  });

  factory BuFrostFfi(ffi.DynamicLibrary lib) {
    return BuFrostFfi._(
      k1Shard: lib.lookupFunction<_ShardN, _ShardD>('bu_frost_k1_shard'),
      k1Combine: lib.lookupFunction<_CombineN, _CombineD>(
        'bu_frost_k1_combine',
      ),
      k1PrepareShares: lib.lookupFunction<_PrepareN, _PrepareD>(
        'bu_frost_k1_prepare_shares',
      ),
      k1GroupFromMembers: lib.lookupFunction<_GroupMembersN, _GroupMembersD>(
        'bu_frost_k1_group_from_members',
      ),
      k1VssCommit: lib.lookupFunction<_VssCommitN, _VssCommitD>(
        'bu_frost_k1_vss_commit',
      ),
      k1VssVerify: lib.lookupFunction<_VssVerifyN, _VssVerifyD>(
        'bu_frost_k1_vss_verify',
      ),
      k1GroupInfo: lib.lookupFunction<_GroupInfoN, _GroupInfoD>(
        'bu_frost_k1_group_info',
      ),
      k1Commit: lib.lookupFunction<_CommitN, _CommitD>('bu_frost_k1_commit'),
      k1BindingFactors: lib.lookupFunction<_BindingFactorsN, _BindingFactorsD>(
        'bu_frost_k1_binding_factors',
      ),
      k1GroupCommitment: lib
          .lookupFunction<_GroupCommitmentN, _GroupCommitmentD>(
            'bu_frost_k1_group_commitment',
          ),
      k1Sign: lib.lookupFunction<_SignN, _SignD>('bu_frost_k1_sign'),
      k1Aggregate: lib.lookupFunction<_AggregateN, _AggregateD>(
        'bu_frost_k1_aggregate',
      ),
      k1VerifyShare: lib.lookupFunction<_VerifyShareN, _VerifyShareD>(
        'bu_frost_k1_verify_share',
      ),
      k1Verify: lib.lookupFunction<_VerifyN, _VerifyD>('bu_frost_k1_verify'),
      edShard: lib.lookupFunction<_EdShardN, _EdShardD>('bu_frost_ed_shard'),
      edCombine: lib.lookupFunction<_EdCombineN, _EdCombineD>(
        'bu_frost_ed_combine',
      ),
      edPrepareShares: lib.lookupFunction<_EdPrepareN, _EdPrepareD>(
        'bu_frost_ed_prepare_shares',
      ),
      edGroupFromMembers: lib.lookupFunction<_GroupMembersN, _GroupMembersD>(
        'bu_frost_ed_group_from_members',
      ),
      edVssCommit: lib.lookupFunction<_EdVssCommitN, _EdVssCommitD>(
        'bu_frost_ed_vss_commit',
      ),
      edVssVerify: lib.lookupFunction<_EdVssVerifyN, _EdVssVerifyD>(
        'bu_frost_ed_vss_verify',
      ),
      edGroupInfo: lib.lookupFunction<_GroupInfoN, _GroupInfoD>(
        'bu_frost_ed_group_info',
      ),
      edCommit: lib.lookupFunction<_EdCommitN, _EdCommitD>(
        'bu_frost_ed_commit',
      ),
      edBindingFactors: lib.lookupFunction<_BindingFactorsN, _BindingFactorsD>(
        'bu_frost_ed_binding_factors',
      ),
      edGroupCommitment: lib
          .lookupFunction<_GroupCommitmentN, _GroupCommitmentD>(
            'bu_frost_ed_group_commitment',
          ),
      edSign: lib.lookupFunction<_EdSignN, _EdSignD>('bu_frost_ed_sign'),
      edAggregate: lib.lookupFunction<_AggregateN, _AggregateD>(
        'bu_frost_ed_aggregate',
      ),
      edVerifyShare: lib.lookupFunction<_VerifyShareN, _VerifyShareD>(
        'bu_frost_ed_verify_share',
      ),
      edVerify: lib.lookupFunction<_VerifyN, _VerifyD>('bu_frost_ed_verify'),
      k1Reshare: lib.lookupFunction<_ReshareN, _ReshareD>(
        'bu_frost_k1_reshare',
      ),
      edReshare: lib.lookupFunction<_ReshareN, _ReshareD>(
        'bu_frost_ed_reshare',
      ),
    );
  }

  final _ShardD k1Shard;
  final _CombineD k1Combine;
  final _PrepareD k1PrepareShares;
  final _GroupMembersD k1GroupFromMembers;
  final _VssCommitD k1VssCommit;
  final _VssVerifyD k1VssVerify;
  final _GroupInfoD k1GroupInfo;
  final _CommitD k1Commit;
  final _BindingFactorsD k1BindingFactors;
  final _GroupCommitmentD k1GroupCommitment;
  final _SignD k1Sign;
  final _AggregateD k1Aggregate;
  final _VerifyShareD k1VerifyShare;
  final _VerifyD k1Verify;
  final _EdShardD edShard;
  final _EdCombineD edCombine;
  final _EdPrepareD edPrepareShares;
  final _GroupMembersD edGroupFromMembers;
  final _EdVssCommitD edVssCommit;
  final _EdVssVerifyD edVssVerify;
  final _GroupInfoD edGroupInfo;
  final _EdCommitD edCommit;
  final _BindingFactorsD edBindingFactors;
  final _GroupCommitmentD edGroupCommitment;
  final _EdSignD edSign;
  final _AggregateD edAggregate;
  final _VerifyShareD edVerifyShare;
  final _VerifyD edVerify;
  final _ReshareD k1Reshare;
  final _ReshareD edReshare;
}

typedef _ShardN =
    ffi.Int32 Function(
      ffi.Pointer<ffi.Uint8>,
      ffi.Pointer<ffi.Uint8>,
      ffi.Size,
      ffi.Uint16,
      ffi.Pointer<ffi.Uint8>,
      ffi.Size,
      ffi.Pointer<ffi.Uint8>,
      ffi.Size,
    );
typedef _ShardD =
    int Function(
      ffi.Pointer<ffi.Uint8>,
      ffi.Pointer<ffi.Uint8>,
      int,
      int,
      ffi.Pointer<ffi.Uint8>,
      int,
      ffi.Pointer<ffi.Uint8>,
      int,
    );

typedef _CombineN =
    ffi.Int32 Function(
      ffi.Pointer<ffi.Uint8>,
      ffi.Size,
      ffi.Pointer<ffi.Uint8>,
      ffi.Size,
    );
typedef _CombineD =
    int Function(ffi.Pointer<ffi.Uint8>, int, ffi.Pointer<ffi.Uint8>, int);

typedef _VssCommitN =
    ffi.Int32 Function(
      ffi.Pointer<ffi.Uint8>,
      ffi.Size,
      ffi.Pointer<ffi.Uint8>,
      ffi.Size,
    );
typedef _VssCommitD =
    int Function(ffi.Pointer<ffi.Uint8>, int, ffi.Pointer<ffi.Uint8>, int);

typedef _VssVerifyN =
    ffi.Int32 Function(
      ffi.Uint32,
      ffi.Pointer<ffi.Uint8>,
      ffi.Pointer<ffi.Uint8>,
      ffi.Size,
    );
typedef _VssVerifyD =
    int Function(int, ffi.Pointer<ffi.Uint8>, ffi.Pointer<ffi.Uint8>, int);

typedef _GroupInfoN =
    ffi.Int32 Function(
      ffi.Pointer<ffi.Uint8>,
      ffi.Size,
      ffi.Uint16,
      ffi.Pointer<ffi.Uint8>,
      ffi.Pointer<ffi.Uint8>,
      ffi.Size,
    );
typedef _GroupInfoD =
    int Function(
      ffi.Pointer<ffi.Uint8>,
      int,
      int,
      ffi.Pointer<ffi.Uint8>,
      ffi.Pointer<ffi.Uint8>,
      int,
    );

typedef _CommitN =
    ffi.Int32 Function(
      ffi.Pointer<ffi.Uint8>,
      ffi.Pointer<ffi.Uint8>,
      ffi.Pointer<ffi.Uint8>,
      ffi.Pointer<ffi.Uint8>,
      ffi.Pointer<ffi.Uint8>,
      ffi.Pointer<ffi.Uint8>,
      ffi.Pointer<ffi.Uint8>,
    );
typedef _CommitD =
    int Function(
      ffi.Pointer<ffi.Uint8>,
      ffi.Pointer<ffi.Uint8>,
      ffi.Pointer<ffi.Uint8>,
      ffi.Pointer<ffi.Uint8>,
      ffi.Pointer<ffi.Uint8>,
      ffi.Pointer<ffi.Uint8>,
      ffi.Pointer<ffi.Uint8>,
    );

typedef _BindingFactorsN =
    ffi.Int32 Function(
      ffi.Pointer<ffi.Uint8>,
      ffi.Pointer<ffi.Uint8>,
      ffi.Size,
      ffi.Pointer<ffi.Uint8>,
      ffi.Size,
      ffi.Pointer<ffi.Uint8>,
      ffi.Size,
    );
typedef _BindingFactorsD =
    int Function(
      ffi.Pointer<ffi.Uint8>,
      ffi.Pointer<ffi.Uint8>,
      int,
      ffi.Pointer<ffi.Uint8>,
      int,
      ffi.Pointer<ffi.Uint8>,
      int,
    );

typedef _GroupCommitmentN =
    ffi.Int32 Function(
      ffi.Pointer<ffi.Uint8>,
      ffi.Pointer<ffi.Uint8>,
      ffi.Size,
      ffi.Pointer<ffi.Uint8>,
      ffi.Size,
    );
typedef _GroupCommitmentD =
    int Function(
      ffi.Pointer<ffi.Uint8>,
      ffi.Pointer<ffi.Uint8>,
      int,
      ffi.Pointer<ffi.Uint8>,
      int,
    );

typedef _SignN =
    ffi.Int32 Function(
      ffi.Uint32,
      ffi.Pointer<ffi.Uint8>,
      ffi.Pointer<ffi.Uint8>,
      ffi.Pointer<ffi.Uint8>,
      ffi.Pointer<ffi.Uint8>,
      ffi.Pointer<ffi.Uint8>,
      ffi.Pointer<ffi.Uint8>,
      ffi.Pointer<ffi.Uint8>,
      ffi.Size,
      ffi.Pointer<ffi.Uint8>,
      ffi.Size,
      ffi.Pointer<ffi.Uint8>,
      ffi.Size,
    );
typedef _SignD =
    int Function(
      int,
      ffi.Pointer<ffi.Uint8>,
      ffi.Pointer<ffi.Uint8>,
      ffi.Pointer<ffi.Uint8>,
      ffi.Pointer<ffi.Uint8>,
      ffi.Pointer<ffi.Uint8>,
      ffi.Pointer<ffi.Uint8>,
      ffi.Pointer<ffi.Uint8>,
      int,
      ffi.Pointer<ffi.Uint8>,
      int,
      ffi.Pointer<ffi.Uint8>,
      int,
    );

typedef _AggregateN =
    ffi.Int32 Function(
      ffi.Pointer<ffi.Uint8>,
      ffi.Size,
      ffi.Pointer<ffi.Uint8>,
      ffi.Size,
      ffi.Pointer<ffi.Uint8>,
      ffi.Pointer<ffi.Uint8>,
      ffi.Size,
      ffi.Pointer<ffi.Uint8>,
      ffi.Pointer<ffi.Uint8>,
    );
typedef _AggregateD =
    int Function(
      ffi.Pointer<ffi.Uint8>,
      int,
      ffi.Pointer<ffi.Uint8>,
      int,
      ffi.Pointer<ffi.Uint8>,
      ffi.Pointer<ffi.Uint8>,
      int,
      ffi.Pointer<ffi.Uint8>,
      ffi.Pointer<ffi.Uint8>,
    );

typedef _VerifyShareN =
    ffi.Int32 Function(
      ffi.Uint32,
      ffi.Pointer<ffi.Uint8>,
      ffi.Pointer<ffi.Uint8>,
      ffi.Pointer<ffi.Uint8>,
      ffi.Pointer<ffi.Uint8>,
      ffi.Size,
      ffi.Pointer<ffi.Uint8>,
      ffi.Pointer<ffi.Uint8>,
      ffi.Size,
    );
typedef _VerifyShareD =
    int Function(
      int,
      ffi.Pointer<ffi.Uint8>,
      ffi.Pointer<ffi.Uint8>,
      ffi.Pointer<ffi.Uint8>,
      ffi.Pointer<ffi.Uint8>,
      int,
      ffi.Pointer<ffi.Uint8>,
      ffi.Pointer<ffi.Uint8>,
      int,
    );

typedef _VerifyN =
    ffi.Int32 Function(
      ffi.Pointer<ffi.Uint8>,
      ffi.Pointer<ffi.Uint8>,
      ffi.Pointer<ffi.Uint8>,
      ffi.Pointer<ffi.Uint8>,
      ffi.Size,
    );
typedef _VerifyD =
    int Function(
      ffi.Pointer<ffi.Uint8>,
      ffi.Pointer<ffi.Uint8>,
      ffi.Pointer<ffi.Uint8>,
      ffi.Pointer<ffi.Uint8>,
      int,
    );

// Signing-share preparation: `shares(n*36)` + threshold u16 → `out(n*32)`.
// Ed variant appends trailing `is_scalar: u8`.
typedef _PrepareN =
    ffi.Int32 Function(
      ffi.Pointer<ffi.Uint8>,
      ffi.Size,
      ffi.Uint16,
      ffi.Pointer<ffi.Uint8>,
      ffi.Size,
    );
typedef _PrepareD =
    int Function(ffi.Pointer<ffi.Uint8>, int, int, ffi.Pointer<ffi.Uint8>, int);

typedef _EdPrepareN =
    ffi.Int32 Function(
      ffi.Pointer<ffi.Uint8>,
      ffi.Size,
      ffi.Uint16,
      ffi.Uint8,
      ffi.Pointer<ffi.Uint8>,
      ffi.Size,
    );
typedef _EdPrepareD =
    int Function(
      ffi.Pointer<ffi.Uint8>,
      int,
      int,
      int,
      ffi.Pointer<ffi.Uint8>,
      int,
    );

// Group key from member points: `ids(n*4 u32LE)` + `pubs(n*elen)` +
// threshold u16 → `group(elen)`. Same shape for both suites.
typedef _GroupMembersN =
    ffi.Int32 Function(
      ffi.Pointer<ffi.Uint8>,
      ffi.Pointer<ffi.Uint8>,
      ffi.Size,
      ffi.Uint16,
      ffi.Pointer<ffi.Uint8>,
      ffi.Size,
    );
typedef _GroupMembersD =
    int Function(
      ffi.Pointer<ffi.Uint8>,
      ffi.Pointer<ffi.Uint8>,
      int,
      int,
      ffi.Pointer<ffi.Uint8>,
      int,
    );

// Reshare: `ids(n*4 u32LE)` + `secrets(n*32)` + n + `coeffs(nCoeffs*32)` +
// nCoeffs + threshold u16 → `shares(n*32)` + `pubs(n*elen)` + `group(elen)`.
// Same shape for both suites.
typedef _ReshareN =
    ffi.Int32 Function(
      ffi.Pointer<ffi.Uint8>,
      ffi.Pointer<ffi.Uint8>,
      ffi.Size,
      ffi.Pointer<ffi.Uint8>,
      ffi.Size,
      ffi.Uint16,
      ffi.Pointer<ffi.Uint8>,
      ffi.Size,
      ffi.Pointer<ffi.Uint8>,
      ffi.Size,
      ffi.Pointer<ffi.Uint8>,
      ffi.Size,
    );
typedef _ReshareD =
    int Function(
      ffi.Pointer<ffi.Uint8>,
      ffi.Pointer<ffi.Uint8>,
      int,
      ffi.Pointer<ffi.Uint8>,
      int,
      int,
      ffi.Pointer<ffi.Uint8>,
      int,
      ffi.Pointer<ffi.Uint8>,
      int,
      ffi.Pointer<ffi.Uint8>,
      int,
    );

// Ed25519 secret-input entry points take a trailing `is_scalar: u8`
// (`1` = canonical scalar, `0` = RFC 8032 seed).
typedef _EdShardN =
    ffi.Int32 Function(
      ffi.Pointer<ffi.Uint8>,
      ffi.Pointer<ffi.Uint8>,
      ffi.Size,
      ffi.Uint16,
      ffi.Pointer<ffi.Uint8>,
      ffi.Size,
      ffi.Pointer<ffi.Uint8>,
      ffi.Size,
      ffi.Uint8,
    );
typedef _EdShardD =
    int Function(
      ffi.Pointer<ffi.Uint8>,
      ffi.Pointer<ffi.Uint8>,
      int,
      int,
      ffi.Pointer<ffi.Uint8>,
      int,
      ffi.Pointer<ffi.Uint8>,
      int,
      int,
    );

typedef _EdCombineN =
    ffi.Int32 Function(
      ffi.Pointer<ffi.Uint8>,
      ffi.Size,
      ffi.Pointer<ffi.Uint8>,
      ffi.Size,
      ffi.Uint8,
    );
typedef _EdCombineD =
    int Function(ffi.Pointer<ffi.Uint8>, int, ffi.Pointer<ffi.Uint8>, int, int);

typedef _EdVssCommitN =
    ffi.Int32 Function(
      ffi.Pointer<ffi.Uint8>,
      ffi.Size,
      ffi.Pointer<ffi.Uint8>,
      ffi.Size,
      ffi.Uint8,
    );
typedef _EdVssCommitD =
    int Function(ffi.Pointer<ffi.Uint8>, int, ffi.Pointer<ffi.Uint8>, int, int);

typedef _EdVssVerifyN =
    ffi.Int32 Function(
      ffi.Uint32,
      ffi.Pointer<ffi.Uint8>,
      ffi.Pointer<ffi.Uint8>,
      ffi.Size,
      ffi.Uint8,
    );
typedef _EdVssVerifyD =
    int Function(int, ffi.Pointer<ffi.Uint8>, ffi.Pointer<ffi.Uint8>, int, int);

typedef _EdCommitN =
    ffi.Int32 Function(
      ffi.Pointer<ffi.Uint8>,
      ffi.Pointer<ffi.Uint8>,
      ffi.Pointer<ffi.Uint8>,
      ffi.Pointer<ffi.Uint8>,
      ffi.Pointer<ffi.Uint8>,
      ffi.Pointer<ffi.Uint8>,
      ffi.Pointer<ffi.Uint8>,
      ffi.Uint8,
    );
typedef _EdCommitD =
    int Function(
      ffi.Pointer<ffi.Uint8>,
      ffi.Pointer<ffi.Uint8>,
      ffi.Pointer<ffi.Uint8>,
      ffi.Pointer<ffi.Uint8>,
      ffi.Pointer<ffi.Uint8>,
      ffi.Pointer<ffi.Uint8>,
      ffi.Pointer<ffi.Uint8>,
      int,
    );

typedef _EdSignN =
    ffi.Int32 Function(
      ffi.Uint32,
      ffi.Pointer<ffi.Uint8>,
      ffi.Pointer<ffi.Uint8>,
      ffi.Pointer<ffi.Uint8>,
      ffi.Pointer<ffi.Uint8>,
      ffi.Pointer<ffi.Uint8>,
      ffi.Pointer<ffi.Uint8>,
      ffi.Pointer<ffi.Uint8>,
      ffi.Size,
      ffi.Pointer<ffi.Uint8>,
      ffi.Size,
      ffi.Pointer<ffi.Uint8>,
      ffi.Size,
      ffi.Uint8,
    );
typedef _EdSignD =
    int Function(
      int,
      ffi.Pointer<ffi.Uint8>,
      ffi.Pointer<ffi.Uint8>,
      ffi.Pointer<ffi.Uint8>,
      ffi.Pointer<ffi.Uint8>,
      ffi.Pointer<ffi.Uint8>,
      ffi.Pointer<ffi.Uint8>,
      ffi.Pointer<ffi.Uint8>,
      int,
      ffi.Pointer<ffi.Uint8>,
      int,
      ffi.Pointer<ffi.Uint8>,
      int,
      int,
    );
