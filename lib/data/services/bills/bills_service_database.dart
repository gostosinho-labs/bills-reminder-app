import 'package:bills_reminder/data/services/bills/bills_service.dart';
import 'package:bills_reminder/data/services/database/bills_database.dart';
import 'package:bills_reminder/domain/models/bill.dart';
import 'package:sqflite/sqflite.dart';

class BillsServiceDatabase implements BillsService {
  @override
  Future<List<Bill>> getBills() async {
    final database = await BillsDatabase.instance.database;
    final List<Map<String, dynamic>> maps = await database.query('bills');

    return List.generate(maps.length, (i) => Bill.fromMap(maps[i]));
  }

  @override
  Future<Bill> getBill(String id) async {
    final database = await BillsDatabase.instance.database;
    final List<Map<String, dynamic>> maps = await database.query(
      'bills',
      where: 'id = ?',
      whereArgs: [id],
    );

    return Bill.fromMap(maps.first);
  }

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
  Future<void> updateBill(Bill bill) async {
    final database = await BillsDatabase.instance.database;

    await database.update(
      'bills',
      bill.toMap(),
      where: 'id = ?',
      whereArgs: [bill.id],
    );
  }

  @override
  Future<void> deleteBills() async {
    final database = await BillsDatabase.instance.database;

    await database.delete('bills');
  }
}
