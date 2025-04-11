import 'dart:io';
import 'package:bills_reminder/data/services/bills_notification/bills_notification_service.dart';
import 'package:bills_reminder/domain/models/bill.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class BillsNotificationServiceLocal implements BillsNotificationService {
  static final _notifications = FlutterLocalNotificationsPlugin();

  static Future<void> initialize() async {
    tz.initializeTimeZones();

    final timezone = await FlutterTimezone.getLocalTimezone();
    tz.setLocalLocation(tz.getLocation(timezone));

    const androidSettings = AndroidInitializationSettings(
      '@mipmap/ic_launcher',
    );
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    await _notifications.initialize(
      const InitializationSettings(android: androidSettings, iOS: iosSettings),
    );

    if (Platform.isAndroid) {
      final androidNotifications =
          _notifications
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
    final date =
        scheduledDate.isBefore(DateTime.now())
            ? scheduledDate.add(const Duration(days: 1))
            : scheduledDate;

    final notificationDetails = NotificationDetails(
      android: AndroidNotificationDetails(
        'bills_channel',
        'Bills Notifications',
        channelDescription: 'Notifications for bill payments',
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

    await _notifications.zonedSchedule(
      bill.id,
      bill.name,
      'Due today ${bill.value != null ? '(${bill.value})' : ''}',
      date,
      notificationDetails,
      androidScheduleMode: AndroidScheduleMode.alarmClock,
    );
  }

  @override
  Future<void> cancel(Bill bill) async {
    await _notifications.cancel(bill.id);
  }

  @override
  Future<void> cancelAll() async {
    await _notifications.cancelAll();
  }
}
