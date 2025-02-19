import 'package:bills_reminder/ui/core/bills/bill_list_view.dart';
import 'package:bills_reminder/ui/home/home_view_model.dart';
import 'package:flutter/material.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key, required HomeViewModel viewModel})
    : _viewModel = viewModel;

  final HomeViewModel _viewModel;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    widget._viewModel.getBills();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Bills Reminder')),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await widget._viewModel.addBill();
          await widget._viewModel.getBills();
        },
        child: const Icon(Icons.add),
      ),
      body: ListenableBuilder(
        listenable: widget._viewModel,
        builder: (context, _) {
          if (widget._viewModel.error != null) {
            return Center(child: Text('Error: ${widget._viewModel.error}'));
          }

          if (widget._viewModel.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          final bills = widget._viewModel.bills;

          if (bills.isEmpty) {
            return const Center(child: Text('No bills found.'));
          }

          return BillListView(bills: bills);
        },
      ),
    );
  }
}
