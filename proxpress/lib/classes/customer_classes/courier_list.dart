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

class CourierList extends StatefulWidget {
  final String pickupAddress;
  final GeoPoint pickupCoordinates;
  final String dropOffAddress;
  final GeoPoint dropOffCoordinates;
  final double distance;
  final String vehicleType;

  CourierList({
    Key key,
    @required this.pickupAddress,
    @required this.pickupCoordinates,
    @required this.dropOffAddress,
    @required this.dropOffCoordinates,
    @required this.distance,
    @required this.vehicleType,
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

    Stream<List<Courier>> listCour = FirebaseFirestore.instance
        .collection('Couriers')
        .where('Admin Approved', isEqualTo: true)
        .where('Active Status', isEqualTo: 'Active')
        .snapshots()
        .map(DatabaseService().courierDataListFromSnapshot);

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

          pending.forEach((delivery) {
            excludeCouriers.add(delivery.courierRef.id);
          });

          return FirestoreSearchScaffold(
            firestoreCollectionName: 'Couriers',
            searchBy: 'First Name',
            dataListFromSnapshot: DatabaseService().courierDataListFromSnapshot,
            vehicleType: widget.vehicleType,
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                final List<Courier> dataList = snapshot.data;
                print(widget.vehicleType);
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
                          distance: widget.distance,
                        );
                      } else {
                        return Container();
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