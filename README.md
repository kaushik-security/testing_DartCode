# Vulnerable Dart Application

This is a deliberately vulnerable Dart application created for security testing and educational purposes. It contains various security vulnerabilities that should never be used in production environments.

## Vulnerabilities Included

1. **Cross-Site Scripting (XSS)**
   - Endpoint: `GET /xss?name=<script>alert(1)</script>`
   - Description: User input is directly embedded in HTML without proper escaping

2. **SQL Injection**
   - Endpoint: `GET /search?username=admin' OR '1'='1`
   - Description: Direct string interpolation in SQL queries allows SQL injection

3. **Path Traversal**
   - Endpoint: `GET /file?file=../../etc/passwd`
   - Description: Unvalidated user input used in file operations

4. **Hardcoded Secrets**
   - Database credentials and API keys hardcoded in the source code
   - Found in `main.dart`

5. **Insecure Direct Object Reference (IDOR)**
   - Endpoint: `GET /data?user_id=1`
   - Description: Direct access to resources without proper authorization checks

6. **Insecure Storage**
   - Plain text password storage in memory
   - Found in the `users` map in `main.dart`

## Setup Instructions

1. Install Dart SDK (if not already installed)
2. Install dependencies:
   ```bash
   dart pub get
   ```
3. Run the application:
   ```bash
   dart run bin/main.dart
   ```
4. The server will start on `http://localhost:8080`

## Security Warning

⚠️ **WARNING** ⚠️

This application contains intentional security vulnerabilities. Do not deploy this application to any publicly accessible server. This is for testing and educational purposes only.

## Testing the Vulnerabilities

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
