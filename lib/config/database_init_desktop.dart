import 'package:sqflite_common_ffi/sqflite_ffi.dart';

/// Initialize sqflite for desktop platforms
void initDesktopDatabase() {
  sqfliteFfiInit();
  databaseFactory = databaseFactoryFfi;
}
