import 'dart:math';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../components/buttons/custom_button.dart';
import '../../components/buttons/icon_toggle_button.dart';
import '../../components/dropdowns/custom_dropdown.dart';
import '../../components/inputs/custom_text_field.dart';
import '../../components/loading/shimmer_loading.dart';
import '../drawer/app_drawer.dart';
import '../../services/api_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with SingleTickerProviderStateMixin {
  final TextEditingController _quantityController = TextEditingController();
  final TextEditingController _rateController = TextEditingController();
  final TextEditingController _totalController = TextEditingController();

  bool _isUpSelected = false;
  bool _isDownSelected = false;
  String _selectedCurrency = 'Валюта';
  List<String> _currencies = ['Валюта'];
  String _selectedDate = DateFormat('yyyy-MM-dd').format(DateTime.now());
  late final AnimationController _backgroundController;
  late final Animation<double> _animation;
  bool _isInitialLoading = true; // Add new variable for initial loading state

  final GlobalKey<CustomDropdownState> _dropdownKey = GlobalKey<CustomDropdownState>();

  @override
  void initState() {
    super.initState();
    
    _backgroundController = AnimationController(
      duration: const Duration(seconds: 15),
      vsync: this,
    );

    _animation = Tween<double>(
      begin: -1.0,
      end: 1.0,
    ).animate(
      CurvedAnimation(
        parent: _backgroundController,
        curve: Curves.easeInOutSine,
      ),
    );

    _backgroundController.addStatusListener((status) {
      if (!mounted) return;
      if (status == AnimationStatus.completed) {
        _backgroundController.reverse();
      } else if (status == AnimationStatus.dismissed) {
        _backgroundController.forward();
      }
    });

    _backgroundController.forward();
    _initialFetchCurrencies(); // Rename method call
  }

  Future<void> _initialFetchCurrencies() async {
    try {
      final currencies = await ApiService.fetchCurrencies();
      if (mounted) {
        setState(() {
          _currencies = ['Валюта', ...currencies];
          _isInitialLoading = false;
        });
      }
    } catch (e) {
      print('Error in _initialFetchCurrencies: $e');
      if (mounted) {
        setState(() {
          _currencies = ['Валюта'];
          _isInitialLoading = false;
        });
      }
    }
  }

  Future<void> _fetchCurrencies() async {
    try {
      final currencies = await ApiService.fetchCurrencies();
      if (mounted) {
        setState(() {
          _currencies = ['Валюта', ...currencies];
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _currencies = ['Валюта'];
        });
      }
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null) {
      setState(() {
        _selectedDate = DateFormat('yyyy-MM-dd').format(picked);
      });
    }
  }

  @override
  void dispose() {
    _backgroundController.stop();
    _backgroundController.dispose();
    _quantityController.dispose();
    _rateController.dispose();
    _totalController.dispose();
    super.dispose();
  }

  void _calculateTotal() {
    final double quantity = double.tryParse(_quantityController.text) ?? 0;
    final double rate = double.tryParse(_rateController.text) ?? 0;
    final double total = quantity * rate;
    _totalController.text = total.toStringAsFixed(2);
  }

  void _clearFields() {
    setState(() {
      _selectedCurrency = 'Валюта';
      _selectedDate = DateFormat('yyyy-MM-dd').format(DateTime.now());
      _isUpSelected = false;
      _isDownSelected = false;
    });
    _quantityController.clear();
    _rateController.clear();
    _totalController.clear();
  }

  void _selectUp() {
    setState(() {
      _isUpSelected = true;
      _isDownSelected = false;
    });
  }

  void _selectDown() {
    setState(() {
      _isUpSelected = false;
      _isDownSelected = true;
    });
  }

  Future<void> _submitEvent() async {
    if (_selectedCurrency == 'Валюта' || 
        _quantityController.text.isEmpty || 
        _rateController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Заполните все поля')),
      );
      return;
    }

    try {
      final type = _isUpSelected ? 'up' : _isDownSelected ? 'down' : '';
      if (type.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Выберите тип операции (продажа/покупка)')),
        );
        return;
      }

      await ApiService.addEvent(
        type,
        _selectedCurrency,
        double.parse(_quantityController.text),
        _selectedDate,
        double.parse(_rateController.text),
        double.parse(_totalController.text),
      );

      _clearFields();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Событие успешно добавлено')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Ошибка: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: Builder(
          builder: (BuildContext context) {
            return IconButton(
              icon: Icon(Icons.menu),
              onPressed: () {
                Scaffold.of(context).openDrawer();
              },
            );
          },
        ),
        title: Text('Обменник отчеты'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      drawer: Builder(
        builder: (context) => AppDrawer(
          onDrawerOpened: () {
            _dropdownKey.currentState?.closeDropdown();
          },
        ),
      ),
      extendBodyBehindAppBar: true,
      body: AnimatedBuilder(
        animation: _animation,
        builder: (context, child) {
          final position = (_animation.value + 1) / 2;
          return Stack(
            children: [
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: const [
                      Color(0xFF1a1a1a),
                      Color(0xFF242424),
                      Color(0xFF1a1a1a),
                    ],
                    stops: [
                      position * 0.2,
                      position,
                      position * 1.8,
                    ],
                    transform: GradientRotation(pi / 4),
                  ),
                ),
              ),
              BackdropFilter(
                filter: ImageFilter.blur(
                  sigmaX: 50.0,
                  sigmaY: 50.0,
                ),
                child: child,
              ),
            ],
          );
        },
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  if (_isInitialLoading) // Change condition to use _isInitialLoading
                    Column(
                      children: List.generate(
                        5,
                        (index) => Padding(
                          padding: EdgeInsets.only(bottom: 16),
                          child: ShimmerLoading(
                            width: double.infinity,
                            height: 50,
                          ),
                        ),
                      ),
                    )
                  else
                    Column(
                      children: [
                        ElevatedButton(
                          onPressed: () => _selectDate(context),
                          child: Text(_selectedDate),
                        ),
                        SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            IconToggleButton(
                              icon: Icons.arrow_upward,
                              isSelected: _isUpSelected,
                              onPressed: _selectUp,
                            ),
                            SizedBox(width: 16),
                            IconToggleButton(
                              icon: Icons.arrow_downward,
                              isSelected: _isDownSelected,
                              onPressed: _selectDown,
                            ),
                          ],
                        ),
                        SizedBox(height: 16),
                        CustomDropdown(
                          key: _dropdownKey,
                          value: _selectedCurrency,
                          items: _currencies,
                          onChanged: (String? newValue) {
                            setState(() {
                              _selectedCurrency = newValue!;
                            });
                          },
                          onMenuOpened: _fetchCurrencies,
                        ),
                        SizedBox(height: 16),
                        CustomTextField(
                          controller: _quantityController,
                          hintText: 'Количество',
                          onChanged: (value) => _calculateTotal(),
                        ),
                        SizedBox(height: 16),
                        CustomTextField(
                          controller: _rateController,
                          hintText: 'Курс',
                          onChanged: (value) => _calculateTotal(),
                        ),
                        SizedBox(height: 16),
                        CustomTextField(
                          controller: _totalController,
                          hintText: 'Общий',
                          readOnly: true,
                        ),
                        SizedBox(height: 16),
                        CustomButton(
                          onPressed: _submitEvent,
                          text: 'Добавить',
                        ),
                      ],
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