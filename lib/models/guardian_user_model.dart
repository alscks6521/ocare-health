import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

class GuardianUserModel with ChangeNotifier {
  String name;
  String id;
  int age;
  int weight;
  String guardian;
  int systolic;
  int diastolic;
  int bloodSugar;
  String nickname;
  String email;
  List<String>? friends;
  Timestamp? timestamp;

  GuardianUserModel({
    required this.name,
    required this.id,
    required this.age,
    required this.weight,
    required this.guardian,
    required this.systolic,
    required this.diastolic,
    required this.bloodSugar,
    required this.nickname,
    required this.email,
    this.friends,
    this.timestamp,
  });

  factory GuardianUserModel.fromMap(Map<String, dynamic> map) {
    return GuardianUserModel(
      name: map['name'],
      id: map['id'],
      age: map['age'],
      weight: map['weight'],
      guardian: map['guardian'],
      systolic: map['systolic'],
      diastolic: map['diastolic'],
      bloodSugar: map['bloodSugar'],
      nickname: map['nickname'] ?? '',
      email: map['email'] ?? '',
      friends: List<String>.from(map['friends'] ?? []),
      timestamp:
      map['timestamp'] != null ? (map['timestamp'] as Timestamp) : null,
    );
  }

  Future<void> loadGuardianData(String guardianUID) async {
    final firestore = FirebaseFirestore.instance;
    final guardianDoc = await firestore.collection('users').doc(guardianUID).get();

    if (guardianDoc.exists) {
      final guardianData = guardianDoc.data();
      name = guardianData?['name'] ?? '';
      id = guardianData?['id'] ?? '';
      age = guardianData?['age'] ?? 0;
      weight = guardianData?['weight'] ?? 0;
      guardian = guardianData?['guardian'] ?? '';
      systolic = guardianData?['systolic'] ?? 0;
      diastolic = guardianData?['diastolic'] ?? 0;
      bloodSugar = guardianData?['bloodSugar'] ?? 0;
      nickname = guardianData?['nickname'] ?? '';
      email = guardianData?['email'] ?? '';
      timestamp = guardianData?['timestamp'];

      notifyListeners();
    } else {
      // 보호자 문서가 없는 경우 처리
    }
  }
}