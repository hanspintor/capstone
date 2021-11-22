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

    if (delivery.length != 0) {
      return delivery == null ? UserLoading() : ListView.builder(
        physics: NeverScrollableScrollPhysics(),
        shrinkWrap: true,
        itemCount: delivery.length,
        itemBuilder: (context, index) {
          return DeliveryTile(delivery: delivery[index],
            lengthDelivery: delivery.length,
            notifPopUpStatus: widget.notifPopUpStatus,
            notifPopUpCounter: widget.notifPopUpCounter,
          );
        },
      );
    } else {
      return Row(
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Text(
                'You currently have no pending requests.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 18,
                ),
              ),
            ),
          ),
        ],
      );
    }
  }
}