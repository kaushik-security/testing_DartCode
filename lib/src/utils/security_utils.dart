import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:logger/logger.dart';

/// Security utility functions for data sanitization and validation
class SecurityUtils {
  static final Logger _logger = Logger();

  /// Sanitize user data by removing sensitive information
  static Map<String, dynamic> sanitizeUserData(Map<String, dynamic> data) {
    final sanitized = Map<String, dynamic>.from(data);

    // Remove sensitive fields
    sanitized.remove('password');
    sanitized.remove('hashed_password');
    sanitized.remove('token');
    sanitized.remove('refresh_token');
    sanitized.remove('api_key');
    sanitized.remove('secret');
    sanitized.remove('private_key');
    sanitized.remove('credit_card');
    sanitized.remove('ssn');
    sanitized.remove('social_security');

    // Sanitize metadata if present
    if (sanitized.containsKey('metadata') && sanitized['metadata'] is Map) {
      sanitized['metadata'] = sanitizeUserData(sanitized['metadata'] as Map<String, dynamic>);
    }

    // Remove any field containing sensitive keywords
    final sensitiveKeywords = ['password', 'secret', 'token', 'key', 'auth', 'credential'];
    final keysToRemove = <String>[];

    sanitized.forEach((key, value) {
      final lowerKey = key.toLowerCase();
      if (sensitiveKeywords.any((keyword) => lowerKey.contains(keyword))) {
        keysToRemove.add(key);
      }
    });

    keysToRemove.forEach(sanitized.remove);

    _logger.d('User data sanitized: ${sanitized.keys.join(', ')}');
    return sanitized;
  }

  /// Validate input string for potential security issues
  static bool isValidInput(String input, {int maxLength = 1000}) {
    if (input.isEmpty) return false;
    if (input.length > maxLength) return false;

    // Check for potential script injection
    final suspiciousPatterns = [
      '<script',
      '</script>',
      'javascript:',
      'vbscript:',
      'onload=',
      'onerror=',
      'onclick=',
      'onmouseover=',
      'eval(',
      'alert(',
      'document.cookie',
      'window.location',
    ];

    final lowerInput = input.toLowerCase();
    for (final pattern in suspiciousPatterns) {
      if (lowerInput.contains(pattern)) {
        _logger.w('Suspicious pattern detected in input: $pattern');
        return false;
      }
    }

    return true;
  }

  /// Sanitize filename to prevent path traversal attacks
  static String sanitizeFilename(String filename) {
    if (filename.isEmpty) return 'unnamed_file';

    // Remove or replace dangerous characters
    final sanitized = filename
        .replaceAll('..', '')
        .replaceAll('/', '_')
        .replaceAll('\\', '_')
        .replaceAll(':', '_')
        .replaceAll('*', '_')
        .replaceAll('?', '_')
        .replaceAll('"', '_')
        .replaceAll('<', '_')
        .replaceAll('>', '_')
        .replaceAll('|', '_');

    // Ensure filename is not too long and not empty after sanitization
    final trimmed = sanitized.trim();
    if (trimmed.isEmpty) return 'unnamed_file';
    if (trimmed.length > 255) return trimmed.substring(0, 255);

    return trimmed;
  }

  /// Validate URL for security
  static bool isValidUrl(String url) {
    try {
      final uri = Uri.parse(url);

      // Check scheme
      if (!['http', 'https'].contains(uri.scheme)) {
        return false;
      }

      // Check for suspicious patterns
      final lowerUrl = url.toLowerCase();
      final suspiciousPatterns = [
        'javascript:',
        'vbscript:',
        'data:',
        'file:',
        '..',
        '%2e%2e',
      ];

      for (final pattern in suspiciousPatterns) {
        if (lowerUrl.contains(pattern)) {
          return false;
        }
      }

      return uri.host.isNotEmpty;
    } catch (e) {
      _logger.w('Invalid URL format: $url');
      return false;
    }
  }

  /// Hash sensitive string data
  static String hashString(String data) {
    final bytes = utf8.encode(data);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  /// Generate secure random string
  static String generateSecureRandomString(int length) {
    const chars = 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    final random = DateTime.now().millisecondsSinceEpoch.toString();

    String result = '';
    for (int i = 0; i < length; i++) {
      final hash = hashString('$random$i');
      final index = hash.codeUnitAt(i % hash.length) % chars.length;
      result += chars[index];
    }

    return result;
  }

  /// Validate email format
  static bool isValidEmail(String email) {
    if (email.isEmpty || email.length > 254) return false;

    final emailRegex = RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');
    return emailRegex.hasMatch(email);
  }

  /// Check password strength
  static PasswordStrength checkPasswordStrength(String password) {
    if (password.isEmpty) return PasswordStrength.veryWeak;

    int score = 0;

    // Length check
    if (password.length >= 8) score++;
    if (password.length >= 12) score++;

    // Character variety
    if (RegExp(r'[a-z]').hasMatch(password)) score++;
    if (RegExp(r'[A-Z]').hasMatch(password)) score++;
    if (RegExp(r'[0-9]').hasMatch(password)) score++;
    if (RegExp(r'[!@#$%^&*(),.?":{}|<>]').hasMatch(password)) score++;

    // Check for common patterns
    if (RegExp(r'(.)\1{2,}').hasMatch(password)) score--; // Repeated characters
    if (RegExp(r'123|abc|qwe|password|admin', caseSensitive: false).hasMatch(password)) {
      score -= 2; // Common patterns
    }

    // Clamp score
    score = score.clamp(0, 6);

    switch (score) {
      case 0:
      case 1:
        return PasswordStrength.veryWeak;
      case 2:
        return PasswordStrength.weak;
      case 3:
        return PasswordStrength.fair;
      case 4:
        return PasswordStrength.good;
      case 5:
      case 6:
        return PasswordStrength.strong;
      default:
        return PasswordStrength.veryWeak;
    }
  }

  /// Rate limit checker (simple in-memory implementation)
  static final Map<String, List<DateTime>> _rateLimitStore = {};

  static bool checkRateLimit(String identifier, {int maxRequests = 10, Duration window = const Duration(minutes: 1)}) {
    final now = DateTime.now();
    final requests = _rateLimitStore[identifier] ?? [];

    // Remove old requests outside the window
    final validRequests = requests.where((time) => now.difference(time) < window).toList();

    if (validRequests.length >= maxRequests) {
      _logger.w('Rate limit exceeded for identifier: $identifier');
      return false;
    }

    // Add current request
    validRequests.add(now);
    _rateLimitStore[identifier] = validRequests;

    return true;
  }

  /// Validate API key format
  static bool isValidApiKey(String apiKey) {
    if (apiKey.isEmpty || apiKey.length < 20) return false;

    // Should contain alphanumeric characters and possibly some special chars
    final apiKeyRegex = RegExp(r'^[a-zA-Z0-9\-_\.]{20,}$');
    return apiKeyRegex.hasMatch(apiKey);
  }

  /// Mask sensitive data for logging
  static String maskSensitiveData(String data, {int visibleChars = 4}) {
    if (data.length <= visibleChars * 2) {
      return '*' * data.length;
    }

    final start = data.substring(0, visibleChars);
    final end = data.substring(data.length - visibleChars);
    final maskLength = data.length - (visibleChars * 2);

    return '$start${'*' * maskLength}$end';
  }

  /// Validate file type for security
  static bool isAllowedFileType(String filename, List<String> allowedExtensions) {
    final extension = filename.split('.').last.toLowerCase();
    return allowedExtensions.contains(extension);
  }

  /// Clean up rate limit data (call periodically)
  static void cleanupRateLimitData({Duration olderThan = const Duration(hours: 1)}) {
    final now = DateTime.now();
    final cutoff = now.subtract(olderThan);

    _rateLimitStore.removeWhere((identifier, requests) {
      return requests.every((time) => time.isBefore(cutoff));
    });

    _logger.d('Rate limit data cleaned up');
  }
}

/// Password strength levels
enum PasswordStrength {
  veryWeak,
  weak,
  fair,
  good,
  strong,
}

/// Extension methods for security utilities
extension SecurityStringExtension on String {
  /// Check if string is a valid email
  bool get isValidEmail => SecurityUtils.isValidEmail(this);

  /// Check if string is a valid URL
  bool get isValidUrl => SecurityUtils.isValidUrl(this);

  /// Check if string is safe input
  bool get isSafeInput => SecurityUtils.isValidInput(this);

  /// Hash the string
  String get hashed => SecurityUtils.hashString(this);

  /// Mask sensitive data
  String mask({int visibleChars = 4}) => SecurityUtils.maskSensitiveData(this, visibleChars: visibleChars);

  /// Sanitize filename
  String get sanitizedFilename => SecurityUtils.sanitizeFilename(this);

  /// Get password strength
  PasswordStrength get passwordStrength => SecurityUtils.checkPasswordStrength(this);
}
