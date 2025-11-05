// UNSAFE: Hardcoded configuration with sensitive data
class AppConfig {
  // Server configuration
  static const String host = '0.0.0.0';
  static const int port = 8080;
  
  // UNSAFE: Hardcoded admin credentials
  static const Map<String, String> defaultAdmin = {
    'username': 'admin',
    'password': 'ChangeMe123!',
    'email': 'admin@example.com',
  };
  
  // UNSAFE: Hardcoded API keys and secrets
  static const Map<String, String> apiKeys = {
    'stripe': 'sk_test_51Nl3YkSJ8X2X8X8X8X8X8X8X8X8X8X8X8X8X',
    'sendgrid': 'SG.8X8X8X8X8X8X8X8X8X8X8X8X8X8X8X8X8X8X8X8X8X',
    'aws': 'AKIA8X8X8X8X8X8X8X8X8X8X8X8X8X8X8X8X8X8X8X8X8X',
  };
  
  // UNSAFE: Database configuration
  static const Map<String, dynamic> database = {
    'host': 'localhost',
    'port': 5432,
    'name': 'vulnerable_app',
    'username': 'admin',
    'password': 'SuperSecretDB123!',
  };
  
  // UNSAFE: JWT configuration
  static const String jwtSecret = 'supersecretjwttoken123';
  
  // UNSAFE: File upload configuration
  static const String uploadDir = 'uploads';
  static const int maxFileSize = 50 * 1024 * 1024; // 50MB
  
  // UNSAFE: Session configuration
  static const String sessionSecret = 'supersessions3cr3t';
  static const int sessionMaxAge = 30 * 24 * 60 * 60; // 30 days
  
  // UNSAFE: CORS configuration
  static const List<String> allowedOrigins = [
    'http://localhost:3000',
    'http://127.0.0.1:3000',
    'http://localhost:8080',
    'http://127.0.0.1:8080',
  ];
  
  // UNSAFE: Rate limiting configuration
  static const int rateLimit = 100; // requests
  static const Duration rateLimitWindow = Duration(minutes: 15);
  
  // UNSAFE: Logging configuration
  static const bool enableRequestLogging = true;
  static const bool logSensitiveData = true; // Logs request bodies, including passwords
  
  // UNSAFE: Debug mode - exposes stack traces in production
  static const bool debugMode = true;
}
