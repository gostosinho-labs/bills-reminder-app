import 'dart:collection';

import 'package:bills_reminder/domain/models/bill.dart';

abstract class BillsRepository {
  Future<UnmodifiableListView<Bill>> getBills();
}
