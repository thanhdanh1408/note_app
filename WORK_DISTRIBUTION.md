# PHÂN CÔNG CÔNG VIỆC - NOTE APP
## Nhóm 5 thành viên

---

## 👨‍💼 **DANH (Nhóm trưởng)**
### Nhiệm vụ: Quản lý dự án + Module Authentication

#### 1. Authentication System (Đăng nhập/Đăng ký)
- ✅ Model: `user_model.dart` (đã tạo)
- ✅ Service: `auth_service.dart` (đã tạo)
- ✅ Repository: `auth_repository.dart` (đã tạo)
- ✅ ViewModel: `auth_provider.dart` (đã tạo)
- ✅ Views: 
  - `login_screen.dart` (đã tạo)
  - `register_screen.dart` (đã tạo)

#### 2. Quản lý chung
- Tích hợp AuthProvider vào `app_bindings.dart`
- Cập nhật `main.dart` với routing và authentication check
- Quản lý navigation guards (kiểm tra đăng nhập)
- Code review và merge code của các thành viên
- Test tích hợp toàn bộ hệ thống

**Deadline:** Tuần 1-2

---

## 👨‍💻 **ĐẠI**
### Nhiệm vụ: Module Note Management (CRUD Operations)

#### 1. Màn hình thêm/sửa ghi chú
- `add_edit_note_screen.dart`
  - Form nhập tiêu đề, nội dung, tag
  - Validation
  - Tích hợp với NoteProvider (Command Pattern)
  - Giao diện Material Design

#### 2. Màn hình chi tiết ghi chú
- `note_detail_screen.dart`
  - Hiển thị đầy đủ thông tin ghi chú
  - Các nút: Sửa, Xóa, Chia sẻ
  - Dialog xác nhận xóa

#### 3. Testing
- Unit test cho AddNoteCommand, UpdateNoteCommand
- Widget test cho màn hình thêm/sửa

**Files cần tạo:**
```
lib/views/screens/add_edit_note_screen.dart
lib/views/screens/note_detail_screen.dart
test/screens/add_edit_note_test.dart
```

**Deadline:** Tuần 2

---

## 👨‍💻 **BẢO**
### Nhiệm vụ: Module Search & Filter

#### 1. Tìm kiếm ghi chú
- Widget search bar tái sử dụng: `search_bar_widget.dart`
- Tìm kiếm real-time
- Hiển thị kết quả tìm kiếm
- Clear search button

#### 2. Lọc và sắp xếp
- `filter_bottom_sheet.dart`:
  - Lọc theo tag
  - Sắp xếp theo ngày tạo/sửa
  - Sắp xếp theo tiêu đề
- Logic lọc trong NoteProvider

#### 3. Giao diện danh sách
- Hoàn thiện `home_screen.dart`
- Tích hợp search và filter
- Pull-to-refresh
- Empty state design

**Files cần tạo:**
```
lib/views/widgets/search_bar_widget.dart
lib/views/widgets/filter_bottom_sheet.dart
lib/views/widgets/note_list_widget.dart
```

**Deadline:** Tuần 2

---

## 👨‍💻 **KHÁNH**
### Nhiệm vụ: UI/UX Components (Data Templates)

#### 1. Widget tái sử dụng
- `note_card_widget.dart`: Card hiển thị ghi chú trong danh sách
- `tag_chip_widget.dart`: Chip hiển thị tag
- `empty_state_widget.dart`: Widget hiển thị khi không có dữ liệu
- `loading_widget.dart`: Widget loading state
- `confirmation_dialog.dart`: Dialog xác nhận (xóa, thoát...)

#### 2. Theme & Styling
- Cập nhật và hoàn thiện `app_constants.dart`
- Tạo custom theme trong `lib/config/app_theme.dart`
- Icon set và assets
- Responsive design utilities

#### 3. Animations
- Thêm animations cho transitions
- Loading animations
- Splash screen animation

**Files cần tạo:**
```
lib/views/widgets/note_card_widget.dart
lib/views/widgets/tag_chip_widget.dart
lib/views/widgets/empty_state_widget.dart
lib/views/widgets/loading_widget.dart
lib/views/widgets/confirmation_dialog.dart
lib/config/app_theme.dart
lib/views/screens/splash_screen.dart
```

**Deadline:** Tuần 1-2

---

## 👩‍💻 **NGỌC**
### Nhiệm vụ: Testing & Documentation

#### 1. Unit Testing
- Test cho Models:
  - `test/models/note_model_test.dart`
  - `test/models/user_model_test.dart`
- Test cho Services:
  - `test/services/database_service_test.dart`
  - `test/services/auth_service_test.dart`
- Test cho Repositories
- Test cho ViewModels/Providers

#### 2. Widget Testing
- Test các màn hình chính
- Test các widget tái sử dụng
- Integration tests

#### 3. Documentation
- README.md chi tiết
- Comment code đầy đủ
- User guide (hướng dẫn sử dụng)
- Developer guide (hướng dẫn phát triển)
- API documentation

**Files cần tạo:**
```
test/models/note_model_test.dart
test/models/user_model_test.dart
test/services/database_service_test.dart
test/services/auth_service_test.dart
test/repositories/note_repository_test.dart
test/viewmodels/note_provider_test.dart
test/viewmodels/auth_provider_test.dart
README.md
DEVELOPER_GUIDE.md
USER_GUIDE.md
```

**Deadline:** Tuần 2-3

---

## 📋 TIMELINE TỔNG QUAN

### **Tuần 1: Setup & Core Features**
- **Danh**: Authentication system + Main.dart
- **Khánh**: UI Components + Theme
- **Đại**: Bắt đầu CRUD screens
- **Bảo**: Bắt đầu Search & Filter
- **Ngọc**: Setup testing framework + Documentation structure

### **Tuần 2: Feature Development**
- **Danh**: Integration + Code review
- **Đại**: Hoàn thiện CRUD operations
- **Bảo**: Hoàn thiện Search & Filter
- **Khánh**: Hoàn thiện UI/UX + Animations
- **Ngọc**: Unit tests + Widget tests

### **Tuần 3: Testing & Polish**
- **Tất cả**: Bug fixing
- **Ngọc**: Integration tests + Documentation
- **Danh**: Final review + Deployment preparation

---

## 📊 CHECKLIST TỔNG THỂ

### Core Features
- [ ] Authentication (Login/Register)
- [ ] CRUD Notes (Create, Read, Update, Delete)
- [ ] Search Notes
- [ ] Filter by Tag
- [ ] Sort Notes

### UI/UX
- [ ] Material Design
- [ ] Responsive layout
- [ ] Animations
- [ ] Empty states
- [ ] Loading states
- [ ] Error handling UI

### Technical
- [ ] MVVM Architecture
- [ ] Provider State Management
- [ ] SQLite Database
- [ ] Repository Pattern
- [ ] Command Pattern
- [ ] Data Binding

### Quality
- [ ] Unit Tests (>80% coverage)
- [ ] Widget Tests
- [ ] Integration Tests
- [ ] Code Documentation
- [ ] User Documentation

---

## 🔧 DEPENDENCIES CẦN THÊM

Cập nhật trong `pubspec.yaml`:
```yaml
dependencies:
  # Đã có
  provider: ^6.1.1
  sqflite: ^2.3.0
  path_provider: ^2.1.1
  intl: ^0.19.0
  
  # Cần thêm
  shared_preferences: ^2.2.2  # Lưu session
  crypto: ^3.0.3              # Hash password

dev_dependencies:
  # Testing
  mockito: ^5.4.4
  build_runner: ^2.4.7
```

---

## 📞 COMMUNICATION

- **Daily Standup**: 9:00 AM (15 phút)
- **Code Review**: Mỗi PR phải được review bởi ít nhất 1 người
- **Git Branch Strategy**: 
  - `main`: Production code
  - `develop`: Development branch
  - `feature/[tên-chức-năng]`: Feature branches
- **Commit Message Format**: `[Type] Mô tả ngắn gọn`
  - Types: feat, fix, docs, style, refactor, test

---

## 🎯 MỤC TIÊU CUỐI CÙNG

Ứng dụng Note App hoàn chỉnh với:
✅ Đăng nhập/Đăng ký
✅ Quản lý ghi chú (CRUD)
✅ Tìm kiếm và lọc
✅ UI/UX đẹp, mượt mà
✅ Code sạch, tuân thủ MVVM
✅ Test coverage cao
✅ Documentation đầy đủ

**Good luck team! 💪🚀**
