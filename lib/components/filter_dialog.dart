import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'dropdowns/custom_dropdown.dart';
import 'buttons/custom_button.dart';

class FilterDialog extends StatefulWidget {
  final List<String> currencies;
  final String? selectedCurrency;
  final String? selectedType;
  final DateTime? selectedDate;

  const FilterDialog({
    super.key,
    required this.currencies,
    this.selectedCurrency,
    this.selectedType,
    this.selectedDate,
  });

  @override
  State<FilterDialog> createState() => _FilterDialogState();
}

class _FilterDialogState extends State<FilterDialog> {
  late String? _selectedCurrency;
  late String? _selectedType;
  late DateTime? _selectedDate;

  @override
  void initState() {
    super.initState();
    _selectedCurrency = widget.selectedCurrency;
    _selectedType = widget.selectedType;
    _selectedDate = widget.selectedDate;
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Фильтры', style: TextStyle(fontSize: 20)),
            const SizedBox(height: 16),
            CustomDropdown(
              value: _selectedCurrency ?? 'Выберите валюту',
              items: ['Выберите валюту', ...widget.currencies],
              onChanged: (value) {
                setState(() {
                  _selectedCurrency = value == 'Выберите валюту' ? null : value;
                });
              },
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: CustomButton(
                    onPressed: () {
                      setState(() {
                        _selectedType = _selectedType == 'Покупка' ? null : 'Покупка';
                      });
                    },
                    text: 'Покупка${_selectedType == 'Покупка' ? ' ✓' : ''}',
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: CustomButton(
                    onPressed: () {
                      setState(() {
                        _selectedType = _selectedType == 'Продажа' ? null : 'Продажа';
                      });
                    },
                    text: 'Продажа${_selectedType == 'Продажа' ? ' ✓' : ''}',
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: CustomButton(
                    onPressed: () => _selectDate(context),
                    text: _selectedDate == null
                        ? 'Выберите дату'
                        : DateFormat('yyyy-MM-dd').format(_selectedDate!),
                  ),
                ),
                if (_selectedDate != null) ...[
                  const SizedBox(width: 8),
                  IconButton(
                    onPressed: () => setState(() => _selectedDate = null),
                    icon: const Icon(Icons.close, color: Colors.red),
                  ),
                ],
              ],
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Отмена'),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: () => Navigator.pop(context, {
                    'currency': _selectedCurrency,
                    'type': _selectedType,
                    'date': _selectedDate,
                  }),
                  child: const Text('Применить'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}