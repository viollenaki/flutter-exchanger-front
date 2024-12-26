import 'package:flutter/material.dart';
import '../../components/loading/shimmer_loading.dart';
import '../../services/api_service.dart';

import '../../components/header_cell.dart';
import '../../components/table_cell.dart' as custom;
import '../../components/edit_event_dialog.dart';

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

  Future<void> _deleteEvent(int id) async {
    try {
      await ApiService.deleteEvent(id);
      setState(() {
        _selectedRowIndex = null;
        _animationController.reverse();
      });
      await _fetchEvents(); // Refresh the events list
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Событие успешно удалено')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Ошибка удаления события: $e')),
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

  Future<void> _showEditDialog(Map<String, dynamic> event) async {
    await showDialog(
      context: context,
      builder: (context) => EditEventDialog(event: event),
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
                      await _showDeleteConfirmation();
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
                                                  custom.TableCell(
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