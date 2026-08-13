import 'package:bills_reminder/data/repositories/notifications_settings/notifications_settings_repository.dart';
import 'package:flutter/foundation.dart';
import 'package:logging/logging.dart';

class NotificationsSettingsViewModel extends ChangeNotifier {
  NotificationsSettingsViewModel({
    required NotificationsSettingsRepository repository,
  }) : _repository = repository;

  final NotificationsSettingsRepository _repository;
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
      _enableStartupNotification = await _repository
          .isStartupNotificationEnabled();
      _enablePerBillNotification = await _repository
          .isPerBillNotificationEnabled();
      _enableDailyNotification = await _repository
          .isDailyNotificationEnabled();

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
      await _repository.setStartupNotificationEnabled(value);

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
      await _repository.setPerBillNotificationEnabled(value);

      _enablePerBillNotification = value;
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
      await _repository.setDailyNotificationEnabled(value);

      _enableDailyNotification = value;
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
