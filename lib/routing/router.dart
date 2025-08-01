import 'package:bills_reminder/ui/bills/create/bills_create_screen.dart';
import 'package:bills_reminder/ui/bills/edit/bills_edit_screen.dart';
import 'package:bills_reminder/ui/calendar/calendar_screen.dart';
import 'package:bills_reminder/ui/home/home_screen.dart';
import 'package:bills_reminder/ui/settings/notifications/notifications_settings_screen.dart';
import 'package:go_router/go_router.dart';

final router = GoRouter(
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => const HomeScreen(),
      routes: [
        GoRoute(
          path: 'bills/create',
          builder: (context, state) => const BillsCreateScreen(),
        ),
        GoRoute(
          path: 'bills/:id',
          builder: (context, state) =>
              BillsEditScreen(id: int.parse(state.pathParameters['id']!)),
        ),
        GoRoute(
          path: 'calendar',
          builder: (context, state) => const CalendarScreen(),
        ),
        GoRoute(
          path: 'settings/notifications',
          builder: (context, state) => const NotificationsSettingsScreen(),
        ),
      ],
    ),
  ],
);
