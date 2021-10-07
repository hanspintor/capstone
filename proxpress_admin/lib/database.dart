import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:proxpress/couriers.dart';
import 'package:proxpress/delivery_prices.dart';

class DatabaseService {
  final String uid;
  DatabaseService({this.uid});
  final CollectionReference courierCollection = FirebaseFirestore.instance.collection('Couriers');
  final CollectionReference deliveryPriceCollection = FirebaseFirestore.instance.collection('Delivery Prices');

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

  Stream<List<Courier>> get courierList {
    return courierCollection.snapshots().map(_courierDataListFromSnapshot);
  }

  Future approveCourier() async {
    await FirebaseFirestore.instance.collection('Couriers')
        .doc(uid)
        .update({
      'Admin Approved': true,
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

  Future updateDeliveryPrice(int baseFare, int farePerKM) async {
    await deliveryPriceCollection
        .doc(uid)
        .update({
      'Base Fare': baseFare,
      'Fare Per KM': farePerKM,
    });
  }
}