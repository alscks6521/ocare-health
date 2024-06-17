import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:go_router/go_router.dart';
import 'package:ocare/widgets/app_bar.dart';
import 'package:flutter/material.dart';
import 'package:ocare/controllers/user_controller.dart';
import 'package:provider/provider.dart';
import '../models/user_model.dart';
import '../router/app_router.dart';
import '../services/notification_service.dart';
import '../widgets/user_box.dart';

/*
* 각 해당 ui에 맞게 모듈화 진행 요청 -> 1개밖에 안쓰이는것은 모듈화 필요 없음.
* ui의
* */

// 위 파일은 프로필 스크린임. 프로필의 스크린을 확인하고, 개인의 정보를 확인할 수 있으며, 수정도 가능함.
class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

// 아 코드 주석 남겨야 하는데, 뭐가 뭔지 알 수 있어야.. 주석을 남기든 말든 할텐데. 우짜냐 진짜.
// 일단 밑 부분은 선언. textediting controller로서, text입력값을 받는 부분.

// text edit는 다른 파일에서도 사용해야하기에, 주석 처리후, 화면에 textview로 바꾼다.
class _ProfileScreenState extends State<ProfileScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _idController = TextEditingController();
  final TextEditingController _ageController = TextEditingController();
  final TextEditingController _weightController = TextEditingController();
  final TextEditingController _guardianController = TextEditingController();
  final TextEditingController _systolicController = TextEditingController();
  final TextEditingController _diastolicController = TextEditingController();
  final TextEditingController _bloodSugarController = TextEditingController();

  final UserController _userController = UserController();

  // 밑 코드는 초기화 코드, 만약, 초기화 하지 않는다면 어떤일이?
  @override
  void initState() {
    super.initState();
  }

  //
  //  super는 상위 객체에서 dispose를 가져오겠다는건데, 위의 코드를 가져오는 이유가 궁금.
  @override
  void dispose() {
    _nameController.dispose();
    _idController.dispose();
    _ageController.dispose();
    _weightController.dispose();
    _guardianController.dispose();
    _systolicController.dispose();
    _diastolicController.dispose();
    _bloodSugarController.dispose();
    super.dispose();
  }

  // 위 코드는 firestore에 데이터를 저장하는 로직. 가장 핵심인 부분. 위의 입력값들을 각 형식에 맞게 firestore에 저장하는 역할을 하기때문에. 가장 핵심기능이라고 할수있음.
  // 데이터를 가져온후  ,
  /// 테스트용 코드 작성. 지정된 uid를 사용해서 해당 uid는 루트 데이터 베이스를 사용할 수 있게 코드 변경.
  ///
  /// 유저 박스에서 사용되고 있기에 필요하지 않은 코드.
  Future<void> _saveToFirestore() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final userId = user.uid; // 현재 로그인한 사용자의 식별자 가져오기
      final timestamp = Timestamp.now(); // 현재 시간을 가져오기

      // 닉네임, 이메일 가져오기 실패
      // -> 이름 수정하려면 nickname을 수정해야하는데,
      final nicknameController = TextEditingController();
      final emailController = TextEditingController();

      // add code -> 야매로 함. 실질적으로는 uid가져와서 입력
      // pw- a6521
      // ktgMbo0sT6gyhgTNv8c96UZ3FVm2 사용자인 경우 -> 특정 사용자 추가. 데이터가 루트사용자에게 저장될 수 있게 로직 변경. 위와 같은 로직으로 kt사용자는 루트 데이터베이스에 데이터를 저장할 수 있고, 데이터를 불러오는게 가능해짐.

//TODO add code
// -> kt user일 경우, data가 안가져와짐. -> 수정 kt, kw 둘다 가져와지게.
      if (userId == 'ktgMbo0sT6gyhgTNv8c96UZ3FVm2' || userId == 'KWjegweDuEhSVN9I6D8iRnh22kc2') {
        String targetUserId = userId == 'ktgMbo0sT6gyhgTNv8c96UZ3FVm2'
            ? 'KWjegweDuEhSVN9I6D8iRnh22kc2'
            : 'ktgMbo0sT6gyhgTNv8c96UZ3FVm2';

        //
        await _userController.saveUserData(
          targetUserId,
          _nameController.text,
          _idController.text,
          int.tryParse(_ageController.text) ?? 0,
          int.tryParse(_weightController.text) ?? 0,
          _guardianController.text,
          int.tryParse(_systolicController.text) ?? 0,
          int.tryParse(_diastolicController.text) ?? 0,
          int.tryParse(_bloodSugarController.text) ?? 0,
          timestamp,
          nicknameController.text,
          emailController.text,
        );
      }

      // 현재 사용자의 데이터베이스에도 저장
      await _userController.saveUserData(
        userId,
        _nameController.text,
        _idController.text,
        int.tryParse(_ageController.text) ?? 0,
        int.tryParse(_weightController.text) ?? 0,
        _guardianController.text,
        int.tryParse(_systolicController.text) ?? 0,
        int.tryParse(_diastolicController.text) ?? 0,
        int.tryParse(_bloodSugarController.text) ?? 0,
        timestamp,
        nicknameController.text,
        emailController.text,
      );
    } else {
      // 로그인하지 않은 경우 처리 로직 추가
      // 예: 로그인 화면으로 이동, 오류 메시지 표시 등
      // print("당신은 로그인할 수 없습니다.");
      return;
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<UserModel>(context);

    return SafeArea(
      child: ListView(
        // Column 대신 ListView 사용
        padding: const EdgeInsets.all(25.0),

        children: [
          const AppbarWidget(title: '내 정보'),
          const SizedBox(height: 20.0),

          // Text(
          //   '${user.name} 님 안녕하세요 \n오늘하루도 건강한 하루 되세요',
          //   style: TextStyle(
          //     fontSize: 18.0,
          //     fontWeight: FontWeight.bold,
          //   ),
          // ),
          const SizedBox(
            height: 16,
          ),

          UserBox(
            nameController: _nameController,
            idController: _idController,
            ageController: _ageController,
            weightController: _weightController,
            guardianController: _guardianController,
            systolicController: _systolicController,
            diastolicController: _diastolicController,
            bloodSugarController: _bloodSugarController,

            /// save로직 포함.
          ),

          const SizedBox(height: 16.0),
          _buildButtonSection(context),
          const SizedBox(
            height: 32,
          ),
          _buildSettingsText(),
          const SizedBox(
            height: 24,
          ),
          _buildPushNotificationSetting(),
          const SizedBox(
            height: 24,
          ),
          _buildPrivacyAndMarketingSettings(),
          const SizedBox(
            height: 24,
          ),
          _inviteSetting(),
          const SizedBox(
            height: 24,
          ),
          _invite(),
          const SizedBox(height: 80.0), // 바텀 패딩 추가
        ],
      ),

      // floatingActionButton: Container(
      //   width: 80.0, // 너비
      //   height: 80.0, // 높이

      //   margin: const EdgeInsets.only(bottom: 175), // 원하는 만큼 위로 올리기
      //   // child: FloatingActionButton(
      //   //   onPressed: _saveToFirestore,
      //   //   child: const Icon(
      //   //     Icons.save,
      //   //     size: 40,
      //   //   ), // 아이콘 크기도 조절
      //   // ),
      // ),
    );
  }

  Widget _buildButtonSection(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: const Color(0xFFEFEFEF),
        borderRadius: BorderRadius.circular(26.0),
        boxShadow: const [
          BoxShadow(
            color: Color(0x29000000),
            blurRadius: 6.0,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          ElevatedButton(
            onPressed: () {
              context.push(AppScreen.calendarPage);
              // context.push(AppScreen.calendarAndChart);
            },
            style: ElevatedButton.styleFrom(
              minimumSize: const Size(140, 50),
              backgroundColor: Colors.blue,
              // 버튼의 가로 및 세로 크기 설정
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15), // 버튼의 모서리 반경 설정
              ), // 버튼의 배경색 설정
            ),
            child: const Text(
              '캘린더',
              style: TextStyle(
                color: Colors.white, // 텍스트 색상을 흰색으로 설정
                fontSize: 24.0, // 텍스트 크기를 24로 설정
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              context.push(AppScreen.chartPage);
            },
            style: ElevatedButton.styleFrom(
              minimumSize: const Size(140, 50),
              backgroundColor: Colors.blue,
              // 버튼의 가로 및 세로 크기 설정
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15), // 버튼의 모서리 반경 설정
              ), // 버튼의 배경색 설정
            ),
            child: const Text(
              '통계',
              style: TextStyle(
                color: Colors.white, // 텍스트 색상을 흰색으로 설정
                fontSize: 24.0, // 텍스트 크기를 24로 설정
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsText() {
    return const Padding(
      padding: EdgeInsets.symmetric(horizontal: 0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            '앱 설정',
            style: TextStyle(
              fontSize: 50.0,
            ),
          ),
        ],
      ),
    );
  }

  bool isSwitched = false; // false

  ///
  /// 알림 설정
  Widget _buildPushNotificationSetting() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 0.0),
      child: Container(
        padding: const EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          color: const Color(0xFFEFEFEF),
          borderRadius: BorderRadius.circular(26.0),
          boxShadow: const [
            BoxShadow(
              color: Color(0x29000000),
              blurRadius: 6.0,
              offset: Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              '앱 알림 설정 (테스트알림)',
              style: TextStyle(
                fontSize: 20.0,
              ),
            ),
            Switch(
              value: isSwitched,
              onChanged: (value) {
                setState(() {
                  isSwitched = value;
                  if (isSwitched) {
                    FlutterLocalNotification.showNotification();
                    // 테스트 알림
                    // Fluttertoast.showToast(
                    //   msg: "알림이 설정되었습니다.",
                    //   toastLength: Toast.LENGTH_LONG,
                    //   gravity: ToastGravity.TOP,
                    //   timeInSecForIosWeb: 1,
                    //   backgroundColor: Colors.grey,
                    //   textColor: Colors.white,
                    //   fontSize: 24.0,
                    // );
                  }
                });
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPrivacyAndMarketingSettings() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: .0),
      child: Container(
        padding: const EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          color: const Color(0xFFEFEFEF),
          borderRadius: BorderRadius.circular(26.0),
          boxShadow: const [
            BoxShadow(
              color: Color(0x29000000),
              blurRadius: 6.0,
              offset: Offset(0, 3),
            ),
          ],
        ),
        child: const ExpansionTile(
          title: Text(
            '개인정보 활용 및 마케팅 수신',
            style: TextStyle(
              fontSize: 20.0,
            ),
          ),
          children: [
            Padding(
              padding: EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '개인정보 활용 동의',
                    style: TextStyle(
                      fontSize: 16.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 8.0),
                  Text(
                    '서비스 제공을 위해 필수적인 개인정보 수집에 동의합니다.',
                    style: TextStyle(
                      fontSize: 14.0,
                    ),
                  ),
                  SizedBox(height: 16.0),
                  Text(
                    '마케팅 수신 동의',
                    style: TextStyle(
                      fontSize: 16.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 8.0),
                  Text(
                    '이벤트 및 프로모션 정보를 수신하는 것에 동의합니다.',
                    style: TextStyle(
                      fontSize: 14.0,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _inviteSetting() {
    return const Padding(
      padding: EdgeInsets.symmetric(horizontal: 0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            '초대',
            style: TextStyle(
              fontSize: 50.0,
            ),
          ),
        ],
      ),
    );
  }

  Widget _invite() {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: const Color(0xFFEFEFEF),
        borderRadius: BorderRadius.circular(26.0),
        boxShadow: const [
          BoxShadow(
            color: Color(0x29000000),
            blurRadius: 6.0,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          // ElevatedButton(
          //   onPressed: () {
          //     context.push(AppScreen.mainPage);
          //   },
          //   child: const Text('오케어 초대'),
          // ),
          ElevatedButton(
            onPressed: () {
              context.push(AppScreen.mainPage);
            },
            style: ElevatedButton.styleFrom(
              minimumSize: const Size(160, 50),
              backgroundColor: Colors.blue,
              // 버튼의 가로 및 세로 크기 설정
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15), // 버튼의 모서리 반경 설정
              ), // 버튼의 배경색 설정
            ),
            child: const Text(
              '오케어 초대하기',
              style: TextStyle(
                color: Colors.white, // 텍스트 색상을 흰색으로 설정
                fontSize: 20.0, // 텍스트 크기를 24로 설정
              ),
            ),
          ),

          // 캘린더 버튼
        ],
      ),
    );
  }
}
