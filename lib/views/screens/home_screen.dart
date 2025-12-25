import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../viewmodels/note_provider.dart';
import '../../viewmodels/auth_provider.dart';
import '../../constants/app_constants.dart';
import 'note_detail_screen.dart';
import 'add_edit_note_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();

    // Load danh sách ghi chú khi Home vừa mở
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<NoteProvider>(context, listen: false).loadNotes();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _openFilterSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (_) => const _HomeFilterSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.homeTitle),
        actions: [
          // Đăng xuất
          Consumer<AuthProvider>(
            builder: (context, authProvider, child) {
              return IconButton(
                icon: const Icon(Icons.logout),
                onPressed: () async {
                  await authProvider.logout();
                  if (context.mounted) {
                    Navigator.of(context).pushReplacementNamed('/login');
                  }
                },
              );
            },
          ),
        ],
      ),
      body: Consumer<NoteProvider>(
        builder: (context, noteProvider, child) {
          if (noteProvider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          // Danh sách hiển thị trên Home (đã áp dụng search/tag + lọc ngày + sort)
          final notes = noteProvider.homeNotes;

          return Column(
            children: [
              // Thanh tìm kiếm + nút mở bộ lọc
              Padding(
                padding: const EdgeInsets.all(AppDimensions.paddingMedium),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _searchController,
                        onChanged: (v) => noteProvider.searchNotes(v),
                        decoration: InputDecoration(
                          hintText: AppStrings.searchHint,
                          prefixIcon: const Icon(Icons.search),
                          suffixIcon: _searchController.text.isNotEmpty
                              ? IconButton(
                                  icon: const Icon(Icons.close),
                                  onPressed: () {
                                    _searchController.clear();
                                    noteProvider.searchNotes('');
                                    setState(() {});
                                  },
                                )
                              : null,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    IconButton(
                      icon: const Icon(Icons.tune),
                      tooltip: 'Filter & Sort',
                      onPressed: () => _openFilterSheet(context),
                    ),
                  ],
                ),
              ),

              // Khu vực danh sách ghi chú / empty state
              Expanded(
                child: notes.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              noteProvider.homeHasActiveFilters
                                  ? Icons.search_off
                                  : Icons.note_add,
                              size: 80,
                              color: AppColors.textHint,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              noteProvider.homeHasActiveFilters
                                  ? 'Không có kết quả phù hợp'
                                  : AppStrings.emptyNotes,
                              style: AppTextStyles.titleMedium,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              noteProvider.homeHasActiveFilters
                                  ? 'Thử đổi từ khóa hoặc bộ lọc'
                                  : AppStrings.emptyNotesSubtitle,
                              style: AppTextStyles.bodyMedium,
                              textAlign: TextAlign.center,
                            ),
                            if (noteProvider.homeHasActiveFilters) ...[
                              const SizedBox(height: 16),
                              ElevatedButton(
                                onPressed: () {
                                  _searchController.clear();
                                  noteProvider.clearHomeFilters();
                                  setState(() {});
                                },
                                child: const Text('Xóa bộ lọc'),
                              ),
                            ],
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding:
                            const EdgeInsets.all(AppDimensions.paddingMedium),
                        itemCount: notes.length,
                        itemBuilder: (context, index) {
                          final note = notes[index];
                          return Card(
                            margin: const EdgeInsets.only(
                              bottom: AppDimensions.paddingMedium,
                            ),
                            child: ListTile(
                              title: Text(
                                note.title,
                                style: AppTextStyles.titleSmall,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              subtitle: Text(
                                note.content,
                                style: AppTextStyles.bodyMedium,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                              trailing: const Icon(Icons.chevron_right),
                              onTap: () {
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        NoteDetailScreen(note: note),
                                  ),
                                );
                              },
                            ),
                          );
                        },
                      ),
              ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => const AddEditNoteScreen(),
            ),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}

class _HomeFilterSheet extends StatefulWidget {
  const _HomeFilterSheet();

  @override
  State<_HomeFilterSheet> createState() => _HomeFilterSheetState();
}

class _HomeFilterSheetState extends State<_HomeFilterSheet> {
  late TextEditingController _tagController;

  DateTime? _from;
  DateTime? _to;
  NoteSortOption _sort = NoteSortOption.newest;

  @override
  void initState() {
    super.initState();

    // Lấy trạng thái filter hiện tại để hiển thị lên UI
    final p = Provider.of<NoteProvider>(context, listen: false);
    _tagController = TextEditingController(text: p.selectedTag ?? '');
    _from = p.createdFrom;
    _to = p.createdTo;
    _sort = p.sortOption;
  }

  @override
  void dispose() {
    _tagController.dispose();
    super.dispose();
  }

  String _fmt(DateTime d) => '${d.day}/${d.month}/${d.year}';

  @override
  Widget build(BuildContext context) {
    final p = Provider.of<NoteProvider>(context, listen: false);

    // Padding để sheet không bị dính sát đáy và không sát mép
    return SafeArea(
      child: Padding(
        padding: EdgeInsets.only(
          left: 16,
          right: 16,
          top: 12,
          bottom: MediaQuery.of(context).viewInsets.bottom + 24,
        ),
        child: Container(
          margin: const EdgeInsets.only(bottom: 12),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Bộ lọc & Sắp xếp',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),

              // Sort
              DropdownButtonFormField<NoteSortOption>(
                value: _sort,
                decoration: const InputDecoration(
                  labelText: 'Sắp xếp',
                  prefixIcon: Icon(Icons.sort),
                ),
                items: const [
                  DropdownMenuItem(
                    value: NoteSortOption.newest,
                    child: Text('Newest (mới nhất)'),
                  ),
                  DropdownMenuItem(
                    value: NoteSortOption.oldest,
                    child: Text('Oldest (cũ nhất)'),
                  ),
                  DropdownMenuItem(
                    value: NoteSortOption.titleAZ,
                    child: Text('Tiêu đề A-Z'),
                  ),
                  DropdownMenuItem(
                    value: NoteSortOption.titleZA,
                    child: Text('Tiêu đề Z-A'),
                  ),
                ],
                onChanged: (v) {
                  if (v != null) setState(() => _sort = v);
                },
              ),
              const SizedBox(height: 12),

              // Tag/Category (dùng note.tag)
              TextField(
                controller: _tagController,
                decoration: const InputDecoration(
                  labelText: 'Category/Tag',
                  hintText: 'Ví dụ: work, personal...',
                  prefixIcon: Icon(Icons.label),
                ),
              ),
              const SizedBox(height: 12),

              // Lọc theo ngày tạo (createdAt)
              OutlinedButton.icon(
                icon: const Icon(Icons.date_range),
                label: Text(
                  (_from == null && _to == null)
                      ? 'Chọn khoảng ngày tạo'
                      : (_from != null && _to != null)
                          ? '${_fmt(_from!)} → ${_fmt(_to!)}'
                          : (_from != null)
                              ? 'Từ ${_fmt(_from!)}'
                              : 'Đến ${_fmt(_to!)}',
                ),
                onPressed: () async {
                  final now = DateTime.now();
                  final picked = await showDateRangePicker(
                    context: context,
                    firstDate: DateTime(2000),
                    lastDate: DateTime(2100),
                    initialDateRange: (_from != null && _to != null)
                        ? DateTimeRange(start: _from!, end: _to!)
                        : DateTimeRange(
                            start: now.subtract(const Duration(days: 7)),
                            end: now,
                          ),
                  );

                  if (picked != null) {
                    setState(() {
                      _from = picked.start;
                      _to = picked.end;
                    });
                  }
                },
              ),
              const SizedBox(height: 16),

              Row(
                children: [
                  TextButton(
                    onPressed: () {
                      setState(() {
                        _tagController.clear();
                        _from = null;
                        _to = null;
                        _sort = NoteSortOption.newest;
                      });
                    },
                    child: const Text('Reset'),
                  ),
                  const Spacer(),
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Hủy'),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: () async {
                      final tag = _tagController.text.trim();

                      await p.filterByTag(tag.isEmpty ? null : tag);
                      p.setCreatedDateRange(from: _from, to: _to);
                      p.setSortOption(_sort);

                      if (context.mounted) Navigator.pop(context);
                    },
                    child: const Text('Áp dụng'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
