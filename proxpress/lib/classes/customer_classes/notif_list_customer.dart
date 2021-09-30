import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:proxpress/Load/user_load.dart';
import 'package:proxpress/classes/customer_classes/notif_tile_customer.dart';
import 'package:proxpress/models/deliveries.dart';
import 'package:proxpress/models/notifications.dart';

class NotifListCustomer extends StatefulWidget {

  @override
  _NotifListCustomerState createState() => _NotifListCustomerState();
}

class _NotifListCustomerState extends State<NotifListCustomer> {
  @override
  Widget build(BuildContext context) {
    final notif = Provider.of<List<Notifications>>(context);

    notif.sort((a, b) => b.time.compareTo(a.time));
    return notif == null ? UserLoading() :  ListView.builder(
          itemCount: notif.length,
          itemBuilder: (context, index){
            return NotifTileCustomer(notif: notif[index]);
          },
        );
  }
}


