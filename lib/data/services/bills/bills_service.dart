import 'package:bills_reminder/domain/models/bill.dart';

abstract class BillsService {
  Future<void> addBill(Bill bill);
  Future<void> getBills();
  Future<void> deleteBills();
}
