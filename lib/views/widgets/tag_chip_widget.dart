import 'package:flutter/material.dart';
import '../../constants/app_constants.dart';

enum TagChipSize { small, medium, large }

class TagChipWidget extends StatelessWidget {
  final String tag;
  final TagChipSize size;
  final VoidCallback? onTap;
  final VoidCallback? onDelete;

  const TagChipWidget({
    super.key,
    required this.tag,
    this.size = TagChipSize.medium,
    this.onTap,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final config = _config();

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: config['h']!,
          vertical: config['v']!,
        ),
        decoration: BoxDecoration(
          color: AppColors.primaryLight,
          borderRadius: BorderRadius.circular(config['r']!),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.label, size: 14),
            const SizedBox(width: 4),
            Text(tag, style: TextStyle(fontSize: config['f'])),
            if (onDelete != null) ...[
              const SizedBox(width: 4),
              GestureDetector(
                onTap: onDelete,
                child: const Icon(Icons.close, size: 14),
              ),
            ]
          ],
        ),
      ),
    );
  }

  Map<String, double> _config() {
    switch (size) {
      case TagChipSize.small:
        return {'h': 8, 'v': 4, 'r': 12, 'f': 10};
      case TagChipSize.large:
        return {'h': 16, 'v': 8, 'r': 20, 'f': 14};
      default:
        return {'h': 12, 'v': 6, 'r': 16, 'f': 12};
    }
  }
}
