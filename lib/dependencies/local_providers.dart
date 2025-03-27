import 'package:bills_reminder/data/repositories/bills/bills_repository.dart';
import 'package:bills_reminder/data/repositories/bills/bills_repository_local.dart';
import 'package:bills_reminder/data/services/bills/bills_service.dart';
import 'package:bills_reminder/data/services/bills/bills_service_database.dart';
import 'package:bills_reminder/data/services/bills_notification/bills_notification_service.dart';
import 'package:bills_reminder/data/services/bills_notification/bills_notification_service_local.dart';
import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';

List<SingleChildWidget> localProviders() {
  return [
    Provider(create: (context) => BillsServiceDatabase() as BillsService),
    Provider(
      create:
          (context) =>
              BillsNotificationServiceLocal() as BillsNotificationService,
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
