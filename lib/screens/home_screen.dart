import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/gestures.dart';
import 'package:go_router/go_router.dart';
import 'package:ocare/widgets/app_bar.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/user_model.dart';
import '../router/app_router.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    _initUserModel();
    // 종료되고 실행되었을때 랜덤 배열 로직
    _goodFoods = getRandomGoodFoods(3);
    _badFoods = getRandomBadFoods(2);
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
    return Scaffold(
      body: SafeArea(
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
                  final userModel =
                      Provider.of<UserModel>(context, listen: false);
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
      await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .update({'name': username});
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
          _slideOffset = _slideOffset.clamp(-MediaQuery.of(context).size.width, 0);
        });
      },
      onHorizontalDragEnd: (details) {
        if (_slideOffset < -MediaQuery.of(context).size.width / 2) {
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
            duration: Duration(milliseconds: 300),
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
                        Icon(
                          Icons.person,
                          color: Color(0xFF276AEE),
                          size: 56.49,
                        ),
                        Text(
                          '${user.name} 님',
                          style: TextStyle(fontSize: 20.0),
                        ),
                      ],
                    ),
                    SizedBox(
                      width: 0,
                    ),
                    VerticalDivider(
                      color: Colors.grey,
                      thickness: 1.0,
                      width: 32.0,
                    ),
                    SizedBox(
                      width: 15,
                    ),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Text(
                                '혈압',
                                style: TextStyle(fontSize: 15.0),
                              ),
                              SizedBox(width: 4.0),
                              Text(
                                '${user.systolic}',
                                style: TextStyle(
                                  fontSize: 25.0,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              SizedBox(width: 8.0),
                              Text(
                                '혈당',
                                style: TextStyle(fontSize: 15.0),
                              ),
                              SizedBox(width: 4.0),
                              Text(
                                '${user.bloodSugar}',
                                style: TextStyle(
                                  fontSize: 25.0,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 8.0),
                          Text(
                            '이런 음식이 좋아요!',
                            style: TextStyle(fontSize: 17.0),
                          ),
                          Text(
                            _goodFoods,
                            style: TextStyle(
                              fontSize: 15.0,
                              color: Colors.grey,
                            ),
                          ),
                          SizedBox(height: 8.0),
                          Text(
                            '이런 음식이 나빠요!',
                            style: TextStyle(fontSize: 17.0),
                          ),
                          Text(
                            _badFoods,
                            style: TextStyle(
                              fontSize: 15,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          AnimatedContainer(
            duration: Duration(milliseconds: 200),
            transform: Matrix4.translationValues(
              _slideOffset + MediaQuery.of(context).size.width,
              0,
              0,
            ),
            child: UserInfoCard(user: user),
          ),
          Positioned(
            top: 0,
            bottom: 0,
            right: 10,
            child: Center(
              child: AnimatedOpacity(
                opacity: _slideOffset == 0 ? 1.0 : 0.0,
                duration: Duration(milliseconds: 200),
                child: Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.grey.withOpacity(0.5),
                  ),
                  padding: EdgeInsets.all(8.0), // 아이콘과 동그라미 사이의 간격 조절
                  child: Icon(
                    Icons.arrow_forward_ios,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          )

        ],
      ),
    );
  }

// 건강데이터 종류
  List<String> goodFoods = [
    '당근',
    '호박',
    '고구마',
    '브로콜리',
    '시금치',
    '토마토',
    '파프리카',
    '양배추',
    '오이',
    '가지'
  ];
  List<String> badFoods = [
    '치킨',
    '햄버거',
    '피자',
    '감자튀김',
    '도넛',
    '핫도그',
    '소시지',
    '베이컨',
    '초콜릿바',
    '캔디'
  ];

// 몸에 좋은 음식 가져오기
  String getRandomGoodFoods(int count) {
    final random = Random();
    return List.generate(
        count, (_) => goodFoods[random.nextInt(goodFoods.length)]).join(', ');
  }

// 몸에 안좋은 음식 가져오기
  String getRandomBadFoods(int count) {
    final random = Random();
    return List.generate(
        count, (_) => badFoods[random.nextInt(badFoods.length)]).join(', ');
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
    );
  }

  // 최근 기록 로직
  ///
  /// 최근에 저장된 데이터 로직
  /// 리스트로 언제 데이터 저장했었는지 알 수 있게?
  ///
  Widget _buildRecentRecordBox() {
    final userModel = Provider.of<UserModel>(context);

    return Container(
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
    );
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
      final minuteString =
          dateTime.minute.toString().padLeft(2, '0'); // 분에 0 추가
      return Text(
        '$hourString:$minuteString',
        style: const TextStyle(fontSize: 30.0, color: Color(0xFF276AEE)),
      );
    } else {
      return const Text('N/A',
          style: TextStyle(fontSize: 30.0, color: Color(0xFF276AEE)));
    }
  }
}


// 다른 사용자 info 입력칸,
//만약 fw사용자라면 fq사용자의 name데이터
//fq사용자라면 fw의 사용자 데이터의 이름이 보이게 설정
//둘다 아니고 상대방의 이름이 없다면 추가 내용을 표시하게

class UserInfoCard extends StatelessWidget {
  final UserModel user;

  const UserInfoCard({Key? key, required this.user}) : super(key: key);

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
      return data['name'] ?? '이름 없음';
    } else {
      return '상대방의 이름이 없습니다.';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(

      // 크기 고정 로직
      width: 500, // 가로 길이 맞춰서 코드 수정해야함.
      height: 200,

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
                return CircularProgressIndicator();
              } else if (snapshot.hasError) {
                return Text('에러: ${snapshot.error}');
              } else {
                // string이 공백일 경우 연결되지 않음을 출력. 일단,
                String otherUserName = snapshot.data?.trim() ?? '';
                if (otherUserName.isEmpty) {
                  return Text(
                    '연결되지 않음',
                    style: TextStyle(fontSize: 24.0, fontWeight: FontWeight.bold),
                  );
                } else {


                  return RichText(
                    textAlign: TextAlign.center,
                    text: TextSpan(
                      children: [
                        TextSpan(
                          text: '${user.guardian} 님과 \n연결되어 있습니다.\n',
                          style: TextStyle(
                            fontSize: 24.0,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                        TextSpan(
                          text: '자세히 보시려면 눌러주세요.',
                          style: TextStyle(
                            fontSize: 20.0,
                            color: Colors.blue,
                            decoration: TextDecoration.underline,
                          ),

                          recognizer: TapGestureRecognizer()
                            ..onTap = () {
                            // user detail로 이동하는 로직.
                              context.push(AppScreen.userDetail);
                              print('자세히 보기 클릭');
                            },
                        ),
                      ],
                    ),
                  );
                }
              }
            },
          ),
        ],
      ),
    );
  }
}
