import 'package:bills_reminder/routing/routes.dart';
import 'package:bills_reminder/ui/home/home_screen.dart';
import 'package:bills_reminder/ui/home/home_view_model.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

GoRouter router = GoRouter(
  routes: [
    GoRoute(
      path: Routes.home,
      builder:
          (context, state) =>
              HomeScreen(viewModel: HomeViewModel(repository: context.read())),
    ),
  ],
);
