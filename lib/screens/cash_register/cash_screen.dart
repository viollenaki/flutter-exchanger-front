import 'package:flutter/material.dart';
import '../../components/header_cell.dart';
import '../../components/table_cell.dart' as custom;
import '../../components/loading/shimmer_loading.dart';
import '../../services/api_service.dart';

class CashScreen extends StatefulWidget {
  const CashScreen({super.key});

  @override
  State<CashScreen> createState() => _CashScreenState();
}

class _CashScreenState extends State<CashScreen> {
  bool _isLoading = true;
  List<Map<String, dynamic>> _cashReport = [];
  double _totalSum = 0.0;
  double _totalProfit = 0.0;

  final Map<String, String> _headerTitles = {
    'currency': 'Валюта',
    'buyTotal': 'Сумма покупки',
    'buyCount': 'Кол-во покупок',
    'buyAverage': 'Средняя покупка',
    'sellTotal': 'Сумма продажи',
    'sellCount': 'Кол-во продаж',
    'sellAverage': 'Средняя продажа',
    'profit': 'Профит',
  };

  @override
  void initState() {
    super.initState();
    _fetchCashReport();
  }

  Future<void> _fetchCashReport() async {
    try {
      final events = await ApiService.fetchEvents();
      final report = _processEvents(events);
      setState(() {
        _cashReport = report;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading cash report: $e')),
      );
    }
  }

  List<Map<String, dynamic>> _processEvents(List<dynamic> events) {
    Map<String, Map<String, dynamic>> reportMap = {};

    for (var event in events) {
      final currency = event['currency'];
      final type = event['type'];
      final total = double.parse(event['total'].toString());

      if (!reportMap.containsKey(currency)) {
        reportMap[currency] = {
          'currency': currency,
          'buyTotal': 0.0,
          'buyCount': 0,
          'sellTotal': 0.0,
          'sellCount': 0,
        };
      }

      if (type == 'Покупка') {
        reportMap[currency]!['buyTotal'] += total;
        reportMap[currency]!['buyCount']++;
      } else if (type == 'Продажа') {
        reportMap[currency]!['sellTotal'] += total;
        reportMap[currency]!['sellCount']++;
      }
    }

    // Calculate totals after processing events
    _totalSum = reportMap.values.fold(0.0, (sum, report) => 
      sum + report['buyTotal'] + report['sellTotal']
    );
    
    final reportList = reportMap.values.map((report) {
      final buyAverage = report['buyCount'] > 0 
          ? report['buyTotal'] / report['buyCount'] 
          : 0.0;
      final sellAverage = report['sellCount'] > 0 
          ? report['sellTotal'] / report['sellCount'] 
          : 0.0;
      
      final profit = report['buyCount'] * (sellAverage - buyAverage);
      _totalProfit += profit;
      
      return {
        ...report,
        'buyAverage': buyAverage,
        'sellAverage': sellAverage,
        'profit': profit,
      };
    }).toList();

    return reportList;
  }

  Widget _buildTotalsSection() {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.grey[800],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          Column(
            children: [
              Text(
                'Общий оборот',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 16,
                ),
              ),
              Text(
                _totalSum.toStringAsFixed(2),
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          Column(
            children: [
              Text(
                'Общая прибыль',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 16,
                ),
              ),
              Text(
                _totalProfit.toStringAsFixed(2),
                style: TextStyle(
                  color: _totalProfit < 0 ? Colors.red : Colors.green,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Касса'),
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
                child: Column(
                  children: [
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
                                Row(
                                  children: _headerTitles.entries.map((entry) => 
                                    HeaderCell(
                                      entry.value, 
                                      width: 140,
                                    )
                                  ).toList(),
                                ),
                                Expanded(
                                  child: SingleChildScrollView(
                                    child: Column(
                                      children: _cashReport.map((report) {
                                        return Row(
                                          children: _headerTitles.keys.map((key) => 
                                            custom.TableCell(
                                              report[key].toString(),
                                              width: 140,
                                            )
                                          ).toList(),
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
                    SizedBox(height: 16),
                    _buildTotalsSection(),
                  ],
                ),
              ),
      ),
    );
  }
}