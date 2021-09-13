import 'package:proxpress/classes/delivery_tile.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:proxpress/Load/user_load.dart';
import 'package:proxpress/models/deliveries.dart';

class DeliveryList extends StatefulWidget {
  @override
  _DeliveryListState createState() => _DeliveryListState();
}

class _DeliveryListState extends State<DeliveryList> {
  @override
  Widget build(BuildContext context) {
    final delivery = Provider.of<List<Delivery>>(context);
    print(delivery.length.toString());
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
