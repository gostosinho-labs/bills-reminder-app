import 'package:bills_reminder/domain/models/bill.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class BillListItem extends StatelessWidget {
  const BillListItem({super.key, required this.bill, required this.onTap});

  final Bill bill;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final locale = Localizations.localeOf(context).toString();
    final dateFormat = DateFormat.MMMd(locale);
    final numberFormat = NumberFormat.simpleCurrency(locale: locale);

    final isDue = bill.date.isBefore(DateTime.now());
    final isPaid = bill.paid;

    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    bill.name,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  Text(
                    dateFormat.format(bill.date),
                    style: TextStyle(
                      color: !isPaid && isDue ? Colors.red : null,
                      fontWeight: !isPaid && isDue ? FontWeight.bold : null,
                    ),
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  bill.value != null ? numberFormat.format(bill.value) : '',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      bill.notification
                          ? Icons.notifications_active
                          : Icons.notifications_off,
                      size: 16,
                      color: Colors.grey.shade600,
                    ),
                    const SizedBox(width: 2),
                    Icon(
                      bill.recurrence ? Icons.update : Icons.update_disabled,
                      size: 16,
                      color: Colors.grey.shade600,
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
