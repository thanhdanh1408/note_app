import 'package:flutter/foundation.dart';
import '../models/note_model.dart';
import '../repositories/note_repository.dart';

/// Tùy chọn sắp xếp ghi chú trên Home
enum NoteSortOption {
  newest,  // theo updatedAt giảm dần
  oldest,  // theo updatedAt tăng dần
  titleAZ, // theo title A-Z
  titleZA, // theo title Z-A
}

class NoteProvider extends ChangeNotifier {
  final NoteRepository _repository = NoteRepository();

  // Danh sách ghi chú gốc lấy từ database
  List<NoteModel> _notes = [];

  // Danh sách ghi chú sau khi search/filter tag (dùng lại logic cũ)
  List<NoteModel> _filteredNotes = [];

  bool _isLoading = false;

  // Từ khóa search và tag/category hiện tại
  String _searchKeyword = '';
  String? _selectedTag;

  // Bộ lọc theo ngày tạo (createdAt) và sort
  DateTime? _createdFrom;
  DateTime? _createdTo;
  NoteSortOption _sortOption = NoteSortOption.newest;

  // Danh sách dùng để hiển thị trên Home: search/tag + lọc ngày + sort
  List<NoteModel> _homeNotes = [];

  // =======================
  // Getter dùng chung
  // =======================
  List<NoteModel> get notes =>
      _filteredNotes.isEmpty && _searchKeyword.isEmpty ? _notes : _filteredNotes;

  bool get isLoading => _isLoading;
  String get searchKeyword => _searchKeyword;
  String? get selectedTag => _selectedTag;
  int get notesCount => notes.length;

  // =======================
  // Getter dùng cho Home
  // =======================
  List<NoteModel> get homeNotes => _homeNotes;
  DateTime? get createdFrom => _createdFrom;
  DateTime? get createdTo => _createdTo;
  NoteSortOption get sortOption => _sortOption;

  /// Dùng để xác định Home đang có điều kiện lọc/search/sort hay không
  bool get homeHasActiveFilters {
    final hasKeyword = _searchKeyword.trim().isNotEmpty;
    final hasTag = _selectedTag != null && _selectedTag!.trim().isNotEmpty;
    final hasDate = _createdFrom != null || _createdTo != null;
    final hasSort = _sortOption != NoteSortOption.newest;
    return hasKeyword || hasTag || hasDate || hasSort;
  }

  // =======================
  // CRUD
  // =======================
  Future<void> loadNotes() async {
    _isLoading = true;
    notifyListeners();

    try {
      _notes = await _repository.getAllNotes();
      _filteredNotes = [];
      _searchKeyword = '';
      _selectedTag = null;

      _rebuildHomeNotes();
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

  // =======================
  // Search / Filter tag (giữ tên hàm để dùng với Command hiện có)
  // =======================
  Future<void> searchNotes(String keyword) async {
    _searchKeyword = keyword;

    if (keyword.isEmpty) {
      _filteredNotes = [];
      _rebuildHomeNotes();
      notifyListeners();
      return;
    }

    try {
      _filteredNotes = await _repository.searchNotes(keyword);
      _rebuildHomeNotes();
      notifyListeners();
    } catch (e) {
      debugPrint('Error searching notes: $e');
    }
  }

  Future<void> filterByTag(String? tag) async {
    _selectedTag = tag;

    if (tag == null || tag.isEmpty) {
      await loadNotes();
      return;
    }

    try {
      _filteredNotes = await _repository.getNotesByTag(tag);
      _rebuildHomeNotes();
      notifyListeners();
    } catch (e) {
      debugPrint('Error filtering notes by tag: $e');
    }
  }

  void clearFilters() {
    _searchKeyword = '';
    _selectedTag = null;
    _filteredNotes = [];

    _rebuildHomeNotes();
    notifyListeners();
  }

  // =======================
  // Filter theo ngày tạo + sort (dùng trên Home)
  // =======================
  void setCreatedDateRange({DateTime? from, DateTime? to}) {
    _createdFrom = from;
    _createdTo = to;
    _rebuildHomeNotes();
    notifyListeners();
  }

  void clearCreatedDateRange() {
    _createdFrom = null;
    _createdTo = null;
    _rebuildHomeNotes();
    notifyListeners();
  }

  void setSortOption(NoteSortOption option) {
    _sortOption = option;
    _rebuildHomeNotes();
    notifyListeners();
  }

  /// Xóa toàn bộ điều kiện trên Home (search, tag, ngày tạo, sort)
  void clearHomeFilters() {
    _searchKeyword = '';
    _selectedTag = null;
    _filteredNotes = [];
    _createdFrom = null;
    _createdTo = null;
    _sortOption = NoteSortOption.newest;

    _rebuildHomeNotes();
    notifyListeners();
  }

  // =======================
  // Tạo danh sách hiển thị trên Home
  // =======================
  void _rebuildHomeNotes() {
    // Nếu đang search/tag thì dùng danh sách đã lọc, ngược lại dùng danh sách gốc
    final usingFilteredBase =
        _searchKeyword.trim().isNotEmpty ||
        (_selectedTag != null && _selectedTag!.trim().isNotEmpty);

    Iterable<NoteModel> data = usingFilteredBase ? _filteredNotes : _notes;

    // Lọc theo ngày tạo (createdAt)
    if (_createdFrom != null) {
      final from = DateTime(
        _createdFrom!.year,
        _createdFrom!.month,
        _createdFrom!.day,
      );
      data = data.where((n) => !n.createdAt.isBefore(from));
    }

    if (_createdTo != null) {
      final to = DateTime(
        _createdTo!.year,
        _createdTo!.month,
        _createdTo!.day,
        23,
        59,
        59,
      );
      data = data.where((n) => !n.createdAt.isAfter(to));
    }

    // Sắp xếp
    final list = data.toList();
    switch (_sortOption) {
      case NoteSortOption.newest:
        list.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
        break;
      case NoteSortOption.oldest:
        list.sort((a, b) => a.updatedAt.compareTo(b.updatedAt));
        break;
      case NoteSortOption.titleAZ:
        list.sort((a, b) =>
            a.title.toLowerCase().compareTo(b.title.toLowerCase()));
        break;
      case NoteSortOption.titleZA:
        list.sort((a, b) =>
            b.title.toLowerCase().compareTo(a.title.toLowerCase()));
        break;
    }

    _homeNotes = list;
  }
}
