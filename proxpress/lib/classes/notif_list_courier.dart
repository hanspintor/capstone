import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:proxpress/Load/user_load.dart';
import 'package:proxpress/models/deliveries.dart';

import 'notif_tile_courier.dart';

class NotifList extends StatefulWidget {

  @override
  _NotifListState createState() => _NotifListState();
}

class _NotifListState extends State<NotifList> {
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
            return NotifTile(delivery: delivery[index]);
          },
        ),
      ),
    );
  }
}


