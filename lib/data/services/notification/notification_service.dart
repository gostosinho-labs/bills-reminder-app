import 'package:bills_reminder/domain/models/bill.dart';

abstract class NotificationService {
  Future<void> schedule(Bill bill);
  Future<void> show(Bill bill);
  Future<void> cancel(Bill bill);
  Future<void> cancelAll();
}
