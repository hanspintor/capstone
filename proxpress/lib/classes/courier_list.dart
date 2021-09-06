import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:proxpress/classes/firestore_search.dart';
import 'package:firestore_search/firestore_service.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:proxpress/Load/user_load.dart';
import 'package:proxpress/classes/courier_tile.dart';
import 'package:proxpress/models/couriers.dart';
import 'package:proxpress/services/database.dart';

class CourierList extends StatefulWidget {
  String searched;
  CourierList({this.searched});

  @override
  _CourierListState createState() => _CourierListState();
}

class _CourierListState extends State<CourierList> {
  String searched;
  _CourierListState({this.searched});

  List<Courier> showResults;

  @override
  Widget build(BuildContext context) {
    final courier = Provider.of<List<Courier>>(context);
    List<Courier> Function(QuerySnapshot<Object> snapshot) courierList = DatabaseService().courierDataListFromSnapshot;
    return courier == null ? UserLoading() : FirestoreSearchScaffold(
      firestoreCollectionName: 'Couriers',
      searchBy: 'First Name',
      dataListFromSnapshot: courierList,
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          final List<Courier> dataList = snapshot.data;

          return SingleChildScrollView(
            child: ListView.builder(
                shrinkWrap: true,
                itemCount: dataList.length ?? 0,
                itemBuilder: (context, index) {
                  return CourierTile(courier: dataList[index]);
                }),
          );
        }
        return Center(
          child: CircularProgressIndicator(),
        );
      },
    );

    // SingleChildScrollView(
    //   child: SizedBox(
    //     height: 650,
    //     child: ListView.builder(
    //         itemCount: courier.length,
    //         itemBuilder: (context, index) {
    //           return CourierTile(courier: courier[index]);
    //         },
    //     ),
    //   ),
    // );
  }
}
