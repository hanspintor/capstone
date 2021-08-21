import 'package:cloud_firestore/cloud_firestore.dart';


class DatabaseService {

  final String uid;
  DatabaseService( {this.uid});

  // collection reference
  final CollectionReference customerCollection = FirebaseFirestore.instance.collection('Customers');

  Future updateCustomerData(String Fname, String Lname, String email, String ContactNo, String Password, String Address) async {
    return await customerCollection.doc(uid).set({
      'First Name': Fname,
      'Last Name' : Lname,
      'Contact No' : ContactNo,
      'Password' : Password,
      'Email' : email,
      'Address' : Address,
    });
  }
}