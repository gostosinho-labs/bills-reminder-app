import 'package:bills_reminder/data/services/background/bills_background_service_local.dart';
import 'package:bills_reminder/data/services/bills/bills_service_database.dart';
import 'package:bills_reminder/data/services/bills_notification/bills_notification_service_local.dart';
import 'package:bills_reminder/data/services/preference/bills_preference_bool.dart';
import 'package:bills_reminder/data/services/preference/bills_preference_service.dart';
import 'package:bills_reminder/data/services/preference/bills_preference_service_local.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:logging/logging.dart';

class NotificationsSettingsViewModel extends ChangeNotifier {
  NotificationsSettingsViewModel({
    required BillsPreferenceService preferenceService,
  }) : _preferenceService = preferenceService;

  final BillsPreferenceService _preferenceService;
  final _log = Logger('NotificationsSettingsViewModel');

  bool _isLoading = true;
  Object? _error;
  bool _enableStartupNotification = false;
  bool _enablePerBillNotification = false;
  bool _enableDailyNotification = false;

  bool get isLoading => _isLoading;
  Object? get error => _error;
  bool get enableStartupNotification => _enableStartupNotification;
  bool get enablePerBillNotification => _enablePerBillNotification;
  bool get enableDailyNotification => _enableDailyNotification;

  Future<void> loadSettings() async {
    _log.fine('Loading notification settings');

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _enableStartupNotification = await _preferenceService.isBool(
        BillsPreferenceBool.startup,
      );
      _enablePerBillNotification = await _preferenceService.isBool(
        BillsPreferenceBool.perBill,
      );
      _enableDailyNotification = await _preferenceService.isBool(
        BillsPreferenceBool.daily,
      );

      _log.fine('Notification settings loaded');
    } catch (e) {
      _error = e;
      _log.severe('Error loading notification settings', e);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> setStartupNotification(bool value) async {
    _log.fine('Setting startup notification to $value');

    try {
      await _preferenceService.setBool(BillsPreferenceBool.startup, value);

      _enableStartupNotification = value;
      _error = null;

      _log.fine('Startup notification set to $value');
    } catch (e) {
      _error = e;
      _log.severe('Error setting startup notification', e);
    } finally {
      notifyListeners();
    }
  }

  Future<void> setPerBillNotification(bool value) async {
    _log.fine('Setting per bill notification to $value');

    try {
      await _preferenceService.setBool(BillsPreferenceBool.perBill, value);

      _enablePerBillNotification = value;

      // Not awaited since the result isn't important.
      compute((message) async {
        BackgroundIsolateBinaryMessenger.ensureInitialized(message.token);

        await BillsNotificationServiceLocal.initializeTimezone();

        final service = BillsServiceDatabase();
        final notification = BillsNotificationServiceLocal();
        final log = Logger(
          'NotificationsSettingsViewModel.setPerBillNotification',
        );

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
          await notification.cancelAll();
        }
      }, (enabled: value, token: RootIsolateToken.instance!));

      _error = null;
      _log.fine('Per bill notification set to $value');
    } catch (e) {
      _error = e;
      _log.severe('Error setting per bill notification', e);
    } finally {
      notifyListeners();
    }
  }

  Future<void> setDailyNotification(bool value) async {
    _log.fine('Setting daily notification to $value');

    try {
      await _preferenceService.setBool(BillsPreferenceBool.daily, value);

      _enableDailyNotification = value;

      // Not awaited since the result isn't important.
      compute((message) async {
        BackgroundIsolateBinaryMessenger.ensureInitialized(message.token);

        await BillsBackgroundServiceLocal.initialize();

        final preferenceService = BillsPreferenceServiceLocal();
        final backgroundService = BillsBackgroundServiceLocal(
          preferenceService: preferenceService,
        );

        await backgroundService.registerDailyNotification();
      }, (token: RootIsolateToken.instance!));

      _error = null;
      _log.fine('Daily notification set to $value');
    } catch (e) {
      _error = e;
      _log.severe('Error setting daily notification', e);
    } finally {
      notifyListeners();
    }
  }
}
