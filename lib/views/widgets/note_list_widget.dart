import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../viewmodels/note_provider.dart';
import '../../constants/app_constants.dart';
import '../screens/note_detail_screen.dart';

class NoteListWidget extends StatelessWidget {
  const NoteListWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<NoteProvider>(
      builder: (context, noteProvider, child) {
        if (noteProvider.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        final notes = noteProvider.notes;

        if (notes.isEmpty) {
          final hasFilters = noteProvider.hasActiveFilters;
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  hasFilters ? Icons.search_off : Icons.note_add,
                  size: 80,
                  color: AppColors.textHint,
                ),
                const SizedBox(height: 16),
                Text(
                  hasFilters ? 'Không tìm thấy kết quả' : AppStrings.emptyNotes,
                  style: AppTextStyles.titleMedium,
                ),
                const SizedBox(height: 8),
                Text(
                  hasFilters
                      ? 'Thử đổi từ khóa hoặc bộ lọc'
                      : AppStrings.emptyNotesSubtitle,
                  style: AppTextStyles.bodyMedium,
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: () => noteProvider.loadNotes(),
          child: ListView.builder(
            padding: const EdgeInsets.all(AppDimensions.paddingMedium),
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
                        builder: (_) => NoteDetailScreen(note: note),
                      ),
                    );
                  },
                ),
              );
            },
          ),
        );
      },
    );
  }
}
