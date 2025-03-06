import 'package:bills_reminder/data/services/bills_notification/bills_notification_service.dart';
import 'package:bills_reminder/domain/models/bill.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class BillsNotificationServiceLocal implements BillsNotificationService {
  BillsNotificationServiceLocal();

  final _notifications = FlutterLocalNotificationsPlugin();

  Future<void> initialize() async {
    tz.initializeTimeZones();

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
    // TODO: Use the bill date in the final version.
    final date = tz.TZDateTime.from(
      DateTime.now().add(const Duration(seconds: 5)),
      tz.local,
    );

    await _notifications.zonedSchedule(
      bill.id,
      bill.name,
      '${bill.name} payment of ${bill.value} is due',
      date,
      NotificationDetails(
        android: AndroidNotificationDetails(
          'bills_channel',
          'Bills Notifications',
          channelDescription: 'Notifications for bill payments',
          importance: Importance.high,
        ),
        iOS: const DarwinNotificationDetails(),
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
