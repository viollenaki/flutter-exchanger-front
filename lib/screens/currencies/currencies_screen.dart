import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:exchanger/components/background/animated_background.dart';
import 'package:exchanger/styles/app_theme.dart';
import '../../components/loading/shimmer_loading.dart';
import '../../services/api_service.dart';
import '../../components/header_cell.dart';
import '../../components/table_cell.dart' as custom;
import '../../components/buttons/custom_button.dart';
import 'dart:async';

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
  final formKey = GlobalKey<FormState>();
  Timer? _updateTimer;

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
    // Повторить запрос
    _updateTimer = Timer.periodic(const Duration(seconds: 5), (timer) {
      _fetchCurrencies();
      print('Currencies updated');
    });
  
  }

  @override
  void dispose() {
    _animationController.dispose();
    _updateTimer?.cancel();
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

  String? _validateCurrency(String? value) {
    if (value == null || value.isEmpty) {
      return 'Введите название валюты';
    }
    if (value.length < 2) {
      return 'Название валюты должно содержать минимум 2 символа';
    }
    return null;
  }

  Widget _buildCurrencyField(
    BuildContext context,
    TextEditingController controller,
    bool isEditMode,
  ) {
    final theme = Theme.of(context);
    String? currencyError;

    if (theme.isIOS) {
      return StatefulBuilder(
        builder: (context, setState) {
          return Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CupertinoTextField(
                controller: controller,
                placeholder: 'Название валюты',
                style: const TextStyle(color: CupertinoColors.white),
                decoration: BoxDecoration(
                  border: Border.all(
                    color: currencyError != null ? CupertinoColors.systemRed : CupertinoColors.systemGrey,
                  ),
                  borderRadius: BorderRadius.circular(8.0),
                ),
                padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
                onChanged: (value) {
                  setState(() {
                    currencyError = _validateCurrency(value);
                  });
                },
              ),
              if (currencyError != null)
                Padding(
                  padding: const EdgeInsets.only(top: 4, left: 12),
                  child: Text(
                    currencyError!,
                    style: const TextStyle(color: CupertinoColors.systemRed, fontSize: 12),
                  ),
                ),
            ],
          );
        },
      );
    } else {
      return Form(
        key: formKey,
        child: TextFormField(
          controller: controller,
          decoration: const InputDecoration(labelText: 'Название валюты'),
          validator: _validateCurrency,
        ),
      );
    }
  }

  Future<void> _showEditDialog(String currency) async {
    final TextEditingController controller = TextEditingController(text: currency);
    String oldCurrency = currency;

    if (Theme.of(context).isIOS) {
      await showCupertinoDialog(
        context: context,
        builder: (context) {
          return CupertinoAlertDialog(
            title: const Text('Редактировать валюту'),
            content: Padding(
              padding: const EdgeInsets.symmetric(vertical: 16.0),
              child: _buildCurrencyField(context, controller, true),
            ),
            actions: [
              CupertinoDialogAction(
                child: const Text('Отмена'),
                onPressed: () => Navigator.pop(context),
              ),
              CupertinoDialogAction(
                child: const Text('Сохранить'),
                onPressed: () async {
                  final error = _validateCurrency(controller.text);
                  if (error == null) {
                    await _editCurrentcy(controller.text, oldCurrency);
                    Navigator.pop(context);
                  }
                },
              ),
            ],
          );
        },
      );
    } else {
      await showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text('Редактировать валюту'),
            content: _buildCurrencyField(context, controller, true),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Отмена'),
              ),
              TextButton(
                onPressed: () async {
                  if (formKey.currentState!.validate()) {
                    await _editCurrentcy(controller.text, oldCurrency);
                    Navigator.pop(context);
                  }
                },
                child: const Text('Сохранить'),
              ),
            ],
          );
        },
      );
    }
  }

  Future<void> _showDeleteDialog(String currency) async {
    if (Theme.of(context).isIOS) {
      await showCupertinoDialog(
        context: context,
        builder: (context) {
          return CupertinoAlertDialog(
            title: const Text('Удалить валюту'),
            content: Text('Вы уверены, что хотите удалить валюту "$currency"?'),
            actions: [
              CupertinoDialogAction(
                child: const Text('Отмена'),
                onPressed: () => Navigator.pop(context),
              ),
              CupertinoDialogAction(
                isDestructiveAction: true,
                onPressed: () {
                  _deleteCurrency(currency);
                  Navigator.pop(context);
                },
                child: const Text('Удалить'),
              ),
            ],
          );
        },
      );
    } else {
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
  }

  Future<void> _showAddDialog() async {
    final TextEditingController controller = TextEditingController();

    if (Theme.of(context).isIOS) {
      await showCupertinoDialog(
        context: context,
        builder: (context) {
          return CupertinoAlertDialog(
            title: const Text('Добавить валюту'),
            content: Padding(
              padding: const EdgeInsets.symmetric(vertical: 16.0),
              child: _buildCurrencyField(context, controller, false),
            ),
            actions: [
              CupertinoDialogAction(
                child: const Text('Отмена'),
                onPressed: () => Navigator.pop(context),
              ),
              CupertinoDialogAction(
                child: const Text('Добавить'),
                onPressed: () async {
                  final error = _validateCurrency(controller.text);
                  if (error == null) {
                    await _addCurrency(controller.text);
                    Navigator.pop(context);
                  }
                },
              ),
            ],
          );
        },
      );
    } else {
      await showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text('Добавить валюту'),
            content: _buildCurrencyField(context, controller, false),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Отмена'),
              ),
              TextButton(
                onPressed: () async {
                  if (formKey.currentState!.validate()) {
                    await _addCurrency(controller.text);
                    Navigator.pop(context);
                  }
                },
                child: const Text('Добавить'),
              ),
            ],
          );
        },
      );
    }
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
                    icon: const Icon(Icons.edit, color: Colors.white,),
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
                    icon: const Icon(Icons.delete, color: Colors.white,),
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