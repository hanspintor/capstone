import 'package:flutter/material.dart';

class NotifDrawer extends StatefulWidget {


  @override
  _NotifDrawerState createState() => _NotifDrawerState();
}

class _NotifDrawerState extends State<NotifDrawer>{
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
