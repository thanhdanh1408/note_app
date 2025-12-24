import 'package:sqflite/sqflite.dart';
import 'package:crypto/crypto.dart';
import 'dart:convert';
import '../models/user_model.dart';
import 'database_service.dart';

/// Service Layer - Xử lý Authentication
/// Đăng ký, đăng nhập, quản lý session
class AuthService {
  static final AuthService _instance = AuthService._internal();
  final DatabaseService _databaseService = DatabaseService();

  factory AuthService() {
    return _instance;
  }

  AuthService._internal();

  /// Khởi tạo table users
  Future<void> initializeAuthTables() async {
    final db = await _databaseService.database;
    await db.execute('''
      CREATE TABLE IF NOT EXISTS users(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        username TEXT UNIQUE NOT NULL,
        email TEXT UNIQUE NOT NULL,
        password TEXT NOT NULL,
        createdAt TEXT NOT NULL
      )
    ''');
  }

  /// Hash mật khẩu
  String _hashPassword(String password) {
    var bytes = utf8.encode(password);
    var digest = sha256.convert(bytes);
    return digest.toString();
  }

  /// Đăng ký user mới
  Future<Map<String, dynamic>> register({
    required String username,
    required String email,
    required String password,
  }) async {
    try {
      await initializeAuthTables();
      final db = await _databaseService.database;

      // Kiểm tra username đã tồn tại
      final existingUser = await db.query(
        'users',
        where: 'username = ? OR email = ?',
        whereArgs: [username, email],
      );

      if (existingUser.isNotEmpty) {
        return {
          'success': false,
          'message': 'Tên đăng nhập hoặc email đã tồn tại',
        };
      }

      // Tạo user mới
      final user = UserModel(
        username: username,
        email: email,
        password: _hashPassword(password),
        createdAt: DateTime.now(),
      );

      final id = await db.insert('users', user.toMap());

      return {
        'success': true,
        'message': 'Đăng ký thành công',
        'userId': id,
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Lỗi: $e',
      };
    }
  }

  /// Đăng nhập
  Future<Map<String, dynamic>> login({
    required String username,
    required String password,
  }) async {
    try {
      await initializeAuthTables();
      final db = await _databaseService.database;

      final result = await db.query(
        'users',
        where: 'username = ? AND password = ?',
        whereArgs: [username, _hashPassword(password)],
      );

      if (result.isEmpty) {
        return {
          'success': false,
          'message': 'Tên đăng nhập hoặc mật khẩu không đúng',
        };
      }

      final user = UserModel.fromMap(result.first);

      return {
        'success': true,
        'message': 'Đăng nhập thành công',
        'user': user,
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Lỗi: $e',
      };
    }
  }

  /// Lấy thông tin user theo ID
  Future<UserModel?> getUserById(int id) async {
    try {
      await initializeAuthTables();
      final db = await _databaseService.database;
      
      final result = await db.query(
        'users',
        where: 'id = ?',
        whereArgs: [id],
      );

      if (result.isEmpty) return null;
      return UserModel.fromMap(result.first);
    } catch (e) {
      return null;
    }
  }
}
