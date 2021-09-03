import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:proxpress/models/customers.dart';
import 'package:proxpress/models/couriers.dart';

class DatabaseService {

  final String uid;
  DatabaseService( {this.uid});

  // Customer Collection Reference
  final CollectionReference customerCollection = FirebaseFirestore.instance.collection('Customers');
  final CollectionReference courierCollection = FirebaseFirestore.instance.collection('Couriers');

  // Creation of a collection reference for customer data
  Future updateCustomerData(String fname, String lname, String email, String contactNo, String password, String address, String avatarUrl) async {
    return await customerCollection.doc(uid).set({
      'First Name': fname,
      'Last Name' : lname,
      'Email' : email,
      'Contact No' : contactNo,
      'Password' : password,
      'Address' : address,
      'Avatar URL' : avatarUrl,
    });
  }
  Future updateCustomerProfilePic(String avatarUrl) async {
    await FirebaseFirestore.instance.collection('Customers')
        .doc(uid)
        .update({
      'Avatar URL': avatarUrl,
    });
  }

  Future uploadCourierCredentials(String driversLicenseFront_, String driversLicenseBack_, String nbiClearancePhoto_, String vehicleRegistrationOR_, String vehicleRegistrationCR_, String vehiclePhoto_) async {
    await FirebaseFirestore.instance.collection('Courier')
        .doc(uid)
        .update({
      'Driver\'s License Front' : driversLicenseFront_,
      'Driver\'s License Back' : driversLicenseFront_,
      'NBI Clearance Photo' : nbiClearancePhoto_,
      'Vehicle Registration OR' : vehicleRegistrationOR_,
      'Vehicle Registration CR' : vehicleRegistrationCR_,
      'Vehicle Photo' : vehiclePhoto_,
    });
  }

  // Creation of collection reference for courier data
  Future updateCourierData(String fname, String lname, String email, String contactNo, String password, String address, String status, bool approved, String vehicleType, String vehicleColor, String driversLicenseFront_, String driversLicenseBack_, String nbiClearancePhoto_, String vehicleRegistrationOR_, String vehicleRegistrationCR_, String vehiclePhoto_) async {
    return await courierCollection.doc(uid).set({
      'First Name': fname,
      'Last Name' : lname,
      'Email' : email,
      'Contact No' : contactNo,
      'Password' : password,
      'Address' : address,
      'Active Status' : status,
      'Admin Approved': approved,
      'Vehicle Type': vehicleType,
      'Vehicle Color': vehicleColor,
      'License Front URL': driversLicenseFront_,
      'License Back URL': driversLicenseBack_,
      'NBI Clearance URL': nbiClearancePhoto_,
      'Vehicle OR URL': vehicleRegistrationOR_,
      'Vehicle CR URL': vehicleRegistrationCR_,
      'Vehicle Photo URL': vehiclePhoto_,
    });
  }

  Future updateCourierCredentials(String driversLicenseFront_, String driversLicenseBack_, String nbiClearancePhoto_, String vehicleRegistrationOR_, String vehicleRegistrationCR_, String vehiclePhoto_) async {
    await FirebaseFirestore.instance.collection('Couriers')
        .doc(uid)
        .update({
      'License Front URL': driversLicenseFront_,
      'License Back URL': driversLicenseBack_,
      'NBI Clearance URL': nbiClearancePhoto_,
      'Vehicle OR URL': vehicleRegistrationOR_,
      'Vehicle CR URL': vehicleRegistrationCR_,
      'Vehicle Photo URL': vehiclePhoto_,
    });
  }

  Future updateStatus(String status) async {
    return await courierCollection.doc(uid).update({
      'Active Status' : status,
    });
  }
  Future<void> AuthupdateCustomerPassword(String password) {
    return customerCollection
        .doc(uid)
        .update({'Password': password})
        .then((value) => print("User Updated"))
        .catchError((error) => print("Failed to update user: $error"));
  }
  Future<void> AuthupdateCourierPassword(String password) {
    return courierCollection
        .doc(uid)
        .update({'Password': password})
        .then((value) => print("User Updated"))
        .catchError((error) => print("Failed to update user: $error"));
  }

  //Customer model list builder
  List<Courier> _courierDataListFromSnapshot(QuerySnapshot snapshot){
    return snapshot.docs.map((doc){
     return Courier(
       fName: (doc.data() as dynamic) ['First Name'] ?? '',
       lName: (doc.data() as dynamic) ['Last Name'] ?? '',
       contactNo: (doc.data() as dynamic) ['Contact No'] ?? '',
       password: (doc.data() as dynamic) ['Password'] ?? '',
       email: (doc.data() as dynamic) ['Email'] ?? '',
       address: (doc.data() as dynamic) ['Address']?? '',
       status: (doc.data() as dynamic) ['Active Status']?? '',
       vehicleColor: (doc.data() as dynamic) ['Vehicle Color']?? '',
       vehicleType: (doc.data() as dynamic) ['Vehicle Type']?? '',


     );
    }).toList();
  }

  List<Customer> _customerDataListFromSnapshot(QuerySnapshot snapshot){
    return snapshot.docs.map((doc){
      return Customer(
        fName: (doc.data() as dynamic) ['First Name'] ?? '',
        lName: (doc.data() as dynamic) ['Last Name'] ?? '',
        contactNo: (doc.data() as dynamic) ['Contact No'] ?? '',
        password: (doc.data() as dynamic) ['Password'] ?? '',
        email: (doc.data() as dynamic) ['Email'] ?? '',
        address: (doc.data() as dynamic) ['Address']?? '',
        avatarUrl: (doc.data() as dynamic) ['Avatar URL']?? '',
      );
    }).toList();
  }
  // Get data from the database collection customer
  Stream<List<Customer>> get customerList {
    return customerCollection.snapshots().map(_customerDataListFromSnapshot);
  }

  Stream<List<Courier>> get courierList {
    return courierCollection.snapshots().map(_courierDataListFromSnapshot);
  }
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
      avatarUrl: snapshot['Avatar URL'],
    );
  }
// specific data
  Courier _courierDataFromSnapshot(DocumentSnapshot snapshot){
    return Courier(
      uid: uid,
      fName: snapshot['First Name'],
      lName: snapshot['Last Name'],
      contactNo: snapshot['Contact No'],
      password: snapshot['Password'],
      email: snapshot['Email'],
      address: snapshot['Address'],
      status: snapshot['Active Status'],
      //vehicleType: snapshot['Vehicle Type'],
      vehicleColor: snapshot['Vehicle Color'],
    );
  }

  Stream<Customer> get customerData{
    return customerCollection.doc(uid).snapshots().map(_customerDataFromSnapshot);
  }
  Stream<Courier> get courierData{
    return courierCollection.doc(uid).snapshots().map(_courierDataFromSnapshot);
  }


}