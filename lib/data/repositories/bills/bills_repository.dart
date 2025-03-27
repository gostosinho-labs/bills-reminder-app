import 'dart:collection';

import 'package:bills_reminder/domain/models/bill.dart';

abstract class BillsRepository {
  Future<UnmodifiableListView<Bill>> getBills();
  Future<Bill> getBill(String id);
  Future<void> addBill(Bill bill);
  Future<void> updateBill(Bill bill);
  Future<void> deleteBills();
}
