import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../viewmodels/note_provider.dart';
import '../../constants/app_constants.dart';
import 'sort_options_widget.dart';

class FilterBottomSheet extends StatefulWidget {
  const FilterBottomSheet({super.key});

  @override
  State<FilterBottomSheet> createState() => _FilterBottomSheetState();
}

class _FilterBottomSheetState extends State<FilterBottomSheet> {
  late NoteSortOption _sort;
  String? _selectedTag;
  List<String> _tags = [];

  @override
  void initState() {
    super.initState();
    final p = Provider.of<NoteProvider>(context, listen: false);
    _sort = p.sortOption;
    _selectedTag = p.selectedTag;
    _tags = p.getAvailableTags();
  }

  @override
  Widget build(BuildContext context) {
    final p = Provider.of<NoteProvider>(context, listen: false);

    return SafeArea(
      child: SingleChildScrollView(
        padding: EdgeInsets.only(
          left: AppDimensions.paddingLarge,
          right: AppDimensions.paddingLarge,
          top: AppDimensions.paddingMedium,
          bottom: MediaQuery.of(context).viewInsets.bottom +
              AppDimensions.paddingLarge,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Lọc & Sắp xếp', style: AppTextStyles.titleMedium),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                )
              ],
            ),
            const SizedBox(height: 8),

            Text('SẮP XẾP', style: AppTextStyles.titleSmall),
            SortOptionsWidget(
              value: _sort,
              onChanged: (v) => setState(() => _sort = v),
            ),

            const SizedBox(height: 8),
            Text('LỌC THEO TAG', style: AppTextStyles.titleSmall),
            const SizedBox(height: 8),

            if (_tags.isEmpty)
              const Text('Chưa có tag nào', style: AppTextStyles.bodyMedium)
            else
              Column(
                children: _tags.map((tag) {
                  final count =
                      p.allNotes.where((n) => (n.tag ?? '') == tag).length;

                  return CheckboxListTile(
                    title: Text('$tag ($count)'),
                    value: _selectedTag == tag,
                    onChanged: (checked) {
                      setState(() {
                        _selectedTag = checked == true ? tag : null;
                      });
                    },
                    contentPadding: EdgeInsets.zero,
                    controlAffinity: ListTileControlAffinity.leading,
                  );
                }).toList(),
              ),

            const SizedBox(height: 16),

            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      p.clearAllFilters();
                      Navigator.pop(context);
                    },
                    child: const Text('Reset'),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () async {
                      await p.filterByTag(_selectedTag);
                      p.setSortOption(_sort);

                      if (context.mounted) Navigator.pop(context);
                    },
                    child: const Text('Áp dụng'),
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}

void showFilterBottomSheet(BuildContext context) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(
        top: Radius.circular(AppDimensions.radiusLarge),
      ),
    ),
    builder: (_) => const FilterBottomSheet(),
  );
}
