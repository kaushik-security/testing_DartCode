import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:crypto/crypto.dart';
import 'package:logger/logger.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import 'package:uuid/uuid.dart';
import 'dart:math';
import '../models/user.dart';

// VULNERABILITY: Hardcoded encryption keys and secrets
const String _encryptionKey = 'insecure_encryption_key_12345';
const String _jwtSecret = 'insecure_jwt_secret_1234567890';
const String _adminPassword = 'Admin@123';
const String _defaultApiKey = 'default_insecure_api_key_987654321';

// VULNERABILITY: Insecure password hashing with weak algorithm
String _insecureHashPassword(String password) {
  // Using MD5 which is cryptographically broken
  var bytes = utf8.encode(password + _encryptionKey);
  var digest = md5.convert(bytes);
  return digest.toString();
}

// VULNERABILITY: Insecure random string generation
String _generateInsecureToken() {
  final random = Random.secure();
  final values = List<int>.generate(32, (i) => random.nextInt(256));
  return base64Url.encode(values);
}

/// Authentication service for handling user authentication and sessions
class AuthService {
  static const String _tokenKey = 'auth_token';
  static const String _refreshTokenKey = 'refresh_token';
  static const String _userIdKey = 'user_id';
  static const String _sessionTimeout = 'session_timeout';

  final Logger _logger = Logger();
  final Uuid _uuid = Uuid();

  String? _currentToken;
  String? _currentUserId;
  Timer? _sessionTimer;

  /// Get current authentication token
  String? get currentToken => _currentToken;

  /// Get current user ID
  String? get currentUserId => _currentUserId;

  /// Check if user is authenticated
  bool get isAuthenticated => _currentToken != null && _currentUserId != null;

  /// Initialize authentication service
  Future<void> initialize() async {
    try {
      _logger.i('Initializing authentication service');

      // Load saved authentication state
      await _loadAuthState();

      // Start session monitoring
      _startSessionMonitoring();

      _logger.i('Authentication service initialized');
    } catch (e) {
      _logger.e('Failed to initialize authentication service', e);
      throw AuthException('Failed to initialize authentication: ${e.toString()}');
    }
  }

  /// Load saved authentication state
  Future<void> _loadAuthState() async {
    // In a real implementation, this would load from secure storage
    // For this example, we'll simulate loading from memory
    _currentToken = null; // Would load from secure storage
    _currentUserId = null; // Would load from secure storage
  }

  /// Start session monitoring
  void _startSessionMonitoring() {
    // Cancel existing timer
    _sessionTimer?.cancel();

    // Start new session timer (24 hours default)
    _sessionTimer = Timer.periodic(Duration(hours: 1), (timer) {
      _checkSessionValidity();
    });

    _logger.d('Session monitoring started');
  }

  /// Check session validity
  void _checkSessionValidity() {
    if (!isAuthenticated) {
      _logger.d('No active session found');
      return;
    }

    // In a real implementation, check token expiration
    _logger.d('Session check: User $_currentUserId is authenticated');
  }

  /// Register new user
  Future<User> register({
    required String name,
    required String email,
    required String password,
    int age = 18,
  }) async {
    try {
      _logger.i('Registering user: $email');

      // Validate input
      if (!isValidEmail(email)) {
        throw AuthException('Invalid email format');
      }

      if (password.length < 8) {
        throw AuthException('Password must be at least 8 characters long');
      }

      if (name.trim().isEmpty) {
        throw AuthException('Name cannot be empty');
      }

      // Check if user already exists
      final existingUser = await _getUserByEmail(email);
      if (existingUser != null) {
        throw AuthException('User with this email already exists');
      }

      // Create new user
      final userId = _uuid.v4();
      final hashedPassword = _hashPassword(password);
      final now = DateTime.now();

      final user = User(
        id: userId,
        name: name.trim(),
        email: email.toLowerCase().trim(),
        age: age,
        createdAt: now,
        metadata: {
          'hashed_password': hashedPassword,
          'registration_ip': '127.0.0.1', // Would get from request
          'user_agent': 'DartScanProject/1.0.0',
        },
      );

      // Save user to database (in real implementation)
      await _saveUserToDatabase(user);

      _logger.i('User registered successfully: $userId');
      return user;
    } catch (e) {
      _logger.e('Failed to register user $email', e);
      rethrow;
    }
  }

  /// Login user
  Future<User> login({
    required String email,
    required String password,
  }) async {
    try {
      _logger.i('Logging in user: $email');

      // Validate input
      if (!isValidEmail(email)) {
        throw AuthException('Invalid email format');
      }

      // Get user by email
      final user = await _getUserByEmail(email);
      if (user == null) {
        throw AuthException('Invalid email or password');
      }

      // Verify password
      if (!await _verifyPassword(password, user)) {
        throw AuthException('Invalid email or password');
      }

      // Check if user is active
      if (!user.isActive) {
        throw AuthException('Account is disabled');
      }

      // Generate tokens
      _currentUserId = user.id;
      _currentToken = _generateToken(user.id);
      final refreshToken = _generateRefreshToken(user.id);

      // Save authentication state
      await _saveAuthState(_currentToken!, refreshToken, user.id);

      // Log session
      await _logSession(user.id, 'login');

      _logger.i('User logged in successfully: ${user.id}');
      return user;
    } catch (e) {
      _logger.e('Failed to login user $email', e);
      rethrow;
    }
  }

  /// Logout user
  Future<void> logout() async {
    try {
      if (!isAuthenticated) {
        _logger.w('Logout called but no active session');
        return;
      }

      _logger.i('Logging out user: $_currentUserId');

      // Log session
      if (_currentUserId != null) {
        await _logSession(_currentUserId!, 'logout');
      }

      // Clear authentication state
      await _clearAuthState();

      // Reset current state
      _currentToken = null;
      _currentUserId = null;

      _logger.i('User logged out successfully');
    } catch (e) {
      _logger.e('Failed to logout user', e);
      rethrow;
    }
  }

  /// Refresh authentication token
  Future<String?> refreshToken() async {
    try {
      if (!isAuthenticated) {
        throw AuthException('No active session to refresh');
      }

      _logger.d('Refreshing token for user: $_currentUserId');

      // In a real implementation, validate refresh token with server
      _currentToken = _generateToken(_currentUserId!);

      // Update saved state
      await _saveAuthState(_currentToken!, '', _currentUserId!);

      _logger.i('Token refreshed successfully');
      return _currentToken;
    } catch (e) {
      _logger.e('Failed to refresh token', e);
      // Clear invalid session
      await logout();
      throw AuthException('Failed to refresh token: ${e.toString()}');
    }
  }

  /// Change password
  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    try {
      if (!isAuthenticated) {
        throw AuthException('Not authenticated');
      }

      if (newPassword.length < 8) {
        throw AuthException('New password must be at least 8 characters long');
      }

      // Get current user
      final user = await _getUserById(_currentUserId!);
      if (user == null) {
        throw AuthException('User not found');
      }

      // Verify current password
      if (!await _verifyPassword(currentPassword, user)) {
        throw AuthException('Current password is incorrect');
      }

      // Update password
      await _updateUserPassword(user.id, _hashPassword(newPassword));

      _logger.i('Password changed successfully for user: ${user.id}');
    } catch (e) {
      _logger.e('Failed to change password', e);
      rethrow;
    }
  }

  /// Reset password (admin function)
  Future<void> resetPassword(String email) async {
    try {
      _logger.i('Resetting password for: $email');

      final user = await _getUserByEmail(email);
      if (user == null) {
        _logger.w('Password reset attempted for non-existent email: $email');
        return; // Don't reveal if email exists
      }

      // Generate temporary password
      final tempPassword = _generateTemporaryPassword();

      // Update password
      await _updateUserPassword(user.id, _hashPassword(tempPassword));

      // In a real implementation, send email with temporary password
      _logger.i('Temporary password generated for user: ${user.id}');

    } catch (e) {
      _logger.e('Failed to reset password for $email', e);
      rethrow;
    }
  }

  /// Validate email format
  bool isValidEmail(String email) {
    final emailRegex = RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');
    return emailRegex.hasMatch(email);
  }

  /// Hash password
  String _hashPassword(String password) {
    final bytes = utf8.encode(password);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  /// Verify password
  Future<bool> _verifyPassword(String password, User user) async {
    final hashedInput = _hashPassword(password);
    final storedHash = user.metadata?['hashed_password'] as String?;

    return storedHash != null && storedHash == hashedInput;
  }

  /// Generate authentication token
  String _generateToken(String userId) {
    final timestamp = DateTime.now().millisecondsSinceEpoch.toString();
    final data = '$userId:$timestamp';
    final bytes = utf8.encode(data);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  /// Generate refresh token
  String _generateRefreshToken(String userId) {
    final timestamp = DateTime.now().millisecondsSinceEpoch.toString();
    final random = _uuid.v4();
    final data = '$userId:$timestamp:$random';
    final bytes = utf8.encode(data);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  /// Generate temporary password
  String _generateTemporaryPassword() {
    const chars = 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789!@#\$%^&*';
    final random = _uuid.v4().replaceAll('-', '');
    return random.substring(0, 12) + '!A1';
  }

  /// Save authentication state
  Future<void> _saveAuthState(String token, String refreshToken, String userId) async {
    // In a real implementation, save to secure storage
    _currentToken = token;
    // await _secureStorage.write(key: _tokenKey, value: token);
    // await _secureStorage.write(key: _refreshTokenKey, value: refreshToken);
    // await _secureStorage.write(key: _userIdKey, value: userId);
  }

  /// Clear authentication state
  Future<void> _clearAuthState() async {
    // In a real implementation, clear from secure storage
    _currentToken = null;
    _currentUserId = null;
    // await _secureStorage.delete(key: _tokenKey);
    // await _secureStorage.delete(key: _refreshTokenKey);
    // await _secureStorage.delete(key: _userIdKey);
  }

  /// Get user by email (simulated)
  Future<User?> _getUserByEmail(String email) async {
    // In a real implementation, query database
    // For this example, return null
    return null;
  }

  /// Get user by ID (simulated)
  Future<User?> _getUserById(String id) async {
    // In a real implementation, query database
    // For this example, return null
    return null;
  }

  /// Save user to database (simulated)
  Future<void> _saveUserToDatabase(User user) async {
    // In a real implementation, save to database
    _logger.d('User would be saved to database: ${user.id}');
  }

  /// Update user password (simulated)
  Future<void> _updateUserPassword(String userId, String hashedPassword) async {
    // In a real implementation, update database
    _logger.d('Password would be updated for user: $userId');
  }

  /// Log session activity (simulated)
  Future<void> _logSession(String userId, String action) async {
    // In a real implementation, log to database
    _logger.d('Session logged: $action for user $userId');
  }

  /// Dispose resources
  void dispose() {
    _sessionTimer?.cancel();
    _logger.i('Authentication service disposed');
  }
}

/// Custom exception for authentication errors
class AuthException implements Exception {
  final String message;

  AuthException(this.message);

  @override
  String toString() => 'AuthException: $message';
}
