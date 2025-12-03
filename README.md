# Advanced Vulnerable Dart Application

This is a deliberately vulnerable Dart application created for advanced security testing and educational purposes. It contains **30+ security vulnerabilities** spanning multiple categories including injection attacks, cryptographic failures, PII exposure, authentication bypass, and more.

## ⚠️ CRITICAL SECURITY WARNING ⚠️

**DO NOT deploy this application to any publicly accessible server or production environment.** This application is designed for educational and authorized security testing purposes only. Unauthorized access to systems using this code is illegal.

## 📊 Vulnerability Overview

- **Application Vulnerabilities:** 40+
- **Vulnerable Dependencies (SCA):** 24+
- **Critical Issues:** 8+
- **High Severity Issues:** 12+
- **Total Security Issues:** 64+

## Comprehensive Vulnerability List

### 1. Hardcoded Secrets & Credentials
- **Location**: `bin/main.dart`, `lib/config/app_config.dart`
- **Vulnerabilities**:
  - Hardcoded database credentials (admin/SuperSecret123!)
  - Multiple API keys exposed (Stripe, Twilio, AWS, SendGrid, Mailgun, etc.)
  - JWT secrets hardcoded in source code
  - Encryption keys and IVs hardcoded
  - OAuth tokens stored in plain text
  - Multiple user accounts with weak passwords
  - Webhook URLs hardcoded
  - Payment gateway credentials exposed

### 2. PII Data Exposure
- **Location**: `bin/main.dart`, `lib/services/pii_service.dart`
- **Endpoints**:
  - `GET /pii?user_id=1` - Retrieve individual PII
  - `GET /pii/all` - Retrieve all PII data
  - `GET /search/ssn?ssn=123-45-6789` - Search by SSN
  - `GET /search/card?card=4532-1234-5678-9010` - Search by credit card
- **Exposed Data**:
  - Social Security Numbers (SSN)
  - Full names and dates of birth
  - Credit card numbers and CVV codes
  - Phone numbers and addresses
  - Driver's license and passport numbers
  - Security questions and answers
  - Bank account and routing numbers
  - Location history
  - Activity logs

### 3. SQL Injection
- **Location**: `lib/services/database_service.dart`, `lib/services/injection_service.dart`
- **Endpoints**:
  - `GET /search?username=admin' OR '1'='1`
  - `GET /search/ssn?ssn=123-45-6789' OR '1'='1`
  - `GET /search/card?card=4532' OR '1'='1`
- **Vulnerable Functions**:
  - `searchUsers()` - Direct string interpolation
  - `authenticateUser()` - Login bypass via SQL injection
  - `updateUserProfile()` - Profile manipulation
  - `deleteUser()` - Unauthorized deletion
  - `searchBySSN()` - PII search injection
  - `searchByCredCard()` - Payment data injection

### 4. Cross-Site Scripting (XSS)
- **Location**: `bin/main.dart`
- **Endpoint**: `GET /xss?name=<script>alert('XSS')</script>`
- **Vulnerability**: User input directly embedded in HTML without escaping
- **Impact**: Session hijacking, credential theft, malware distribution

### 5. Insecure Direct Object Reference (IDOR)
- **Location**: `bin/main.dart`
- **Endpoints**:
  - `GET /pii?user_id=1` - Access any user's PII
  - `GET /session?session_id=session_123` - Access any session
  - `GET /data?user_id=1` - Access sensitive data
- **Vulnerability**: No authorization checks on resource access

### 6. Path Traversal
- **Location**: `bin/main.dart`, `lib/services/file_service.dart`
- **Endpoint**: `GET /file?file=../../etc/passwd`
- **Vulnerability**: Unvalidated file paths allow reading arbitrary files

### 7. Weak Cryptography
- **Location**: `lib/services/crypto_service.dart`
- **Vulnerabilities**:
  - MD5 hashing for passwords (cryptographically broken)
  - SHA-1 hashing (deprecated)
  - XOR encryption (trivially breakable)
  - Caesar cipher (trivial to break)
  - Base64 encoding used as encryption
  - Static IV in encryption
  - Weak random number generation
  - Predictable token generation

### 8. Broken Authentication
- **Location**: `bin/main.dart`, `lib/services/auth_service.dart`
- **Vulnerabilities**:
  - No rate limiting on login attempts
  - Predictable session tokens (based on timestamp)
  - No password hashing
  - Weak password requirements
  - Credentials logged in plain text
  - No multi-factor authentication
  - Session fixation possible
  - Weak JWT implementation with SHA-1

### 9. Insecure Session Management
- **Location**: `bin/main.dart`
- **Endpoints**:
  - `GET /session?session_id=session_123` - Retrieve session
  - `GET /sessions` - List all sessions
- **Vulnerabilities**:
  - Predictable session IDs
  - No session expiration
  - Sessions stored in memory (not persistent)
  - No CSRF protection
  - Session data exposed

### 10. Information Disclosure
- **Location**: `bin/main.dart`
- **Endpoints**:
  - `GET /secrets` - Expose all hardcoded secrets
  - `GET /debug` - Expose system information
  - `GET /logs` - Expose API logs with credentials
- **Exposed Information**:
  - Database credentials
  - API keys
  - System environment variables
  - User credentials
  - PII data
  - API request logs

### 11. Command Injection
- **Location**: `bin/main.dart`, `lib/services/injection_service.dart`
- **Endpoint**: `GET /cmd?cmd=ls%20-la`
- **Vulnerability**: User input directly passed to shell commands
- **Impact**: Remote code execution, system compromise

### 12. Insecure API Implementation
- **Location**: `lib/services/insecure_api_service.dart`
- **Vulnerabilities**:
  - No API key validation
  - API keys logged in plain text
  - No rate limiting
  - No signature verification on webhooks
  - Payment data stored without encryption
  - OAuth tokens stored in plain text
  - Hardcoded webhook URLs

### 13. Weak Password Reset
- **Location**: `bin/main.dart`
- **Endpoint**: `GET /reset-password?email=user@example.com`
- **Vulnerabilities**:
  - Predictable reset tokens (based on timestamp)
  - Reset tokens logged to console
  - No token expiration
  - No email verification

### 14. Insecure Payment Processing
- **Location**: `bin/main.dart`
- **Endpoint**: `GET /process-payment?card=4532-1234-5678-9010&cvv=123&amount=100`
- **Vulnerabilities**:
  - No input validation
  - Credit card data stored in logs
  - CVV stored in memory
  - No encryption
  - No PCI DSS compliance

### 15. LDAP Injection
- **Location**: `lib/services/injection_service.dart`
- **Vulnerability**: LDAP filter injection in authentication

### 16. XXE (XML External Entity)
- **Location**: `lib/services/injection_service.dart`
- **Vulnerability**: No XXE protection in XML parsing

### 17. NoSQL Injection
- **Location**: `lib/services/injection_service.dart`
- **Vulnerability**: Direct query execution without parameterization

### 18. Template Injection
- **Location**: `lib/services/injection_service.dart`
- **Vulnerability**: Direct template rendering with user input

### 19. Expression Language Injection
- **Location**: `lib/services/injection_service.dart`
- **Vulnerability**: User-provided expressions evaluated

### 20. Code Injection / Eval
- **Location**: `lib/services/injection_service.dart`
- **Vulnerability**: Direct code execution capability

### 21. Zip Slip Vulnerability
- **Location**: `lib/services/injection_service.dart`
- **Vulnerability**: No path validation in zip extraction

### 22. Insecure File Upload
- **Location**: `lib/services/file_service.dart`
- **Vulnerabilities**:
  - No file type validation
  - No size limits
  - Executable files allowed (.exe, .sh, .bat)
  - Path traversal in upload paths
  - MIME type guessing from extension

### 23. Directory Listing
- **Location**: `lib/services/file_service.dart`
- **Vulnerability**: Arbitrary directory listing without authentication

### 24. Insecure Deserialization
- **Location**: Multiple service files
- **Vulnerability**: Direct JSON deserialization without validation

### 25. Missing Access Control
- **Location**: All endpoints
- **Vulnerability**: No authentication/authorization on sensitive endpoints

### 26. Sensitive Data in Logs
- **Location**: `lib/services/pii_service.dart`, `lib/services/insecure_api_service.dart`
- **Vulnerabilities**:
  - Passwords logged
  - PII logged
  - API keys logged
  - Credit card data logged
  - Session tokens logged

### 27. Insecure Direct Communication
- **Location**: `lib/services/insecure_api_service.dart`
- **Vulnerability**: No HTTPS enforcement, webhook URLs hardcoded

### 28. Weak CORS Configuration
- **Location**: `lib/config/app_config.dart`
- **Vulnerability**: CORS allows '*' (all origins)

### 29. Debug Mode Enabled
- **Location**: `lib/config/app_config.dart`
- **Vulnerability**: Debug mode enabled in production, exposes stack traces

### 30. Insufficient Logging & Monitoring
- **Location**: All endpoints
- **Vulnerability**: No security event logging, no intrusion detection

## Setup Instructions

1. Install Dart SDK (if not already installed):
   ```bash
   brew install dart  # macOS
   ```

2. Install dependencies:
   ```bash
   cd /Users/kaushik.kumar/Movies/testing_DartCode
   dart pub get
   ```

3. Run the application:
   ```bash
   dart run bin/main.dart
   ```

4. The server will start on `http://localhost:8080`

## Testing the Vulnerabilities

### Test XSS
```
http://localhost:8080/xss?name=<script>alert('XSS')</script>
```

### Test SQL Injection
```
http://localhost:8080/search?username=admin' OR '1'='1
http://localhost:8080/search/ssn?ssn=123-45-6789' OR '1'='1
```

### Test PII Exposure
```
http://localhost:8080/pii?user_id=1
http://localhost:8080/pii/all
http://localhost:8080/search/ssn?ssn=123-45-6789
http://localhost:8080/search/card?card=4532-1234-5678-9010
```

### Test Hardcoded Secrets
```
http://localhost:8080/secrets
http://localhost:8080/debug
```

### Test Session Enumeration
```
http://localhost:8080/sessions
http://localhost:8080/session?session_id=session_1234567890
```

### Test Command Injection
```
http://localhost:8080/cmd?cmd=whoami
http://localhost:8080/cmd?cmd=cat%20/etc/passwd
```

### Test Weak Authentication
```
http://localhost:8080/login?username=admin&password=password123
```

### Test API Logs Exposure
```
http://localhost:8080/logs
```

### Test Payment Processing
```
http://localhost:8080/process-payment?card=4532-1234-5678-9010&cvv=123&amount=100
```

### Test Path Traversal
```
http://localhost:8080/file?file=../../etc/passwd
```

## File Structure

```
testing_DartCode/
├── bin/
│   └── main.dart                 # Main application with vulnerable endpoints
├── lib/
│   ├── config/
│   │   └── app_config.dart       # Hardcoded configuration and secrets
│   └── services/
│       ├── auth_service.dart     # Weak authentication implementation
│       ├── database_service.dart # SQL injection vulnerabilities
│       ├── file_service.dart     # File upload and traversal issues
│       ├── pii_service.dart      # PII data exposure
│       ├── crypto_service.dart   # Weak cryptography
│       ├── insecure_api_service.dart # API security issues
│       └── injection_service.dart    # Injection attack vectors
├── pubspec.yaml                  # Dart dependencies
└── README.md                      # This file
```

## Vulnerability Categories (OWASP Top 10)

1. **Broken Access Control** - IDOR, missing authorization
2. **Cryptographic Failures** - Weak encryption, hardcoded keys
3. **Injection** - SQL, Command, LDAP, XXE, NoSQL, Template
4. **Insecure Design** - Weak password reset, predictable tokens
5. **Security Misconfiguration** - Debug mode, permissive CORS
6. **Vulnerable Components** - Weak cryptography libraries
7. **Authentication Failures** - Weak passwords, no rate limiting
8. **Data Integrity Failures** - No input validation
9. **Logging & Monitoring Failures** - Sensitive data in logs
10. **SSRF** - Hardcoded webhook URLs

## Security Recommendations

### For Developers
1. Use parameterized queries for all database operations
2. Implement proper input validation and sanitization
3. Use strong cryptography (AES-256, SHA-256, bcrypt)
4. Never hardcode secrets - use environment variables
5. Implement rate limiting on authentication endpoints
6. Use HTTPS for all communications
7. Implement proper access control and authorization
8. Use secure session management with random tokens
9. Encrypt sensitive data at rest and in transit
10. Implement comprehensive logging and monitoring

### For Security Testers
1. Use this application only in authorized testing environments
2. Document all vulnerabilities found
3. Provide remediation recommendations
4. Test for both known and unknown vulnerabilities
5. Use automated and manual testing techniques
6. Verify fixes before marking as resolved

## Educational Purpose

This application demonstrates real-world security vulnerabilities that exist in production systems. By studying these vulnerabilities, developers and security professionals can:

- Understand common attack vectors
- Learn secure coding practices
- Practice vulnerability identification
- Develop security testing skills
- Improve code review capabilities

## Disclaimer

This application is provided for educational and authorized security testing purposes only. Unauthorized access to computer systems is illegal. Users are responsible for ensuring they have proper authorization before testing this application against any system.

## References

- OWASP Top 10: https://owasp.org/www-project-top-ten/
- CWE/SANS Top 25: https://cwe.mitre.org/top25/
- OWASP Testing Guide: https://owasp.org/www-project-web-security-testing-guide/
- Dart Security Best Practices: https://dart.dev/guides/security

### XSS Test
Visit: `http://localhost:8080/xss?name=<script>alert('XSS')</script>`

### SQL Injection Test
Visit: `http://localhost:8080/search?username=admin' OR '1'='1`

### Path Traversal Test
Visit: `http://localhost:8080/file?file=../../etc/passwd`

### IDOR Test
Visit: `http://localhost:8080/data?user_id=1`

## Secure Coding Practices

For each vulnerability in this application, consider these secure alternatives:

1. **XSS Protection**: Use HTML escaping libraries or templating engines that auto-escape by default
2. **SQL Injection**: Use parameterized queries or ORM libraries
3. **Path Traversal**: Validate and sanitize file paths, use `path.normalize()`
4. **Secrets Management**: Use environment variables or secret management services
5. **Authentication**: Implement proper session management and authorization checks
6. **Password Storage**: Use strong hashing algorithms like Argon2, bcrypt, or PBKDF2


📊 Key Metrics
Metric	                     Value
Total Vulnerabilities	      40+
Critical Issues	            15+
High Issues	                  20+
Medium Issues	               5+
Vulnerable Endpoints	         18+
Hardcoded Secrets	            15+
Documentation Files	         7
Total Lines of Code	         4,000+
Code Examples	               50+
Testing Scenarios	            30+