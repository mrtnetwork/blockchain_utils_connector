import 'package:blockchain_utils_connector/src/api/solana_zk_api.dart';
import 'package:blockchain_utils_connector/src/bytes/bytes.dart';
import 'package:blockchain_utils_connector/src/error/bu_error.dart';
import 'package:blockchain_utils_connector/src/platform/bindings.dart';

///  Solana ZK backend over [BuPlatformBindings] (FFI native or
/// WASM). All proofs verify on-chain: fixed instruction transcripts live in
/// Rust, so callers cannot pick a wrong context.
class DefaultSolanaZkApi implements BuSolanaZkApi {
  ///  Create with platform bindings.
  DefaultSolanaZkApi(this._b);
  final BuPlatformBindings _b;
  BuBytes _as(List<int> x) => BuBytes.from(x);

  static BuError _map(int rc) => BuError.fromNativeCode(switch (rc) {
    // Rust BU_SOLANA_ZK_*: 0 ok, 1 invalid-equation, -1 null, -2 length,
    // -3 parse, -4 crypto, -5 internal, -6 backend-not-linked.
    // 0 is unreachable: callers check rc first.
    0 => 7,
    1 => 14,
    -1 => 1,
    -2 => 9,
    -3 => 4,
    -4 => 10,
    -6 => 6,
    _ => 7,
  });

  BuResult<BuBytes> _fixed(int rc, BuBytes out, String ctx) {
    if (rc == 0) {
      return BuResult.ok(out);
    }
    if (rc == -6) {
      return BuResult.err(
        BuError(
          DefaultErrorType.unsupported,
          'solana_zk.$ctx: native backend not linked',
        ),
      );
    }
    return BuResult.err(_map(rc));
  }

  BuResult<bool> _verdict(int rc, String ctx) {
    if (rc == 0) {
      return BuResult.ok(true);
    }
    if (rc == 1) {
      return BuResult.ok(false);
    }
    if (rc == -6) {
      return BuResult.err(
        BuError(
          DefaultErrorType.unsupported,
          'solana_zk.$ctx: native backend not linked',
        ),
      );
    }
    return BuResult.err(_map(rc));
  }

  @override
  BuResult<bool> validatePubkey(List<int> pubkey) =>
      _verdict(_b.solanaZkValidatePubkey(_as(pubkey)), 'validatePubkey');

  @override
  BuResult<bool> validateCiphertext(List<int> ciphertext) => _verdict(
    _b.solanaZkValidateCiphertext(_as(ciphertext)),
    'validateCiphertext',
  );

  @override
  BuResult<bool> validateAe(List<int> ae) =>
      _verdict(_b.solanaZkValidateAe(_as(ae)), 'validateAe');

  @override
  BuResult<BuBytes> aeEncrypt({
    required List<int> key16,
    required int amount,
    required List<int> nonce12,
  }) {
    final out = BuBytes.zero(36);
    return _fixed(
      _b.solanaZkAeEncrypt(_as(key16), amount, _as(nonce12), out),
      out,
      'aeEncrypt',
    );
  }

  @override
  BuResult<int> aeDecrypt({required List<int> key16, required List<int> ae}) {
    final out = BuBytes.zero(8);
    final rc = _b.solanaZkAeDecrypt(_as(key16), _as(ae), out);
    if (rc == 0) {
      // Exact on VM (64-bit) and web (f64 < 2^53): `<<` with counts >= 32
      // is a 32-bit op in JS and would truncate, so use multiplication.
      var lo = 0;
      var hi = 0;
      for (var i = 0; i < 4; i++) {
        lo += (out[i] & 0xFF) * (1 << (8 * i));
        hi += (out[i + 4] & 0xFF) * (1 << (8 * i));
      }
      return BuResult.ok(lo + hi * 0x100000000);
    }
    if (rc == -6) {
      return BuResult.err(
        BuError(
          DefaultErrorType.unsupported,
          'solana_zk.aeDecrypt: native backend not linked',
        ),
      );
    }
    return BuResult.err(_map(rc));
  }

  @override
  BuResult<BuBytes> pubkeyFromSecret(List<int> secret) {
    final out = BuBytes.zero(32);
    return _fixed(
      _b.solanaZkPubkeyFromSecret(_as(secret), out),
      out,
      'pubkeyFromSecret',
    );
  }

  @override
  BuResult<BuBytes> encryptWith({
    required List<int> pubkey,
    required int amount,
    required List<int> opening,
  }) {
    final out = BuBytes.zero(64);
    return _fixed(
      _b.solanaZkEncryptWith(_as(pubkey), amount, _as(opening), out),
      out,
      'encryptWith',
    );
  }

  @override
  BuResult<int> decryptU32({
    required List<int> secret,
    required List<int> ciphertext,
  }) {
    final out = BuBytes.zero(8);
    final rc = _b.solanaZkDecryptU32(_as(secret), _as(ciphertext), out);
    if (rc == 0) {
      // Exact on VM (64-bit) and web (f64 < 2^53): `<<` with counts >= 32
      // is a 32-bit op in JS and would truncate, so use multiplication.
      var lo = 0;
      var hi = 0;
      for (var i = 0; i < 4; i++) {
        lo += (out[i] & 0xFF) * (1 << (8 * i));
        hi += (out[i + 4] & 0xFF) * (1 << (8 * i));
      }
      return BuResult.ok(lo + hi * 0x100000000);
    }
    if (rc == -6) {
      return BuResult.err(
        BuError(
          DefaultErrorType.unsupported,
          'solana_zk.decryptU32: native backend not linked',
        ),
      );
    }
    return BuResult.err(_map(rc));
  }

  @override
  BuResult<BuBytes> provePubkeyValidity({
    required List<int> secret,
    required List<int> seed32,
  }) {
    final out = BuBytes.zero(64);
    return _fixed(
      _b.solanaZkProvePubkeyValidity(_as(secret), _as(seed32), out),
      out,
      'provePubkeyValidity',
    );
  }

  @override
  BuResult<bool> verifyPubkeyValidity({
    required List<int> pubkey,
    required List<int> proof,
  }) => _verdict(
    _b.solanaZkVerifyPubkeyValidity(_as(pubkey), _as(proof)),
    'verifyPubkeyValidity',
  );

  @override
  BuResult<BuBytes> proveZeroCiphertext({
    required List<int> secret,
    required List<int> pubkey,
    required List<int> ciphertext,
    required List<int> seed32,
  }) {
    final out = BuBytes.zero(96);
    return _fixed(
      _b.solanaZkProveZeroCiphertext(
        _as(secret),
        _as(pubkey),
        _as(ciphertext),
        _as(seed32),
        out,
      ),
      out,
      'proveZeroCiphertext',
    );
  }

  @override
  BuResult<bool> verifyZeroCiphertext({
    required List<int> pubkey,
    required List<int> ciphertext,
    required List<int> proof,
  }) => _verdict(
    _b.solanaZkVerifyZeroCiphertext(_as(pubkey), _as(ciphertext), _as(proof)),
    'verifyZeroCiphertext',
  );

  @override
  BuResult<BuBytes> proveEquality({
    required List<int> secret,
    required List<int> pubkey,
    required List<int> ciphertext,
    required List<int> commitment,
    required List<int> opening,
    required int amount,
    required List<int> seed32,
  }) {
    final out = BuBytes.zero(192);
    return _fixed(
      _b.solanaZkProveEquality(
        secret: _as(secret),
        pubkey: _as(pubkey),
        ciphertext: _as(ciphertext),
        commitment: _as(commitment),
        opening: _as(opening),
        amount: amount,
        seed32: _as(seed32),
        out192: out,
      ),
      out,
      'proveEquality',
    );
  }

  @override
  BuResult<bool> verifyEquality({
    required List<int> pubkey,
    required List<int> ciphertext,
    required List<int> commitment,
    required List<int> proof,
  }) => _verdict(
    _b.solanaZkVerifyEquality(
      pubkey: _as(pubkey),
      ciphertext: _as(ciphertext),
      commitment: _as(commitment),
      proof: _as(proof),
    ),
    'verifyEquality',
  );

  @override
  BuResult<BuBytes> proveCiphertextEquality({
    required List<int> firstSecret,
    required List<int> firstPubkey,
    required List<int> secondPubkey,
    required List<int> firstCiphertext,
    required List<int> secondCiphertext,
    required List<int> secondOpening,
    required int amount,
    required List<int> seed32,
  }) {
    final out = BuBytes.zero(224);
    return _fixed(
      _b.solanaZkProveCiphertextEquality(
        firstSecret: _as(firstSecret),
        firstPubkey: _as(firstPubkey),
        secondPubkey: _as(secondPubkey),
        firstCiphertext: _as(firstCiphertext),
        secondCiphertext: _as(secondCiphertext),
        secondOpening: _as(secondOpening),
        amount: amount,
        seed32: _as(seed32),
        out224: out,
      ),
      out,
      'proveCiphertextEquality',
    );
  }

  @override
  BuResult<bool> verifyCiphertextEquality({
    required List<int> firstPubkey,
    required List<int> secondPubkey,
    required List<int> firstCiphertext,
    required List<int> secondCiphertext,
    required List<int> proof,
  }) => _verdict(
    _b.solanaZkVerifyCiphertextEquality(
      firstPubkey: _as(firstPubkey),
      secondPubkey: _as(secondPubkey),
      firstCiphertext: _as(firstCiphertext),
      secondCiphertext: _as(secondCiphertext),
      proof: _as(proof),
    ),
    'verifyCiphertextEquality',
  );

  @override
  BuResult<BuBytes> proveGroupedValidity2({
    required List<int> firstPubkey,
    required List<int> secondPubkey,
    required List<int> grouped96,
    required int amount,
    required List<int> opening,
    required List<int> seed32,
  }) {
    final out = BuBytes.zero(160);
    return _fixed(
      _b.solanaZkProveGroupedValidity2(
        firstPubkey: _as(firstPubkey),
        secondPubkey: _as(secondPubkey),
        grouped96: _as(grouped96),
        amount: amount,
        opening: _as(opening),
        seed32: _as(seed32),
        out160: out,
      ),
      out,
      'proveGroupedValidity2',
    );
  }

  @override
  BuResult<bool> verifyGroupedValidity2({
    required List<int> firstPubkey,
    required List<int> secondPubkey,
    required List<int> grouped96,
    required List<int> proof,
  }) => _verdict(
    _b.solanaZkVerifyGroupedValidity2(
      firstPubkey: _as(firstPubkey),
      secondPubkey: _as(secondPubkey),
      grouped96: _as(grouped96),
      proof: _as(proof),
    ),
    'verifyGroupedValidity2',
  );

  @override
  BuResult<BuBytes> proveGroupedValidity3({
    required List<int> firstPubkey,
    required List<int> secondPubkey,
    required List<int> thirdPubkey,
    required List<int> grouped128,
    required int amount,
    required List<int> opening,
    required List<int> seed32,
  }) {
    final out = BuBytes.zero(192);
    return _fixed(
      _b.solanaZkProveGroupedValidity3(
        firstPubkey: _as(firstPubkey),
        secondPubkey: _as(secondPubkey),
        thirdPubkey: _as(thirdPubkey),
        grouped128: _as(grouped128),
        amount: amount,
        opening: _as(opening),
        seed32: _as(seed32),
        out192: out,
      ),
      out,
      'proveGroupedValidity3',
    );
  }

  @override
  BuResult<bool> verifyGroupedValidity3({
    required List<int> firstPubkey,
    required List<int> secondPubkey,
    required List<int> thirdPubkey,
    required List<int> grouped128,
    required List<int> proof,
  }) => _verdict(
    _b.solanaZkVerifyGroupedValidity3(
      firstPubkey: _as(firstPubkey),
      secondPubkey: _as(secondPubkey),
      thirdPubkey: _as(thirdPubkey),
      grouped128: _as(grouped128),
      proof: _as(proof),
    ),
    'verifyGroupedValidity3',
  );

  @override
  BuResult<BuBytes> proveBatchedGroupedValidity2({
    required List<int> firstPubkey,
    required List<int> secondPubkey,
    required List<int> groupedLo96,
    required List<int> groupedHi96,
    required int amountLo,
    required int amountHi,
    required List<int> openingLo,
    required List<int> openingHi,
    required List<int> seed32,
  }) {
    final out = BuBytes.zero(160);
    return _fixed(
      _b.solanaZkProveBatchedGroupedValidity2(
        firstPubkey: _as(firstPubkey),
        secondPubkey: _as(secondPubkey),
        groupedLo96: _as(groupedLo96),
        groupedHi96: _as(groupedHi96),
        amountLo: amountLo,
        amountHi: amountHi,
        openingLo: _as(openingLo),
        openingHi: _as(openingHi),
        seed32: _as(seed32),
        out160: out,
      ),
      out,
      'proveBatchedGroupedValidity2',
    );
  }

  @override
  BuResult<bool> verifyBatchedGroupedValidity2({
    required List<int> firstPubkey,
    required List<int> secondPubkey,
    required List<int> groupedLo96,
    required List<int> groupedHi96,
    required List<int> proof,
  }) => _verdict(
    _b.solanaZkVerifyBatchedGroupedValidity2(
      firstPubkey: _as(firstPubkey),
      secondPubkey: _as(secondPubkey),
      groupedLo96: _as(groupedLo96),
      groupedHi96: _as(groupedHi96),
      proof: _as(proof),
    ),
    'verifyBatchedGroupedValidity2',
  );

  @override
  BuResult<BuBytes> proveBatchedGroupedValidity3({
    required List<int> firstPubkey,
    required List<int> secondPubkey,
    required List<int> thirdPubkey,
    required List<int> groupedLo128,
    required List<int> groupedHi128,
    required int amountLo,
    required int amountHi,
    required List<int> openingLo,
    required List<int> openingHi,
    required List<int> seed32,
  }) {
    final out = BuBytes.zero(192);
    return _fixed(
      _b.solanaZkProveBatchedGroupedValidity3(
        firstPubkey: _as(firstPubkey),
        secondPubkey: _as(secondPubkey),
        thirdPubkey: _as(thirdPubkey),
        groupedLo128: _as(groupedLo128),
        groupedHi128: _as(groupedHi128),
        amountLo: amountLo,
        amountHi: amountHi,
        openingLo: _as(openingLo),
        openingHi: _as(openingHi),
        seed32: _as(seed32),
        out192: out,
      ),
      out,
      'proveBatchedGroupedValidity3',
    );
  }

  @override
  BuResult<bool> verifyBatchedGroupedValidity3({
    required List<int> firstPubkey,
    required List<int> secondPubkey,
    required List<int> thirdPubkey,
    required List<int> groupedLo128,
    required List<int> groupedHi128,
    required List<int> proof,
  }) => _verdict(
    _b.solanaZkVerifyBatchedGroupedValidity3(
      firstPubkey: _as(firstPubkey),
      secondPubkey: _as(secondPubkey),
      thirdPubkey: _as(thirdPubkey),
      groupedLo128: _as(groupedLo128),
      groupedHi128: _as(groupedHi128),
      proof: _as(proof),
    ),
    'verifyBatchedGroupedValidity3',
  );

  @override
  BuResult<BuBytes> provePercentageWithCap({
    required List<int> percentageCommitment,
    required List<int> percentageOpening,
    required int percentageAmount,
    required List<int> deltaCommitment,
    required List<int> deltaOpening,
    required int deltaAmount,
    required List<int> claimedCommitment,
    required List<int> claimedOpening,
    required int maxValue,
    required List<int> seed32,
  }) {
    final out = BuBytes.zero(256);
    return _fixed(
      _b.solanaZkProvePercentageWithCap(
        percentageCommitment: _as(percentageCommitment),
        percentageOpening: _as(percentageOpening),
        percentageAmount: percentageAmount,
        deltaCommitment: _as(deltaCommitment),
        deltaOpening: _as(deltaOpening),
        deltaAmount: deltaAmount,
        claimedCommitment: _as(claimedCommitment),
        claimedOpening: _as(claimedOpening),
        maxValue: maxValue,
        seed32: _as(seed32),
        out256: out,
      ),
      out,
      'provePercentageWithCap',
    );
  }

  @override
  BuResult<bool> verifyPercentageWithCap({
    required List<int> percentageCommitment,
    required List<int> deltaCommitment,
    required List<int> claimedCommitment,
    required int maxValue,
    required List<int> proof,
  }) => _verdict(
    _b.solanaZkVerifyPercentageWithCap(
      percentageCommitment: _as(percentageCommitment),
      deltaCommitment: _as(deltaCommitment),
      claimedCommitment: _as(claimedCommitment),
      maxValue: maxValue,
      proof: _as(proof),
    ),
    'verifyPercentageWithCap',
  );

  @override
  BuResult<BuBytes> proveBatchedRange({
    required List<List<int>> amountsLe,
    required List<List<int>> openings,
    required List<int> seed32,
  }) {
    if (amountsLe.isEmpty || amountsLe.length > 16) {
      return BuResult.err(
        BuError(
          DefaultErrorType.invalidLength,
          'amountsLe must hold 1..16 entries',
        ),
      );
    }
    final flat = <BuBytes>[];
    final rc = _b.solanaZkProveBatchedRange(
      amountsLe: amountsLe.map(_as).toList(),
      openings: openings.map(_as).toList(),
      seed32: _as(seed32),
      outBlob: flat,
    );
    if (rc == 0 && flat.isNotEmpty) {
      return BuResult.ok(flat.first);
    }
    if (rc == -6) {
      return BuResult.err(
        BuError(
          DefaultErrorType.unsupported,
          'solana_zk.proveBatchedRange: native backend not linked',
        ),
      );
    }
    return BuResult.err(_map(rc));
  }

  @override
  BuResult<bool> verifyBatchedRange({
    required List<int> proof,
    required List<int> commitments,
    required int n,
  }) => _verdict(
    _b.solanaZkVerifyBatchedRange(
      proof: _as(proof),
      commitments: _as(commitments),
      n: n,
    ),
    'verifyBatchedRange',
  );

  @override
  BuResult<BuBytes> proveWithdraw({
    required List<int> sourceSecret,
    required List<int> sourcePubkey,
    required List<int> currentCiphertext,
    required int currentBalance,
    required int withdrawAmount,
    required List<int> seed32,
  }) {
    final out = BuBytes.zero(1256);
    return _fixed(
      _b.solanaZkProveWithdraw(
        sourceSecret: _as(sourceSecret),
        sourcePubkey: _as(sourcePubkey),
        currentCiphertext: _as(currentCiphertext),
        currentBalance: currentBalance,
        withdrawAmount: withdrawAmount,
        seed32: _as(seed32),
        out1256: out,
      ),
      out,
      'proveWithdraw',
    );
  }

  @override
  BuResult<BuBytes> proveTransfer({
    required List<int> sourceSecret,
    required List<int> sourcePubkey,
    required List<int> destPubkey,
    required List<int> auditorPubkey,
    required List<int> currentCiphertext,
    required int currentBalance,
    required int transferAmount,
    required List<int> seed32,
  }) {
    final out = BuBytes.zero(1896);
    return _fixed(
      _b.solanaZkProveTransfer(
        sourceSecret: _as(sourceSecret),
        sourcePubkey: _as(sourcePubkey),
        destPubkey: _as(destPubkey),
        auditorPubkey: _as(auditorPubkey),
        currentCiphertext: _as(currentCiphertext),
        currentBalance: currentBalance,
        transferAmount: transferAmount,
        seed32: _as(seed32),
        out1896: out,
      ),
      out,
      'proveTransfer',
    );
  }

  @override
  BuResult<BuBytes> proveTransferWithFee({
    required List<int> sourceSecret,
    required List<int> sourcePubkey,
    required List<int> destPubkey,
    required List<int> auditorPubkey,
    required List<int> authorityPubkey,
    required List<int> currentCiphertext,
    required int currentBalance,
    required int transferAmount,
    required int feeRateBasisPoints,
    required int maximumFee,
    required List<int> seed32,
  }) {
    final out = BuBytes.zero(2576);
    return _fixed(
      _b.solanaZkProveTransferWithFee(
        sourceSecret: _as(sourceSecret),
        sourcePubkey: _as(sourcePubkey),
        destPubkey: _as(destPubkey),
        auditorPubkey: _as(auditorPubkey),
        authorityPubkey: _as(authorityPubkey),
        currentCiphertext: _as(currentCiphertext),
        currentBalance: currentBalance,
        transferAmount: transferAmount,
        feeRateBasisPoints: feeRateBasisPoints,
        maximumFee: maximumFee,
        seed32: _as(seed32),
        out2576: out,
      ),
      out,
      'proveTransferWithFee',
    );
  }
}
