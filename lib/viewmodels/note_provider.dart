import 'package:flutter/foundation.dart';
import '../models/note_model.dart';
import '../repositories/note_repository.dart';

/// ViewModel - Quản lý trạng thái và logic xử lý trong MVVM
/// Sử dụng Provider (ChangeNotifier) để thực hiện Data Binding
/// View sẽ tự động cập nhật khi ViewModel thay đổi
class NoteProvider extends ChangeNotifier {
  final NoteRepository _repository = NoteRepository();

  // State management
  List<NoteModel> _notes = [];
  List<NoteModel> _filteredNotes = [];
  bool _isLoading = false;
  String _searchKeyword = '';
  String? _selectedTag;

  // Getters - Phơi bày dữ liệu cho View (Data Binding)
  List<NoteModel> get notes => _filteredNotes.isEmpty && _searchKeyword.isEmpty
      ? _notes
      : _filteredNotes;
  bool get isLoading => _isLoading;
  String get searchKeyword => _searchKeyword;
  String? get selectedTag => _selectedTag;
  int get notesCount => notes.length;

  /// Load tất cả ghi chú từ database
  Future<void> loadNotes() async {
    _isLoading = true;
    notifyListeners();

    try {
      _notes = await _repository.getAllNotes();
      _filteredNotes = [];
      _searchKeyword = '';
      _selectedTag = null;
    } catch (e) {
      debugPrint('Error loading notes: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Thêm ghi chú mới
  Future<bool> addNote({
    required String title,
    required String content,
    String? tag,
  }) async {
    try {
      final now = DateTime.now();
      final note = NoteModel(
        title: title,
        content: content,
        tag: tag,
        createdAt: now,
        updatedAt: now,
      );

      await _repository.addNote(note);
      await loadNotes(); // Reload danh sách
      return true;
    } catch (e) {
      debugPrint('Error adding note: $e');
      return false;
    }
  }

  /// Cập nhật ghi chú
  Future<bool> updateNote({
    required int id,
    required String title,
    required String content,
    String? tag,
    required DateTime createdAt,
  }) async {
    try {
      final note = NoteModel(
        id: id,
        title: title,
        content: content,
        tag: tag,
        createdAt: createdAt,
        updatedAt: DateTime.now(),
      );

      await _repository.updateNote(note);
      await loadNotes(); // Reload danh sách
      return true;
    } catch (e) {
      debugPrint('Error updating note: $e');
      return false;
    }
  }

  /// Xóa ghi chú
  Future<bool> deleteNote(int id) async {
    try {
      await _repository.deleteNote(id);
      await loadNotes(); // Reload danh sách
      return true;
    } catch (e) {
      debugPrint('Error deleting note: $e');
      return false;
    }
  }

  /// Tìm kiếm ghi chú theo từ khóa (real-time search)
  Future<void> searchNotes(String keyword) async {
    _searchKeyword = keyword;

    if (keyword.isEmpty) {
      _filteredNotes = [];
      notifyListeners();
      return;
    }

    try {
      _filteredNotes = await _repository.searchNotes(keyword);
      notifyListeners();
    } catch (e) {
      debugPrint('Error searching notes: $e');
    }
  }

  /// Lọc ghi chú theo tag
  Future<void> filterByTag(String? tag) async {
    _selectedTag = tag;

    if (tag == null || tag.isEmpty) {
      await loadNotes();
      return;
    }

    try {
      _filteredNotes = await _repository.getNotesByTag(tag);
      notifyListeners();
    } catch (e) {
      debugPrint('Error filtering notes by tag: $e');
    }
  }

  /// Clear search và filter
  void clearFilters() {
    _searchKeyword = '';
    _selectedTag = null;
    _filteredNotes = [];
    notifyListeners();
  }
}
