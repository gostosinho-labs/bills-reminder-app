import 'dart:collection';

import 'package:bills_reminder/data/services/bills/bills_service.dart';
import 'package:bills_reminder/data/services/bills_notification/bills_notification_service.dart';
import 'package:bills_reminder/domain/models/bill.dart';

import 'bills_repository.dart';

class BillsRepositoryLocal implements BillsRepository {
  BillsRepositoryLocal({
    required BillsService billsService,
    required BillsNotificationService billsNotificationService,
  }) : _billsService = billsService,
       _billsNotificationService = billsNotificationService;

  final BillsService _billsService;
  final BillsNotificationService _billsNotificationService;

  @override
  Future<UnmodifiableListView<Bill>> getBills() async {
    final bills = await _billsService.getBills();

    return UnmodifiableListView(bills);
  }

  @override
  Future<Bill> getBill(int id) {
    return _billsService.getBill(id);
  }

  @override
  Future<void> addBill(Bill bill) async {
    final id = await _billsService.addBill(bill);

    bill = bill.copyWith(id: id);

    if (bill.notification) {
      await _billsNotificationService.schedule(bill);
    }
  }

  @override
  Future<void> updateBill(Bill bill) async {
    await _billsService.updateBill(bill);

    if (bill.notification && bill.date.isAfter(DateTime.now())) {
      await _billsNotificationService.schedule(bill);
    } else {
      await _billsNotificationService.cancel(bill);
    }
  }

  @override
  Future<void> deleteBills() async {
    await _billsService.deleteBills();
    await _billsNotificationService.cancelAll();
  }

  @override
  Future<void> deleteBill(Bill bill) async {
    await _billsService.deleteBill(bill);
    await _billsNotificationService.cancel(bill);
  }
}
