import 'package:exchanger/components/dropdowns/custom_dropdown.dart';
import 'package:exchanger/components/inputs/custom_text_field.dart';
import 'package:flutter/material.dart';
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

  @override
  void initState() {
    super.initState();
    quantityController = TextEditingController(text: widget.event['amount'].toString());
    rateController = TextEditingController(text: widget.event['rate'].toString());
    totalController = TextEditingController(text: widget.event['total'].toString());
    isUpSelected = widget.event['type'] == 'Продажа';
    isDownSelected = widget.event['type'] == 'Покупка';
    selectedCurrency = widget.event['currency'];
    currencies = [selectedCurrency];
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

  @override
  Widget build(BuildContext context) {
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
                onMenuOpened: () async {
                  final newCurrencies = await ApiService.fetchCurrencies();
                  setState(() {
                    currencies = newCurrencies;
                  });
                },
              ),
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
                    bool status = await _editEvent();
                    if (status) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Запись успешно обновлена')),
                      );
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Не удалось обновить запись')),
                      );
                    }
                    Navigator.pop(context);
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