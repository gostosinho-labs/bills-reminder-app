import 'package:bills_reminder/data/services/bills/bills_service_database.dart';
import 'package:bills_reminder/data/services/bills_notification/bills_notification_service_local.dart';
import 'package:bills_reminder/data/services/preference/bills_preference_bool.dart';
import 'package:bills_reminder/data/services/preference/bills_preference_service.dart';
import 'package:logging/logging.dart';
import 'package:workmanager/workmanager.dart';

import 'bills_background_service.dart';

class BillsBackgroundServiceLocal implements BillsBackgroundService {
  BillsBackgroundServiceLocal({
    required BillsPreferenceService preferenceService,
  }) : _preferenceService = preferenceService,
       _log = Logger('BillsBackgroundServiceLocal');

  final BillsPreferenceService _preferenceService;
  final Logger _log;

  static final dailyNotificationUniqueName = 'daily-notification';
  static final dailyNotificationTaskName = 'Daily Notification';
  static final oneTimeNotificationUniqueName = 'one-time-notification';
  static final oneTimeNotificationTaskName = 'One Time Notification';

  static final _workManager = Workmanager();

  static Future<void> initialize() async {
    await _workManager.initialize(backgroundEntrypoint, isInDebugMode: true);
  }

  @override
  Future<void> registerDailyNotification() async {
    final startupNotification = await _preferenceService.isBool(
      BillsPreferenceBool.startup,
    );
    final dailyNotification = await _preferenceService.isBool(
      BillsPreferenceBool.daily,
    );

    _workManager.cancelAll();

    if (startupNotification) {
      _workManager.registerOneOffTask(
        BillsBackgroundServiceLocal.oneTimeNotificationUniqueName,
        BillsBackgroundServiceLocal.oneTimeNotificationTaskName,
      );
    }

    if (dailyNotification) {
      final now = DateTime.now();
      final today9am = DateTime(now.year, now.month, now.day, 9);
      final next9am = today9am.isAfter(now)
          ? today9am
          : today9am.add(const Duration(days: 1));
      final initialDelay = next9am.difference(now);

      _workManager.registerPeriodicTask(
        dailyNotificationUniqueName,
        dailyNotificationTaskName,
        frequency: const Duration(hours: 1),
        initialDelay: initialDelay,
        existingWorkPolicy: ExistingWorkPolicy.replace,
        backoffPolicy: BackoffPolicy.linear,
      );
    } else {
      _log.fine(
        'Background service: Daily notification is disabled, cancelling task.',
      );

      _workManager.cancelByUniqueName(dailyNotificationUniqueName);
    }
  }
}

@pragma('vm:entry-point')
void backgroundEntrypoint() {
  BillsBackgroundServiceLocal._workManager.executeTask((task, inputData) async {
    final log = Logger('BillsBackgroundServiceLocal.backgroundEntrypoint');

    try {
      log.info('Background service: task "$task" started.');

      if (task == BillsBackgroundServiceLocal.dailyNotificationTaskName ||
          task == BillsBackgroundServiceLocal.oneTimeNotificationTaskName) {
        await backgroundDailyReminder(log);
      }

      log.fine('Background service: success on task "$task".');

      // For everything else, just mark the background task as complete.
      return Future.value(true);
    } catch (err) {
      log.severe('Background service: error ($err).');

      throw Exception(err);
    }
  });
}

Future<void> backgroundDailyReminder(Logger log) async {
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
    log.fine('Background service: no relevant bills found for notification.');
    return;
  }

  for (final bill in relevantBills) {
    log.fine('Background service: notification for ${bill.name} (${bill.id}).');
    await notification.show(bill);
  }
}
