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

    final homeViewModel = widget._viewModel;

    homeViewModel.getBills();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Bills Reminder')),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await widget._viewModel.addBill();
        },
        child: const Icon(Icons.add),
      ),
      body: StreamBuilder(
        stream: widget._viewModel.bills,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final bills = snapshot.data!;

          if (bills.isEmpty) {
            return const Center(child: Text('No bills found.'));
          }

          return BillListView(bills: bills);
        },
      ),
    );
  }

  @override
  void dispose() {
    widget._viewModel.dispose();
    super.dispose();
  }
}
