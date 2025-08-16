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

  UnmodifiableListView<Bill> _pendingBills = UnmodifiableListView([]);
  UnmodifiableListView<Bill> _paidBills = UnmodifiableListView([]);
  bool _isLoading = false;
  Object? _error;

  bool get isLoading => _isLoading;
  Object? get error => _error;

  UnmodifiableListView<Bill> get pendingBills => _pendingBills;
  UnmodifiableListView<Bill> get paidBills => _paidBills;

  Future<void> getBills() async {
    _log.fine('Bills loading');

    _isLoading = true;
    _error = null;

    notifyListeners();

    try {
      final bills = await _repository.getBills();

      _pendingBills = UnmodifiableListView(bills.where((bill) => !bill.paid));
      _paidBills = UnmodifiableListView(bills.where((bill) => bill.paid));

      _log.fine('Bills loaded: ${bills.length}');
    } catch (e) {
      _error = e;
      _log.severe('Error loading bills', e);
    } finally {
      _isLoading = false;

      notifyListeners();
    }
  }

  Future<void> deleteBills() async {
    _log.fine('Deleting all bills');

    await _repository.deleteBills();

    _log.fine('Deleted all bills');
  }

  Future<void> createSampleBills() async {
    final now = DateTime.now();
    final sampleNames = [
      'Electricity Bill',
      'Water Bill',
      'Internet Subscription',
      'Mobile Phone',
      'Car Rental',
      'Groceries',
      'Health Insurance',
      'Gym Membership',
      'Streaming Service',
      'Credit Card Payment',
      'Mortgage',
      'School Fees',
      'Fuel',
      'Property Tax',
      'Home Security',
    ];

    for (var i = 0; i < sampleNames.length; i++) {
      final bill = Bill(
        id: 0,
        name: sampleNames[i],
        value: 50.0 + (i * 25),
        date: DateTime(now.year, now.month, (i * 2 % 28) + 1),
        paid: false,
        notification: true,
        recurrence: true,
      );

      await _repository.addBill(bill);
    }
  }
}
