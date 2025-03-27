import 'package:bills_reminder/data/services/bills_notification/bills_notification_service_local.dart';
import 'package:bills_reminder/dependencies/local_providers.dart';
import 'package:bills_reminder/routing/router.dart';
import 'package:flutter/material.dart';
import 'package:logging/logging.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await BillsNotificationServiceLocal.initialize();
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
      child: MaterialApp.router(routerConfig: router),
    );
  }
}
