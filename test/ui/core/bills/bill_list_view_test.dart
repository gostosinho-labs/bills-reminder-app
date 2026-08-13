import 'dart:collection';

import 'package:bills_reminder/domain/models/bill.dart';
import 'package:bills_reminder/ui/core/bills/bill_list_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/intl.dart';

void main() {
  Bill buildBill({required int id, required int month, required int day}) {
    return Bill(
      id: id,
      name: 'Bill $id',
      date: DateTime(2024, month, day),
      notification: false,
      recurrence: false,
      paid: false,
      value: 10,
    );
  }

  String monthYearOf(int month) {
    return DateFormat('MMMM/yyyy').format(DateTime(2024, month)).toUpperCase();
  }

  Widget buildTestWidget(List<Bill> bills, {double height = 400}) {
    return MaterialApp(
      home: Scaffold(
        body: SizedBox(
          height: height,
          child: BillListView(
            bills: UnmodifiableListView(bills),
            onEdit: (_) {},
          ),
        ),
      ),
    );
  }

  testWidgets('shows a single header for a group of same-month bills', (
    tester,
  ) async {
    // Arrange
    final bills = [
      buildBill(id: 1, month: 1, day: 5),
      buildBill(id: 2, month: 1, day: 10),
      buildBill(id: 3, month: 1, day: 15),
    ];

    // Act
    await tester.pumpWidget(buildTestWidget(bills));

    // Assert
    expect(find.text(monthYearOf(1)), findsOneWidget);
  });

  testWidgets('shows a header for each month when it changes', (
    tester,
  ) async {
    // Arrange
    final bills = [
      buildBill(id: 1, month: 1, day: 5),
      buildBill(id: 2, month: 2, day: 5),
      buildBill(id: 3, month: 3, day: 5),
    ];

    // Act
    await tester.pumpWidget(buildTestWidget(bills));

    // Assert
    expect(find.text(monthYearOf(1)), findsOneWidget);
    expect(find.text(monthYearOf(2)), findsOneWidget);
    expect(find.text(monthYearOf(3)), findsOneWidget);
  });

  testWidgets(
    'keeps every month header exactly once after scrolling to the bottom '
    'and back to the top',
    (tester) async {
      // Arrange: enough items across multiple months, in a short viewport, so
      // the list lazily disposes and rebuilds items while scrolling instead
      // of keeping every item alive at once.
      final bills = [
        for (var month = 1; month <= 6; month++)
          for (var day = 1; day <= 5; day++)
            buildBill(id: month * 10 + day, month: month, day: day),
      ];

      await tester.pumpWidget(buildTestWidget(bills));

      // Act: scroll all the way down, then all the way back up.
      await tester.scrollUntilVisible(
        find.text('Bill ${bills.last.id}'),
        200,
        scrollable: find.byType(Scrollable),
      );
      await tester.pumpAndSettle();

      await tester.scrollUntilVisible(
        find.text('Bill ${bills.first.id}'),
        -200,
        scrollable: find.byType(Scrollable),
      );
      await tester.pumpAndSettle();

      // Assert: the January header is still shown exactly once, and it sits
      // above the first bill of January (day 1) rather than above some other
      // (later) bill in the group, which is how the stale-state bug
      // manifested: the header attaching to the wrong item after the list
      // rebuilt items out of ascending order while scrolling back up.
      expect(find.text(monthYearOf(1)), findsOneWidget);
      final headerY = tester.getTopLeft(find.text(monthYearOf(1))).dy;
      final firstBillY = tester.getTopLeft(find.text('Bill 11')).dy;
      expect(headerY, lessThan(firstBillY));
    },
  );
}
