/// Model - Định nghĩa cấu trúc dữ liệu User
/// Phục vụ cho chức năng Authentication
class UserModel {
  final int? id;
  final String username;
  final String email;
  final String password; // Sẽ được hash trước khi lưu
  final DateTime createdAt;

  UserModel({
    this.id,
    required this.username,
    required this.email,
    required this.password,
    required this.createdAt,
  });

  /// Convert User object to Map for SQLite
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'username': username,
      'email': email,
      'password': password,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  /// Create User object from Map
  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      id: map['id'] as int?,
      username: map['username'] as String,
      email: map['email'] as String,
      password: map['password'] as String,
      createdAt: DateTime.parse(map['createdAt'] as String),
    );
  }

  /// Create a copy of User with updated fields
  UserModel copyWith({
    int? id,
    String? username,
    String? email,
    String? password,
    DateTime? createdAt,
  }) {
    return UserModel(
      id: id ?? this.id,
      username: username ?? this.username,
      email: email ?? this.email,
      password: password ?? this.password,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
