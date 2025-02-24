import 'dart:collection';

import 'package:bills_reminder/data/services/bills/bills_service_database.dart';
import 'package:bills_reminder/domain/models/bill.dart';

import 'bills_repository.dart';

class BillsRepositoryLocal implements BillsRepository {
  BillsRepositoryLocal({required BillsServiceDatabase billsServiceDatabase})
    : _billsServiceDatabase = billsServiceDatabase;

  final BillsServiceDatabase _billsServiceDatabase;

  @override
  Future<UnmodifiableListView<Bill>> getBills() async {
    final bills = await _billsServiceDatabase.getBills();

    return UnmodifiableListView(bills);
  }

  @override
  Future<Bill> getBill(String id) {
    return _billsServiceDatabase.getBill(id);
  }

  @override
  Future<void> addBill(Bill bill) {
    return _billsServiceDatabase.addBill(bill);
  }

  @override
  Future<void> updateBill(Bill bill) {
    return _billsServiceDatabase.updateBill(bill);
  }

  @override
  Future<void> deleteBills() {
    return _billsServiceDatabase.deleteBills();
  }
}
