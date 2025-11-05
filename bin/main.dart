import 'dart:io';
import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart';
import 'package:shelf_router/shelf_router.dart';
import 'package:postgres/postgres.dart' as pg;
import 'package:path/path.dart' as path;

// Hardcoded credentials (Vulnerability: Hardcoded Secrets)
const String DB_USER = 'admin';
const String DB_PASSWORD = 'SuperSecret123!';
const String API_KEY = 'sk_test_1234567890abcdef';

// Simulated user database (Vulnerability: Insecure Storage)
final Map<String, String> users = {
  'admin': 'password123',
  'user1': 'qwerty',
};

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
  
  // Start server
  final server = await serve(app, '0.0.0.0', 8080);
  print('Server running on ${server.address.host}:${server.port}');
}
