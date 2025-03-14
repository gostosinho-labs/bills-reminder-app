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

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  late HomeViewModel _viewModel;
  late TabController _tabController;

  @override
  void initState() {
    super.initState();

    _viewModel = HomeViewModel(repository: context.read());
    _tabController = TabController(length: 2, vsync: this);

    Future.microtask(() => _viewModel.getBills());
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
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
}
