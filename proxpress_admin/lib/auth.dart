import 'package:firebase_auth/firebase_auth.dart';
import 'package:proxpress/user.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  TheUser _userFromFirebaseUser(User user) {
    return user != null ? TheUser(uid: user.uid) : null;
  }
  Stream<TheUser> get user {
    return _auth.authStateChanges().map(_userFromFirebaseUser);
  }

  Future SignIn(String email, String password) async {
    try{
      UserCredential result = await _auth.signInWithEmailAndPassword(email: email, password: password);
      User user = result.user;
      print(user.uid);
      return _userFromFirebaseUser(user);
    }
    catch(e) {
      print(e.toString());
      return null;
    }
  }

  // Sign Out
  Future signOut() async {
    try{
      return await _auth.signOut();
    } catch (e) {
      print(e.toString());
      return null;
    }
  }
}