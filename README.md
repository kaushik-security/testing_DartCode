# Advanced Vulnerable Dart Application

This is a deliberately vulnerable Dart application created for advanced security testing and educational purposes. It contains **30+ security vulnerabilities** spanning multiple categories including injection attacks, cryptographic failures, PII exposure, authentication bypass, and more.

## ⚠️ CRITICAL SECURITY WARNING ⚠️

**DO NOT deploy this application to any publicly accessible server or production environment.** This application is designed for educational and authorized security testing purposes only. Unauthorized access to systems using this code is illegal.

## Comprehensive Vulnerability List

## 1. Hardcoded Secrets & Credentials
## 2. PII Data Exposure
## 3. SQL Injection
## 4. Cross-Site Scripting (XSS)
## 5. Insecure Direct Object Reference (IDOR)
## 6. Path Traversal
## 7. Weak Cryptography
## 8. Broken Authentication
## 9. Insecure Session Management
## 10. Information Disclosure
## 11. Command Injection
## 12. Insecure API Implementation
## 13. Weak Password Reset
## 14. Insecure Payment Processing
## 15. LDAP Injection
## 16. XXE (XML External Entity)
## 17. NoSQL Injection
## 18. Template Injection
## 19. Expression Language Injection
## 20. Code Injection / Eval
## 21. Zip Slip Vulnerability
## 22. Insecure File Upload
## 23. Directory Listing
## 24. Insecure Deserialization
## 25. Missing Access Control
## 26. Sensitive Data in Logs
## 27. Insecure Direct Communication
## 28. Weak CORS Configuration
## 29. Debug Mode Enabled
## 30. Insufficient Logging & Monitoring

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
