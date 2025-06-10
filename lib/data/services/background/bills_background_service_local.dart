import 'package:bills_reminder/data/services/bills/bills_service.dart';
import 'package:bills_reminder/data/services/bills/bills_service_database.dart';
import 'package:bills_reminder/data/services/bills_notification/bills_notification_service_local.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:workmanager/workmanager.dart';

import 'bills_background_service.dart';

class BillsBackgroundServiceLocal implements BillsBackgroundService {
  // Negative values not to conflict with bill IDs.
  static final dailyReminderNotificationId = -1;
  static final dailyReminderUniqueName = 'daily-reminder';
  static final dailyReminderTaskName = 'Daily Reminder';

  static final _workManager = Workmanager();

  static Future<void> initialize() async {
    await _workManager.initialize(backgroundEntrypoint, isInDebugMode: true);
  }

  @override
  Future<void> registerDailyReminder() async {
    _workManager.registerPeriodicTask(
      dailyReminderUniqueName,
      dailyReminderTaskName,
      frequency: const Duration(minutes: 15),
      existingWorkPolicy: ExistingWorkPolicy.replace,
      backoffPolicy: BackoffPolicy.linear,
    );
  }
}

@pragma('vm:entry-point')
void backgroundEntrypoint() {
  BillsBackgroundServiceLocal._workManager.executeTask((task, inputData) async {
    if (task == BillsBackgroundServiceLocal.dailyReminderTaskName) {
      return await backgroundDailyReminder();
    }

    // For everything else, just mark the background task as complete.
    return Future.value(true);
  });
}

Future<bool> backgroundDailyReminder() async {
  BillsNotificationServiceLocal.initializeNotification();

  final notificationDetails = NotificationDetails(
    android: AndroidNotificationDetails(
      'reminder_channel',
      'Reminder Notifications',
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

  final BillsService database = BillsServiceDatabase();
  final now = DateTime.now();

  final bills = await database.getBills();
  final relevantBills = bills
      .where((bill) => bill.date.isBefore(now))
      .where((bill) => bill.paid == false)
      .toList();

  if (relevantBills.isEmpty) {
    debugPrint('No relevant bills found for notification.');
    return Future.value(true);
  }

  final billWord = relevantBills.length > 1 ? 'bills' : 'bill';

  await BillsNotificationServiceLocal.notification.show(
    BillsBackgroundServiceLocal.dailyReminderNotificationId,
    'Daily Reminder',
    'You have ${relevantBills.length} past due $billWord.',
    notificationDetails,
  );

  return Future.value(true);
}
