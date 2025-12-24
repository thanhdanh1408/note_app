# CHI TIẾT CÔNG VIỆC - BẢO

## 🎯 VAI TRÒ: Module Search & Filter + Hoàn thiện Home Screen

---

## TỔNG QUAN NHIỆM VỤ

Bảo chịu trách nhiệm xây dựng tính năng tìm kiếm và lọc ghi chú, đồng thời hoàn thiện màn hình Home để hiển thị danh sách ghi chú một cách đẹp mắt và tiện dụng.

**Files cần tạo**:
```
lib/views/widgets/search_bar_widget.dart
lib/views/widgets/filter_bottom_sheet.dart
lib/views/widgets/note_list_widget.dart
lib/views/widgets/sort_options_widget.dart
```

**Files cần update**:
```
lib/views/screens/home_screen.dart (cập nhật từ file đã có)
```

---

## PHẦN 1: SEARCH BAR WIDGET

### 1.1. Mô tả Chức năng

Widget search bar cho phép:
- **Real-time search**: Tìm kiếm ngay khi gõ
- **Clear button**: Xóa nhanh text đã nhập
- **Search icon**: Visual cue
- **Placeholder text**: Gợi ý người dùng

---

### 1.2. UI Design

```
┌─────────────────────────────────────┐
│  🔍  Tìm kiếm ghi chú...        [×] │ ← Search bar
└─────────────────────────────────────┘
```

**States**:
1. **Empty**: Hiển thị placeholder + search icon
2. **Typing**: Hiển thị text + clear button (×)
3. **Has results**: Filter list hiển thị
4. **No results**: Hiển thị "Không tìm thấy kết quả"

---

### 1.3. Implementation Chi tiết

#### A. Widget Structure

```dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../viewmodels/note_provider.dart';
import '../../constants/app_constants.dart';

class SearchBarWidget extends StatefulWidget {
  const SearchBarWidget({super.key});

  @override
  State<SearchBarWidget> createState() => _SearchBarWidgetState();
}

class _SearchBarWidgetState extends State<SearchBarWidget> {
  final TextEditingController _searchController = TextEditingController();
  
  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimensions.paddingMedium,
        vertical: AppDimensions.paddingSmall,
      ),
      child: TextField(
        controller: _searchController,
        decoration: InputDecoration(
          hintText: AppStrings.searchHint,
          prefixIcon: const Icon(Icons.search),
          suffixIcon: _searchController.text.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: _clearSearch,
                )
              : null,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
            borderSide: BorderSide(color: AppColors.divider),
          ),
          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: AppDimensions.paddingMedium,
            vertical: AppDimensions.paddingSmall,
          ),
        ),
        onChanged: _onSearchChanged,
      ),
    );
  }

  void _onSearchChanged(String query) {
    setState(() {}); // Để update suffixIcon
    
    // Debounce search để tránh gọi quá nhiều
    Future.delayed(const Duration(milliseconds: 300), () {
      if (_searchController.text == query) {
        Provider.of<NoteProvider>(context, listen: false)
            .searchNotes(query);
      }
    });
  }

  void _clearSearch() {
    _searchController.clear();
    Provider.of<NoteProvider>(context, listen: false)
        .clearFilters();
    setState(() {});
  }
}
```

---

#### B. Debouncing Technique

**Vấn đề**: Nếu search mỗi khi gõ, sẽ có quá nhiều database queries.

**Giải pháp**: Debounce - chỉ search sau khi user ngừng gõ 300ms.

**Cách implement tốt hơn**:
```dart
import 'dart:async';

class _SearchBarWidgetState extends State<SearchBarWidget> {
  final TextEditingController _searchController = TextEditingController();
  Timer? _debounce;

  @override
  void dispose() {
    _searchController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  void _onSearchChanged(String query) {
    setState(() {});
    
    // Cancel timer cũ nếu có
    if (_debounce?.isActive ?? false) _debounce!.cancel();

    // Tạo timer mới
    _debounce = Timer(const Duration(milliseconds: 300), () {
      Provider.of<NoteProvider>(context, listen: false)
          .searchNotes(query);
    });
  }
}
```

---

## PHẦN 2: FILTER BOTTOM SHEET

### 2.1. Mô tả Chức năng

Bottom sheet cho phép:
- **Lọc theo Tag**: Hiển thị list các tags có sẵn
- **Sắp xếp**: Theo ngày tạo / ngày sửa / tiêu đề
- **Apply button**: Áp dụng filter
- **Clear button**: Xóa tất cả filter

---

### 2.2. UI Design

```
        ┌─────────────────────────────┐
        │  Lọc & Sắp xếp          [×] │
        ├─────────────────────────────┤
        │                             │
        │  SẮP XẾP                    │
        │  ○ Ngày sửa (mới nhất)      │
        │  ○ Ngày tạo (mới nhất)      │
        │  ○ Tiêu đề (A-Z)            │
        │                             │
        │  LỌC THEO TAG               │
        │  [ ] work (5)               │
        │  [ ] personal (3)           │
        │  [ ] study (7)              │
        │                             │
        │  ┌────────────┬────────────┐│
        │  │ Xóa filter │ Áp dụng    ││
        │  └────────────┴────────────┘│
        └─────────────────────────────┘
```

---

### 2.3. Implementation Chi tiết

```dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../viewmodels/note_provider.dart';
import '../../constants/app_constants.dart';

enum SortOption {
  dateModified,
  dateCreated,
  title,
}

class FilterBottomSheet extends StatefulWidget {
  const FilterBottomSheet({super.key});

  @override
  State<FilterBottomSheet> createState() => _FilterBottomSheetState();
}

class _FilterBottomSheetState extends State<FilterBottomSheet> {
  SortOption _selectedSort = SortOption.dateModified;
  String? _selectedTag;
  List<String> _availableTags = [];

  @override
  void initState() {
    super.initState();
    _loadAvailableTags();
  }

  void _loadAvailableTags() {
    final noteProvider = Provider.of<NoteProvider>(context, listen: false);
    // Lấy danh sách unique tags từ notes
    final tags = noteProvider.notes
        .where((note) => note.tag != null && note.tag!.isNotEmpty)
        .map((note) => note.tag!)
        .toSet()
        .toList();
    setState(() {
      _availableTags = tags;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppDimensions.paddingLarge),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppDimensions.radiusLarge),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Lọc & Sắp xếp',
                style: AppTextStyles.titleMedium,
              ),
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Sort options
          Text(
            'SẮP XẾP',
            style: AppTextStyles.titleSmall,
          ),
          const SizedBox(height: 8),
          _buildSortOptions(),
          
          const SizedBox(height: 24),

          // Filter by tag
          Text(
            'LỌC THEO TAG',
            style: AppTextStyles.titleSmall,
          ),
          const SizedBox(height: 8),
          _buildTagFilters(),

          const SizedBox(height: 24),

          // Action buttons
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: _clearFilters,
                  child: const Text('Xóa filter'),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: ElevatedButton(
                  onPressed: _applyFilters,
                  child: const Text('Áp dụng'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSortOptions() {
    return Column(
      children: [
        RadioListTile<SortOption>(
          title: const Text('Ngày sửa (mới nhất)'),
          value: SortOption.dateModified,
          groupValue: _selectedSort,
          onChanged: (value) {
            setState(() {
              _selectedSort = value!;
            });
          },
        ),
        RadioListTile<SortOption>(
          title: const Text('Ngày tạo (mới nhất)'),
          value: SortOption.dateCreated,
          groupValue: _selectedSort,
          onChanged: (value) {
            setState(() {
              _selectedSort = value!;
            });
          },
        ),
        RadioListTile<SortOption>(
          title: const Text('Tiêu đề (A-Z)'),
          value: SortOption.title,
          groupValue: _selectedSort,
          onChanged: (value) {
            setState(() {
              _selectedSort = value!;
            });
          },
        ),
      ],
    );
  }

  Widget _buildTagFilters() {
    if (_availableTags.isEmpty) {
      return const Text(
        'Chưa có tag nào',
        style: AppTextStyles.bodyMedium,
      );
    }

    return Column(
      children: _availableTags.map((tag) {
        // Đếm số notes có tag này
        final count = Provider.of<NoteProvider>(context, listen: false)
            .notes
            .where((note) => note.tag == tag)
            .length;

        return CheckboxListTile(
          title: Text('$tag ($count)'),
          value: _selectedTag == tag,
          onChanged: (checked) {
            setState(() {
              _selectedTag = checked == true ? tag : null;
            });
          },
        );
      }).toList(),
    );
  }

  void _clearFilters() {
    setState(() {
      _selectedSort = SortOption.dateModified;
      _selectedTag = null;
    });
    Provider.of<NoteProvider>(context, listen: false).clearFilters();
    Navigator.pop(context);
  }

  void _applyFilters() {
    final noteProvider = Provider.of<NoteProvider>(context, listen: false);
    
    // Apply tag filter
    if (_selectedTag != null) {
      noteProvider.filterByTag(_selectedTag);
    }
    
    // Apply sort
    _applySorting(noteProvider);
    
    Navigator.pop(context);
  }

  void _applySorting(NoteProvider provider) {
    // TODO: Implement sorting in NoteProvider
    switch (_selectedSort) {
      case SortOption.dateModified:
        provider.sortByDateModified();
        break;
      case SortOption.dateCreated:
        provider.sortByDateCreated();
        break;
      case SortOption.title:
        provider.sortByTitle();
        break;
    }
  }
}

// Show bottom sheet
void showFilterBottomSheet(BuildContext context) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(
        top: Radius.circular(AppDimensions.radiusLarge),
      ),
    ),
    builder: (context) => const FilterBottomSheet(),
  );
}
```

---

### 2.4. Update NoteProvider với Sort Methods

**File cần update**: `lib/viewmodels/note_provider.dart`

```dart
// Thêm vào NoteProvider class

void sortByDateModified() {
  _notes.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
  notifyListeners();
}

void sortByDateCreated() {
  _notes.sort((a, b) => b.createdAt.compareTo(a.createdAt));
  notifyListeners();
}

void sortByTitle() {
  _notes.sort((a, b) => a.title.compareTo(b.title));
  notifyListeners();
}
```

---

## PHẦN 3: NOTE LIST WIDGET

### 3.1. Mô tả Chức năng

Widget hiển thị danh sách ghi chú với:
- **List/Grid view**: Có thể toggle giữa 2 chế độ
- **Pull to refresh**: Kéo xuống để refresh
- **Empty state**: Hiển thị khi không có ghi chú
- **Loading state**: Hiển thị khi đang load

---

### 3.2. Implementation

```dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/note_model.dart';
import '../../viewmodels/note_provider.dart';
import '../../views/screens/note_detail_screen.dart';
import '../../constants/app_constants.dart';
import '../../utils/helpers.dart';

enum ViewMode { list, grid }

class NoteListWidget extends StatefulWidget {
  const NoteListWidget({super.key});

  @override
  State<NoteListWidget> createState() => _NoteListWidgetState();
}

class _NoteListWidgetState extends State<NoteListWidget> {
  ViewMode _viewMode = ViewMode.list;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildViewModeToggle(),
        Expanded(
          child: Consumer<NoteProvider>(
            builder: (context, noteProvider, child) {
              if (noteProvider.isLoading) {
                return const Center(child: CircularProgressIndicator());
              }

              if (noteProvider.notes.isEmpty) {
                return _buildEmptyState();
              }

              return RefreshIndicator(
                onRefresh: () => noteProvider.loadNotes(),
                child: _viewMode == ViewMode.list
                    ? _buildListView(noteProvider.notes)
                    : _buildGridView(noteProvider.notes),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildViewModeToggle() {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimensions.paddingMedium,
        vertical: AppDimensions.paddingSmall,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          IconButton(
            icon: Icon(
              Icons.view_list,
              color: _viewMode == ViewMode.list
                  ? AppColors.primary
                  : AppColors.textSecondary,
            ),
            onPressed: () {
              setState(() {
                _viewMode = ViewMode.list;
              });
            },
          ),
          IconButton(
            icon: Icon(
              Icons.grid_view,
              color: _viewMode == ViewMode.grid
                  ? AppColors.primary
                  : AppColors.textSecondary,
            ),
            onPressed: () {
              setState(() {
                _viewMode = ViewMode.grid;
              });
            },
          ),
        ],
      ),
    );
  }

  Widget _buildListView(List<NoteModel> notes) {
    return ListView.builder(
      padding: const EdgeInsets.all(AppDimensions.paddingMedium),
      itemCount: notes.length,
      itemBuilder: (context, index) {
        final note = notes[index];
        return _buildNoteCard(note);
      },
    );
  }

  Widget _buildGridView(List<NoteModel> notes) {
    return GridView.builder(
      padding: const EdgeInsets.all(AppDimensions.paddingMedium),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: AppDimensions.paddingSmall,
        mainAxisSpacing: AppDimensions.paddingSmall,
        childAspectRatio: 0.8,
      ),
      itemCount: notes.length,
      itemBuilder: (context, index) {
        final note = notes[index];
        return _buildNoteCard(note);
      },
    );
  }

  Widget _buildNoteCard(NoteModel note) {
    return Card(
      elevation: AppDimensions.cardElevation,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
      ),
      child: InkWell(
        onTap: () => _navigateToDetail(note),
        borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
        child: Padding(
          padding: const EdgeInsets.all(AppDimensions.paddingMedium),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Title
              Text(
                note.title,
                style: AppTextStyles.titleSmall,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 8),

              // Content preview
              Text(
                StringHelper.getExcerpt(note.content, maxLength: 100),
                style: AppTextStyles.bodyMedium,
                maxLines: _viewMode == ViewMode.list ? 2 : 4,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 8),

              // Tag (if exists)
              if (note.tag != null && note.tag!.isNotEmpty)
                Chip(
                  label: Text(
                    note.tag!,
                    style: const TextStyle(fontSize: 12),
                  ),
                  padding: EdgeInsets.zero,
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),

              const Spacer(),

              // Date
              Text(
                DateTimeHelper.formatDateTime(note.updatedAt),
                style: AppTextStyles.caption,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.note_add,
            size: 80,
            color: AppColors.textHint,
          ),
          const SizedBox(height: 16),
          Text(
            AppStrings.emptyNotes,
            style: AppTextStyles.titleMedium,
          ),
          const SizedBox(height: 8),
          Text(
            AppStrings.emptyNotesSubtitle,
            style: AppTextStyles.bodyMedium,
          ),
        ],
      ),
    );
  }

  void _navigateToDetail(NoteModel note) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => NoteDetailScreen(note: note),
      ),
    );
  }
}
```

---

## PHẦN 4: HOÀN THIỆN HOME SCREEN

### 4.1. Updated Home Screen

```dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../viewmodels/note_provider.dart';
import '../../viewmodels/auth_provider.dart';
import '../../constants/app_constants.dart';
import '../../views/screens/add_edit_note_screen.dart';
import '../widgets/search_bar_widget.dart';
import '../widgets/note_list_widget.dart';
import '../widgets/filter_bottom_sheet.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<NoteProvider>(context, listen: false).loadNotes();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(),
      body: Column(
        children: [
          const SearchBarWidget(),
          Expanded(
            child: const NoteListWidget(),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _navigateToAddNote,
        child: const Icon(Icons.add),
        tooltip: 'Thêm ghi chú',
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      title: Consumer<AuthProvider>(
        builder: (context, authProvider, child) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(AppStrings.homeTitle),
              if (authProvider.currentUser != null)
                Text(
                  'Xin chào, ${authProvider.currentUser!.username}',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.normal,
                  ),
                ),
            ],
          );
        },
      ),
      actions: [
        // Filter button
        IconButton(
          icon: const Icon(Icons.filter_list),
          onPressed: () => showFilterBottomSheet(context),
          tooltip: 'Lọc & sắp xếp',
        ),

        // Logout button
        IconButton(
          icon: const Icon(Icons.logout),
          onPressed: _handleLogout,
          tooltip: 'Đăng xuất',
        ),
      ],
    );
  }

  void _navigateToAddNote() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const AddEditNoteScreen(),
      ),
    );
  }

  Future<void> _handleLogout() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Đăng xuất'),
        content: const Text('Bạn có chắc muốn đăng xuất?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Hủy'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Đăng xuất'),
          ),
        ],
      ),
    );

    if (confirm == true && mounted) {
      await Provider.of<AuthProvider>(context, listen: false).logout();
      if (mounted) {
        Navigator.of(context).pushReplacementNamed('/login');
      }
    }
  }
}
```

---

## PHẦN 5: ADVANCED FEATURES (OPTIONAL)

### 5.1. Multi-select & Batch Delete

```dart
// Thêm vào NoteListWidget
bool _isSelectionMode = false;
Set<int> _selectedNoteIds = {};

// Toggle selection mode
void _toggleSelectionMode() {
  setState(() {
    _isSelectionMode = !_isSelectionMode;
    if (!_isSelectionMode) {
      _selectedNoteIds.clear();
    }
  });
}

// Long press to enter selection mode
onLongPress: () {
  setState(() {
    _isSelectionMode = true;
    _selectedNoteIds.add(note.id!);
  });
}

// Batch delete
Future<void> _batchDelete() async {
  final noteProvider = Provider.of<NoteProvider>(context, listen: false);
  for (final id in _selectedNoteIds) {
    await noteProvider.deleteNote(id);
  }
  setState(() {
    _isSelectionMode = false;
    _selectedNoteIds.clear();
  });
}
```

---

### 5.2. Search History

```dart
// Lưu search history vào SharedPreferences
class SearchHistory {
  static const String _key = 'search_history';
  static const int _maxHistory = 10;

  static Future<void> addSearch(String query) async {
    final prefs = await SharedPreferences.getInstance();
    List<String> history = prefs.getStringList(_key) ?? [];
    
    history.remove(query); // Remove duplicate
    history.insert(0, query); // Add to top
    
    if (history.length > _maxHistory) {
      history = history.take(_maxHistory).toList();
    }
    
    await prefs.setStringList(_key, history);
  }

  static Future<List<String>> getHistory() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList(_key) ?? [];
  }
}
```

---

## PHẦN 6: TESTING

### 6.1. Widget Test cho SearchBarWidget

```dart
testWidgets('SearchBar should filter notes on text input', (tester) async {
  // Setup
  await tester.pumpWidget(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => MockNoteProvider()),
      ],
      child: MaterialApp(
        home: Scaffold(
          body: SearchBarWidget(),
        ),
      ),
    ),
  );

  // Find search field
  final searchField = find.byType(TextField);
  expect(searchField, findsOneWidget);

  // Enter text
  await tester.enterText(searchField, 'test');
  await tester.pump(const Duration(milliseconds: 300));

  // Verify search was called
  // ...
});
```

---

## PHẦN 7: PERFORMANCE OPTIMIZATION

### 7.1. ListView Optimization

```dart
// Sử dụng ListView.builder thay vì ListView
// → Chỉ build widget khi cần (lazy loading)

// Sử dụng const widgets khi có thể
const SizedBox(height: 8)

// Cache image/icon nếu có
```

### 7.2. Search Debouncing

Đã implement ở phần 1.3.B

---

## SUMMARY - TÓM TẮT

**Bảo làm gì**:
1. ✅ SearchBarWidget với debouncing
2. ✅ FilterBottomSheet với sort & filter
3. ✅ NoteListWidget với list/grid view
4. ✅ Hoàn thiện HomeScreen
5. ✅ Pull-to-refresh
6. ✅ Empty states

**Output cuối cùng**:
- Home screen hoàn chỉnh, đẹp mắt
- Search real-time mượt mà
- Filter & sort functionality
- Responsive UI

**Thời gian ước tính**: 2 tuần
