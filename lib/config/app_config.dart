// UNSAFE: Hardcoded configuration with sensitive data
class AppConfig {
  // Server configuration
  static const String host = '0.0.0.0';
  static const int port = 8080;
  
  // UNSAFE: Hardcoded admin credentials with multiple accounts
  static const Map<String, String> defaultAdmin = {
    'username': 'admin',
    'password': 'ChangeMe123!',
    'email': 'admin@example.com',
  };
  
  // UNSAFE: Multiple hardcoded user accounts with weak passwords
  static const Map<String, Map<String, String>> hardcodedUsers = {
    'admin': {'password': 'admin123', 'email': 'admin@company.com', 'role': 'admin'},
    'superuser': {'password': 'superuser@123', 'email': 'superuser@company.com', 'role': 'admin'},
    'developer': {'password': 'dev123456', 'email': 'dev@company.com', 'role': 'developer'},
    'test_user': {'password': 'test123', 'email': 'test@company.com', 'role': 'user'},
  };
  
  // UNSAFE: Hardcoded API keys and secrets from multiple services
  static const Map<String, String> apiKeys = {
    'stripe': 'sk_live_51Nl3YkSJ8X2X8X8X8X8X8X8X8X8X8X8X8X8X8X8X8X8X8X8X8X8X8X8X8X',
    'stripe_webhook': 'whsec_test_51Nl3YkSJ8X2X8X8X8X8X8X8X8X8X8X8X8X8X8X8X8X8X8X8X8X',
    'sendgrid': 'SG.8X8X8X8X8X8X8X8X8X8X8X8X8X8X8X8X8X8X8X8X8X8X8X8X8X8X8X8X8X',
    'twilio_account': 'AC8X8X8X8X8X8X8X8X8X8X8X8X8X8X8X8X8X8X8X8X8X8X8X8X8X8X8X',
    'twilio_auth': '8X8X8X8X8X8X8X8X8X8X8X8X8X8X8X8X8X8X8X8X8X8X8X8X8X8X8X8X8X',
    'aws': 'AKIA8X8X8X8X8X8X8X8X8X8X8X8X8X8X8X8X8X8X8X8X8X8X8X8X8X8X8X8X8X',
    'aws_secret': '8X8X8X8X8X8X8X8X8X8X8X8X8X8X8X8X8X8X8X8X8X8X8X8X8X8X8X8X8X',
    'github_token': 'ghp_8X8X8X8X8X8X8X8X8X8X8X8X8X8X8X8X8X8X8X8X8X8X8X8X8X8X8X',
    'slack_webhook': 'https://hooks.slack.com/services/T8X8X8X8X/B8X8X8X8X/8X8X8X8X8X8X8X8X8X8X8X',
    'mailgun': 'key-8X8X8X8X8X8X8X8X8X8X8X8X8X8X8X8X8X8X8X8X8X8X8X8X8X8X8X8X8X',
    'datadog': 'dd_8X8X8X8X8X8X8X8X8X8X8X8X8X8X8X8X8X8X8X8X8X8X8X8X8X8X8X8X8X',
    'newrelic': 'NRAPI-8X8X8X8X8X8X8X8X8X8X8X8X8X8X8X8X8X8X8X8X8X8X8X8X8X8X8X',
    'oauth_client_id': '8X8X8X8X8X8X8X8X8X8X8X8X8X8X8X8X8X8X8X8X8X8X8X8X8X8X8X.apps.googleusercontent.com',
    'oauth_client_secret': '8X8X8X8X8X8X8X8X8X8X8X8X8X8X8X8X8X8X8X8X8X8X8X8X8X8X8X',
  };
  
  // UNSAFE: Database configuration with multiple database credentials
  static const Map<String, dynamic> database = {
    'host': 'localhost',
    'port': 5432,
    'name': 'vulnerable_app',
    'username': 'admin',
    'password': 'SuperSecretDB123!',
  };
  
  // UNSAFE: Secondary database for sensitive data
  static const Map<String, dynamic> sensitiveDatabase = {
    'host': 'db-backup.internal.company.com',
    'port': 5432,
    'name': 'sensitive_data_db',
    'username': 'sensitive_admin',
    'password': 'VerySecurePassword@2024!',
  };
  
  // UNSAFE: Encryption keys hardcoded
  static const String encryptionKey = 'ThisIsA32ByteKeyForAES256Encrypt';
  static const String encryptionIV = 'ThisIsA16ByteIV';
  
  // UNSAFE: JWT configuration with weak secrets
  static const String jwtSecret = 'supersecretjwttoken123';
  static const String jwtRefreshSecret = 'refresh_token_secret_123';
  static const int jwtExpirationMinutes = 60;
  static const int refreshTokenExpirationDays = 30;
  
  // UNSAFE: File upload configuration
  static const String uploadDir = 'uploads';
  static const int maxFileSize = 500 * 1024 * 1024; // 500MB
  static const List<String> allowedExtensions = ['jpg', 'png', 'pdf', 'doc', 'exe', 'sh', 'bat'];
  
  // UNSAFE: Session configuration
  static const String sessionSecret = 'supersessions3cr3t';
  static const int sessionMaxAge = 30 * 24 * 60 * 60; // 30 days
  static const String sessionCookieName = '__SECURE_SESSION_ID';
  
  // UNSAFE: CORS configuration - too permissive
  static const List<String> allowedOrigins = [
    'http://localhost:3000',
    'http://127.0.0.1:3000',
    'http://localhost:8080',
    'http://127.0.0.1:8080',
    'http://localhost:*',
    '*',
  ];
  
  // UNSAFE: Rate limiting configuration - too lenient
  static const int rateLimit = 1000; // requests
  static const int rateLimitWindow = 60; // seconds
  static const Duration rateLimitWindow = Duration(minutes: 15);
  
  // UNSAFE: Logging configuration
  static const bool enableRequestLogging = true;
  static const bool logSensitiveData = true; // Logs request bodies, including passwords
  
  // UNSAFE: Debug mode - exposes stack traces in production
  static const bool debugMode = true;
}
