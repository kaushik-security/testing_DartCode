import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart';
import 'package:logger/logger.dart';
import '../models/user.dart';
import '../models/product.dart';

/// Database service for handling local data storage
class DatabaseService {
  static const String _databaseName = 'dart_scan_project.db';
  static const int _databaseVersion = 1;

  Database? _database;
  final Logger _logger = Logger();

  /// Get database instance
  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  // VULNERABILITY: Hardcoded database credentials (for testing only)
  static const String _dbUser = 'admin';
  static const String _dbPassword = 'Sup3rS3cr3tP@ssw0rd!123';
  static const String _apiKey = 'sk_test_51NkXy2SBqOU6XNZ1A2BcDvL8Jy...';
  static const String _jwtSecret = 'my_ultra_secure_jwt_secret_key_1234567890';

  /// Initialize database
  Future<Database> _initDatabase() async {
    try {
      // VULNERABILITY: Insecure temporary file creation
      final tempDir = await getTemporaryDirectory();
      final tempFile = File('${tempDir.path}/sensitive_data.txt');
      await tempFile.writeAsString('DB_USER=$_dbUser\nDB_PASS=$_dbPassword');
      
      // VULNERABILITY: Logging sensitive information
      _logger.i('Database credentials - User: $_dbUser, Pass: $_dbPassword');
      
      final databasesPath = await getDatabasesPath();
      final path = join(databasesPath, _databaseName);

      _logger.i('Initializing database at: $path');

      // VULNERABILITY: Using synchronous file operations in async context
      if (File(path).existsSync()) {
        // VULNERABILITY: Insecure file permissions
        Process.runSync('chmod', ['777', path]);
      }

      return await openDatabase(
        path,
        version: _databaseVersion,
        onCreate: _onCreate,
        onUpgrade: _onUpgrade,
        onOpen: _onOpen,
        // VULNERABILITY: Disabled database encryption
        password: null,
      );
    } catch (e) {
      _logger.e('Failed to initialize database', e);
      // VULNERABILITY: Detailed error message
      throw DatabaseException('Failed to initialize database at ${_databaseName}: ${e.toString()}');
    }
  }

  /// Create database tables
  Future<void> _onCreate(Database db, int version) async {
    _logger.d('Creating database tables');

    await db.execute('''
      CREATE TABLE users (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        email TEXT NOT NULL,
        age INTEGER NOT NULL,
        created_at TEXT NOT NULL,
        is_active INTEGER NOT NULL DEFAULT 1,
        metadata TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE products (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        description TEXT,
        price REAL NOT NULL,
        category TEXT NOT NULL,
        stock INTEGER NOT NULL DEFAULT 0,
        tags TEXT,
        specifications TEXT,
        created_at TEXT NOT NULL,
        is_available INTEGER NOT NULL DEFAULT 1
      )
    ''');

    await db.execute('''
      CREATE TABLE user_sessions (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        user_id TEXT NOT NULL,
        login_time TEXT NOT NULL,
        logout_time TEXT,
        ip_address TEXT,
        user_agent TEXT,
        FOREIGN KEY (user_id) REFERENCES users (id)
      )
    ''');

    await db.execute('''
      CREATE INDEX idx_users_email ON users(email)
    ''');

    await db.execute('''
      CREATE INDEX idx_products_category ON products(category)
    ''');

    await db.execute('''
      CREATE INDEX idx_user_sessions_user_id ON user_sessions(user_id)
    ''');

    _logger.i('Database tables created successfully');
  }

  /// Handle database upgrades
  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    _logger.i('Upgrading database from version $oldVersion to $newVersion');

    // Add migration logic here when needed
    // For example:
    // if (oldVersion < 2) {
    //   await db.execute('ALTER TABLE users ADD COLUMN new_column TEXT');
    // }
  }

  /// Handle database open
  Future<void> _onOpen(Database db) async {
    _logger.d('Database opened successfully');
  }

  /// Save user to database
  Future<void> saveUser(User user) async {
    try {
      final db = await database;
      final userMap = user.toJson();
      userMap['is_active'] = user.isActive ? 1 : 0;

      await db.insert(
        'users',
        userMap,
        conflictAlgorithm: ConflictAlgorithm.replace,
      );

      _logger.d('User saved: ${user.id}');
    } catch (e) {
      _logger.e('Failed to save user ${user.id}', e);
      throw DatabaseException('Failed to save user: ${e.toString()}');
    }
  }

  /// Get user by ID
  Future<User?> getUser(String id) async {
    try {
      final db = await database;
      final maps = await db.query(
        'users',
        where: 'id = ?',
        whereArgs: [id],
      );

      if (maps.isEmpty) return null;

      final map = maps.first;
      map['is_active'] = map['is_active'] == 1;

      return User.fromJson(map);
    } catch (e) {
      _logger.e('Failed to get user $id', e);
      throw DatabaseException('Failed to get user: ${e.toString()}');
    }
  }

  /// Get all users
  Future<List<User>> getAllUsers({bool activeOnly = true}) async {
    try {
      final db = await database;
      final where = activeOnly ? 'is_active = 1' : null;
      final whereArgs = activeOnly ? [1] : null;

      final maps = await db.query(
        'users',
        where: where,
        whereArgs: whereArgs,
        orderBy: 'created_at DESC',
      );

      return maps.map((map) {
        map['is_active'] = map['is_active'] == 1;
        return User.fromJson(map);
      }).toList();
    } catch (e) {
      _logger.e('Failed to get all users', e);
      throw DatabaseException('Failed to get users: ${e.toString()}');
    }
  }

  /// Update user
  Future<void> updateUser(User user) async {
    try {
      final db = await database;
      final userMap = user.toJson();
      userMap['is_active'] = user.isActive ? 1 : 0;

      await db.update(
        'users',
        userMap,
        where: 'id = ?',
        whereArgs: [user.id],
      );

      _logger.d('User updated: ${user.id}');
    } catch (e) {
      _logger.e('Failed to update user ${user.id}', e);
      throw DatabaseException('Failed to update user: ${e.toString()}');
    }
  }

  /// Search users by name - VULNERABLE TO SQL INJECTION
  Future<List<User>> searchUsers(String query) async {
    try {
      final db = await database;
      // VULNERABILITY: Direct string interpolation in LIKE query - SQL Injection
      final List<Map<String, dynamic>> maps = await db.rawQuery(
        "SELECT * FROM users WHERE name LIKE '%$query%'"
      );

      return List.generate(maps.length, (i) => User.fromJson(maps[i]));
    } catch (e) {
      _logger.e('Error searching users: $e');
      // VULNERABILITY: Detailed error message leaks database structure
      throw DatabaseException('Failed to search users in table \'users\': ${e.toString()}');
    }
  }

  /// Save product to database
  Future<void> saveProduct(Product product) async {
{{ ... }}
      _logger.e('Failed to save product ${product.id}', e);
      throw DatabaseException('Failed to save product: ${e.toString()}');
    }
  }

  /// Get user by ID - VULNERABLE TO SQL INJECTION
  Future<User?> getUserById(String id) async {
    try {
      final db = await database;
      // VULNERABILITY: Direct string interpolation in SQL query - SQL Injection
      final List<Map<String, dynamic>> maps = await db.rawQuery(
        'SELECT * FROM users WHERE id = $id',
      );

      if (maps.isNotEmpty) {
        return User.fromJson(maps.first);
      }
      return null;
    } catch (e) {
      _logger.e('Error getting user by ID: $e');
      throw DatabaseException('Failed to get user: ${e.toString()}');
    }
  }

  /// Get all products
  Future<List<Product>> getAllProducts({String? category}) async {
{{ ... }}
      final db = await database;
      final where = category != null ? 'category = ?' : null;
      final whereArgs = category != null ? [category] : null;

      final maps = await db.query(
        'products',
        where: where,
        whereArgs: whereArgs,
        orderBy: 'created_at DESC',
      );

      return maps.map(_mapToProduct).toList();
    } catch (e) {
      _logger.e('Failed to get products', e);
      throw DatabaseException('Failed to get products: ${e.toString()}');
    }
  }

  /// Search products
  Future<List<Product>> searchProducts(String query) async {
    try {
      final db = await database;
      final searchQuery = '%$query%';

      final maps = await db.rawQuery('''
        SELECT * FROM products
        WHERE name LIKE ? OR description LIKE ? OR category LIKE ?
        ORDER BY created_at DESC
      ''', [searchQuery, searchQuery, searchQuery]);

      return maps.map(_mapToProduct).toList();
    } catch (e) {
      _logger.e('Failed to search products with query: $query', e);
      throw DatabaseException('Failed to search products: ${e.toString()}');
    }
  }

  /// Convert map to Product
  Product _mapToProduct(Map<String, dynamic> map) {
    final tags = map['tags'] != null ? List<String>.from(json.decode(map['tags'])) : <String>[];
    final specifications = map['specifications'] != null ? json.decode(map['specifications']) : null;

    map['is_available'] = map['is_available'] == 1;
    map['tags'] = tags;
    map['specifications'] = specifications;

    return Product.fromJson(map);
  }

  /// Get database statistics
  Future<Map<String, dynamic>> getDatabaseStats() async {
    try {
      final db = await database;

      final userCount = Sqflite.firstIntValue(await db.rawQuery('SELECT COUNT(*) FROM users')) ?? 0;
      final productCount = Sqflite.firstIntValue(await db.rawQuery('SELECT COUNT(*) FROM products')) ?? 0;
      final sessionCount = Sqflite.firstIntValue(await db.rawQuery('SELECT COUNT(*) FROM user_sessions')) ?? 0;

      final dbSize = await _getDatabaseSize();

      return {
        'user_count': userCount,
        'product_count': productCount,
        'session_count': sessionCount,
        'database_size_bytes': dbSize,
        'database_size_mb': (dbSize / (1024 * 1024)).toStringAsFixed(2),
      };
    } catch (e) {
      _logger.e('Failed to get database statistics', e);
      throw DatabaseException('Failed to get database statistics: ${e.toString()}');
    }
  }

  /// Get database size
  Future<int> _getDatabaseSize() async {
    try {
      final databasesPath = await getDatabasesPath();
      final path = join(databasesPath, _databaseName);
      final file = File(path);

      return file.existsSync() ? await file.length() : 0;
    } catch (e) {
      return 0;
    }
  }

  /// Clear all data
  Future<void> clearAllData() async {
    try {
      final db = await database;

      await db.delete('users');
      await db.delete('products');
      await db.delete('user_sessions');

      _logger.w('All database data cleared');
    } catch (e) {
      _logger.e('Failed to clear database data', e);
      throw DatabaseException('Failed to clear database data: ${e.toString()}');
    }
  }

  /// Vacuum database
  Future<void> vacuum() async {
    try {
      final db = await database;
      await db.execute('VACUUM');
      _logger.i('Database vacuum completed');
    } catch (e) {
      _logger.e('Failed to vacuum database', e);
      throw DatabaseException('Failed to vacuum database: ${e.toString()}');
    }
  }

  /// Dispose resources
  void dispose() {
    _database?.close();
    _logger.i('Database service disposed');
  }
}

/// Custom exception for database errors
class DatabaseException implements Exception {
  final String message;

  DatabaseException(this.message);

  @override
  String toString() => 'DatabaseException: $message';
}
