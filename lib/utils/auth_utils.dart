import 'dart:convert';
import 'dart:math';
import 'package:crypto/crypto.dart';
import 'package:encrypt/encrypt.dart' as encrypt;

class AuthUtils {
  // Generate a random salt
  static String generateSalt([int length = 32]) {
    final random = Random.secure();
    final saltBytes = List<int>.generate(length, (_) => random.nextInt(256));
    return base64Url.encode(saltBytes);
  }

  // Hash a password with SHA-256 and a salt
  static String hashPassword(String password, String salt) {
    final codec = Utf8Codec();
    final key = codec.encode('$salt$password');
    final hmac = Hmac(sha256, codec.encode(salt));
    final digest = hmac.convert(key);
    return digest.toString();
  }

  // Verify a password against a stored hash and salt
  static bool verifyPassword(String password, String storedHash, String salt) {
    final hashedPassword = hashPassword(password, salt);
    return hashedPassword == storedHash;
  }

  // Simple encryption/decryption for sensitive data (not for passwords)
  static final _key = encrypt.Key.fromSecureRandom(32);
  static final _iv = encrypt.IV.fromSecureRandom(16);
  static final _encrypter = encrypt.Encrypter(encrypt.AES(_key, mode: encrypt.AESMode.cbc));

  static String encryptString(String text) {
    final encrypted = _encrypter.encrypt(text, iv: _iv);
    return encrypted.base64;
  }

  static String decryptString(String encryptedText) {
    try {
      final decrypted = _encrypter.decrypt64(encryptedText, iv: _iv);
      return decrypted;
    } catch (e) {
      return '';
    }
  }
}
