import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/note_model.dart';

/// Web-compatible Database Service using localStorage (via shared_preferences)
/// Data persists even after browser refresh
class DatabaseService {
  static final DatabaseService _instance = DatabaseService._internal();
  static const String _notesKey = 'notes_data';
  static const String _nextIdKey = 'notes_next_id';

  factory DatabaseService() {
    return _instance;
  }

  DatabaseService._internal();

  /// Get SharedPreferences instance
  Future<SharedPreferences> get _prefs async =>
      await SharedPreferences.getInstance();

  /// Load notes from localStorage
  Future<List<NoteModel>> _loadNotes() async {
    final prefs = await _prefs;
    final String? jsonString = prefs.getString(_notesKey);
    if (jsonString == null || jsonString.isEmpty) {
      return [];
    }
    try {
      final List<dynamic> jsonList = json.decode(jsonString);
      return jsonList.map((map) => NoteModel.fromMap(map)).toList();
    } catch (e) {
      return [];
    }
  }

  /// Save notes to localStorage
  Future<void> _saveNotes(List<NoteModel> notes) async {
    final prefs = await _prefs;
    final jsonList = notes.map((note) => note.toMap()).toList();
    await prefs.setString(_notesKey, json.encode(jsonList));
  }

  /// Get next ID
  Future<int> _getNextId() async {
    final prefs = await _prefs;
    return prefs.getInt(_nextIdKey) ?? 1;
  }

  /// Increment and save next ID
  Future<void> _setNextId(int id) async {
    final prefs = await _prefs;
    await prefs.setInt(_nextIdKey, id);
  }

  /// CREATE - Thêm ghi chú mới
  Future<int> insertNote(NoteModel note) async {
    final notes = await _loadNotes();
    final nextId = await _getNextId();
    
    final newNote = NoteModel(
      id: nextId,
      title: note.title,
      content: note.content,
      tag: note.tag,
      createdAt: note.createdAt,
      updatedAt: note.updatedAt,
    );
    
    notes.add(newNote);
    await _saveNotes(notes);
    await _setNextId(nextId + 1);
    
    return nextId;
  }

  /// READ - Lấy tất cả ghi chú
  Future<List<NoteModel>> getAllNotes() async {
    final notes = await _loadNotes();
    // Sort by updatedAt DESC
    notes.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
    return notes;
  }

  /// READ - Lấy ghi chú theo ID
  Future<NoteModel?> getNoteById(int id) async {
    final notes = await _loadNotes();
    try {
      return notes.firstWhere((note) => note.id == id);
    } catch (e) {
      return null;
    }
  }

  /// UPDATE - Cập nhật ghi chú
  Future<int> updateNote(NoteModel note) async {
    final notes = await _loadNotes();
    final index = notes.indexWhere((n) => n.id == note.id);
    if (index != -1) {
      notes[index] = note;
      await _saveNotes(notes);
      return 1;
    }
    return 0;
  }

  /// DELETE - Xóa ghi chú
  Future<int> deleteNote(int id) async {
    final notes = await _loadNotes();
    final lengthBefore = notes.length;
    notes.removeWhere((note) => note.id == id);
    await _saveNotes(notes);
    return lengthBefore - notes.length;
  }

  /// SEARCH - Tìm kiếm ghi chú theo từ khóa
  Future<List<NoteModel>> searchNotes(String keyword) async {
    final notes = await _loadNotes();
    final lowercaseKeyword = keyword.toLowerCase();
    final results = notes
        .where((note) =>
            note.title.toLowerCase().contains(lowercaseKeyword) ||
            note.content.toLowerCase().contains(lowercaseKeyword))
        .toList();
    results.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
    return results;
  }

  /// FILTER - Lọc ghi chú theo tag
  Future<List<NoteModel>> getNotesByTag(String tag) async {
    final notes = await _loadNotes();
    final results = notes.where((note) => note.tag == tag).toList();
    results.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
    return results;
  }

  /// Close database (no-op for localStorage)
  Future<void> closeDatabase() async {
    // No-op
  }
  
  /// Clear all notes (for testing/debugging)
  Future<void> clearAllNotes() async {
    final prefs = await _prefs;
    await prefs.remove(_notesKey);
    await prefs.remove(_nextIdKey);
  }
}
