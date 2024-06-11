import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:ocare/widgets/text_field_with_controller.dart';
// import 'package:ocare/widgets/user_data_text_field_with_controller.dart';
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





    return Container(
        decoration: BoxDecoration(
          color: Colors.grey[200], // 배경색 변경
          borderRadius: BorderRadius.circular(16.0), // 모서리 반지름 변경
        ),
        child: Padding(
          padding: const EdgeInsets.all(30.0), // 전체 패딩 값 설정
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: TextFieldWithController(
                      label: '이름',
                      hintText: user.name,
                      controller: nameController,
                    ),
                  ),
                  const SizedBox(width: 16.0),

                  Expanded(
                    child: FutureBuilder<String>(
                      future: getOtherUserName(user.name),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return const CircularProgressIndicator();
                        } else if (snapshot.hasError) {
                          return Text('에러: ${snapshot.error}');
                        } else {
                          String otherUserName = snapshot.data?.trim() ?? '';
                          return TextFieldWithController(
                            label: '나의 보호자',
                            hintText: user.guardian,
                            controller: guardianController,
                          );
                        }
                      },
                    ),
                  ),

                  // 고유번호 필요한지?
                  // Expanded(
                  //   child: TextFieldWithController(
                  //     label: '고유번호',
                  //     hintText: '고유번호를 입력하세요',
                  //     controller: idController,
                  //   ),
                  // ),
                ],
              ),
              const SizedBox(height: 16.0),
              Row(
                children: [
                  Expanded(
                    child: TextFieldWithController(
                      label: '나이',
                      hintText: '${user.age}',
                      controller: ageController,
                      keyboardType: TextInputType.number,
                    ),
                  ),
                  const SizedBox(width: 16.0),
                  Expanded(
                    child: TextFieldWithController(
                      label: '체중',
                      hintText: '${user.weight}',
                      controller: weightController,
                      keyboardType: TextInputType.number,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16.0),
              const SizedBox(height: 16.0),
              Row(

                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [

                  /// 일단 주석처리함. 제대로 실행되는거 확인후 디자인 수정하기
                  // Expanded(
                  //   child: TextFieldWithController(
                  //       label: '수축기',
                  //
                  //     keyboardType: TextInputType.number,
                  //     controller: systolicController,
                  //
                  //   ),
                  // ),
                  // Expanded(
                  //   child: TextFieldWithController(
                  //     decoration: const InputDecoration(
                  //       labelText: '이완기',
                  //     ),
                  //     keyboardType: TextInputType.number,
                  //     controller: diastolicController,
                  //   ),
                  // ),
                  // const SizedBox(width: 16.0),
                  Expanded(
                    child: CustomTextField(
                      label: '체중',
                      hintText: '${user.weight}',
                      controller: weightController,


                    ),
                  ),
                ],
              ),
              const SizedBox(
                height: 26,
              ),


              /// 저장 로직입니다.
              Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton(
                      onPressed: () async {
                        FirestoreServiceCustom firestoreService = FirestoreServiceCustom();
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
}}
