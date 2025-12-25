import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../models/note_model.dart';
import '../../viewmodels/note_provider.dart';
import '../../commands/note_commands.dart';
import '../../constants/app_constants.dart';
import '../../utils/helpers.dart';
import 'add_edit_note_screen.dart';

/// Màn hình hiển thị chi tiết ghi chú
/// Với các action: Edit, Delete, Share
class NoteDetailScreen extends StatelessWidget {
  final NoteModel note;

  const NoteDetailScreen({
    super.key,
    required this.note,
  });

  /// Hiển thị dialog xác nhận xóa
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

  /// Xử lý xóa ghi chú
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

  /// Xử lý chia sẻ (copy to clipboard)
  void _handleShare(BuildContext context) {
    final shareText = '''
${note.title}

${note.content}

${note.tag != null && note.tag!.isNotEmpty ? 'Tag: ${note.tag}' : ''}
''';

    Clipboard.setData(ClipboardData(text: shareText.trim()));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Đã sao chép nội dung')),
    );
  }

  /// Navigate đến màn hình Edit
  void _navigateToEdit(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => AddEditNoteScreen(note: note),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(context),
      body: _buildBody(context),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      title: const Text('Chi tiết'),
      actions: [
        // Edit button
        IconButton(
          icon: const Icon(Icons.edit),
          tooltip: 'Chỉnh sửa',
          onPressed: () => _navigateToEdit(context),
        ),
        // Delete button
        IconButton(
          icon: const Icon(Icons.delete),
          tooltip: 'Xóa',
          onPressed: () => _showDeleteConfirmation(context),
        ),
        // Share button
        IconButton(
          icon: const Icon(Icons.share),
          tooltip: 'Chia sẻ',
          onPressed: () => _handleShare(context),
        ),
      ],
    );
  }

  Widget _buildBody(BuildContext context) {
    return SingleChildScrollView(
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
                backgroundColor: AppColors.primaryLight,
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
    );
  }

  Widget _buildMetadata() {
    return Container(
      padding: const EdgeInsets.all(AppDimensions.paddingMedium),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(AppDimensions.radiusSmall),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.calendar_today,
                  size: 16, color: AppColors.textSecondary),
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
              const Icon(Icons.edit, size: 16, color: AppColors.textSecondary),
              const SizedBox(width: 8),
              Text(
                'Sửa lần cuối: ${DateTimeHelper.formatDateTime(note.updatedAt)}',
                style: AppTextStyles.caption,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
