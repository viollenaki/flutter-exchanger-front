import 'package:flutter/material.dart';
import 'package:exchanger/components/background/animated_background.dart';
import '../../components/loading/shimmer_loading.dart';
import '../../services/api_service.dart';
import '../../components/header_cell.dart';
import '../../components/table_cell.dart' as custom;
import '../../components/buttons/custom_button.dart';

class CurrenciesScreen extends StatefulWidget {
  const CurrenciesScreen({super.key});

  @override
  _CurrenciesScreenState createState() => _CurrenciesScreenState();
}

class _CurrenciesScreenState extends State<CurrenciesScreen> with SingleTickerProviderStateMixin {
  bool _isLoading = true;
  List<String> _currencies = [];
  int? _selectedRowIndex;
  late AnimationController _animationController;

  final Map<String, String> _headerTitles = {
    'currency': 'Валюта',
  };

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );
    _fetchCurrencies();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _fetchCurrencies() async {
    try {
      final currencies = await ApiService.fetchCurrencies();
      setState(() {
        _currencies = currencies;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Ошибка загрузки валют')),
      );
    }
  }

  Future<void> _addCurrency(String currencyName) async {
    try {
      await ApiService.addCurrency(currencyName);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: const Text('Валюта добавлена')),
      );
      await _fetchCurrencies();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Ошибка добавления валюты')),
      );
    }
  }

  Future<void> _editCurrentcy(String currencyName, String oldCurrencyName) async {
    try {
      await ApiService.editCurrency(currencyName, oldCurrencyName);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: const Text('Валюта изменена')),
      );
      await _fetchCurrencies();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Ошибка изменения валюты')),
      );
    }
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

  Future<void> _deleteCurrency(String currency) async {
    try {
      await ApiService.deleteCurrency(currency);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Валюта "$currency" удалена')),
      );
      setState(() {
        _selectedRowIndex = null;
        _animationController.reverse();
      });
      await _fetchCurrencies();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Ошибка удаления валюты')),
      );
    }
  }

  Future<void> _showEditDialog(String currency) async {
    final TextEditingController controller = TextEditingController(text: currency);
    String oldCurrency = currency;
    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Редактировать валюту'),
          content: TextField(
            controller: controller,
            decoration: const InputDecoration(
              labelText: 'Название валюты',
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Отмена'),
            ),
            TextButton(
              onPressed: () async {
                await _editCurrentcy(controller.text, oldCurrency);
                Navigator.of(context).pop();
              },
              child: const Text('Сохранить'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _showDeleteDialog(String currency) async {
    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Удалить валюту'),
          content: Text('Вы уверены, что хотите удалить валюту "$currency"?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Отмена'),
            ),
            TextButton(
              onPressed: () {
                _deleteCurrency(currency);
                Navigator.of(context).pop();
              },
              style: TextButton.styleFrom(
                foregroundColor: Colors.red,
              ),
              child: const Text('Удалить'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _showAddDialog() async {
    final TextEditingController controller = TextEditingController();
    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Добавить валюту'),
          content: TextField(
            controller: controller,
            decoration: const InputDecoration(
              labelText: 'Название валюты',
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Отмена'),
            ),
            TextButton(
              onPressed: () async {
                await _addCurrency(controller.text);
                Navigator.of(context).pop();
              },
              child: const Text('Добавить'),
            ),
          ],
        );
      },
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
                        _showEditDialog(_currencies[_selectedRowIndex!]);
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
                    onPressed: () {
                      if (_selectedRowIndex != null) {
                        _showDeleteDialog(_currencies[_selectedRowIndex!]);
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Валюты'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      extendBodyBehindAppBar: true,
      body: AnimatedBackground(
        child: SafeArea(
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
                    height: MediaQuery.of(context).size.height - 150,
                    child: Column(
                      children: [
                        _buildActionButtons(),
                        Expanded(
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8),
                              color: Colors.grey[900],
                            ),
                            child: Column(
                              children: [
                                Stack(
                                  children: [
                                    ClipRRect(
                                      borderRadius: const BorderRadius.only(
                                        topLeft: Radius.circular(8),
                                        topRight: Radius.circular(8),
                                      ),
                                      child: Container(
                                        color: Colors.grey[800],
                                        child: Row(
                                          children: _headerTitles.entries.map((entry) => 
                                            Expanded(
                                              child: HeaderCell(
                                                entry.value, 
                                                width: MediaQuery.of(context).size.width / _headerTitles.length,
                                              ),
                                            ),
                                          ).toList(),
                                        ),
                                      ),
                                    ),
                                    Positioned.fill(
                                      child: ClipRRect(
                                        borderRadius: const BorderRadius.only(
                                          topLeft: Radius.circular(8),
                                          topRight: Radius.circular(8),
                                        ),
                                        child: Container(
                                          color: Colors.transparent,
                                          child: Row(
                                            children: List.generate(
                                              _headerTitles.length,
                                              (index) => Expanded(
                                                child: Container(
                                                  decoration: BoxDecoration(
                                                    borderRadius: index == 0
                                                        ? const BorderRadius.only(topLeft: Radius.circular(8))
                                                        : index == _headerTitles.length - 1
                                                            ? const BorderRadius.only(topRight: Radius.circular(8))
                                                            : BorderRadius.zero,
                                                    color: Colors.transparent,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                Expanded(
                                  child: ListView.builder(
                                    itemCount: _currencies.length,
                                    itemBuilder: (context, index) {
                                      final currency = _currencies[index];
                                      return GestureDetector(
                                        onTap: () => _handleRowSelection(index),
                                        child: Container(
                                          color: _selectedRowIndex == index 
                                            ? Colors.blue.withOpacity(0.2) 
                                            : null,
                                          child: Row(
                                            children: _headerTitles.keys.map((key) => 
                                              Expanded(
                                                child: custom.TableCell(
                                                  currency, 
                                                  width: MediaQuery.of(context).size.width / _headerTitles.length, // Adjust width dynamically
                                                ),
                                              ),
                                            ).toList(),
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 16), // Add some space between the table and the button
                        CustomButton(
                          onPressed: _showAddDialog,
                          text: 'Добавить',
                        ),
                      ],
                    ),
                  ),
                ),
        ),
      ),
    );
  }
}