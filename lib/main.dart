import 'package:flutter/foundation.dart' show kIsWeb, defaultTargetPlatform, TargetPlatform;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'views/screens/login_screen.dart';
import 'views/screens/register_screen.dart';
import 'views/screens/home_screen.dart';
import 'constants/app_constants.dart';
import 'viewmodels/auth_provider.dart';
import 'viewmodels/note_provider.dart';

// Conditional import for database initialization
import 'config/database_init_web.dart' if (dart.library.io) 'config/database_init_desktop.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize FFI for desktop platforms (Windows, Linux, macOS)
  // Skip on web since dart:io is not available
  if (!kIsWeb) {
    final isDesktop = defaultTargetPlatform == TargetPlatform.windows ||
        defaultTargetPlatform == TargetPlatform.linux ||
        defaultTargetPlatform == TargetPlatform.macOS;
    if (isDesktop) {
      initDesktopDatabase();
    }
  }

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()..initialize()),
        ChangeNotifierProvider(create: (_) => NoteProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: AppStrings.appName,
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: AppColors.primary),
        useMaterial3: true,
      ),
      initialRoute: '/home',
      routes: {
        '/login': (context) => const LoginScreen(),
        '/register': (context) => const RegisterScreen(),
        '/home': (context) => const HomeScreen(),
      },
    );
  }
}
