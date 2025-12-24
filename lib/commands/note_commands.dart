import '../models/note_model.dart';
import '../viewmodels/note_provider.dart';

/// Command Pattern - Đóng gói các hành động của người dùng
/// Tương đương với Command trong MVVM chuẩn (WPF/UWP)
/// Giúp tách biệt logic xử lý sự kiện khỏi View

/// Base Command interface
abstract class Command {
  Future<bool> execute();
}

/// Command thêm ghi chú mới
class AddNoteCommand implements Command {
  final NoteProvider provider;
  final String title;
  final String content;
  final String? tag;

  AddNoteCommand({
    required this.provider,
    required this.title,
    required this.content,
    this.tag,
  });

  @override
  Future<bool> execute() async {
    return await provider.addNote(
      title: title,
      content: content,
      tag: tag,
    );
  }
}

/// Command cập nhật ghi chú
class UpdateNoteCommand implements Command {
  final NoteProvider provider;
  final int id;
  final String title;
  final String content;
  final String? tag;
  final DateTime createdAt;

  UpdateNoteCommand({
    required this.provider,
    required this.id,
    required this.title,
    required this.content,
    this.tag,
    required this.createdAt,
  });

  @override
  Future<bool> execute() async {
    return await provider.updateNote(
      id: id,
      title: title,
      content: content,
      tag: tag,
      createdAt: createdAt,
    );
  }
}

/// Command xóa ghi chú
class DeleteNoteCommand implements Command {
  final NoteProvider provider;
  final int id;

  DeleteNoteCommand({
    required this.provider,
    required this.id,
  });

  @override
  Future<bool> execute() async {
    return await provider.deleteNote(id);
  }
}

/// Command tìm kiếm ghi chú
class SearchNotesCommand implements Command {
  final NoteProvider provider;
  final String keyword;

  SearchNotesCommand({
    required this.provider,
    required this.keyword,
  });

  @override
  Future<bool> execute() async {
    await provider.searchNotes(keyword);
    return true;
  }
}

/// Command lọc theo tag
class FilterByTagCommand implements Command {
  final NoteProvider provider;
  final String? tag;

  FilterByTagCommand({
    required this.provider,
    this.tag,
  });

  @override
  Future<bool> execute() async {
    await provider.filterByTag(tag);
    return true;
  }
}
