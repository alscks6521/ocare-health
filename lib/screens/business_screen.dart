// ignore_for_file: dead_code
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
// import 'package:gptchat/consts.dart';
import 'package:http/http.dart' as http;
import 'package:bubble/bubble.dart';
import 'package:loading_indicator/loading_indicator.dart';
import 'package:ocare/screens/consts.dart';
import '../business/screens/nutritional_dialog.dart';
import '../widgets/app_bar.dart';

class BusinessScreen extends StatefulWidget {
  const BusinessScreen({super.key});

  @override
  State<BusinessScreen> createState() => _BusinessScreenState();
}

class _BusinessScreenState extends State<BusinessScreen> {
  final TextEditingController _textController = TextEditingController();
  final List<Map<String, dynamic>> _messages = [];
  final List<dynamic> _items = [];
  bool _isTyping = false;
  bool isButtonDisabled = false;

  @override
  void initState() {
    super.initState();
    _recomNutritional();
  }

  Future<void> _recomNutritional() async {
    // 증상
    var url =
        Uri.parse('http://openapi.foodsafetykorea.go.kr/api/$FOOD_API/C003/json/1/10/PRDLST_NM=혈압');

    var response = await http.get(url);

    if (response.statusCode == 200) {
      var data = jsonDecode(response.body);
      if (data['C003']['row'] != null) {
        List<dynamic> nutritionList = [];

        for (var item in data['C003']['row']) {
          nutritionList.add(item);
          // nutritionList.add(item['PRDLST_NM']);
          // debugPrint("${item['PRDLST_NM']}");
        }
        setState(() {
          _items.addAll(nutritionList);
        });
      } else {
        debugPrint("관련 영양제 정보가 없습니다.");
      }
    } else {
      debugPrint('영양제 정보를 불러오는데 실패했습니다.');
    }
  }

  Future<void> _sendMessage() async {
    final String message = _textController.text;
    _textController.clear();

    setState(() {
      _messages.add({'role': 'user', 'content': message});
      _isTyping = true;
    });
    await Future.delayed(const Duration(seconds: 2));

    final response = await http.post(
      Uri.parse('https://api.openai.com/v1/chat/completions'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $OPENAI_API', // Use your actual API key
      },
      body: jsonEncode({
        'model': 'gpt-3.5-turbo',
        'messages': [
          {
            'role': 'system',
            'content':
                '당신은 건강 관련 질문, 사용자의 현재 몸 상태, 소개 등에 대해 답변해야 합니다. 답변은 300자 내외로 간결하되, 어르신이 이해하기 쉽고 예의 바른 언어로 작성해 주세요. 존댓말을 사용하고, 어려운 의학 용어는 평이한 말로 풀어서 설명해 주세요. 만약 질문이 건강, 몸 상태, 소개 등과 관련이 없다면, "죄송하지만, 건강이나 몸 상태, 소개 등에 관해 더 자세히 말씀해 주시면 제가 잘 이해하고 도와드릴 수 있을 것 같습니다."라고 친절하게 답변해 주세요.',
          },
          {'role': 'user', 'content': message},
        ],
        'max_tokens': 300,
        'temperature': 0.7,
        'n': 1,
      }),
    );
    setState(() {
      _isTyping = false; // 타이핑 상태를 false로 설정
    });

    if (response.statusCode == 200) {
      final jsonResponse = json.decode(utf8.decode(response.bodyBytes));
      final String reply = jsonResponse['choices'][0]['message']['content'];
      if (reply.contains('어르신, 건강이나 몸 상태, 소개 등에 관해 더 자세히 말씀해 주시면 제가 잘 이해하고 도와드릴 수 있을 것 같습니다.')) {
        setState(() {
          _messages.add({
            'role': 'assistant',
            'content':
                '어르신, 건강이나 몸 상태, 소개 등에 관해 더 자세히 말씀해 주시면 제가 잘 이해하고 도와드릴 수 있을 것 같습니다. 어르신의 상태를 더 잘 파악하고 싶습니다.'
          });
        });
      } else {
        setState(() {
          _messages.add({'role': 'assistant', 'content': reply});
        });
      }
    } else {
      setState(() {
        _messages.add({'role': 'assistant', 'content': '죄송합니다. 현재 답변을 생성할 수 없습니다.'}); // 에러 메시지 추가
      });
      debugPrint('Request failed with status: ${response.statusCode}.');
      debugPrint('Response body: ${response.body}');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(15),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const AppbarWidget(title: 'Ai'),
                const SizedBox(height: 20),
                Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.white, // 여기에 배경색을 지정
                    borderRadius: BorderRadius.circular(7),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.3),
                        spreadRadius: 1,
                        blurRadius: 7,
                        offset: const Offset(0, 1),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 8,
                        ),
                        child: Row(
                          children: [
                            RichText(
                              text: TextSpan(
                                children: [
                                  WidgetSpan(
                                    alignment: PlaceholderAlignment.middle,
                                    child: SvgPicture.asset(
                                      './assets/robot.svg',
                                      width: 30.0,
                                      height: 30.0,
                                      colorFilter: const ColorFilter.mode(
                                        Colors.blue, // 원하는 색상으로 변경
                                        BlendMode.srcIn,
                                      ),
                                    ),
                                  ),
                                  const TextSpan(
                                    text: " 제가 추천드리는 영양제입니다!",
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 17,
                                      color: Color.fromARGB(255, 69, 69, 69),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(
                  height: 15,
                ),
                Stack(
                  children: [
                    Container(
                      height: 110,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: const Color(0xFFEFEFEF),
                        borderRadius: BorderRadius.circular(26),
                      ),
                      child: PageView.builder(
                        itemCount: (_items.length / 3).ceil(), // 카드 당 3개씩
                        itemBuilder: (context, index) {
                          int startIndex = index * 3;
                          int endIndex = (index + 1) * 3;
                          if (endIndex > _items.length) endIndex = _items.length;

                          return Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: List.generate(endIndex - startIndex, (itemIndex) {
                              return NutritionalContainer(
                                nutritionalItem: _items[startIndex + itemIndex],
                              );
                            }),
                          );
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 15),
                ConstrainedBox(
                  constraints: BoxConstraints(
                    maxHeight: MediaQuery.of(context).size.height * 0.45,
                  ),
                  child: Column(
                    children: [
                      Expanded(
                        child: Container(
                          color: Colors.transparent,
                          child: ListView.builder(
                            itemCount: _messages.length,
                            shrinkWrap: true,
                            itemBuilder: (context, index) {
                              final message = _messages[index];
                              final isUser = message['role'] == 'user';
                              return Padding(
                                padding: const EdgeInsets.symmetric(vertical: 8.0),
                                child: Bubble(
                                  alignment: isUser ? Alignment.topRight : Alignment.topLeft,
                                  radius: const Radius.circular(26),
                                  padding: const BubbleEdges.symmetric(horizontal: 30),
                                  nip: BubbleNip.no, // Tail 디자인 제거
                                  elevation: 2,
                                  color: isUser ? const Color(0xFFEFEFEF) : const Color(0xFF276AEE),
                                  child: Text(
                                    message['content'],
                                    style: TextStyle(
                                      fontSize: 18,
                                      color: isUser ? Colors.black : Colors.white,
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                      if (_isTyping)
                        Container(
                          color: Colors.transparent,
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8.0),
                            child: Bubble(
                              alignment: Alignment.topLeft,
                              radius: const Radius.circular(26),
                              padding: const BubbleEdges.symmetric(horizontal: 30),
                              nip: BubbleNip.no, // Tail 디자인 제거
                              color: const Color(0xFF276AEE),
                              child: const SizedBox(
                                height: 20,
                                width: 40,
                                child: LoadingIndicator(
                                  indicatorType: Indicator.ballPulse,
                                  colors: [
                                    Colors.white,
                                  ],
                                  strokeWidth: 1,
                                ),
                              ),
                            ),
                          ),
                        ),
                      Container(
                        height: 48,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.3),
                              spreadRadius: 1,
                              blurRadius: 7,
                              offset: const Offset(0, 1),
                            ),
                          ],
                          border: Border.all(
                            color: const Color(0xFF88B0FF),
                          ),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                                child: TextField(
                                  controller: _textController,
                                  decoration: const InputDecoration(
                                    hintText: 'AI에게 건강 상태를 질문해보세요!',
                                    border: InputBorder.none,
                                  ),
                                ),
                              ),
                            ),
                            Container(
                              height: 20,
                              width: 1,
                              color: const Color(0xFFb5b5b5),
                            ),
                            TextButton(
                              onPressed: isButtonDisabled
                                  ? null
                                  : () {
                                      setState(() {
                                        isButtonDisabled = true;
                                      });
                                      _sendMessage();
                                      Future.delayed(const Duration(seconds: 3), () {
                                        setState(() {
                                          isButtonDisabled = false;
                                        });
                                      });
                                    },
                              child: const Text(
                                '전송',
                                style: TextStyle(
                                  color: Color(0xFF276AEE),
                                ),
                              ),
                            ),
                          ],
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
    );
  }
}
