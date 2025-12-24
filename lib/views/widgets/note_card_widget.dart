import 'package:flutter/material.dart';
import '../../models/note_model.dart';
import '../../constants/app_constants.dart';
import '../../utils/helpers.dart';
import 'tag_chip_widget.dart';

enum NoteCardStyle {
  standard,
  compact,
  grid,
}

class NoteCardWidget extends StatelessWidget {
  final NoteModel note;
  final NoteCardStyle style;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final bool isSelected;

  const NoteCardWidget({
    super.key,
    required this.note,
    this.style = NoteCardStyle.standard,
    this.onTap,
    this.onLongPress,
    this.isSelected = false,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: isSelected ? 8 : AppDimensions.cardElevation,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
        side: isSelected
            ? const BorderSide(color: AppColors.primary, width: 2)
            : BorderSide.none,
      ),
      child: InkWell(
        onTap: onTap,
        onLongPress: onLongPress,
        borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
        child: Padding(
          padding: const EdgeInsets.all(AppDimensions.paddingMedium),
          child: _buildContent(),
        ),
      ),
    );
  }

  Widget _buildContent() {
    switch (style) {
      case NoteCardStyle.compact:
        return _buildCompact();
      case NoteCardStyle.grid:
        return _buildGrid();
      default:
        return _buildStandard();
    }
  }

  Widget _buildStandard() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          note.title,
          style: AppTextStyles.titleSmall,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 8),
        Text(
          StringHelper.getExcerpt(note.content, maxLength: 100),
          style: AppTextStyles.bodyMedium,
          maxLines: 3,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            if (note.tag?.isNotEmpty == true)
              TagChipWidget(tag: note.tag!),
            const Spacer(),
            Row(
              children: [
                const Icon(Icons.access_time, size: 14),
                const SizedBox(width: 4),
                Text(
                  DateTimeHelper.formatDateTime(note.updatedAt),
                  style: AppTextStyles.caption,
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildCompact() {
    return Row(
      children: [
        const Icon(Icons.note),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                note.title,
                style: AppTextStyles.titleSmall,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              Text(
                DateTimeHelper.formatDateTime(note.updatedAt),
                style: AppTextStyles.caption,
              ),
            ],
          ),
        ),
        if (note.tag?.isNotEmpty == true)
          TagChipWidget(tag: note.tag!, size: TagChipSize.small),
      ],
    );
  }

  Widget _buildGrid() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          note.title,
          style: AppTextStyles.titleSmall,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 8),
        Expanded(
          child: Text(
            StringHelper.getExcerpt(note.content, maxLength: 80),
            style: AppTextStyles.bodyMedium,
            maxLines: 4,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        if (note.tag?.isNotEmpty == true)
          TagChipWidget(tag: note.tag!, size: TagChipSize.small),
        Text(
          DateTimeHelper.formatDateShort(note.updatedAt),
          style: AppTextStyles.caption,
        ),
      ],
    );
  }
}
