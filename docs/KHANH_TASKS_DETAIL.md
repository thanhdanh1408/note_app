# CHI TIẾT CÔNG VIỆC - ĐẠI

## 🎯 VAI TRÒ: Module CRUD Operations (Create, Read, Update, Delete Notes)

---

## TỔNG QUAN NHIỆM VỤ

Đại chịu trách nhiệm xây dựng toàn bộ chức năng thêm, sửa, xem chi tiết và xóa ghi chú. Đây là **core feature** quan trọng nhất của ứng dụng.

**Files cần tạo**:
```
lib/views/screens/add_edit_note_screen.dart
lib/views/screens/note_detail_screen.dart
test/screens/add_edit_note_test.dart
test/commands/note_commands_test.dart
```

---

## PHẦN 1: ADD/EDIT NOTE SCREEN

### 1.1. Mô tả Chức năng

**Màn hình này có 2 chế độ**:
1. **Add Mode**: Tạo ghi chú mới
2. **Edit Mode**: Chỉnh sửa ghi chú đã có

**Phân biệt mode**:
```dart
// Constructor nhận NoteModel? (nullable)
// Nếu null → Add mode
// Nếu có note → Edit mode

class AddEditNoteScreen extends StatefulWidget {
  final NoteModel? note;  // null = add, not null = edit
  
  const AddEditNoteScreen({super.key, this.note});
}
```

---

### 1.2. UI Design

```
┌─────────────────────────────────────┐
│  < Thêm Ghi Chú  (hoặc Sửa)    [✓] │ ← AppBar
├─────────────────────────────────────┤
│                                     │
│  ┌─────────────────────────────┐   │
│  │ Tiêu đề                     │   │ ← TextField (single line)
│  └─────────────────────────────┘   │
│                                     │
│  ┌─────────────────────────────┐   │
│  │ Nội dung ghi chú...         │   │
│  │                             │   │
│  │                             │   │ ← TextField (multiline)
│  │                             │   │
│  │                             │   │
│  └─────────────────────────────┘   │
│                                     │
│  ┌─────────────────────────────┐   │
│  │ Tag (tùy chọn)              │   │ ← TextField (optional)
│  └─────────────────────────────┘   │
│                                     │
│  Ngày tạo: 24/12/2025 10:30        │ ← Info text
│  Ngày sửa: 24/12/2025 15:45        │
│                                     │
└─────────────────────────────────────┘
```

---

### 1.3. Implementation Chi tiết

#### A. State Management

```dart
class _AddEditNoteScreenState extends State<AddEditNoteScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleController;
  late TextEditingController _contentController;
  late TextEditingController _tagController;
  bool _isEditMode = false;
  
  @override
  void initState() {
    super.initState();
    _isEditMode = widget.note != null;
    
    // Pre-fill nếu edit mode
    _titleController = TextEditingController(
      text: widget.note?.title ?? '',
    );
    _contentController = TextEditingController(
      text: widget.note?.content ?? '',
    );
    _tagController = TextEditingController(
      text: widget.note?.tag ?? '',
    );
  }
  
  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    _tagController.dispose();
    super.dispose();
  }
}
```

---

#### B. Form Validation

```dart
TextFormField(
  controller: _titleController,
  decoration: const InputDecoration(
    labelText: 'Tiêu đề',
    hintText: 'Nhập tiêu đề ghi chú',
    border: OutlineInputBorder(),
  ),
  validator: (value) {
    if (value == null || value.trim().isEmpty) {
      return 'Vui lòng nhập tiêu đề';
    }
    if (value.length > 100) {
      return 'Tiêu đề không được quá 100 ký tự';
    }
    return null;
  },
),

TextFormField(
  controller: _contentController,
  decoration: const InputDecoration(
    labelText: 'Nội dung',
    hintText: 'Nhập nội dung ghi chú...',
    border: OutlineInputBorder(),
    alignLabelWithHint: true,
  ),
  maxLines: 10,
  minLines: 5,
  validator: (value) {
    if (value == null || value.trim().isEmpty) {
      return 'Vui lòng nhập nội dung';
    }
    return null;
  },
),

TextFormField(
  controller: _tagController,
  decoration: const InputDecoration(
    labelText: 'Tag (tùy chọn)',
    hintText: 'work, personal, study...',
    border: OutlineInputBorder(),
    prefixIcon: Icon(Icons.label),
  ),
  // Không cần validator vì optional
),
```

---

#### C. Save Logic - Sử dụng Command Pattern

```dart
Future<void> _handleSave() async {
  if (!_formKey.currentState!.validate()) return;

  final noteProvider = Provider.of<NoteProvider>(context, listen: false);
  bool success;

  if (_isEditMode) {
    // Update existing note
    final command = UpdateNoteCommand(
      provider: noteProvider,
      id: widget.note!.id!,
      title: _titleController.text.trim(),
      content: _contentController.text.trim(),
      tag: _tagController.text.trim().isEmpty 
          ? null 
          : _tagController.text.trim(),
      createdAt: widget.note!.createdAt,
    );
    success = await command.execute();
  } else {
    // Add new note
    final command = AddNoteCommand(
      provider: noteProvider,
      title: _titleController.text.trim(),
      content: _contentController.text.trim(),
      tag: _tagController.text.trim().isEmpty 
          ? null 
          : _tagController.text.trim(),
    );
    success = await command.execute();
  }

  if (!mounted) return;

  if (success) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(_isEditMode 
            ? AppStrings.noteUpdated 
            : AppStrings.noteAdded),
      ),
    );
    Navigator.of(context).pop();
  } else {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text(AppStrings.error)),
    );
  }
}
```

---

#### D. AppBar Actions

```dart
AppBar(
  title: Text(_isEditMode ? AppStrings.editNote : AppStrings.addNote),
  actions: [
    IconButton(
      icon: const Icon(Icons.check),
      onPressed: _handleSave,
      tooltip: 'Lưu',
    ),
  ],
)
```

---

#### E. Unsaved Changes Warning

```dart
// Cảnh báo khi back mà chưa save
@override
Widget build(BuildContext context) {
  return WillPopScope(
    onWillPop: () async {
      // Check if có thay đổi
      if (_hasChanges()) {
        return await _showDiscardDialog();
      }
      return true;
    },
    child: Scaffold(
      // ... UI
    ),
  );
}

bool _hasChanges() {
  if (!_isEditMode) {
    // Add mode: check nếu có input nào
    return _titleController.text.isNotEmpty ||
           _contentController.text.isNotEmpty ||
           _tagController.text.isNotEmpty;
  } else {
    // Edit mode: check nếu khác với original
    return _titleController.text != widget.note!.title ||
           _contentController.text != widget.note!.content ||
           _tagController.text != (widget.note!.tag ?? '');
  }
}

Future<bool> _showDiscardDialog() async {
  return await showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('Hủy thay đổi?'),
      content: const Text('Các thay đổi chưa được lưu sẽ bị mất'),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: const Text('Tiếp tục chỉnh sửa'),
        ),
        TextButton(
          onPressed: () => Navigator.of(context).pop(true),
          child: const Text('Hủy'),
        ),
      ],
    ),
  ) ?? false;
}
```

---

#### F. Show Info (Created/Updated Date)

```dart
if (_isEditMode && widget.note != null)
  Padding(
    padding: const EdgeInsets.all(16.0),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Ngày tạo: ${DateTimeHelper.formatDateTime(widget.note!.createdAt)}',
          style: AppTextStyles.caption,
        ),
        const SizedBox(height: 4),
        Text(
          'Ngày sửa: ${DateTimeHelper.formatDateTime(widget.note!.updatedAt)}',
          style: AppTextStyles.caption,
        ),
      ],
    ),
  ),
```

---

### 1.4. Complete Code Structure

```dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/note_model.dart';
import '../../viewmodels/note_provider.dart';
import '../../commands/note_commands.dart';
import '../../constants/app_constants.dart';
import '../../utils/helpers.dart';

class AddEditNoteScreen extends StatefulWidget {
  final NoteModel? note;
  
  const AddEditNoteScreen({super.key, this.note});

  @override
  State<AddEditNoteScreen> createState() => _AddEditNoteScreenState();
}

class _AddEditNoteScreenState extends State<AddEditNoteScreen> {
  // State variables
  // Controllers
  // Methods
  
  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        appBar: _buildAppBar(),
        body: _buildBody(),
      ),
    );
  }
  
  // Private methods
  Widget _buildAppBar() { }
  Widget _buildBody() { }
  Future<void> _handleSave() { }
  bool _hasChanges() { }
  Future<bool> _showDiscardDialog() { }
}
```

---

## PHẦN 2: NOTE DETAIL SCREEN

### 2.1. Mô tả Chức năng

Màn hình hiển thị chi tiết đầy đủ của một ghi chú với các actions:
- **View**: Xem toàn bộ nội dung
- **Edit**: Chuyển sang AddEditNoteScreen
- **Delete**: Xóa ghi chú (có confirm)
- **Share**: Chia sẻ nội dung (Optional)

---

### 2.2. UI Design

```
┌─────────────────────────────────────┐
│  < Chi Tiết       [✏️] [🗑️] [↗️]    │ ← AppBar với actions
├─────────────────────────────────────┤
│                                     │
│  Tiêu đề Ghi Chú                    │ ← Large title
│                                     │
│  [work]                             │ ← Tag chip (nếu có)
│                                     │
│  ─────────────────────────────────  │
│                                     │
│  Đây là nội dung của ghi chú.       │
│  Có thể rất dài và có nhiều dòng.   │
│                                     │ ← Scrollable content
│  - Item 1                           │
│  - Item 2                           │
│  - Item 3                           │
│                                     │
│  ─────────────────────────────────  │
│                                     │
│  📅 Ngày tạo: 24/12/2025 10:30     │
│  ✏️ Sửa lần cuối: 24/12/2025 15:45 │
│                                     │
└─────────────────────────────────────┘
```

---

### 2.3. Implementation Chi tiết

#### A. Constructor

```dart
class NoteDetailScreen extends StatelessWidget {
  final NoteModel note;
  
  const NoteDetailScreen({
    super.key,
    required this.note,
  });
}
```

---

#### B. AppBar với Actions

```dart
AppBar(
  title: const Text('Chi tiết'),
  actions: [
    // Edit button
    IconButton(
      icon: const Icon(Icons.edit),
      tooltip: 'Chỉnh sửa',
      onPressed: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => AddEditNoteScreen(note: note),
          ),
        );
      },
    ),
    
    // Delete button
    IconButton(
      icon: const Icon(Icons.delete),
      tooltip: 'Xóa',
      onPressed: () => _showDeleteConfirmation(context),
    ),
    
    // Share button (Optional)
    IconButton(
      icon: const Icon(Icons.share),
      tooltip: 'Chia sẻ',
      onPressed: () => _handleShare(context),
    ),
  ],
)
```

---

#### C. Body Layout

```dart
@override
Widget build(BuildContext context) {
  return Scaffold(
    appBar: _buildAppBar(context),
    body: SingleChildScrollView(
      padding: const EdgeInsets.all(AppDimensions.paddingLarge),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title
          Text(
            note.title,
            style: AppTextStyles.titleLarge,
          ),
          const SizedBox(height: 8),
          
          // Tag (nếu có)
          if (note.tag != null && note.tag!.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: Chip(
                label: Text(note.tag!),
                avatar: const Icon(Icons.label, size: 16),
              ),
            ),
          
          // Divider
          const Divider(),
          const SizedBox(height: 16),
          
          // Content
          Text(
            note.content,
            style: AppTextStyles.bodyLarge,
          ),
          
          const SizedBox(height: 24),
          const Divider(),
          const SizedBox(height: 16),
          
          // Metadata
          _buildMetadata(),
        ],
      ),
    ),
  );
}

Widget _buildMetadata() {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Row(
        children: [
          const Icon(Icons.calendar_today, size: 16, color: Colors.grey),
          const SizedBox(width: 8),
          Text(
            'Ngày tạo: ${DateTimeHelper.formatDateTime(note.createdAt)}',
            style: AppTextStyles.caption,
          ),
        ],
      ),
      const SizedBox(height: 8),
      Row(
        children: [
          const Icon(Icons.edit, size: 16, color: Colors.grey),
          const SizedBox(width: 8),
          Text(
            'Sửa lần cuối: ${DateTimeHelper.formatDateTime(note.updatedAt)}',
            style: AppTextStyles.caption,
          ),
        ],
      ),
    ],
  );
}
```

---

#### D. Delete Confirmation Dialog

```dart
void _showDeleteConfirmation(BuildContext context) {
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text(AppStrings.deleteTitle),
      content: const Text(AppStrings.deleteMessage),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text(AppStrings.cancel),
        ),
        TextButton(
          onPressed: () async {
            Navigator.of(context).pop(); // Close dialog
            await _handleDelete(context);
          },
          style: TextButton.styleFrom(
            foregroundColor: AppColors.error,
          ),
          child: const Text(AppStrings.delete),
        ),
      ],
    ),
  );
}

Future<void> _handleDelete(BuildContext context) async {
  final noteProvider = Provider.of<NoteProvider>(context, listen: false);
  
  final command = DeleteNoteCommand(
    provider: noteProvider,
    id: note.id!,
  );
  
  final success = await command.execute();
  
  if (!context.mounted) return;
  
  if (success) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text(AppStrings.noteDeleted)),
    );
    Navigator.of(context).pop(); // Back to home
  } else {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text(AppStrings.error)),
    );
  }
}
```

---

#### E. Share Functionality (Optional)

```dart
void _handleShare(BuildContext context) {
  final shareText = '''
${note.title}

${note.content}

${note.tag != null ? 'Tag: ${note.tag}' : ''}
''';

  // Sử dụng package share_plus
  // Share.share(shareText);
  
  // Hoặc đơn giản copy to clipboard
  Clipboard.setData(ClipboardData(text: shareText));
  ScaffoldMessenger.of(context).showSnackBar(
    const SnackBar(content: Text('Đã sao chép nội dung')),
  );
}
```

---

### 2.4. Navigation từ Home Screen

**Cập nhật trong home_screen.dart** (Bảo sẽ làm, nhưng Đại cần coordinate):

```dart
ListTile(
  title: Text(note.title),
  subtitle: Text(note.content),
  onTap: () {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => NoteDetailScreen(note: note),
      ),
    );
  },
)
```

---

## PHẦN 3: TESTING

### 3.1. Unit Tests cho Commands

**File**: `test/commands/note_commands_test.dart`

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:note_app/commands/note_commands.dart';
import 'package:note_app/viewmodels/note_provider.dart';

class MockNoteProvider extends Mock implements NoteProvider {}

void main() {
  group('AddNoteCommand Tests', () {
    late MockNoteProvider mockProvider;
    
    setUp(() {
      mockProvider = MockNoteProvider();
    });
    
    test('execute() should call provider.addNote() with correct params', () async {
      // Arrange
      final command = AddNoteCommand(
        provider: mockProvider,
        title: 'Test Title',
        content: 'Test Content',
        tag: 'test',
      );
      
      when(mockProvider.addNote(
        title: anyNamed('title'),
        content: anyNamed('content'),
        tag: anyNamed('tag'),
      )).thenAnswer((_) async => true);
      
      // Act
      final result = await command.execute();
      
      // Assert
      expect(result, true);
      verify(mockProvider.addNote(
        title: 'Test Title',
        content: 'Test Content',
        tag: 'test',
      )).called(1);
    });
    
    test('execute() should return false on failure', () async {
      // Arrange
      final command = AddNoteCommand(
        provider: mockProvider,
        title: 'Test',
        content: 'Test',
      );
      
      when(mockProvider.addNote(
        title: anyNamed('title'),
        content: anyNamed('content'),
        tag: anyNamed('tag'),
      )).thenAnswer((_) async => false);
      
      // Act
      final result = await command.execute();
      
      // Assert
      expect(result, false);
    });
  });
  
  group('UpdateNoteCommand Tests', () {
    // Similar tests for update
  });
  
  group('DeleteNoteCommand Tests', () {
    // Similar tests for delete
  });
}
```

---

### 3.2. Widget Tests cho Screens

**File**: `test/screens/add_edit_note_test.dart`

```dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:note_app/views/screens/add_edit_note_screen.dart';
import 'package:provider/provider.dart';

void main() {
  group('AddEditNoteScreen Widget Tests', () {
    testWidgets('Add mode: should show "Thêm Ghi Chú" title', (tester) async {
      // Build widget
      await tester.pumpWidget(
        MaterialApp(
          home: AddEditNoteScreen(),
        ),
      );
      
      // Verify
      expect(find.text('Thêm Ghi Chú'), findsOneWidget);
    });
    
    testWidgets('Add mode: fields should be empty', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: AddEditNoteScreen(),
        ),
      );
      
      // Find text fields
      final titleField = find.byType(TextFormField).at(0);
      final contentField = find.byType(TextFormField).at(1);
      
      // Verify empty
      expect(
        (tester.widget(titleField) as TextFormField).controller!.text,
        isEmpty,
      );
      expect(
        (tester.widget(contentField) as TextFormField).controller!.text,
        isEmpty,
      );
    });
    
    testWidgets('Validation: should show error when title is empty', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: AddEditNoteScreen(),
        ),
      );
      
      // Tap save button
      await tester.tap(find.byIcon(Icons.check));
      await tester.pumpAndSettle();
      
      // Verify error message
      expect(find.text('Vui lòng nhập tiêu đề'), findsOneWidget);
    });
    
    // More tests...
  });
}
```

---

## PHẦN 4: INTEGRATION VỚI CÁC MODULE KHÁC

### 4.1. Với Module của Bảo (Search & Filter)

**Coordinate cần thiết**:
- Bảo sẽ implement home screen với note list
- Đại cần ensure navigation hoạt động:
  - Tap on note card → Navigate to NoteDetailScreen
  - FAB button → Navigate to AddEditNoteScreen

**Communication**:
```dart
// home_screen.dart (Bảo làm)
onTap: () {
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => NoteDetailScreen(note: note),
    ),
  );
}

// FAB
onPressed: () {
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => AddEditNoteScreen(),
    ),
  );
}
```

---

### 4.2. Với Module của Khánh (UI Components)

**Widgets Khánh sẽ tạo mà Đại cần dùng**:

1. **confirmation_dialog.dart**:
```dart
// Đại có thể dùng thay vì AlertDialog thường
await showConfirmationDialog(
  context: context,
  title: AppStrings.deleteTitle,
  message: AppStrings.deleteMessage,
  confirmText: AppStrings.delete,
  cancelText: AppStrings.cancel,
  isDestructive: true,
);
```

2. **loading_widget.dart**:
```dart
// Hiển thị loading khi save
if (isLoading)
  LoadingWidget()
```

---

### 4.3. Với Module của Ngọc (Testing)

**Ngọc sẽ viết tests, Đại cần**:
1. Ensure code dễ test (separation of concerns)
2. Provide test data
3. Fix bugs từ test results

---

## PHẦN 5: BEST PRACTICES & TIPS

### 5.1. Code Organization

```
add_edit_note_screen.dart
├── Imports
├── Class definition
├── State variables
├── Lifecycle methods (initState, dispose)
├── Build method
├── Widget builders (_buildAppBar, _buildBody...)
├── Action handlers (_handleSave, _handleDelete...)
└── Helper methods (_hasChanges, _showDialog...)
```

---

### 5.2. Error Handling

```dart
try {
  final success = await command.execute();
  if (success) {
    // Handle success
  } else {
    // Handle failure
  }
} catch (e) {
  // Handle exception
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text('Lỗi: ${e.toString()}')),
  );
}
```

---

### 5.3. User Feedback

**Luôn cung cấp feedback cho user**:
- ✅ SnackBar khi save thành công
- ❌ SnackBar khi có lỗi
- ⏳ Loading indicator khi đang xử lý
- ⚠️ Confirmation dialog cho destructive actions

---

## PHẦN 6: TIMELINE & MILESTONES

### Week 1:
- [x] Read requirements
- [ ] Setup development environment
- [ ] Create add_edit_note_screen.dart basic UI
- [ ] Implement form validation

### Week 2:
- [ ] Implement save logic với Commands
- [ ] Handle add/edit modes
- [ ] Create note_detail_screen.dart
- [ ] Implement delete functionality
- [ ] Test manually

### Week 3:
- [ ] Write unit tests
- [ ] Write widget tests
- [ ] Fix bugs
- [ ] Code review với Danh
- [ ] Integration testing

---

## SUMMARY - TÓM TẮT

**Đại làm gì**:
1. ✅ Màn hình thêm/sửa ghi chú với validation
2. ✅ Màn hình chi tiết ghi chú
3. ✅ Delete confirmation
4. ✅ Sử dụng Command Pattern
5. ✅ Testing (unit + widget)

**Output cuối cùng**:
- 2 screens hoàn chỉnh
- Integration với NoteProvider
- Test coverage > 80%
- Bug-free, smooth UX

**Thời gian ước tính**: 2 tuần
