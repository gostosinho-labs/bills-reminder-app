import 'dart:collection';

import 'package:bills_reminder/data/services/database/bills_service.dart';
import 'package:bills_reminder/data/services/notification/notification_service.dart';
import 'package:bills_reminder/data/services/preference/preference_bool.dart';
import 'package:bills_reminder/data/services/preference/preference_service.dart';
import 'package:bills_reminder/domain/models/bill.dart';
import 'package:logging/logging.dart';

import 'bills_repository.dart';

class BillsRepositoryLocal implements BillsRepository {
  BillsRepositoryLocal({
    required BillsService billsService,
    required NotificationService billsNotificationService,
    required PreferenceService preferenceService,
  }) : _billsService = billsService,
       _billsNotificationService = billsNotificationService,
       _preferenceService = preferenceService;

  final BillsService _billsService;
  final NotificationService _billsNotificationService;
  final PreferenceService _preferenceService;
  final _log = Logger('BillsRepositoryLocal');

  /// A bill should only be scheduled when it opts in individually and the
  /// global "Per Bill" notification preference is enabled. Without this
  /// check, a bill could schedule a notification even after the global
  /// preference has been disabled from the settings screen.
  Future<bool> _shouldScheduleNotification(Bill bill) async {
    if (!bill.notification || !bill.date.isAfter(DateTime.now())) {
      return false;
    }

    return _preferenceService.isBool(PreferenceBool.perBill);
  }

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

    if (await _shouldScheduleNotification(bill)) {
      _log.fine('Scheduling notification for new bill ${bill.id}');
      await _billsNotificationService.schedule(bill);
    }
  }

  @override
  Future<void> updateBill(Bill bill) async {
    await _billsService.updateBill(bill);

    if (await _shouldScheduleNotification(bill)) {
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
