import 'dart:async';
import 'package:ocare/components/colors.dart';
import 'package:ocare/router/app_router.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Timer(
      const Duration(seconds: 1),
      () => context.pushReplacement(AppScreen.home),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
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
          Padding(
            padding: const EdgeInsets.only(bottom: 100.0),
            child: SizedBox(
              width: 33,
              height: 33,
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(
                    MyColors.primaryMaterialColor.shade600),
                strokeWidth: 5.0,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
