import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class TextCurrencyFormField extends StatefulWidget {
  const TextCurrencyFormField({
    super.key,
    required this.controller,
    this.labelText,
    this.helperText,
  });

  final TextEditingController controller;
  final String? labelText;
  final String? helperText;

  @override
  State<TextCurrencyFormField> createState() => _TextCurrencyFormFieldState();
}

class _TextCurrencyFormFieldState extends State<TextCurrencyFormField> {
  @override
  void initState() {
    super.initState();

    widget.controller.value = TextEditingValue(
      text: widget.controller.text.isEmpty ? '0.00' : widget.controller.text,
      selection: TextSelection.collapsed(offset: '0.00'.length),
    );
  }

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: widget.controller,
      keyboardType: TextInputType.number,
      decoration: InputDecoration(
        labelText: widget.labelText,
        border: const OutlineInputBorder(),
        helperText: widget.helperText,
      ),
      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
      onChanged: _onChanged,
    );
  }

  void _onChanged(String value) {
    // Remove non-numeric characters
    String cleanValue = value.replaceAll(RegExp(r'[^0-9]'), '');

    // Parse the cleaned value as an integer
    int parsedValue = int.tryParse(cleanValue) ?? 0;

    // Format the value as currency (without symbol)
    final formattedValue = (parsedValue / 100).toStringAsFixed(2);

    // Update the text field with the formatted value
    widget.controller.value = TextEditingValue(
      text: formattedValue,
      selection: TextSelection.collapsed(offset: formattedValue.length),
    );
  }
}
