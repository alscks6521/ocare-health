import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:ocare/widgets/text_field_with_controller.dart';
import 'package:provider/provider.dart';

import '../models/user_model.dart';
import '../services/firebase-custom-service-save.dart';

class UserBoxUserDataSave extends StatelessWidget {
  UserBoxUserDataSave({
    super.key,
    required this.nameController,
    required this.idController,
    required this.ageController,
    required this.weightController,
    required this.guardianController,
    required this.systolicController,
    required this.diastolicController,
    required this.bloodSugarController,
  });

  final TextEditingController nameController;
  final TextEditingController idController;
  final TextEditingController ageController;
  final TextEditingController weightController;
  final TextEditingController guardianController;
  final TextEditingController systolicController;
  final TextEditingController diastolicController;
  final TextEditingController bloodSugarController;

  final systolicValues =
      List.generate(200, (index) => (index + 100).toString());
  final diastolicValues =
      List.generate(150, (index) => (index + 40).toString());
  final bloodSugarValues =
      List.generate(400, (index) => (index + 60).toString());

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<UserModel>(context);

    // 필요한 로직?
    String? validateValue(String? value, List<String> values) {
      if (value == null || !values.contains(value)) {
        return values.isNotEmpty ? values.first : null;
      }
      return value;
    }

    //상대방 데이터 가져오는 로직
    Future<String> getOtherUserName(String userId) async {
      String otherUserId = userId == 'ktgMbo0sT6gyhgTNv8c96UZ3FVm2'
          ? 'KWjegweDuEhSVN9I6D8iRnh22kc2'
          : 'ktgMbo0sT6gyhgTNv8c96UZ3FVm2';

      DocumentSnapshot snapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(otherUserId)
          .get();

      if (snapshot.exists) {
        Map<String, dynamic> data = snapshot.data() as Map<String, dynamic>;
        return data['name'] ?? '상대방 이름 없음';
      } else {
        return '상대방의 이름이 없습니다.';
      }
    }
    // 인풋 높이 지정
    double height = 55;
  double width = 182;

    return Container(
        decoration: BoxDecoration(

        ),
        child: Padding(
          padding: const EdgeInsets.all(30.0), // 전체 패딩 값 설정

          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [


              SizedBox(
                height: height,
                width: width,
                child: CustomTextField(
                  label: '체중',
                  hintText: '${user.weight}',
                  controller: weightController,
                  keyboardType: TextInputType.number,
                ),
              ),
              SizedBox(height: 18,),
              SizedBox(
                height: height,
                child: CustomTextField(
                  label: '나이',
                  hintText: '${user.age}',
                  controller: ageController,
                  keyboardType: TextInputType.number,
                ),
              ),
              SizedBox(
                height: height,
                child: CustomTextField(
                  label: '체중',
                  hintText: '${user.weight}',
                  controller: weightController,
                ),
              ),





              /// 저장 로직입니다.
              Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton(
                      onPressed: () async {
                        FirestoreServiceCustom firestoreService =
                            FirestoreServiceCustom();
                        await firestoreService.saveToFirestoreCustom(
                          nameController: nameController,
                          idController: idController,
                          ageController: ageController,
                          weightController: weightController,
                          guardianController: guardianController,
                          systolicController: systolicController,
                          diastolicController: diastolicController,
                          bloodSugarController: bloodSugarController,
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size(140, 50),
                        backgroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                          side: const BorderSide(
                            color: Colors.blue,
                            width: 1.0,
                          ),
                        ),
                      ),
                      child: const Text(
                        '저장',
                        style: TextStyle(
                          color: Colors.blueAccent,
                          fontSize: 20.0,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ));
  }
}
