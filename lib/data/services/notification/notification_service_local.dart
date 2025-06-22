import 'dart:io';

import 'package:bills_reminder/data/services/notification/notification_service.dart';
import 'package:bills_reminder/domain/models/bill.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class NotificationServiceLocal implements NotificationService {
  static final _notification = FlutterLocalNotificationsPlugin();

  static Future<void> initializeTimezone() async {
    tz.initializeTimeZones();

    final timezone = await FlutterTimezone.getLocalTimezone();
    tz.setLocalLocation(tz.getLocation(timezone));
  }

  static Future<void> initializeNotification() async {
    const androidSettings = AndroidInitializationSettings(
      '@mipmap/launcher_icon',
    );
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    await _notification.initialize(
      const InitializationSettings(android: androidSettings, iOS: iosSettings),
    );
  }

  static Future<void> initializeNotificationPermissions() async {
    if (Platform.isAndroid) {
      final androidNotifications = _notification
          .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin
          >()!;

      await androidNotifications.requestNotificationsPermission();
      await androidNotifications.requestExactAlarmsPermission();
      await androidNotifications.createNotificationChannel(
        AndroidNotificationChannel(
          'bills_channel',
          'Bills Notifications',
          description: 'Notifications for bill payments',
          importance: Importance.max,
        ),
      );
    }
  }

  @override
  Future<void> schedule(Bill bill) async {
    final scheduledDate = tz.TZDateTime(
      tz.local,
      bill.date.year,
      bill.date.month,
      bill.date.day,
      8, // 8 AM
    );
    final date = scheduledDate.isBefore(DateTime.now())
        ? scheduledDate.add(const Duration(days: 1))
        : scheduledDate;

    final notificationDetails = NotificationDetails(
      android: AndroidNotificationDetails(
        'bills_channel',
        'Bills Notifications',
        channelDescription: 'Scheduled notifications for bill payments.',
        importance: Importance.max,
        priority: Priority.max,
      ),
      iOS: DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
        interruptionLevel: InterruptionLevel.timeSensitive,
      ),
    );

    await _notification.zonedSchedule(
      bill.id,
      bill.name,
      'Due today ${bill.value != null ? '(${bill.value})' : ''}',
      date,
      notificationDetails,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
    );
  }

  @override
  Future<void> show(Bill bill) async {
    final notificationDetails = NotificationDetails(
      android: AndroidNotificationDetails(
        'bills_channel',
        'Bills Notifications',
        channelDescription: 'Immediate notifications for bill payments.',
        importance: Importance.max,
        priority: Priority.max,
      ),
      iOS: DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      ),
    );

    final days = DateTime.now().difference(bill.date).inDays;
    final dayWord = days == 1 ? 'day' : 'days';

    final initialMessage = days <= 0
        ? 'Due today'
        : 'Overdue bill $days $dayWord late';

    await _notification.show(
      bill.id * -1, // Invert to avoid conflicts with scheduled notifications.
      bill.name,
      '$initialMessage ${bill.value != null ? '(${bill.value})' : ''}',
      notificationDetails,
    );
  }

  @override
  Future<void> cancel(Bill bill) async {
    await _notification.cancel(bill.id);
  }

  @override
  Future<void> cancelAll() async {
    await _notification.cancelAll();
  }
}
