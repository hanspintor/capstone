import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:proxpress/models/user.dart';

import '../login_screen.dart';

class NotifDrawerCustomer extends StatefulWidget {


  @override
  _NotifDrawerCustomerState createState() => _NotifDrawerCustomerState();
}

class _NotifDrawerCustomerState extends State<NotifDrawerCustomer>{

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<TheUser>(context);
    return user == null ? LoginScreen() :Drawer(
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
