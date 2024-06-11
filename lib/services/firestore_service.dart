import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';

class FirestoreService {
  // 위 코드는 정상적으로 작동되는것인지 테스트 필요. 각 데이터가 firestore에 저장되며 collection에 중첩되어서 파일을 만들어서 저장되는지 확인이 필요함.
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // 새로운 컬렉션 이름을 _userDataCollectionName 변수에 저장
  final String _userDataCollectionName = 'user_data';

  // 여기서도 profile screen에서 사용되는 save to firestore가 여기에 있음. -> 여기서는 저장되는 로직이 다음과 같음. 전체적인 저장로직을 설정하며, usersdptj
  // 파라미터 값으로 user id를 받고 user model값을 받음.
  Future<void> saveToFirestore(String userId, UserModel userModel) async {
    try {
      await _firestore
          .collection('users')
          .doc(userId)
          .set(userModel.toMap(), SetOptions(merge: true));
      // 데이터 저장 로직. collection은 users에 저장되며 doc는 userid에 저장됨. userid에따라 users에 저장되는 값이 다름.
      // 옵션을 설정해줄 수 있는데 , usermode은 to map으로 데이터를 저장하고 set options으로서 merge 가 true가 되게 저장됨.
      // user_data 저장 위해 saveUserDataToFirestore 함수 호출
      await saveUserDataToFirestore(userId, userModel.toMap());

      /*
    * 저장되지 못했을때 반환값을 출력함.
    * */
    } catch (e) {
      print('Failed to save data to Firestore: $e');
    }
  }

  // Firestore에 userData를 저장하는 함수 -> user data에 이중으로 데이터가 저장될 수 있게 하는 로직.
/*전체적인 구조는 위의 savetofiresotre와 비슷하나 다른점이 있음.
* 밑의 함수는 user_data에 추가적인 컬렉션을 생성하고 그곳에 데이터가 저장되게 할 수 있음.
* */
  Future<void> saveUserDataToFirestore(
      String userId, Map<String, dynamic> userData) async {
    try {
      // 'users' 컬렉션 내에 userId 문서의 서브컬렉션인 'user_data'에 새로운 문서를 추가
      // 문서 ID는 'user_data1', 'user_data2'와 같이 순차적으로 생성
      final newDocId = 'user_data${await _getNextUserDataIndex(userId)}';
      //  순차적으로 data의 숫자에 따라서 데이터가 저장됨.
      await _firestore
          .collection('users')
          .doc(userId)
          .collection(_userDataCollectionName)
          .doc(newDocId)
          .set(userData);
    } catch (e) {
      print('Failed to save user data to Firestore: $e');
    }
  }

  /*솔직히 밑의 함수는 위와 같은데 왜 있는지 모르겠음. 주석처리해도 코드가 실행된다면, 굳이 필요한 함수인가 싶음.*/
  // 다음에 생성될 userData 문서의 인덱스를 가져오는 함수
  Future<int> _getNextUserDataIndex(String userId) async {
    try {
      // 'users' 컬렉션 내에 userId 문서의 서브컬렉션인 'user_data'의 문서 개수
      final snapshot = await _firestore
          .collection('users')
          .doc(userId)
          .collection(_userDataCollectionName)
          .get();
      // 문서 개수에 1을 더하여 다음 인덱스를 반환합니다.
      return snapshot.size + 1;
    } catch (e) {
      print('Failed to get next user data index: $e');
    }
    return 1; // 오류 발생 시 기본값으로 1을 반환
  }
}
