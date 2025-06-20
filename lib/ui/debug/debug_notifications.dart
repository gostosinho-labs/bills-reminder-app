import 'package:bills_reminder/ui/debug/debug_notifications_view_model.dart';
import 'package:flutter/material.dart';

class DebugNotifications extends StatefulWidget {
  const DebugNotifications({super.key});

  @override
  State<DebugNotifications> createState() => _DebugNotificationsState();
}

class _DebugNotificationsState extends State<DebugNotifications> {
  late final DebugNotificationsViewModel _viewModel;

  @override
  void initState() {
    super.initState();

    _viewModel = DebugNotificationsViewModel();
    Future.microtask(() => _viewModel.loadNotifications());
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
      child: Card(
        child: ListenableBuilder(
          listenable: _viewModel,
          builder: (context, _) {
            if (_viewModel.loading) {
              return const Center(child: CircularProgressIndicator());
            }

            if (_viewModel.error != null) {
              return Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.error_outline,
                      size: 48,
                      color: Colors.red,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Error loading notifications',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _viewModel.error.toString(),
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                ),
              );
            }

            final notifications = _viewModel.notifications;
            if (notifications == null || notifications.isEmpty) {
              return Padding(
                padding: const EdgeInsets.all(16.0),
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.notifications_off_outlined,
                        size: 24,
                        color: Colors.grey,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'No scheduled notifications',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                    ],
                  ),
                ),
              );
            }

            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.all(Radius.circular(16.0)),
                    ),
                    alignment: Alignment.center,
                    child: Text('DEBUG', style: TextStyle(color: Colors.white)),
                  ),
                ),
                ListTile(
                  title: Text(
                    'Pending Notifications (${notifications.length})',
                  ),
                ),
                ...notifications.map((notification) {
                  return ListTile(
                    title: Text(notification.title ?? 'No title'),
                    subtitle: Text(notification.body ?? 'No body'),
                    dense: true,
                    visualDensity: VisualDensity.compact,
                  );
                }),
              ],
            );
          },
        ),
      ),
    );
  }
}
