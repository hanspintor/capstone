import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:proxpress/Load/user_load.dart';
import 'package:proxpress/models/deliveries.dart';
import 'notif_tile_courier.dart';

class NotifListCourier extends StatefulWidget {

  @override
  _NotifListCourierState createState() => _NotifListCourierState();
}

class _NotifListCourierState extends State<NotifListCourier> {
  @override
  Widget build(BuildContext context) {
    final delivery = Provider.of<List<Delivery>>(context);
    return delivery == null ? UserLoading() : ListView.builder(
          itemCount: delivery.length,
          itemBuilder: (context, index){
            return NotifTileCourier(delivery: delivery[index]);
          },
        );
  }
}


