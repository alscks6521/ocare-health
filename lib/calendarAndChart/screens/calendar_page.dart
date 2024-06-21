import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:flutter/services.dart';

import '../providers/health_data_provider.dart'; // HealthDataProvider를 사용하기 위해 필요

class CalendarPage extends StatefulWidget {
  const CalendarPage({super.key});

  @override
  State<CalendarPage> createState() => _CalendarPageState();
}

class _CalendarPageState extends State<CalendarPage> {
  DateTime? _selectedDay; // 선택된 날짜를 저장하는 변수
  DateTime? _focusedDay; // 포커스된 날짜를 저장하는 변수

  @override
  void initState() {
    super.initState();
    _loadDataFromFirebase(); // 변경: Firebase에서 데이터를 로드하는 메서드 호출 추가

    
  }

  Future<void> _loadDataFromFirebase() async {
    try {
      await Provider.of<HealthDataProvider>(context, listen: false).loadDataFromFirebase(); // 변경: Firebase에서 데이터를 로드하는 메서드 호출
    } catch (e) {
      print('Error loading data from Firebase: $e'); // 에러 발생 시 에러 메시지 출력
    }
  }

  @override
  void dispose() {
    SystemChrome.setPreferredOrientations([ // 화면 회전 설정을 초기화
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(14.0),
          child: Column(
            children: [
              _customTableCalendar(context), // 사용자 정의 TableCalendar 위젯
              const SizedBox(height: 15),
              const Divider(height: 1, thickness: 1),
              Flexible(
                fit: FlexFit.loose,
                child: _selectedDayDetails(), // 선택된 날짜의 상세 정보를 보여주는 위젯
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _customTableCalendar(BuildContext context) {
    return Consumer<HealthDataProvider>(
      builder: (context, healthDataProvider, _) {

        return TableCalendar(
          locale: "ko_KR", // 한국어 로케일 설정
          focusedDay: _focusedDay ?? DateTime.now(), // 포커스된 날짜 설정
          firstDay: DateTime.utc(2010, 10, 16), // 달력의 시작 날짜
          lastDay: DateTime.utc(2030, 3, 14), // 달력의 마지막 날짜
          rowHeight: 60.0, // 행의 높이 설정
          headerStyle: const HeaderStyle( // 헤더 스타일 설정
            formatButtonVisible: false,
            titleCentered: true,
            titleTextStyle: TextStyle(
              color: Color(0xFF276AEE),
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
            headerPadding: EdgeInsets.symmetric(vertical: 3),
          ),
          daysOfWeekStyle: const DaysOfWeekStyle( // 요일 스타일 설정
            weekendStyle: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
            weekdayStyle: TextStyle(fontWeight: FontWeight.bold),
          ),
          daysOfWeekHeight: 30.0, // 요일 높이 설정
          calendarStyle: CalendarStyle( // 달력 스타일 설정
            cellAlignment: Alignment.topCenter,
            weekendTextStyle: const TextStyle(color: Colors.red),
            cellMargin: EdgeInsets.zero,
            defaultDecoration: const BoxDecoration(shape: BoxShape.rectangle),
            weekendDecoration: const BoxDecoration(shape: BoxShape.rectangle),
            selectedDecoration: const BoxDecoration(
              color: Color(0xFF276AEE),
              shape: BoxShape.rectangle,

              
            ),
            daysOfWeekHeight: 30.0,
            calendarStyle: CalendarStyle(
              cellAlignment: Alignment.topCenter,
              weekendTextStyle: const TextStyle(color: Colors.red),
              cellMargin: EdgeInsets.zero,
              defaultDecoration: const BoxDecoration(shape: BoxShape.rectangle),
              weekendDecoration: const BoxDecoration(shape: BoxShape.rectangle),
              selectedDecoration: BoxDecoration(
                color: const Color(0xFF276AEE),
                borderRadius: BorderRadius.circular(8),
                shape: BoxShape.rectangle,
              ),
              todayDecoration: BoxDecoration(
                color: const Color(0xFF959D33),
                borderRadius: BorderRadius.circular(8),
                shape: BoxShape.rectangle,
              ),
            ),

          ),
          eventLoader: (day) => healthDataProvider.getDataForDay(day), // 각 날짜에 대한 이벤트 데이터 로드
          selectedDayPredicate: (day) => isSameDay(_selectedDay, day), // 선택된 날짜 판별 함수
          onDaySelected: (selectedDay, focusedDay) { // 날짜 선택 시 호출되는 콜백 함수
            if (!isSameDay(_selectedDay, selectedDay) || !isSameDay(_focusedDay, focusedDay)) {
              setState(() {
                _selectedDay = selectedDay;
                _focusedDay = focusedDay;
              });
            }
          },
          calendarFormat: CalendarFormat.month, // 달력 형식 설정
          onPageChanged: (focusedDay) { // 페이지 변경 시 호출되는 콜백 함수
            if (!isSameDay(_focusedDay, focusedDay)) {
              setState(() {
                _focusedDay = focusedDay;
              });
            }
          },
          calendarBuilders: CalendarBuilders( // 달력 빌더 설정
            markerBuilder: (context, day, events) { // 마커 빌더 설정
              if (events.isNotEmpty) {
                return Positioned(
                  right: 1,
                  bottom: 1,
                  child: buildEventMarker(events.length), // 이벤트 마커 생성
                );

              }
            },
            calendarBuilders: CalendarBuilders(
              markerBuilder: (context, day, events) {
                if (events.isNotEmpty) {
                  return Stack(
                    children: [
                      Positioned.fill(
                        child: Align(
                          alignment: Alignment.bottomRight,
                          child: buildEventMarker(events.length),
                        ),
                      ),
                    ],
                  );
                }
                return null;
              },
              defaultBuilder: (context, day, focusedDay) {
                return _buildCell(day, focusedDay, isSelected: false);
              },
              todayBuilder: (context, day, focusedDay) {
                return _buildCell(day, focusedDay, isToday: true);
              },
              outsideBuilder: (context, day, focusedDay) {
                return _buildCell(day, focusedDay, isOutside: true);
              },
              selectedBuilder: (context, day, focusedDay) {
                return _buildCell(day, focusedDay, isSelected: true);
              },
            ),
          ),
        );
      },
    );
  }

  Widget _buildCell(DateTime day, DateTime focusedDay,
      {bool isSelected = false, bool isToday = false, bool isOutside = false}) {
    final isWeekend = day.weekday == DateTime.saturday || day.weekday == DateTime.sunday;
    final textStyle = TextStyle(
      fontSize: 16,
      color: isSelected
          ? Colors.white
          : isToday
              ? Colors.blue
              : isOutside
                  ? Colors.grey
                  : isWeekend
                      ? Colors.red
                      : Colors.black,
    );

    return Container(
      decoration: isSelected
          ? BoxDecoration(
              color: const Color(0xFF276AEE),
              borderRadius: BorderRadius.circular(8),
              shape: BoxShape.rectangle,
            )
          : null,
      margin: isSelected ? const EdgeInsets.all(6.0) : null,
      alignment: Alignment.center,
      child: Text(
        '${day.day}',
        style: textStyle,
      ),
    );
  }

  Widget buildEventMarker(int count) {
    return Container(
      decoration: const BoxDecoration(
        shape: BoxShape.rectangle,
        color: Colors.red,
      ),
      padding: const EdgeInsets.all(4.0),
      child: Text(
        '$count',
        textAlign: TextAlign.center,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: 10.0,
        ),
      ),
    );
  }

  Widget _selectedDayDetails() {
    return Consumer<HealthDataProvider>(
      builder: (context, provider, child) {
        final data = _selectedDay == null ? [] : provider.getDataForDay(_selectedDay!); // 변경: 선택된 날짜의 데이터 가져오기

        return data.isEmpty
            ? const Center(child: Text('입력된 데이터가 없어요!')) // 데이터가 없을 경우 메시지 표시
            : ListView.separated(

          itemCount: data.length,
          itemBuilder: (_, index) => SizedBox(
            height: 100,
            child: Row(
              children: [
                RichText(
                  text: TextSpan(
                    text: '측정시간\n',
                    style: const TextStyle(
                      fontSize: 18,
                      color: Color(0xFF276AEE),
                    ),
                    children: [
                      TextSpan(
                        text: '${data[index].date.hour}시${data[index].date.minute}분',
                        style: const TextStyle(
                          color: Color(0xFF606060),
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 20),
                Container(
                  height: 80,
                  width: 1,
                  color: Colors.grey,
                ),
                const SizedBox(width: 20),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    RichText(
                      text: const TextSpan(
                        text: '혈압 \n',
                        style: TextStyle(
                          fontSize: 17,
                          color: Color(0xFF606060),
                        ),
                        children: [
                          TextSpan(
                            text: '수축 / 이완',
                            style: TextStyle(
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      '혈당',
                      style: TextStyle(
                        fontSize: 17,
                        color: Color(0xFF606060),
                      ),
                    ),
                  ],
                ),
                const SizedBox(width: 40),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${data[index].systolicBP} / ${data[index].diastolicBP}',
                      style: const TextStyle(fontSize: 24),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      '${data[index].bloodSugar}',
                      style: const TextStyle(fontSize: 24),
                    ),
                  ],
                ),
              ],
            ),
          ),
          separatorBuilder: (_, __) => const Divider(),
        );
      },
    );
  }
}