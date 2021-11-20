import 'package:firebase_auth/firebase_auth.dart';
import 'package:proxpress/models/user.dart';
import 'package:proxpress/services/database.dart';
import 'package:proxpress/services/file_storage.dart';
import 'package:proxpress/models/customers.dart';

class AuthService {

  Customer customer;
  FileStorage customerStorage = FileStorage();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future ResetPassword(String email) async {
    return _auth.sendPasswordResetEmail(email: email);
  }

  // Sign in email and password
  Future SignInCustomer(String email, String password) async {
    try {
      String temp = "";
      temp = email[0] + email[1];

      UserCredential result ;
      if(temp == "09"){
        String contactNo = "+63" + email.substring(1);
        ConfirmationResult confirmationResult = await _auth.signInWithPhoneNumber(contactNo, RecaptchaVerifier(
          container: 'recaptcha',
          size: RecaptchaVerifierSize.compact,
          theme: RecaptchaVerifierTheme.dark,
        ));

      } else{
        result = await _auth.signInWithEmailAndPassword(
        email: email, password: password);
      }

      User user = result.user;
      await DatabaseService(uid: user.uid).AuthupdateCustomerPassword(password);
      await DatabaseService(uid: user.uid).AuthupdateCourierPassword(password);
      return _userFromFirebaseUser(user);
    } catch (e) {
      return null;
    }
  }

  // Creates user obj based on FirebaseUser
  TheUser _userFromFirebaseUser(User user) {
    return user != null ? TheUser(uid: user.uid) : null;
  }

  Stream<TheUser> get user {
    return _auth.authStateChanges().map(_userFromFirebaseUser);
  }

  // Sign Up email and password for Customer
  Future SignUpCustomer(String email, String password, String Fname,
      String Lname, String ContactNo, String Address,
      String avatarUrl, bool notifStatus, int currentNotif,
      Map courier_ref, int wallet) async {
    try {
      // AuthResult before
      UserCredential result = await _auth.createUserWithEmailAndPassword(
          email: email, password: password);

      // FirebaseUser before
      User user = result.user;
      //await FileStorage(uid: user.uid);
      await DatabaseService(uid: user.uid).updateCustomerData(
          Fname,
          Lname,
          email,
          ContactNo,
          password,
          Address,
          avatarUrl,
          notifStatus,
          currentNotif,
          courier_ref,
          wallet);
      return _userFromFirebaseUser(user);
    } catch (e) {
      return null;
    }
  }

  // Sign Up email and password for Customer
  Future SignUpCustomerPhone(String email, String password, String Fname,
      String Lname, String ContactNo, String Address,
      String avatarUrl, bool notifStatus, int currentNotif,
      Map courier_ref, int wallet) async {
    try {
      // AuthResult before
      UserCredential result = await _auth.createUserWithEmailAndPassword(
          email: email, password: password);
      // FirebaseUser before
      User user = result.user;
      //await FileStorage(uid: user.uid);
      await DatabaseService(uid: user.uid).updateCustomerData(
          Fname,
          Lname,
          email,
          ContactNo,
          password,
          Address,
          avatarUrl,
          notifStatus,
          currentNotif,
          courier_ref,
          wallet);
      return _userFromFirebaseUser(user);
    } catch (e) {
      return null;
    }
  }

  // Sign Up email and password for Courier
  Future SignUpCourier(String email, String password, String Fname,
      String Lname, String ContactNo, String Address, String Status,
      String avatarUrl, bool approved, String vehicleType,
      int vehicleColor, String driversLicenseFront_,
      String driversLicenseBack_, String nbiClearancePhoto_,
      vehicleRegistrationOR_, vehicleRegistrationCR_, vehiclePhoto_,
      deliveryPriceRef, notifStatus, currentNotif, notifPopStatus,
      notifPopCounter, String adminMessage,
      List adminCredentialsResponse, int wallet, bool requestedCashout) async {
    try {
      // AuthResult before
      UserCredential result = await _auth.createUserWithEmailAndPassword(
          email: email, password: password);
      // FirebaseUser before
      User user = result.user;
      //await FileStorage(uid: user.uid);
      await DatabaseService(uid: user.uid).updateCourierData(
          Fname,
          Lname,
          email,
          ContactNo,
          password,
          Address,
          Status,
          avatarUrl,
          approved,
          vehicleType,
          vehicleColor,
          driversLicenseFront_,
          driversLicenseBack_,
          nbiClearancePhoto_,
          vehicleRegistrationOR_,
          vehicleRegistrationCR_,
          vehiclePhoto_,
          deliveryPriceRef,
          notifStatus,
          currentNotif,
          notifPopStatus,
          notifPopCounter,
          adminMessage,
          adminCredentialsResponse,
          wallet,
          requestedCashout
      );
      return _userFromFirebaseUser(user);
    } catch (e) {
      return null;
    }
  }

  // Sign Out
  Future signOut() async {
    try {
      return await _auth.signOut();
    } catch (e) {
      return null;
    }
  }

  //validates the password of the customer
  Future<bool> validateCustomerPassword(String password) async {
    var firebaseUser = await _auth.currentUser;

    var authCredentials = EmailAuthProvider.credential(
        email: firebaseUser.email, password: password);
    try {
      var authResult = await firebaseUser
          .reauthenticateWithCredential(authCredentials);
      return authResult.user != null;
    } catch (e) {
      return false;
    }
  }

  Future<bool> validateCustomerEmail(String password) async {
    var firebaseUser = await _auth.currentUser;

    var authCredentials = EmailAuthProvider.credential(
        email: firebaseUser.email, password: password);
    try {
      var authResult = await firebaseUser
          .reauthenticateWithCredential(authCredentials);
      return authResult.user != null;
    } catch (e) {
      return false;
    }
  }

  //validates the password of the courier
  Future<bool> validateCourierPassword(String password) async {
    var firebaseUser = await _auth.currentUser;

    var authCredentials = EmailAuthProvider.credential(
        email: firebaseUser.email, password: password);
    try {
      var authResult = await firebaseUser
          .reauthenticateWithCredential(authCredentials);
      return authResult.user != null;
    } catch (e) {
      return false;
    }
  }

  //updates the password of the customer
  Future<void> updateCustomerPassword(String password) async {
    var firebaseUser = await _auth.currentUser;
    firebaseUser.updatePassword(password);
  }

  //updates the password of the courier
  Future<void> updateCourierPassword(String password) async {
    var firebaseUser = await _auth.currentUser;
    firebaseUser.updatePassword(password);
  }

  //updates the email of the customer
  Future<void> updateCustomerEmail(String email) async {
    var message;
    var firebaseUser = await _auth.currentUser;
    firebaseUser.updateEmail(email).then(
          (value) => message = 'Success',
    ).catchError((onError) => message = 'error');
  }

  //updates the email of the courier
  Future<void> updateCourierEmail(String email) async {
    var message;
    var firebaseUser = await _auth.currentUser;
    firebaseUser.updateEmail(email).then(
          (value) => message = 'Success',
    ).catchError((onError) => message = 'error');
  }

}

