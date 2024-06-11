import 'package:flutter/material.dart';

class TextFieldWithController extends StatelessWidget {
  const TextFieldWithController({
    super.key,
    required this.label,
    required this.hintText,
    required this.controller,
    this.keyboardType = TextInputType.text,
  });

  final String label;
  final String hintText;
  final TextEditingController controller;
  final TextInputType keyboardType;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 16.0,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8.0),
        SizedBox(
          width: 200,
          height: 45,
          child: TextField(
            controller: controller,
            keyboardType: keyboardType,
            decoration: InputDecoration(

              hintText: hintText,
              hintStyle: const TextStyle(height: 0.0), // 힌트 텍스트 줄 간격 제거


              filled: true, // 배경색 설정을 위해 필요
              fillColor: Colors.white, // 배경색 설정
              alignLabelWithHint: true, // 힌트와 레이블 정렬
              contentPadding: const EdgeInsets.symmetric(
                vertical: 15.0,
                horizontal: 15.0,
              ), // 텍스트 수직, 수평 정렬

              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10.0), // TextField 둥근 모서리 설정
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10.0), // 활성화 상태의 둥근 모서리 설정
                borderSide: BorderSide.none,
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10.0), // 포커스 상태의 둥근 모서리 설정
                borderSide: BorderSide.none,
              ),

            ),
          ),
        ),
      ],
    );
  }
}


/// 텍스트필드 상속받는 class파일 입니다
class CustomTextField extends TextFieldWithController {
  const CustomTextField({
    super.key,
    required String label,
    required String hintText,
    required TextEditingController controller,
    TextInputType keyboardType = TextInputType.text,
    EdgeInsetsGeometry contentPadding = const EdgeInsets.symmetric(
      vertical: 15.0,
      horizontal: 15.0,
    ),
  }) : super(
    label: label,
    hintText: hintText,
    controller: controller,
    keyboardType: keyboardType,
  );

  @override
  Widget build(BuildContext context) {


    return Row(
      children: [


        Text(
          label,
          style: const TextStyle(
            fontSize: 16.0,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(width: 8.0),

        Expanded(
          child: SizedBox(
            height: 45,
            child: TextField(
              controller: controller,
              keyboardType: keyboardType,
              decoration: InputDecoration(
                hintText: hintText,
                hintStyle: const TextStyle(height: 0.0),

                // input값 색 변경 코드
                filled: true,
                fillColor: Colors.deepOrangeAccent, // 배경색 설정
                alignLabelWithHint: true,


                contentPadding: const EdgeInsets.symmetric(
                  vertical: 15.0,
                  horizontal: 15.0,
                ), // 텍스트 수직, 수평 정렬


                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.0),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.0),
                  borderSide: BorderSide.none,
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.0),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

