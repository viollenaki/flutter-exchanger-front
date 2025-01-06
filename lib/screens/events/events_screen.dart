import 'package:exchanger/styles/app_theme.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'dart:async';
import '../../components/loading/shimmer_loading.dart';
import '../../services/api_service.dart';
import 'package:exchanger/components/background/animated_background.dart';
import 'package:exchanger/services/export_to_pdf.dart';

import '../../components/header_cell.dart';
import '../../components/table_cell.dart' as custom;
import '../../components/edit_event_dialog.dart';
import '../../components/filter_dialog.dart';

class EventsScreen extends StatefulWidget {
  const EventsScreen({super.key});

  @override
  State<EventsScreen> createState() => _EventsScreenState();
}

class _EventsScreenState extends State<EventsScreen> with SingleTickerProviderStateMixin {
  bool _isLoading = true;
  List<dynamic> _events = [];
  List<String> _currencies = [];
  String? _selectedCurrency;
  String? _selectedType;
  int? _selectedRowIndex;
  TimeOfDay? _selectedTime;
  late AnimationController _animationController;
  Timer? _updateTimer;

  final Map<String, String> _headerTitles = {
    'date': 'Время',
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
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );
    _fetchEvents();
    _fetchCurrencies();
    _updateTimer = Timer.periodic(const Duration(seconds: 5), (timer) {
      _fetchEvents();
      _fetchCurrencies();
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    _updateTimer?.cancel();
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

  Future<void> _fetchCurrencies() async {
    try {
      final currencies = await ApiService.fetchCurrencies();
      setState(() {
        _currencies = currencies;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading currencies: $e')),
      );
    }
  }

  Future<void> _deleteEvent(int id) async {
    try {
      await ApiService.deleteEvent(id);
      setState(() {
        _selectedRowIndex = null;
        _animationController.reverse();
      });
      await _fetchEvents();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Событие успешно удалено')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Ошибка удаления события: $e')),
      );
    }
  }

  Future<bool?> _showDeleteConfirmation() async {
    final theme = Theme.of(context);
    
    if (theme.isIOS) {
      return showCupertinoDialog<bool>(
        context: context,
        builder: (context) {
          return CupertinoAlertDialog(
            title: const Text('Реально???'),
            content: const Text('?!?!?!?!'),
            actions: [
              CupertinoDialogAction(
                child: const Text('неее :)'),
                onPressed: () => Navigator.of(context).pop(false),
              ),
              CupertinoDialogAction(
                isDestructiveAction: true,
                onPressed: () {
                  _deleteEvent(_events[_selectedRowIndex!]['id']);
                  Navigator.of(context).pop(true);
                },
                child: const Text('ага :O'),
              ),
            ],
          );
        },
      );
    } else {
      return showGeneralDialog<bool>(
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
                    onPressed: () {
                      _deleteEvent(_events[_selectedRowIndex!]['id']);
                      Navigator.of(context).pop(true);
                    },
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
  }

  Future<void> _showEditDialog(Map<String, dynamic> event) async {
    await showDialog(
      context: context,
      builder: (context) => EditEventDialog(event: event),
    );
    await _fetchEvents();
  }

  Future<void> _showFilterDialog() async {
    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (context) => FilterDialog(
        currencies: _currencies,
        selectedCurrency: _selectedCurrency,
        selectedType: _selectedType,
        selectedTime: _selectedTime,
      ),
    );

    if (result != null) {
      setState(() {
        _selectedCurrency = result['currency'];
        _selectedType = result['type'];
        _selectedTime = result['time'];
      });
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
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        if (_selectedRowIndex != null) {
                          _showEditDialog(_events[_selectedRowIndex!]);
                        }
                      },
                      icon: const Icon(Icons.edit, color: Colors.white),
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
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () async {
                        await _showDeleteConfirmation();
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

  List<dynamic> _filterEvents() {
    List<dynamic> filteredEvents = _events;
    if (_selectedCurrency != null && _selectedCurrency!.isNotEmpty) {
      filteredEvents = filteredEvents.where((event) => event['currency'] == _selectedCurrency).toList();
    }
    if (_selectedType != null && _selectedType!.isNotEmpty) {
      filteredEvents = filteredEvents.where((event) => event['type'] == _selectedType).toList();
    }
    if (_selectedTime != null) {
      filteredEvents = filteredEvents.where((event) {
        final eventTime = event['date'].toString().split(':');
        final eventHour = int.parse(eventTime[0]);
        final eventMinute = int.parse(eventTime[1]);
        
        return eventHour > _selectedTime!.hour || 
               (eventHour == _selectedTime!.hour && eventMinute >= _selectedTime!.minute);
      }).toList();
    }
    return filteredEvents;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('События'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: _showFilterDialog,
          ),
        ],
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
                    height: MediaQuery.of(context).size.height - 100,
                    child: Column(
                      children: [
                        _buildActionButtons(),
                        const SizedBox(height: 16),
                        Expanded(
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8),
                              color: Colors.grey[900],
                            ),
                            child: SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: SizedBox(
                                width: _headerTitles.length * 140,
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
                                                HeaderCell(
                                                  entry.value, 
                                                  width: 140,
                                                )
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
                                                  (index) => Container(
                                                    width: 140,
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
                                      ],
                                    ),
                                    Expanded(
                                      child: SingleChildScrollView(
                                        child: Column(
                                          children: _filterEvents().asMap().entries.map((entry) {
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
                                                    custom.TableCell(
                                                      key == 'date' 
                                                          ? event[key].toString().substring(0, 5) // Take only first 5 characters (HH:mm)
                                                          : event[key].toString(), 
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
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await ExportToPdf.exportTableToPdf(_filterEvents(), _headerTitles, 'Отчет о событиях');
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Таблица экспортирована в PDF')),
          );
        },
        child: const Icon(Icons.picture_as_pdf),
      ),
    );
  }
}