import 'package:proxpress/services/auth.dart';

class Courier{
  final String uid;
  final String fName;
  final String lName;
  final String email;
  final String contactNo;
  final String password;
  final String address;
  final String status;
  final bool approved;
  final String vehicleType;
  final String vehicleColor;
  // File file;

  final AuthService _auth = AuthService();

  Courier({this.uid, this.fName, this.lName, this.email, this.contactNo, this.password, this.address, this.status, this.approved, this.vehicleType, this.vehicleColor});

  Future<bool> validateCurrentPassword(String password) async {
    return await _auth.validateCourierPassword(password);
  }
  void updateCurrentPassword(String password){
    _auth.updateCourierPassword(password);
  }
  void updateCurrentEmail(String email){
    _auth.updateCourierEmail(email);
  }

}