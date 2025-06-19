import 'package:bills_reminder/data/services/background/bills_background_service.dart';
import 'package:bills_reminder/data/services/bills_notification/bills_notification_service.dart';
import 'package:bills_reminder/data/services/preference/bills_preference_bool.dart';
import 'package:bills_reminder/data/services/preference/bills_preference_service.dart';
import 'package:flutter/foundation.dart';
import 'package:logging/logging.dart';

class NotificationsSettingsViewModel extends ChangeNotifier {
  NotificationsSettingsViewModel({
    required BillsBackgroundService backgroundService,
    required BillsNotificationService notificationService,
    required BillsPreferenceService preferenceService,
  }) : _backgroundService = backgroundService,
       _notificationService = notificationService,
       _preferenceService = preferenceService;

  final BillsBackgroundService _backgroundService;
  final BillsNotificationService _notificationService;
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
      await _backgroundService.registerDailyNotification();

      notifyListeners();
    } catch (e) {
      _error = e;
      _log.severe('Error setting startup notification', e);
    }
  }

  Future<void> setPerBillNotification(bool value) async {
    _log.fine('Setting per bill notification to $value');
    try {
      await _preferenceService.setBool(BillsPreferenceBool.perBill, value);
      _enablePerBillNotification = value;

      if (value) {
        await _notificationService.cancelAll();
      }

      notifyListeners();
    } catch (e) {
      _error = e;
      _log.severe('Error setting per bill notification', e);
    }
  }

  Future<void> setDailyNotification(bool value) async {
    _log.fine('Setting daily notification to $value');
    try {
      await _preferenceService.setBool(BillsPreferenceBool.daily, value);
      _enableDailyNotification = value;

      if (value) {
        await _backgroundService.registerDailyNotification();
      }

      notifyListeners();
    } catch (e) {
      _error = e;
      _log.severe('Error setting daily notification', e);
    }
  }
}
