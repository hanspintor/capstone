import 'package:proxpress/services/auth.dart';

class TheUser {
  final String uid;
  final AuthService _auth = AuthService();
  TheUser({this.uid});

  Future<bool> UserIdentifier(bool isCustomer) async {
    return await _auth.identifyUser(isCustomer);
  }
}