/// Model - Định nghĩa cấu trúc dữ liệu Note
/// Đây là thành phần Model trong MVVM, chứa dữ liệu và logic nghiệp vụ
class NoteModel {
  final int? id;
  final String title;
  final String content;
  final String? tag;
  final DateTime createdAt;
  final DateTime updatedAt;

  NoteModel({
    this.id,
    required this.title,
    required this.content,
    this.tag,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Convert Note object to Map for SQLite
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'content': content,
      'tag': tag,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  /// Create Note object from Map
  factory NoteModel.fromMap(Map<String, dynamic> map) {
    return NoteModel(
      id: map['id'] as int?,
      title: map['title'] as String,
      content: map['content'] as String,
      tag: map['tag'] as String?,
      createdAt: DateTime.parse(map['createdAt'] as String),
      updatedAt: DateTime.parse(map['updatedAt'] as String),
    );
  }

  /// Create a copy of Note with updated fields
  NoteModel copyWith({
    int? id,
    String? title,
    String? content,
    String? tag,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return NoteModel(
      id: id ?? this.id,
      title: title ?? this.title,
      content: content ?? this.content,
      tag: tag ?? this.tag,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
