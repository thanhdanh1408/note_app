import 'package:intl/intl.dart';

/// Helper functions - Các hàm tiện ích sử dụng trong ứng dụng

class DateTimeHelper {
  /// Format DateTime thành string hiển thị
  static String formatDateTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    // Nếu trong ngày hôm nay
    if (difference.inDays == 0) {
      if (difference.inHours == 0) {
        if (difference.inMinutes == 0) {
          return 'Vừa xong';
        }
        return '${difference.inMinutes} phút trước';
      }
      return '${difference.inHours} giờ trước';
    }

    // Nếu hôm qua
    if (difference.inDays == 1) {
      return 'Hôm qua ${DateFormat('HH:mm').format(dateTime)}';
    }

    // Nếu trong tuần này
    if (difference.inDays < 7) {
      return '${difference.inDays} ngày trước';
    }

    // Ngày cụ thể
    return DateFormat('dd/MM/yyyy HH:mm').format(dateTime);
  }

  /// Format ngày tháng ngắn gọn
  static String formatDateShort(DateTime dateTime) {
    return DateFormat('dd/MM/yyyy').format(dateTime);
  }

  /// Format giờ phút
  static String formatTime(DateTime dateTime) {
    return DateFormat('HH:mm').format(dateTime);
  }
}

class StringHelper {
  /// Cắt chuỗi với độ dài tối đa
  static String truncate(String text, int maxLength) {
    if (text.length <= maxLength) return text;
    return '${text.substring(0, maxLength)}...';
  }

  /// Kiểm tra chuỗi rỗng hoặc null
  static bool isNullOrEmpty(String? text) {
    return text == null || text.trim().isEmpty;
  }

  /// Lấy trích đoạn từ nội dung
  static String getExcerpt(String content, {int maxLength = 100}) {
    // Loại bỏ newline và khoảng trắng thừa
    final cleaned = content.replaceAll(RegExp(r'\s+'), ' ').trim();
    return truncate(cleaned, maxLength);
  }
}

class ValidationHelper {
  /// Validate tiêu đề
  static String? validateTitle(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Vui lòng nhập tiêu đề';
    }
    return null;
  }

  /// Validate nội dung
  static String? validateContent(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Vui lòng nhập nội dung';
    }
    return null;
  }
}
