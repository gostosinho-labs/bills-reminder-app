import 'package:bills_reminder/data/repositories/bills/bills_repository.dart';
import 'package:bills_reminder/domain/models/bill.dart';
import 'package:flutter/material.dart';
import 'package:logging/logging.dart';

class BillsEditViewModel extends ChangeNotifier {
  BillsEditViewModel({required BillsRepository repository})
    : _repository = repository;

  final BillsRepository _repository;
  final _log = Logger('BillsEditViewModel');

  Bill? _bill;
  bool _isLoading = false;
  Object? _error;

  Bill? get bill => _bill;
  bool get isLoading => _isLoading;
  Object? get error => _error;

  Future<void> loadBill(String id) async {
    _isLoading = true;
    _error = null;

    notifyListeners();

    try {
      _bill = await _repository.getBill(id);
    } catch (e) {
      _error = e;
      _log.severe('Error loading bill', e);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updateBill(Bill bill) async {
    _isLoading = true;
    _error = null;

    notifyListeners();

    try {
      await _repository.updateBill(bill);
    } catch (e) {
      _error = e;
      _log.severe('Error updating bill', e);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
