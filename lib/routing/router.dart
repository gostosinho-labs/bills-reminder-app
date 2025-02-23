import 'package:bills_reminder/routing/routes.dart';
import 'package:bills_reminder/ui/bills/create/bills_create_screen.dart';
import 'package:bills_reminder/ui/home/home_screen.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

GoRouter router = GoRouter(
  routes: [
    GoRoute(
      path: Routes.home,
      builder:
          (context, state) =>
              HomeScreen(viewModel: context.read(), key: state.pageKey),
    ),
    GoRoute(
      path: Routes.createBill,
      builder:
          (context, state) =>
              BillsCreateScreen(viewModel: context.read(), key: state.pageKey),
    ),
  ],
);
