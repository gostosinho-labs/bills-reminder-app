import 'package:bills_reminder/domain/models/bill.dart';
import 'package:bills_reminder/routing/routes.dart';
import 'package:bills_reminder/ui/calendar/calendar_view_model.dart';
import 'package:bills_reminder/ui/core/bills/bill_list_item.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  late CalendarViewModel _viewModel;
  late List<DateTime> _daysInMonth;

  @override
  void initState() {
    super.initState();
    _viewModel = CalendarViewModel(repository: context.read());
    _daysInMonth = _getDaysInMonth(_viewModel.selectedMonth);

    Future.microtask(() => _viewModel.getBills());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Calendar')),
      body: ListenableBuilder(
        listenable: _viewModel,
        builder: (context, child) {
          if (_viewModel.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (_viewModel.error != null) {
            return Center(child: Text('Error: ${_viewModel.error}'));
          }

          final billsMap = _viewModel.getBillsForMonth();

          return Column(
            children: [
              _buildMonthPicker(),
              _buildCalendarHeader(),
              _buildCalendarGrid(billsMap),
              _buildCalendarFooter(),
            ],
          );
        },
      ),
    );
  }

  Widget _buildMonthPicker() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton.outlined(
            icon: const Icon(Icons.chevron_left),
            onPressed: () => _changeMonth(-1),
          ),
          OutlinedButton(
            onPressed: _showMonthYearPicker,
            child: Text(DateFormat.yMMMM().format(_viewModel.selectedMonth)),
          ),
          IconButton.outlined(
            icon: const Icon(Icons.chevron_right),
            onPressed: () => _changeMonth(1),
          ),
        ],
      ),
    );
  }

  Widget _buildCalendarHeader() {
    final weekDays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Row(
        children: [
          for (final day in weekDays)
            Expanded(
              child: Text(
                day,
                style: const TextStyle(fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildCalendarGrid(Map<DateTime, List<Bill>> billsMap) {
    return Expanded(
      child: GestureDetector(
        onHorizontalDragEnd: (details) {
          if (details.primaryVelocity! > 0) {
            _changeMonth(-1);
          } else {
            _changeMonth(1);
          }
        },
        child: GridView.builder(
          padding: const EdgeInsets.all(16.0),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 7,
            childAspectRatio: 1.0,
          ),
          itemCount: _daysInMonth.length,
          itemBuilder: (context, index) {
            final date = _daysInMonth[index];
            final isToday = _isToday(date);
            final billsForDay =
                billsMap[DateTime(date.year, date.month, date.day)] ?? [];
            final unpaidBills = billsForDay.any((x) => !x.paid);
            final isCurrentMonth = date.month == _viewModel.selectedMonth.month;

            final theme = Theme.of(context);
            final primaryColor = theme.colorScheme.primary;

            return GestureDetector(
              onTap: () {
                if (isCurrentMonth) {
                  _showBillsForDay(date, billsMap);
                }
              },
              child: Container(
                decoration: BoxDecoration(
                  color: isToday ? primaryColor.withValues(alpha: 0.1) : null,
                  border: isToday
                      ? Border.all(color: primaryColor, width: 1)
                      : null,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      '${date.day}',
                      style: TextStyle(
                        color: !isCurrentMonth
                            ? theme.colorScheme.onSurface.withValues(alpha: 0.5)
                            : isToday
                            ? primaryColor
                            : theme.colorScheme.onSurface,
                      ),
                    ),
                    Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: billsForDay.isNotEmpty && isCurrentMonth
                            ? unpaidBills
                                  ? theme.colorScheme.primary
                                  : theme.colorScheme.outline
                            : null,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildCalendarFooter() {
    return SafeArea(
      child: Text(
        'Swipe horizontally to change month.',
        style: Theme.of(context).textTheme.bodySmall,
      ),
    );
  }

  void _changeMonth(int months) {
    final newMonth = DateTime(
      _viewModel.selectedMonth.year,
      _viewModel.selectedMonth.month + months,
      1,
    );
    _viewModel.updateSelectedMonth(newMonth);
    setState(() {
      _daysInMonth = _getDaysInMonth(newMonth);
    });
  }

  void _showMonthYearPicker() async {
    final ThemeData theme = Theme.of(context);
    final initialDate = _viewModel.selectedMonth;

    showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
      initialDatePickerMode: DatePickerMode.year,
      builder: (context, child) {
        return Theme(
          data: theme.copyWith(
            colorScheme: theme.colorScheme.copyWith(
              surface: theme.colorScheme.surface,
            ),
          ),
          child: child!,
        );
      },
    ).then((pickedDate) {
      if (pickedDate != null) {
        final newMonth = DateTime(pickedDate.year, pickedDate.month, 1);
        _viewModel.updateSelectedMonth(newMonth);
        setState(() {
          _daysInMonth = _getDaysInMonth(newMonth);
        });
      }
    });
  }

  bool _isToday(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year &&
        date.month == now.month &&
        date.day == now.day;
  }

  List<DateTime> _getDaysInMonth(DateTime month) {
    final firstDay = DateTime(month.year, month.month, 1);
    final lastDay = DateTime(month.year, month.month + 1, 0);

    // Find the first Monday before the first day of the month
    final firstMonday = firstDay.weekday == DateTime.monday
        ? firstDay
        : firstDay.subtract(Duration(days: firstDay.weekday - 1));

    // Find the last Sunday after the last day of the month
    final lastSunday = lastDay.weekday == DateTime.sunday
        ? lastDay
        : lastDay.add(Duration(days: 7 - lastDay.weekday));

    // Generate all days from first Monday to last Sunday
    final daysInView = <DateTime>[];
    for (
      var day = firstMonday;
      day.isBefore(lastSunday.add(const Duration(days: 1)));
      day = day.add(const Duration(days: 1))
    ) {
      daysInView.add(day);
    }

    return daysInView;
  }

  void _showBillsForDay(DateTime day, Map<DateTime, List<Bill>> billsMap) {
    final date = DateTime(day.year, day.month, day.day);
    final bills = billsMap[date] ?? [];

    if (bills.isEmpty) {
      final scaffoldMessenger = ScaffoldMessenger.of(context);
      final snackBar = const SnackBar(content: Text('No bills for this day.'));

      scaffoldMessenger.showSnackBar(snackBar);

      return;
    }

    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                DateFormat.yMMMMd().format(date),
                style: Theme.of(context).textTheme.titleLarge,
              ),
            ),
            Expanded(
              child: ListView.separated(
                shrinkWrap: true,
                itemCount: bills.length,
                separatorBuilder: (context, index) => const Divider(height: 0),
                itemBuilder: (context, index) {
                  final bill = bills[index];
                  return BillListItem(
                    bill: bill,
                    hideDate: true,
                    onTap: () async {
                      await context.push(Routes.editBill(bill.id));
                      await _viewModel.getBills();
                    },
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }
}
