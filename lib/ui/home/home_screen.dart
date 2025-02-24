import 'package:bills_reminder/routing/routes.dart';
import 'package:bills_reminder/ui/core/bills/bill_list_view.dart';
import 'package:bills_reminder/ui/home/home_view_model.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late HomeViewModel _viewModel;

  @override
  void initState() {
    super.initState();

    _viewModel = HomeViewModel(repository: context.read());

    Future.microtask(() => _viewModel.getBills());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Bills Reminder')),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton(
            heroTag: 'add',
            onPressed: () async {
              await context.push(Routes.createBill);
              await _viewModel.getBills();
            },
            child: const Icon(Icons.add),
          ),
          const SizedBox(height: 16),
          FloatingActionButton(
            heroTag: 'delete',
            onPressed: () async {
              await _viewModel.deleteBills();
              await _viewModel.getBills();
            },
            child: const Icon(Icons.delete),
          ),
        ],
      ),
      body: ListenableBuilder(
        listenable: _viewModel,
        builder: (context, _) {
          if (_viewModel.error != null) {
            return Center(child: Text('Error: ${_viewModel.error}'));
          }

          if (_viewModel.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          final bills = _viewModel.bills;

          if (bills.isEmpty) {
            return const Center(child: Text('No bills found.'));
          }

          return BillListView(bills: bills);
        },
      ),
    );
  }
}
