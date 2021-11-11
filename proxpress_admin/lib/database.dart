import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:proxpress/couriers.dart';
import 'package:proxpress/delivery_prices.dart';
import 'package:proxpress/reports.dart';

import 'customers.dart';

class DatabaseService {
  final String uid;
  DatabaseService({this.uid});

  final CollectionReference customerCollection = FirebaseFirestore.instance
      .collection('Customers');
  final CollectionReference courierCollection = FirebaseFirestore.instance.collection('Couriers');
  final CollectionReference deliveryPriceCollection = FirebaseFirestore.instance.collection('Delivery Prices');

  // Report Collection Reference
  final CollectionReference reportCollection = FirebaseFirestore.instance
      .collection('Reports');

  List<Courier> _courierDataListFromSnapshot(QuerySnapshot snapshot){
    return snapshot.docs.map((doc){
      return Courier(
        uid: doc.id,
        fName: (doc.data() as dynamic) ['First Name'] ?? '',
        lName: (doc.data() as dynamic) ['Last Name'] ?? '',
        contactNo: (doc.data() as dynamic) ['Contact No'] ?? '',
        password: (doc.data() as dynamic) ['Password'] ?? '',
        email: (doc.data() as dynamic) ['Email'] ?? '',
        address: (doc.data() as dynamic) ['Address']?? '',
        vehicleType: (doc.data() as dynamic) ['Vehicle Type'] ?? '',
        vehicleColor: (doc.data() as dynamic) ['Vehicle Color'] ?? '',
        approved: (doc.data() as dynamic) ['Admin Approved'] ?? '',
        driversLicenseFront_: (doc.data() as dynamic) ['License Front URL'] ?? '',
        driversLicenseBack_: (doc.data() as dynamic) ['License Back URL'] ?? '',
        nbiClearancePhoto_: (doc.data() as dynamic) ['NBI Clearance URL'] ?? '',
        vehicleRegistrationOR_: (doc.data() as dynamic) ['Vehicle OR URL'] ?? '',
        vehicleRegistrationCR_: (doc.data() as dynamic) ['Vehicle CR URL'] ?? '',
        vehiclePhoto_: (doc.data() as dynamic) ['Vehicle Photo URL'] ?? '',
        adminMessage: (doc.data() as dynamic) ['Admin Message'] ?? '',
        adminCredentialsResponse : (doc.data() as dynamic) ['Credential Response'] ?? '',
      );
    }).toList();
  }
  // Get Courier Document Data using StreamBuilder
  Courier _courierDataFromSnapshot(DocumentSnapshot snapshot) {
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
      driversLicenseFront_: snapshot['License Front URL'],
      driversLicenseBack_: snapshot['License Back URL'],
      nbiClearancePhoto_: snapshot['NBI Clearance URL'],
      vehicleRegistrationOR_: snapshot['Vehicle OR URL'],
      vehicleRegistrationCR_: snapshot['Vehicle CR URL'],
      vehiclePhoto_: snapshot['Vehicle Photo URL'],
      adminMessage: snapshot['Admin Message'],
      adminCredentialsResponse: snapshot['Credential Response'],
    );
  }
  // Customer Model List Builder
  List<Customer> _customerDataListFromSnapshot(QuerySnapshot snapshot) {
    return snapshot.docs.map((doc) {
      return Customer(
          fName: (doc.data() as dynamic) ['First Name'] ?? '',
          lName: (doc.data() as dynamic) ['Last Name'] ?? '',
          contactNo: (doc.data() as dynamic) ['Contact No'] ?? '',
          password: (doc.data() as dynamic) ['Password'] ?? '',
          email: (doc.data() as dynamic) ['Email'] ?? '',
          address: (doc.data() as dynamic) ['Address'] ?? '',
          avatarUrl: (doc.data() as dynamic) ['Avatar URL'] ?? '',
          notifStatus: (doc.data() as dynamic) ['Notification Status'] ?? '',
          currentNotif: (doc.data() as dynamic) ['Current Notification'] ?? '',
          courier_ref: (doc.data() as dynamic) ['Courier_Ref'] ?? ''
      );
    }).toList();
  }
  List<Reports> _reportsDataListFromSnapshot(QuerySnapshot snapshot){
    return snapshot.docs.map((doc){
      return Reports(
        uid: doc.id,
        reportBy: (doc.data() as dynamic) ['Report By'] ?? '',
        reportTo: (doc.data() as dynamic) ['Report To'] ?? '',
        reportMessage: (doc.data() as dynamic) ['Report Message'] ?? '',
        time: (doc.data() as dynamic) ['Time Reported'] ?? '',

      );
    }).toList();
  }

  Reports reportsDataFromSnapshot(DocumentSnapshot snapshot) {
    return Reports(
      uid: uid,
      reportMessage: snapshot['Report Message'],
      time: snapshot['Time Reported'],
      reportBy: snapshot['Report By'],
      reportTo: snapshot['Report To'],
    );
  }
  Stream<Reports> get ReportsData {
    return reportCollection.doc(uid).snapshots().map(reportsDataFromSnapshot);
  }
  Stream<Customer> get customerData {
    return customerCollection.doc(uid).snapshots().map(
        _customerDataFromSnapshot);
  }
  Stream<Courier> get courierData {
    return courierCollection.doc(uid).snapshots().map(_courierDataFromSnapshot);
  }
  Stream<List<Courier>> get courierList {
    return courierCollection.snapshots().map(_courierDataListFromSnapshot);
  }
  Stream<List<Reports>> get reportList {
    return reportCollection.snapshots().map(_reportsDataListFromSnapshot);
  }
  Future approveCourier(bool approve) async {
    await FirebaseFirestore.instance.collection('Couriers')
        .doc(uid)
        .update({
      'Admin Approved': approve,
    });
  }
  Future updateCredentials(List adminCredentialsResponse) async {
    await FirebaseFirestore.instance.collection('Couriers')
        .doc(uid)
        .update({
      'Credential Response': adminCredentialsResponse,
    });
  }


  Future deleteCourierDocument() {
    return courierCollection.doc(uid).delete();
  }

  Future updateCourierMessage(String adminMessage) async {
    await courierCollection
        .doc(uid)
        .update({
      'Admin Message': adminMessage,
    });
  }

  Customer _customerDataFromSnapshot(DocumentSnapshot snapshot) {
    return Customer(
        uid: uid,
        fName: snapshot['First Name'],
        lName: snapshot['Last Name'],
        contactNo: snapshot['Contact No'],
        password: snapshot['Password'],
        email: snapshot['Email'],
        address: snapshot['Address'],
        avatarUrl: snapshot['Avatar URL'],
        notifStatus: snapshot['Notification Status'],
        currentNotif: snapshot['Current Notification'],
        courier_ref: snapshot['Bookmarks']

    );
  }

  List<DeliveryPrice> _deliveryPriceListFromSnapshot(QuerySnapshot snapshot){
    return snapshot.docs.map((doc){
      return DeliveryPrice(
        uid: doc.id,
        vehicleType: (doc.data() as dynamic) ['Vehicle Type'] ?? '',
        baseFare: (doc.data() as dynamic) ['Base Fare'] ?? '',
        farePerKM: (doc.data() as dynamic) ['Fare Per KM'] ?? '',
      );
    }).toList();
  }

  Stream<List<DeliveryPrice>> get deliveryPriceList {
    return deliveryPriceCollection.snapshots().map(_deliveryPriceListFromSnapshot);
  }
  Stream<List<Customer>> get customerList {
    return customerCollection.snapshots().map(_customerDataListFromSnapshot);
  }

  Future updateBaseFare(int baseFare) async {
    await deliveryPriceCollection
        .doc(uid)
        .update({
      'Base Fare': baseFare,
    });
  }
  Future updateFarePerKM(int farePerKM) async {
    await deliveryPriceCollection
        .doc(uid)
        .update({
      'Fare Per KM': farePerKM,
    });
  }
}