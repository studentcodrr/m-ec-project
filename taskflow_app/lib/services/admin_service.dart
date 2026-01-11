import 'package:firebase_auth/firebase_auth.dart';

class AdminService {
  Future<bool> isCurrentUserAdmin() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return false;

    // force refresh so changes take effect after promotion/demotion
    final token = await user.getIdTokenResult(true);
    return token.claims?['admin'] == true;
  }
}