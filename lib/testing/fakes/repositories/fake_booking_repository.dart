import 'dart:collection';

import 'package:bills_reminder/data/repositories/bills/bills_repository.dart';
import 'package:bills_reminder/domain/models/bill.dart';

class FakeBookingRepository implements BillsRepository {
  final List<Bill> _bills = [
    Bill(
      id: 1,
      name: 'Electricity',
      date: DateTime.now(),
      notification: true,
      recurrence: true,
      paid: false,
      value: 100,
    ),
    Bill(
      id: 2,
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
  Future<Bill> getBill(String id) async {
    return _bills.firstWhere((bill) => bill.id == int.parse(id));
  }

  @override
  Future<void> addBill(Bill bill) async {
    _bills.add(bill);
  }

  @override
  Future<void> deleteBills() async {
    _bills.clear();
  }

  @override
  Future<void> updateBill(Bill bill) async {
    final index = _bills.indexWhere((element) => element.id == bill.id);

    _bills[index] = bill;
  }
}
