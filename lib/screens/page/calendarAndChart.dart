import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:ocare/calendarAndChart/screens/calendar_page.dart';
import 'package:ocare/calendarAndChart/screens/chart_page.dart';
import 'package:ocare/calendarAndChart/providers/health_data_provider.dart';


class CalendarAndChartPage extends StatefulWidget {
  const CalendarAndChartPage({super.key});

  @override
  State<CalendarAndChartPage> createState() => _CalendarAndChartPageState();
}

class _CalendarAndChartPageState extends State<CalendarAndChartPage> {
  @override
  void initState() {
    super.initState();
    _loadDataFromFirebase();
  }

  Future<void> _loadDataFromFirebase() async {
    try {
      await Provider.of<HealthDataProvider>(context, listen: false).loadDataFromFirebase();
    } catch (e) {
      print('Error loading data from Firebase: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('테스트님 건강 정보'),
      ),
      body: Column(
        children: const [
          // Expanded(
          //   child: CalendarPage(),
          // ),
          Expanded(
            child: ChartPage(),
          ),
        ],
      ),
    );
  }
}