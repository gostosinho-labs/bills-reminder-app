import 'package:bills_reminder/data/services/background/background_service_local.dart';
import 'package:bills_reminder/data/services/database/bills_service_database.dart';
import 'package:bills_reminder/data/services/notification/notification_service_local.dart';
import 'package:bills_reminder/data/services/preference/preference_bool.dart';
import 'package:bills_reminder/data/services/preference/preference_service.dart';
import 'package:bills_reminder/data/services/preference/preference_service_local.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:logging/logging.dart';

import 'notifications_settings_repository.dart';

/// Local implementation of [NotificationsSettingsRepository].
///
/// Enabling/disabling the per-bill and daily preferences kicks off
/// unawaited background isolate work (via [compute]) to (re)schedule
/// notifications or WorkManager tasks. That isolate work has no widget
/// tree to read providers from, so it instantiates concrete service
/// classes directly, matching the convention used by background isolate
/// entrypoints elsewhere in the data layer (see `background_service_local.dart`).
class NotificationsSettingsRepositoryLocal
    implements NotificationsSettingsRepository {
  NotificationsSettingsRepositoryLocal({
    required PreferenceService preferenceService,
  }) : _preferenceService = preferenceService,
       _log = Logger('NotificationsSettingsRepositoryLocal');

  final PreferenceService _preferenceService;
  final Logger _log;

  @override
  Future<bool> isStartupNotificationEnabled() {
    return _preferenceService.isBool(PreferenceBool.startup);
  }

  @override
  Future<void> setStartupNotificationEnabled(bool value) {
    _log.fine('Setting startup notification to $value');

    return _preferenceService.setBool(PreferenceBool.startup, value);
  }

  @override
  Future<bool> isPerBillNotificationEnabled() {
    return _preferenceService.isBool(PreferenceBool.perBill);
  }

  @override
  Future<void> setPerBillNotificationEnabled(bool value) async {
    _log.fine('Setting per bill notification to $value');

    await _preferenceService.setBool(PreferenceBool.perBill, value);

    // Not awaited since the result isn't important.
    compute(_schedulePerBillNotifications, (
      enabled: value,
      token: RootIsolateToken.instance!,
    ));
  }

  @override
  Future<bool> isDailyNotificationEnabled() {
    return _preferenceService.isBool(PreferenceBool.daily);
  }

  @override
  Future<void> setDailyNotificationEnabled(bool value) async {
    _log.fine('Setting daily notification to $value');

    await _preferenceService.setBool(PreferenceBool.daily, value);

    // Not awaited since the result isn't important.
    compute(_registerDailyNotification, (token: RootIsolateToken.instance!));
  }
}

Future<void> _schedulePerBillNotifications(
  ({bool enabled, RootIsolateToken token}) message,
) async {
  BackgroundIsolateBinaryMessenger.ensureInitialized(message.token);

  final log = Logger(
    'NotificationsSettingsRepositoryLocal.setPerBillNotificationEnabled',
  );

  await NotificationServiceLocal.initializeTimezone();

  final service = BillsServiceDatabase();
  final notification = NotificationServiceLocal();

  if (message.enabled) {
    final now = DateTime.now();
    final bills = await service.getBills();

    for (final bill in bills) {
      if (bill.date.isAfter(now)) {
        log.fine('Scheduling notification for bill: ${bill.name}');
        await notification.schedule(bill);
      }
    }
  } else {
    log.fine('Cancelling all notifications');
    await notification.cancelAll();
  }
}

Future<void> _registerDailyNotification(
  ({RootIsolateToken token}) message,
) async {
  BackgroundIsolateBinaryMessenger.ensureInitialized(message.token);

  await BackgroundServiceLocal.initialize();

  final preferenceService = PreferenceServiceLocal();
  final backgroundService = BackgroundServiceLocal(
    preferenceService: preferenceService,
  );

  await backgroundService.registerDailyNotification();
}
