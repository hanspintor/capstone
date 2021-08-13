import 'package:flutter/material.dart';

class NotifDrawer extends StatefulWidget {


  @override
  _NotifDrawerState createState() => _NotifDrawerState();
}

class _NotifDrawerState extends State<NotifDrawer>{
  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text('.i.'),
          ],
        ),
      ),
    );
  }
}
