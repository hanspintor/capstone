import 'package:firebase_auth/firebase_auth.dart';
import 'package:proxpress/database.dart';
import 'package:proxpress/user.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  TheUser _userFromFirebaseUser(User user){
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
    catch(e){
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

  Future deleteUser(String email, String password, String passwordAdmin) async {
    try {
      // save admin credentials for re-authentication later
      final User admin = _auth.currentUser;
      String adminEmail = admin.email;
      String adminPassword = passwordAdmin;

      print('admin to sign out: ${admin.uid} $adminEmail');
      await _auth.signOut();
      print('admin to signed out');

      // sign in the courier to be deleted
      dynamic resultSignIn = await SignIn(email, password);

      if (resultSignIn != null) {
        final User courier = _auth.currentUser;
        print('courier to be deleted: ${courier.uid} ${courier.email}');

        AuthCredential credentials = EmailAuthProvider.credential(email: email, password: password);
        UserCredential result = await courier.reauthenticateWithCredential(credentials);
        await DatabaseService(uid: result.user.uid).deleteCourierDocument(); // delete the courier document
        print('user data deleted from database');
        await result.user.delete(); // delete the courier from auth
        print('user deleted from auth');
        await _auth.signOut();

        await SignIn(adminEmail, adminPassword); // authenticate the admin again

        return true;
      }
    } catch (e) {
      print(e.toString());
      return null;
    }
  }
}