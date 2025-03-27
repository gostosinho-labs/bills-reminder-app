import 'dart:collection';

import 'package:bills_reminder/domain/models/bill.dart';

abstract class BillsRepository {
  Future<UnmodifiableListView<Bill>> getBills();
  Future<Bill> getBill(int id);
  Future<void> addBill(Bill bill);
  Future<void> updateBill(Bill bill);
  Future<void> deleteBills();
  Future<void> deleteBill(Bill bill);
}
