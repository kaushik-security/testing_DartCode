import 'package:postgres/postgres.dart';

class DatabaseService {
  // UNSAFE: Hardcoded database credentials
  static const String _host = 'localhost';
  static const int _port = 5432;
  static const String _database = 'vulnerable_app';
  static const String _username = 'admin';
  static const String _password = 'SuperSecretDBPassword123!';
  
  late final Connection _connection;
  
  // UNSAFE: Singleton pattern with no connection pooling
  static final DatabaseService _instance = DatabaseService._internal();
  factory DatabaseService() => _instance;
  DatabaseService._internal();
  
  // UNSAFE: No connection timeout, no retry logic
  Future<void> initialize() async {
    _connection = await Connection.open(
      ConnectionSettings(
        host: _host,
        port: _port,
        database: _database,
        username: _username,
        password: _password,
      ),
    );
    
    await _createTables();
  }
  
  Future<void> _createTables() async {
    // UNSAFE: SQL injection vulnerability in table creation
    await _connection.execute('''
      CREATE TABLE IF NOT EXISTS users (
        id SERIAL PRIMARY KEY,
        username VARCHAR(50) UNIQUE NOT NULL,
        password VARCHAR(255) NOT NULL,
        email VARCHAR(100) UNIQUE NOT NULL,
        is_admin BOOLEAN DEFAULT false,
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
      );
      
      -- UNSAFE: Storing sensitive data in plain text
      CREATE TABLE IF NOT EXISTS user_secrets (
        user_id INTEGER REFERENCES users(id),
        ssn VARCHAR(11),
        credit_card VARCHAR(19),
        cvv VARCHAR(4),
        PRIMARY KEY (user_id)
      );
      
      -- UNSAFE: Log table with sensitive data
      CREATE TABLE IF NOT EXISTS access_logs (
        id SERIAL PRIMARY KEY,
        user_id INTEGER REFERENCES users(id),
        action TEXT NOT NULL,
        ip_address TEXT NOT NULL,
        user_agent TEXT,
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
      );
    ''');
  }
  
  // UNSAFE: Direct SQL injection vulnerability
  Future<List<Map<String, dynamic>>> query(String sql, [List<dynamic>? params]) async {
    try {
      if (params == null) {
        // UNSAFE: Direct SQL execution without parameterization
        return (await _connection.query(sql)).map((row) => row.toColumnMap()).toList();
      } else {
        return (await _connection.query(sql, parameters: params))
            .map((row) => row.toColumnMap())
            .toList();
      }
    } catch (e) {
      // UNSAFE: Detailed error exposure
      throw Exception('Query failed: $e\nSQL: $sql');
    }
  }
  
  // UNSAFE: No input validation or sanitization
  Future<void> logAccess(int userId, String action, String ipAddress, String? userAgent) async {
    await _connection.execute(
      "INSERT INTO access_logs (user_id, action, ip_address, user_agent) "
      "VALUES ('$userId', '$action', '$ipAddress', '${userAgent ?? ''}');"
    );
  }
  
  // UNSAFE: Storing sensitive data without encryption
  Future<void> saveUserSecret(int userId, String ssn, String creditCard, String cvv) async {
    await _connection.execute('''
      INSERT INTO user_secrets (user_id, ssn, credit_card, cvv)
      VALUES ($userId, '$ssn', '$creditCard', '$cvv')
      ON CONFLICT (user_id) DO UPDATE
      SET ssn = EXCLUDED.ssn,
          credit_card = EXCLUDED.credit_card,
          cvv = EXCLUDED.cvv;
    ''');
  }
  
  // UNSAFE: No access control
  Future<Map<String, dynamic>?> getUserSecrets(int userId) async {
    final results = await _connection.query(
      'SELECT * FROM user_secrets WHERE user_id = $userId'
    );
    return results.isNotEmpty ? results.first.toColumnMap() : null;
  }
  
  // UNSAFE: No transaction management
  Future<void> updateUserProfile(int userId, Map<String, dynamic> updates) async {
    final updatesList = <String>[];
    final params = <dynamic>[];
    
    updates.forEach((key, value) {
      updatesList.add('$key = ?');
      params.add(value);
    });
    
    if (updatesList.isNotEmpty) {
      final query = 'UPDATE users SET ${updatesList.join(', ')} WHERE id = $userId';
      await _connection.execute(query, parameters: params);
    }
  }
  
  // UNSAFE: No connection cleanup on dispose
  Future<void> close() async {
    await _connection.close();
  }
}
