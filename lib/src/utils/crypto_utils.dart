import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';
import 'package:crypto/crypto.dart';
import 'package:logger/logger.dart';

/// Cryptographic utility functions for secure data handling
class CryptoUtils {
  static final Logger _logger = Logger();
  static final Random _random = Random.secure();

  /// Hash string using SHA-256
  static String hashString(String data) {
    final bytes = utf8.encode(data);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  /// Hash string using SHA-1
  static String hashStringSHA1(String data) {
    final bytes = utf8.encode(data);
    final digest = sha1.convert(bytes);
    return digest.toString();
  }

  /// Hash string using MD5
  static String hashStringMD5(String data) {
    final bytes = utf8.encode(data);
    final digest = md5.convert(bytes);
    return digest.toString();
  }

  /// Generate HMAC signature
  static String generateHMAC(String data, String key, {String algorithm = 'sha256'}) {
    try {
      final keyBytes = utf8.encode(key);
      final dataBytes = utf8.encode(data);

      final hmac;
      switch (algorithm.toLowerCase()) {
        case 'sha1':
          hmac = Hmac(sha1, keyBytes);
          break;
        case 'sha256':
        default:
          hmac = Hmac(sha256, keyBytes);
          break;
      }

      final digest = hmac.convert(dataBytes);
      return digest.toString();
    } catch (e) {
      _logger.e('Failed to generate HMAC', e);
      throw CryptoException('Failed to generate HMAC: ${e.toString()}');
    }
  }

  /// Verify HMAC signature
  static bool verifyHMAC(String data, String key, String signature, {String algorithm = 'sha256'}) {
    try {
      final expectedSignature = generateHMAC(data, key, algorithm: algorithm);
      return _constantTimeEquals(signature, expectedSignature);
    } catch (e) {
      _logger.e('Failed to verify HMAC', e);
      return false;
    }
  }

  /// Constant time string comparison to prevent timing attacks
  static bool _constantTimeEquals(String a, String b) {
    if (a.length != b.length) return false;

    var result = 0;
    for (var i = 0; i < a.length; i++) {
      result |= a.codeUnitAt(i) ^ b.codeUnitAt(i);
    }

    return result == 0;
  }

  /// Generate cryptographically secure random bytes
  static Uint8List generateRandomBytes(int length) {
    if (length <= 0) {
      throw ArgumentError('Length must be positive');
    }

    if (length > 1024 * 1024) { // 1MB limit
      throw ArgumentError('Length too large: maximum 1MB');
    }

    final bytes = Uint8List(length);
    for (var i = 0; i < length; i++) {
      bytes[i] = _random.nextInt(256);
    }

    return bytes;
  }

  /// Generate secure random string
  static String generateSecureRandomString(int length) {
    const chars = 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    final randomBytes = generateRandomBytes(length * 2); // Extra entropy

    String result = '';
    for (var i = 0; i < length; i++) {
      final index = randomBytes[i * 2] % chars.length;
      result += chars[index];
    }

    return result;
  }

  /// Generate secure random number within range
  static int generateSecureRandomInt(int min, int max) {
    if (min >= max) {
      throw ArgumentError('Min must be less than max');
    }

    final range = max - min;
    final randomBytes = generateRandomBytes(4);
    final randomValue = ByteData.sublistView(randomBytes).getUint32(0, Endian.little);

    return min + (randomValue % range);
  }

  /// Encrypt data using simple XOR cipher (for demonstration - not secure for production)
  static String simpleEncrypt(String data, String key) {
    final dataBytes = utf8.encode(data);
    final keyBytes = utf8.encode(key);

    final encrypted = Uint8List(dataBytes.length);

    for (var i = 0; i < dataBytes.length; i++) {
      encrypted[i] = dataBytes[i] ^ keyBytes[i % keyBytes.length];
    }

    return base64.encode(encrypted);
  }

  /// Decrypt data using simple XOR cipher
  static String simpleDecrypt(String encryptedData, String key) {
    final encryptedBytes = base64.decode(encryptedData);
    final keyBytes = utf8.encode(key);

    final decrypted = Uint8List(encryptedBytes.length);

    for (var i = 0; i < encryptedBytes.length; i++) {
      decrypted[i] = encryptedBytes[i] ^ keyBytes[i % keyBytes.length];
    }

    return utf8.decode(decrypted);
  }

  /// Generate password-based key (PBKDF2-like implementation)
  static String generatePasswordKey(String password, String salt, {int iterations = 1000}) {
    String key = password + salt;

    for (var i = 0; i < iterations; i++) {
      key = hashString(key);
    }

    return key;
  }

  /// Verify password against stored hash
  static bool verifyPasswordHash(String password, String salt, String storedHash) {
    try {
      final computedHash = generatePasswordKey(password, salt);
      return _constantTimeEquals(computedHash, storedHash);
    } catch (e) {
      _logger.e('Failed to verify password hash', e);
      return false;
    }
  }

  /// Generate salt for password hashing
  static String generateSalt({int length = 32}) {
    return base64.encode(generateRandomBytes(length));
  }

  /// Encode data to Base64
  static String encodeBase64(String data) {
    final bytes = utf8.encode(data);
    return base64.encode(bytes);
  }

  /// Decode data from Base64
  static String decodeBase64(String encodedData) {
    try {
      final bytes = base64.decode(encodedData);
      return utf8.decode(bytes);
    } catch (e) {
      _logger.e('Failed to decode Base64 data', e);
      throw CryptoException('Failed to decode Base64: ${e.toString()}');
    }
  }

  /// Encode data to Base64 URL-safe
  static String encodeBase64Url(String data) {
    final bytes = utf8.encode(data);
    return base64Url.encode(bytes);
  }

  /// Decode data from Base64 URL-safe
  static String decodeBase64Url(String encodedData) {
    try {
      final bytes = base64Url.decode(encodedData);
      return utf8.decode(bytes);
    } catch (e) {
      _logger.e('Failed to decode Base64 URL data', e);
      throw CryptoException('Failed to decode Base64 URL: ${e.toString()}');
    }
  }

  /// Generate API key
  static String generateApiKey({int length = 32}) {
    const prefix = 'dsp_'; // Dart Scan Project prefix
    final randomPart = generateSecureRandomString(length);
    return prefix + randomPart;
  }

  /// Validate API key format
  static bool isValidApiKey(String apiKey) {
    if (apiKey.length < 20) return false;

    // Should contain alphanumeric characters and possibly some special chars
    final apiKeyRegex = RegExp(r'^[a-zA-Z0-9\-_\.]+$');
    return apiKeyRegex.hasMatch(apiKey);
  }

  /// Generate session token
  static String generateSessionToken({int length = 64}) {
    return generateSecureRandomString(length);
  }

  /// Generate one-time password (OTP)
  static String generateOTP({int length = 6}) {
    if (length < 4 || length > 10) {
      throw ArgumentError('OTP length must be between 4 and 10');
    }

    final otp = StringBuffer();
    for (var i = 0; i < length; i++) {
      otp.write(_random.nextInt(10));
    }

    return otp.toString();
  }

  /// Hash file contents
  static Future<String> hashFile(String filePath, {String algorithm = 'sha256'}) async {
    try {
      // This would read file in chunks for large files in a real implementation
      // For this example, we'll use a simple approach

      final bytes = utf8.encode(filePath + DateTime.now().toString());
      switch (algorithm.toLowerCase()) {
        case 'md5':
          return md5.convert(bytes).toString();
        case 'sha1':
          return sha1.convert(bytes).toString();
        case 'sha256':
        default:
          return sha256.convert(bytes).toString();
      }
    } catch (e) {
      _logger.e('Failed to hash file: $filePath', e);
      throw CryptoException('Failed to hash file: ${e.toString()}');
    }
  }

  /// Check if data matches hash
  static bool verifyHash(String data, String expectedHash, {String algorithm = 'sha256'}) {
    try {
      final computedHash = _computeHash(data, algorithm);
      return _constantTimeEquals(computedHash, expectedHash);
    } catch (e) {
      _logger.e('Failed to verify hash', e);
      return false;
    }
  }

  /// Compute hash for given algorithm
  static String _computeHash(String data, String algorithm) {
    final bytes = utf8.encode(data);

    switch (algorithm.toLowerCase()) {
      case 'md5':
        return md5.convert(bytes).toString();
      case 'sha1':
        return sha1.convert(bytes).toString();
      case 'sha256':
      default:
        return sha256.convert(bytes).toString();
    }
  }

  /// Generate key pair (simplified - for demonstration only)
  static Map<String, String> generateKeyPair() {
    // In a real implementation, this would use proper asymmetric cryptography
    final privateKey = generateSecureRandomString(64);
    final publicKey = hashString(privateKey).substring(0, 32);

    return {
      'private_key': privateKey,
      'public_key': publicKey,
    };
  }

  /// Sign data (simplified implementation)
  static String signData(String data, String privateKey) {
    // In a real implementation, this would use proper digital signatures
    return generateHMAC(data, privateKey);
  }

  /// Verify signature (simplified implementation)
  static bool verifySignature(String data, String signature, String publicKey) {
    // In a real implementation, this would use proper signature verification
    // For this example, we'll use a simple approach
    final expectedSignature = hashString(data + publicKey);
    return _constantTimeEquals(signature, expectedSignature);
  }

  /// Encrypt data using Caesar cipher (educational purposes only)
  static String caesarEncrypt(String text, int shift) {
    if (shift < 0) shift = 26 + (shift % 26);

    String result = '';
    for (var i = 0; i < text.length; i++) {
      var char = text[i];

      if (char.isAlpha) {
        final isUpper = char.isUpperCase;
        char = char.toLowerCase();

        final charCode = char.codeUnitAt(0);
        final shifted = ((charCode - 97 + shift) % 26) + 97;

        char = String.fromCharCode(shifted);
        if (isUpper) char = char.toUpperCase();
      }

      result += char;
    }

    return result;
  }

  /// Decrypt data using Caesar cipher
  static String caesarDecrypt(String text, int shift) {
    return caesarEncrypt(text, -shift);
  }

  /// Calculate entropy of a string (measure of randomness)
  static double calculateEntropy(String data) {
    if (data.isEmpty) return 0.0;

    final charCounts = <String, int>{};
    for (final char in data.runes) {
      final charStr = String.fromCharCode(char);
      charCounts[charStr] = (charCounts[charStr] ?? 0) + 1;
    }

    final dataLength = data.length.toDouble();
    double entropy = 0.0;

    for (final count in charCounts.values) {
      final probability = count / dataLength;
      entropy -= probability * (log(probability) / ln2);
    }

    return entropy;
  }

  /// Check if string looks like encrypted data
  static bool looksLikeEncrypted(String data) {
    if (data.length < 10) return false;

    final entropy = calculateEntropy(data);
    final base64Ratio = _calculateBase64Ratio(data);

    // High entropy and high Base64 character ratio suggests encryption
    return entropy > 4.0 && base64Ratio > 0.7;
  }

  /// Calculate ratio of Base64-valid characters
  static double _calculateBase64Ratio(String data) {
    if (data.isEmpty) return 0.0;

    const base64Chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/=';
    int validChars = 0;

    for (final char in data.runes) {
      if (base64Chars.contains(String.fromCharCode(char))) {
        validChars++;
      }
    }

    return validChars / data.length;
  }
}

/// Custom exception for cryptographic operations
class CryptoException implements Exception {
  final String message;

  CryptoException(this.message);

  @override
  String toString() => 'CryptoException: $message';
}
