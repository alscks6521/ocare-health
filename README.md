## 건강 'O'케어 앱

### 팀 역할

**디자인(김유진) :**

1. 모델링 초안을 통한 프로젝트 모델링 제작
2. 피그마 이용  
   https://www.figma.com/file/SUOTP5sP5llsLiCKXZpqlu/Untitled?type=design&t=j2lKJHXDYFnqyBR7-6
   <img width="20%" alt="Pasted Graphic" src="https://github.com/alscks6521/health-care-ocare/assets/112923685/cacdfbc5-afc0-49ce-9d58-631fc9fde449">

**디자인(백예준)**.

1. 프로젝트 XD 스타일링
2. 피그마 , XD 이용  
   https://www.figma.com/design/heOuQ4IYUrdbihYjcOQEEd/AllCare?node-id=1-2&t=0cmlhljquiCnIhjl-0
   <img width="20%" alt="Pasted Graphic 1" src="https://github.com/alscks6521/health-care-ocare/assets/112923685/4c57e159-a63f-461f-8431-3b1253e1f46b">

   ***

**문서계획 (김시온)**

1. 프로젝트 기획구상 및 관리
   https://docs.google.com/document/d/1WWEBnlKkD_EmjnFpXzvrdcYwnwkcTwpE-ucwi7pueZ4/edit
2. 여러 문서 작업
3. 프로젝트 모델링 초안 구현

---

**개발 (김민기)**

1. Firebase 인증(카카오 토큰저장)
2. Firebase 데이터베이스 관리
3. 보호자와의 데이터 공유 시스템 연동

UI : Screens (로그인, 메인, 내정보…)

**개발 (김민성)**

1. Kakao Platform 로그인, 사용자 정보 조회, 템플릿 메시지
2. OPEN AI API 챗봇, 영양제 API

UI : Screens ( AI, 차트, 캘린더… )

---

---

## 건강 추가될 데이터 클래스 ( 건강 시각화 )

```dart
class HealthData {
  final DateTime date; // 추가된 날짜
  final int systolicBP; // 수축기
  final int diastolicBP; // 이완기
  final int bloodSugar; // 혈당

  HealthData({
    required this.date,
    required this.systolicBP,
    required this.diastolicBP,
    required this.bloodSugar,
  });
}
```

<img src="https://github.com/alscks6521/health-care-ocare/assets/112923685/c8518c2b-1657-4be2-9308-b6b2000e1b13" width="15%">
<img src="https://github.com/alscks6521/health-care-ocare/assets/112923685/5574976e-3be1-4b0b-8bd8-68381cf625a7" width="15%">

### 데이터 상태 관리 Provider

```dart
class HealthDataProvider with ChangeNotifier {
  final List<HealthData> _healthDataList = []; // HealthData 객체 저장 리스트

  List<HealthData> get data => _healthDataList;

  void addHealthData(HealthData data) {
    _healthDataList.add(data);
    debugPrint('입력 : ${data.date.day}');
    notifyListeners();
  }

  List<HealthData> getDataForDay(DateTime day) {
    return _healthDataList.where((data) {
      return data.date.year == day.year && data.date.month == day.month && data.date.day == day.day;
    }).toList();
  }

  //TODO
  // 파이어베이스 데이터 불러오기
}
```

## KaKao Login Service

https://github.com/alscks6521/flutter-login-kakao

연동페이지 구현

구현 위해 nickname data는 따로 두기.
)-> 반대 벡엔드 구현 완

연동페이지 구현 거의 완료
)->

차트 날짜 데이터 가져오는거 하고 끝
로그인 데이터도 할 수 있으면 좋음.

---

디자인

> 앱 아이콘 디자인
> 알림 디자인
> 테마 디자인 - 네비게이션 색 바꿔야함.

버튼 디자인 )- 버튼 커보이게
데이터 저장 로직 데이터 나오는곳 밑에 바로 위치할 수 있게
정보 저장 아이콘 밑에 저장
로그인 화면 디자인
초대 화면 디자인

데이터 저장 로직 바꾸기. 일단 kw는 nickname에 이름 데이터가 저장되게?

---

일단, 데이터가 collectiondptj uid로 이중 저장되게 해야함.

이를 위해서-> firestore의 규칙을 변경할 필요 있음. 하지만 규칙을 변경했어도 제대로 작동되지 않음. 이와같은 문제 해결법을 위한 방법?

전의 규칙 그대로 실행했으나, 똑같은 문제가 발생했기에, 문제 해결 방안으로서 어떻게 해야할지 찾기 바람.
->

1. nickname과 name의 backend로직 변경. ->

   1. nickname이 실질적 name 역할 <name을 처음에 입력할 수 있게 하여 이름 설정하기> -> profile에서 name 변경 controller를 nickname으로 바꾸기
   2. 앱이 시작되고 맨 처음 값에 닉네임이 없을경우 창이 나와서 이름 설정하라고 나오기. -> 위 기능을 하는 로직.
   3. -> 처음 시작하자 마자 나오게.
      )-> 하고, firebase의 name에 저장되게 provider를 사용

2. 추가적으로 home에서 맨위 ui를 옆으로 넘기면 보이는 페이지가 가디언 데이터를 불러올 수 있게 하기
   1. -> 보호자의 data를 가져와서 옆에 보여질 수 있게 해야함.-> 아이콘을 넣어 옆으로 넘길 수 있게. 상대방의 nickname값을 불러와야함. 상대방이 아직 이름을 작성하지 않았다면 값이 들어가지 않음.
3. > 3. 시작하자마자. home과 연결되며 아이디를 새로 만들었을경우 nickname을 설정할 수 있으며, namew이 설정되면, name데이터가 저장되어서 불러올때 name이 불러와지게.
   >    위의 기능은 필요한 기능인가? 처음 사용자에게 필요한 기능
   1. 1번과 동일
      ) -> fw,fq?의 이름과 데이터를 똑같이 설정했는데, name부분은 빼야하는가? name부분을 제외한 데이터 통합 ........ -> 데이터 저장 로직에서 profile에서 설정할 수 있을것임.
      닉네임을 따로 저장하는것을 성공 이제 가디언 즉, 상대방 정보 ( 이름을 가져오게 할 수 있어야함. )

-> 데이터 저장 화면 새로 만들기. 근데, 만들 필요가 있나?

> 5. 메인페이지에서 친구 초대하는 화면도 변경 백그라운 배경없애고, 메시지 고! 라는 메시지와 친구의 버튼 디자인을 변경해서 시각적으로 더 잘보일 수 있게.

1. 일단 보류 안해도 됨

2. 앱 알림 설정에서 앱 알림이 갈 수 있게. 설정. 앱 알림 기능을 만들어야지. true, false값을 전달할 수 있음.

   1. 앱 아이콘을 누르면 스택값이 생성됨. 언제 알림이 울렸는지 테스트를 처음 실행하고 그 이후 값이 순차적으로 샇이는지 확인. -> 데이터 저장은 로컬 저장소에 데이터가 저장될 수 있게 해야함.

   알림이 4시간 마다 한번씩 가게 설정. -> 4시간 마다 받은 알림이 알림페이지에 스택처럼 데이터 저장됨. 휴지통 버튼을 누르면 모든 알림 삭제됨.
   알림이 가는 기능과 그 데이터가 저장되는 로직만 일단 구성. )->
   )-> end

3. 프로필 화면에서 있는 데이터 값은 텍스트값으로 저장되며, 지워서 저장해야함.
   1. 프로필 화면에서 데이터 입력 값 페이지를 새로 만들것임. 그냥 보여주는걸로 바꾸고 새로운 페이지를 만들어서 그 페이지에 보이도록 설정하기
      )-> 일반 화면에서는 데이터가 입력되어있고 건들지 못하게
   2. 데이터 저장화면 새로 만들고 화면 이동되면 거기서 데이터 저장할 수 있게.

-> 시작하자마자 데이터 인풋값 뜨게 하는 로직 팝업 처럼 뜨고 인풋 컨트롤러를 사용해서 name을 받는것.
flutter언어에서,
핵심 키워드 시작하자마자 .텍스트 이름을 입력해주세요 .인풋 텍스트. 확인버튼
위 기능을 하는 방법에 대한 기술 설명.

-> 만약 데이터가 있을경우, 이름설정 팝업은 뜨지 않음.

---

총 3시간 안에 완성하기
-> 데이터 공유 기능도 만들어야함 -> 우선적으로 데이터 공유 기능? 야매로 함. 사용자가 사용자일경우 루트의ㅣ 데이터베이스에 데이터가 저장되게 로직을 바꿈.
질문? 그럼. 본질적으로 원래의 데이터베이스는 없어지는건가?

데이터 베이스를 공유해야함. 데이터 베이스를 공유하는 방법? ->
이론적으로 데이터 베이스를 어떻게 공유할 수 있는지 찾기

갖고 있는 이론.
나는 firestore를 사용한다. 규칙은 다음과 같다. collection에 데이터가 새롭게 저장된다. 기존의 데이터는 새롭게 저장된다. (일단 이것부터 해야한다.)

firestore의 service의 코드는 다음과 같다. 근데, 데이터는 collection이 중복 저장되지 않는다. 이와 같은 문제를 해결하기 위해서 어떻게?
->

### firesotre - 중복 데이터 저장 로직. 질문 ->

{

rules_version = '2'; // 룰 버전 2 사용
service cloud.firestore { // firestore cloude를 사용하고.
match /databases/{database}/documents { // match에서 어떻게
match /users/{userId} { //userid를 어떻게?
allow read, write: if request.auth != null && request.auth.uid == userId; // read, write를 사용하고 리퀘스트 사용자 널이 아닐경우 리퀘스트 auth.uid가 userid와 같은지 확인.
match /{document=\*\*} { //document는
allow read, write: if request.auth != null && request.auth.uid == userId; // allow read와 write그리고 request가 uid와 userid가 일치할 경우.
} } } }

// 여기서 알고리즘을 이용해서 . user의 id를 입력해서 데이터 베이스를 동기화 하는게 가능한가?
}

-> 임시로 uid를 똑같이 생성하여, 데이터 베이스를 공용화 하는게 가능한가?

---

데이터 동기화를 위해서 하는 방법.

save firebase에서 -> if문을 추가해서
ktgMbo0sT6gyhgTNv8c96UZ3FVm2의 유저만
KWjegweDuEhSVN9I6D8iRnh22kc2의 데이터베이스에 엑세스 하고 읽기, 쓰기가 될 수 있게 if문을 통해서 코드 수정 요청

save to firestore가 있는 코드

- firestore service , profile screen
- 코드는 다음과 같음.

-

// Firestore에 userData를 저장하는 함수 -> user data에 이중으로 데이터가 저장될 수 있게 하는 로직.
/\*전체적인 구조는 위의 savetofiresotre와 비슷하나 다른점이 있음.

단, 기존의 기능은 유지해야함.

-> first
profile에 있는 코드를 추가함. kt USER의 데이터베이스를 kw유저의 데이터에 저장되게 함. 실패.
firestore service의 파일을 수정해서 코드 변경 요청 -> 실패. 애초에 데이터가 저장될대 kt의 데이터로 저장됨.

위의 문제를 해결하기 위한 방법 ->
kt의 데이터를 kw로 바궈야 함.
-> 모든 로직이 kt는 kt의 데이터로 만들어짐. - 문제해결을 위한 방법.

---

위의 코드에서 profile screen에서 주석. TODO add code를 확인 요청
-> 추가로 firestore의 규칙을 변경했으니, 규칙 확인 요청
위의 코드를 확인하여, 알고리즘에 맞게 실행되는지 확인 요청

---

일단 프로필
저장 아이콘 위로 올리고,
데이터 입력되어있게. 힌트가 아닌 값으로 저장되어 있게 하기.
보호자는 상대방 user name값

알림 화면 디자인 하기

로그인 화면 디자인하기

일단 이론상 kt와 kw의 이름을 다르게 설정해두기. 그래서 kt는 name을 kw는 nickname을 사용하게 하기.

노티피케이션 리스트에 몇분전 몇분전 이런 기능을 넣고 싶은데.

--- 순서로 문제 해결 snapshot -d error ?
flutter clean
flutter pub get
depfile 경로가 언급되어 있습니다. 프로젝트 디렉토리 경로에 문제를 일으킬 수 있는 특수 문자나 공백이 없는지
dart --version
flutter channel stable

---

차트 , 캘린더 백엔드 가져올 수 있게.
일단 네비게이션 때문에 오류 발생.

1. 차트, 캘린더는 네비게이션바 안생기게 수정.

calendar initializeDateFormatting main에 추가
chart도 마찬가지. init 해줘야함.

clear

---

2. 차트, 캘린더 데이터 firebase에 저장된 데이터 가져올 수 있어야함

캘린더 연결

1. healthdataprovider class -> loaddatafromfirebase 로직 추가. user_data에 있는 모든 값 가져오는 로직.
2. usermodel class에 frommap생성자 해놨음.
3. loaddatafromfirebase 해서 초기화하고 값 가져오기.

차트 연결
캘린더 연결하면서 provider연결됨.

# ocare-health
# ocare-health
