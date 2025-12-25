import '../models/note_model.dart';
// Conditional import: use web service on web, SQLite service on desktop
import '../services/database_service_web.dart' if (dart.library.io) '../services/database_service.dart';

/// Repository Pattern - Tầng trung gian giữa ViewModel và Service
/// Giúp tách biệt logic truy xuất dữ liệu, giảm coupling
class NoteRepository {
  final DatabaseService _databaseService = DatabaseService();

  /// Lấy tất cả ghi chú
  Future<List<NoteModel>> getAllNotes() async {
    return await _databaseService.getAllNotes();
  }

  /// Lấy ghi chú theo ID
  Future<NoteModel?> getNoteById(int id) async {
    return await _databaseService.getNoteById(id);
  }

  /// Thêm ghi chú mới
  Future<int> addNote(NoteModel note) async {
    return await _databaseService.insertNote(note);
  }

  /// Cập nhật ghi chú
  Future<int> updateNote(NoteModel note) async {
    return await _databaseService.updateNote(note);
  }

  /// Xóa ghi chú
  Future<int> deleteNote(int id) async {
    return await _databaseService.deleteNote(id);
  }

  /// Tìm kiếm ghi chú
  Future<List<NoteModel>> searchNotes(String keyword) async {
    if (keyword.isEmpty) {
      return await getAllNotes();
    }
    return await _databaseService.searchNotes(keyword);
  }

  /// Lọc ghi chú theo tag
  Future<List<NoteModel>> getNotesByTag(String tag) async {
    return await _databaseService.getNotesByTag(tag);
  }
}
