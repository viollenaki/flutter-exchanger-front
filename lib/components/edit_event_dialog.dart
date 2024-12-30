import 'package:exchanger/components/dropdowns/custom_dropdown.dart';
import 'package:exchanger/components/inputs/custom_text_field.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:exchanger/styles/app_theme.dart';
import '../../services/api_service.dart';

import 'buttons/icon_toggle_button.dart';

class EditEventDialog extends StatefulWidget {
  final Map<String, dynamic> event;

  const EditEventDialog({super.key, required this.event});

  @override
  State<EditEventDialog> createState() => _EditEventDialogState();
}

class _EditEventDialogState extends State<EditEventDialog> {
  late final TextEditingController quantityController;
  late final TextEditingController rateController;
  late final TextEditingController totalController;
  late bool isUpSelected;
  late bool isDownSelected;
  late String selectedCurrency;
  List<String> currencies = [];
  final formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    quantityController = TextEditingController(text: widget.event['amount'].toString());
    rateController = TextEditingController(text: widget.event['rate'].toString());
    totalController = TextEditingController(text: widget.event['total'].toString());
    isUpSelected = widget.event['type'] == 'Продажа';
    isDownSelected = widget.event['type'] == 'Покупка';
    selectedCurrency = widget.event['currency'];
    // Initialize with current currency and fetch all currencies immediately
    currencies = [selectedCurrency];
    _fetchCurrencies();
  }

  Future<void> _fetchCurrencies() async {
    try {
      final newCurrencies = await ApiService.fetchCurrencies();
      if (mounted) {
        setState(() {
          currencies = newCurrencies;
        });
      }
    } catch (e) {
      debugPrint('Error fetching currencies: $e');
    }
  }

  @override
  void dispose() {
    quantityController.dispose();
    rateController.dispose();
    totalController.dispose();
    super.dispose();
  }

  void calculateTotal() {
    final double quantity = double.tryParse(quantityController.text) ?? 0;
    final double rate = double.tryParse(rateController.text) ?? 0;
    final double total = quantity * rate;
    totalController.text = total.toStringAsFixed(2);
  }

  Future <bool> _editEvent() async {
    final String type = isUpSelected ? 'Продажа' : 'Покупка';
    final double amount = double.tryParse(quantityController.text) ?? 0;
    final double rate = double.tryParse(rateController.text) ?? 0;
    final double total = double.tryParse(totalController.text) ?? 0;
    bool status = await ApiService.editEvent(
      widget.event['id'],
      type,
      selectedCurrency,
      amount,
      rate,
      total,
    );
    return status;
  }

  String? _validateField(String? value, String fieldName) {
    if (value == null || value.isEmpty) {
      return 'Введите $fieldName';
    }
    if (double.tryParse(value) == null) {
      return 'Введите корректное число';
    }
    return null;
  }

  Widget _buildForm(BuildContext context) {
    final theme = Theme.of(context);
    
    if (theme.isIOS) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconToggleButton(
                icon: Icons.arrow_upward,
                isSelected: isUpSelected,
                onPressed: () => setState(() {
                  isUpSelected = true;
                  isDownSelected = false;
                }),
              ),
              SizedBox(width: 16),
              IconToggleButton(
                icon: Icons.arrow_downward,
                isSelected: isDownSelected,
                onPressed: () => setState(() {
                  isUpSelected = false;
                  isDownSelected = true;
                }),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Material(
            type: MaterialType.transparency,
            child: CustomDropdown(
              value: selectedCurrency,
              items: currencies,
              onChanged: (value) => setState(() => selectedCurrency = value!),
              // Remove onMenuOpened since we're fetching currencies on init
              onMenuOpened: null,
            ),
          ),
          const SizedBox(height: 16),
          CupertinoTextField(
            controller: quantityController,
            placeholder: 'Количество',
            onChanged: (value) => calculateTotal(),
            keyboardType: TextInputType.numberWithOptions(decimal: true),
            style: const TextStyle(color: CupertinoColors.white),
            decoration: BoxDecoration(
              border: Border.all(color: CupertinoColors.systemGrey),
              borderRadius: BorderRadius.circular(8.0),
            ),
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
          ),
          const SizedBox(height: 16),
          CupertinoTextField(
            controller: rateController,
            placeholder: 'Курс',
            onChanged: (value) => calculateTotal(),
            keyboardType: TextInputType.numberWithOptions(decimal: true),
            style: const TextStyle(color: CupertinoColors.white),
            decoration: BoxDecoration(
              border: Border.all(color: CupertinoColors.systemGrey),
              borderRadius: BorderRadius.circular(8.0),
            ),
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
          ),
          const SizedBox(height: 16),
          CupertinoTextField(
            controller: totalController,
            placeholder: 'Общий',
            readOnly: true,
            style: const TextStyle(color: CupertinoColors.white),
            decoration: BoxDecoration(
              border: Border.all(color: CupertinoColors.systemGrey),
              borderRadius: BorderRadius.circular(8.0),
            ),
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
          ),
        ],
      );
    } else {
      return Form(
        key: formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconToggleButton(
                  icon: Icons.arrow_upward,
                  isSelected: isUpSelected,
                  onPressed: () => setState(() {
                    isUpSelected = true;
                    isDownSelected = false;
                  }),
                ),
                SizedBox(width: 16),
                IconToggleButton(
                  icon: Icons.arrow_downward,
                  isSelected: isDownSelected,
                  onPressed: () => setState(() {
                    isUpSelected = false;
                    isDownSelected = true;
                  }),
                ),
              ],
            ),
            const SizedBox(height: 16),
            CustomDropdown(
              value: selectedCurrency,
              items: currencies,
              onChanged: (value) => setState(() => selectedCurrency = value!),
              // Remove onMenuOpened since we're fetching currencies on init
              onMenuOpened: null,
            ),
            const SizedBox(height: 16),
            CustomTextField(
              controller: quantityController,
              hintText: 'Количество',
              onChanged: (value) => calculateTotal(),
            ),
            const SizedBox(height: 16),
            CustomTextField(
              controller: rateController,
              hintText: 'Курс',
              onChanged: (value) => calculateTotal(),
            ),
            const SizedBox(height: 16),
            CustomTextField(
              controller: totalController,
              hintText: 'Общий',
              readOnly: true,
            ),
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    if (theme.isIOS) {
      return CupertinoAlertDialog(
        title: const Text('Редактировать запись'),
        content: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16.0),
          child: _buildForm(context),
        ),
        actions: [
          CupertinoDialogAction(
            child: const Text('Отмена'),
            onPressed: () => Navigator.pop(context),
          ),
          CupertinoDialogAction(
            child: const Text('Сохранить'),
            onPressed: () async {
              if (_validateField(quantityController.text, 'количество') == null &&
                  _validateField(rateController.text, 'курс') == null) {
                bool status = await _editEvent();
                if (status) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Запись успешно обновлена')),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Не удалось обновить запись')),
                  );
                }
                Navigator.pop(context);
              }
            },
          ),
        ],
      );
    } else {
      return Dialog(
        backgroundColor: Colors.grey[900],
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Редактировать запись',
                style: TextStyle(color: Colors.white, fontSize: 18),
              ),
              const SizedBox(height: 16),
              _buildForm(context),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text('Отмена'),
                  ),
                  SizedBox(width: 16),
                  ElevatedButton(
                    onPressed: () async {
                      if (formKey.currentState!.validate()) {
                        bool status = await _editEvent();
                        if (status) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Запись успешно обновлена')),
                          );
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Не удалось обновить запись')),
                          );
                        }
                        Navigator.pop(context);
                      }
                    },
                    child: Text('Сохранить'),
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