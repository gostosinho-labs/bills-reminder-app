import 'package:bills_reminder/data/repositories/bills/bills_repository.dart';
import 'package:bills_reminder/domain/models/bill.dart';

class BillsCreateViewModel {
  BillsCreateViewModel({required BillsRepository repository})
    : _repository = repository;

  final BillsRepository _repository;

  Future<void> createBill({
    required String name,
    required double? value,
    required DateTime date,
    required bool notification,
    required bool recurrence,
  }) async {
    final bill = Bill(
      id: 0,
      name: name,
      value: value,
      date: date,
      notification: notification,
      recurrence: recurrence,
      paid: false,
    );

    await _repository.addBill(bill);
  }
}
