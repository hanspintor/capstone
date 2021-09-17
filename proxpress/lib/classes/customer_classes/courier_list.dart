import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:proxpress/classes/firestore_search.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:proxpress/Load/user_load.dart';
import 'package:proxpress/classes/customer_classes/courier_tile.dart';
import 'package:proxpress/models/couriers.dart';
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

    return courier == null ? UserLoading() : FirestoreSearchScaffold(
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
