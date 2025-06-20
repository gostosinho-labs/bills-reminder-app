import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:logging/logging.dart';

class DebugNotificationsViewModel extends ChangeNotifier {
  DebugNotificationsViewModel() : _log = Logger('DebugNotificationsViewModel');

  final Logger _log;

  List<PendingNotificationRequest>? _notifications;
  Object? _error;
  bool _loading = true;

  List<PendingNotificationRequest>? get notifications => _notifications;
  Object? get error => _error;
  bool get loading => _loading;

  Future<void> loadNotifications() async {
    _log.fine('Loading pending notifications');

    try {
      final plugin = FlutterLocalNotificationsPlugin();

      _notifications = await plugin.pendingNotificationRequests();
      _error = null;
    } catch (e) {
      _error = e;
      _log.severe('Error loading notifications', e);
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  Future<void> cancelNotification(int id) async {
    _log.fine('Cancelling notification $id');

    try {
      final plugin = FlutterLocalNotificationsPlugin();

      await plugin.cancel(id);
      await loadNotifications();
    } catch (e) {
      _error = e;
      _log.severe('Error cancelling notification', e);
    }
  }
}
