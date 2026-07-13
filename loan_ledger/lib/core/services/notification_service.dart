import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;

import 'storage_service.dart';

/// Local notification service for due date reminders.
///
/// Handles scheduling and displaying notifications for:
/// - Loans due today
/// - Loans due tomorrow
/// - Overdue loans
class NotificationService {
  NotificationService._();

  static final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  static bool _initialized = false;

  /// Initialize the notification plugin.
  static Future<void> initialize() async {
    if (_initialized) return;

    tz.initializeTimeZones();

    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');

    const settings = InitializationSettings(
      android: androidSettings,
    );

    await _plugin.initialize(
      settings,
      onDidReceiveNotificationResponse: _onNotificationTapped,
    );

    _initialized = true;
  }

  /// Handle notification tap.
  static void _onNotificationTapped(NotificationResponse response) {
    // Navigation to specific loan/customer can be handled here
    // via the payload string.
  }

  /// Schedule daily due date check at 8:00 AM.
  static Future<void> scheduleDailyCheck() async {
    await _plugin.zonedSchedule(
      0,
      'Loan Ledger',
      'Checking for due and overdue loans...',
      _nextInstanceOfTime(8, 0),
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'daily_check',
          'Daily Due Check',
          channelDescription: 'Daily check for due and overdue loans',
          importance: Importance.high,
          priority: Priority.high,
          icon: '@mipmap/ic_launcher',
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      matchDateTimeComponents: DateTimeComponents.time,
    );
  }

  /// Show immediate notification for overdue loans.
  static Future<void> showOverdueNotification(int count) async {
    await _plugin.show(
      1,
      'Overdue Loans',
      '$count loan${count == 1 ? '' : 's'} overdue. Tap to view details.',
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'overdue',
          'Overdue Loans',
          channelDescription: 'Notifications for overdue loans',
          importance: Importance.max,
          priority: Priority.high,
          icon: '@mipmap/ic_launcher',
          color: Color(0xFFEF4444),
        ),
      ),
    );
  }

  /// Show notification for loans due today.
  static Future<void> showDueTodayNotification(int count) async {
    await _plugin.show(
      2,
      'Loans Due Today',
      '$count loan${count == 1 ? '' : 's'} due today.',
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'due_today',
          'Loans Due Today',
          channelDescription: 'Notifications for loans due today',
          importance: Importance.high,
          priority: Priority.high,
          icon: '@mipmap/ic_launcher',
          color: Color(0xFFF59E0B),
        ),
      ),
    );
  }

  /// Show notification for loans due tomorrow.
  static Future<void> showDueTomorrowNotification(int count) async {
    await _plugin.show(
      3,
      'Loans Due Tomorrow',
      '$count loan${count == 1 ? '' : 's'} due tomorrow.',
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'due_tomorrow',
          'Loans Due Tomorrow',
          channelDescription: 'Notifications for loans due tomorrow',
          importance: Importance.defaultImportance,
          priority: Priority.defaultPriority,
          icon: '@mipmap/ic_launcher',
        ),
      ),
    );
  }

  /// Check all loans and send appropriate notifications.
  static Future<void> checkAndNotify() async {
    final overdueLoans = StorageService.getOverdueLoans();
    if (overdueLoans.isNotEmpty) {
      await showOverdueNotification(overdueLoans.length);
    }

    final today = DateTime.now();
    final dueToday = StorageService.getActiveLoans().where((loan) {
      return loan.dueDate.year == today.year &&
          loan.dueDate.month == today.month &&
          loan.dueDate.day == today.day;
    }).toList();

    if (dueToday.isNotEmpty) {
      await showDueTodayNotification(dueToday.length);
    }

    final tomorrow = today.add(const Duration(days: 1));
    final dueTomorrow = StorageService.getActiveLoans().where((loan) {
      return loan.dueDate.year == tomorrow.year &&
          loan.dueDate.month == tomorrow.month &&
          loan.dueDate.day == tomorrow.day;
    }).toList();

    if (dueTomorrow.isNotEmpty) {
      await showDueTomorrowNotification(dueTomorrow.length);
    }
  }

  /// Cancel all scheduled notifications.
  static Future<void> cancelAll() async {
    await _plugin.cancelAll();
  }

  // ─── Helpers ───────────────────────────────────────────

  static tz.TZDateTime _nextInstanceOfTime(int hour, int minute) {
    final now = tz.TZDateTime.now(tz.local);
    var scheduled = tz.TZDateTime(tz.local, now.year, now.month, now.day, hour, minute);
    if (scheduled.isBefore(now)) {
      scheduled = scheduled.add(const Duration(days: 1));
    }
    return scheduled;
  }
}

/// A color constant for notification use (import-free).
class Color {
  final int value;
  const Color(this.value);
}
