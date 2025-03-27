import 'package:bills_reminder/data/repositories/bills/bills_repository.dart';
import 'package:bills_reminder/data/repositories/bills/bills_repository_local.dart';
import 'package:bills_reminder/data/services/bills/bills_service_database.dart';
import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';

List<SingleChildWidget> localProviders() {
  return [
    Provider(create: (context) => BillsServiceDatabase()),
    Provider(
      create: (context) {
        return BillsRepositoryLocal(billsServiceDatabase: context.read())
            as BillsRepository;
      },
    ),
  ];
}
