import 'package:proxpress/services/auth.dart';

class Courier{
  final String uid;
  final String fName;
  final String lName;
  final String email;
  final String contactNo;
  final String password;
  final String address;
  // File file;

  final AuthService _auth = AuthService();

  Courier({this.uid, this.fName, this.lName, this.email, this.contactNo, this.password, this.address,});

  Future<bool> validateCurrentPassword(String password) async {
    return await _auth.validateCourierPassword(password);
  }
  void updateCurrentPassword(String password){
    _auth.updateCourierPassword(password);
  }
  void updateCurrentEmail(String email){
    _auth.updateCourierEmail(email);
  }

  // Future uploadFile() async {
  //   final fileName = Path.basename(file.path);
  //   final destination = 'Courier Credentials/$fileName';
  //
  //   UploadFile.uploadFile(destination, file);
  // }
}