import 'package:proxpress/services/auth.dart';
class Customer{
  final String uid;
  final String fName;
  final String lName;
  final String email;
  final String contactNo;
  final String password;
  final String address;

  final AuthService _auth = AuthService();

  Customer({this.uid, this.fName, this.lName, this.email, this.contactNo, this.password, this.address,});

  Future<bool> validateCurrentPassword(String password) async {
    return await _auth.validateCustomerPassword(password);
  }
  void updateCurrentPassword(String password){
    _auth.updateCustomerPassword(password);
  }
  void updateCurrentEmail(String email){
    _auth.updateCustomerEmail(email);
  }
}