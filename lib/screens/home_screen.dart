import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/gestures.dart';
import 'package:ocare/screens/page/calendarAndChart.dart';
import 'package:ocare/screens/page/user_data_save_page.dart';
import 'package:ocare/widgets/app_bar.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/guardian_user_model.dart';
import '../models/user_model.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  GuardianUserModel guardianUser;

  _HomeScreenState()
      : guardianUser = GuardianUserModel(
          name: '',
          id: '',
          age: 0,
          weight: 0,
          guardian: '',
          systolic: 0,
          diastolic: 0,
          bloodSugar: 0,
          nickname: '',
          email: '',
        );

  @override
  void initState() {
    super.initState();

    _initUserModel();
    _initGuardianUserModel(); // 가디언 초기화 함수

    // 종료되고 실행되었을때 랜덤 배열 로직
    _goodFoods = getRandomGoodFoods(3);
    _badFoods = getRandomBadFoods(2);
  }

  Future<void> _initGuardianUserModel() async {
    final currentUserUID = FirebaseAuth.instance.currentUser?.uid;
    final guardianUID = currentUserUID == 'KWjegweDuEhSVN9I6D8iRnh22kc2'
        ? 'ktgMbo0sT6gyhgTNv8c96UZ3FVm2'
        : 'KWjegweDuEhSVN9I6D8iRnh22kc2';

    final snapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(guardianUID)
        .get();

    if (snapshot.exists) {
      final data = snapshot.data();
      guardianUser = GuardianUserModel(
        name: data?['name'] ?? '',
        id: data?['id'] ?? '',
        age: data?['age'] ?? 0,
        weight: data?['weight'] ?? 0,
        guardian: data?['guardian'] ?? '',
        systolic: data?['systolic'] ?? 0,
        diastolic: data?['diastolic'] ?? 0,
        bloodSugar: data?['bloodSugar'] ?? 0,
        nickname: data?['nickname'] ?? '',
        email: data?['email'] ?? '',
        friends: List<String>.from(data?['friends'] ?? []),
        timestamp: data?['timestamp'],
      );
    }
  }

  // user box ui animation offset init
  double _slideOffset = 0.0;

  // user box list init
  String _goodFoods = '';
  String _badFoods = '';

  Future<void> _initUserModel() async {
    final userModel = Provider.of<UserModel>(context, listen: false);
    await userModel.initFromFirestore();

    // 유저 네임 확인하는 로직.
    if (userModel.name.isEmpty) {
      // 유저 네임이 없을 경우 위의 로직 실행.
      await _showUsernamePopup(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(25.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const AppbarWidget(title: '홈'),
              const SizedBox(height: 20.0),
              Consumer<UserModel>(
                builder: (context, userModel, child) {
                  return _buildUserBox(context);
                },
              ),
              const SizedBox(height: 24.0),
              Consumer<UserModel>(
                builder: (context, userModel, child) {
                  return _buildHealthPositionBox(context);
                },
              ),
              const SizedBox(height: 24.0),
              _buildRecentRecordBox(),
            ],
          ),
        ),
      ),
    );
  }

  ///
  /// 유저이름 작성하는 로직.
  ///
  Future<void> _showUsernamePopup(BuildContext context) async {
    String username = '';
    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('이름 입력'),
          content: TextField(
            onChanged: (value) {
              username = value;
            },
            decoration: const InputDecoration(hintText: '이름을 입력해주세요'),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                if (username.isNotEmpty) {
                  // 업데이트 한거 firebase의 username을 넣는다.
                  final userModel = Provider.of<UserModel>(context, listen: false);
                  userModel.name = username;
                  _saveToFirestore();
                }
              },
              child: const Text('확인'),
            ),
          ],
        );
      },
    );
  }

  /// save to firestore에 name저장 로직
  Future<void> _saveToFirestore() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final userId = user.uid;
      final userModel = Provider.of<UserModel>(context, listen: false);
      final username = userModel.name;

      // 유저이름을 넣는 로직,
      await FirebaseFirestore.instance.collection('users').doc(userId).update({'name': username});
    }
  }

  ///
  /// 유저박스
  ///
  Widget _buildUserBox(BuildContext context) {
    final user = Provider.of<UserModel>(context);

    return GestureDetector(
      onHorizontalDragUpdate: (details) {
        setState(() {
          _slideOffset += details.delta.dx;
          _slideOffset = _slideOffset.clamp(-MediaQuery.of(context).size.width * 2, 0);
        });
      },
      onHorizontalDragEnd: (details) {
        if (_slideOffset < -MediaQuery.of(context).size.width * 1.5) {
          setState(() {
            _slideOffset = -MediaQuery.of(context).size.width * 2;
          });
        } else if (_slideOffset < -MediaQuery.of(context).size.width / 2) {
          setState(() {
            _slideOffset = -MediaQuery.of(context).size.width;
          });
        } else {
          setState(() {
            _slideOffset = 0;
          });
        }
      },
      child: Stack(
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            transform: Matrix4.translationValues(_slideOffset, 0, 0),
            child: Container(
              padding: const EdgeInsets.all(27.0),
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
              child: IntrinsicHeight(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.person,
                          color: Color(0xFF276AEE),
                          size: 56.49,
                        ),
                        Text(
                          '${user.name} 님',
                          style: const TextStyle(fontSize: 20.0),
                        ),
                      ],
                    ),
                    const SizedBox(
                      width: 0,
                    ),
                    const VerticalDivider(
                      color: Colors.grey,
                      thickness: 1.0,
                      width: 32.0,
                    ),
                    const SizedBox(
                      width: 15,
                    ),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                '혈압',
                                style: TextStyle(fontSize: 20.0),
                              ),
                              const Text(
                                '이완/ 수축',
                                style: TextStyle(fontSize: 14.0),
                              ),
                              Text(
                                '${user.diastolic}/ ${user.systolic}',
                                style: const TextStyle(
                                  fontSize: 28.0,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 16.0), // 큰 줄 간격
                              const Text(
                                '혈당',
                                style: TextStyle(fontSize: 20.0),
                              ),
                              Text(
                                '${user.bloodSugar}',
                                style: const TextStyle(
                                  fontSize: 28.0,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          )
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            transform: Matrix4.translationValues(
              _slideOffset + MediaQuery.of(context).size.width,
              0,
              0,
            ),
            child: UserGuardBox(user: user, guardianUser: guardianUser),
          ),
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            transform: Matrix4.translationValues(
              _slideOffset + MediaQuery.of(context).size.width * 2,
              0,
              0,
            ),
            child: UserInfoCard(
              user: user,
              slideOffset: 0.0,
            ),
          ),
          Positioned(
            top: 0,
            bottom: 0,
            right: 10,
            child: Center(
              child: AnimatedOpacity(
                opacity: _slideOffset == 0 ? 1.0 : 0.0,
                duration: const Duration(milliseconds: 100),
                child: Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.grey.withOpacity(0.5),
                  ),
                  padding: const EdgeInsets.all(8.0),
                  child: const Icon(
                    Icons.arrow_forward_ios,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

// 건강데이터 종류
  List<String> goodFoods = ['당근', '호박', '고구마', '브로콜리', '시금치', '토마토', '파프리카', '양배추', '오이', '가지'];
  List<String> badFoods = ['치킨', '햄버거', '피자', '감자튀김', '도넛', '핫도그', '소시지', '베이컨', '초콜릿바', '캔디'];

// 몸에 좋은 음식 가져오기
  String getRandomGoodFoods(int count) {
    final random = Random();
    return List.generate(count, (_) => goodFoods[random.nextInt(goodFoods.length)]).join(', ');
  }

// 몸에 안좋은 음식 가져오기
  String getRandomBadFoods(int count) {
    final random = Random();
    return List.generate(count, (_) => badFoods[random.nextInt(badFoods.length)]).join(', ');
  }

  // 건강위치 박스
  ///
  /// 건강 데이터 혈압, 혈당에 비래해서 건강 데이터 수치 조절 로직 <br>
  /// 혈압은 정상 120 / 경계성 140 / ~고혈압
  /// 혈당 80~120 / 120 ~ 위험
  ///
  Widget _buildHealthPositionBox(context) {
    final user = Provider.of<UserModel>(context);

    double progress = 0.8; // 초기 진행 비율은 30%로 설정
    double screenWidth = MediaQuery.of(context).size.width;
    double gaugeWidth = screenWidth * 0.8; // 화면 너비의 80%를 게이지 너비로 설정

    Color gaugeColor = const Color(0xFF276AEE); // 초기 게이지 색상은 파란색으로 설정

// 혈압과 혈당에 따른 진행 비율 및 색상 설정
    bool isBpNormal = user.systolic < 120 && user.diastolic < 80;
    bool isBpHigh = user.systolic >= 140 || user.diastolic >= 90;

    bool isBsNormal = user.bloodSugar >= 80 && user.bloodSugar <= 120;
    bool isBsRisky = user.bloodSugar < 80 || user.bloodSugar > 120;

    if (isBpHigh || isBsRisky) {
      progress = 1.0; // 위험: 혈압 고혈압 또는 혈당 위험일 경우 진행 비율 100%
      gaugeColor = const Color(0xFFFF0000); // 위험일 경우 빨간색
    } else if (isBpNormal && isBsNormal) {
      progress = 0.3; // 매우 정상: 혈압과 혈당 모두 정상일 경우 진행 비율 30%
      gaugeColor = const Color(0xFF00FF00); // 매우 정상일 경우 초록색
    } else {
      progress = 0.6; // 정상: 그 외의 경우 진행 비율 60%
      gaugeColor = const Color(0xFF276AEE); // 정상일 경우 파란색
    }

    return InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => CalendarAndChartPage(), // CalendarAndChartPage 위젯으로 변경
            ),
          );
        },


    child:  Container(



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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '나의 건강 위치',
            style: TextStyle(fontSize: 15),
          ),
          const SizedBox(height: 8.0),
          Row(
            children: [
              Text(
                progress < 0.6 ? '정상' : (progress < 1.0 ? '경계' : '위험'),
                style: TextStyle(fontSize: 30, color: gaugeColor),
              ),
              const Text(
                '입니다',
                style: TextStyle(fontSize: 30),
              ),
            ],
          ),
          const SizedBox(height: 8.0),
          Container(
            height: 20,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(26),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x29000000),
                  blurRadius: 6.0,
                  offset: Offset(0, 3),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  height: 20,
                  width: gaugeWidth * progress, // 진행 비율과 화면 너비에 따라 너비 조절
                  decoration: BoxDecoration(
                    color: gaugeColor,
                    borderRadius: BorderRadius.circular(26),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    )


    );
  }

  // 최근 기록 로직
  ///
  /// 최근에 저장된 데이터 로직
  /// 리스트로 언제 데이터 저장했었는지 알 수 있게?
  ///
  Widget _buildRecentRecordBox() {
    final userModel = Provider.of<UserModel>(context);

    return GestureDetector(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const UserDataSavePage()),
          );
        },
        child: Container(
          padding: const EdgeInsets.all(16.0),
          decoration: BoxDecoration(
            color: const Color(0xFFEFEFEF),
            borderRadius: BorderRadius.circular(10.0),
            boxShadow: const [
              BoxShadow(
                color: Color(0x29000000),
                blurRadius: 6.0,
                offset: Offset(0, 3),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                '나의 최근 기록',
                style: TextStyle(fontSize: 15),
              ),
              const SizedBox(height: 8.0),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildTimestampText(userModel.timestamp),
                  const SizedBox(width: 16.0),
                  Container(
                    height: 30.0,
                    width: 1.0,
                    color: Colors.grey,
                  ),
                  const SizedBox(width: 16.0),
                  _buildTimeText(userModel.timestamp), // 변경된 부분
                ],
              ),
            ],
          ),
        ));
  }

  // 최근 기록 박스
  Widget _buildTimestampText(Timestamp? timestamp) {
    if (timestamp != null) {
      final dateTime = timestamp.toDate();
      return Text(
        '${dateTime.year}.${dateTime.month}.${dateTime.day}',
        style: const TextStyle(fontSize: 30.0),
      );
    } else {
      return const Text('날짜: N/A', style: TextStyle(fontSize: 30.0));
    }
  }

  ///
  /// 시간정보
  Widget _buildTimeText(Timestamp? timestamp) {
    if (timestamp != null) {
      final dateTime = timestamp.toDate();
      final hourString = dateTime.hour.toString().padLeft(2, '0'); // 시간에 0 추가
      final minuteString = dateTime.minute.toString().padLeft(2, '0'); // 분에 0 추가
      return Text(
        '$hourString:$minuteString',
        style: const TextStyle(fontSize: 30.0, color: Color(0xFF276AEE)),
      );
    } else {
      return const Text('N/A', style: TextStyle(fontSize: 30.0, color: Color(0xFF276AEE)));
    }
  }
}

// 다른 사용자 info 입력칸,
//만약 fw사용자라면 fq사용자의 name데이터
//fq사용자라면 fw의 사용자 데이터의 이름이 보이게 설정
//둘다 아니고 상대방의 이름이 없다면 추가 내용을 표시하게

class UserInfoCard extends StatelessWidget {
  final UserModel user;
  final double slideOffset;

  const UserInfoCard({super.key, required this.user, required this.slideOffset});

  Future<String> getOtherUserName(String userId) async {
    String otherUserId = userId == 'ktgMbo0sT6gyhgTNv8c96UZ3FVm2'
        ? 'KWjegweDuEhSVN9I6D8iRnh22kc2'
        : 'ktgMbo0sT6gyhgTNv8c96UZ3FVm2';

    DocumentSnapshot snapshot =
        await FirebaseFirestore.instance.collection('users').doc(otherUserId).get();

    if (snapshot.exists) {
      Map<String, dynamic> data = snapshot.data() as Map<String, dynamic>;
      return data['name'] ?? '이름 없음';
    } else {
      return '상대방의 이름이 없습니다.';
    }
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 500,
      height: 200,
      child: Stack(
        children: [
          Container(
            width: double.infinity,
            height: double.infinity,
            padding: const EdgeInsets.all(27.0),
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
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                FutureBuilder<String>(
                  future: getOtherUserName(user.name),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const CircularProgressIndicator();
                    } else if (snapshot.hasError) {
                      return Text('에러: ${snapshot.error}');
                    } else {
                      String otherUserName = snapshot.data?.trim() ?? '';
                      if (false) {
                        return const Text(
                          '연결되지 않음',
                          style: TextStyle(fontSize: 24.0, fontWeight: FontWeight.bold),
                        );
                      } else {
                        return RichText(
                          textAlign: TextAlign.center,
                          text: const TextSpan(
                            children: [
                              TextSpan(
                                text: '연동된 파트너의 계정이 없습니다',
                                style: TextStyle(
                                  fontSize: 22.0,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black,
                                ),
                              ),
                              // TextSpan(
                              //   text: '\n사용자 추가하기.',
                              //   style: TextStyle(
                              //     fontSize: 20.0,
                              //     color: Colors.blue,
                              //     decoration: TextDecoration.underline,
                              //   ),
                              //   recognizer: TapGestureRecognizer()
                              //     ..onTap = () {
                              //       context.push(AppScreen.userDetail);
                              //       print('자세히 보기 클릭');
                              //     },
                              // ),
                            ],
                          ),
                        );
                      }
                    }
                  },
                ),
              ],
            ),
          ),
          Positioned(
            top: 0,
            bottom: 0,
            left: 10,
            child: Center(
              child: AnimatedOpacity(
                opacity: slideOffset == 0 ? 1.0 : 0.0,
                duration: const Duration(milliseconds: 200),
                child: Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.grey.withOpacity(0.5),
                  ),
                  padding: const EdgeInsets.all(8.0),
                  child: const Icon(
                    Icons.arrow_back_ios,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class UserGuardBox extends StatelessWidget {
  final UserModel user;
  final GuardianUserModel guardianUser;

  const UserGuardBox({Key? key, required this.user, required this.guardianUser})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final currentUserUID = FirebaseAuth.instance.currentUser?.uid;
    final guardianUID = currentUserUID == 'KWjegweDuEhSVN9I6D8iRnh22kc2'
        ? 'ktgMbo0sT6gyhgTNv8c96UZ3FVm2'
        : 'KWjegweDuEhSVN9I6D8iRnh22kc2';

    return ConstrainedBox(
      constraints: const BoxConstraints(
        minWidth: double.infinity,
        minHeight: 200,
      ),
      child: Stack(
        children: [
          Container(
            padding: const EdgeInsets.all(27.0),
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
            child: IntrinsicHeight(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.person,
                        color: Color(0xFF276AEE),
                        size: 56.49,
                      ),
                      RichText(
                        textAlign: TextAlign.center,
                        text: TextSpan(
                          children: [
                            const TextSpan(
                              text: '파트너의 정보\n',
                              style: TextStyle(
                                fontSize: 15.0, // 혈압 텍스트 크기
                                color: Colors.black,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            TextSpan(
                              text: '${guardianUser.name}',
                              style: TextStyle(
                                fontSize: 20.0, // 이완 수축 텍스트 크기
                                color: Colors.black,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(width: 0),
                  const VerticalDivider(
                    color: Colors.grey,
                    thickness: 1.0,
                    width: 32.0,
                  ),
                  const SizedBox(width: 15),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              '혈압',
                              style: TextStyle(fontSize: 20.0),
                            ),
                            const Text(
                              '이완/ 수축',
                              style: TextStyle(fontSize: 14.0),
                            ),
                            Text(

                              '${guardianUser.diastolic}/ ${guardianUser.systolic}',
                              style: TextStyle(
                                fontSize: 28.0,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 16.0), // 큰 줄 간격
                            const Text(
                              '혈당',
                              style: TextStyle(fontSize: 20.0),
                            ),
                            Text(
                              '${guardianUser.bloodSugar}',
                              style: TextStyle(
                                fontSize: 28.0,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        )
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            top: 0,
            bottom: 0,
            right: 10,
            child: Center(
              child: AnimatedOpacity(
                opacity: _slideOffset == 0 ? 1.0 : 0.0,
                duration: const Duration(milliseconds: 100),
                child: Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.grey.withOpacity(0.5),
                  ),
                  padding: const EdgeInsets.all(8.0),
                  child: const Icon(
                    Icons.arrow_forward_ios,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            top: 0,
            bottom: 0,
            left: 10,
            child: Center(
              child: AnimatedOpacity(
                opacity: _slideOffset == 0 ? 1.0 : 0.0,
                duration: const Duration(milliseconds: 100),
                child: Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.grey.withOpacity(0.5),
                  ),
                  padding: const EdgeInsets.all(8.0),
                  child: const Icon(
                    Icons.arrow_back_ios,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

double _slideOffset = 0.0;
