import 'package:cloud_firestore/cloud_firestore.dart';
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
  final String driversLicenseFront_;
  final String driversLicenseBack_;
  final String nbiClearancePhoto_;
  final String vehicleRegistrationOR_;
  final String vehicleRegistrationCR_;
  final String vehiclePhoto_;
  final DocumentReference deliveryPriceRef;

  final AuthService _auth = AuthService();

  Courier({this.uid, this.fName, this.lName, this.email, this.contactNo, this.password, this.address, this.status, this.approved, this.vehicleType, this.vehicleColor, this.driversLicenseFront_, this.driversLicenseBack_, this.nbiClearancePhoto_, this.vehicleRegistrationOR_, this.vehicleRegistrationCR_, this.vehiclePhoto_, this.deliveryPriceRef});

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