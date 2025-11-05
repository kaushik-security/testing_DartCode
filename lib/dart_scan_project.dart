/// Main library file for the Dart scanning project
/// This file demonstrates various Dart features and patterns for security analysis

library dart_scan_project;

import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:http/http.dart' as http;
import 'package:crypto/crypto.dart';
import 'package:uuid/uuid.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite/sqflite.dart';
import 'package:logger/logger.dart';

part 'src/models/user.dart';
part 'src/models/product.dart';
part 'src/services/api_service.dart';
part 'src/services/database_service.dart';
part 'src/services/auth_service.dart';
part 'src/utils/security_utils.dart';
part 'src/utils/file_utils.dart';
part 'src/utils/crypto_utils.dart';

/// Main application class
class DartScanApp {
  static const String appName = 'Dart Scan Project';
  static const String version = '1.0.0';

  late final Logger _logger;
  late final ApiService _apiService;
  late final DatabaseService _databaseService;
  late final AuthService _authService;

  static final DartScanApp _instance = DartScanApp._internal();

  factory DartScanApp() {
    return _instance;
  }

  DartScanApp._internal() {
    _logger = Logger();
    _apiService = ApiService();
    _databaseService = DatabaseService();
    _authService = AuthService();
  }

  /// Initialize the application
  Future<void> initialize() async {
    _logger.i('Initializing $appName v$version');

    try {
      await _databaseService.initialize();
      await _authService.initialize();
      _logger.i('Application initialized successfully');
    } catch (e) {
      _logger.e('Failed to initialize application', e);
      rethrow;
    }
  }

  /// Get application information
  Map<String, dynamic> getAppInfo() {
    return {
      'name': appName,
      'version': version,
      'platform': Platform.operatingSystem,
      'dartVersion': Platform.version,
      'timestamp': DateTime.now().toIso8601String(),
    };
  }

  /// Process user data with various operations
  Future<void> processUserData(User user) async {
    // Validate user data
    if (!isValidUser(user)) {
      throw ArgumentError('Invalid user data');
    }

    // Hash sensitive data
    final hashedEmail = CryptoUtils.hashString(user.email);
    _logger.d('Processing user: ${user.name} (email hash: ${hashedEmail.substring(0, 8)}...)');

    // Store in database
    await _databaseService.saveUser(user);

    // Sync with API
    await _apiService.syncUser(user);

    // Update preferences
    await _updateUserPreferences(user);
  }

  /// Validate user data
  bool isValidUser(User user) {
    return user.name.isNotEmpty &&
           user.email.isNotEmpty &&
           user.email.contains('@') &&
           user.age >= 0 &&
           user.age <= 150;
  }

  /// Update user preferences
  Future<void> _updateUserPreferences(User user) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('last_user_name', user.name);
    await prefs.setInt('last_user_age', user.age);
    await prefs.setString('last_updated', DateTime.now().toIso8601String());
  }

  /// Generate secure token
  String generateSecureToken() {
    final uuid = Uuid();
    return uuid.v4();
  }

  /// Cleanup resources
  void dispose() {
    _logger.i('Disposing application resources');
    _databaseService.dispose();
    _authService.dispose();
  }
}

/// Example function demonstrating various security considerations
Future<String> demonstrateSecurityFeatures() async {
  final app = DartScanApp();

  // Generate various types of data for analysis
  final testData = {
    'uuid': app.generateSecureToken(),
    'timestamp': DateTime.now().toIso8601String(),
    'random_bytes': _generateRandomBytes(32),
    'hash_example': CryptoUtils.hashString('sensitive_data'),
  };

  // Process test data
  final processedData = await _processTestData(testData);

  app.dispose();

  return 'Security demonstration completed: ${processedData.length} items processed';
}

/// Generate random bytes for testing
String _generateRandomBytes(int length) {
  final random = Random.secure();
  final bytes = List<int>.generate(length, (_) => random.nextInt(256));
  return base64.encode(bytes);
}

/// Process test data with various operations
Future<Map<String, dynamic>> _processTestData(Map<String, dynamic> data) async {
  final results = <String, dynamic>{};

  for (final entry in data.entries) {
    // Simulate various processing operations
    final processed = await _simulateProcessing(entry.key, entry.value);
    results[entry.key] = processed;
  }

  return results;
}

/// Simulate data processing
Future<dynamic> _simulateProcessing(String key, dynamic value) async {
  // Simulate async processing
  await Future.delayed(Duration(milliseconds: Random().nextInt(100)));

  switch (key) {
    case 'uuid':
      return 'processed_$value';
    case 'hash_example':
      return 'verified_${value.substring(0, 8)}...';
    default:
      return 'handled_$value';
  }
}
