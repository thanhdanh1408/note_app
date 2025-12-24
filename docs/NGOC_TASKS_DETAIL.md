# CHI TIẾT CÔNG VIỆC - NGỌC

## 🎯 VAI TRÒ: Testing & Documentation

---

## TỔNG QUAN NHIỆM VỤ

Ngọc chịu trách nhiệm đảm bảo **chất lượng code** thông qua testing và tạo **documentation đầy đủ** để team và người dùng hiểu rõ về project.

**Files cần tạo**:
```
# Testing
test/models/note_model_test.dart
test/models/user_model_test.dart
test/services/database_service_test.dart
test/services/auth_service_test.dart
test/repositories/note_repository_test.dart
test/repositories/auth_repository_test.dart
test/viewmodels/note_provider_test.dart
test/viewmodels/auth_provider_test.dart
test/commands/note_commands_test.dart
test/widgets/note_card_widget_test.dart
test_driver/integration_test.dart

# Documentation
README.md
DEVELOPER_GUIDE.md
USER_GUIDE.md
API_DOCUMENTATION.md
ARCHITECTURE.md
```

---

## PHẦN 1: UNIT TESTING

### 1.1. Setup Testing Environment

#### A. Update pubspec.yaml

```yaml
dev_dependencies:
  flutter_test:
    sdk: flutter
  mockito: ^5.4.4
  build_runner: ^2.4.7
  integration_test:
    sdk: flutter
```

#### B. Create Mock Classes

**File**: `test/mocks/mocks.dart`

```dart
import 'package:mockito/annotations.dart';
import 'package:note_app/repositories/note_repository.dart';
import 'package:note_app/repositories/auth_repository.dart';
import 'package:note_app/services/database_service.dart';
import 'package:note_app/services/auth_service.dart';

@GenerateMocks([
  NoteRepository,
  AuthRepository,
  DatabaseService,
  AuthService,
])
void main() {}
```

**Generate mocks**:
```bash
flutter pub run build_runner build
```

---

### 1.2. Model Tests

#### A. Note Model Test

**File**: `test/models/note_model_test.dart`

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:note_app/models/note_model.dart';

void main() {
  group('NoteModel Tests', () {
    final testDate = DateTime(2025, 12, 24, 10, 30);
    
    test('should create NoteModel with correct properties', () {
      // Arrange & Act
      final note = NoteModel(
        id: 1,
        title: 'Test Title',
        content: 'Test Content',
        tag: 'test',
        createdAt: testDate,
        updatedAt: testDate,
      );

      // Assert
      expect(note.id, 1);
      expect(note.title, 'Test Title');
      expect(note.content, 'Test Content');
      expect(note.tag, 'test');
      expect(note.createdAt, testDate);
      expect(note.updatedAt, testDate);
    });

    test('should convert NoteModel to Map correctly', () {
      // Arrange
      final note = NoteModel(
        id: 1,
        title: 'Test Title',
        content: 'Test Content',
        tag: 'test',
        createdAt: testDate,
        updatedAt: testDate,
      );

      // Act
      final map = note.toMap();

      // Assert
      expect(map['id'], 1);
      expect(map['title'], 'Test Title');
      expect(map['content'], 'Test Content');
      expect(map['tag'], 'test');
      expect(map['createdAt'], testDate.toIso8601String());
      expect(map['updatedAt'], testDate.toIso8601String());
    });

    test('should create NoteModel from Map correctly', () {
      // Arrange
      final map = {
        'id': 1,
        'title': 'Test Title',
        'content': 'Test Content',
        'tag': 'test',
        'createdAt': testDate.toIso8601String(),
        'updatedAt': testDate.toIso8601String(),
      };

      // Act
      final note = NoteModel.fromMap(map);

      // Assert
      expect(note.id, 1);
      expect(note.title, 'Test Title');
      expect(note.content, 'Test Content');
      expect(note.tag, 'test');
      expect(note.createdAt, testDate);
      expect(note.updatedAt, testDate);
    });

    test('should create copy with updated fields', () {
      // Arrange
      final original = NoteModel(
        id: 1,
        title: 'Original Title',
        content: 'Original Content',
        tag: 'original',
        createdAt: testDate,
        updatedAt: testDate,
      );

      // Act
      final copy = original.copyWith(
        title: 'Updated Title',
        tag: 'updated',
      );

      // Assert
      expect(copy.id, 1);
      expect(copy.title, 'Updated Title');
      expect(copy.content, 'Original Content');
      expect(copy.tag, 'updated');
      expect(copy.createdAt, testDate);
    });

    test('should handle null tag', () {
      // Arrange & Act
      final note = NoteModel(
        id: 1,
        title: 'Test Title',
        content: 'Test Content',
        tag: null,
        createdAt: testDate,
        updatedAt: testDate,
      );

      // Assert
      expect(note.tag, null);
      expect(note.toMap()['tag'], null);
    });
  });
}
```

#### B. User Model Test

**File**: `test/models/user_model_test.dart`

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:note_app/models/user_model.dart';

void main() {
  group('UserModel Tests', () {
    final testDate = DateTime(2025, 12, 24);

    test('should create UserModel with correct properties', () {
      // Arrange & Act
      final user = UserModel(
        id: 1,
        username: 'testuser',
        email: 'test@email.com',
        password: 'hashedpassword',
        createdAt: testDate,
      );

      // Assert
      expect(user.id, 1);
      expect(user.username, 'testuser');
      expect(user.email, 'test@email.com');
      expect(user.password, 'hashedpassword');
      expect(user.createdAt, testDate);
    });

    test('should convert to Map correctly', () {
      // Arrange
      final user = UserModel(
        id: 1,
        username: 'testuser',
        email: 'test@email.com',
        password: 'hashedpassword',
        createdAt: testDate,
      );

      // Act
      final map = user.toMap();

      // Assert
      expect(map['id'], 1);
      expect(map['username'], 'testuser');
      expect(map['email'], 'test@email.com');
      expect(map['password'], 'hashedpassword');
    });

    test('should create from Map correctly', () {
      // Arrange
      final map = {
        'id': 1,
        'username': 'testuser',
        'email': 'test@email.com',
        'password': 'hashedpassword',
        'createdAt': testDate.toIso8601String(),
      };

      // Act
      final user = UserModel.fromMap(map);

      // Assert
      expect(user.id, 1);
      expect(user.username, 'testuser');
      expect(user.email, 'test@email.com');
    });
  });
}
```

---

### 1.3. Service Tests

#### A. Database Service Test (Simplified)

**File**: `test/services/database_service_test.dart`

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:note_app/services/database_service.dart';
import 'package:note_app/models/note_model.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  sqfliteFfiInit();
  
  group('DatabaseService Tests', () {
    late DatabaseService service;

    setUp(() async {
      // Setup test database
      databaseFactory = databaseFactoryFfi;
      service = DatabaseService();
    });

    test('should insert note and return id', () async {
      // Arrange
      final note = NoteModel(
        title: 'Test Note',
        content: 'Test Content',
        tag: 'test',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      // Act
      final id = await service.insertNote(note);

      // Assert
      expect(id, greaterThan(0));
    });

    test('should retrieve note by id', () async {
      // Arrange
      final note = NoteModel(
        title: 'Test Note',
        content: 'Test Content',
        tag: 'test',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      final id = await service.insertNote(note);

      // Act
      final retrieved = await service.getNoteById(id);

      // Assert
      expect(retrieved, isNotNull);
      expect(retrieved!.title, 'Test Note');
    });

    test('should update note', () async {
      // Arrange
      final note = NoteModel(
        title: 'Original Title',
        content: 'Original Content',
        tag: 'test',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      final id = await service.insertNote(note);
      
      final updated = note.copyWith(
        id: id,
        title: 'Updated Title',
      );

      // Act
      final result = await service.updateNote(updated);

      // Assert
      expect(result, 1); // 1 row affected
      final retrieved = await service.getNoteById(id);
      expect(retrieved!.title, 'Updated Title');
    });

    test('should delete note', () async {
      // Arrange
      final note = NoteModel(
        title: 'Test Note',
        content: 'Test Content',
        tag: 'test',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      final id = await service.insertNote(note);

      // Act
      final result = await service.deleteNote(id);

      // Assert
      expect(result, 1);
      final retrieved = await service.getNoteById(id);
      expect(retrieved, isNull);
    });

    test('should search notes by keyword', () async {
      // Arrange
      await service.insertNote(NoteModel(
        title: 'Flutter Tutorial',
        content: 'Learn Flutter',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ));
      await service.insertNote(NoteModel(
        title: 'Dart Basics',
        content: 'Learn Dart',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ));

      // Act
      final results = await service.searchNotes('Flutter');

      // Assert
      expect(results.length, 1);
      expect(results.first.title, 'Flutter Tutorial');
    });
  });
}
```

---

### 1.4. ViewModel/Provider Tests

**File**: `test/viewmodels/note_provider_test.dart`

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:note_app/viewmodels/note_provider.dart';
import 'package:note_app/models/note_model.dart';
import '../mocks/mocks.mocks.dart';

void main() {
  group('NoteProvider Tests', () {
    late NoteProvider provider;
    late MockNoteRepository mockRepository;

    setUp(() {
      mockRepository = MockNoteRepository();
      provider = NoteProvider();
      // Inject mock repository (cần refactor NoteProvider để support DI)
    });

    test('initial state should be correct', () {
      // Assert
      expect(provider.notes, isEmpty);
      expect(provider.isLoading, false);
      expect(provider.searchKeyword, isEmpty);
    });

    test('loadNotes should fetch notes from repository', () async {
      // Arrange
      final testNotes = [
        NoteModel(
          id: 1,
          title: 'Note 1',
          content: 'Content 1',
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
        NoteModel(
          id: 2,
          title: 'Note 2',
          content: 'Content 2',
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
      ];

      when(mockRepository.getAllNotes())
          .thenAnswer((_) async => testNotes);

      // Act
      await provider.loadNotes();

      // Assert
      expect(provider.notes.length, 2);
      expect(provider.isLoading, false);
      verify(mockRepository.getAllNotes()).called(1);
    });

    test('addNote should call repository and reload notes', () async {
      // Arrange
      when(mockRepository.addNote(any))
          .thenAnswer((_) async => 1);
      when(mockRepository.getAllNotes())
          .thenAnswer((_) async => []);

      // Act
      final result = await provider.addNote(
        title: 'New Note',
        content: 'New Content',
      );

      // Assert
      expect(result, true);
      verify(mockRepository.addNote(any)).called(1);
      verify(mockRepository.getAllNotes()).called(1);
    });

    test('searchNotes should filter notes by keyword', () async {
      // Arrange
      final testNotes = [
        NoteModel(
          id: 1,
          title: 'Flutter Tutorial',
          content: 'Learn Flutter',
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
      ];

      when(mockRepository.searchNotes('Flutter'))
          .thenAnswer((_) async => testNotes);

      // Act
      await provider.searchNotes('Flutter');

      // Assert
      verify(mockRepository.searchNotes('Flutter')).called(1);
    });
  });
}
```

---

## PHẦN 2: WIDGET TESTING

### 2.1. Widget Test Template

**File**: `test/widgets/note_card_widget_test.dart`

```dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:note_app/views/widgets/note_card_widget.dart';
import 'package:note_app/models/note_model.dart';

void main() {
  group('NoteCardWidget Tests', () {
    final testNote = NoteModel(
      id: 1,
      title: 'Test Note',
      content: 'Test Content',
      tag: 'test',
      createdAt: DateTime(2025, 12, 24),
      updatedAt: DateTime(2025, 12, 24),
    );

    testWidgets('should display note title', (tester) async {
      // Arrange & Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: NoteCardWidget(note: testNote),
          ),
        ),
      );

      // Assert
      expect(find.text('Test Note'), findsOneWidget);
    });

    testWidgets('should display note content', (tester) async {
      // Arrange & Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: NoteCardWidget(note: testNote),
          ),
        ),
      );

      // Assert
      expect(find.textContaining('Test Content'), findsOneWidget);
    });

    testWidgets('should display tag if present', (tester) async {
      // Arrange & Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: NoteCardWidget(note: testNote),
          ),
        ),
      );

      // Assert
      expect(find.text('test'), findsOneWidget);
    });

    testWidgets('should call onTap when tapped', (tester) async {
      // Arrange
      bool tapped = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: NoteCardWidget(
              note: testNote,
              onTap: () => tapped = true,
            ),
          ),
        ),
      );

      // Act
      await tester.tap(find.byType(NoteCardWidget));
      await tester.pumpAndSettle();

      // Assert
      expect(tapped, true);
    });

    testWidgets('should highlight when selected', (tester) async {
      // Arrange & Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: NoteCardWidget(
              note: testNote,
              isSelected: true,
            ),
          ),
        ),
      );

      // Assert
      final card = tester.widget<Card>(find.byType(Card));
      final shape = card.shape as RoundedRectangleBorder;
      expect(shape.side.width, 2);
    });
  });
}
```

---

## PHẦN 3: INTEGRATION TESTING

### 3.1. Integration Test

**File**: `test_driver/integration_test.dart`

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:note_app/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Note App Integration Tests', () {
    testWidgets('Complete flow: Register -> Login -> Add Note -> View Note',
        (tester) async {
      // Start app
      app.main();
      await tester.pumpAndSettle();

      // Should start at login screen
      expect(find.text('Note App'), findsOneWidget);

      // Go to register
      await tester.tap(find.text('Chưa có tài khoản? Đăng ký ngay'));
      await tester.pumpAndSettle();

      // Fill register form
      await tester.enterText(
        find.byType(TextField).at(0),
        'testuser',
      );
      await tester.enterText(
        find.byType(TextField).at(1),
        'test@email.com',
      );
      await tester.enterText(
        find.byType(TextField).at(2),
        'password123',
      );
      await tester.enterText(
        find.byType(TextField).at(3),
        'password123',
      );

      // Submit register
      await tester.tap(find.text('Đăng ký'));
      await tester.pumpAndSettle();

      // Should navigate to home
      expect(find.text('Ghi Chú Của Tôi'), findsOneWidget);

      // Tap FAB to add note
      await tester.tap(find.byType(FloatingActionButton));
      await tester.pumpAndSettle();

      // Fill note form
      await tester.enterText(
        find.byType(TextField).at(0),
        'My First Note',
      );
      await tester.enterText(
        find.byType(TextField).at(1),
        'This is the content of my first note',
      );

      // Save note
      await tester.tap(find.byIcon(Icons.check));
      await tester.pumpAndSettle();

      // Should show note in list
      expect(find.text('My First Note'), findsOneWidget);

      // Tap note to view detail
      await tester.tap(find.text('My First Note'));
      await tester.pumpAndSettle();

      // Should show full content
      expect(find.text('This is the content of my first note'), findsOneWidget);
    });

    testWidgets('Search functionality', (tester) async {
      // Assume logged in and has notes
      app.main();
      await tester.pumpAndSettle();

      // Enter search query
      await tester.enterText(
        find.byType(TextField).first,
        'Flutter',
      );
      await tester.pumpAndSettle();

      // Should filter results
      expect(find.textContaining('Flutter'), findsWidgets);
    });
  });
}
```

---

## PHẦN 4: DOCUMENTATION

### 4.1. README.md

```markdown
# Note App - Ứng Dụng Ghi Chú

Ứng dụng ghi chú đơn giản, dễ sử dụng được xây dựng bằng Flutter với kiến trúc MVVM.

## Tính năng

- ✅ Đăng ký / Đăng nhập
- ✅ Thêm, sửa, xóa ghi chú
- ✅ Tìm kiếm ghi chú
- ✅ Lọc và sắp xếp
- ✅ Tag cho ghi chú
- ✅ Offline-first (SQLite)

## Yêu cầu hệ thống

- Flutter SDK >= 3.0.0
- Dart >= 3.0.0
- Android Studio / VS Code
- Android SDK (cho Android)
- Xcode (cho iOS)

## Cài đặt

### 1. Clone repository
\`\`\`bash
git clone https://github.com/your-repo/note_app.git
cd note_app
\`\`\`

### 2. Cài đặt dependencies
\`\`\`bash
flutter pub get
\`\`\`

### 3. Chạy ứng dụng
\`\`\`bash
# Android
flutter run

# iOS
flutter run --device ios

# Web (nếu support)
flutter run -d chrome
\`\`\`

## Cấu trúc thư mục

\`\`\`
lib/
├── models/              # Data models
├── views/               # UI screens & widgets
│   ├── screens/         # Main screens
│   └── widgets/         # Reusable widgets
├── viewmodels/          # State management (Provider)
├── repositories/        # Data access layer
├── services/            # Business logic services
├── commands/            # Command pattern implementations
├── bindings/            # Provider configuration
├── constants/           # App constants
├── utils/               # Helper functions
└── config/              # App configuration
\`\`\`

## Kiến trúc

Ứng dụng sử dụng mô hình **MVVM (Model-View-ViewModel)**:

- **Model**: Định nghĩa cấu trúc dữ liệu
- **View**: Giao diện người dùng
- **ViewModel**: Logic và state management
- **Repository**: Tầng trung gian truy xuất dữ liệu
- **Service**: Xử lý database và business logic

## Testing

### Unit Tests
\`\`\`bash
flutter test
\`\`\`

### Integration Tests
\`\`\`bash
flutter test integration_test/
\`\`\`

### Coverage
\`\`\`bash
flutter test --coverage
\`\`\`

## Công nghệ sử dụng

- **Framework**: Flutter
- **Language**: Dart
- **State Management**: Provider
- **Database**: SQLite (sqflite)
- **Authentication**: Local (SharedPreferences)
- **UI**: Material Design

## Contributors

- **Danh** - Project Lead & Authentication
- **Đại** - CRUD Operations
- **Bảo** - Search & Filter
- **Khánh** - UI/UX Components
- **Ngọc** - Testing & Documentation

## License

MIT License - xem [LICENSE](LICENSE) để biết thêm chi tiết.

## Contact

- Email: support@noteapp.com
- GitHub: https://github.com/your-repo/note_app
\`\`\`

---

### 4.2. DEVELOPER_GUIDE.md

```markdown
# Developer Guide - Note App

Hướng dẫn phát triển cho developers tham gia dự án.

## Setup Development Environment

### Required Tools
- Flutter SDK (stable channel)
- Android Studio / VS Code
- Git
- SQLite Browser (optional, for debugging)

### VS Code Extensions
- Flutter
- Dart
- Flutter Widget Snippets
- Error Lens

### Android Studio Plugins
- Flutter
- Dart

## Coding Standards

### Naming Conventions
- **Classes**: PascalCase (`NoteModel`, `HomeScreen`)
- **Files**: snake_case (`note_model.dart`, `home_screen.dart`)
- **Variables/Functions**: camelCase (`userName`, `loadNotes()`)
- **Constants**: UPPER_SNAKE_CASE (`APP_NAME`, `API_URL`)
- **Private members**: prefix với _ (`_privateMethod`)

### File Organization
\`\`\`dart
// 1. Imports (sorted)
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// 2. Class definition
class MyWidget extends StatelessWidget {
  // 3. Properties
  final String title;
  
  // 4. Constructor
  const MyWidget({super.key, required this.title});
  
  // 5. Lifecycle methods
  @override
  Widget build(BuildContext context) {
    // ...
  }
  
  // 6. Public methods
  void publicMethod() {}
  
  // 7. Private methods
  void _privateMethod() {}
}
\`\`\`

### Comments
\`\`\`dart
/// Doc comment cho public APIs
/// Sử dụng /// cho documentation

// Single line comment cho implementation details

/*
 * Multi-line comment
 * for complex explanations
 */
\`\`\`

## MVVM Architecture

### Data Flow
\`\`\`
View → ViewModel (Provider) → Repository → Service → Database
  ↑           ↓
  notifyListeners()
\`\`\`

### Best Practices
1. **View không chứa logic business**
2. **ViewModel không reference View**
3. **Repository tách biệt data source**
4. **Service handle business logic**
5. **Model chỉ chứa data**

## Git Workflow

### Branch Strategy
\`\`\`
main (production)
  ↑
develop (integration)
  ↑
feature/xxx (development)
\`\`\`

### Commit Message Format
\`\`\`
[Type] Short description

Types:
- feat: New feature
- fix: Bug fix
- docs: Documentation
- style: Formatting
- refactor: Code restructuring
- test: Adding tests
- chore: Maintenance
\`\`\`

### Pull Request Process
1. Create feature branch
2. Make changes
3. Write tests
4. Create PR
5. Code review
6. Merge to develop

## Testing Guidelines

### Unit Test Template
\`\`\`dart
void main() {
  group('FeatureName Tests', () {
    setUp(() {
      // Setup before each test
    });
    
    tearDown() {
      // Cleanup after each test
    });
    
    test('should do something', () {
      // Arrange
      // Act
      // Assert
    });
  });
}
\`\`\`

### Widget Test Template
\`\`\`dart
testWidgets('description', (tester) async {
  // Build widget
  await tester.pumpWidget(MyWidget());
  
  // Interact
  await tester.tap(find.byType(Button));
  await tester.pumpAndSettle();
  
  // Verify
  expect(find.text('Result'), findsOneWidget);
});
\`\`\`

## Debugging

### Print Statements
\`\`\`dart
debugPrint('Debug message');  // Preferred
print('Simple message');       // OK for quick debugging
\`\`\`

### Flutter DevTools
- Performance monitoring
- Widget inspector
- Memory profiler
- Network inspector

### Common Issues

**Issue**: Hot reload not working
**Solution**: Hot restart (Shift + R)

**Issue**: Database locked
**Solution**: Close all database connections

**Issue**: Provider not updating UI
**Solution**: Call notifyListeners()

## Performance Best Practices

1. Use `const` widgets when possible
2. Avoid rebuilding entire tree
3. Use `ListView.builder` for long lists
4. Cache images
5. Minimize database queries
6. Use `compute()` for heavy computations

## Resources

- Flutter Docs: https://docs.flutter.dev
- Dart Docs: https://dart.dev
- Provider: https://pub.dev/packages/provider
- sqflite: https://pub.dev/packages/sqflite
\`\`\`

---

## SUMMARY - TÓM TẮT

**Ngọc làm gì**:
1. ✅ Unit tests cho tất cả layers
2. ✅ Widget tests
3. ✅ Integration tests
4. ✅ Documentation đầy đủ
5. ✅ Ensure code quality

**Output cuối cùng**:
- Test coverage > 80%
- Documentation hoàn chỉnh
- Quality assurance

**Thời gian ước tính**: 2-3 tuần
