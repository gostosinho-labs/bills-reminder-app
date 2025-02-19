import 'dart:async';
import 'dart:collection';

import 'package:bills_reminder/data/repositories/bills/bills_repository.dart';
import 'package:bills_reminder/domain/models/bill.dart';
import 'package:logging/logging.dart';

class HomeViewModel {
  HomeViewModel({required BillsRepository repository})
    : _repository = repository,
      _billsController = StreamController();

  final BillsRepository _repository;
  final StreamController<UnmodifiableListView<Bill>> _billsController;

  final _log = Logger('HomeViewModel');

  Stream<UnmodifiableListView<Bill>> get bills => _billsController.stream;

  Future<void> getBills() async {
    _log.fine('Bills loading');

    await Future.delayed(const Duration(seconds: 1));

    final bills = await _repository.getBills();
    _billsController.add(UnmodifiableListView(bills));

    _log.fine('Bills loaded: ${bills.length}');
  }

  Future<void> addBill() async {
    _log.fine('Adding new bill');

    await _repository.addBill(
      Bill(
        name: 'New Bill',
        date: DateTime.now(),
        notification: true,
        recurrence: true,
        paid: false,
        value: 0,
      ),
    );

    _log.fine('New bill added');

    await getBills();
  }

  void dispose() {
    _billsController.close();
  }
}
