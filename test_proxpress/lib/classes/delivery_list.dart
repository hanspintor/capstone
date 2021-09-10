import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:proxpress/classes/firestore_search.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:proxpress/Load/user_load.dart';
import 'package:proxpress/classes/courier_tile.dart';
import 'package:proxpress/classes/delivery_tile.dart';
import 'package:proxpress/models/couriers.dart';
import 'package:proxpress/models/deliveries.dart';
import 'package:proxpress/services/database.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:proxpress/services/firestore_service.dart';

class DeliveryList extends StatefulWidget {
  // final String pickupAddress;
  // final LatLng pickupCoordinates;
  // final String dropOffAddress;
  // final LatLng dropOffCoordinates;
  // final double distance;
  //
  // DeliveryList({
  //   Key key,
  //   @required this.pickupAddress,
  //   @required this.pickupCoordinates,
  //   @required this.dropOffAddress,
  //   @required this.dropOffCoordinates,
  //   @required this.distance,
  // }) : super(key: key);

  @override
  _DeliveryListState createState() => _DeliveryListState();
}

class _DeliveryListState extends State<DeliveryList> {
  @override
  Widget build(BuildContext context) {
    final FirebaseAuth _auth = FirebaseAuth.instance;
    User user = _auth.currentUser;

    final delivery = Provider.of<List<Delivery>>(context);
    return delivery == null
        ? UserLoading()
        : SingleChildScrollView(
            child: Container(
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height - 200,
              //color: widget.searchBodyBackgroundColor,
              child: StreamBuilder<List>(
                stream: FirestoreServicePackage(
                        collectionName: 'Couriers',
                        searchBy: 'Courier Reference' ?? '',
                        dataListFromSnapshot:
                            DatabaseService().deliveryDataListFromSnapshot,
                        limitOfRetrievedData: 10)
                    .searchData(FirebaseFirestore.instance
                        .collection('Couriers')
                        .doc(user.uid)),
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    final List<Delivery> dataList = snapshot.data;
                    return ListView.builder(
                        itemCount: dataList.length ?? 0,
                        itemBuilder: (context, index) {
                          return DeliveryTile(
                            delivery: dataList[index],
                          );
                        });
                  }
                  return Center(
                    child: CircularProgressIndicator(),
                  );
                },
              ),
            ),
          );

    // FirestoreSearchScaffold(
    //   firestoreCollectionName: 'Delivery',
    //   searchBy: 'Courier Reference',
    //   dataListFromSnapshot: DatabaseService().deliveryDataListFromSnapshot,
    //   builder: (context, snapshot) {
    //     if (snapshot.hasData) {
    //       final List<Delivery> dataList = snapshot.data;
    //
    //       return ListView.builder(
    //           itemCount: dataList.length ?? 0,
    //           itemBuilder: (context, index) {
    //             return DeliveryTile(
    //               delivery: dataList[index],
    //               pickupAddress: widget.pickupAddress,
    //               pickupCoordinates: widget.pickupCoordinates,
    //               dropOffAddress: widget.dropOffAddress,
    //               dropOffCoordinates: widget.dropOffCoordinates,
    //               distance: widget.distance,);
    //           });
    //     }
    //     return Center(
    //       child: CircularProgressIndicator(),
    //     );
    //   },
    // );
  }
}
