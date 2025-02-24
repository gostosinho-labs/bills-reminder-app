import 'package:bills_reminder/domain/models/bill.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

class BillsForm extends StatefulWidget {
  const BillsForm({
    super.key,
    required this.onSave,
    required this.isEdit,
    this.bill,
  });

  final Function(Bill bill) onSave;
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
    _valueController.text = bill?.value.toStringAsFixed(2) ?? '';
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
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: <Widget>[
              TextFormField(
                autofocus: true,
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
              const SizedBox(height: 16),
              TextFormField(
                controller: _valueController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Bill Value',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a bill value';
                  }
                  if (double.tryParse(value) == null) {
                    return 'Please enter a valid number';
                  }
                  return null;
                },
                textInputAction: TextInputAction.next,
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
                ],
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _dateController,
                decoration: const InputDecoration(
                  labelText: 'Date',
                  border: OutlineInputBorder(),
                  suffixIcon: Icon(Icons.calendar_today),
                ),
                readOnly: true,
                onTap: () => _selectDate(context),
              ),
              const SizedBox(height: 16),
              CheckboxListTile(
                title: const Text('Notification'),
                value: _notification,
                onChanged: (value) {
                  setState(() {
                    _notification = value!;
                  });
                },
              ),
              CheckboxListTile(
                title: const Text('Monthly Recurrence'),
                value: _recurrence,
                onChanged: (value) {
                  setState(() {
                    _recurrence = value!;
                  });
                },
              ),
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
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      final bill = Bill(
                        name: _nameController.text,
                        value: double.parse(_valueController.text),
                        date: _date,
                        notification: _notification,
                        recurrence: _recurrence,
                        paid: _paid,
                      );

                      widget.onSave(bill);
                    }
                  },
                  child: Text(widget.isEdit ? 'Edit Bill' : 'Create Bill'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
