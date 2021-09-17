import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:expansion_tile_card/expansion_tile_card.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:proxpress/Load/user_load.dart';
import 'package:proxpress/UI/login_screen.dart';
import 'package:proxpress/models/customers.dart';
import 'package:proxpress/models/deliveries.dart';
import 'package:proxpress/services/database.dart';

class NotifTileCourier extends StatefulWidget {
  final Delivery delivery;

  NotifTileCourier({ Key key, this.delivery}) : super(key: key);

  @override
  State<NotifTileCourier> createState() => _NotifTileCourierState();
}

class _NotifTileCourierState extends State<NotifTileCourier> {
  int flag = 0;
  String uid;
  bool view = true;
  @override
  Widget build(BuildContext context) {
    uid = widget.delivery.customerRef.id;

    final FirebaseAuth _auth = FirebaseAuth.instance;
    User user = _auth.currentUser;

    if(widget.delivery.courierApproval == "Approved")
      view = false;
    else view = true;
    return user == null ? LoginScreen() : StreamBuilder<Customer>(
      stream: DatabaseService(uid: uid).customerData,
      builder: (context, snapshot){
        if(snapshot.hasData){
          Customer customerData = snapshot.data;
          return  Card(
              child: ListTile(
                selected: view,
                leading: Icon(
                  Icons.fiber_manual_record,
                  size: 15,
                ),
                title: Text(
                    "${customerData.fName} ${customerData.lName} "
                        "requested a delivery",
                  style: TextStyle(
                    color: view ? Colors.black87 : Colors.black54,
                  ),
                ),
                onTap: (){
                    setState(() {
                      view = false;
                    });
                },

              ),
            );

        } else {
          return Center(

          );
        }
      },
    );
  }
}