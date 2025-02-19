import 'dart:collection';

import 'package:bills_reminder/data/repositories/bills/bills_repository.dart';
import 'package:bills_reminder/domain/models/bill.dart';
import 'package:flutter/foundation.dart';
import 'package:logging/logging.dart';

class HomeViewModel extends ChangeNotifier {
  HomeViewModel({required BillsRepository repository})
    : _repository = repository;

  final BillsRepository _repository;
  final _log = Logger('HomeViewModel');

  UnmodifiableListView<Bill> _bills = UnmodifiableListView([]);
  bool _isLoading = false;
  Object? _error;

  UnmodifiableListView<Bill> get bills => _bills;
  bool get isLoading => _isLoading;
  Object? get error => _error;

  Future<void> getBills() async {
    _log.fine('Bills loading');

    _isLoading = true;
    _error = null;

    notifyListeners();

    try {
      await Future.delayed(const Duration(seconds: 1));

      final bills = await _repository.getBills();
      _bills = UnmodifiableListView(bills);

      _log.fine('Bills loaded: ${bills.length}');
    } catch (e) {
      _error = e;
      _log.severe('Error loading bills', e);
    } finally {
      _isLoading = false;

      notifyListeners();
    }
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
  }
}
