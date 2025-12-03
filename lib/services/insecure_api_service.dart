import 'dart:convert';
import 'package:postgres/postgres.dart';

// UNSAFE: Insecure API Service with multiple vulnerabilities
class InsecureAPIService {
  final Connection _db;
  
  // UNSAFE: Hardcoded API keys
  static const Map<String, String> apiCredentials = {
    'stripe_key': 'sk_live_51Nl3YkSJ8X2X8X8X8X8X8X8X8X8X8X8X8X8X8X8X8X8X8X8X8X8X8X8X8X',
    'paypal_key': 'AQkXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX',
    'twilio_key': 'AC8X8X8X8X8X8X8X8X8X8X8X8X8X8X8X8X8X8X8X8X8X8X8X8X8X8X8X',
    'sendgrid_key': 'SG.8X8X8X8X8X8X8X8X8X8X8X8X8X8X8X8X8X8X8X8X8X8X8X8X8X8X8X8X8X',
  };
  
  // UNSAFE: API request logging with sensitive data
  static final List<Map<String, dynamic>> requestLog = [];
  
  InsecureAPIService(this._db);
  
  // UNSAFE: No API key validation, accepts any key
  Future<bool> validateAPIKey(String apiKey) async {
    // UNSAFE: Weak validation - just checks if not empty
    return apiKey.isNotEmpty;
  }
  
  // UNSAFE: API key stored in plain text in logs
  Future<void> logAPIRequest(String apiKey, String endpoint, Map<String, dynamic> data) async {
    // UNSAFE: Logging API key and request data
    requestLog.add({
      'timestamp': DateTime.now().toIso8601String(),
      'api_key': apiKey,  // UNSAFE: Logging sensitive API key
      'endpoint': endpoint,
      'data': data,  // UNSAFE: Logging request data
      'ip_address': '0.0.0.0',  // UNSAFE: Not capturing real IP
    });
    
    print('API Request logged: $apiKey -> $endpoint');
  }
  
  // UNSAFE: Retrieve all API logs without authorization
  Future<List<Map<String, dynamic>>> getAllAPILogs() async {
    // UNSAFE: No access control on sensitive logs
    return requestLog;
  }
  
  // UNSAFE: Get API key from logs
  Future<String?> getAPIKeyFromLogs(String endpoint) async {
    // UNSAFE: Exposing API keys from logs
    for (final log in requestLog) {
      if (log['endpoint'] == endpoint) {
        return log['api_key'];
      }
    }
    return null;
  }
  
  // UNSAFE: Process payment without proper validation
  Future<Map<String, dynamic>> processPayment(
    String apiKey,
    double amount,
    String cardNumber,
    String cvv,
  ) async {
    // UNSAFE: No validation of card number or CVV
    // UNSAFE: Storing sensitive payment data
    
    if (!await validateAPIKey(apiKey)) {
      return {'success': false, 'error': 'Invalid API key'};
    }
    
    try {
      // UNSAFE: Direct string interpolation with sensitive data
      await _db.execute('''
        INSERT INTO payments (api_key, amount, card_number, cvv, status)
        VALUES ('$apiKey', $amount, '$cardNumber', '$cvv', 'pending')
      ''');
      
      // UNSAFE: Logging payment details
      await logAPIRequest(apiKey, '/process-payment', {
        'amount': amount,
        'card': cardNumber,
        'cvv': cvv,
      });
      
      return {
        'success': true,
        'transaction_id': 'txn_${DateTime.now().millisecondsSinceEpoch}',
        'amount': amount,
        'card_last_four': cardNumber.substring(cardNumber.length - 4),
      };
    } catch (e) {
      // UNSAFE: Detailed error exposure
      return {'success': false, 'error': 'Payment failed: $e'};
    }
  }
  
  // UNSAFE: Retrieve payment history without authorization
  Future<List<Map<String, dynamic>>> getPaymentHistory(String apiKey) async {
    try {
      // UNSAFE: No access control, returns all payments for any API key
      final result = await _db.query('SELECT * FROM payments WHERE api_key = \'$apiKey\'');
      return result.map((row) => row.toColumnMap()).toList();
    } catch (e) {
      throw Exception('Failed to retrieve payment history: $e');
    }
  }
  
  // UNSAFE: Retrieve all payments without authentication
  Future<List<Map<String, dynamic>>> getAllPayments() async {
    try {
      // UNSAFE: No authentication required
      final result = await _db.query('SELECT * FROM payments');
      return result.map((row) => row.toColumnMap()).toList();
    } catch (e) {
      throw Exception('Failed to retrieve payments: $e');
    }
  }
  
  // UNSAFE: Webhook handler with no signature verification
  Future<bool> handleWebhook(String payload, String signature) async {
    // UNSAFE: No signature verification
    try {
      final data = jsonDecode(payload);
      
      // UNSAFE: Directly processing webhook without validation
      if (data['event'] == 'payment.completed') {
        await _db.execute(
          "UPDATE payments SET status = 'completed' WHERE id = ${data['payment_id']}"
        );
        return true;
      }
      
      return false;
    } catch (e) {
      // UNSAFE: Exposing error details
      throw Exception('Webhook processing failed: $e');
    }
  }
  
  // UNSAFE: OAuth token stored in plain text
  static final Map<String, String> oauthTokens = {
    'user_1': 'oauth_token_abc123def456ghi789jkl012mno345',
    'user_2': 'oauth_token_xyz789uvw012rst345qpo678lmn901',
  };
  
  // UNSAFE: Retrieve OAuth token without authentication
  Future<String?> getOAuthToken(String userId) async {
    // UNSAFE: No access control
    return oauthTokens[userId];
  }
  
  // UNSAFE: Store OAuth token in plain text
  Future<void> storeOAuthToken(String userId, String token) async {
    // UNSAFE: Storing token without encryption
    oauthTokens[userId] = token;
    
    // UNSAFE: Logging token
    print('OAuth token stored for $userId: $token');
  }
  
  // UNSAFE: Refresh token without proper validation
  Future<String> refreshOAuthToken(String userId, String refreshToken) async {
    // UNSAFE: No validation of refresh token
    final newToken = 'oauth_token_${DateTime.now().millisecondsSinceEpoch}';
    oauthTokens[userId] = newToken;
    return newToken;
  }
  
  // UNSAFE: API rate limiting not implemented
  static int requestCount = 0;
  
  Future<bool> checkRateLimit(String apiKey) async {
    // UNSAFE: No rate limiting
    requestCount++;
    return true;
  }
  
  // UNSAFE: Get request count without authentication
  Future<int> getRequestCount() async {
    // UNSAFE: No access control
    return requestCount;
  }
  
  // UNSAFE: Reset rate limit for any API key
  Future<void> resetRateLimit(String apiKey) async {
    // UNSAFE: No validation
    requestCount = 0;
  }
  
  // UNSAFE: Hardcoded webhook URLs
  static const List<String> webhookUrls = [
    'http://localhost:3000/webhook',
    'http://internal-service.local/webhook',
    'http://192.168.1.100:8000/webhook',
  ];
  
  // UNSAFE: Send data to webhook without verification
  Future<void> sendToWebhook(String url, Map<String, dynamic> data) async {
    // UNSAFE: No URL validation, could send to arbitrary URLs
    // UNSAFE: Sending sensitive data to webhook
    print('Sending to webhook: $url');
    print('Data: ${jsonEncode(data)}');
  }
  
  // UNSAFE: Retrieve webhook URLs without authentication
  Future<List<String>> getWebhookUrls() async {
    // UNSAFE: No access control
    return webhookUrls;
  }
}
