import 'dart:collection';

import 'package:bills_reminder/data/services/database/bills_service.dart';
import 'package:bills_reminder/data/services/notification/notification_service.dart';
import 'package:bills_reminder/domain/models/bill.dart';
import 'package:logging/logging.dart';

import 'bills_repository.dart';

class BillsRepositoryLocal implements BillsRepository {
  BillsRepositoryLocal({
    required BillsService billsService,
    required NotificationService billsNotificationService,
  }) : _billsService = billsService,
       _billsNotificationService = billsNotificationService;

  final BillsService _billsService;
  final NotificationService _billsNotificationService;
  final _log = Logger('BillsRepositoryLocal');

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

    if (bill.notification && bill.date.isAfter(DateTime.now())) {
      _log.fine('Scheduling notification for new bill ${bill.id}');
      await _billsNotificationService.schedule(bill);
    }
  }

  @override
  Future<void> updateBill(Bill bill) async {
    await _billsService.updateBill(bill);

    if (bill.notification && bill.date.isAfter(DateTime.now())) {
      _log.fine('Scheduling notification for updated bill ${bill.id}');
      await _billsNotificationService.schedule(bill);
    } else {
      _log.fine('Cancelling notification for updated bill ${bill.id}');
      await _billsNotificationService.cancel(bill);
    }
  }

  @override
  Future<void> deleteBills() async {
    await _billsService.deleteBills();
    await _billsNotificationService.cancelAll();

    _log.fine('Deleted all bills and cancelled all notifications');
  }

  @override
  Future<void> deleteBill(Bill bill) async {
    await _billsService.deleteBill(bill);
    await _billsNotificationService.cancel(bill);

    _log.fine('Deleted bill ${bill.id} and cancelled its notification');
  }
}
