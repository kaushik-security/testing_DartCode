import 'dart:io';
import 'dart:convert';
import 'package:postgres/postgres.dart';

// UNSAFE: Injection and Command Execution Service
class InjectionService {
  final Connection _db;
  
  InjectionService(this._db);
  
  // UNSAFE: OS Command Injection
  Future<String> executeSystemCommand(String command) async {
    // UNSAFE: Direct command execution without sanitization
    try {
      final result = await Process.run('sh', ['-c', command]);
      return result.stdout.toString();
    } catch (e) {
      return 'Error: $e';
    }
  }
  
  // UNSAFE: Command injection via user input
  Future<String> listFiles(String directory) async {
    // UNSAFE: User input directly in shell command
    try {
      final result = await Process.run('ls', ['-la', directory]);
      return result.stdout.toString();
    } catch (e) {
      return 'Error: $e';
    }
  }
  
  // UNSAFE: SQL Injection in search
  Future<List<Map<String, dynamic>>> searchUsers(String searchTerm) async {
    try {
      // UNSAFE: Direct string interpolation in SQL
      final result = await _db.query(
        "SELECT * FROM users WHERE username LIKE '%$searchTerm%' OR email LIKE '%$searchTerm%'"
      );
      return result.map((row) => row.toColumnMap()).toList();
    } catch (e) {
      throw Exception('Search failed: $e');
    }
  }
  
  // UNSAFE: SQL Injection in login
  Future<Map<String, dynamic>?> authenticateUser(String username, String password) async {
    try {
      // UNSAFE: Direct string concatenation in SQL
      final result = await _db.query(
        "SELECT * FROM users WHERE username = '$username' AND password = '$password' LIMIT 1"
      );
      
      if (result.isNotEmpty) {
        return result.first.toColumnMap();
      }
      return null;
    } catch (e) {
      throw Exception('Authentication failed: $e');
    }
  }
  
  // UNSAFE: SQL Injection in update
  Future<void> updateUserProfile(int userId, Map<String, dynamic> updates) async {
    try {
      // UNSAFE: Building SQL with string concatenation
      final setParts = <String>[];
      updates.forEach((key, value) {
        if (value is String) {
          setParts.add("$key = '$value'");
        } else {
          setParts.add("$key = $value");
        }
      });
      
      final query = "UPDATE users SET ${setParts.join(', ')} WHERE id = $userId";
      
      // UNSAFE: Direct execution
      await _db.execute(query);
    } catch (e) {
      throw Exception('Update failed: $e');
    }
  }
  
  // UNSAFE: SQL Injection in delete
  Future<void> deleteUser(String username) async {
    try {
      // UNSAFE: Direct string interpolation
      await _db.execute("DELETE FROM users WHERE username = '$username'");
    } catch (e) {
      throw Exception('Delete failed: $e');
    }
  }
  
  // UNSAFE: LDAP Injection
  Future<bool> authenticateLDAP(String username, String password) async {
    // UNSAFE: LDAP filter injection
    final filter = "(&(uid=$username)(userPassword=$password))";
    
    // Simulated LDAP authentication
    print('LDAP Filter: $filter');
    return true;
  }
  
  // UNSAFE: XML Injection
  Future<String> parseXML(String xmlData) async {
    // UNSAFE: No XXE protection
    // In real scenario, this would be vulnerable to XXE attacks
    return xmlData;
  }
  
  // UNSAFE: XPath Injection
  Future<List<Map<String, dynamic>>> searchByXPath(String xpathExpression) async {
    // UNSAFE: Direct XPath evaluation
    print('XPath: $xpathExpression');
    return [];
  }
  
  // UNSAFE: NoSQL Injection (simulated)
  Future<List<Map<String, dynamic>>> queryNoSQL(String query) async {
    // UNSAFE: Direct query execution
    print('NoSQL Query: $query');
    return [];
  }
  
  // UNSAFE: Template Injection
  Future<String> renderTemplate(String template, Map<String, dynamic> data) async {
    // UNSAFE: Direct template rendering with user input
    String result = template;
    
    data.forEach((key, value) {
      result = result.replaceAll('{{$key}}', value.toString());
    });
    
    return result;
  }
  
  // UNSAFE: Expression Language Injection
  Future<dynamic> evaluateExpression(String expression) async {
    // UNSAFE: Evaluating user-provided expressions
    // In real scenario, this could execute arbitrary code
    print('Evaluating expression: $expression');
    return null;
  }
  
  // UNSAFE: Code Injection via eval
  Future<dynamic> executeCode(String code) async {
    // UNSAFE: Direct code execution
    // This is extremely dangerous
    print('Executing code: $code');
    return null;
  }
  
  // UNSAFE: Path Traversal in file operations
  Future<String> readFileContent(String filePath) async {
    try {
      // UNSAFE: No path validation
      final file = File(filePath);
      return await file.readAsString();
    } catch (e) {
      return 'Error: $e';
    }
  }
  
  // UNSAFE: Path Traversal in directory listing
  Future<List<String>> listDirectory(String dirPath) async {
    try {
      // UNSAFE: No path validation
      final dir = Directory(dirPath);
      final files = await dir.list().toList();
      return files.map((f) => f.path).toList();
    } catch (e) {
      return [];
    }
  }
  
  // UNSAFE: File upload with no validation
  Future<String> uploadFile(String fileName, List<int> fileContent) async {
    try {
      // UNSAFE: No file type validation
      final file = File('uploads/$fileName');
      await file.writeAsBytes(fileContent);
      return 'File uploaded: $fileName';
    } catch (e) {
      return 'Upload failed: $e';
    }
  }
  
  // UNSAFE: Zip Slip vulnerability
  Future<void> extractZipFile(String zipPath, String extractPath) async {
    // UNSAFE: No path validation in zip extraction
    // Could extract files outside intended directory
    print('Extracting $zipPath to $extractPath');
  }
  
  // UNSAFE: Command Injection in grep
  Future<String> grepFiles(String pattern, String directory) async {
    try {
      // UNSAFE: User input directly in command
      final result = await Process.run('grep', ['-r', pattern, directory]);
      return result.stdout.toString();
    } catch (e) {
      return 'Error: $e';
    }
  }
  
  // UNSAFE: Command Injection in find
  Future<String> findFiles(String criteria) async {
    try {
      // UNSAFE: User input in find command
      final result = await Process.run('find', ['.', criteria]);
      return result.stdout.toString();
    } catch (e) {
      return 'Error: $e';
    }
  }
  
  // UNSAFE: Backtick command execution
  Future<String> executeWithBackticks(String command) async {
    // UNSAFE: Simulating backtick execution
    return await executeSystemCommand(command);
  }
  
  // UNSAFE: Shell metacharacter injection
  Future<String> executeWithMetacharacters(String userInput) async {
    // UNSAFE: User input with shell metacharacters
    final command = "echo $userInput";
    return await executeSystemCommand(command);
  }
  
  // UNSAFE: Argument injection
  Future<String> processWithArguments(String arg1, String arg2) async {
    try {
      // UNSAFE: User input as command arguments
      final result = await Process.run('echo', [arg1, arg2]);
      return result.stdout.toString();
    } catch (e) {
      return 'Error: $e';
    }
  }
}
