import 'dart:convert';
import 'package:postgres/postgres.dart';

// UNSAFE: PII Data Service with multiple vulnerabilities
class PIIService {
  final Connection _db;
  
  // UNSAFE: Hardcoded sample PII data
  static final Map<int, Map<String, dynamic>> piiDatabase = {
    1: {
      'user_id': 1,
      'ssn': '123-45-6789',
      'full_name': 'John Michael Smith',
      'date_of_birth': '1990-05-15',
      'phone': '+1-555-123-4567',
      'email': 'john.smith@example.com',
      'address': '123 Main Street, Springfield, IL 62701',
      'credit_card': '4532-1234-5678-9010',
      'credit_card_cvv': '123',
      'credit_card_expiry': '12/25',
      'bank_account': '9876543210',
      'bank_routing': '021000021',
      'drivers_license': 'IL-D1234567',
      'passport_number': 'C12345678',
      'mothers_maiden_name': 'Johnson',
      'security_questions': {
        'q1': 'What is your pet name?',
        'a1': 'Fluffy',
        'q2': 'What city were you born?',
        'a2': 'Chicago',
      },
      'ip_addresses': ['192.168.1.100', '203.0.113.45', '198.51.100.23'],
      'device_ids': ['device_abc123', 'device_xyz789'],
    },
    2: {
      'user_id': 2,
      'ssn': '987-65-4321',
      'full_name': 'Jane Elizabeth Brown',
      'date_of_birth': '1988-11-22',
      'phone': '+1-555-987-6543',
      'email': 'jane.brown@example.com',
      'address': '456 Oak Avenue, Chicago, IL 60601',
      'credit_card': '5425-2334-3010-9903',
      'credit_card_cvv': '456',
      'credit_card_expiry': '08/26',
      'bank_account': '1234567890',
      'bank_routing': '021000021',
      'drivers_license': 'IL-D7654321',
      'passport_number': 'C87654321',
      'mothers_maiden_name': 'Williams',
      'security_questions': {
        'q1': 'What is your favorite color?',
        'a1': 'Blue',
        'q2': 'What is your favorite food?',
        'a2': 'Pizza',
      },
      'ip_addresses': ['192.168.1.101', '203.0.113.46'],
      'device_ids': ['device_def456', 'device_uvw012'],
    },
  };
  
  PIIService(this._db);
  
  // UNSAFE: Retrieve all PII data without any authorization
  Future<Map<int, Map<String, dynamic>>> getAllPIIData() async {
    return piiDatabase;
  }
  
  // UNSAFE: Retrieve PII by user ID with no access control
  Future<Map<String, dynamic>?> getPIIByUserId(int userId) async {
    return piiDatabase[userId];
  }
  
  // UNSAFE: Search PII data by SSN - SQL injection vulnerable
  Future<List<Map<String, dynamic>>> searchBySSN(String ssn) async {
    try {
      // UNSAFE: Direct string interpolation in SQL query
      final result = await _db.query(
        "SELECT * FROM user_pii WHERE ssn = '$ssn'"
      );
      return result.map((row) => row.toColumnMap()).toList();
    } catch (e) {
      // UNSAFE: Exposing detailed error information
      throw Exception('SSN search failed: $e');
    }
  }
  
  // UNSAFE: Search by credit card - SQL injection vulnerable
  Future<List<Map<String, dynamic>>> searchByCredCard(String creditCard) async {
    try {
      // UNSAFE: Direct string interpolation
      final result = await _db.query(
        "SELECT * FROM user_pii WHERE credit_card = '$creditCard'"
      );
      return result.map((row) => row.toColumnMap()).toList();
    } catch (e) {
      throw Exception('Credit card search failed: $e');
    }
  }
  
  // UNSAFE: Export all PII to JSON without encryption
  Future<String> exportAllPIIAsJSON() async {
    final allData = piiDatabase.values.toList();
    // UNSAFE: No encryption, no access control, directly exposing all PII
    return jsonEncode(allData);
  }
  
  // UNSAFE: Store PII in plain text without encryption
  Future<void> storePII(int userId, Map<String, dynamic> piiData) async {
    try {
      // UNSAFE: Storing sensitive data without encryption
      final ssn = piiData['ssn'];
      final creditCard = piiData['credit_card'];
      final bankAccount = piiData['bank_account'];
      
      // UNSAFE: Direct string interpolation with unescaped data
      await _db.execute('''
        INSERT INTO user_pii (user_id, ssn, credit_card, bank_account, full_data)
        VALUES ($userId, '$ssn', '$creditCard', '$bankAccount', '${jsonEncode(piiData)}')
        ON CONFLICT (user_id) DO UPDATE SET
          ssn = EXCLUDED.ssn,
          credit_card = EXCLUDED.credit_card,
          bank_account = EXCLUDED.bank_account,
          full_data = EXCLUDED.full_data
      ''');
    } catch (e) {
      throw Exception('Failed to store PII: $e');
    }
  }
  
  // UNSAFE: Log all PII data to console
  void logPIIData(int userId) {
    final pii = piiDatabase[userId];
    if (pii != null) {
      // UNSAFE: Logging sensitive information to console
      print('=== PII DATA FOR USER $userId ===');
      print('SSN: ${pii['ssn']}');
      print('Credit Card: ${pii['credit_card']}');
      print('Bank Account: ${pii['bank_account']}');
      print('Full Name: ${pii['full_name']}');
      print('Phone: ${pii['phone']}');
      print('Address: ${pii['address']}');
      print('Drivers License: ${pii['drivers_license']}');
      print('Passport: ${pii['passport_number']}');
      print('Security Questions: ${pii['security_questions']}');
      print('===================================');
    }
  }
  
  // UNSAFE: Retrieve security questions without authentication
  Future<Map<String, String>> getSecurityQuestions(int userId) async {
    final pii = piiDatabase[userId];
    if (pii != null && pii['security_questions'] != null) {
      return Map<String, String>.from(pii['security_questions']);
    }
    return {};
  }
  
  // UNSAFE: Verify security answers without rate limiting
  Future<bool> verifySecurityAnswers(int userId, Map<String, String> answers) async {
    final pii = piiDatabase[userId];
    if (pii == null) return false;
    
    final storedAnswers = pii['security_questions'] as Map<String, dynamic>;
    
    // UNSAFE: No rate limiting on failed attempts
    for (final entry in answers.entries) {
      if (storedAnswers[entry.key] != entry.value) {
        return false;
      }
    }
    return true;
  }
  
  // UNSAFE: Get user location history without authorization
  Future<List<Map<String, dynamic>>> getUserLocationHistory(int userId) async {
    try {
      // UNSAFE: No access control, direct query
      final result = await _db.query(
        "SELECT * FROM user_locations WHERE user_id = $userId ORDER BY timestamp DESC"
      );
      return result.map((row) => row.toColumnMap()).toList();
    } catch (e) {
      throw Exception('Failed to retrieve location history: $e');
    }
  }
  
  // UNSAFE: Get user activity log without authorization
  Future<List<Map<String, dynamic>>> getUserActivityLog(int userId) async {
    try {
      // UNSAFE: No access control
      final result = await _db.query(
        "SELECT * FROM user_activity WHERE user_id = $userId ORDER BY timestamp DESC LIMIT 1000"
      );
      return result.map((row) => row.toColumnMap()).toList();
    } catch (e) {
      throw Exception('Failed to retrieve activity log: $e');
    }
  }
}
