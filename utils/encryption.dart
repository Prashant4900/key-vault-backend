import 'package:encrypt/encrypt.dart';

/// A utility class for encryption and decryption using AES.
class Encryption {
  /// Encrypts the given [plainText] using AES with the provided [password].
  ///
  /// - Parameters:
  ///   - [password]: The encryption key to be used for the AES algorithm.
  ///   - [plainText]: The text that needs to be encrypted.
  /// - Returns: The encrypted text concatenated with the IV, separated by '||||'.
  static String encrypt({
    required String password,
    required String plainText,
  }) {
    final key = Key.fromUtf8(password);
    final iv = IV.fromSecureRandom(16);
    final encrypter = Encrypter(AES(key));
    final encrypted = encrypter.encrypt(plainText, iv: iv);

    // Concatenate the encrypted text with the IV, separated by '||||'
    final cipherText = '${encrypted.base64}||||${iv.base64}';

    return cipherText;
  }

  /// Decrypts the given [encryptedText] using AES with the provided [password].
  ///
  /// - Parameters:
  ///   - [password]: The decryption key to be used for the AES algorithm.
  ///   - [encryptedText]: The text that needs to be decrypted. It should contain
  ///     both the encrypted data and the IV, separated by '||||'.
  /// - Returns: The decrypted text as a `String`.
  static String decrypt({
    required String password,
    required String encryptedText,
  }) {
    final key = Key.fromUtf8(password);

    // Split the encrypted text to extract the encrypted data and the IV
    final parts = encryptedText.split('||||');
    if (parts.length != 2) {
      throw ArgumentError('Invalid encrypted text format');
    }

    final encryptedData = parts[0];
    final iv = IV.fromBase64(parts[1]);

    final encrypter = Encrypter(AES(key));

    // Decrypt the encrypted data using the extracted IV
    final plainText = encrypter.decrypt64(encryptedData, iv: iv);

    return plainText;
  }
}
