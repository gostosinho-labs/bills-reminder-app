import 'dart:collection';

import 'package:bills_reminder/domain/models/bill.dart';
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

class _HomeScreenState extends State<HomeScreen>
    with TickerProviderStateMixin, WidgetsBindingObserver {
  late HomeViewModel _viewModel;
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    _viewModel = HomeViewModel(repository: context.read());
    _tabController = TabController(length: 2, vsync: this);

    Future.microtask(() => _viewModel.getBills());
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _tabController.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);

    if (state == AppLifecycleState.resumed) {
      // In case the app keeps running when the next day comes,
      // the bills are refreshed to render the due date correctly.
      _viewModel.getBills();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Bills Reminder'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [Tab(text: 'Pending'), Tab(text: 'Paid')],
        ),
      ),
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
            onPressed: () => _onDeleteAll(context),
            child: const Icon(Icons.delete),
          ),
        ],
      ),
      body: ListenableBuilder(
        listenable: _viewModel,
        builder: (context, child) {
          return TabBarView(
            controller: _tabController,
            children: [
              _buildBillsView(_viewModel.pendingBills),
              _buildBillsView(_viewModel.paidBills),
            ],
          );
        },
      ),
    );
  }

  Widget _buildBillsView(UnmodifiableListView<Bill> bills) {
    if (_viewModel.error != null) {
      return Center(child: Text('Error: ${_viewModel.error}'));
    }

    if (_viewModel.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (bills.isEmpty) {
      return const Center(child: Text('No bills found.'));
    }

    return BillListView(
      bills: bills,
      onEdit: (Bill bill) async {
        await context.push(Routes.editBill(bill.id));
        await _viewModel.getBills();
      },
    );
  }

  Future<void> _onDeleteAll(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Delete All Bills?'),
            content: const Text(
              'Are you sure you want to delete all bills? This action cannot be undone.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: const Text('Delete'),
              ),
            ],
          ),
    );

    if (confirmed == true) {
      await _viewModel.deleteBills();
      await _viewModel.getBills();
    }
  }
}
