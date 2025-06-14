import 'package:bills_reminder/data/services/bills/bills_service_database.dart';
import 'package:bills_reminder/data/services/bills_notification/bills_notification_service_local.dart';
import 'package:flutter/material.dart';
import 'package:workmanager/workmanager.dart';

import 'bills_background_service.dart';

class BillsBackgroundServiceLocal implements BillsBackgroundService {
  static final dailyReminderUniqueName = 'daily-reminder';
  static final dailyReminderTaskName = 'Daily Reminder';
  static final oneTimeReminderUniqueName = 'one-time-reminder';
  static final oneTimeReminderTaskName = 'One Time Reminder';

  static final _workManager = Workmanager();

  static Future<void> initialize() async {
    await _workManager.initialize(backgroundEntrypoint, isInDebugMode: false);
  }

  @override
  Future<void> registerDailyReminder() async {
    final now = DateTime.now();
    final today9am = DateTime(now.year, now.month, now.day, 9);
    final next9am = today9am.isAfter(now)
        ? today9am
        : today9am.add(const Duration(days: 1));
    final initialDelay = next9am.difference(now);

    _workManager.cancelAll();
    _workManager.registerOneOffTask(
      BillsBackgroundServiceLocal.oneTimeReminderUniqueName,
      BillsBackgroundServiceLocal.oneTimeReminderTaskName,
    );
    _workManager.registerPeriodicTask(
      dailyReminderUniqueName,
      dailyReminderTaskName,
      frequency: const Duration(hours: 1),
      initialDelay: initialDelay,
      existingWorkPolicy: ExistingWorkPolicy.replace,
      backoffPolicy: BackoffPolicy.linear,
    );
  }
}

@pragma('vm:entry-point')
void backgroundEntrypoint() {
  BillsBackgroundServiceLocal._workManager.executeTask((task, inputData) async {
    try {
      if (task == BillsBackgroundServiceLocal.dailyReminderTaskName ||
          task == BillsBackgroundServiceLocal.oneTimeReminderTaskName) {
        await backgroundDailyReminder();
      }

      debugPrint('Background service: success on task "$task".');

      // For everything else, just mark the background task as complete.
      return Future.value(true);
    } catch (err) {
      debugPrint('Background service: error ($err).');

      throw Exception(err);
    }
  });
}

Future<void> backgroundDailyReminder() async {
  // await BillsNotificationServiceLocal.initializeTimezone();
  // await BillsNotificationServiceLocal.initializeNotificationPermissions();
  await BillsNotificationServiceLocal.initializeNotification();

  final database = BillsServiceDatabase();
  final notification = BillsNotificationServiceLocal();

  final now = DateTime.now();
  final bills = await database.getBills();
  final relevantBills = bills
      .where((bill) => bill.date.isBefore(now))
      .where((bill) => bill.paid == false)
      .toList();

  if (relevantBills.isEmpty) {
    debugPrint('Background service: no relevant bills found for notification.');
    return;
  }

  for (final bill in relevantBills) {
    debugPrint(
      'Background service: notification for ${bill.name} (${bill.id}).',
    );
    await notification.show(bill);
  }
}
