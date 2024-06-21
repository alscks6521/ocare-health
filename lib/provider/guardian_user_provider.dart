import 'package:flutter/foundation.dart';
import '../models/guardian_user_model.dart';

class GuardianUserProvider with ChangeNotifier {
  GuardianUserModel? _guardianUser;

  GuardianUserModel? get guardianUser => _guardianUser;

  Future<void> loadGuardianData(String guardianUID) async {
    _guardianUser = GuardianUserModel(
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

    await _guardianUser?.loadGuardianData(guardianUID);
    notifyListeners();
  }
}