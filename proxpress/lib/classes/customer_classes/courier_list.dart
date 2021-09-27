import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:proxpress/classes/firestore_search.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:proxpress/Load/user_load.dart';
import 'package:proxpress/classes/customer_classes/courier_tile.dart';
import 'package:proxpress/models/couriers.dart';
import 'package:proxpress/models/deliveries.dart';
import 'package:proxpress/services/database.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class CourierList extends StatefulWidget {
  final String pickupAddress;
  final LatLng pickupCoordinates;
  final String dropOffAddress;
  final LatLng dropOffCoordinates;
  final double distance;

  CourierList({
    Key key,
    @required this.pickupAddress,
    @required this.pickupCoordinates,
    @required this.dropOffAddress,
    @required this.dropOffCoordinates,
    @required this.distance,
  }) : super(key: key);

  @override
  _CourierListState createState() => _CourierListState();
}

class _CourierListState extends State<CourierList> {
  @override
  Widget build(BuildContext context) {
    final courier = Provider.of<List<Courier>>(context);

    final FirebaseAuth _auth = FirebaseAuth.instance;
    User user = _auth.currentUser;

    Stream<List<Delivery>> deliveryRequestPending = FirebaseFirestore.instance
        .collection('Deliveries')
        .where('Courier Approval', isEqualTo: 'Pending')
        .where('Customer Reference', isEqualTo: FirebaseFirestore.instance.collection('Customers').doc(user.uid))
        .snapshots()
        .map(DatabaseService().deliveryDataListFromSnapshot);

    return courier == null ? UserLoading() : StreamBuilder<List<Delivery>>(
      stream: deliveryRequestPending,
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          List<Delivery> pending = snapshot.data;

          List<String> excludeCouriers = [];

          pending.forEach((delivery){
            excludeCouriers.add(delivery.courierRef.id);
          });

          return FirestoreSearchScaffold(
            firestoreCollectionName: 'Couriers',
            searchBy: 'First Name',
            dataListFromSnapshot: DatabaseService().courierDataListFromSnapshot,
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                final List<Courier> dataList = snapshot.data;

                return ListView.builder(
                    itemCount: dataList.length ?? 0,
                    itemBuilder: (context, index) {
                      if (!excludeCouriers.any((element) => dataList[index].uid == element)) {
                        return CourierTile(
                          courier: dataList[index],
                          pickupAddress: widget.pickupAddress,
                          pickupCoordinates: widget.pickupCoordinates,
                          dropOffAddress: widget.dropOffAddress,
                          dropOffCoordinates: widget.dropOffCoordinates,
                          distance: widget.distance,);
                      } else {
                        return Container(
                          //child: Text('Courier Disabled: ${dataList[index].fName} ${dataList[index].lName}'),
                        );
                      }
                    });
              }
              return Center(
                child: CircularProgressIndicator(),
              );
            },
          );
        } else {
          return FirestoreSearchScaffold(
            firestoreCollectionName: 'Couriers',
            searchBy: 'First Name',
            dataListFromSnapshot: DatabaseService().courierDataListFromSnapshot,
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                final List<Courier> dataList = snapshot.data;

                return ListView.builder(
                    itemCount: dataList.length ?? 0,
                    itemBuilder: (context, index) {
                      return CourierTile(
                        courier: dataList[index],
                        pickupAddress: widget.pickupAddress,
                        pickupCoordinates: widget.pickupCoordinates,
                        dropOffAddress: widget.dropOffAddress,
                        dropOffCoordinates: widget.dropOffCoordinates,
                        distance: widget.distance,);
                    });
              }
              return Center(
                child: CircularProgressIndicator(),
              );
            },
          );
        }
      }
    );
  }
}
