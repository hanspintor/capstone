import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreServicePackage<T> {
  final String collectionName;
  final String searchBy;
  final List Function(QuerySnapshot) dataListFromSnapshot;
  final int limitOfRetrievedData;

  FirestoreServicePackage(
      {this.collectionName,
        this.searchBy,
        this.dataListFromSnapshot,
        this.limitOfRetrievedData});
  final FirebaseFirestore firebasefirestore = FirebaseFirestore.instance;

  Stream<List> searchData(String query) {
    final collectionReference = firebasefirestore.collection(collectionName).orderBy('First Name');


    print("niceee $searchBy");
    print("niceee $query");

    return collectionReference
        .where(searchBy, isGreaterThanOrEqualTo: query)
        .where(searchBy, isLessThan: query + 'z')
        .limit(limitOfRetrievedData)
        .snapshots()
        .map(dataListFromSnapshot);
  }
}
