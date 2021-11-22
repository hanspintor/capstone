import 'package:flutter/material.dart';
import 'package:proxpress/models/notifications.dart';

class NotifTileCustomer extends StatefulWidget {
  final Notifications notif;

  NotifTileCustomer({Key key, this.notif}) : super(key: key);

  @override
  State<NotifTileCustomer> createState() => _NotifTileCustomerState();
}

class _NotifTileCustomerState extends State<NotifTileCustomer> {
  int flag = 0;
  int countList = 0;
  String uid;
  bool view = true;
  bool accepted = false;
  bool canceled = false;

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