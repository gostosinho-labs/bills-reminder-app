import 'package:bills_reminder/domain/models/bill.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

class BillsForm extends StatefulWidget {
  const BillsForm({
    super.key,
    required this.onSave,
    required this.onDelete,
    required this.isEdit,
    this.bill,
  });

  final Function(Bill bill) onSave;
  final Function(Bill bill)? onDelete;
  final bool isEdit;
  final Bill? bill;

  @override
  State<BillsForm> createState() => _BillsFormState();
}

class _BillsFormState extends State<BillsForm> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _valueController = TextEditingController();
  final _dateController = TextEditingController();

  late DateTime _date;
  late bool _notification;
  late bool _recurrence;
  late bool _paid;

  @override
  void initState() {
    super.initState();

    final bill = widget.bill;

    _date = bill?.date ?? DateTime.now();
    _notification = bill?.notification ?? false;
    _recurrence = bill?.recurrence ?? false;
    _paid = bill?.paid ?? false;

    _nameController.text = bill?.name ?? '';
    _valueController.text = bill?.value?.toStringAsFixed(2) ?? '';
    _dateController.text = DateFormat.yMMMd().format(_date);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _valueController.dispose();
    _dateController.dispose();

    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime.now(),
      lastDate: DateTime(DateTime.now().year + 1),
    );

    if (picked != null && picked != _date) {
      setState(() {
        _date = picked;
        _dateController.text = DateFormat.yMMMd().format(_date);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Column(
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: TextFormField(
                  autofocus: !widget.isEdit,
                  controller: _nameController,
                  decoration: const InputDecoration(
                    labelText: 'Bill Name',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a bill name';
                    }
                    return null;
                  },
                  textInputAction: TextInputAction.next,
                ),
              ),
              const SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: TextFormField(
                  controller: _valueController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Bill Value',
                    border: OutlineInputBorder(),
                    helperText: 'Leave empty for bills with variable value',
                  ),
                  validator: (value) {
                    if (value != null && value.isNotEmpty) {
                      if (double.tryParse(value) == null) {
                        return 'Please enter a valid number';
                      }
                    }
                    return null;
                  },
                  textInputAction: TextInputAction.next,
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(
                      RegExp(r'^\d+\.?\d{0,2}'),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: TextFormField(
                  controller: _dateController,
                  decoration: InputDecoration(
                    labelText: 'Date',
                    border: const OutlineInputBorder(),
                    suffixIcon: const Icon(Icons.calendar_today),
                  ),
                  readOnly: true,
                  onTap: () => _selectDate(context),
                ),
              ),
              const SizedBox(height: 16),
              CheckboxListTile(
                title: const Text('Notification'),
                subtitle: const Text('Sent at 08:00 AM'),
                value: _notification,
                onChanged: (value) {
                  setState(() {
                    _notification = value!;
                  });
                },
              ),
              CheckboxListTile(
                title: const Text('Monthly Recurrence'),
                subtitle: const Text(
                  'When paid, reschedule for the next month',
                ),
                value: _recurrence,
                onChanged: (value) {
                  setState(() {
                    _recurrence = value!;
                  });
                },
              ),
              if (widget.isEdit)
                CheckboxListTile(
                  title: const Text('Paid'),
                  value: _paid,
                  onChanged: (value) {
                    setState(() {
                      _paid = value!;
                    });
                  },
                ),
              const SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        final bill = Bill(
                          id: widget.bill?.id ?? 0,
                          name: _nameController.text,
                          value:
                              _valueController.text.isNotEmpty
                                  ? double.parse(_valueController.text)
                                  : null,
                          date: _date,
                          notification: _notification,
                          recurrence: _recurrence,
                          paid: _paid,
                        );

                        widget.onSave(bill);
                      }
                    },
                    child: Text('Save Bill'),
                  ),
                ),
              ),
              if (widget.isEdit) ...[
                const SizedBox(height: 8),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: SizedBox(
                    width: double.infinity,
                    child: OutlinedButton(
                      onPressed: () {
                        final bill = Bill(
                          id: widget.bill?.id ?? 0,
                          name: _nameController.text,
                          value:
                              _valueController.text.isNotEmpty
                                  ? double.parse(_valueController.text)
                                  : null,
                          date: _date,
                          notification: _notification,
                          recurrence: _recurrence,
                          paid: _paid,
                        );

                        widget.onDelete?.call(bill);
                      },
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(
                          color: Theme.of(context).colorScheme.primary,
                        ),
                        foregroundColor: Theme.of(context).colorScheme.primary,
                      ),
                      child: const Text('Delete Bill'),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
