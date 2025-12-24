import '../models/user_model.dart';
import '../services/auth_service.dart';

/// Repository Pattern - Tầng trung gian cho Authentication
class AuthRepository {
  final AuthService _authService = AuthService();

  /// Đăng ký user mới
  Future<Map<String, dynamic>> register({
    required String username,
    required String email,
    required String password,
  }) async {
    return await _authService.register(
      username: username,
      email: email,
      password: password,
    );
  }

  /// Đăng nhập
  Future<Map<String, dynamic>> login({
    required String username,
    required String password,
  }) async {
    return await _authService.login(
      username: username,
      password: password,
    );
  }

  /// Lấy thông tin user
  Future<UserModel?> getUserById(int id) async {
    return await _authService.getUserById(id);
  }
}
