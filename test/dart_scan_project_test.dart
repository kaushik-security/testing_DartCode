import 'package:test/test.dart';
import 'package:dart_scan_project/dart_scan_project.dart';
import 'package:dart_scan_project/src/models/user.dart';
import 'package:dart_scan_project/src/utils/security_utils.dart';
import 'package:dart_scan_project/src/utils/crypto_utils.dart';

void main() {
  group('DartScanProject Tests', () {
    late DartScanApp app;

    setUp(() {
      app = DartScanApp();
    });

    tearDown(() {
      app.dispose();
    });

    test('App initializes correctly', () {
      final appInfo = app.getAppInfo();
      expect(appInfo['name'], equals('Dart Scan Project'));
      expect(appInfo['version'], equals('1.0.0'));
      expect(appInfo['platform'], isNotEmpty);
    });

    test('Generates secure token', () {
      final token1 = app.generateSecureToken();
      final token2 = app.generateSecureToken();

      expect(token1, isNotEmpty);
      expect(token2, isNotEmpty);
      expect(token1, isNotEquals(token2));
      expect(token1.length, equals(36)); // UUID v4 length
    });

    test('Validates user data correctly', () {
      final validUser = User(
        id: 'test-id',
        name: 'Test User',
        email: 'test@example.com',
        age: 25,
      );

      expect(app.isValidUser(validUser), isTrue);

      final invalidUser = User(
        id: '',
        name: '',
        email: 'invalid-email',
        age: -1,
      );

      expect(app.isValidUser(invalidUser), isFalse);
    });

    test('Processes user data successfully', () async {
      final user = User(
        id: 'test-id',
        name: 'Test User',
        email: 'test@example.com',
        age: 25,
      );

      // This should not throw an exception
      await expectLater(
        app.processUserData(user),
        completes,
      );
    });
  });

  group('SecurityUtils Tests', () {
    test('Sanitizes user data correctly', () {
      final userData = {
        'name': 'John Doe',
        'email': 'john@example.com',
        'password': 'secret123',
        'token': 'abc123',
        'metadata': {
          'api_key': 'key123',
          'secret': 'hidden',
        },
      };

      final sanitized = SecurityUtils.sanitizeUserData(userData);

      expect(sanitized.containsKey('name'), isTrue);
      expect(sanitized.containsKey('email'), isTrue);
      expect(sanitized.containsKey('password'), isFalse);
      expect(sanitized.containsKey('token'), isFalse);
      expect(sanitized['metadata'] is Map, isTrue);

      final metadata = sanitized['metadata'] as Map<String, dynamic>;
      expect(metadata.containsKey('api_key'), isFalse);
      expect(metadata.containsKey('secret'), isFalse);
    });

    test('Validates input correctly', () {
      expect(SecurityUtils.isValidInput('normal text'), isTrue);
      expect(SecurityUtils.isValidInput('<script>alert("xss")</script>'), isFalse);
      expect(SecurityUtils.isValidInput('javascript:alert("xss")'), isFalse);
      expect(SecurityUtils.isValidInput(''), isFalse);
      expect(SecurityUtils.isValidInput('a' * 2000), isFalse);
    });

    test('Sanitizes filenames correctly', () {
      expect(SecurityUtils.sanitizeFilename('normal_file.txt'), equals('normal_file.txt'));
      expect(SecurityUtils.sanitizeFilename('../../../etc/passwd'), equals('etc_passwd'));
      expect(SecurityUtils.sanitizeFilename('file<script>.txt'), equals('file_script_.txt'));
      expect(SecurityUtils.sanitizeFilename(''), equals('unnamed_file'));
    });

    test('Validates email format', () {
      expect('test@example.com'.isValidEmail, isTrue);
      expect('invalid-email'.isValidEmail, isFalse);
      expect(''.isValidEmail, isFalse);
      expect('@example.com'.isValidEmail, isFalse);
      expect('test@'.isValidEmail, isFalse);
    });

    test('Validates URLs correctly', () {
      expect(SecurityUtils.isValidUrl('https://example.com'), isTrue);
      expect(SecurityUtils.isValidUrl('http://example.com'), isTrue);
      expect(SecurityUtils.isValidUrl('ftp://example.com'), isFalse);
      expect(SecurityUtils.isValidUrl('javascript:alert("xss")'), isFalse);
      expect(SecurityUtils.isValidUrl('invalid-url'), isFalse);
    });

    test('Generates secure random strings', () {
      final random1 = SecurityUtils.generateSecureRandomString(10);
      final random2 = SecurityUtils.generateSecureRandomString(10);

      expect(random1.length, equals(10));
      expect(random2.length, equals(10));
      expect(random1, isNotEquals(random2));
      expect(RegExp(r'^[a-zA-Z0-9]+$').hasMatch(random1), isTrue);
    });

    test('Checks password strength', () {
      expect(SecurityUtils.checkPasswordStrength('weak'), equals(PasswordStrength.veryWeak));
      expect(SecurityUtils.checkPasswordStrength('password123'), equals(PasswordStrength.weak));
      expect(SecurityUtils.checkPasswordStrength('Password123'), equals(PasswordStrength.fair));
      expect(SecurityUtils.checkPasswordStrength('Password123!'), equals(PasswordStrength.good));
      expect(SecurityUtils.checkPasswordStrength('StrongP@ssw0rd!2023'), equals(PasswordStrength.strong));
    });

    test('Rate limiting works correctly', () {
      const identifier = 'test-user';

      // Should allow first few requests
      for (var i = 0; i < 5; i++) {
        expect(SecurityUtils.checkRateLimit(identifier, maxRequests: 10), isTrue);
      }

      // Should still allow more requests within limit
      expect(SecurityUtils.checkRateLimit(identifier, maxRequests: 10), isTrue);
    });

    test('Validates API keys correctly', () {
      expect(SecurityUtils.isValidApiKey('dsp_a1b2c3d4e5f6g7h8i9j0k1l2m3n4o5p6'), isTrue);
      expect(SecurityUtils.isValidApiKey('short'), isFalse);
      expect(SecurityUtils.isValidApiKey(''), isFalse);
      expect(SecurityUtils.isValidApiKey('key with spaces'), isFalse);
    });

    test('Masks sensitive data correctly', () {
      expect(SecurityUtils.maskSensitiveData('1234567890'), equals('1234****90'));
      expect(SecurityUtils.maskSensitiveData('short'), equals('*****'));
      expect(SecurityUtils.maskSensitiveData('a1b2c3d4e5f6'), equals('a1b2****f6'));
    });
  });

  group('CryptoUtils Tests', () {
    test('Hashes strings consistently', () {
      const data = 'test data';
      final hash1 = CryptoUtils.hashString(data);
      final hash2 = CryptoUtils.hashString(data);

      expect(hash1, equals(hash2));
      expect(hash1.length, equals(64)); // SHA-256 produces 64 character hex string
      expect(hash1, isNotEmpty);
    });

    test('Generates HMAC correctly', () {
      const data = 'test message';
      const key = 'secret key';

      final signature1 = CryptoUtils.generateHMAC(data, key);
      final signature2 = CryptoUtils.generateHMAC(data, key);

      expect(signature1, equals(signature2));
      expect(signature1, isNotEmpty);
    });

    test('Verifies HMAC correctly', () {
      const data = 'test message';
      const key = 'secret key';
      const signature = 'expected_signature';

      // This test would need a pre-computed signature in a real scenario
      expect(CryptoUtils.verifyHMAC(data, key, signature), isFalse); // Will fail with random signature
    });

    test('Generates secure random bytes', () {
      final bytes1 = CryptoUtils.generateRandomBytes(32);
      final bytes2 = CryptoUtils.generateRandomBytes(32);

      expect(bytes1.length, equals(32));
      expect(bytes2.length, equals(32));
      expect(bytes1, isNotEquals(bytes2));
    });

    test('Generates secure random strings', () {
      final random1 = CryptoUtils.generateSecureRandomString(20);
      final random2 = CryptoUtils.generateSecureRandomString(20);

      expect(random1.length, equals(20));
      expect(random2.length, equals(20));
      expect(random1, isNotEquals(random2));
      expect(RegExp(r'^[a-zA-Z0-9]+$').hasMatch(random1), isTrue);
    });

    test('Encodes and decodes Base64 correctly', () {
      const original = 'Hello, World!';
      final encoded = CryptoUtils.encodeBase64(original);
      final decoded = CryptoUtils.decodeBase64(encoded);

      expect(decoded, equals(original));
      expect(encoded, isNotEmpty);
    });

    test('Generates valid API keys', () {
      final apiKey = CryptoUtils.generateApiKey();
      expect(apiKey.startsWith('dsp_'), isTrue);
      expect(apiKey.length, greaterThan(30));
      expect(CryptoUtils.isValidApiKey(apiKey), isTrue);
    });

    test('Generates OTP correctly', () {
      final otp = CryptoUtils.generateOTP();
      expect(otp.length, equals(6));
      expect(RegExp(r'^[0-9]+$').hasMatch(otp), isTrue);

      final otp8 = CryptoUtils.generateOTP(length: 8);
      expect(otp8.length, equals(8));
    });

    test('Calculates entropy correctly', () {
      expect(CryptoUtils.calculateEntropy(''), equals(0.0));
      expect(CryptoUtils.calculateEntropy('aaaa'), closeTo(0.0, 0.1));
      expect(CryptoUtils.calculateEntropy('random text with variety'), greaterThan(3.0));
    });

    test('Detects encrypted-looking data', () {
      expect(CryptoUtils.looksLikeEncrypted('normal text'), isFalse);
      expect(CryptoUtils.looksLikeEncrypted('SGVsbG8gV29ybGQ='), isFalse); // Base64 of "Hello World"
      expect(CryptoUtils.looksLikeEncrypted('short'), isFalse);
    });

    test('Caesar cipher works correctly', () {
      const original = 'Hello World';
      const shift = 3;

      final encrypted = CryptoUtils.caesarEncrypt(original, shift);
      final decrypted = CryptoUtils.caesarDecrypt(encrypted, shift);

      expect(decrypted, equals(original));
      expect(encrypted, isNotEquals(original));
    });
  });

  group('User Model Tests', () {
    test('Creates user correctly', () {
      final user = User(
        id: 'test-id',
        name: 'Test User',
        email: 'test@example.com',
        age: 25,
      );

      expect(user.id, equals('test-id'));
      expect(user.name, equals('Test User'));
      expect(user.email, equals('test@example.com'));
      expect(user.age, equals(25));
      expect(user.isActive, isTrue);
      expect(user.createdAt, isNotNull);
    });

    test('Serializes to JSON correctly', () {
      final user = User(
        id: 'test-id',
        name: 'Test User',
        email: 'test@example.com',
        age: 25,
        isActive: false,
        metadata: {'key': 'value'},
      );

      final json = user.toJson();

      expect(json['id'], equals('test-id'));
      expect(json['name'], equals('Test User'));
      expect(json['email'], equals('test@example.com'));
      expect(json['age'], equals(25));
      expect(json['is_active'], equals(false));
      expect(json['metadata'], equals({'key': 'value'}));
    });

    test('Deserializes from JSON correctly', () {
      final json = {
        'id': 'test-id',
        'name': 'Test User',
        'email': 'test@example.com',
        'age': 25,
        'created_at': '2023-01-01T00:00:00.000',
        'is_active': true,
        'metadata': {'key': 'value'},
      };

      final user = User.fromJson(json);

      expect(user.id, equals('test-id'));
      expect(user.name, equals('Test User'));
      expect(user.email, equals('test@example.com'));
      expect(user.age, equals(25));
      expect(user.isActive, isTrue);
      expect(user.metadata, equals({'key': 'value'}));
    });

    test('Copy with works correctly', () {
      final user = User(
        id: 'test-id',
        name: 'Test User',
        email: 'test@example.com',
        age: 25,
      );

      final copied = user.copyWith(name: 'New Name', age: 30);

      expect(copied.id, equals('test-id'));
      expect(copied.name, equals('New Name'));
      expect(copied.email, equals('test@example.com'));
      expect(copied.age, equals(30));
    });

    test('Equality works correctly', () {
      final user1 = User(
        id: 'test-id',
        name: 'Test User',
        email: 'test@example.com',
        age: 25,
      );

      final user2 = User(
        id: 'test-id',
        name: 'Different Name',
        email: 'different@example.com',
        age: 30,
      );

      final user3 = User(
        id: 'different-id',
        name: 'Test User',
        email: 'test@example.com',
        age: 25,
      );

      expect(user1 == user2, isTrue); // Same ID
      expect(user1 == user3, isFalse); // Different ID
    });
  });
}
