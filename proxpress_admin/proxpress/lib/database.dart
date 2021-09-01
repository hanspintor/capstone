import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:proxpress/couriers.dart';

class DatabaseService {
  final String uid;
  DatabaseService({this.uid});
  final CollectionReference courierCollection = FirebaseFirestore.instance.collection('Couriers');

  List<Courier> _courierDataListFromSnapshot(QuerySnapshot snapshot){
    return snapshot.docs.map((doc){
      return Courier(
        fName: (doc.data() as dynamic) ['First Name'] ?? '',
        lName: (doc.data() as dynamic) ['Last Name'] ?? '',
        contactNo: (doc.data() as dynamic) ['Contact No'] ?? '',
        password: (doc.data() as dynamic) ['Password'] ?? '',
        email: (doc.data() as dynamic) ['Email'] ?? '',
        address: (doc.data() as dynamic) ['Address']?? '',
        vehicleType: (doc.data() as dynamic) ['Vehicle Type'] ?? '',
        vehicleColor: (doc.data() as dynamic) ['Vehicle Color'] ?? '',

      );
    }).toList();
  }
  Stream<List<Courier>> get courierList {
    return courierCollection.snapshots().map(_courierDataListFromSnapshot);
  }
}