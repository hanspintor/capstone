import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart';
import 'package:proxpress/models/user.dart';
import 'package:proxpress/services/database.dart';
import 'package:proxpress/services/file_storage.dart';
import 'package:proxpress/models/customers.dart';

class AuthService {

  Customer customer;
  FileStorage customerStorage = FileStorage();
  final FirebaseAuth _auth = FirebaseAuth.instance;


    Future ResetPassword(String email) async{
      return _auth.sendPasswordResetEmail(email: email);
    }

  // Sign in email and password
  Future SignInCustomer(String email, String password) async {
    try{
      // AuthResult before
      UserCredential result = await _auth.signInWithEmailAndPassword(email: email, password: password);
      // FirebaseUser before
      User user = result.user;
      //await FileStorage(uid: user.uid);
      await DatabaseService(uid: user.uid).AuthupdateCustomerPassword(password);
      await DatabaseService(uid: user.uid).AuthupdateCourierPassword(password);
      print(user.uid);
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
  Stream<TheUser> get user {
    return _auth.authStateChanges().map(_userFromFirebaseUser);
  }

  // Sign Up email and password for Customer
  Future SignUpCustomer(String email, String password, String Fname, String Lname, String ContactNo, String Address) async {
    try{
      // AuthResult before
      UserCredential result = await _auth.createUserWithEmailAndPassword(email: email, password: password);
      // FirebaseUser before
      User user = result.user;
      //await FileStorage(uid: user.uid);
      await DatabaseService(uid: user.uid).updateCustomerData(Fname, Lname, email, ContactNo, password, Address);
      return _userFromFirebaseUser(user);
    }catch(e){
      print(e.toString());
      return null;
    }
  }
  // Sign Up email and password for Courier
  Future SignUpCourier(String email, String password, String Fname, String Lname, String ContactNo, String Address) async {
    try{
      // AuthResult before
      UserCredential result = await _auth.createUserWithEmailAndPassword(email: email, password: password);
      // FirebaseUser before
      User user = result.user;
      await FileStorage(uid: user.uid);
      await DatabaseService(uid: user.uid).updateCourierData(Fname, Lname, email, ContactNo, password, Address);
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
  Future<bool> validateCustomerPassword(String password) async {
    var firebaseUser = await _auth.currentUser;

    var authCredentials = EmailAuthProvider.credential(email: firebaseUser.email, password: password);
    try {
      var authResult = await firebaseUser
          .reauthenticateWithCredential(authCredentials);
      return authResult.user != null;
    } catch (e) {
      print(e);
      return false;
    }
  }
  Future<void> updateCustomerPassword(String password) async {
    var firebaseUser = await _auth.currentUser;
    firebaseUser.updatePassword(password);
  }
  Future<void> updateCustomerEmail(String email) async {
    var firebaseUser = await _auth.currentUser;
    firebaseUser.updateEmail(email);
  }
  // Future<void> uploadProfilePicture(File image) async{
  //   customer.avatarUrl = await customerStorage.uploadFile(image);
  // }
}