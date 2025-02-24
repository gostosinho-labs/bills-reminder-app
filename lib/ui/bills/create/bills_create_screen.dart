import 'package:bills_reminder/domain/models/bill.dart';
import 'package:bills_reminder/ui/bills/create/bills_create_view_model.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:bills_reminder/ui/core/bills/bills_form.dart';

class BillsCreateScreen extends StatelessWidget {
  const BillsCreateScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final viewModel = BillsCreateViewModel(repository: context.read());

    return Scaffold(
      appBar: AppBar(title: const Text('Create Bill')),
      body: BillsForm(
        onSave: (Bill bill) async {
          await viewModel.createBill(
            name: bill.name,
            value: bill.value,
            date: bill.date,
            notification: bill.notification,
            recurrence: bill.recurrence,
          );

          if (context.mounted) {
            context.pop();
          }
        },
        isEdit: false,
      ),
    );
  }
}
