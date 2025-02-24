import 'package:bills_reminder/domain/models/bill.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class BillListItem extends StatelessWidget {
  const BillListItem({super.key, required this.bill, required this.onTap});

  final Bill bill;
  final VoidCallback onTap;

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
        trailing: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              '\$${bill.value.toStringAsFixed(2)}',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (bill.notification)
                  Icon(
                    Icons.notifications_active,
                    size: 16,
                    color: Colors.grey.shade600,
                  )
                else
                  Icon(
                    Icons.notifications_off,
                    size: 16,
                    color: Colors.grey.shade600,
                  ),
                const SizedBox(width: 4),
                if (bill.recurrence)
                  Icon(Icons.update, size: 20, color: Colors.grey.shade600)
                else
                  Icon(
                    Icons.update_disabled,
                    size: 20,
                    color: Colors.grey.shade600,
                  ),
                const SizedBox(width: 4),
                if (bill.paid)
                  Icon(Icons.check_box, size: 20, color: Colors.grey.shade600)
                else
                  Icon(
                    Icons.check_box_outline_blank,
                    size: 16,
                    color: Colors.grey.shade600,
                  ),
              ],
            ),
          ],
        ),
        onTap: onTap,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }
}
