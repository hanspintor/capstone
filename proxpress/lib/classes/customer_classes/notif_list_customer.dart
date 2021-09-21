import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:proxpress/Load/user_load.dart';
import 'package:proxpress/classes/customer_classes/notif_tile_customer.dart';
import 'package:proxpress/models/deliveries.dart';

class NotifListCustomer extends StatefulWidget {

  @override
  _NotifListCustomerState createState() => _NotifListCustomerState();
}

class _NotifListCustomerState extends State<NotifListCustomer> {
  @override
  Widget build(BuildContext context) {
    final delivery = Provider.of<List<Delivery>>(context);
    return delivery == null ? UserLoading() : SingleChildScrollView(
      child: SizedBox(
        height: 500,
        width: 500,
        child: ListView.builder(
          itemCount: delivery.length,
          itemBuilder: (context, index){
            return NotifTileCustomer(delivery: delivery[index], lengthDeliv: delivery.length,);
          },
        ),
      ),
    );
  }
}


