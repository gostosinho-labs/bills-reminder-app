import 'dart:collection';

import 'package:bills_reminder/domain/models/bill.dart';
import 'package:bills_reminder/testing/fakes/repositories/fake_booking_repository.dart';

import 'bills_repository.dart';

class BillsRepositoryLocal implements BillsRepository {
  BillsRepositoryLocal({required FakeBookingRepository fakeRepository})
    : _fakeRepository = fakeRepository;

  final FakeBookingRepository _fakeRepository;

  @override
  Future<UnmodifiableListView<Bill>> getBills() {
    return _fakeRepository.getBills();
  }

  @override
  Future<void> addBill(Bill bill) {
    return _fakeRepository.addBill(bill);
  }
}
