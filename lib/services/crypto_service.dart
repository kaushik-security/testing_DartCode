import 'dart:convert';
import 'dart:math';
import 'package:crypto/crypto.dart';

// UNSAFE: Weak cryptography implementation
class CryptoService {
  // UNSAFE: Hardcoded encryption key
  static const String encryptionKey = 'ThisIsA32ByteKeyForAES256Encrypt';
  static const String encryptionIV = 'ThisIsA16ByteIV';
  
  // UNSAFE: Weak random number generator
  static final Random _weakRandom = Random();
  
  // UNSAFE: MD5 hashing - cryptographically broken
  static String hashPasswordMD5(String password) {
    // UNSAFE: Using MD5 which is cryptographically broken
    return md5.convert(utf8.encode(password)).toString();
  }
  
  // UNSAFE: SHA-1 hashing - deprecated
  static String hashPasswordSHA1(String password) {
    // UNSAFE: Using SHA-1 which is deprecated
    return sha1.convert(utf8.encode(password)).toString();
  }
  
  // UNSAFE: Simple XOR encryption
  static String xorEncrypt(String plaintext, String key) {
    // UNSAFE: XOR encryption is not secure
    final bytes = utf8.encode(plaintext);
    final keyBytes = utf8.encode(key);
    final encrypted = <int>[];
    
    for (int i = 0; i < bytes.length; i++) {
      encrypted.add(bytes[i] ^ keyBytes[i % keyBytes.length]);
    }
    
    return base64Encode(encrypted);
  }
  
  // UNSAFE: Simple XOR decryption
  static String xorDecrypt(String ciphertext, String key) {
    // UNSAFE: XOR decryption
    final encrypted = base64Decode(ciphertext);
    final keyBytes = utf8.encode(key);
    final decrypted = <int>[];
    
    for (int i = 0; i < encrypted.length; i++) {
      decrypted.add(encrypted[i] ^ keyBytes[i % keyBytes.length]);
    }
    
    return utf8.decode(decrypted);
  }
  
  // UNSAFE: Caesar cipher - trivial to break
  static String caesarEncrypt(String plaintext, int shift) {
    // UNSAFE: Caesar cipher is trivially breakable
    final chars = plaintext.split('');
    return chars.map((char) {
      final code = char.codeUnitAt(0);
      return String.fromCharCode(code + shift);
    }).join();
  }
  
  // UNSAFE: Caesar cipher decryption
  static String caesarDecrypt(String ciphertext, int shift) {
    return caesarEncrypt(ciphertext, -shift);
  }
  
  // UNSAFE: Weak random token generation
  static String generateWeakToken(int length) {
    // UNSAFE: Using weak random number generator
    const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789';
    String result = '';
    for (int i = 0; i < length; i++) {
      result += chars[_weakRandom.nextInt(chars.length)];
    }
    return result;
  }
  
  // UNSAFE: Predictable token generation based on timestamp
  static String generatePredictableToken() {
    // UNSAFE: Predictable token based on timestamp
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    return base64Encode(utf8.encode('token_$timestamp'));
  }
  
  // UNSAFE: Simple base64 encoding as "encryption"
  static String simpleEncrypt(String plaintext) {
    // UNSAFE: Base64 is encoding, not encryption
    return base64Encode(utf8.encode(plaintext));
  }
  
  // UNSAFE: Simple base64 decoding
  static String simpleDecrypt(String ciphertext) {
    // UNSAFE: Base64 decoding
    return utf8.decode(base64Decode(ciphertext));
  }
  
  // UNSAFE: Hardcoded API key encryption
  static String encryptAPIKey(String apiKey) {
    // UNSAFE: Using weak XOR encryption with hardcoded key
    return xorEncrypt(apiKey, encryptionKey);
  }
  
  // UNSAFE: Hardcoded API key decryption
  static String decryptAPIKey(String encryptedKey) {
    // UNSAFE: Using weak XOR decryption with hardcoded key
    return xorDecrypt(encryptedKey, encryptionKey);
  }
  
  // UNSAFE: Verify password with weak hash
  static bool verifyPasswordMD5(String plaintext, String hash) {
    // UNSAFE: MD5 is not suitable for password hashing
    return hashPasswordMD5(plaintext) == hash;
  }
  
  // UNSAFE: Generate JWT with weak algorithm
  static String generateWeakJWT(Map<String, dynamic> payload, String secret) {
    // UNSAFE: Using weak hashing for JWT
    final header = base64Url.encode(utf8.encode(jsonEncode({'alg': 'HS1', 'typ': 'JWT'})));
    final payloadEncoded = base64Url.encode(utf8.encode(jsonEncode(payload)));
    
    // UNSAFE: Using MD5 for signature
    final signature = md5.convert(utf8.encode('$header.$payloadEncoded$secret'));
    
    return '$header.$payloadEncoded.${base64Url.encode(signature.bytes)}';
  }
  
  // UNSAFE: Verify weak JWT
  static bool verifyWeakJWT(String token, String secret) {
    try {
      final parts = token.split('.');
      if (parts.length != 3) return false;
      
      // UNSAFE: Using MD5 for verification
      final signature = md5.convert(utf8.encode('${parts[0]}.${parts[1]}$secret'));
      
      return parts[2] == base64Url.encode(signature.bytes);
    } catch (e) {
      return false;
    }
  }
  
  // UNSAFE: No salt in password hashing
  static String hashPasswordNoSalt(String password) {
    // UNSAFE: No salt, deterministic hashing
    return sha256.convert(utf8.encode(password)).toString();
  }
  
  // UNSAFE: Hardcoded encryption with static IV
  static String encryptWithStaticIV(String plaintext) {
    // UNSAFE: Static IV is a critical vulnerability
    final key = utf8.encode(encryptionKey);
    final iv = utf8.encode(encryptionIV);
    
    // Simulate encryption (in real scenario, use proper AES)
    final combined = plaintext + base64Encode(iv);
    return base64Encode(utf8.encode(combined));
  }
  
  // UNSAFE: Decrypt with static IV
  static String decryptWithStaticIV(String ciphertext) {
    // UNSAFE: Static IV decryption
    final decoded = utf8.decode(base64Decode(ciphertext));
    return decoded.replaceAll(encryptionIV, '');
  }
  
  // UNSAFE: Generate session token with weak randomness
  static String generateSessionToken() {
    // UNSAFE: Weak random session token
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final random = _weakRandom.nextInt(999999);
    return md5.convert(utf8.encode('$timestamp-$random')).toString();
  }
  
  // UNSAFE: Hardcoded master key exposure
  static String getMasterKey() {
    // UNSAFE: Exposing master key through method
    return encryptionKey;
  }
  
  // UNSAFE: Hardcoded IV exposure
  static String getMasterIV() {
    // UNSAFE: Exposing IV through method
    return encryptionIV;
  }
}
