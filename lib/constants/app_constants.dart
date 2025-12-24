import 'package:flutter/material.dart';

/// Constants - Hằng số sử dụng trong toàn bộ ứng dụng
/// Strings, Colors, Styles, Dimensions

class AppStrings {
  // App
  static const String appName = 'Note App';
  
  // Home Screen
  static const String homeTitle = 'Ghi Chú Của Tôi';
  static const String searchHint = 'Tìm kiếm ghi chú...';
  static const String emptyNotes = 'Chưa có ghi chú nào';
  static const String emptyNotesSubtitle = 'Nhấn nút + để tạo ghi chú mới';
  
  // Add/Edit Screen
  static const String addNote = 'Thêm Ghi Chú';
  static const String editNote = 'Chỉnh Sửa Ghi Chú';
  static const String titleHint = 'Tiêu đề';
  static const String contentHint = 'Nội dung ghi chú...';
  static const String tagHint = 'Tag (tùy chọn)';
  static const String save = 'Lưu';
  static const String cancel = 'Hủy';
  
  // Delete Confirmation
  static const String deleteTitle = 'Xóa Ghi Chú';
  static const String deleteMessage = 'Bạn có chắc chắn muốn xóa ghi chú này?';
  static const String delete = 'Xóa';
  
  // Validation
  static const String titleRequired = 'Vui lòng nhập tiêu đề';
  static const String contentRequired = 'Vui lòng nhập nội dung';
  
  // Messages
  static const String noteAdded = 'Đã thêm ghi chú';
  static const String noteUpdated = 'Đã cập nhật ghi chú';
  static const String noteDeleted = 'Đã xóa ghi chú';
  static const String error = 'Có lỗi xảy ra';
  
  // Sort Options
  static const String sortByDateCreated = 'Ngày tạo';
  static const String sortByDateModified = 'Ngày sửa';
  static const String sortByTitle = 'Tiêu đề';
}

class AppColors {
  // Primary Colors
  static const Color primary = Color(0xFF2196F3);
  static const Color primaryDark = Color(0xFF1976D2);
  static const Color primaryLight = Color(0xFFBBDEFB);
  
  // Accent Colors
  static const Color accent = Color(0xFFFF9800);
  
  // Background
  static const Color background = Color(0xFFF5F5F5);
  static const Color cardBackground = Colors.white;
  
  // Text Colors
  static const Color textPrimary = Color(0xFF212121);
  static const Color textSecondary = Color(0xFF757575);
  static const Color textHint = Color(0xFFBDBDBD);
  
  // Status Colors
  static const Color success = Color(0xFF4CAF50);
  static const Color error = Color(0xFFF44336);
  static const Color warning = Color(0xFFFF9800);
  
  // Divider
  static const Color divider = Color(0xFFE0E0E0);
}

class AppDimensions {
  // Padding
  static const double paddingSmall = 8.0;
  static const double paddingMedium = 16.0;
  static const double paddingLarge = 24.0;
  
  // Border Radius
  static const double radiusSmall = 8.0;
  static const double radiusMedium = 12.0;
  static const double radiusLarge = 16.0;
  
  // Icon Size
  static const double iconSmall = 20.0;
  static const double iconMedium = 24.0;
  static const double iconLarge = 32.0;
  
  // Card
  static const double cardElevation = 2.0;
  static const double cardHeight = 120.0;
}

class AppTextStyles {
  // Title Styles
  static const TextStyle titleLarge = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.bold,
    color: AppColors.textPrimary,
  );
  
  static const TextStyle titleMedium = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.bold,
    color: AppColors.textPrimary,
  );
  
  static const TextStyle titleSmall = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
  );
  
  // Body Styles
  static const TextStyle bodyLarge = TextStyle(
    fontSize: 16,
    color: AppColors.textPrimary,
  );
  
  static const TextStyle bodyMedium = TextStyle(
    fontSize: 14,
    color: AppColors.textSecondary,
  );
  
  static const TextStyle bodySmall = TextStyle(
    fontSize: 12,
    color: AppColors.textSecondary,
  );
  
  // Caption
  static const TextStyle caption = TextStyle(
    fontSize: 12,
    color: AppColors.textHint,
  );
}
