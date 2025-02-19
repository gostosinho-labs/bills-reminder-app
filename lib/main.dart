import 'package:bills_reminder/dependencies/local_providers.dart';
import 'package:bills_reminder/routing/router.dart';
import 'package:flutter/material.dart';
import 'package:logging/logging.dart';
import 'package:provider/provider.dart';

void main() {
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
