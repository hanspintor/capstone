import 'package:firebase_auth/firebase_auth.dart';
import 'package:proxpress/services/auth.dart';

class Customer{
  final String uid;
  final String fName;
  final String lName;
  final String email;
  final String contactNo;
  final String password;
  final String address;
  final String avatarUrl;
  final int wallet;
  final AuthService _auth = AuthService();

  Customer({this.uid, this.fName, this.lName, this.email,
    this.contactNo, this.password, this.address, this.avatarUrl,
    this.wallet});

  Future<bool> validateCurrentPassword(String password) async {
    return await _auth.validateCustomerPassword(password);
  }
  void updateCurrentPassword(String password) {
    _auth.updateCustomerPassword(password);
  }
  Future<bool> validateCurrentEmail(String email) async {
    return await _auth.validateCustomerEmail(email);
  }
  void updateCurrentEmail(String email) {
    _auth.updateCustomerEmail(email);
  }

  void updateContactNo(PhoneAuthCredential contact) {
    _auth.updateContactNo(contact);
  }
}