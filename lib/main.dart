import 'package:bills_reminder/dependencies/local_providers.dart';
import 'package:bills_reminder/routing/router.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

void main() {
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
