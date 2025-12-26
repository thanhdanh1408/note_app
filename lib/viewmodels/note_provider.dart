import 'package:flutter/foundation.dart';
import '../models/note_model.dart';
import '../repositories/note_repository.dart';

/// Tùy chọn sắp xếp trên Home
enum NoteSortOption {
  dateModified, // updatedAt DESC
  dateCreated, // createdAt DESC
  titleAZ, // title A-Z
}

class NoteProvider extends ChangeNotifier {
  final NoteRepository _repository = NoteRepository();

  // Data gốc từ DB
  List<NoteModel> _notes = [];

  // Data hiển thị khi search/filter
  List<NoteModel> _filteredNotes = [];

  bool _isLoading = false;
  String _searchKeyword = '';
  String? _selectedTag;

  // Sort mặc định: ngày sửa mới nhất
  NoteSortOption _sortOption = NoteSortOption.dateModified;

  // Notes đang hiển thị (gốc hoặc đã search/filter)
  List<NoteModel> get notes => _filteredNotes.isEmpty && _searchKeyword.isEmpty
      ? _notes
      : _filteredNotes;

  bool get isLoading => _isLoading;
  String get searchKeyword => _searchKeyword;
  String? get selectedTag => _selectedTag;

  NoteSortOption get sortOption => _sortOption;

  // Notes gốc (dùng để lấy tag/count)
  List<NoteModel> get allNotes => _notes;

  // Dùng cho empty state: đang có search/filter/sort không
  bool get hasActiveFilters {
    final hasSearch = _searchKeyword.trim().isNotEmpty;
    final hasTag = _selectedTag != null && _selectedTag!.trim().isNotEmpty;
    final hasSort = _sortOption != NoteSortOption.dateModified;
    return hasSearch || hasTag || hasSort;
  }

  // Lấy danh sách tag unique từ notes gốc
  List<String> getAvailableTags() {
    final tags = _notes
        .where((n) => n.tag != null && n.tag!.trim().isNotEmpty)
        .map((n) => n.tag!.trim())
        .toSet()
        .toList();
    tags.sort((a, b) => a.toLowerCase().compareTo(b.toLowerCase()));
    return tags;
  }

  Future<void> loadNotes() async {
    _isLoading = true;
    notifyListeners();

    try {
      _notes = await _repository.getAllNotes();
      _filteredNotes = [];
      _searchKeyword = '';
      _selectedTag = null;
      _applySort();
    } catch (e) {
      debugPrint('Error loading notes: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

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
      await loadNotes();
      return true;
    } catch (e) {
      debugPrint('Error adding note: $e');
      return false;
    }
  }

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
      await loadNotes();
      return true;
    } catch (e) {
      debugPrint('Error updating note: $e');
      return false;
    }
  }

  Future<bool> deleteNote(int id) async {
    try {
      await _repository.deleteNote(id);
      await loadNotes();
      return true;
    } catch (e) {
      debugPrint('Error deleting note: $e');
      return false;
    }
  }

  // Search realtime theo title/content
  Future<void> searchNotes(String keyword) async {
    _searchKeyword = keyword;

    if (keyword.isEmpty) {
      _filteredNotes = [];
      notifyListeners();
      return;
    }

    try {
      _filteredNotes = await _repository.searchNotes(keyword);
      _applySort();
      notifyListeners();
    } catch (e) {
      debugPrint('Error searching notes: $e');
    }
  }

  // Filter theo tag
  Future<void> filterByTag(String? tag) async {
    _selectedTag = tag;

    if (tag == null || tag.isEmpty) {
      await loadNotes();
      return;
    }

    try {
      _filteredNotes = await _repository.getNotesByTag(tag);
      _applySort();
      notifyListeners();
    } catch (e) {
      debugPrint('Error filtering notes by tag: $e');
    }
  }

  // Xóa search + tag filter (không reset sort)
  void clearFilters() {
    _searchKeyword = '';
    _selectedTag = null;
    _filteredNotes = [];
    notifyListeners();
  }

  // Xóa tất cả (search + tag + sort)
  void clearAllFilters() {
    _searchKeyword = '';
    _selectedTag = null;
    _filteredNotes = [];
    _sortOption = NoteSortOption.dateModified;
    _applySort();
    notifyListeners();
  }

  // Đổi sort và áp dụng lên danh sách hiện tại
  void setSortOption(NoteSortOption option) {
    _sortOption = option;
    _applySort();
    notifyListeners();
  }

  void _applySort() {
    final listToSort = (_filteredNotes.isNotEmpty || _searchKeyword.isNotEmpty)
        ? _filteredNotes
        : _notes;

    switch (_sortOption) {
      case NoteSortOption.dateModified:
        listToSort.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
        break;
      case NoteSortOption.dateCreated:
        listToSort.sort((a, b) => b.createdAt.compareTo(a.createdAt));
        break;
      case NoteSortOption.titleAZ:
        listToSort.sort(
          (a, b) => a.title.toLowerCase().compareTo(b.title.toLowerCase()),
        );
        break;
    }
  }
}
