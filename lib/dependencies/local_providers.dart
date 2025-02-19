import 'package:bills_reminder/data/repositories/bills/bills_repository.dart';
import 'package:bills_reminder/data/repositories/bills/bills_repository_local.dart';
import 'package:bills_reminder/testing/fakes/repositories/fake_booking_repository.dart';
import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';

List<SingleChildWidget> localProviders() {
  return [
    Provider(lazy: true, create: (context) => FakeBookingRepository()),
    Provider(
      lazy: true,
      create:
          (context) =>
              BillsRepositoryLocal(fakeRepository: context.read())
                  as BillsRepository,
    ),
  ];
}
