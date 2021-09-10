import 'package:flutter/material.dart';

class NotifDrawerCourier extends StatefulWidget {
  @override
  _NotifDrawerCourierState createState() => _NotifDrawerCourierState();
}

class _NotifDrawerCourierState extends State<NotifDrawerCourier> {
  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Column(
          mainAxisSize : MainAxisSize.max,
          children: [
            Expanded(
              child: ListView(
                children: [
                  ListTile(

                  ),
                ],
              ),
            ),
            Container(
              height: MediaQuery.of(context).size.height / 20,
              width: MediaQuery.of(context).size.width / 1,
              child: ElevatedButton.icon(
                icon: Icon(Icons.clear),
                label: Text('Clear'),
                onPressed: (){
                },
                style: ElevatedButton.styleFrom(primary: Color(0xfffb0d0d), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(0)),),
              ),
            ),
          ]
      ),
    );
  }
}
