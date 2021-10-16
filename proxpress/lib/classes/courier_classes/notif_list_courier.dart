import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:proxpress/Load/user_load.dart';
import 'package:proxpress/models/notifications.dart';
import 'notif_tile_courier.dart';

class NotifListCourier extends StatefulWidget {

  @override
  _NotifListCourierState createState() => _NotifListCourierState();
}

class _NotifListCourierState extends State<NotifListCourier> {
  @override
  Widget build(BuildContext context) {
    final notif = Provider.of<List<Notifications>>(context);

    notif.sort((a, b) => b.time.compareTo(a.time));
    return notif == null ? UserLoading() : ListView.builder(
          itemCount: notif.length,
          itemBuilder: (context, index){
            return NotifTileCourier(notif: notif[index]);
          },
        );
  }
}


