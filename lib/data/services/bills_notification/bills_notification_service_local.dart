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

    // If the scheduled date is in the past, schedule for the next day
    final date =
        scheduledDate.isBefore(DateTime.now())
            ? scheduledDate.add(const Duration(days: 1))
            : scheduledDate;

    // TODO: Consider using `periodicallyShow` to schedule the notification.
    await _notifications.zonedSchedule(
      bill.id,
      bill.name,
      'Value: ${bill.value}',
      date,
      NotificationDetails(
        android: AndroidNotificationDetails(
          'bills_channel',
          'Bills Notifications',
          channelDescription: 'Notifications for bill payments',
          importance: Importance.high,
          priority: Priority.max,
          ticker: 'ticker',
          subText: 'Value: ${bill.value}',
        ),
        iOS: DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
          interruptionLevel: InterruptionLevel.timeSensitive,
          subtitle: 'Value: ${bill.value}',
        ),
      ),
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
    );
  }

  @override
  Future<void> cancel(Bill bill) async {
    await _notifications.cancel(bill.id);
  }
}
