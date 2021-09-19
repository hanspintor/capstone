import 'package:proxpress/classes/courier_classes/delivery_tile.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:proxpress/Load/user_load.dart';
import 'package:proxpress/models/deliveries.dart';

class DeliveryList extends StatefulWidget {
  final bool notifPopUpStatus;
  final int notifPopUpCounter;
  DeliveryList({
    Key key,
    @required this.notifPopUpStatus,
    @required this.notifPopUpCounter,
  }) : super(key: key);
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
            return DeliveryTile(delivery: delivery[index],
              lengthDelivery: delivery.length,
              notifPopUpStatus: widget.notifPopUpStatus,
              notifPopUpCounter: widget.notifPopUpCounter,
            );
          },
        ),
      ),
    );
  }
}