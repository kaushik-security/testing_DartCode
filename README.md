# Dart Scan Project

A comprehensive Dart project designed for security scanning and vulnerability detection. This project demonstrates various Dart/Flutter development patterns and includes extensive security utilities, data models, and services that are ideal for security analysis tools like Snyk.

## Features

- **Security Utilities**: Comprehensive security validation, input sanitization, and cryptographic functions
- **Data Models**: Strongly typed models with JSON serialization
- **API Services**: HTTP client with authentication, error handling, and security features
- **Database Services**: SQLite integration with proper schema management
- **Authentication Services**: User management, password hashing, and session handling
- **File Operations**: Safe file handling with security validations
- **Cryptographic Functions**: Various encryption, hashing, and secure random generation utilities
- **Comprehensive Testing**: Unit tests covering all major components
- **Code Analysis**: Configured for static analysis and linting

## Project Structure

```
lib/
├── dart_scan_project.dart          # Main library entry point
└── src/
    ├── models/                     # Data models
    │   ├── user.dart
    │   └── product.dart
    ├── services/                   # Business logic services
    │   ├── api_service.dart
    │   ├── database_service.dart
    │   └── auth_service.dart
    └── utils/                      # Utility functions
        ├── security_utils.dart
        ├── file_utils.dart
        └── crypto_utils.dart

test/                               # Unit tests
├── dart_scan_project_test.dart
├── product_model_test.dart
└── file_utils_test.dart

pubspec.yaml                        # Dependencies and project configuration
analysis_options.yaml               # Code analysis configuration
.gitignore                         # Git ignore patterns
README.md                          # This file
```

## Dependencies

This project includes a comprehensive set of dependencies that are commonly analyzed by security scanning tools:

### Core Dependencies
- **http**: HTTP client for API communications
- **dio**: Alternative HTTP client with advanced features
- **crypto**: Cryptographic functions and utilities
- **sqflite**: SQLite database for local storage
- **shared_preferences**: Local key-value storage
- **path_provider**: File system path utilities
- **uuid**: Universal unique identifier generation
- **logger**: Logging framework

### Security & Authentication
- **pointycastle**: Cryptographic primitives
- **local_auth**: Local authentication (biometrics)
- **firebase_auth**: Firebase authentication integration

### UI & State Management (Flutter)
- **provider**: State management
- **bloc**: Business logic component
- **flutter_riverpod**: Reactive state management

### Development & Testing
- **test**: Unit testing framework
- **mockito**: Mocking framework for tests
- **build_runner**: Code generation
- **json_serializable**: JSON serialization
- **flutter_lints**: Code linting rules

## Security Features

### Input Validation
- Email format validation
- URL security validation
- Input sanitization against XSS attacks
- File type validation
- Filename sanitization

### Authentication & Authorization
- Password strength validation
- Secure password hashing (SHA-256)
- Session management
- Token-based authentication
- Rate limiting protection

### Data Protection
- Sensitive data masking
- HMAC signature generation and verification
- Base64 encoding/decoding
- Secure random number generation
- File content validation

### Cryptographic Utilities
- Multiple hashing algorithms (MD5, SHA-1, SHA-256)
- HMAC implementations
- Secure random byte generation
- Password-based key derivation
- Entropy calculation

## Usage

### Basic Usage

```dart
import 'package:dart_scan_project/dart_scan_project.dart';

// Initialize the application
final app = DartScanApp();
await app.initialize();

// Create and process a user
final user = User(
  id: 'user-123',
  name: 'John Doe',
  email: 'john@example.com',
  age: 30,
);

await app.processUserData(user);

// Generate secure tokens
final token = app.generateSecureToken();
print('Generated token: $token');

// Get application information
final info = app.getAppInfo();
print('App: ${info['name']} v${info['version']}');

// Clean up
app.dispose();
```

### Security Utilities

```dart
import 'package:dart_scan_project/src/utils/security_utils.dart';

// Validate input
final isValid = SecurityUtils.isValidInput(userInput);
final isValidEmail = 'user@example.com'.isValidEmail;

// Sanitize data
final sanitized = SecurityUtils.sanitizeUserData(userData);

// Check password strength
final strength = SecurityUtils.checkPasswordStrength(password);

// Generate secure random data
final randomString = SecurityUtils.generateSecureRandomString(32);
```

### File Operations

```dart
import 'package:dart_scan_project/src/utils/file_utils.dart';

// Safe file operations
await FileUtils.writeFileSafely('path/to/file.txt', 'content');
final content = await FileUtils.readFileSafely('path/to/file.txt');

// File information
final info = await FileUtils.getFileInfo('path/to/file.txt');
print('File size: ${info.size} bytes');

// File type detection
final type = await FileUtils.detectFileType('path/to/file.txt');
```

### Cryptographic Functions

```dart
import 'package:dart_scan_project/src/utils/crypto_utils.dart';

// Hashing
final hash = CryptoUtils.hashString('sensitive data');

// HMAC
final signature = CryptoUtils.generateHMAC(data, key);
final isValid = CryptoUtils.verifyHMAC(data, key, signature);

// Secure random generation
final randomBytes = CryptoUtils.generateRandomBytes(32);
final randomString = CryptoUtils.generateSecureRandomString(64);
```

## Testing

Run the comprehensive test suite:

```bash
# Run all tests
dart test

# Run tests with coverage
dart test --coverage=coverage

# Run specific test file
dart test test/dart_scan_project_test.dart

# Run tests with specific patterns
dart test -n "SecurityUtils"
```

## Security Scanning

This project is specifically designed for security scanning tools like Snyk. It includes:

1. **Comprehensive Dependencies**: Wide range of packages with various security implications
2. **Security Patterns**: Demonstrates secure coding practices and common vulnerabilities
3. **Input Validation**: Multiple layers of input sanitization and validation
4. **Error Handling**: Proper exception handling and logging
5. **Code Quality**: Configured for static analysis and linting

### Snyk Configuration

The project includes security-focused configurations:

- **pubspec.yaml**: Comprehensive dependency list for vulnerability scanning
- **analysis_options.yaml**: Strict code analysis rules
- **Security Utilities**: Built-in security validation functions

## Configuration

### Code Analysis

The project uses strict analysis options defined in `analysis_options.yaml`:

```yaml
analyzer:
  strong-mode: true
  errors:
    unused_element: error
    unused_import: error
    unused_local_variable: error

linter:
  rules:
    - avoid_empty_else
    - avoid_relative_lib_imports
    - prefer_const_constructors
    - prefer_final_fields
    - prefer_single_quotes
    - unnecessary_brace_in_string_interps
```

### Dependencies

All dependencies are pinned to specific versions in `pubspec.yaml` to ensure reproducible builds and accurate security scanning.

## Contributing

1. Follow the existing code style and patterns
2. Add comprehensive tests for new features
3. Update documentation as needed
4. Ensure all tests pass before submitting changes
5. Follow security best practices

## License

This project is for educational and security scanning demonstration purposes.

## Security Considerations

This project demonstrates various security concepts but should not be used in production without proper security review:

- Password hashing uses SHA-256 (consider using bcrypt/scrypt for production)
- Simple XOR encryption is for educational purposes only
- File operations include security validations but may need additional hardening
- API implementations include basic security but require production hardening

For production use, consider:
- Using established security libraries
- Implementing proper encryption algorithms
- Adding comprehensive security audits
- Following security best practices for your specific use case
