import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:proxpress/models/customers.dart';

class DatabaseService {

  final String uid;
  DatabaseService( {this.uid});

  // Customer Collection Reference
  final CollectionReference customerCollection = FirebaseFirestore.instance.collection('Customers');

  // Creation of a collection reference
  Future updateCustomerData(String fname, String lname, String email, String contactNo, String password, String address) async {
    return await customerCollection.doc(uid).set({
      'First Name': fname,
      'Last Name' : lname,
      'Email' : email,
      'Contact No' : contactNo,
      'Password' : password,
      'Address' : address,
    });
  }

  // Customer model
  // List<Customer> _customerListFromSnapshot(QuerySnapshot snapshot){
  //   return snapshot.docs.map((doc){
  //    return Customer(
  //      fName: (doc.data() as dynamic) ['fName'] ?? '',
  //      lName: (doc.data() as dynamic) ['lName'] ?? '',
  //      contactNo: (doc.data() as dynamic) ['contactNo'] ?? '',
  //      password: (doc.data() as dynamic) ['password'] ?? '',
  //      email: (doc.data() as dynamic) ['email'] ?? '',
  //      address: (doc.data() as dynamic) ['address']?? '',
  //
  //    );
  //   }).toList();
  // }
  // // Get data from the database collection customer
  // Stream<List<Customer>> get Customers {
  //   return customerCollection.snapshots().map(_customerListFromSnapshot);
  // }

  // Get data individually using streambuilder
  Customer _customerDataFromSnapshot(DocumentSnapshot snapshot){
    return Customer(
      uid: uid,
      fName: snapshot['First Name'],
      lName: snapshot['Last Name'],
      contactNo: snapshot['Contact No'],
      password: snapshot['Password'],
      email: snapshot['Email'],
      address: snapshot['Address'],
    );
  }

  Stream<Customer> get customerData{
    return customerCollection.doc(uid).snapshots().map(_customerDataFromSnapshot);
  }


}