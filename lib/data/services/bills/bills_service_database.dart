import 'package:bills_reminder/data/services/bills/bills_service.dart';
import 'package:bills_reminder/data/services/database/bills_database.dart';
import 'package:bills_reminder/domain/models/bill.dart';
import 'package:sqflite/sqflite.dart';

class BillsServiceDatabase implements BillsService {
  @override
  Future<void> addBill(Bill bill) async {
    final database = await BillsDatabase.instance.database;

    await database.insert(
      'bills',
      bill.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  @override
  Future<List<Bill>> getBills() async {
    final database = await BillsDatabase.instance.database;
    final List<Map<String, dynamic>> maps = await database.query('bills');

    return List.generate(maps.length, (i) => Bill.fromMap(maps[i]));
  }

  @override
  Future<void> deleteBills() async {
    final database = await BillsDatabase.instance.database;

    await database.delete('bills');
  }
}
