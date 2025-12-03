import 'dart:io';
import 'dart:convert';
import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart';
import 'package:shelf_router/shelf_router.dart';
import 'package:postgres/postgres.dart' as pg;
import 'package:path/path.dart' as path;

// Hardcoded credentials (Vulnerability: Hardcoded Secrets)
const String DB_USER = 'admin';
const String DB_PASSWORD = 'SuperSecret123!';
const String API_KEY = 'sk_test_1234567890abcdef';
const String STRIPE_KEY = 'sk_live_51Nl3YkSJ8X2X8X8X8X8X8X8X8X8X8X8X8X8X8X8X8X8X8X8X8X8X8X8X8X';
const String TWILIO_KEY = 'AC8X8X8X8X8X8X8X8X8X8X8X8X8X8X8X8X8X8X8X8X8X8X8X8X8X8X8X';
const String AWS_KEY = 'AKIA8X8X8X8X8X8X8X8X8X8X8X8X8X8X8X8X8X8X8X8X8X8X8X8X8X8X8X8X8X';
const String AWS_SECRET = '8X8X8X8X8X8X8X8X8X8X8X8X8X8X8X8X8X8X8X8X8X8X8X8X8X8X8X8X8X';
const String JWT_SECRET = 'supersecretjwttoken123';

// Simulated user database (Vulnerability: Insecure Storage)
final Map<String, String> users = {
  'admin': 'password123',
  'user1': 'qwerty',
  'superuser': 'superuser@123',
  'developer': 'dev123456',
};

// UNSAFE: Hardcoded PII data
final Map<int, Map<String, dynamic>> piiData = {
  1: {
    'user_id': 1,
    'ssn': '123-45-6789',
    'full_name': 'John Michael Smith',
    'credit_card': '4532-1234-5678-9010',
    'credit_card_cvv': '123',
    'phone': '+1-555-123-4567',
    'address': '123 Main Street, Springfield, IL 62701',
    'drivers_license': 'IL-D1234567',
    'passport': 'C12345678',
  },
  2: {
    'user_id': 2,
    'ssn': '987-65-4321',
    'full_name': 'Jane Elizabeth Brown',
    'credit_card': '5425-2334-3010-9903',
    'credit_card_cvv': '456',
    'phone': '+1-555-987-6543',
    'address': '456 Oak Avenue, Chicago, IL 60601',
    'drivers_license': 'IL-D7654321',
    'passport': 'C87654321',
  },
};

// UNSAFE: Session storage with tokens
final Map<String, Map<String, dynamic>> sessions = {};

// UNSAFE: API request logs with sensitive data
final List<Map<String, dynamic>> apiLogs = [];

// Vulnerable SQL Query (Vulnerability: SQL Injection)
    Future<List<Map<String, dynamic>>> searchUsers(String username) async {
      final conn = await pg.PostgreSQLConnection(
        'localhost',
        5432,
        'testdb',
        username: DB_USER,
        password: DB_PASSWORD,
      );
      await conn.open();

      try {
        // UNSAFE: Direct string interpolation in SQL query
        final result = await conn.query('SELECT * FROM users WHERE username = @username', substitutionValues: {'username': username});
        return result.map((row) => row.toColumnMap()).toList();
      } finally {
        await conn.close();
      }
    }

// Vulnerable File Access (Vulnerability: Path Traversal)
String readFile(String fileName) {
  // UNSAFE: No path traversal protection
  final file = File(fileName);
  return file.readAsStringSync();
}

// Vulnerable XSS endpoint (Vulnerability: XSS)
Response handleXSS(Request request) {
  final params = request.requestedUri.queryParameters;
  final name = params['name'] ?? 'Guest';
  
  // UNSAFE: Directly embedding user input in HTML
  final html = '''
    <html>
      <body>
        <h1>Hello, $name!</h1>
        <div>Welcome to our vulnerable app</div>
      </body>
    </html>
  ''';
  
  return Response.ok(html, headers: {'Content-Type': 'text/html'});
}

// Vulnerable API Key Validation (Vulnerability: Insecure Direct Object Reference)
Response handleSensitiveData(Request request) {
  final params = request.requestedUri.queryParameters;
  final userId = params['user_id'] ?? '1';
  
  // UNSAFE: No proper authorization check
  if (userId == '1') {
    return Response.ok('Sensitive data for user $userId: Very secret information!');
  } else {
    return Response.forbidden('Access denied');
  }
}

// Root handler
Response handleRoot(Request request) {
  final html = '''
    <html>
      <head>
        <title>Vulnerable Dart App</title>
        <style>
          body { font-family: Arial, sans-serif; margin: 40px; }
          h1 { color: #333; }
          .endpoint { 
            background: #f5f5f5; 
            padding: 10px; 
            margin: 10px 0; 
            border-left: 4px solid #4CAF50;
          }
          code { background: #f0f0f0; padding: 2px 5px; border-radius: 3px; }
        </style>
      </head>
      <body>
        <h1>Welcome to Vulnerable Dart App</h1>
        <p>This is a demonstration application with intentional vulnerabilities.</p>
        
        <h2>Available Endpoints:</h2>
        <div class="endpoint">
          <strong>Root</strong>: <code>GET /</code> - This page
        </div>
        <div class="endpoint">
          <strong>XSS Example</strong>: <code>GET /xss?name=&lt;script&gt;alert(1)&lt;/script&gt;</code> - XSS vulnerability demo
        </div>
        <div class="endpoint">
          <strong>SQL Injection</strong>: <code>GET /search?username=admin' OR '1'='1</code> - SQL injection demo
        </div>
        <div class="endpoint">
          <strong>File Access</strong>: <code>GET /file?file=path/to/file</code> - Path traversal demo
        </div>
        <div class="endpoint">
          <strong>Sensitive Data</strong>: <code>GET /data?userId=1</code> - Insecure direct object reference demo
        </div>
        
        <p style="margin-top: 30px; color: #666; font-size: 0.9em;">
          <strong>Note:</strong> This application is for educational purposes only.
          The vulnerabilities demonstrated here should not be used maliciously.
        </p>
      </body>
    </html>
  ''';
  return Response.ok(html, headers: {'Content-Type': 'text/html'});
}

// UNSAFE: Get PII data without authorization
Response getPIIData(Request request) {
  final params = request.requestedUri.queryParameters;
  final userId = params['user_id'] ?? '1';
  
  try {
    final id = int.parse(userId);
    final data = piiData[id];
    if (data != null) {
      // UNSAFE: Exposing all PII data
      return Response.ok(jsonEncode(data), headers: {'Content-Type': 'application/json'});
    }
    return Response.notFound('User not found');
  } catch (e) {
    return Response.internalServerError(body: 'Error: $e');
  }
}

// UNSAFE: Retrieve all PII data
Response getAllPIIData(Request request) {
  // UNSAFE: No authentication required
  return Response.ok(jsonEncode(piiData), headers: {'Content-Type': 'application/json'});
}

// UNSAFE: Search by SSN - SQL injection vulnerable
Response searchBySSN(Request request) {
  final params = request.requestedUri.queryParameters;
  final ssn = params['ssn'] ?? '';
  
  // UNSAFE: Direct string interpolation in SQL
  print('SELECT * FROM users WHERE ssn = \'$ssn\'');
  
  for (final entry in piiData.entries) {
    if (entry.value['ssn'] == ssn) {
      return Response.ok(jsonEncode(entry.value), headers: {'Content-Type': 'application/json'});
    }
  }
  
  return Response.notFound('SSN not found');
}

// UNSAFE: Search by credit card
Response searchByCredCard(Request request) {
  final params = request.requestedUri.queryParameters;
  final card = params['card'] ?? '';
  
  // UNSAFE: Direct string interpolation
  print('SELECT * FROM users WHERE credit_card = \'$card\'');
  
  for (final entry in piiData.entries) {
    if (entry.value['credit_card'] == card) {
      return Response.ok(jsonEncode(entry.value), headers: {'Content-Type': 'application/json'});
    }
  }
  
  return Response.notFound('Card not found');
}

// UNSAFE: Weak login without rate limiting
Response login(Request request) {
  final params = request.requestedUri.queryParameters;
  final username = params['username'] ?? '';
  final password = params['password'] ?? '';
  
  // UNSAFE: No rate limiting, weak authentication
  if (users[username] == password) {
    // UNSAFE: Predictable session token
    final sessionId = 'session_${DateTime.now().millisecondsSinceEpoch}';
    sessions[sessionId] = {
      'username': username,
      'user_id': 1,
      'created_at': DateTime.now().toIso8601String(),
    };
    
    // UNSAFE: Logging credentials
    apiLogs.add({
      'endpoint': '/login',
      'username': username,
      'password': password,
      'timestamp': DateTime.now().toIso8601String(),
    });
    
    return Response.ok(jsonEncode({'session_id': sessionId, 'username': username}),
        headers: {'Content-Type': 'application/json'});
  }
  
  return Response.forbidden('Invalid credentials');
}

// UNSAFE: Get session info without validation
Response getSessionInfo(Request request) {
  final params = request.requestedUri.queryParameters;
  final sessionId = params['session_id'] ?? '';
  
  // UNSAFE: No validation
  final session = sessions[sessionId];
  if (session != null) {
    return Response.ok(jsonEncode(session), headers: {'Content-Type': 'application/json'});
  }
  
  return Response.notFound('Session not found');
}

// UNSAFE: Get all sessions
Response getAllSessions(Request request) {
  // UNSAFE: No authentication
  return Response.ok(jsonEncode(sessions), headers: {'Content-Type': 'application/json'});
}

// UNSAFE: Get API logs with sensitive data
Response getAPILogs(Request request) {
  // UNSAFE: Exposing all API logs including credentials
  return Response.ok(jsonEncode(apiLogs), headers: {'Content-Type': 'application/json'});
}

// UNSAFE: Command execution endpoint
Response executeCommand(Request request) {
  final params = request.requestedUri.queryParameters;
  final command = params['cmd'] ?? '';
  
  try {
    // UNSAFE: Direct command execution
    final result = Process.runSync('sh', ['-c', command]);
    return Response.ok(result.stdout.toString());
  } catch (e) {
    return Response.internalServerError(body: 'Error: $e');
  }
}

// UNSAFE: Retrieve hardcoded secrets
Response getSecrets(Request request) {
  // UNSAFE: Exposing all secrets
  return Response.ok(jsonEncode({
    'db_user': DB_USER,
    'db_password': DB_PASSWORD,
    'api_key': API_KEY,
    'stripe_key': STRIPE_KEY,
    'twilio_key': TWILIO_KEY,
    'aws_key': AWS_KEY,
    'aws_secret': AWS_SECRET,
    'jwt_secret': JWT_SECRET,
  }), headers: {'Content-Type': 'application/json'});
}

// UNSAFE: Debug endpoint exposing system info
Response getDebugInfo(Request request) {
  // UNSAFE: Exposing sensitive system information
  return Response.ok(jsonEncode({
    'dart_version': Platform.version,
    'os': Platform.operatingSystem,
    'hostname': Platform.localHostname,
    'environment': Platform.environment,
    'users': users,
    'pii_data': piiData,
    'sessions': sessions,
    'api_logs': apiLogs,
  }), headers: {'Content-Type': 'application/json'});
}

// UNSAFE: Weak password reset
Response resetPassword(Request request) {
  final params = request.requestedUri.queryParameters;
  final email = params['email'] ?? '';
  
  // UNSAFE: Predictable reset token
  final resetToken = DateTime.now().millisecondsSinceEpoch.toString();
  
  // UNSAFE: Logging reset token
  print('Password reset token for $email: $resetToken');
  
  return Response.ok(jsonEncode({
    'reset_token': resetToken,
    'email': email,
    'reset_link': 'http://localhost:8080/reset?token=$resetToken',
  }), headers: {'Content-Type': 'application/json'});
}

// UNSAFE: Process payment without validation
Response processPayment(Request request) {
  final params = request.requestedUri.queryParameters;
  final cardNumber = params['card'] ?? '';
  final cvv = params['cvv'] ?? '';
  final amount = params['amount'] ?? '0';
  
  // UNSAFE: Storing payment data
  apiLogs.add({
    'endpoint': '/process-payment',
    'card': cardNumber,
    'cvv': cvv,
    'amount': amount,
    'timestamp': DateTime.now().toIso8601String(),
  });
  
  return Response.ok(jsonEncode({
    'success': true,
    'transaction_id': 'txn_${DateTime.now().millisecondsSinceEpoch}',
    'amount': amount,
  }), headers: {'Content-Type': 'application/json'});
}

// Main server setup
void main() async {
  final app = Router();
  
  // Root route
  app.get('/', handleRoot);
  
  // Vulnerable endpoints
  app.get('/xss', handleXSS);
  app.get('/search', (Request request) async {
    final params = request.requestedUri.queryParameters;
    final username = params['username'] ?? '';
    
    try {
      final results = await searchUsers(username);
      return Response.ok('Search results: $results');
    } catch (e) {
      return Response.internalServerError(body: 'Error: $e');
    }
  });
  
  app.get('/file', (Request request) {
    final params = request.requestedUri.queryParameters;
    final fileName = params['file'] ?? 'example.txt';
    
    try {
      final content = readFile(fileName);
      return Response.ok('File content: $content');
    } catch (e) {
      return Response.internalServerError(body: 'Error reading file: $e');
    }
  });
  
  app.get('/data', handleSensitiveData);
  
  // New vulnerable endpoints
  app.get('/pii', getPIIData);
  app.get('/pii/all', getAllPIIData);
  app.get('/search/ssn', searchBySSN);
  app.get('/search/card', searchByCredCard);
  app.get('/login', login);
  app.get('/session', getSessionInfo);
  app.get('/sessions', getAllSessions);
  app.get('/logs', getAPILogs);
  app.get('/cmd', executeCommand);
  app.get('/secrets', getSecrets);
  app.get('/debug', getDebugInfo);
  app.get('/reset-password', resetPassword);
  app.get('/process-payment', processPayment);
  
  // Start server
  final server = await serve(app, '0.0.0.0', 8080);
  print('Server running on ${server.address.host}:${server.port}');
}
