import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:note_app/views/screens/add_edit_note_screen.dart';
import 'package:note_app/viewmodels/note_provider.dart';
import 'package:note_app/models/note_model.dart';

/// Widget Tests cho AddEditNoteScreen
void main() {
  /// Helper để wrap widget với cần thiết providers
  Widget createTestWidget({NoteModel? note}) {
    return MaterialApp(
      home: ChangeNotifierProvider<NoteProvider>(
        create: (_) => NoteProvider(),
        child: AddEditNoteScreen(note: note),
      ),
    );
  }

  group('AddEditNoteScreen Widget Tests', () {
    testWidgets('Add mode: should show "Thêm Ghi Chú" title', (tester) async {
      // Build widget
      await tester.pumpWidget(createTestWidget());

      // Verify
      expect(find.text('Thêm Ghi Chú'), findsOneWidget);
    });

    testWidgets('Add mode: fields should be empty', (tester) async {
      await tester.pumpWidget(createTestWidget());

      // Find text fields by their label
      expect(find.text('Tiêu đề'), findsOneWidget);
      expect(find.text('Nội dung'), findsOneWidget);
      expect(find.text('Tag (tùy chọn)'), findsOneWidget);
    });

    testWidgets('Validation: should show error when title is empty',
        (tester) async {
      await tester.pumpWidget(createTestWidget());

      // Tap save button
      await tester.tap(find.byIcon(Icons.check));
      await tester.pumpAndSettle();

      // Verify error message
      expect(find.text('Vui lòng nhập tiêu đề'), findsOneWidget);
    });

    testWidgets('Validation: should show error when content is empty',
        (tester) async {
      await tester.pumpWidget(createTestWidget());

      // Enter title but no content
      await tester.enterText(
          find.widgetWithText(TextFormField, 'Tiêu đề'), 'Test Title');

      // Tap save button
      await tester.tap(find.byIcon(Icons.check));
      await tester.pumpAndSettle();

      // Verify error message
      expect(find.text('Vui lòng nhập nội dung'), findsOneWidget);
    });

    testWidgets('Edit mode: should show "Chỉnh Sửa Ghi Chú" title',
        (tester) async {
      final testNote = NoteModel(
        id: 1,
        title: 'Test Title',
        content: 'Test Content',
        tag: 'test',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await tester.pumpWidget(createTestWidget(note: testNote));

      // Verify
      expect(find.text('Chỉnh Sửa Ghi Chú'), findsOneWidget);
    });

    testWidgets('Edit mode: should pre-fill fields with note data',
        (tester) async {
      final testNote = NoteModel(
        id: 1,
        title: 'Existing Title',
        content: 'Existing Content',
        tag: 'existing',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await tester.pumpWidget(createTestWidget(note: testNote));

      // Verify fields are pre-filled
      expect(find.text('Existing Title'), findsOneWidget);
      expect(find.text('Existing Content'), findsOneWidget);
      expect(find.text('existing'), findsOneWidget);
    });

    testWidgets('Edit mode: should show metadata info', (tester) async {
      final testNote = NoteModel(
        id: 1,
        title: 'Test',
        content: 'Content',
        createdAt: DateTime(2025, 12, 25, 10, 30),
        updatedAt: DateTime(2025, 12, 25, 15, 45),
      );

      await tester.pumpWidget(createTestWidget(note: testNote));

      // Verify metadata section exists
      expect(find.byIcon(Icons.calendar_today), findsOneWidget);
    });

    testWidgets('Should have check icon button for save', (tester) async {
      await tester.pumpWidget(createTestWidget());

      expect(find.byIcon(Icons.check), findsOneWidget);
    });

    testWidgets('Title validation: should reject very long titles',
        (tester) async {
      await tester.pumpWidget(createTestWidget());

      // Enter very long title (> 100 characters)
      final longTitle = 'A' * 101;
      await tester.enterText(
          find.widgetWithText(TextFormField, 'Tiêu đề'), longTitle);

      // Enter valid content
      await tester.enterText(
          find.widgetWithText(TextFormField, 'Nội dung'), 'Valid content');

      // Tap save button
      await tester.tap(find.byIcon(Icons.check));
      await tester.pumpAndSettle();

      // Verify error message
      expect(find.text('Tiêu đề không được quá 100 ký tự'), findsOneWidget);
    });
  });
}
