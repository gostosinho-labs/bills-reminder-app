import 'package:bills_reminder/data/repositories/bills/bills_repository.dart';
import 'package:bills_reminder/data/repositories/bills/bills_repository_local.dart';
import 'package:bills_reminder/data/services/background/background_service.dart';
import 'package:bills_reminder/data/services/background/background_service_local.dart';
import 'package:bills_reminder/data/services/database/bills_service.dart';
import 'package:bills_reminder/data/services/database/bills_service_database.dart';
import 'package:bills_reminder/data/services/notification/notification_service.dart';
import 'package:bills_reminder/data/services/notification/notification_service_local.dart';
import 'package:bills_reminder/data/services/preference/preference_service.dart';
import 'package:bills_reminder/data/services/preference/preference_service_local.dart';
import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';

List<SingleChildWidget> localProviders() {
  return [
    Provider(create: (context) => BillsServiceDatabase() as BillsService),
    Provider(
      create: (context) => NotificationServiceLocal() as NotificationService,
    ),
    Provider(
      create: (context) => PreferenceServiceLocal() as PreferenceService,
    ),
    Provider(
      create: (context) =>
          BackgroundServiceLocal(preferenceService: context.read())
              as BackgroundService,
    ),
    Provider(
      create: (context) {
        return BillsRepositoryLocal(
              billsService: context.read(),
              billsNotificationService: context.read(),
            )
            as BillsRepository;
      },
    ),
  ];
}
