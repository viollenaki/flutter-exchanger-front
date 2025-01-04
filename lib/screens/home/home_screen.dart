import 'dart:async';
import 'package:exchanger/models/user.dart';
import 'package:exchanger/styles/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import '../../components/buttons/custom_button.dart';
import '../../components/buttons/icon_toggle_button.dart';
import '../../components/dropdowns/custom_dropdown.dart';
import '../../components/inputs/custom_text_field.dart';
import '../../components/loading/shimmer_loading.dart';
import '../drawer/app_drawer.dart';
import '../../services/api_service.dart';
import 'package:exchanger/components/background/animated_background.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with SingleTickerProviderStateMixin, RouteAware {
  final TextEditingController _quantityController = TextEditingController();
  final TextEditingController _rateController = TextEditingController();
  final TextEditingController _totalController = TextEditingController();

  bool _isUpSelected = false;
  bool _isDownSelected = false;
  String _selectedCurrency = 'Валюта';
  List<String> _currencies = ['Валюта'];
  bool _isInitialLoading = true; 
  Map<String, dynamic> _rates = {};

  final GlobalKey<CustomDropdownState> _dropdownKey = GlobalKey<CustomDropdownState>();
  late Future<void> _initFuture;

  final ScrollController _ratesScrollController = ScrollController();
  Timer? _scrollTimer;
  final GlobalKey _scrollKey = GlobalKey();
  double _singleCycleWidth = 0.0;

  @override
  void initState() {
    super.initState();
    
    _initFuture = _initialFetchCurrencies(); 
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final username = UserManager().getCurrentUser();
      if (username != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Добро пожаловать, $username!')),
        );
      }
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollKey.currentContext != null) {
        final box = _scrollKey.currentContext!.findRenderObject() as RenderBox;
        _singleCycleWidth = box.size.width / 2;
      }
      _startAutoScroll();
    });
  }

  void _startAutoScroll() {
    if (_scrollTimer != null && _scrollTimer!.isActive) return;
    _scrollTimer = Timer.periodic(const Duration(milliseconds: 40), (_) {
      if (_ratesScrollController.hasClients && _singleCycleWidth > 0) {
        final offset = _ratesScrollController.offset + 1;
        if (offset >= _singleCycleWidth) {
          _ratesScrollController.jumpTo(offset - _singleCycleWidth);
        } else {
          _ratesScrollController.jumpTo(offset);
        }
      }
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _fetchCurrencies();
  }

  @override
  void didPush() {
    super.didPush();
    _fetchCurrencies();
  }

  Future<void> _initialFetchCurrencies() async {
    try {
      final currencies = await ApiService.fetchCurrencies();
      final rates = await ApiService.getCurrencyRate();
      if (mounted) {
        setState(() {
          _currencies = ['Валюта', ...currencies];
          _isInitialLoading = false;
          _rates = rates;
        });
      }
    } catch (e) {
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
      setState(() {
        _currencies = ['Валюта', ...currencies];
      });
    } catch (e) {
      if (mounted) {
        setState(() {
          _currencies = ['Валюта'];
        });
      }
    }
  }

  @override
  void dispose() {
    _scrollTimer?.cancel();
    _ratesScrollController.dispose();
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

  // New method to build input fields based on platform
  Widget _buildInputFields(BuildContext context) {
    final theme = Theme.of(context);
    final inputFormatters = [FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*'))];
    
    if (theme.isIOS) {
      return Column(
        children: [
          CupertinoTextField(
            controller: _quantityController,
            placeholder: 'Количество',
            placeholderStyle: TextStyle(color: CupertinoColors.systemGrey.withOpacity(0.7)),
            onChanged: (value) => _calculateTotal(),
            style: TextStyle(color: CupertinoColors.white),
            decoration: BoxDecoration(
              border: Border.all(color: CupertinoColors.systemGrey),
              borderRadius: BorderRadius.circular(8.0),
            ),
            padding: EdgeInsets.symmetric(vertical: 16, horizontal: 12),
            keyboardType: TextInputType.numberWithOptions(decimal: true),
            inputFormatters: inputFormatters,
          ),
          SizedBox(height: 16),
          CupertinoTextField(
            controller: _rateController,
            placeholder: 'Курс',
            placeholderStyle: TextStyle(color: CupertinoColors.systemGrey.withOpacity(0.7)),
            onChanged: (value) => _calculateTotal(),
            style: TextStyle(color: CupertinoColors.white),
            decoration: BoxDecoration(
              border: Border.all(color: CupertinoColors.systemGrey),
              borderRadius: BorderRadius.circular(8.0),
            ),
            padding: EdgeInsets.symmetric(vertical: 16, horizontal: 12),
            keyboardType: TextInputType.numberWithOptions(decimal: true),
            inputFormatters: inputFormatters,
          ),
          SizedBox(height: 16),
          CupertinoTextField(
            controller: _totalController,
            placeholder: 'Общий',
            placeholderStyle: TextStyle(color: CupertinoColors.systemGrey.withOpacity(0.7)),
            readOnly: true,
            style: TextStyle(color: CupertinoColors.white),
            decoration: BoxDecoration(
              border: Border.all(color: CupertinoColors.systemGrey),
              borderRadius: BorderRadius.circular(8.0),
            ),
            padding: EdgeInsets.symmetric(vertical: 16, horizontal: 12),
            keyboardType: TextInputType.numberWithOptions(decimal: true),
            inputFormatters: inputFormatters,
          ),
        ],
      );
    } else {
      return Column(
        children: [
          CustomTextField(
            controller: _quantityController,
            hintText: 'Количество',
            onChanged: (value) => _calculateTotal(),
            inputFormatters: inputFormatters,
          ),
          SizedBox(height: 16),
          CustomTextField(
            controller: _rateController,
            hintText: 'Курс',
            onChanged: (value) => _calculateTotal(),
            inputFormatters: inputFormatters,
          ),
          SizedBox(height: 16),
          CustomTextField(
            controller: _totalController,
            hintText: 'Общий',
            readOnly: true,
            inputFormatters: inputFormatters,
          ),
        ],
      );
    }
  }

  // New method to show dialog based on platform
  void _showPlatformDialog(String message) {
    final theme = Theme.of(context);
    if (theme.isIOS) {
      showCupertinoDialog(
        context: context,
        builder: (context) => CupertinoAlertDialog(
          content: Text(message),
          actions: [
            CupertinoDialogAction(
              child: Text('OK'),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ],
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message)),
      );
    }
  }

  Future<void> _submitEvent() async {
    if (_selectedCurrency == 'Валюта' || 
        _quantityController.text.isEmpty || 
        _rateController.text.isEmpty) {
      _showPlatformDialog('Заполните все поля');
      return;
    }

    try {
      final type = _isUpSelected ? 'Продажа' : _isDownSelected ? 'Покупка' : '';
      if (type.isEmpty) {
        _showPlatformDialog('Выберите тип операции (продажа/покупка)');
        return;
      }

      await ApiService.addEvent(
        type,
        _selectedCurrency,
        double.parse(_quantityController.text),
        double.parse(_rateController.text),
        double.parse(_totalController.text),
      );

      _clearFields();
      _showPlatformDialog('Событие успешно добавлено');
    } catch (e) {
      _showPlatformDialog('Ошибка: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<void>(
      future: _initFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Scaffold(
            appBar: AppBar(
              title: const Text('Обменник отчеты'),
            ),
            body: const Center(
              child: CircularProgressIndicator(),
            ),
          );
        } else if (snapshot.hasError) {
          return Scaffold(
            appBar: AppBar(
              title: const Text('Обменник отчеты'),
            ),
            body: Center(
              child: Text('Ошибка: ${snapshot.error}'),
            ),
          );
        } else {
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
            body: AnimatedBackground(
              child: SafeArea(
                child: Center(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        if (_isInitialLoading) 
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
                              SizedBox(height: 16),
                              _buildScrollingRates(),
                              Padding(
                                padding: const EdgeInsets.symmetric(vertical: 24),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    IconToggleButton(
                                      icon: Icons.arrow_upward,
                                      isSelected: _isUpSelected,
                                      onPressed: _selectUp,
                                      selectedColor: Theme.of(context).primaryColor, 
                                    ),
                                    SizedBox(width: 16),
                                    IconToggleButton(
                                      icon: Icons.arrow_downward,
                                      isSelected: _isDownSelected,
                                      onPressed: _selectDown,
                                      selectedColor: Theme.of(context).primaryColor, 
                                    ),
                                  ],
                                ),
                              ),
                              SizedBox(height: 16),
                              CustomDropdown(
                                key: _dropdownKey,
                                value: _selectedCurrency,
                                items: _currencies,
                                onChanged: (String? newValue) {
                                  String lowerCurrency = newValue!.toLowerCase();
                                  setState(() {
                                    _selectedCurrency = newValue;
                                    if (_selectedCurrency != 'Валюта') {
                                      _rateController.text = _rates.keys.contains(lowerCurrency) ? _rateController.text = double.parse(_rates[lowerCurrency]).toStringAsFixed(2) : _rateController.text = '';
                                      _calculateTotal();
                                    }else{
                                      _rateController.text = '';
                                      _calculateTotal();
                                    }
                                  });
                                },
                                onMenuOpened: _fetchCurrencies,
                              ),
                              SizedBox(height: 16),
                              _buildInputFields(context), 
                              SizedBox(height: 16),
                              Padding(
                                padding: const EdgeInsets.only(bottom: 24),
                                child: CustomButton(
                                  onPressed: _submitEvent,
                                  text: 'Добавить',
                                ),
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
      },
    );
  }

  Widget _buildScrollingRates() {
    final List<String> currencies = ['RUB', 'USD', 'KZT', 'EUR', 'CNY', 'UZS', 'GBP', 'TRY'];
    final List<String> rates = currencies.map((currency) {
      final lowerCurrency = currency.toLowerCase();
      return _rates.containsKey(lowerCurrency) ? '$currency: ${double.parse(_rates[lowerCurrency]).toStringAsFixed(2)}' : '$currency: N/A';
    }).toList();

    final List<String> repeatedRates = [...rates, ...rates];

    return SizedBox(
      height: 30,
      child: LayoutBuilder(
        builder: (context, constraints) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (_scrollKey.currentContext != null) {
              final box = _scrollKey.currentContext!.findRenderObject() as RenderBox;
              final measuredWidth = box.size.width / 2;
              if (measuredWidth != _singleCycleWidth) {
                setState(() {
                  _singleCycleWidth = measuredWidth;
                });
                _startAutoScroll();
              }
            }
          });
          return SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            controller: _ratesScrollController,
            child: Row(
              key: _scrollKey,
              children: repeatedRates.map((rateText) {
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: Text(
                    rateText,
                    style: TextStyle(color: Colors.amber, fontSize: 16),
                  ),
                );
              }).toList(),
            ),
          );
        },
      ),
    );
  }
}