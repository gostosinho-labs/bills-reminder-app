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

  Future<void> deleteBills() async {
    _log.fine('Deleting all bills');

    await _repository.deleteBills();

    _log.fine('Deleted all bills');
  }
}
