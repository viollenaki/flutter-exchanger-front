import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:exchanger/styles/app_theme.dart';
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
    final theme = Theme.of(context);
    
    if (theme.isIOS) {
      return CupertinoAlertDialog(
        title: const Text('Фильтры'),
        content: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
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
              CustomButton(
                onPressed: () async {
                  await showCupertinoModalPopup(
                    context: context,
                    builder: (BuildContext context) {
                      return Container(
                        height: 300,
                        color: CupertinoColors.systemBackground.resolveFrom(context),
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                CupertinoButton(
                                  child: const Text('Отмена'),
                                  onPressed: () => Navigator.pop(context),
                                ),
                                CupertinoButton(
                                  child: const Text('Готово'),
                                  onPressed: () {
                                    Navigator.pop(context);
                                  },
                                ),
                              ],
                            ),
                            Expanded(
                              child: CupertinoDatePicker(
                                mode: CupertinoDatePickerMode.time,
                                use24hFormat: true,
                                initialDateTime: DateTime.now(),
                                onDateTimeChanged: (DateTime newDateTime) {
                                  setState(() {
                                    _selectedTime = TimeOfDay.fromDateTime(newDateTime);
                                  });
                                },
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  );
                },
                text: _selectedTime == null
                    ? 'Выберите время'
                    : '${_selectedTime!.hour.toString().padLeft(2, '0')}:${_selectedTime!.minute.toString().padLeft(2, '0')}',
              ),
              if (_selectedTime != null) ...[
                const SizedBox(height: 8),
                CupertinoButton(
                  padding: EdgeInsets.zero,
                  onPressed: () => setState(() => _selectedTime = null),
                  child: const Icon(CupertinoIcons.clear_circled, color: CupertinoColors.systemRed),
                ),
              ],
            ],
          ),
        ),
        actions: [
          CupertinoDialogAction(
            child: const Text('Отмена'),
            onPressed: () => Navigator.pop(context),
          ),
          CupertinoDialogAction(
            child: const Text('Применить'),
            onPressed: () => Navigator.pop(context, {
              'currency': _selectedCurrency,
              'type': _selectedType,
              'time': _selectedTime,
            }),
          ),
        ],
      );
    } else {
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
}