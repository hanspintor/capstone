import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:proxpress/models/customers.dart';
import 'package:proxpress/models/couriers.dart';
import 'package:proxpress/models/delivery.dart';

class DatabaseService {
  final String uid;
  DatabaseService( {this.uid});

  // Customers Collection Reference
  final CollectionReference customerCollection = FirebaseFirestore.instance.collection('Customers');

  // Couriers Collection Reference
  final CollectionReference courierCollection = FirebaseFirestore.instance.collection('Couriers');

  // Deliveries Collection Reference
  final CollectionReference deliveryCollection = FirebaseFirestore.instance.collection('Deliveries');

  // Create/Update a Customer Document
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

  // Update Customer Password in Auth
  Future<void> AuthupdateCustomerPassword(String password) {
    return customerCollection
        .doc(uid)
        .update({'Password': password})
        .then((value) => print("User Updated"))
        .catchError((error) => print("Failed to update user: $error"));
  }

  // Update Customer Profile Picture
  Future updateCustomerProfilePic(String avatarUrl) async {
    await FirebaseFirestore.instance.collection('Customers')
        .doc(uid)
        .update({
      'Avatar URL': avatarUrl,
    });
  }

  // Create/Update a Courier Document
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

  // Together with Courier Creation, Update Credentials URL
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

  // Update Courier Password in Auth
  Future<void> AuthupdateCourierPassword(String password) {
    return courierCollection
        .doc(uid)
        .update({'Password': password})
        .then((value) => print("User Updated"))
        .catchError((error) => print("Failed to update user: $error"));
  }

  // Update Courier Status
  Future updateStatus(String status) async {
    return await courierCollection.doc(uid).update({
      'Active Status' : status,
    });
  }

  // Create Delivery Document
  Future updateDelivery(DocumentReference customer, DocumentReference courier,
      String pickupAddress, GeoPoint pickupCoordinates, String dropOffAddress,
      GeoPoint dropOffCoordinates, String itemDescription, String senderName,
      String senderContactNum, String receiverName, String receiverContactNum,
      String whoWillPay, String specificInstructions, String paymentOption,
      double deliveryFee, String courierApproval, String deliveryStatus) async {
    await FirebaseFirestore.instance.collection('Deliveries')
        .doc(uid)
        .set({
      'Customer Reference' : customer,
      'Courier Reference' : courier,
      'Pickup Address' : pickupAddress,
      'Pickup Coordinates' : pickupCoordinates,
      'DropOff Address' : dropOffAddress,
      'DropOff Coordinates' : dropOffCoordinates,
      'Item Description' : itemDescription,
      'Sender Name': senderName,
      'Sender Contact Number' : senderContactNum,
      'Receiver Name' : receiverName,
      'Receiver Contact Number' : receiverContactNum,
      'Who Will Pay' : whoWillPay,
      'Specific Instructions' : specificInstructions,
      'Payment Option' : paymentOption,
      'Delivery Fee' : deliveryFee,
      'Courier Approval' : courierApproval,
      'Delivery Status' : deliveryStatus,
    });
  }

  // Customer Model List Builder
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

  // Courier Model List Builder
  List<Courier> courierDataListFromSnapshot(QuerySnapshot snapshot){
    return snapshot.docs.map((doc){
      return Courier(
        uid: doc.id,
        fName: (doc.data() as dynamic) ['First Name'] ?? '',
        lName: (doc.data() as dynamic) ['Last Name'] ?? '',
        contactNo: (doc.data() as dynamic) ['Contact No'] ?? '',
        password: (doc.data() as dynamic) ['Password'] ?? '',
        email: (doc.data() as dynamic) ['Email'] ?? '',
        address: (doc.data() as dynamic) ['Address'] ?? '',
        status: (doc.data() as dynamic) ['Active Status'] ?? '',
        vehicleColor: (doc.data() as dynamic) ['Vehicle Color'] ?? '',
        vehicleType: (doc.data() as dynamic) ['Vehicle Type'] ?? '',
      );
    }).toList();
  }

  // Delivery Model List Builder
  List<Delivery> deliveryDataListFromSnapshot(QuerySnapshot snapshot){
    return snapshot.docs.map((doc){
      return Delivery(
        uid: doc.id,
        customer: (doc.data() as dynamic) ['Customer Reference'] ?? '',
        courier: (doc.data() as dynamic) ['Courier Reference'] ?? '',
        pickupAddress: (doc.data() as dynamic) ['Pickup Address'] ?? '',
        pickupCoordinates: (doc.data() as dynamic) ['Pickup Coordinates'] ?? '',
        dropOffAddress: (doc.data() as dynamic) ['DropOff Address'] ?? '',
        dropOffCoordinates: (doc.data() as dynamic) ['DropOff Coordinates'] ?? '',
        itemDescription: (doc.data() as dynamic) ['Item Description'] ?? '',
        senderName: (doc.data() as dynamic) ['Sender Name'] ?? '',
        senderContactNum: (doc.data() as dynamic) ['Sender Contact Number'] ?? '',
        receiverName: (doc.data() as dynamic) ['Receiver Name'] ?? '',
        receiverContactNum: (doc.data() as dynamic) ['Receiver Contact Number'] ?? '',
        whoWillPay: (doc.data() as dynamic) ['Who Will Pay'] ?? '',
        specificInstructions: (doc.data() as dynamic) ['Specific Instructions'] ?? '',
        paymentOption: (doc.data() as dynamic) ['Payment Option'] ?? '',
        deliveryFee: (doc.data() as dynamic) ['Delivery Fee'] ?? '',
        courierApproval: (doc.data() as dynamic) ['Courier Approval'] ?? '',
        deliveryStatus: (doc.data() as dynamic) ['Delivery Status'] ?? '',
      );
    }).toList();
  }

  // Get list of data from Customers Collection
  Stream<List<Customer>> get customerList {
    return customerCollection.snapshots().map(_customerDataListFromSnapshot);
  }

  // Get list of data from Couriers Collection
  Stream<List<Courier>> get courierList {
    return courierCollection.snapshots().map(courierDataListFromSnapshot);
  }

  // Get list of data from Deliveries Collection
  Stream<List<Delivery>> get deliveryList {
    return courierCollection.snapshots().map(deliveryDataListFromSnapshot);
  }

  // Get Customer Document Data using StreamBuilder
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

  // Get Courier Document Data using StreamBuilder
  Courier _courierDataFromSnapshot(DocumentSnapshot snapshot){
    return Courier(
      uid: uid,
      fName: snapshot['First Name'],
      lName: snapshot['Last Name'],
      contactNo: snapshot['Contact No'],
      password: snapshot['Password'],
      email: snapshot['Email'],
      address: snapshot['Address'],
      approved: snapshot['Admin Approved'],
      status: snapshot['Active Status'],
      vehicleType: snapshot['Vehicle Type'],
      vehicleColor: snapshot['Vehicle Color'],
    );
  }

  // Get Delivery Document Data using StreamBuilder
  Delivery _deliveryDataFromSnapshot(DocumentSnapshot snapshot){
    return Delivery(
      uid: uid,
      customer: snapshot['Customer Reference'],
      courier: snapshot['Courier Reference'],
      pickupAddress: snapshot['Pickup Address'],
      pickupCoordinates: snapshot['Pickup Coordinates'],
      dropOffAddress: snapshot['DropOff Address'],
      dropOffCoordinates: snapshot['DropOff Coordinates'],
      itemDescription: snapshot['Item Description'],
      senderName: snapshot['Sender Name'],
      senderContactNum: snapshot['Sender Contact Number'],
      receiverName: snapshot['Receiver Name'],
      receiverContactNum: snapshot['Receiver Contact Number'],
      whoWillPay: snapshot['Who Will Pay'],
      specificInstructions: snapshot['Specific Instructions'],
      paymentOption: snapshot['Payment Option'],
      deliveryFee: snapshot['Delivery Fee'],
      courierApproval: snapshot['Courier Approval'],
      deliveryStatus: snapshot['Delivery Status'],
    );
  }

  // Get Customer Document Data
  Stream<Customer> get customerData{
    return customerCollection.doc(uid).snapshots().map(_customerDataFromSnapshot);
  }

  // Get Courier Document Data
  Stream<Courier> get courierData{
    return courierCollection.doc(uid).snapshots().map(_courierDataFromSnapshot);
  }

  // Get Delivery Document Data
  Stream<Delivery> get deliveryData{
    return customerCollection.doc(uid).snapshots().map(_deliveryDataFromSnapshot);
  }
}