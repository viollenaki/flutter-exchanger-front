import 'package:flutter/material.dart';
import '../../components/loading/shimmer_loading.dart';
import '../../services/api_service.dart';
import '../../components/buttons/icon_toggle_button.dart';
import '../../components/dropdowns/custom_dropdown.dart';
import '../../components/inputs/custom_text_field.dart';
import 'package:intl/intl.dart';

class EventsScreen extends StatefulWidget {
  const EventsScreen({super.key});

  @override
  State<EventsScreen> createState() => _EventsScreenState();
}

class _EventsScreenState extends State<EventsScreen> with SingleTickerProviderStateMixin {
  bool _isLoading = true;
  List<dynamic> _events = [];
  int? _selectedRowIndex; // Добавляем индекс выбранной строки
  late AnimationController _animationController;  // Добавляем контроллер анимации

  final Map<String, String> _headerTitles = {
    'date': 'Дата',
    'type': 'Тип',
    'currency': 'Валюта',
    'amount': 'Количество',
    'rate': 'Курс',
    'total': 'Итого',
  };

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 150), // Изменили с 300 на 150
      vsync: this,
    );
    _fetchEvents();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _fetchEvents() async {
    try {
      final events = await ApiService.fetchEvents();
      setState(() {
        _events = events;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading events: $e')),
      );
    }
  }

  Future<bool?> _showDeleteConfirmation() async { // Changed return type to Future<bool?>
    return showGeneralDialog<bool>( // Added type parameter <bool>
      context: context,
      barrierDismissible: true,
      barrierLabel: '',
      transitionDuration: const Duration(milliseconds: 200),
      pageBuilder: (context, animation1, animation2) => Container(),
      transitionBuilder: (context, animation, secondaryAnimation, child) {
        final curvedAnimation = CurvedAnimation(
          parent: animation,
          curve: Curves.easeOutBack,
        );

        return ScaleTransition(
          scale: Tween<double>(begin: 0.8, end: 1.0).animate(curvedAnimation),
          child: FadeTransition(
            opacity: animation,
            child: AlertDialog(
              backgroundColor: Colors.grey[900],
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              title: const Text(
                'Реально???',
                style: TextStyle(color: Colors.white),
              ),
              content: const Text(
                '?!?!?!?!',
                style: TextStyle(color: Colors.white70),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  child: const Text('неее :)'),
                ),
                TextButton(
                  onPressed: () => Navigator.of(context).pop(true),
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.red,
                  ),
                  child: const Text('ага :O'),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _showEditDialog(Map<String, dynamic> event) async {
  await showDialog(
    context: context,
    builder: (context) => _EditEventDialog(event: event),
  );
}

  Widget _buildActionButtons() {
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return SizeTransition(
          sizeFactor: _animationController,
          child: FadeTransition(
            opacity: _animationController,
            child: Container(
              height: 60,
              padding: const EdgeInsets.only(bottom: 16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton.icon(
                    onPressed: () {
                      if (_selectedRowIndex != null) {
                        _showEditDialog(_events[_selectedRowIndex!]);
                      }
                    },
                    icon: const Icon(Icons.edit),
                    label: const Text('Редактировать'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      elevation: 4,
                    ),
                  ),
                  const SizedBox(width: 16),
                  ElevatedButton.icon(
                    onPressed: () async {
                      final shouldDelete = await _showDeleteConfirmation();
                      if (shouldDelete == true) {
                        // TODO: Implement delete functionality
                        print('Deleting item at index $_selectedRowIndex');
                      }
                    },
                    icon: const Icon(Icons.delete),
                    label: const Text('Удалить'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      elevation: 4,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void _handleRowSelection(int index) {
    setState(() {
      if (_selectedRowIndex == index) {
        _selectedRowIndex = null;
        _animationController.reverse();
      } else {
        _selectedRowIndex = index;
        _animationController.forward();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('События'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      extendBodyBehindAppBar: true,
      body: SafeArea(
        child: _isLoading
            ? Column(
                children: List.generate(
                  10,
                  (index) => Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16.0,
                      vertical: 8.0,
                    ),
                    child: ShimmerLoading(
                      width: double.infinity,
                      height: 50,
                    ),
                  ),
                ),
              )
            : Padding(
                padding: const EdgeInsets.all(16.0),
                child: SizedBox(
                  height: MediaQuery.of(context).size.height - 100, // Высота экрана минус отступы
                  child: Column(
                    children: [
                      _buildActionButtons(),
                      Expanded(
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                            color: Colors.grey[900],
                          ),
                          child: SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: SizedBox(
                              width: _headerTitles.length * 140, // Фиксированная общая ширина
                              child: Column(
                                children: [
                                  Container(
                                    color: Colors.grey[800],
                                    child: Row(
                                      children: _headerTitles.entries.map((entry) => 
                                        _HeaderCell(
                                          entry.value, 
                                          width: 140,
                                        )
                                      ).toList(),
                                    ),
                                  ),
                                  Expanded(
                                    child: SingleChildScrollView(
                                      child: Column(
                                        children: _events.asMap().entries.map((entry) {
                                          final index = entry.key;
                                          final event = entry.value;
                                          return GestureDetector(
                                            onTap: () => _handleRowSelection(index),
                                            child: Container(
                                              color: _selectedRowIndex == index 
                                                ? Colors.blue.withOpacity(0.2) 
                                                : null,
                                              child: Row(
                                                children: _headerTitles.keys.map((key) => 
                                                  _TableCell(
                                                    event[key].toString(), 
                                                    width: 140,
                                                  )
                                                ).toList(),
                                              ),
                                            ),
                                          );
                                        }).toList(),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
      ),
    );
  }
}

class _HeaderCell extends StatelessWidget {
  final String text;
  final double width;

  const _HeaderCell(this.text, {required this.width});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
      child: Text(
        text,
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          color: Colors.white,
          fontSize: 16,
        ),
      ),
    );
  }
}

class _TableCell extends StatelessWidget {
  final String text;
  final double width;

  const _TableCell(this.text, {required this.width});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
      decoration: const BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Colors.grey),
          right: BorderSide(color: Colors.grey),
        ),
      ),
      child: Text(
        text, 
        style: const TextStyle(
          color: Colors.white,
          fontSize: 16,
        ),
      ),
    );
  }
}

class _EditEventDialog extends StatefulWidget {
  final Map<String, dynamic> event;

  const _EditEventDialog({required this.event});

  @override
  State<_EditEventDialog> createState() => _EditEventDialogState();
}

class _EditEventDialogState extends State<_EditEventDialog> {
  late final TextEditingController quantityController;
  late final TextEditingController rateController;
  late final TextEditingController totalController;
  late bool isUpSelected;
  late bool isDownSelected;
  late String selectedCurrency;
  late String selectedDate;
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
    selectedDate = widget.event['date'];
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
            ElevatedButton(
              onPressed: () async {
                final DateTime? picked = await showDatePicker(
                  context: context,
                  initialDate: DateTime.parse(selectedDate),
                  firstDate: DateTime(2000),
                  lastDate: DateTime(2101),
                );
                if (picked != null) {
                  setState(() {
                    selectedDate = DateFormat('yyyy-MM-dd').format(picked);
                  });
                }
              },
              child: Text(selectedDate),
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
                  onPressed: () {
                    // TODO: Implement update functionality
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