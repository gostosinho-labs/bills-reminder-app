import 'dart:collection';

import 'package:bills_reminder/domain/models/bill.dart';
import 'package:bills_reminder/ui/core/bills/bill_list_item.dart';
import 'package:flutter/material.dart';

class BillListView extends StatelessWidget {
  const BillListView({super.key, required this.bills, required this.onEdit});

  final UnmodifiableListView<Bill> bills;
  final void Function(Bill bill) onEdit;

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: bills.length,
      itemBuilder: (context, index) {
        final bill = bills[index];

        return BillListItem(bill: bill, onTap: () => onEdit(bill));
      },
    );
  }
}
