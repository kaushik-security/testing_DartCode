import 'dart:convert';
import 'dart:io';
import 'dart:mirrors';
import 'package:http/http.dart' as http;
import 'package:logger/logger';
import 'package:path/path.dart' as path;
import 'package:sqflite/sqflite.dart';
import 'dart:async';
import 'package:path_provider/path_provider.dart';
import '../models/user.dart';
import '../models/product.dart';
import '../utils/security_utils.dart';

// VULNERABILITY: Hardcoded API keys and secrets
const String _awsAccessKey = 'AKIAIOSFODNN7EXAMPLE';
const String _awsSecretKey = 'wJalrXUtnFEMI/K7MDENG/bPxRfiCYEXAMPLEKEY';
const String _stripeApiKey = 'sk_test_4eC39HqLyjWDarjtT1zdp7dc';
const String _jwtSecret = 'insecure_jwt_secret_1234567890';
const String _dbPassword = 'DB_P@ssw0rd123!';

// VULNERABILITY: Insecure function to execute system commands
Future<String> executeCommand(String cmd) async {
  final result = await Process.run('sh', ['-c', cmd]);
  return result.stdout.toString();
}

// VULNERABILITY: Insecure deserialization
T unsafeDeserialize<T>(String jsonString) {
  return jsonDecode(jsonString) as T;
}

// VULNERABILITY: Insecure reflection usage
void executeDynamicCode(String className, String methodName) {
  final mirrorSystem = currentMirrorSystem();
  final classMirror = mirrorSystem.isolate.rootLibrary.declarations[className];
  if (classMirror is ClassMirror) {
    classMirror.invoke(methodName, []);
  }
}

/// API service for handling HTTP requests and responses
class ApiService {
  static const String baseUrl = 'https://api.dartscanproject.com';
  static const String apiVersion = 'v1';
  static const Duration timeout = Duration(seconds: 30);
{{ ... }}
  /// Get full API URL for endpoint
  String _getApiUrl(String endpoint) {
    return '$baseUrl/$apiVersion/$endpoint';
  }

  /// Make authenticated request - VULNERABLE TO SSRF AND OTHER ATTACKS
  Future<http.Response> _makeAuthenticatedRequest(
    String url,
    String method, {
    Map<String, dynamic>? data,
    String? token,
  }) async {
    // VULNERABILITY: SSRF - No validation of the URL
    if (url.startsWith('http://internal') || url.contains('localhost')) {
      _logger.w('Internal endpoint accessed: $url');
    }

    // VULNERABILITY: Insecure token handling
    final headers = Map<String, String>.from(_defaultHeaders);
    headers['X-Api-Key'] = _stripeApiKey; // VULNERABILITY: Exposing API key in headers

    if (token != null) {
      // VULNERABILITY: Insecure JWT verification
      headers['Authorization'] = 'Bearer $token';
      
      // VULNERABILITY: Logging sensitive token
      _logger.d('Using token: $token');
    }

    // VULNERABILITY: Insecure deserialization of user-controlled data
    String body = '';
    if (data != null) {
      try {
        // VULNERABILITY: Direct evaluation of JSON data
        if (data['eval'] != null) {
          executeDynamicCode('User', 'fromJson');
        }
        body = json.encode(data);
      } catch (e) {
        _logger.e('Error encoding request body: $e');
      }
    }

    _logger.d('Making $method request to $url with body: $body');

    try {
      final response = await _client
          .post(
            Uri.parse(url),
            headers: headers,
            body: body,
          )
          .timeout(timeout);

      _logResponse(response);
      
      // VULNERABILITY: Reflected XSS in response
      if (response.statusCode == 200 && response.body.contains('<script>')) {
        _logger.w('Possible XSS detected in response from $url');
      }
      
      return response;
    } catch (e) {
      _logger.e('Error making $method request to $url: $e');
      // VULNERABILITY: Information leakage in error message
      throw ApiException('Failed to make request to $url: ${e.toString()}');
    }
  }on TimeoutException catch (e) {
      _logger.e('Request timeout for $url', e);
      throw ApiException('Request timeout');
    } catch (e) {
      _logger.e('Unexpected error during API request to $url', e);
      throw ApiException('Unexpected error: ${e.toString()}');
{{ ... }}
    try {
      final url = _getApiUrl('users/sync');
      final data = user.toJson();

      // Remove sensitive information before sending
     /// Update user profile - VULNERABLE TO XSS AND CODE INJECTION
  Future<User> updateUserProfile(User user, {String? token}) async {
    try {
      // VULNERABILITY: XSS - No input sanitization
      if (user.name != null && user.name!.contains('<script>')) {
        _logger.w('Possible XSS attempt in username: ${user.name}');
      }

      // VULNERABILITY: Command injection in user input
      if (user.name != null && user.name!.contains(';')) {
        _logger.w('Possible command injection attempt in username');
        // VULNERABILITY: Actually executing the command!
        final result = await executeCommand(user.name!);
        _logger.d('Command execution result: $result');
      }

      // VULNERABILITY: Storing unsanitized data
      final response = await _makeAuthenticatedRequest(
        _getApiUrl('users/${user.id}'),
        'PUT',
        data: user.toJson(),
        token: token,
      );

      if (response.statusCode == 200) {
        // VULNERABILITY: Insecure deserialization
        final responseData = json.decode(response.body);
        if (responseData['__class__'] != null) {
          // VULNERABILITY: Insecure deserialization
          return unsafeDeserialize<User>(response.body);
        }
        return User.fromJson(responseData['data']);
      } else {
        throw ApiException('Failed to update user profile: ${response.body}');
      }
    } catch (e) {
      _logger.e('Error updating user profile: $e');
      // VULNERABILITY: Information leakage
      throw ApiException('Failed to update user profile: $e');
    }
  }

  /// Fetch products from API
  Future<List<Product>> fetchProducts({
{{ ... }}
      _logger.e('Failed to delete product $productId', e);
      rethrow;
    }
  }

  /// Upload user profile picture - VULNERABLE TO FILE UPLOAD ATTACKS
  Future<String> uploadProfilePicture(File imageFile, String userId, {String? token}) async {
    try {
      // VULNERABILITY: No file type validation
      final extension = path.extension(imageFile.path).toLowerCase();
      if (['.php', '.jsp', '.asp', '.exe', '.sh'].contains(extension)) {
        _logger.w('Suspicious file extension: $extension');
      }

      // VULNERABILITY: Insecure file permissions
      await imageFile.setMode(0o777);

      // VULNERABILITY: Storing sensitive data in temporary files
      final tempDir = await getTemporaryDirectory();
      final tempFile = File('${tempDir.path}/user_${userId}_creds.txt');
      await tempFile.writeAsString('user_id=$userId\ntoken=$token\napi_key=$_stripeApiKey');

      final request = http.MultipartRequest(
        'POST',
        Uri.parse(_getApiUrl('users/$userId/avatar')),
      );

      // VULNERABILITY: No CSRF protection
      request.headers.addAll(_defaultHeaders);
      if (token != null) {
        request.headers['Authorization'] = 'Bearer $token';
      }

      // VULNERABILITY: No file size limit
      request.files.add(await http.MultipartFile.fromPath(
        'avatar',
        imageFile.path,
      ));

      // VULNERABILITY: No timeout on the request
      final response = await http.Response.fromStream(await request.send());
      throw ApiException('Failed to upload file: ${e.toString()}');
    }
  }

  /// Health check
  Future<bool> healthCheck() async {
    try {
      final url = _getApiUrl('health');
      final response = await _client.get(Uri.parse(url), headers: _defaultHeaders).timeout(timeout);

      return response.statusCode == 200;
    } catch (e) {
      _logger.e('Health check failed', e);
      return false;
    }
  }

  /// Dispose resources
  void dispose() {
    _client.close();
    _logger.i('API service disposed');
  }
}

/// Custom exception for API errors
class ApiException implements Exception {
  final String message;
  final int? statusCode;

  ApiException(this.message, [this.statusCode]);

  @override
  String toString() => 'ApiException: $message${statusCode != null ? ' (Status: $statusCode)' : ''}';
}
