import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:ocare/screens/consts.dart';

class ChatState with ChangeNotifier {
  final List<Map<String, dynamic>> _messages = [];
  List<dynamic> _items = [];
  bool _isTyping = false;

  List<Map<String, dynamic>> get messages => _messages;
  List<dynamic> get items => _items;
  bool get isTyping => _isTyping;

  Future<void> init() async {
    await recomNutritional();
  }

  void addMessage(Map<String, dynamic> message) {
    _messages.add(message);
    notifyListeners();
  }

  void setItems(List<dynamic> items) {
    _items = items;
    notifyListeners();
  }

  void setIsTyping(bool isTyping) {
    _isTyping = isTyping;
    notifyListeners();
  }

  Future<void> recomNutritional() async {
    var url =
        Uri.parse('http://openapi.foodsafetykorea.go.kr/api/$FOOD_API/C003/json/1/10/PRDLST_NM=혈압');

    var response = await http.get(url);

    if (response.statusCode == 200) {
      var data = jsonDecode(response.body);
      if (data['C003']['row'] != null) {
        List<dynamic> nutritionList = [];

        for (var item in data['C003']['row']) {
          nutritionList.add(item);
        }
        setItems(nutritionList);
      } else {
        debugPrint("관련 영양제 정보가 없습니다.");
      }
    } else {
      debugPrint('영양제 정보를 불러오는데 실패했습니다.');
    }
  }

  Future<void> sendMessage(String message) async {
    addMessage({'role': 'user', 'content': message});
    setIsTyping(true);

    await Future.delayed(const Duration(seconds: 2));

    final response = await http.post(
      Uri.parse('https://api.openai.com/v1/chat/completions'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $OPENAI_API',
      },
      body: jsonEncode({
        'model': 'gpt-3.5-turbo',
        'messages': [
          {
            'role': 'system',
            'content':
                '당신은 건강 관련 질문, 사용자의 현재 몸 상태, 소개 등에 대해 답변해야 합니다. 답변은 300자 내외로 간결하되, 어르신이 이해하기 쉽고 예의 바른 언어로 작성해 주세요. 존댓말을 사용하고, 어려운 의학 용어는 쉽게 말로 풀어서 설명해 주세요. 만약 질문이 건강, 몸 상태, 소개 등과 관련이 없다면, "죄송하지만, 건강이나 몸 상태, 소개 등에 관해 더 자세히 말씀해 주시면 제가 잘 이해하고 도와드릴 수 있을 것 같습니다."라고 친절하게 답변해 주세요.',
          },
          {'role': 'user', 'content': message},
        ],
        'max_tokens': 300,
        'temperature': 0.7,
        'n': 1,
      }),
    );

    setIsTyping(false);

    if (response.statusCode == 200) {
      final jsonResponse = json.decode(utf8.decode(response.bodyBytes));
      final String reply = jsonResponse['choices'][0]['message']['content'];
      if (reply.contains('어르신, 건강이나 몸 상태, 소개 등에 관해 더 자세히 말씀해 주시면 제가 잘 이해하고 도와드릴 수 있을 것 같습니다.')) {
        addMessage({
          'role': 'assistant',
          'content':
              '어르신, 건강이나 몸 상태, 소개 등에 관해 더 자세히 말씀해 주시면 제가 잘 이해하고 도와드릴 수 있을 것 같습니다. 어르신의 상태를 더 잘 파악하고 싶습니다.'
        });
      } else {
        addMessage({'role': 'assistant', 'content': reply});
      }
    } else {
      addMessage({'role': 'assistant', 'content': '죄송합니다. 현재 답변을 생성할 수 없습니다.'});
      debugPrint('Request failed with status: ${response.statusCode}.');
      debugPrint('Response body: ${response.body}');
    }
  }
}
