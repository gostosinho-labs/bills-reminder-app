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
    final dateFormat = DateFormat('MMMM');

    String? currentMonth;

    return ListView.builder(
      itemCount: bills.length,
      itemBuilder: (context, index) {
        final bill = bills[index];
        final month = dateFormat.format(bill.date);

        final bool showMonth = currentMonth != month;

        if (showMonth) {
          currentMonth = month;
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (showMonth)
              Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  month,
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
