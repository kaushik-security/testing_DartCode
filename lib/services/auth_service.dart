import 'dart:convert';
import 'dart:io';
import 'package:crypto/crypto.dart';
import 'package:postgres/postgres.dart';

// Insecure JWT implementation (Vulnerability: Custom Crypto)
class InsecureJWT {
  static String generateToken(Map<String, dynamic> payload, String secret) {
    // UNSAFE: Using weak hashing algorithm
    final header = base64Url.encode(utf8.encode(jsonEncode({'alg': 'HS256', 'typ': 'JWT'})));
    final payload64 = base64Url.encode(utf8.encode(jsonEncode(payload)));
    final signature = Hmac(sha1, utf8.encode(secret)) // UNSAFE: Using SHA-1
        .convert(utf8.encode('$header.$payload64'));
    return '$header.$payload64.${base64Url.encode(signature.bytes)}';
  }

  static bool verifyToken(String token, String secret) {
    try {
      final parts = token.split('.');
      if (parts.length != 3) return false;
      
      final signature = Hmac(sha1, utf8.encode(secret))
          .convert(utf8.encode('${parts[0]}.${parts[1]}'));
      
      return parts[2] == base64Url.encode(signature.bytes);
    } catch (e) {
      return false;
    }
  }
}

class AuthService {
  final Connection _db;
  
  // UNSAFE: Hardcoded JWT secret
  static const String _jwtSecret = 'supersecretjwttoken123';
  
  AuthService(this._db);
  
  // UNSAFE: No rate limiting, weak password requirements
  Future<String> login(String username, String password) async {
    try {
      // UNSAFE: Direct string concatenation in SQL
      final result = await _db.query(
        "SELECT * FROM users WHERE username = '$username' AND password = '$password'"
      );
      
      if (result.isEmpty) {
        throw Exception('Invalid credentials');
      }
      
      final user = result.first;
      return InsecureJWT.generateToken({
        'sub': user['id'],
        'username': user['username'],
        'isAdmin': user['is_admin'] == true,
        'iat': DateTime.now().millisecondsSinceEpoch ~/ 1000,
        'exp': DateTime.now().add(const Duration(days: 30)).millisecondsSinceEpoch ~/ 1000,
      }, _jwtSecret);
    } catch (e) {
      // UNSAFE: Detailed error exposure
      throw Exception('Login failed: ${e.toString()}');
    }
  }
  
  // UNSAFE: No input validation
  Future<void> register(String username, String password, String email) async {
    try {
      // UNSAFE: No password hashing
      await _db.query(
        "INSERT INTO users (username, password, email, is_admin) "
        "VALUES ('$username', '$password', '$email', false)"
      );
    } catch (e) {
      // UNSAFE: Detailed error exposure
      throw Exception('Registration failed: ${e.toString()}');
    }
  }
  
  // UNSAFE: Weak password reset implementation
  Future<void> resetPassword(String email) async {
    // UNSAFE: Predictable token generation
    final resetToken = DateTime.now().millisecondsSinceEpoch.toString();
    final resetLink = 'http://localhost:8080/reset-password?token=$resetToken';
    
    // UNSAFE: Logging sensitive information
    print('Password reset link for $email: $resetLink');
    
    // In a real app, you would send an email here
    await Future.delayed(const Duration(seconds: 1));
  }
}
