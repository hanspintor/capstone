import 'package:proxpress/classes/courier_classes/delivery_tile.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:proxpress/Load/user_load.dart';
import 'package:proxpress/classes/customer_classes/request_tile.dart';
import 'package:proxpress/models/deliveries.dart';

class RequestList extends StatefulWidget {
  @override
  _RequestListState createState() => _RequestListState();
}

class _RequestListState extends State<RequestList> {
  @override
  Widget build(BuildContext context) {
    final delivery = Provider.of<List<Delivery>>(context);
    //print(delivery.length.toString());

    return delivery == null ? UserLoading() : ListView.builder(
      shrinkWrap: true,
      itemCount: delivery.length,
      itemBuilder: (context, index) {
        return RequestTile(delivery: delivery[index]);
      },
    );
  }
}