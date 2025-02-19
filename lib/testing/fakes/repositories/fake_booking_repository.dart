import 'dart:collection';

import 'package:bills_reminder/data/repositories/bills/bills_repository.dart';
import 'package:bills_reminder/domain/models/bill.dart';

class FakeBookingRepository implements BillsRepository {
  final List<Bill> _bills = [
    Bill(
      name: 'Electricity',
      date: DateTime.now(),
      notification: true,
      recurrence: true,
      paid: false,
      value: 100,
    ),
    Bill(
      name: 'Gas',
      date: DateTime.now().add(const Duration(days: 1)),
      notification: true,
      recurrence: true,
      paid: false,
      value: 120,
    ),
  ];

  @override
  Future<UnmodifiableListView<Bill>> getBills() async {
    return UnmodifiableListView(_bills);
  }

  @override
  Future<void> addBill(Bill bill) async {
    _bills.add(bill);
  }
}
