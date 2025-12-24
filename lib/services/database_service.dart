import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/note_model.dart';

/// Service Layer - Xử lý tất cả thao tác với SQLite database
/// Đây là tầng Service trong kiến trúc MVVM, chịu trách nhiệm lưu trữ dữ liệu
class DatabaseService {
  static final DatabaseService _instance = DatabaseService._internal();
  static Database? _database;

  factory DatabaseService() {
    return _instance;
  }

  DatabaseService._internal();

  /// Getter cho database instance
  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  /// Khởi tạo database
  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'notes.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
  }

  /// Tạo table notes khi database được khởi tạo lần đầu
  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE notes(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT NOT NULL,
        content TEXT NOT NULL,
        tag TEXT,
        createdAt TEXT NOT NULL,
        updatedAt TEXT NOT NULL
      )
    ''');
  }

  /// CREATE - Thêm ghi chú mới
  Future<int> insertNote(NoteModel note) async {
    final db = await database;
    return await db.insert('notes', note.toMap());
  }

  /// READ - Lấy tất cả ghi chú
  Future<List<NoteModel>> getAllNotes() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'notes',
      orderBy: 'updatedAt DESC',
    );
    return List.generate(maps.length, (i) => NoteModel.fromMap(maps[i]));
  }

  /// READ - Lấy ghi chú theo ID
  Future<NoteModel?> getNoteById(int id) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'notes',
      where: 'id = ?',
      whereArgs: [id],
    );
    if (maps.isEmpty) return null;
    return NoteModel.fromMap(maps.first);
  }

  /// UPDATE - Cập nhật ghi chú
  Future<int> updateNote(NoteModel note) async {
    final db = await database;
    return await db.update(
      'notes',
      note.toMap(),
      where: 'id = ?',
      whereArgs: [note.id],
    );
  }

  /// DELETE - Xóa ghi chú
  Future<int> deleteNote(int id) async {
    final db = await database;
    return await db.delete(
      'notes',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  /// SEARCH - Tìm kiếm ghi chú theo từ khóa
  Future<List<NoteModel>> searchNotes(String keyword) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'notes',
      where: 'title LIKE ? OR content LIKE ?',
      whereArgs: ['%$keyword%', '%$keyword%'],
      orderBy: 'updatedAt DESC',
    );
    return List.generate(maps.length, (i) => NoteModel.fromMap(maps[i]));
  }

  /// FILTER - Lọc ghi chú theo tag
  Future<List<NoteModel>> getNotesByTag(String tag) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'notes',
      where: 'tag = ?',
      whereArgs: [tag],
      orderBy: 'updatedAt DESC',
    );
    return List.generate(maps.length, (i) => NoteModel.fromMap(maps[i]));
  }

  /// Close database
  Future<void> closeDatabase() async {
    final db = await database;
    await db.close();
  }
}
