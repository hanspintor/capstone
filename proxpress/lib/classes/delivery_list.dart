import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:proxpress/classes/delivery_tile.dart';
import 'package:proxpress/classes/firestore_search.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:proxpress/Load/user_load.dart';
import 'package:proxpress/classes/courier_tile.dart';
import 'package:proxpress/models/couriers.dart';
import 'package:proxpress/models/deliveries.dart';
import 'package:proxpress/services/database.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class DeliveryList extends StatefulWidget {
  @override
  _DeliveryListState createState() => _DeliveryListState();
}

class _DeliveryListState extends State<DeliveryList> {
  @override
  Widget build(BuildContext context) {
    final delivery = Provider.of<List<Delivery>>(context);

    return delivery == null ? UserLoading() : SingleChildScrollView(
      child: SizedBox(
        height: 500,
        width: 500,
        child: ListView.builder(
          itemCount: delivery.length,
          itemBuilder: (context, index) {
            return DeliveryTile(delivery: delivery[index]);
          },
        ),
      ),
    );
  }
}
// FirestoreSearchScaffold(
//   firestoreCollectionName: 'Couriers',
//   searchBy: 'First Name',
//   dataListFromSnapshot: DatabaseService().courierDataListFromSnapshot,
//   builder: (context, snapshot) {
//     if (snapshot.hasData) {
//       final List<Courier> dataList = snapshot.data;
//
//       return ListView.builder(
//           itemCount: dataList.length ?? 0,
//           itemBuilder: (context, index) {
//             return CourierTile(
//               courier: dataList[index],
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
// ),
