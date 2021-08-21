import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:proxpress/models/customers.dart';

class DatabaseService {

  final String uid;
  DatabaseService( {this.uid});

  // Customer Collection Reference
  final CollectionReference customerCollection = FirebaseFirestore.instance.collection('Customers');

  Future updateCustomerData(String fname, String lname, String email, String contactNo, String password, String address) async {
    return await customerCollection.doc(uid).set({
      'First Name': fname,
      'Last Name' : lname,
      'Contact No' : contactNo,
      'Password' : password,
      'Email' : email,
      'Address' : address,
    });
  }

  // Customer model
  List<Customer> _customerListFromSnapshot(QuerySnapshot snapshot){
    return snapshot.docs.map((doc){
     return Customer(
       fName: doc.get('fname') ?? '',
       lName: doc.get('lName') ?? '',
       contactNo: doc.get('contactNo') ?? '',
       password: doc.get('password') ?? '',
       email: doc.get('email') ?? '',
       address: doc.get('address') ?? '',

     );
    }).toList();
  }
  // Get data from the database collection customer
  Stream<List<Customer>> get Customers {
    return customerCollection.snapshots().map(_customerListFromSnapshot);
  }
}