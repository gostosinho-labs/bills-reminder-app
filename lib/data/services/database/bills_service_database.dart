import 'package:bills_reminder/data/services/database/bills_service.dart';
import 'package:bills_reminder/data/services/database/database.dart';
import 'package:bills_reminder/domain/models/bill.dart';
import 'package:logging/logging.dart';
import 'package:sqflite/sqflite.dart' hide Database;

class BillsServiceDatabase implements BillsService {
  final _log = Logger('BillsServiceDatabase');

  @override
  Future<List<Bill>> getBills() async {
    final database = await DatabaseAccessor.instance.database;
    final List<Map<String, dynamic>> maps = await database.query(
      'bills',
      orderBy: 'date ASC',
    );

    _log.fine('Loaded ${maps.length} bills');

    return List.generate(maps.length, (i) => Bill.fromMap(maps[i]));
  }

  @override
  Future<Bill> getBill(int id) async {
    final database = await DatabaseAccessor.instance.database;
    final List<Map<String, dynamic>> maps = await database.query(
      'bills',
      where: 'id = ?',
      whereArgs: [id],
    );

    _log.fine('Loaded bill $id');

    return Bill.fromMap(maps.first);
  }

  @override
  Future<int> addBill(Bill bill) async {
    final database = await DatabaseAccessor.instance.database;

    final id = await database.insert(
      'bills',
      bill.toMap(),
      conflictAlgorithm: ConflictAlgorithm.fail,
    );

    _log.fine('Added bill $id');

    return id;
  }

  @override
  Future<void> updateBill(Bill bill) async {
    final database = await DatabaseAccessor.instance.database;

    await database.update(
      'bills',
      bill.toMap(),
      where: 'id = ?',
      whereArgs: [bill.id],
      conflictAlgorithm: ConflictAlgorithm.fail,
    );

    _log.fine('Updated bill ${bill.id}');
  }

  @override
  Future<void> deleteBills() async {
    final database = await DatabaseAccessor.instance.database;

    await database.delete('bills');

    _log.fine('Deleted all bills');
  }

  @override
  Future<void> deleteBill(Bill bill) async {
    final database = await DatabaseAccessor.instance.database;

    await database.delete('bills', where: 'id = ?', whereArgs: [bill.id]);

    _log.fine('Deleted bill ${bill.id}');
  }
}
