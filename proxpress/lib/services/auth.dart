import 'package:firebase_auth/firebase_auth.dart';
import 'package:proxpress/models/user.dart';

class AuthService {

  final FirebaseAuth _auth = FirebaseAuth.instance;

  TheUser _userFromFirebaseUser(User user){
    return user != null ? TheUser(uid: user.uid) : null;
  }
  Future SignUpCustomer(String email, String password) async {
    try{
      // AuthResult before
      UserCredential result = await _auth.createUserWithEmailAndPassword(email: email, password: password);
      // FirebaseUser before
      User user = result.user;
      return _userFromFirebaseUser(user);
    }catch(e){
      print(e.toString());
      return null;
    }
  }


}