import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_model.dart';
import '../repositories/auth_repository.dart';

/// ViewModel - Quản lý trạng thái Authentication
class AuthProvider extends ChangeNotifier {
  final AuthRepository _repository = AuthRepository();

  UserModel? _currentUser;
  bool _isAuthenticated = false;
  bool _isLoading = false;

  // Getters
  UserModel? get currentUser => _currentUser;
  bool get isAuthenticated => _isAuthenticated;
  bool get isLoading => _isLoading;

  /// Khởi tạo - Kiểm tra session
  Future<void> initialize() async {
    _isLoading = true;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getInt('userId');

      if (userId != null) {
        final user = await _repository.getUserById(userId);
        if (user != null) {
          _currentUser = user;
          _isAuthenticated = true;
        }
      }
    } catch (e) {
      debugPrint('Error initializing auth: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Đăng ký
  Future<Map<String, dynamic>> register({
    required String username,
    required String email,
    required String password,
  }) async {
    _isLoading = true;
    notifyListeners();

    try {
      final result = await _repository.register(
        username: username,
        email: email,
        password: password,
      );

      if (result['success']) {
        // Tự động đăng nhập sau khi đăng ký
        await login(username: username, password: password);
      }

      return result;
    } catch (e) {
      return {
        'success': false,
        'message': 'Lỗi: $e',
      };
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Đăng nhập
  Future<Map<String, dynamic>> login({
    required String username,
    required String password,
  }) async {
    _isLoading = true;
    notifyListeners();

    try {
      final result = await _repository.login(
        username: username,
        password: password,
      );

      if (result['success']) {
        _currentUser = result['user'] as UserModel;
        _isAuthenticated = true;

        // Lưu session
        final prefs = await SharedPreferences.getInstance();
        await prefs.setInt('userId', _currentUser!.id!);
      }

      return result;
    } catch (e) {
      return {
        'success': false,
        'message': 'Lỗi: $e',
      };
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Đăng xuất
  Future<void> logout() async {
    _currentUser = null;
    _isAuthenticated = false;

    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('userId');

    notifyListeners();
  }
}
