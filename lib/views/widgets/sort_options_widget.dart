import 'package:flutter/material.dart';
import '../../viewmodels/note_provider.dart';

class SortOptionsWidget extends StatelessWidget {
  final NoteSortOption value;
  final ValueChanged<NoteSortOption> onChanged;

  const SortOptionsWidget({
    super.key,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        RadioListTile<NoteSortOption>(
          title: const Text('Ngày sửa (mới nhất)'),
          value: NoteSortOption.dateModified,
          groupValue: value,
          onChanged: (v) => onChanged(v!),
        ),
        RadioListTile<NoteSortOption>(
          title: const Text('Ngày tạo (mới nhất)'),
          value: NoteSortOption.dateCreated,
          groupValue: value,
          onChanged: (v) => onChanged(v!),
        ),
        RadioListTile<NoteSortOption>(
          title: const Text('Tiêu đề (A-Z)'),
          value: NoteSortOption.titleAZ,
          groupValue: value,
          onChanged: (v) => onChanged(v!),
        ),
      ],
    );
  }
}
