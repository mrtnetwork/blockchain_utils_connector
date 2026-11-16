import 'package:blockchain_utils_connector/src/aead/aead.dart';
import 'package:blockchain_utils_connector/src/bytes/bytes.dart';
import 'package:blockchain_utils_connector/src/error/bu_error.dart';

abstract interface class BuAeadApi {
  BuResult<BuAead> chacha20Poly1305(List<int> key);
  BuResult<BuAead> aesGcm(List<int> aesKey);

  /// XSalsa20-Poly1305 (NaCl secretbox) from a 32-byte [key].
  /// Strict 24-byte nonce; wire order `TAG ‖ CIPHERTEXT` (authenticator first).
  BuResult<BuAead> xsalsa20Poly1305(List<int> key);

  /// NaCl `crypto_box_beforenm`: 32-byte transport key from 32-byte
  /// [peerPublicKey] and [secretKey]. Err on invalid lengths or a zero
  /// shared secret.
  BuResult<BuBytes> salsaBoxBeforenm({
    required List<int> peerPublicKey,
    required List<int> secretKey,
  });

  /// NaCl `crypto_box_easy` detached encrypt with explicit 24-byte [nonce].
  /// Ok value is `TAG ‖ CIPHERTEXT` (authenticator first).
  BuResult<BuBytes> salsaBoxEncrypt({
    required List<int> peerPublicKey,
    required List<int> secretKey,
    required List<int> nonce,
    required List<int> plaintext,
  });

  /// NaCl `crypto_box_open_easy` detached decrypt with explicit 24-byte
  /// [nonce]. `ok(null)` means authentication failure; err means invalid
  /// key/nonce lengths.
  BuResult<BuBytes?> salsaBoxDecrypt({
    required List<int> peerPublicKey,
    required List<int> secretKey,
    required List<int> nonce,
    required List<int> sealed,
  });
}
