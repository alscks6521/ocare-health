import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../models/HealthData.dart';

class HealthDataProvider with ChangeNotifier {
  /// 날짜별로 데이터를 그룹화하여 저장. 특정 날짜의 데이터를 가져올 때 더 빠른 검색이 가능
  final Map<DateTime, List<HealthData>> _healthDataMap = {};

  List<HealthData> get allData =>
      _healthDataMap.values.expand((data) => data).toList();

  void addHealthData(HealthData data) {
    final dateKey = DateTime(data.date.year, data.date.month, data.date.day);
    _healthDataMap[dateKey] ??= [];
    _healthDataMap[dateKey]!.add(data);
    debugPrint('입력 : ${data.date.day}');
    notifyListeners();
  }

  List<HealthData> getDataForDay(DateTime day) {
    final dateKey = DateTime(day.year, day.month, day.day);
    return _healthDataMap[dateKey] ?? [];
  }

  // 파이어베이스 데이터 불러오기
  Future<void> loadDataFromFirebase() async {
    try {
      final usersCollection = FirebaseFirestore.instance.collection('users');
      final userDoc = usersCollection.doc('KWjegweDuEhSVN9I6D8iRnh22kc2');
      final userDataCollection = userDoc.collection('user_data');
      final querySnapshot = await userDataCollection.get();

      print('Documents retrieved: ${querySnapshot.docs.length}'); // 가져온 문서 개수 로그 출력


      final List<HealthData> healthDataList = [];

      for (final doc in querySnapshot.docs) {
        final data = doc.data();
        print('Document data: $data'); // 각 문서의 데이터 로그 출력

        final healthData = HealthData(
          date: (data['timestamp'] as Timestamp).toDate(), // timestamp 값을 DateTime으로 변환
          systolicBP: data['systolic'],
          diastolicBP: data['diastolic'],
          bloodSugar: data['bloodSugar'],
        );
        healthDataList.add(healthData);
      }
      print('Health data loaded: $healthDataList'); // 가져온 건강 데이터 로그 출력

      // Update the health data in the provider
      // ...
      _healthDataMap.clear();
      for (final data in healthDataList) {
        addHealthData(data);
      }
      notifyListeners();

    } catch (e) {
      print('Error loading data from Firebase: $e');
    }
  }

}
