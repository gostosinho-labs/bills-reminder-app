import 'package:bills_reminder/domain/models/bill.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class BillListItem extends StatelessWidget {
  const BillListItem({super.key, required this.bill});

  final Bill bill;

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat.yMMMd(
      Localizations.localeOf(context).toString(),
    );

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ListTile(
        title: Text(bill.name),
        subtitle: Text(dateFormat.format(bill.date)),
        trailing: Text(
          '\$${bill.value.toStringAsFixed(2)}',
          style: Theme.of(context).textTheme.titleMedium,
        ),
      ),
    );
  }
}
