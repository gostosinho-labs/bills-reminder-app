import 'package:bills_reminder/testing/fakes/repositories/fake_booking_repository.dart';
import 'package:bills_reminder/ui/home/home_view_model.dart';
import 'package:test/test.dart';

void main() {
  test('get bills', () async {
    // Arrange
    final repository = FakeBookingRepository();
    final viewModel = HomeViewModel(repository: repository);

    // Act
    await viewModel.getBills();

    // Assert
    expect(viewModel.bills.length, 2);
  });
}
