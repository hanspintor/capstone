import 'package:firebase_auth/firebase_auth.dart';
import 'package:proxpress/models/user.dart';

class AuthService {

  final FirebaseAuth _auth = FirebaseAuth.instance;


  // Sign in email and password
  Future SignInCustomer(String email, String password) async {
    try{
      // AuthResult before
      UserCredential result = await _auth.signInWithEmailAndPassword(email: email, password: password);
      // FirebaseUser before
      User user = result.user;
      return _userFromFirebaseUser(user);
    }catch(e){
      print(e.toString());
      return null;
    }
  }
  // Creates user obj based on FirebaseUser
  TheUser _userFromFirebaseUser(User user){
    return user != null ? TheUser(uid: user.uid) : null;
  }

  // Sign Up email and password
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

  // Sign Out
  Future signOut() async {
    try{
      return await _auth.signOut();
    } catch (e){
      print(e.toString());
      return null;
    }
  }
}