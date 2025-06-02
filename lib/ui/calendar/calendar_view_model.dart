import 'dart:collection';

import 'package:bills_reminder/data/repositories/bills/bills_repository.dart';
import 'package:bills_reminder/domain/models/bill.dart';
import 'package:flutter/foundation.dart';
import 'package:logging/logging.dart';

class CalendarViewModel extends ChangeNotifier {
  CalendarViewModel({required BillsRepository repository})
      : _repository = repository;

  final BillsRepository _repository;
  final _log = Logger('CalendarViewModel');

  UnmodifiableListView<Bill> _bills = UnmodifiableListView([]);
  DateTime _selectedMonth = DateTime(
    DateTime.now().year,
    DateTime.now().month,
    1,
  );
  bool _isLoading = false;
  Object? _error;

  bool get isLoading => _isLoading;
  Object? get error => _error;
  UnmodifiableListView<Bill> get bills => _bills;
  DateTime get selectedMonth => _selectedMonth;

  Future<void> getBills() async {
    _log.fine('Bills loading for calendar view');

    _isLoading = true;
    _error = null;

    notifyListeners();

    try {
      final bills = await _repository.getBills();
      _bills = UnmodifiableListView(bills);

      _log.fine('Bills loaded for calendar: ${bills.length}');
    } catch (e) {
      _error = e;
      _log.severe('Error loading bills for calendar', e);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void updateSelectedMonth(DateTime month) {
    _selectedMonth = DateTime(month.year, month.month, 1);
    notifyListeners();
  }

  Map<DateTime, List<Bill>> getBillsForMonth() {
    final billsByDate = <DateTime, List<Bill>>{};

    for (final bill in _bills) {
      // Only consider bills within the selected month.
      if (bill.date.year == _selectedMonth.year && 
          bill.date.month == _selectedMonth.month) {
        final date = DateTime(bill.date.year, bill.date.month, bill.date.day);
        
        if (billsByDate.containsKey(date)) {
          billsByDate[date]!.add(bill);
        } else {
          billsByDate[date] = [bill];
        }
      }
    }

    return billsByDate;
  }
}