import 'package:flutter/material.dart';
import 'package:proxpress/models/notifications.dart';

class NotifTileCourier extends StatefulWidget {
  final Notifications notif;

  NotifTileCourier({ Key key, this.notif}) : super(key: key);

  @override
  State<NotifTileCourier> createState() => _NotifTileCourierState();
}

class _NotifTileCourierState extends State<NotifTileCourier> {
  String uid;
  bool view = true;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        selected: view,
        leading: Icon(
          Icons.fiber_manual_record,
          size: 15,
        ),
        title: Text(
          "${widget.notif.notifMessage}",
          style: TextStyle(
            color: view ? Colors.black87 : Colors.black54,
          ),
        ),
        onTap: () {
          setState(() {
            view = false;
          });
        },
      ),
    );
  }
}