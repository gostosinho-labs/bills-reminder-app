import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class DebugNotifications extends StatefulWidget {
  const DebugNotifications({super.key});

  @override
  State<DebugNotifications> createState() => _DebugNotificationsState();
}

class _DebugNotificationsState extends State<DebugNotifications> {
  List<PendingNotificationRequest> _notifications = [];

  @override
  void initState() {
    super.initState();
    _loadNotifications();
  }

  Future<void> _loadNotifications() async {
    final plugin = FlutterLocalNotificationsPlugin();
    final notifications = await plugin.pendingNotificationRequests();
    setState(() {
      _notifications = notifications;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
      child: Card(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Container(
                decoration: const BoxDecoration(
                  color: Colors.red,
                  borderRadius: BorderRadius.all(Radius.circular(16.0)),
                ),
                alignment: Alignment.center,
                child: const Text(
                  'DEBUG',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ),
            ListTile(
              title: Text('Pending Notifications (${_notifications.length})'),
              trailing: IconButton(
                icon: const Icon(Icons.refresh),
                onPressed: _loadNotifications,
                tooltip: 'Refresh',
              ),
            ),
            if (_notifications.isEmpty)
              const Padding(
                padding: EdgeInsets.all(16.0),
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.notifications_off_outlined,
                        size: 24,
                        color: Colors.grey,
                      ),
                      SizedBox(height: 16),
                      Text(
                        'No scheduled notifications',
                        style: TextStyle(fontWeight: FontWeight.w500),
                      ),
                    ],
                  ),
                ),
              )
            else
              ..._notifications.map(
                (notification) => ListTile(
                  title: Text(notification.title ?? 'No title'),
                  subtitle: Text(notification.body ?? 'No body'),
                  dense: true,
                  visualDensity: VisualDensity.compact,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
