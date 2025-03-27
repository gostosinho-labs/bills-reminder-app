import 'package:bills_reminder/domain/models/bill.dart';
import 'package:bills_reminder/ui/bills/edit/bills_edit_view_model.dart';
import 'package:bills_reminder/ui/core/bills/bills_form.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

class BillsEditScreen extends StatefulWidget {
  const BillsEditScreen({super.key, required this.id});

  final String id;

  @override
  State<BillsEditScreen> createState() => _BillsEditScreenState();
}

class _BillsEditScreenState extends State<BillsEditScreen> {
  late final BillsEditViewModel _viewModel;

  @override
  void initState() {
    super.initState();

    _viewModel = BillsEditViewModel(repository: context.read());
    _viewModel.loadBill(widget.id);
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: _viewModel,
      child: Scaffold(
        appBar: AppBar(title: const Text('Edit Bill')),
        body: ListenableBuilder(
          listenable: _viewModel,
          builder: (context, _) {
            if (_viewModel.isLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            if (_viewModel.error != null) {
              return Center(child: Text('Error: ${_viewModel.error}'));
            }

            return _viewModel.bill == null
                ? const Center(child: Text('Bill not found'))
                : BillsForm(
                  bill: _viewModel.bill,
                  isEdit: true,
                  onSave: (Bill bill) async {
                    await _viewModel.updateBill(bill);

                    if (context.mounted) {
                      context.pop();
                    }
                  },
                );
          },
        ),
      ),
    );
  }
}
