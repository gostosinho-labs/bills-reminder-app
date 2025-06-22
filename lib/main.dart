import 'package:bills_reminder/data/services/background/background_service.dart';
import 'package:bills_reminder/data/services/background/background_service_local.dart';
import 'package:bills_reminder/data/services/notification/notification_service_local.dart';
import 'package:bills_reminder/dependencies/local_providers.dart';
import 'package:bills_reminder/routing/router.dart';
import 'package:flutter/material.dart';
import 'package:logging/logging.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await NotificationServiceLocal.initializeTimezone();
  await NotificationServiceLocal.initializeNotification();
  await NotificationServiceLocal.initializeNotificationPermissions();
  await BackgroundServiceLocal.initialize();

  Logger.root.level = Level.ALL;
  Logger.root.onRecord.listen((rec) {
    debugPrint(
      '${rec.loggerName} ${rec.level.name} [${rec.time.toIso8601String()}]: ${rec.message}',
    );
  });

  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: localProviders(),
      child: MaterialApp.router(
        routerConfig: router,
        title: 'Bills Reminder',
        themeMode: ThemeMode.system,
        theme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(
            seedColor: Colors.blue,
            brightness: Brightness.light,
          ),
        ),
        darkTheme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(
            seedColor: Colors.blue,
            brightness: Brightness.dark,
          ),
        ),
      ),
      builder: (context, child) {
        final backgroundService = context.read<BackgroundService>();

        backgroundService.registerStartupNotification();
        backgroundService.registerDailyNotification();

        return child!;
      },
    );
  }
}
