# CHI TIẾT CÔNG VIỆC - DANH (Nhóm trưởng)

## 🎯 VAI TRÒ: Quản lý dự án + Module Authentication

---

## PHẦN 1: MODULE AUTHENTICATION ✅ (ĐÃ HOÀN THÀNH)

### 1.1. Các file đã tạo
```
lib/models/user_model.dart
lib/services/auth_service.dart
lib/repositories/auth_repository.dart
lib/viewmodels/auth_provider.dart
lib/views/screens/login_screen.dart
lib/views/screens/register_screen.dart
```

### 1.2. Chức năng đã implement

#### A. Model - user_model.dart
**Mô tả**: Định nghĩa cấu trúc dữ liệu User
**Chi tiết**:
- Properties:
  - `id`: ID tự động tăng
  - `username`: Tên đăng nhập (unique)
  - `email`: Email (unique)
  - `password`: Mật khẩu đã hash
  - `createdAt`: Thời gian tạo tài khoản

- Methods:
  - `toMap()`: Convert object sang Map để lưu SQLite
  - `fromMap()`: Tạo object từ Map lấy từ database
  - `copyWith()`: Tạo bản copy với các field được update

**Ví dụ sử dụng**:
```dart
// Tạo user mới
final user = UserModel(
  username: 'john_doe',
  email: 'john@email.com',
  password: hashedPassword,
  createdAt: DateTime.now(),
);

// Chuyển sang Map để lưu DB
final map = user.toMap();

// Tạo từ Map
final userFromDb = UserModel.fromMap(map);
```

---

#### B. Service - auth_service.dart
**Mô tả**: Xử lý logic authentication ở tầng database
**Chi tiết**:

**1. Khởi tạo Database**
```dart
Future<void> initializeAuthTables()
```
- Tạo bảng `users` nếu chưa có
- Các cột: id, username, email, password, createdAt
- Constraints: username và email UNIQUE

**2. Hash Password**
```dart
String _hashPassword(String password)
```
- Sử dụng SHA-256 để hash password
- Input: password plain text
- Output: password đã hash (không thể reverse)
- Lý do: Bảo mật, không lưu password dạng plain text

**3. Đăng ký**
```dart
Future<Map<String, dynamic>> register({
  required String username,
  required String email,
  required String password,
})
```
**Flow**:
1. Khởi tạo bảng users nếu chưa có
2. Kiểm tra username/email đã tồn tại chưa
3. Nếu tồn tại → return error
4. Nếu chưa → Hash password
5. Tạo UserModel mới
6. Insert vào database
7. Return success với userId

**Output**:
```dart
{
  'success': true/false,
  'message': 'Thông báo',
  'userId': 123 // nếu thành công
}
```

**4. Đăng nhập**
```dart
Future<Map<String, dynamic>> login({
  required String username,
  required String password,
})
```
**Flow**:
1. Khởi tạo bảng users
2. Hash password nhập vào
3. Query database với username và hashed password
4. Nếu tìm thấy → return success với user object
5. Nếu không → return error

**Output**:
```dart
{
  'success': true/false,
  'message': 'Thông báo',
  'user': UserModel // nếu thành công
}
```

**5. Lấy thông tin User**
```dart
Future<UserModel?> getUserById(int id)
```
- Query user theo ID
- Return UserModel hoặc null nếu không tìm thấy

---

#### C. Repository - auth_repository.dart
**Mô tả**: Tầng trung gian giữa ViewModel và Service
**Lý do cần Repository**:
- Tách biệt logic business khỏi ViewModel
- Dễ dàng thay đổi data source (SQLite → API → Firebase)
- Dễ test

**Methods**:
```dart
Future<Map<String, dynamic>> register(...)  // Gọi authService.register()
Future<Map<String, dynamic>> login(...)     // Gọi authService.login()
Future<UserModel?> getUserById(int id)      // Gọi authService.getUserById()
```

**Pattern sử dụng**: Repository Pattern
**Nhiệm vụ**: Proxy, không xử lý logic phức tạp

---

#### D. ViewModel - auth_provider.dart
**Mô tả**: Quản lý state authentication, logic UI
**Kế thừa**: `ChangeNotifier` (Provider pattern)

**State Management**:
```dart
UserModel? _currentUser;        // User hiện tại
bool _isAuthenticated = false;  // Trạng thái đăng nhập
bool _isLoading = false;        // Trạng thái loading
```

**Getters** (Data Binding):
```dart
UserModel? get currentUser
bool get isAuthenticated
bool get isLoading
```

**Methods**:

**1. Initialize**
```dart
Future<void> initialize()
```
**Mục đích**: Khôi phục session khi mở app
**Flow**:
1. Đọc userId từ SharedPreferences
2. Nếu có userId → Load user từ database
3. Set _currentUser và _isAuthenticated
4. notifyListeners() → UI tự động update

**2. Register**
```dart
Future<Map<String, dynamic>> register({
  required String username,
  required String email,
  required String password,
})
```
**Flow**:
1. Set _isLoading = true → Hiển thị loading
2. Gọi repository.register()
3. Nếu thành công → Tự động login
4. Set _isLoading = false
5. notifyListeners()

**3. Login**
```dart
Future<Map<String, dynamic>> login({
  required String username,
  required String password,
})
```
**Flow**:
1. Set _isLoading = true
2. Gọi repository.login()
3. Nếu thành công:
   - Set _currentUser
   - Set _isAuthenticated = true
   - Lưu userId vào SharedPreferences
4. Set _isLoading = false
5. notifyListeners()

**4. Logout**
```dart
Future<void> logout()
```
**Flow**:
1. Clear _currentUser
2. Set _isAuthenticated = false
3. Xóa userId khỏi SharedPreferences
4. notifyListeners()

---

#### E. View - login_screen.dart
**Mô tả**: Màn hình đăng nhập
**UI Components**:
```
┌─────────────────────────┐
│      App Logo/Icon      │
│       "Note App"        │
│  "Đăng nhập để tiếp tục"│
│                         │
│  ┌─────────────────┐   │
│  │ Username Input  │   │
│  └─────────────────┘   │
│                         │
│  ┌─────────────────┐   │
│  │ Password Input  │   │
│  └─────────────────┘   │
│                         │
│  ┌─────────────────┐   │
│  │  Đăng nhập Btn  │   │
│  └─────────────────┘   │
│                         │
│   Chưa có tài khoản?    │
│     Đăng ký ngay        │
└─────────────────────────┘
```

**Features**:
1. **Form Validation**:
   - Username: Không được để trống
   - Password: Không được để trống

2. **Show/Hide Password**:
   - IconButton toggle visibility

3. **Loading State**:
   - Hiển thị CircularProgressIndicator khi đang login
   - Disable button khi loading

4. **Error Handling**:
   - Hiển thị SnackBar nếu login fail

5. **Navigation**:
   - Success → Navigate to '/home'
   - Đăng ký → Navigate to '/register'

**Code chính**:
```dart
Future<void> _handleLogin() async {
  if (!_formKey.currentState!.validate()) return;

  final authProvider = Provider.of<AuthProvider>(context, listen: false);
  
  final result = await authProvider.login(
    username: _usernameController.text.trim(),
    password: _passwordController.text,
  );

  if (result['success']) {
    Navigator.of(context).pushReplacementNamed('/home');
  } else {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(result['message'])),
    );
  }
}
```

---

#### F. View - register_screen.dart
**Mô tả**: Màn hình đăng ký
**UI Components**:
```
┌─────────────────────────┐
│      "Đăng ký"          │
│  (AppBar with back btn) │
│                         │
│  ┌─────────────────┐   │
│  │ Username Input  │   │
│  └─────────────────┘   │
│                         │
│  ┌─────────────────┐   │
│  │  Email Input    │   │
│  └─────────────────┘   │
│                         │
│  ┌─────────────────┐   │
│  │ Password Input  │   │
│  └─────────────────┘   │
│                         │
│  ┌─────────────────┐   │
│  │ Confirm Pass    │   │
│  └─────────────────┘   │
│                         │
│  ┌─────────────────┐   │
│  │   Đăng ký Btn   │   │
│  └─────────────────┘   │
└─────────────────────────┘
```

**Features**:
1. **Form Validation**:
   - Username: 
     - Không được để trống
     - Tối thiểu 3 ký tự
   - Email:
     - Không được để trống
     - Phải có format email (chứa @)
   - Password:
     - Không được để trống
     - Tối thiểu 6 ký tự
   - Confirm Password:
     - Phải khớp với password

2. **Show/Hide Password**: Cả 2 fields

3. **Auto Login**: Sau khi đăng ký thành công → tự động login

4. **Navigation**:
   - Success → Navigate to '/home'
   - Đã có tài khoản → Back to login

---

## PHẦN 2: INTEGRATION & CODE REVIEW (CÔNG VIỆC TIẾP THEO)

### 2.1. Integration Tasks

#### A. Main.dart Configuration ✅ (Đã hoàn thành)
- Setup MultiProvider với AuthProvider và NoteProvider
- Configure routing
- Setup theme
- Authentication guard (TODO)

#### B. Session Management ✅ (Đã hoàn thành)
- Initialize AuthProvider khi app start
- Kiểm tra session với SharedPreferences
- Auto login nếu có session hợp lệ

#### C. Navigation Guard (TODO - Công việc tiếp theo)
**Mục đích**: Bảo vệ các route yêu cầu authentication

**Cần implement**:
```dart
class AuthGuard extends StatelessWidget {
  final Widget child;
  
  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, _) {
        if (authProvider.isAuthenticated) {
          return child;
        } else {
          return const LoginScreen();
        }
      },
    );
  }
}
```

**Sử dụng**:
```dart
'/home': (context) => AuthGuard(child: const HomeScreen()),
```

---

### 2.2. Code Review Responsibilities

#### A. Review Checklist

**1. Code Quality**:
- [ ] Code tuân thủ MVVM pattern
- [ ] Không có logic business trong View
- [ ] Provider được sử dụng đúng cách
- [ ] Naming conventions rõ ràng
- [ ] Comments đầy đủ

**2. UI/UX**:
- [ ] Responsive design
- [ ] Loading states
- [ ] Error handling
- [ ] Empty states
- [ ] Consistent styling

**3. Performance**:
- [ ] Không có memory leak
- [ ] Dispose controllers properly
- [ ] Optimize rebuild (Consumer thay vì Provider.of)

**4. Security**:
- [ ] Password được hash
- [ ] Input validation
- [ ] SQL injection prevention

**5. Testing**:
- [ ] Unit tests coverage > 80%
- [ ] Widget tests cho critical flows
- [ ] Integration tests

---

#### B. Review Process

**Step 1: Pre-review**
```bash
# Check code format
flutter format .

# Run analyzer
flutter analyze

# Run tests
flutter test
```

**Step 2: Review Code**
- Đọc code changes
- Kiểm tra logic
- Test trên emulator/device
- Check performance

**Step 3: Feedback**
- Comment trên PR
- Request changes nếu cần
- Approve khi đạt tiêu chuẩn

**Step 4: Merge**
```bash
git checkout develop
git merge feature/xxx
git push origin develop
```

---

### 2.3. Integration with Note Module

#### A. Link User với Notes (TODO)
**Mục đích**: Mỗi user chỉ thấy notes của mình

**Cần thay đổi**:

**1. Update note_model.dart**:
```dart
class NoteModel {
  final int? id;
  final int userId;  // ← THÊM FIELD NÀY
  final String title;
  // ... các fields khác
}
```

**2. Update database_service.dart**:
```dart
// Thêm cột userId vào table notes
CREATE TABLE notes(
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  userId INTEGER NOT NULL,  // ← THÊM FIELD NÀY
  title TEXT NOT NULL,
  content TEXT NOT NULL,
  // ...
  FOREIGN KEY (userId) REFERENCES users(id)
)

// Update query methods
Future<List<NoteModel>> getAllNotes(int userId) async {
  final db = await database;
  final List<Map<String, dynamic>> maps = await db.query(
    'notes',
    where: 'userId = ?',  // ← FILTER BY USER
    whereArgs: [userId],
    orderBy: 'updatedAt DESC',
  );
  return List.generate(maps.length, (i) => NoteModel.fromMap(maps[i]));
}
```

**3. Update note_provider.dart**:
```dart
class NoteProvider extends ChangeNotifier {
  final NoteRepository _repository = NoteRepository();
  int? _currentUserId;  // ← THÊM

  void setUserId(int userId) {
    _currentUserId = userId;
  }

  Future<void> loadNotes() async {
    if (_currentUserId == null) return;
    _notes = await _repository.getAllNotes(_currentUserId!);
    notifyListeners();
  }
}
```

**4. Integration trong main.dart hoặc home_screen.dart**:
```dart
@override
void initState() {
  super.initState();
  WidgetsBinding.instance.addPostFrameCallback((_) {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final noteProvider = Provider.of<NoteProvider>(context, listen: false);
    
    // Set userId cho NoteProvider
    if (authProvider.currentUser != null) {
      noteProvider.setUserId(authProvider.currentUser!.id!);
      noteProvider.loadNotes();
    }
  });
}
```

---

## PHẦN 3: QUẢN LÝ DỰ ÁN

### 3.1. Git Workflow Management

#### Branch Strategy:
```
main (production)
  ↑
develop (integration)
  ↑
feature/auth-login (Danh)
feature/note-crud (Đại)
feature/search-filter (Bảo)
feature/ui-components (Khánh)
feature/testing (Ngọc)
```

#### Git Commands để dạy team:
```bash
# Tạo branch mới
git checkout -b feature/your-feature

# Commit changes
git add .
git commit -m "[feat] Add login screen"

# Push lên remote
git push origin feature/your-feature

# Tạo Pull Request trên GitHub/GitLab

# Merge vào develop (sau khi approve)
git checkout develop
git merge feature/your-feature
git push origin develop
```

---

### 3.2. Daily Standup Management

**Format**: 15 phút mỗi sáng

**3 câu hỏi cho mỗi người**:
1. Hôm qua làm được gì?
2. Hôm nay sẽ làm gì?
3. Có vấn đề gì cần support?

**Ví dụ**:
```
Đại: 
- Hôm qua: Hoàn thành add_edit_note_screen UI
- Hôm nay: Implement save note logic
- Blocker: Cần confirm validation rules

Bảo:
- Hôm qua: Research search functionality
- Hôm nay: Implement search bar widget
- Blocker: None
```

---

### 3.3. Sprint Planning

#### Week 1 Plan:
```
┌─────────────┬──────────────────────────────────┐
│   Thành viên │            Nhiệm vụ              │
├─────────────┼──────────────────────────────────┤
│ Danh        │ ✅ Auth module                    │
│             │ □ Integration setup              │
│             │ □ Code review setup              │
├─────────────┼──────────────────────────────────┤
│ Đại         │ □ Add/Edit screen UI             │
│             │ □ Detail screen UI               │
├─────────────┼──────────────────────────────────┤
│ Bảo         │ □ Home screen enhancement        │
│             │ □ Search bar widget              │
├─────────────┼──────────────────────────────────┤
│ Khánh       │ □ Note card widget               │
│             │ □ Theme setup                    │
│             │ □ Splash screen                  │
├─────────────┼──────────────────────────────────┤
│ Ngọc        │ □ Test framework setup           │
│             │ □ Write unit tests for models    │
└─────────────┴──────────────────────────────────┘
```

---

### 3.4. Documentation Management

**Cần maintain các docs**:
1. ✅ `WORK_DISTRIBUTION.md` - Phân công công việc
2. ✅ `DANH_TASKS.md` - Chi tiết công việc Danh (file này)
3. TODO: `README.md` - Hướng dẫn setup project
4. TODO: `DEVELOPER_GUIDE.md` - Hướng dẫn dev
5. TODO: `API_DOCS.md` - Document các methods

---

### 3.5. Meeting Schedule

**Weekly Meetings**:
- **Monday 9:00 AM**: Sprint Planning
- **Daily 9:00 AM**: Standup (15 min)
- **Wednesday 3:00 PM**: Code Review Session
- **Friday 4:00 PM**: Sprint Review & Retrospective

---

## PHẦN 4: TESTING & DEPLOYMENT

### 4.1. Integration Testing (Với Ngọc)

**Test Scenarios cần verify**:
1. **Auth Flow**:
   - Register → Auto login → Home screen
   - Login → Home screen
   - Logout → Login screen
   - Invalid credentials → Error message

2. **Session Management**:
   - Close app → Reopen → Still logged in
   - Logout → Close app → Reopen → Login screen

3. **Navigation**:
   - Protected routes
   - Back button behavior

---

### 4.2. Pre-deployment Checklist

**Danh phải verify**:
- [ ] All tests passing
- [ ] No console errors
- [ ] Performance acceptable
- [ ] UI responsive on multiple devices
- [ ] Security checks passed
- [ ] Documentation complete

---

## CÔNG CỤ CẦN THIẾT

### Development Tools:
- Flutter SDK
- Android Studio / VS Code
- Git
- SQLite Browser (để debug database)

### Project Management:
- Trello / Jira (Task tracking)
- GitHub / GitLab (Code repository)
- Slack / Discord (Communication)

### Testing Tools:
- Flutter DevTools
- Chrome DevTools
- Android Emulator
- iOS Simulator

---

## TÀI LIỆU THAM KHẢO

1. **MVVM Pattern**:
   - https://interdata.vn/blog/mvvm-la-gi/
   - Flutter Provider Documentation

2. **Authentication**:
   - SHA-256 Hashing: https://api.dart.dev/stable/dart-crypto
   - SharedPreferences: https://pub.dev/packages/shared_preferences

3. **SQLite**:
   - sqflite Documentation: https://pub.dev/packages/sqflite

---

## SUMMARY - TÓM TẮT CÔNG VIỆC DANH

### ✅ Đã hoàn thành:
1. Module Authentication (100%)
   - Models, Services, Repositories, ViewModels, Views
2. Basic Integration
   - Provider setup
   - Routing
   - Theme

### 🔄 Đang làm:
1. Navigation Guard
2. Link User với Notes
3. Code Review setup

### 📋 Sắp tới:
1. Daily code review
2. Integration testing với team
3. Bug fixing
4. Final deployment preparation

**Ước tính thời gian**: 2-3 tuần để hoàn thành tất cả
