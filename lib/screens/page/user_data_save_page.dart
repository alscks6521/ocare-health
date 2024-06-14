import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../widgets/user_box_user_data_save.dart';

class UserDataSavePage extends StatefulWidget {
  const UserDataSavePage({super.key});

  @override
  State<UserDataSavePage> createState() => _UserDataSavePageState();
}

class _UserDataSavePageState extends State<UserDataSavePage> {

  //초기화 선언.
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _idController = TextEditingController();
  final TextEditingController _ageController = TextEditingController();
  final TextEditingController _weightController = TextEditingController();
  final TextEditingController _guardianController = TextEditingController();
  final TextEditingController _systolicController = TextEditingController();
  final TextEditingController _diastolicController = TextEditingController();
  final TextEditingController _bloodSugarController = TextEditingController();


  @override
  Widget build(BuildContext context) {


    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(25.0),
          children: [
            const Row(
              children: [
                // 뒤로가기 아이콘 필요할때 대비 코드
                // IconButton(
                //   icon: Icon(Icons.arrow_back),
                //   onPressed: () {
                //     Navigator.of(context).pop();
                //   },
                // ),
                Text(
                  '내 기록',
                  style: TextStyle(
                    fontSize: 35,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            // 데이터 입력란.
            Column(
              children: [
                ///
                /// 유저박스 가져오기
                UserBoxUserDataSave(
                  nameController: _nameController,
                  idController: _idController,
                  ageController: _ageController,
                  weightController: _weightController,
                  guardianController: _guardianController,
                  systolicController: _systolicController,
                  diastolicController: _diastolicController,
                  bloodSugarController: _bloodSugarController,
                ),
                /// 데이터 저장 , 위의 데이터 전부 되게 일단?

              ],
            )
          ],
        ),
      ),
    );
  }
}
                /// 저장로직 만들어야 합니다.
