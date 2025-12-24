import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/note_provider.dart';
import '../viewmodels/auth_provider.dart';

/// App Bindings - Cấu hình Data Binding cho ứng dụng
/// Thiết lập Provider để thực hiện Data Binding giữa View và ViewModel
/// Tương đương với DataContext binding trong WPF/XAML

class AppBindings {
  /// Khởi tạo tất cả Provider cho ứng dụng
  static List<ChangeNotifierProvider> getProviders() {
    return [
      ChangeNotifierProvider(
        create: (_) => AuthProvider()..initialize(),
      ),
      ChangeNotifierProvider(
        create: (_) => NoteProvider(),
      ),
    ];
  }

  /// Wrap app với MultiProvider để enable Data Binding
  static Widget setupBindings(Widget child) {
    return MultiProvider(
      providers: getProviders(),
      child: child,
    );
  }
}
