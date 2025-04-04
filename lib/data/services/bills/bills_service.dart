import 'package:bills_reminder/domain/models/bill.dart';

abstract class BillsService {
  Future<List<Bill>> getBills();
  Future<Bill> getBill(int id);
  Future<int> addBill(Bill bill);
  Future<void> updateBill(Bill bill);
  Future<void> deleteBills();
  Future<void> deleteBill(Bill bill);
}
