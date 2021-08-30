import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:proxpress/UI/login_screen.dart';
import 'package:proxpress/classes/courier_list.dart';
import 'package:proxpress/models/couriers.dart';


class CourierTile extends StatelessWidget {
  final Courier courier;
  CourierTile({this.courier});

  @override
  Widget build(BuildContext context) {
    final FirebaseAuth _auth = FirebaseAuth.instance;
    User user = _auth.currentUser;
    return user == null ? LoginScreen() : Padding(
      padding: EdgeInsets.only(top: 8.0),
      child: Card(
        margin: EdgeInsets.fromLTRB(20.0, 6.0, 20.0, 0.0),
        child: ListTile(
          title: Text("${courier.fName} ${courier.lName}"),
          leading: Icon(
                 Icons.account_circle_rounded,
                 size: 50,
           ),
          subtitle: Text(
              "Vehicle Type: "
          ),
        ),
      ),
    );
  }
}
