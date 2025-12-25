import 'package:flutter/foundation.dart';
import '../models/note_model.dart';
import '../repositories/note_repository.dart';

/// BỔ SUNG: Enum sắp xếp ghi chú cho Home
enum NoteSortOption {
  newest, // mới nhất (updatedAt DESC)
  oldest, // cũ nhất (updatedAt ASC)
  titleAZ, // tiêu đề A-Z
  titleZA, // tiêu đề Z-A
}

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

  // =======================
  // BỔ SUNG: Filter theo ngày tạo + Sort cho Home 
  // =======================
  DateTime? _createdFrom; // lọc từ ngày tạo
  DateTime? _createdTo; // lọc đến ngày tạo
  NoteSortOption _sortOption = NoteSortOption.newest;

  // BỔ SUNG: danh sách hiển thị riêng cho Home (đã áp dụng filter/sort bổ sung)
  List<NoteModel> _homeNotes = [];

  // Getters - Phơi bày dữ liệu cho View (Data Binding)
  List<NoteModel> get notes => _filteredNotes.isEmpty && _searchKeyword.isEmpty
      ? _notes
      : _filteredNotes;
  bool get isLoading => _isLoading;
  String get searchKeyword => _searchKeyword;
  String? get selectedTag => _selectedTag;
  int get notesCount => notes.length;

  // ===== BỔ SUNG: Getter cho Home =====
  List<NoteModel> get homeNotes => _homeNotes;
  DateTime? get createdFrom => _createdFrom;
  DateTime? get createdTo => _createdTo;
  NoteSortOption get sortOption => _sortOption;

  /// BỔ SUNG: Home dùng để biết đang có search/filter/sort không
  bool get homeHasActiveFilters {
    final hasKeyword = _searchKeyword.trim().isNotEmpty;
    final hasTag = _selectedTag != null && _selectedTag!.trim().isNotEmpty;
    final hasDate = _createdFrom != null || _createdTo != null;
    final hasSort = _sortOption != NoteSortOption.newest;
    return hasKeyword || hasTag || hasDate || hasSort;
  }

  /// Load tất cả ghi chú từ database
  Future<void> loadNotes() async {
    _isLoading = true;
    notifyListeners();

    try {
      _notes = await _repository.getAllNotes();
      _filteredNotes = [];
      _searchKeyword = '';
      _selectedTag = null;

      // BỔ SUNG: sau khi load dữ liệu gốc, build danh sách hiển thị Home
      _rebuildHomeNotes();
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

      // BỔ SUNG: cập nhật danh sách Home khi bỏ search
      _rebuildHomeNotes();

      notifyListeners();
      return;
    }

    try {
      _filteredNotes = await _repository.searchNotes(keyword);

      // BỔ SUNG: cập nhật danh sách Home sau khi search
      _rebuildHomeNotes();

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

      // BỔ SUNG: cập nhật danh sách Home sau khi filter tag
      _rebuildHomeNotes();

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

    // BỔ SUNG: clearFilters gốc vẫn giữ nguyên hành vi,
    // nhưng ta vẫn rebuild Home để UI Home không bị lệch
    _rebuildHomeNotes();

    notifyListeners();
  }

  // =======================
  // BỔ SUNG: API dành riêng cho Home (không phá chức năng khác)
  // =======================

  /// BỔ SUNG: Set khoảng ngày tạo (createdAt) cho Home
  void setCreatedDateRange({DateTime? from, DateTime? to}) {
    _createdFrom = from;
    _createdTo = to;
    _rebuildHomeNotes();
    notifyListeners();
  }

  /// BỔ SUNG: Clear lọc ngày tạo
  void clearCreatedDateRange() {
    _createdFrom = null;
    _createdTo = null;
    _rebuildHomeNotes();
    notifyListeners();
  }

  /// BỔ SUNG: Set sắp xếp cho Home
  void setSortOption(NoteSortOption option) {
    _sortOption = option;
    _rebuildHomeNotes();
    notifyListeners();
  }

  /// BỔ SUNG: Clear toàn bộ filter/sort của Home (bao gồm cả date/sort)
  /// Không dùng clearFilters() gốc vì clearFilters() gốc không reset date/sort.
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
  // BỔ SUNG: logic build danh sách hiển thị riêng cho Home
  // =======================

  void _rebuildHomeNotes() {
    // Base list:
    // - Nếu đang search/tag filter thì lấy _filteredNotes (kết quả từ repository)
    // - Nếu không thì lấy _notes (danh sách gốc)
    final bool usingFilteredBase =
        _searchKeyword.trim().isNotEmpty ||
            (_selectedTag != null && _selectedTag!.trim().isNotEmpty);

    Iterable<NoteModel> data = usingFilteredBase ? _filteredNotes : _notes;

    // 1) Filter theo ngày tạo (createdAt)
    if (_createdFrom != null) {
      final from = DateTime(_createdFrom!.year, _createdFrom!.month, _createdFrom!.day);
      data = data.where((n) => !n.createdAt.isBefore(from));
    }
    if (_createdTo != null) {
      final to = DateTime(_createdTo!.year, _createdTo!.month, _createdTo!.day, 23, 59, 59);
      data = data.where((n) => !n.createdAt.isAfter(to));
    }

    // 2) Sort
    final list = data.toList();
    switch (_sortOption) {
      case NoteSortOption.newest:
        list.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
        break;
      case NoteSortOption.oldest:
        list.sort((a, b) => a.updatedAt.compareTo(b.updatedAt));
        break;
      case NoteSortOption.titleAZ:
        list.sort((a, b) => a.title.toLowerCase().compareTo(b.title.toLowerCase()));
        break;
      case NoteSortOption.titleZA:
        list.sort((a, b) => b.title.toLowerCase().compareTo(a.title.toLowerCase()));
        break;
    }

    _homeNotes = list;
  }
}
