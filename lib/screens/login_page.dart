import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:kakao_flutter_sdk/kakao_flutter_sdk.dart';
import 'package:ocare/constants/constants.dart';
import 'package:ocare/screens/home_screen.dart';
import 'package:provider/provider.dart';
import 'package:ocare/models/user_model.dart';
import '../components/colors.dart';
import '../controllers/user_controller.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  Future<void> initLoginService(BuildContext context) async {
    try {
      print("로그인 시도");
      var token = await UserApi.instance.loginWithKakaoTalk();
      debugPrint('카카오 로그인 성공, 액세스 토큰: ${token.accessToken}');

      var user = await UserApi.instance.me();
      print("로그인 시도 값: $token, $user");

      // 카카오 계정 정보로 Firebase Authentication에 계정 생성 또는 로그인
      String email = user.kakaoAccount?.email ?? '';
      String password = user.id.toString(); // 카카오 ID를 비밀번호 대용으로 사용
      String displayName = user.kakaoAccount?.profile?.nickname ?? '';

      try {
        print("로그인 시도2");
        // Firebase Authentication에 계정 생성 또는 로그인 시도
        UserCredential userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: email,
          password: password,
        );

        // 사용자 이름(닉네임) 설정
        await userCredential.user?.updateDisplayName(displayName);

        // UserController의 saveUserData 메서드 호출하여 사용자 정보 저장
        final userController = UserController();

        // 초기화 값.
        await userController.saveUserData(
          user.id.toString(),
          // 사용자 식별자(카카오 ID)
          displayName,
          // 사용자 이름
          user.id.toString(),
          // 사용자 고유 식별자(카카오 ID)
          0,
          // 나이 (필요한 경우 수정)
          0,
          // 체중 (필요한 경우 수정)
          '',
          // 보호자 (필요한 경우 수정)
          0,
          // 수축기 혈압 (필요한 경우 수정)
          0,
          // 이완기 혈압 (필요한 경우 수정)
          0,
          // 혈당 (필요한 경우 수정)
          Timestamp.now(),
          user.kakaoAccount?.profile?.nickname ?? '',
          // 닉네임 추가
          user.kakaoAccount?.email ?? '', // 이메일 추가

          // 현재 시간을 나타내는 Timestamp 객체 전달
        );

        // 로그인 성공 처리
        Provider.of<UserModel>(context, listen: false).nickname = displayName;
        Provider.of<UserModel>(context, listen: false).email = email;
        Navigator.pushReplacement(
            context, MaterialPageRoute(builder: (context) => const HomeScreen()));
      } on FirebaseAuthException catch (e) {
        if (e.code == 'email-already-in-use') {
          // 이미 존재하는 이메일인 경우, 로그인 시도
          await FirebaseAuth.instance.signInWithEmailAndPassword(
            email: email,
            password: password,
          );

          // 로그인 성공 처리
          Provider.of<UserModel>(context, listen: false).nickname = displayName;
          Provider.of<UserModel>(context, listen: false).email = email;
          Navigator.pushReplacement(
              context, MaterialPageRoute(builder: (context) => const HomeScreen()));
        } else {
          debugPrint('Firebase Authentication 에러: ${e.code}');
          // 에러 처리 로직 추가
        }
      } catch (e) {
        debugPrint('Firebase Authentication 에러: $e');
        // 에러 처리 로직 추가
      }
    } catch (error) {
      print(await KakaoSdk.origin);
      debugPrint('카카오 로그인 실패 $error');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Expanded(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      'Ocare',
                      style: TextStyle(
                        fontSize: 40,
                        color: MyColors.primaryColor,
                        fontFamily: 'Gmak',
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 10),
                    Text(
                      '당신을 위한 건강 관리',
                      style: TextStyle(
                        fontSize: 15,
                        color: MyColors.primaryColor,
                        fontFamily: 'Gmak',
                        fontWeight: FontWeight.w300,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                initLoginService(context);
              },
              child: const Text(
                '카카오 연동하기',
                style: TextStyle(fontSize: 15),
              ),
            ),
            const SizedBox(
              height: 110,
            )
          ],
        ),
      ),
    );
  }
}
