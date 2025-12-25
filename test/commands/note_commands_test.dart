import 'package:flutter_test/flutter_test.dart';
import 'package:note_app/commands/note_commands.dart';
import 'package:note_app/viewmodels/note_provider.dart';


/// Mock NoteProvider để test Commands
class MockNoteProvider extends NoteProvider {
  bool addNoteCalled = false;
  bool updateNoteCalled = false;
  bool deleteNoteCalled = false;
  bool searchNotesCalled = false;
  bool filterByTagCalled = false;

  String? lastTitle;
  String? lastContent;
  String? lastTag;
  int? lastId;

  bool shouldSucceed = true;

  @override
  Future<bool> addNote({
    required String title,
    required String content,
    String? tag,
  }) async {
    addNoteCalled = true;
    lastTitle = title;
    lastContent = content;
    lastTag = tag;
    return shouldSucceed;
  }

  @override
  Future<bool> updateNote({
    required int id,
    required String title,
    required String content,
    String? tag,
    required DateTime createdAt,
  }) async {
    updateNoteCalled = true;
    lastId = id;
    lastTitle = title;
    lastContent = content;
    lastTag = tag;
    return shouldSucceed;
  }

  @override
  Future<bool> deleteNote(int id) async {
    deleteNoteCalled = true;
    lastId = id;
    return shouldSucceed;
  }

  @override
  Future<void> searchNotes(String keyword) async {
    searchNotesCalled = true;
  }

  @override
  Future<void> filterByTag(String? tag) async {
    filterByTagCalled = true;
    lastTag = tag;
  }
}

void main() {
  group('AddNoteCommand Tests', () {
    late MockNoteProvider mockProvider;

    setUp(() {
      mockProvider = MockNoteProvider();
    });

    test('execute() should call provider.addNote() with correct params',
        () async {
      // Arrange
      final command = AddNoteCommand(
        provider: mockProvider,
        title: 'Test Title',
        content: 'Test Content',
        tag: 'test',
      );

      // Act
      final result = await command.execute();

      // Assert
      expect(result, true);
      expect(mockProvider.addNoteCalled, true);
      expect(mockProvider.lastTitle, 'Test Title');
      expect(mockProvider.lastContent, 'Test Content');
      expect(mockProvider.lastTag, 'test');
    });

    test('execute() should return false on failure', () async {
      // Arrange
      mockProvider.shouldSucceed = false;
      final command = AddNoteCommand(
        provider: mockProvider,
        title: 'Test',
        content: 'Test',
      );

      // Act
      final result = await command.execute();

      // Assert
      expect(result, false);
    });

    test('execute() should work without tag', () async {
      // Arrange
      final command = AddNoteCommand(
        provider: mockProvider,
        title: 'No Tag Title',
        content: 'No Tag Content',
      );

      // Act
      final result = await command.execute();

      // Assert
      expect(result, true);
      expect(mockProvider.lastTag, null);
    });
  });

  group('UpdateNoteCommand Tests', () {
    late MockNoteProvider mockProvider;

    setUp(() {
      mockProvider = MockNoteProvider();
    });

    test('execute() should call provider.updateNote() with correct params',
        () async {
      // Arrange
      final createdAt = DateTime(2025, 12, 25, 10, 0);
      final command = UpdateNoteCommand(
        provider: mockProvider,
        id: 1,
        title: 'Updated Title',
        content: 'Updated Content',
        tag: 'updated',
        createdAt: createdAt,
      );

      // Act
      final result = await command.execute();

      // Assert
      expect(result, true);
      expect(mockProvider.updateNoteCalled, true);
      expect(mockProvider.lastId, 1);
      expect(mockProvider.lastTitle, 'Updated Title');
      expect(mockProvider.lastContent, 'Updated Content');
      expect(mockProvider.lastTag, 'updated');
    });

    test('execute() should return false on failure', () async {
      // Arrange
      mockProvider.shouldSucceed = false;
      final command = UpdateNoteCommand(
        provider: mockProvider,
        id: 1,
        title: 'Test',
        content: 'Test',
        createdAt: DateTime.now(),
      );

      // Act
      final result = await command.execute();

      // Assert
      expect(result, false);
    });
  });

  group('DeleteNoteCommand Tests', () {
    late MockNoteProvider mockProvider;

    setUp(() {
      mockProvider = MockNoteProvider();
    });

    test('execute() should call provider.deleteNote() with correct id',
        () async {
      // Arrange
      final command = DeleteNoteCommand(
        provider: mockProvider,
        id: 42,
      );

      // Act
      final result = await command.execute();

      // Assert
      expect(result, true);
      expect(mockProvider.deleteNoteCalled, true);
      expect(mockProvider.lastId, 42);
    });

    test('execute() should return false on failure', () async {
      // Arrange
      mockProvider.shouldSucceed = false;
      final command = DeleteNoteCommand(
        provider: mockProvider,
        id: 1,
      );

      // Act
      final result = await command.execute();

      // Assert
      expect(result, false);
    });
  });

  group('SearchNotesCommand Tests', () {
    late MockNoteProvider mockProvider;

    setUp(() {
      mockProvider = MockNoteProvider();
    });

    test('execute() should call provider.searchNotes()', () async {
      // Arrange
      final command = SearchNotesCommand(
        provider: mockProvider,
        keyword: 'search term',
      );

      // Act
      final result = await command.execute();

      // Assert
      expect(result, true);
      expect(mockProvider.searchNotesCalled, true);
    });
  });

  group('FilterByTagCommand Tests', () {
    late MockNoteProvider mockProvider;

    setUp(() {
      mockProvider = MockNoteProvider();
    });

    test('execute() should call provider.filterByTag() with tag', () async {
      // Arrange
      final command = FilterByTagCommand(
        provider: mockProvider,
        tag: 'work',
      );

      // Act
      final result = await command.execute();

      // Assert
      expect(result, true);
      expect(mockProvider.filterByTagCalled, true);
      expect(mockProvider.lastTag, 'work');
    });

    test('execute() should work with null tag', () async {
      // Arrange
      final command = FilterByTagCommand(
        provider: mockProvider,
        tag: null,
      );

      // Act
      final result = await command.execute();

      // Assert
      expect(result, true);
      expect(mockProvider.lastTag, null);
    });
  });
}
