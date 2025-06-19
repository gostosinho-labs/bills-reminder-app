import 'package:bills_reminder/ui/settings/notifications/notifications_settings_view_model.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class NotificationsSettingsScreen extends StatefulWidget {
  const NotificationsSettingsScreen({super.key});

  @override
  State<NotificationsSettingsScreen> createState() =>
      _NotificationsSettingsScreenState();
}

class _NotificationsSettingsScreenState
    extends State<NotificationsSettingsScreen> {
  late final NotificationsSettingsViewModel _viewModel;

  @override
  void initState() {
    super.initState();
    _viewModel = NotificationsSettingsViewModel(
      backgroundService: context.read(),
      notificationService: context.read(),
      preferenceService: context.read(),
    );

    Future.microtask(() => _viewModel.loadSettings());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Notification Settings')),
      body: ListenableBuilder(
        listenable: _viewModel,
        builder: (context, _) {
          if (_viewModel.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          return ListView(
            children: [
              SwitchListTile(
                title: const Text('On Startup'),
                subtitle: const Text(
                  'When the app starts, get notified about due bills.',
                ),
                value: _viewModel.enableStartupNotification,
                onChanged: (value) => _viewModel.setStartupNotification(value),
              ),
              SwitchListTile(
                title: const Text('Per Bill'),
                subtitle: const Text(
                  'On the due date, get notified per bill. You must enable notifications per bill.',
                ),
                value: _viewModel.enablePerBillNotification,
                onChanged: (value) => _viewModel.setPerBillNotification(value),
              ),
              SwitchListTile(
                title: const Text('Daily Notification'),
                subtitle: const Text(
                  'Every day, get notified about due bills.',
                ),
                value: _viewModel.enableDailyNotification,
                onChanged: (value) => _viewModel.setDailyNotification(value),
              ),
            ],
          );
        },
      ),
    );
  }
}
