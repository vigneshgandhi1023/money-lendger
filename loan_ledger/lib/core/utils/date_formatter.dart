import 'package:intl/intl.dart';

/// Date formatting utilities for consistent date display.
class DateFormatter {
  DateFormatter._();

  /// Full date: 15 Jan 2025
  static String format(DateTime date) {
    return DateFormat('d MMM yyyy').format(date);
  }

  /// Short date: 15 Jan
  static String formatShort(DateTime date) {
    return DateFormat('d MMM').format(date);
  }

  /// Date with time: 15 Jan 2025, 3:30 PM
  static String formatWithTime(DateTime date) {
    return DateFormat('d MMM yyyy, h:mm a').format(date);
  }

  /// Relative date: Today, Yesterday, 2 days ago, 15 Jan
  static String formatRelative(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final dateOnly = DateTime(date.year, date.month, date.day);
    final difference = today.difference(dateOnly).inDays;

    if (difference == 0) return 'Today';
    if (difference == 1) return 'Yesterday';
    if (difference == -1) return 'Tomorrow';
    if (difference > 1 && difference <= 7) return '$difference days ago';
    if (difference < -1 && difference >= -7) return 'In ${-difference} days';
    return format(date);
  }

  /// Due date status text with urgency
  static String formatDueStatus(DateTime dueDate) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final due = DateTime(dueDate.year, dueDate.month, dueDate.day);
    final difference = due.difference(today).inDays;

    if (difference < 0) return 'Overdue by ${-difference} day${-difference == 1 ? '' : 's'}';
    if (difference == 0) return 'Due today';
    if (difference == 1) return 'Due tomorrow';
    if (difference <= 7) return 'Due in $difference days';
    return 'Due ${format(dueDate)}';
  }

  /// Month-year: January 2025
  static String formatMonthYear(DateTime date) {
    return DateFormat('MMMM yyyy').format(date);
  }

  /// ISO format for storage
  static String toIso(DateTime date) {
    return date.toIso8601String();
  }

  /// Parse from ISO
  static DateTime fromIso(String iso) {
    return DateTime.parse(iso);
  }

  /// Check if date is today
  static bool isToday(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year &&
        date.month == now.month &&
        date.day == now.day;
  }

  /// Check if date is overdue (before today)
  static bool isOverdue(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final dateOnly = DateTime(date.year, date.month, date.day);
    return dateOnly.isBefore(today);
  }
}
