import 'package:bills_reminder/domain/models/bill.dart';

abstract class BillsNotificationService {
  Future<void> schedule(Bill bill);
  Future<void> cancel(Bill bill);
  Future<void> cancelAll();
}
