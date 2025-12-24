# CHI TIẾT CÔNG VIỆC - KHÁNH

## 🎯 VAI TRÒ: UI/UX Components + Theme + Animations

---

## TỔNG QUAN NHIỆM VỤ

Khánh chịu trách nhiệm xây dựng tất cả các **widget tái sử dụng** (Data Templates trong MVVM), thiết kế **theme** thống nhất cho toàn bộ app, và thêm các **animations** để nâng cao trải nghiệm người dùng.

**Files cần tạo**:
```
lib/views/widgets/note_card_widget.dart
lib/views/widgets/tag_chip_widget.dart
lib/views/widgets/empty_state_widget.dart
lib/views/widgets/loading_widget.dart
lib/views/widgets/confirmation_dialog.dart
lib/config/app_theme.dart
lib/views/screens/splash_screen.dart
lib/animations/fade_animation.dart
lib/animations/slide_animation.dart
```

---

## PHẦN 1: REUSABLE WIDGETS (Data Templates)

### 1.1. NOTE CARD WIDGET

**Mô tả**: Widget hiển thị một ghi chú trong danh sách, có thể dùng ở nhiều nơi.

#### A. Design Variations

```
┌─────────────────────────────────┐
│  📝 Tiêu đề ghi chú             │
│                                 │
│  Đây là trích đoạn nội dung...  │
│                                 │
│  [work]    📅 24/12/2025        │
└─────────────────────────────────┘

Compact Mode

┌─────────────────────────────────┐
│  ┌─┐                            │
│  │📝│ Tiêu đề ghi chú   [work]  │
│  └─┘ 24/12/2025                 │
└─────────────────────────────────┘

Grid Mode (Square)

┌──────────────┐
│              │
│ Tiêu đề      │
│              │
│ Nội dung...  │
│              │
│ [work]       │
│ 24/12/2025   │
└──────────────┘
```

#### B. Implementation

```dart
import 'package:flutter/material.dart';
import '../../models/note_model.dart';
import '../../constants/app_constants.dart';
import '../../utils/helpers.dart';
import 'tag_chip_widget.dart';

enum NoteCardStyle {
  standard,  // Default card với đầy đủ thông tin
  compact,   // Compact, 1-2 lines
  grid,      // Grid view, square
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
            ? BorderSide(color: AppColors.primary, width: 2)
            : BorderSide.none,
      ),
      child: InkWell(
        onTap: onTap,
        onLongPress: onLongPress,
        borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
        child: Padding(
          padding: const EdgeInsets.all(AppDimensions.paddingMedium),
          child: _buildContent(context),
        ),
      ),
    );
  }

  Widget _buildContent(BuildContext context) {
    switch (style) {
      case NoteCardStyle.standard:
        return _buildStandardContent();
      case NoteCardStyle.compact:
        return _buildCompactContent();
      case NoteCardStyle.grid:
        return _buildGridContent();
    }
  }

  Widget _buildStandardContent() {
    return Column(
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
          maxLines: 3,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 12),

        // Bottom row: Tag + Date
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            if (note.tag != null && note.tag!.isNotEmpty)
              TagChipWidget(tag: note.tag!),
            const Spacer(),
            Row(
              children: [
                Icon(
                  Icons.access_time,
                  size: 14,
                  color: AppColors.textSecondary,
                ),
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

  Widget _buildCompactContent() {
    return Row(
      children: [
        // Icon
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: AppColors.primaryLight,
            borderRadius: BorderRadius.circular(AppDimensions.radiusSmall),
          ),
          child: const Icon(
            Icons.note,
            color: AppColors.primary,
          ),
        ),
        const SizedBox(width: 12),

        // Content
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      note.title,
                      style: AppTextStyles.titleSmall,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  if (note.tag != null && note.tag!.isNotEmpty)
                    TagChipWidget(tag: note.tag!, size: TagChipSize.small),
                ],
              ),
              Text(
                DateTimeHelper.formatDateTime(note.updatedAt),
                style: AppTextStyles.caption,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildGridContent() {
    return Column(
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

        // Content
        Expanded(
          child: Text(
            StringHelper.getExcerpt(note.content, maxLength: 80),
            style: AppTextStyles.bodyMedium,
            maxLines: 4,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        const SizedBox(height: 8),

        // Tag
        if (note.tag != null && note.tag!.isNotEmpty)
          TagChipWidget(tag: note.tag!, size: TagChipSize.small),

        // Date
        Text(
          DateTimeHelper.formatDateShort(note.updatedAt),
          style: AppTextStyles.caption,
        ),
      ],
    );
  }
}
```

---

### 1.2. TAG CHIP WIDGET

**Mô tả**: Widget hiển thị tag (label) của ghi chú.

```dart
import 'package:flutter/material.dart';
import '../../constants/app_constants.dart';

enum TagChipSize {
  small,
  medium,
  large,
}

class TagChipWidget extends StatelessWidget {
  final String tag;
  final TagChipSize size;
  final VoidCallback? onTap;
  final VoidCallback? onDelete;
  final Color? backgroundColor;
  final Color? textColor;

  const TagChipWidget({
    super.key,
    required this.tag,
    this.size = TagChipSize.medium,
    this.onTap,
    this.onDelete,
    this.backgroundColor,
    this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    final config = _getConfigForSize();

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: config['paddingH'],
          vertical: config['paddingV'],
        ),
        decoration: BoxDecoration(
          color: backgroundColor ?? AppColors.primaryLight,
          borderRadius: BorderRadius.circular(config['radius']),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.label,
              size: config['iconSize'],
              color: textColor ?? AppColors.primary,
            ),
            SizedBox(width: config['spacing']),
            Text(
              tag,
              style: TextStyle(
                fontSize: config['fontSize'],
                color: textColor ?? AppColors.primary,
                fontWeight: FontWeight.w500,
              ),
            ),
            if (onDelete != null) ...[
              SizedBox(width: config['spacing']),
              GestureDetector(
                onTap: onDelete,
                child: Icon(
                  Icons.close,
                  size: config['iconSize'],
                  color: textColor ?? AppColors.primary,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Map<String, double> _getConfigForSize() {
    switch (size) {
      case TagChipSize.small:
        return {
          'paddingH': 8.0,
          'paddingV': 4.0,
          'radius': 12.0,
          'iconSize': 12.0,
          'fontSize': 10.0,
          'spacing': 4.0,
        };
      case TagChipSize.medium:
        return {
          'paddingH': 12.0,
          'paddingV': 6.0,
          'radius': 16.0,
          'iconSize': 16.0,
          'fontSize': 12.0,
          'spacing': 6.0,
        };
      case TagChipSize.large:
        return {
          'paddingH': 16.0,
          'paddingV': 8.0,
          'radius': 20.0,
          'iconSize': 20.0,
          'fontSize': 14.0,
          'spacing': 8.0,
        };
    }
  }
}

// Predefined tag colors
class TagColors {
  static const Map<String, Color> colors = {
    'work': Colors.blue,
    'personal': Colors.green,
    'study': Colors.purple,
    'important': Colors.red,
    'idea': Colors.orange,
  };

  static Color getColorForTag(String tag) {
    return colors[tag.toLowerCase()] ?? AppColors.primary;
  }
}
```

---

### 1.3. EMPTY STATE WIDGET

**Mô tả**: Widget hiển thị khi không có dữ liệu.

```dart
import 'package:flutter/material.dart';
import '../../constants/app_constants.dart';

class EmptyStateWidget extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final String? actionText;
  final VoidCallback? onAction;

  const EmptyStateWidget({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    this.actionText,
    this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppDimensions.paddingLarge),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Icon với animation
            TweenAnimationBuilder<double>(
              duration: const Duration(milliseconds: 600),
              tween: Tween(begin: 0.0, end: 1.0),
              builder: (context, value, child) {
                return Transform.scale(
                  scale: value,
                  child: Opacity(
                    opacity: value,
                    child: child,
                  ),
                );
              },
              child: Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  color: AppColors.primaryLight.withOpacity(0.3),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  icon,
                  size: 60,
                  color: AppColors.primary,
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Title
            Text(
              title,
              style: AppTextStyles.titleMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),

            // Subtitle
            Text(
              subtitle,
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),

            // Action button
            if (actionText != null && onAction != null) ...[
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: onAction,
                icon: const Icon(Icons.add),
                label: Text(actionText!),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

// Predefined empty states
class EmptyStates {
  static Widget noNotes({VoidCallback? onAdd}) {
    return EmptyStateWidget(
      icon: Icons.note_add,
      title: 'Chưa có ghi chú nào',
      subtitle: 'Nhấn nút + để tạo ghi chú đầu tiên',
      actionText: onAdd != null ? 'Tạo ghi chú' : null,
      onAction: onAdd,
    );
  }

  static Widget noSearchResults() {
    return const EmptyStateWidget(
      icon: Icons.search_off,
      title: 'Không tìm thấy kết quả',
      subtitle: 'Thử tìm kiếm với từ khóa khác',
    );
  }

  static Widget noFilterResults() {
    return const EmptyStateWidget(
      icon: Icons.filter_alt_off,
      title: 'Không có ghi chú phù hợp',
      subtitle: 'Thử điều chỉnh bộ lọc của bạn',
    );
  }
}
```

---

### 1.4. LOADING WIDGET

**Mô tả**: Widget hiển thị khi đang tải dữ liệu.

```dart
import 'package:flutter/material.dart';
import '../../constants/app_constants.dart';

enum LoadingStyle {
  circular,    // CircularProgressIndicator đơn giản
  spinner,     // Custom spinner
  shimmer,     // Shimmer effect
  overlay,     // Full screen overlay
}

class LoadingWidget extends StatelessWidget {
  final LoadingStyle style;
  final String? message;
  final Color? color;

  const LoadingWidget({
    super.key,
    this.style = LoadingStyle.circular,
    this.message,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    switch (style) {
      case LoadingStyle.circular:
        return _buildCircularLoading();
      case LoadingStyle.spinner:
        return _buildSpinnerLoading();
      case LoadingStyle.shimmer:
        return _buildShimmerLoading();
      case LoadingStyle.overlay:
        return _buildOverlayLoading(context);
    }
  }

  Widget _buildCircularLoading() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            color: color ?? AppColors.primary,
          ),
          if (message != null) ...[
            const SizedBox(height: 16),
            Text(
              message!,
              style: AppTextStyles.bodyMedium,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildSpinnerLoading() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: 50,
            height: 50,
            child: CircularProgressIndicator(
              strokeWidth: 3,
              color: color ?? AppColors.primary,
            ),
          ),
          if (message != null) ...[
            const SizedBox(height: 16),
            Text(
              message!,
              style: AppTextStyles.bodyMedium,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildShimmerLoading() {
    // Shimmer effect cho loading skeleton
    return ListView.builder(
      padding: const EdgeInsets.all(AppDimensions.paddingMedium),
      itemCount: 5,
      itemBuilder: (context, index) {
        return _ShimmerCard();
      },
    );
  }

  Widget _buildOverlayLoading(BuildContext context) {
    return Container(
      color: Colors.black54,
      child: Center(
        child: Card(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(
                  color: color ?? AppColors.primary,
                ),
                if (message != null) ...[
                  const SizedBox(height: 16),
                  Text(
                    message!,
                    style: AppTextStyles.bodyMedium,
                    textAlign: TextAlign.center,
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ShimmerCard extends StatefulWidget {
  @override
  State<_ShimmerCard> createState() => _ShimmerCardState();
}

class _ShimmerCardState extends State<_ShimmerCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildShimmerBox(width: 200, height: 20),
            const SizedBox(height: 8),
            _buildShimmerBox(width: double.infinity, height: 14),
            const SizedBox(height: 4),
            _buildShimmerBox(width: double.infinity, height: 14),
            const SizedBox(height: 8),
            _buildShimmerBox(width: 80, height: 12),
          ],
        ),
      ),
    );
  }

  Widget _buildShimmerBox({required double width, required double height}) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Container(
          width: width,
          height: height,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              colors: [
                Colors.grey[300]!,
                Colors.grey[100]!,
                Colors.grey[300]!,
              ],
              stops: [
                _controller.value - 0.3,
                _controller.value,
                _controller.value + 0.3,
              ],
            ),
            borderRadius: BorderRadius.circular(4),
          ),
        );
      },
    );
  }
}
```

---

### 1.5. CONFIRMATION DIALOG

**Mô tả**: Dialog xác nhận cho các hành động quan trọng.

```dart
import 'package:flutter/material.dart';
import '../../constants/app_constants.dart';

class ConfirmationDialog extends StatelessWidget {
  final String title;
  final String message;
  final String confirmText;
  final String cancelText;
  final VoidCallback? onConfirm;
  final VoidCallback? onCancel;
  final bool isDestructive;
  final IconData? icon;

  const ConfirmationDialog({
    super.key,
    required this.title,
    required this.message,
    this.confirmText = 'Xác nhận',
    this.cancelText = 'Hủy',
    this.onConfirm,
    this.onCancel,
    this.isDestructive = false,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
      ),
      title: Row(
        children: [
          if (icon != null) ...[
            Icon(
              icon,
              color: isDestructive ? AppColors.error : AppColors.primary,
            ),
            const SizedBox(width: 12),
          ],
          Expanded(
            child: Text(
              title,
              style: AppTextStyles.titleMedium,
            ),
          ),
        ],
      ),
      content: Text(
        message,
        style: AppTextStyles.bodyMedium,
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop(false);
            onCancel?.call();
          },
          child: Text(cancelText),
        ),
        ElevatedButton(
          onPressed: () {
            Navigator.of(context).pop(true);
            onConfirm?.call();
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: isDestructive ? AppColors.error : AppColors.primary,
          ),
          child: Text(confirmText),
        ),
      ],
    );
  }
}

// Helper function để show dialog
Future<bool> showConfirmationDialog({
  required BuildContext context,
  required String title,
  required String message,
  String confirmText = 'Xác nhận',
  String cancelText = 'Hủy',
  bool isDestructive = false,
  IconData? icon,
}) async {
  final result = await showDialog<bool>(
    context: context,
    builder: (context) => ConfirmationDialog(
      title: title,
      message: message,
      confirmText: confirmText,
      cancelText: cancelText,
      isDestructive: isDestructive,
      icon: icon,
    ),
  );
  return result ?? false;
}

// Predefined dialogs
class ConfirmationDialogs {
  static Future<bool> deleteNote(BuildContext context) {
    return showConfirmationDialog(
      context: context,
      title: 'Xóa ghi chú',
      message: 'Bạn có chắc muốn xóa ghi chú này? Hành động này không thể hoàn tác.',
      confirmText: 'Xóa',
      cancelText: 'Hủy',
      isDestructive: true,
      icon: Icons.delete,
    );
  }

  static Future<bool> logout(BuildContext context) {
    return showConfirmationDialog(
      context: context,
      title: 'Đăng xuất',
      message: 'Bạn có chắc muốn đăng xuất?',
      confirmText: 'Đăng xuất',
      cancelText: 'Hủy',
      icon: Icons.logout,
    );
  }

  static Future<bool> discardChanges(BuildContext context) {
    return showConfirmationDialog(
      context: context,
      title: 'Hủy thay đổi',
      message: 'Các thay đổi chưa được lưu sẽ bị mất',
      confirmText: 'Hủy thay đổi',
      cancelText: 'Tiếp tục chỉnh sửa',
      isDestructive: true,
      icon: Icons.warning,
    );
  }
}
```

---

## PHẦN 2: THEME CONFIGURATION

### 2.1. APP THEME

**File**: `lib/config/app_theme.dart`

```dart
import 'package:flutter/material.dart';
import '../constants/app_constants.dart';

class AppTheme {
  // Light Theme
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      
      // Color Scheme
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.primary,
        primary: AppColors.primary,
        secondary: AppColors.accent,
        error: AppColors.error,
        background: AppColors.background,
        surface: AppColors.cardBackground,
      ),

      // Scaffold
      scaffoldBackgroundColor: AppColors.background,

      // AppBar
      appBarTheme: const AppBarTheme(
        centerTitle: true,
        elevation: 0,
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        titleTextStyle: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),

      // Card
      cardTheme: CardTheme(
        elevation: AppDimensions.cardElevation,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
        ),
        color: AppColors.cardBackground,
      ),

      // FloatingActionButton
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 4,
      ),

      // ElevatedButton
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(
            horizontal: 24,
            vertical: 12,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppDimensions.radiusSmall),
          ),
          elevation: 2,
        ),
      ),

      // TextButton
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.primary,
          padding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 8,
          ),
        ),
      ),

      // OutlinedButton
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.primary,
          side: const BorderSide(color: AppColors.primary),
          padding: const EdgeInsets.symmetric(
            horizontal: 24,
            vertical: 12,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppDimensions.radiusSmall),
          ),
        ),
      ),

      // InputDecoration
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusSmall),
          borderSide: const BorderSide(color: AppColors.divider),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusSmall),
          borderSide: const BorderSide(color: AppColors.divider),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusSmall),
          borderSide: const BorderSide(color: AppColors.primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusSmall),
          borderSide: const BorderSide(color: AppColors.error),
        ),
        contentPadding: const EdgeInsets.all(AppDimensions.paddingMedium),
      ),

      // Divider
      dividerTheme: const DividerThemeData(
        color: AppColors.divider,
        thickness: 1,
        space: 1,
      ),

      // SnackBar
      snackBarTheme: SnackBarThemeData(
        backgroundColor: AppColors.textPrimary,
        contentTextStyle: const TextStyle(color: Colors.white),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusSmall),
        ),
        behavior: SnackBarBehavior.floating,
      ),

      // Dialog
      dialogTheme: DialogTheme(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
        ),
        elevation: 8,
      ),

      // Chip
      chipTheme: ChipThemeData(
        backgroundColor: AppColors.primaryLight,
        labelStyle: const TextStyle(
          color: AppColors.primary,
          fontSize: 12,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),

      // Text Theme
      textTheme: const TextTheme(
        displayLarge: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
        displayMedium: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
        displaySmall: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        headlineLarge: TextStyle(fontSize: 22, fontWeight: FontWeight.w600),
        headlineMedium: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
        headlineSmall: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
        titleLarge: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        titleMedium: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
        titleSmall: TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
        bodyLarge: TextStyle(fontSize: 16),
        bodyMedium: TextStyle(fontSize: 14),
        bodySmall: TextStyle(fontSize: 12),
        labelLarge: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
        labelMedium: TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
        labelSmall: TextStyle(fontSize: 10, fontWeight: FontWeight.w500),
      ),
    );
  }

  // Dark Theme (Optional - có thể implement sau)
  static ThemeData get darkTheme {
    // TODO: Implement dark theme
    return lightTheme;
  }
}
```

---

## PHẦN 3: SPLASH SCREEN

**Mô tả**: Màn hình chờ khi mở app, check authentication.

```dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../viewmodels/auth_provider.dart';
import '../../constants/app_constants.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    
    // Setup animations
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.5, curve: Curves.easeIn),
      ),
    );

    _scaleAnimation = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.5, curve: Curves.easeOut),
      ),
    );

    _controller.forward();

    // Check authentication and navigate
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    await authProvider.initialize();

    // Wait for animation to complete
    await Future.delayed(const Duration(milliseconds: 2000));

    if (!mounted) return;

    // Navigate based on auth status
    if (authProvider.isAuthenticated) {
      Navigator.of(context).pushReplacementNamed('/home');
    } else {
      Navigator.of(context).pushReplacementNamed('/login');
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primary,
      body: Center(
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            return FadeTransition(
              opacity: _fadeAnimation,
              child: ScaleTransition(
                scale: _scaleAnimation,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // App Icon
                    Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(30),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.2),
                            blurRadius: 20,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.note_alt,
                        size: 60,
                        color: AppColors.primary,
                      ),
                    ),
                    const SizedBox(height: 24),

                    // App Name
                    const Text(
                      AppStrings.appName,
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 8),

                    // Tagline
                    const Text(
                      'Ghi chú thông minh',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.white70,
                      ),
                    ),
                    const SizedBox(height: 48),

                    // Loading indicator
                    const SizedBox(
                      width: 40,
                      height: 40,
                      child: CircularProgressIndicator(
                        strokeWidth: 3,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
```

---

## PHẦN 4: ANIMATIONS

### 4.1. FADE ANIMATION

```dart
import 'package:flutter/material.dart';

class FadeAnimation extends StatelessWidget {
  final Widget child;
  final Duration duration;
  final Duration delay;
  final Curve curve;

  const FadeAnimation({
    super.key,
    required this.child,
    this.duration = const Duration(milliseconds: 500),
    this.delay = Duration.zero,
    this.curve = Curves.easeIn,
  });

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      duration: duration,
      tween: Tween(begin: 0.0, end: 1.0),
      curve: curve,
      builder: (context, value, child) {
        return FutureBuilder(
          future: Future.delayed(delay),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.done) {
              return Opacity(
                opacity: value,
                child: child,
              );
            }
            return const SizedBox.shrink();
          },
        );
      },
      child: child,
    );
  }
}
```

### 4.2. SLIDE ANIMATION

```dart
class SlideAnimation extends StatelessWidget {
  final Widget child;
  final Duration duration;
  final Duration delay;
  final Offset begin;
  final Offset end;
  final Curve curve;

  const SlideAnimation({
    super.key,
    required this.child,
    this.duration = const Duration(milliseconds: 500),
    this.delay = Duration.zero,
    this.begin = const Offset(0, 0.3),
    this.end = Offset.zero,
    this.curve = Curves.easeOut,
  });

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      duration: duration,
      tween: Tween(begin: 0.0, end: 1.0),
      curve: curve,
      builder: (context, value, child) {
        return FutureBuilder(
          future: Future.delayed(delay),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.done) {
              return Transform.translate(
                offset: Offset.lerp(begin, end, value)!,
                child: Opacity(
                  opacity: value,
                  child: child,
                ),
              );
            }
            return const SizedBox.shrink();
          },
        );
      },
      child: child,
    );
  }
}
```

---

## SUMMARY - TÓM TẮT

**Khánh làm gì**:
1. ✅ 5 reusable widgets (Note Card, Tag Chip, Empty State, Loading, Confirmation Dialog)
2. ✅ Theme configuration (AppTheme)
3. ✅ Splash screen với animations
4. ✅ Animation utilities (Fade, Slide)

**Output cuối cùng**:
- Component library hoàn chỉnh
- Theme thống nhất
- UX mượt mà với animations

**Thời gian ước tính**: 1-2 tuần
