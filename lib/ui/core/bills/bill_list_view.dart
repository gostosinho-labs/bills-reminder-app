import 'dart:collection';

import 'package:bills_reminder/domain/models/bill.dart';
import 'package:bills_reminder/ui/core/bills/bill_list_item.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class BillListView extends StatelessWidget {
  const BillListView({super.key, required this.bills, required this.onEdit});

  final UnmodifiableListView<Bill> bills;
  final void Function(Bill bill) onEdit;

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('MMMM/yyyy');

    String? currentMonthYear;

    return ListView.separated(
      // The bottom padding is needed or the floating action buttons would cover the last items.
      padding: const EdgeInsets.only(bottom: 192),
      itemCount: bills.length,
      separatorBuilder: (context, index) => const Divider(height: 0),
      itemBuilder: (context, index) {
        final bill = bills[index];
        final monthYear = dateFormat.format(bill.date).toUpperCase();

        final bool showMonthYear = currentMonthYear != monthYear;

        if (showMonthYear) {
          currentMonthYear = monthYear;
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (showMonthYear)
              Container(
                margin: index == 0 ? null : const EdgeInsets.only(top: 24),
                padding: const EdgeInsets.only(
                  left: 16,
                  right: 16,
                  top: 16,
                  bottom: 8,
                ),
                width: double.infinity,
                child: Text(
                  monthYear,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ),
            BillListItem(bill: bill, onTap: () => onEdit(bill)),
          ],
        );
      },
    );
  }
}
