import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:proxpress/models/customers.dart';
import 'package:proxpress/models/couriers.dart';
import 'package:proxpress/models/deliveries.dart';
import 'package:proxpress/models/delivery_prices.dart';

class DatabaseService {
  final String uid;
  DatabaseService( {this.uid});

  // Customers Collection Reference
  final CollectionReference customerCollection = FirebaseFirestore.instance.collection('Customers');

  // Couriers Collection Reference
  final CollectionReference courierCollection = FirebaseFirestore.instance.collection('Couriers');

  // Deliveries Collection Reference
  final CollectionReference deliveryCollection = FirebaseFirestore.instance.collection('Deliveries');

  // Delivery Price Collection Reference
  final CollectionReference deliveryPriceCollection = FirebaseFirestore.instance.collection('Delivery Prices');


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
    await customerCollection
        .doc(uid)
        .update({
      'Avatar URL': avatarUrl,
    });
  }

  Future updateCourierProfilePic(String avatarUrl) async {
    await courierCollection
        .doc(uid)
        .update({
      'Avatar URL' : avatarUrl,
    });
  }

  // Create/Update a Courier Document
  Future updateCourierData(String fname, String lname, String email, String contactNo, String password, String address, String status, String avatarUrl, bool approved, String vehicleType, String vehicleColor, String driversLicenseFront_, String driversLicenseBack_, String nbiClearancePhoto_, String vehicleRegistrationOR_, String vehicleRegistrationCR_, String vehiclePhoto_, DocumentReference deliveryPriceRef, bool notifStatus, int currentNotif) async {
    return await courierCollection.doc(uid).set({
      'First Name': fname,
      'Last Name' : lname,
      'Email' : email,
      'Contact No' : contactNo,
      'Password' : password,
      'Address' : address,
      'Active Status' : status,
      'Avatar URL' : avatarUrl,
      'Admin Approved': approved,
      'Vehicle Type': vehicleType,
      'Vehicle Color': vehicleColor,
      'License Front URL': driversLicenseFront_,
      'License Back URL': driversLicenseBack_,
      'NBI Clearance URL': nbiClearancePhoto_,
      'Vehicle OR URL': vehicleRegistrationOR_,
      'Vehicle CR URL': vehicleRegistrationCR_,
      'Vehicle Photo URL': vehiclePhoto_,
      'Delivery Price Reference': deliveryPriceRef,
      'Notification Status' : notifStatus,
      'Current Notification' : currentNotif,
    });
  }

  // Together with Courier Creation, Update Credentials URL
  Future updateCourierCredentials(String driversLicenseFront_, String driversLicenseBack_, String nbiClearancePhoto_, String vehicleRegistrationOR_, String vehicleRegistrationCR_, String vehiclePhoto_) async {
    await courierCollection
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
  // Update delivery approval
  Future updateApproval(String courierApproval) async {
    return await deliveryCollection.doc(uid).update({
      'Courier Approval' : courierApproval,
    });
  }
  // Update Delivery Status
  Future updateDeliveryStatus(String status) async {
    return await courierCollection.doc(uid).update({
      'Delivery Status' : status,
    });
  }
  Future updateNotifCounter(int notifC) async {
    return await courierCollection.doc(uid).update({
      'Current Notification': notifC,
    });
  }
  Future updateNotifStatus(bool viewable) async {
    return await courierCollection.doc(uid).update({
      'Notification Status': viewable,
    });
  }
  // Create Delivery Document
  Future updateDelivery(DocumentReference customer, DocumentReference courier,
      String pickupAddress, GeoPoint pickupCoordinates, String dropOffAddress,
      GeoPoint dropOffCoordinates, String itemDescription, String senderName,
      String senderContactNum, String receiverName, String receiverContactNum,
      String whoWillPay, String specificInstructions, String paymentOption,
      int deliveryFee, String courierApproval, String deliveryStatus) async {
    await deliveryCollection
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
        avatarUrl: (doc.data() as dynamic) ['Avatar URL']?? '',
        vehicleColor: (doc.data() as dynamic) ['Vehicle Color'] ?? '',
        vehicleType: (doc.data() as dynamic) ['Vehicle Type'] ?? '',
        deliveryPriceRef: (doc.data() as dynamic) ['Delivery Price Reference'] ?? '',
        vehiclePhoto_: (doc.data() as dynamic) ['Vehicle Photo URL'] ?? '',
        notifStatus: (doc.data() as dynamic) ['Notification Status'] ?? '',
        currentNotif: (doc.data() as dynamic) ['Current Notification'] ?? '',
      );
    }).toList();
  }

  // Delivery Model List Builder
  List<Delivery> deliveryDataListFromSnapshot(QuerySnapshot snapshot){
    return snapshot.docs.map((doc){
      return Delivery(
        uid: doc.id,
        customerRef: (doc.data() as dynamic) ['Customer Reference'] ?? '',
        courierRef: (doc.data() as dynamic) ['Courier Reference'] ?? '',
        pickupAddress: (doc.data() as dynamic) ['Pickup Address'] ?? '',
        pickupCoordinates: (doc.data() as dynamic) ['Pickup Coordinates'] ?? '',
        dropOffAddress: (doc.data() as dynamic) ['DropOff Address'] ?? '',
        dropOffCoordinates: (doc.data() as dynamic) ['DropOff Coordinates'] ?? '',
        itemDescription: (doc.data() as dynamic) ['Item Description'] ?? '',
        pickupPointPerson: (doc.data() as dynamic) ['Sender Name'] ?? '',
        pickupContactNum: (doc.data() as dynamic) ['Sender Contact Number'] ?? '',
        dropoffPointPerson: (doc.data() as dynamic) ['Receiver Name'] ?? '',
        dropoffContactNum: (doc.data() as dynamic) ['Receiver Contact Number'] ?? '',
        whoWillPay: (doc.data() as dynamic) ['Who Will Pay'] ?? '',
        specificInstructions: (doc.data() as dynamic) ['Specific Instructions'] ?? '',
        paymentOption: (doc.data() as dynamic) ['Payment Option'] ?? '',
        deliveryFee: (doc.data() as dynamic) ['Delivery Fee'] ?? '',
        courierApproval: (doc.data() as dynamic) ['Courier Approval'] ?? '',
        deliveryStatus: (doc.data() as dynamic) ['Delivery Status'] ?? '',
      );
    }).toList();
  }

  // Delivery Model List Builder
  List<DeliveryPrice> deliveryPriceDataListFromSnapshot(QuerySnapshot snapshot){
    return snapshot.docs.map((doc){
      return DeliveryPrice(
        uid: doc.id,
        vehicleType: (doc.data() as dynamic) ['Vehicle Type'] ?? '',
        baseFare: (doc.data() as dynamic) ['Base Fare'] ?? '',
        farePerKM: (doc.data() as dynamic) ['Fare Per KM'] ?? '',
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
    return deliveryCollection.snapshots().map(deliveryDataListFromSnapshot);
  }

  // Get list of data from Customers Collection
  Stream<List<DeliveryPrice>> get deliveryPriceList {
    return deliveryPriceCollection.snapshots().map(deliveryPriceDataListFromSnapshot);
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
      avatarUrl: snapshot['Avatar URL'],
      vehicleType: snapshot['Vehicle Type'],
      vehicleColor: snapshot['Vehicle Color'],
      driversLicenseFront_: snapshot['License Front URL'],
      driversLicenseBack_: snapshot['License Back URL'],
      nbiClearancePhoto_: snapshot['NBI Clearance URL'],
      vehicleRegistrationOR_: snapshot['Vehicle OR URL'],
      vehicleRegistrationCR_: snapshot['Vehicle CR URL'],
      vehiclePhoto_: snapshot['Vehicle Photo URL'],
      deliveryPriceRef: snapshot['Delivery Price Reference'],
      notifStatus: snapshot['Notification Status'],
      currentNotif: snapshot['Current Notification']
    );
  }

  // Get Delivery Document Data using StreamBuilder
  Delivery _deliveryDataFromSnapshot(DocumentSnapshot snapshot){
    return Delivery(
      uid: uid,
      customerRef: snapshot['Customer Reference'],
      courierRef: snapshot['Courier Reference'],
      pickupAddress: snapshot['Pickup Address'],
      pickupCoordinates: snapshot['Pickup Coordinates'],
      dropOffAddress: snapshot['DropOff Address'],
      dropOffCoordinates: snapshot['DropOff Coordinates'],
      itemDescription: snapshot['Item Description'],
      pickupPointPerson: snapshot['Sender Name'],
      pickupContactNum: snapshot['Sender Contact Number'],
      dropoffPointPerson: snapshot['Receiver Name'],
      dropoffContactNum: snapshot['Receiver Contact Number'],
      whoWillPay: snapshot['Who Will Pay'],
      specificInstructions: snapshot['Specific Instructions'],
      paymentOption: snapshot['Payment Option'],
      deliveryFee: snapshot['Delivery Fee'],
      courierApproval: snapshot['Courier Approval'],
      deliveryStatus: snapshot['Delivery Status'],
    );
  }

  // Get Delivery Document Data using StreamBuilder
  DeliveryPrice _deliveryPriceDataFromSnapshot(DocumentSnapshot snapshot){
    return DeliveryPrice(
      uid: uid,
      vehicleType: snapshot['Vehicle Type'],
      baseFare: snapshot['Base Fare'],
      farePerKM: snapshot['Fare Per KM']
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
    return deliveryCollection.doc(uid).snapshots().map(_deliveryDataFromSnapshot);
  }

  // Get Delivery Price Document Data
  Stream<DeliveryPrice> get deliveryPriceData{
    return deliveryPriceCollection.doc(uid).snapshots().map(_deliveryPriceDataFromSnapshot);
  }
}