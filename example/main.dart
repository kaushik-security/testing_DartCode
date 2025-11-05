import 'package:dart_scan_project/dart_scan_project.dart';
import 'package:dart_scan_project/src/models/user.dart';
import 'package:dart_scan_project/src/utils/security_utils.dart';
import 'package:dart_scan_project/src/utils/crypto_utils.dart';

/// Example usage of the Dart Scan Project library
Future<void> main() async {
  print('=== Dart Scan Project Demo ===\n');

  // Initialize the application
  final app = DartScanApp();
  await app.initialize();

  try {
    // Get application information
    final appInfo = app.getAppInfo();
    print('Application: ${appInfo['name']} v${appInfo['version']}');
    print('Platform: ${appInfo['platform']}\n');

    // Demonstrate user creation and validation
    print('=== User Management Demo ===');
    final user = User(
      id: 'demo-user-123',
      name: 'Demo User',
      email: 'demo@example.com',
      age: 28,
      metadata: {
        'registration_source': 'demo',
        'preferences': {'theme': 'dark', 'notifications': true},
      },
    );

    print('Created user: ${user.name} (${user.email})');
    print('User validation: ${app.isValidUser(user) ? 'VALID' : 'INVALID'}');

    // Process user data (this will demonstrate various security checks)
    await app.processUserData(user);
    print('User data processed successfully\n');

    // Demonstrate security utilities
    print('=== Security Utilities Demo ===');

    // Input validation
    const testInput = 'normal user input';
    print('Input validation: "${testInput.isSafeInput ? 'SAFE' : 'UNSAFE'}"');

    const maliciousInput = '<script>alert("xss")</script>';
    print('Malicious input: "${maliciousInput.isSafeInput ? 'SAFE' : 'UNSAFE'}"');

    // Password strength checking
    const weakPassword = '123';
    const strongPassword = 'StrongP@ssw0rd2023!';

    print('Password strength - Weak: ${SecurityUtils.checkPasswordStrength(weakPassword)}');
    print('Password strength - Strong: ${SecurityUtils.checkPasswordStrength(strongPassword)}');

    // Data sanitization
    final userData = {
      'name': 'John Doe',
      'email': 'john@example.com',
      'password': 'secret123',
      'api_key': 'sk_test_123456789',
    };

    final sanitizedData = SecurityUtils.sanitizeUserData(userData);
    print('Original data keys: ${userData.keys.join(', ')}');
    print('Sanitized data keys: ${sanitizedData.keys.join(', ')}\n');

    // Demonstrate cryptographic utilities
    print('=== Cryptographic Utilities Demo ===');

    // Hashing
    const sensitiveData = 'sensitive information';
    final hash = CryptoUtils.hashString(sensitiveData);
    print('SHA-256 hash: ${hash.substring(0, 16)}...');

    // HMAC generation
    const message = 'secure message';
    const secret = 'my_secret_key';
    final hmac = CryptoUtils.generateHMAC(message, secret);
    print('HMAC signature: ${hmac.substring(0, 16)}...');

    // Secure random generation
    final randomString = CryptoUtils.generateSecureRandomString(16);
    print('Secure random: $randomString');

    final otp = CryptoUtils.generateOTP();
    print('Generated OTP: $otp');

    // API key generation
    final apiKey = CryptoUtils.generateApiKey();
    print('Generated API key: ${apiKey.substring(0, 20)}...\n');

    // Demonstrate file operations (commented out to avoid file system operations)
    print('=== File Operations Demo ===');
    print('File operations available in FileUtils class');
    print('- Safe file reading/writing');
    print('- File type detection');
    print('- Hash calculation');
    print('- Directory listing with security filters\n');

    // Generate secure token
    final token = app.generateSecureToken();
    print('Generated secure token: $token\n');

    // Database statistics (simulated)
    print('=== Database Operations ===');
    print('Database operations available in DatabaseService class');
    print('- User management');
    print('- Product catalog');
    print('- Session tracking');
    print('- Statistics and monitoring\n');

    // Authentication demo (simulated)
    print('=== Authentication Demo ===');
    print('Authentication operations available in AuthService class');
    print('- User registration and login');
    print('- Password hashing and verification');
    print('- Session management');
    print('- Token refresh\n');

    print('=== Demo completed successfully! ===');
    print('\nThis project demonstrates:');
    print('✓ Security best practices');
    print('✓ Input validation and sanitization');
    print('✓ Cryptographic operations');
    print('✓ Data models and serialization');
    print('✓ API integration patterns');
    print('✓ Database operations');
    print('✓ Authentication flows');
    print('✓ File handling security');
    print('✓ Comprehensive testing');
    print('✓ Code analysis configuration');

  } catch (e) {
    print('Error during demo: $e');
  } finally {
    // Clean up resources
    app.dispose();
    print('\nApplication disposed successfully.');
  }
}
