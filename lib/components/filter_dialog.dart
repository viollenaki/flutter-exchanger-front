import 'package:flutter/material.dart';
import 'dropdowns/custom_dropdown.dart';
import 'buttons/custom_button.dart';

class FilterDialog extends StatefulWidget {
  final List<String> currencies;
  final String? selectedCurrency;
  final String? selectedType;
  final TimeOfDay? selectedTime; 

  const FilterDialog({
    super.key,
    required this.currencies,
    this.selectedCurrency,
    this.selectedType,
    this.selectedTime,  
  });

  @override
  State<FilterDialog> createState() => _FilterDialogState();
}

class _FilterDialogState extends State<FilterDialog> {
  late String? _selectedCurrency;
  late String? _selectedType;
  late TimeOfDay? _selectedTime;  

  @override
  void initState() {
    super.initState();
    _selectedCurrency = widget.selectedCurrency;
    _selectedType = widget.selectedType;
    _selectedTime = widget.selectedTime;  // Add this
  }

  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime ?? TimeOfDay.now(),
    );
    if (picked != null) {
      setState(() {
        _selectedTime = picked;
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
                    onPressed: () => _selectTime(context),
                    text: _selectedTime == null
                        ? 'Выберите время'
                        : '${_selectedTime!.hour.toString().padLeft(2, '0')}:${_selectedTime!.minute.toString().padLeft(2, '0')}',
                  ),
                ),
                if (_selectedTime != null) ...[
                  const SizedBox(width: 8),
                  IconButton(
                    onPressed: () => setState(() => _selectedTime = null),
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
                    'time': _selectedTime,  // Add this
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