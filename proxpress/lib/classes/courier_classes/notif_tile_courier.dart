import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
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
  String str;
  @override
  Widget build(BuildContext context) {
    uid = widget.delivery.customerRef.id;

    final FirebaseAuth _auth = FirebaseAuth.instance;
    User user = _auth.currentUser;


    if(widget.delivery.courierApproval == "Cancelled"){
      str = "cancelled";
    } else{
      str = "requested";
    }
    if(widget.delivery.courierApproval == "Approved" || widget.delivery.courierApproval == "Cancelled")
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
                        "${str} a delivery",
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