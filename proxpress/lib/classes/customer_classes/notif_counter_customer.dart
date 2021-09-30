import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:proxpress/models/couriers.dart';
import 'package:proxpress/models/customers.dart';
import 'package:proxpress/models/deliveries.dart';
import 'package:proxpress/models/notifications.dart';

import 'package:proxpress/services/database.dart';

class NotifCounterCustomer extends StatefulWidget {
  final GlobalKey<ScaffoldState> scaffoldKey;
  final approved;
  NotifCounterCustomer({
    Key key,
    @required this.scaffoldKey,
    @required this.approved,
  }) : super(key: key);

  @override
  _NotifCounterCustomerState createState() => _NotifCounterCustomerState();
}

class _NotifCounterCustomerState extends State<NotifCounterCustomer> {
  bool viewable;
  void _openEndDrawer() {
    widget.scaffoldKey.currentState.openEndDrawer();
  }
  int flag = 0;

  @override
  Widget build(BuildContext context) {
    final notif = Provider.of<List<Notifications>>(context);
    final FirebaseAuth _auth = FirebaseAuth.instance;
    User user = _auth.currentUser;

    DocumentReference customer = FirebaseFirestore.instance.collection('Customers').doc(user.uid);
    Stream<List<Notifications>> notifList = FirebaseFirestore.instance
        .collection('Notifications')
        .where('Sent To', isEqualTo: customer)
        .snapshots()
        .map(DatabaseService().notifListFromSnapshot);

    return StreamBuilder <List<Notifications>>(
      stream: notifList,
      builder: (context, snapshot){
        if(snapshot.hasData){
          List<Notifications> n = snapshot.data;
          if(notif.length == 0){
            viewable = false;
          }

          n.forEach((element) {
            if(flag <= 0){
              print("${element.sentBy.id} ${element.seen}");
              if(element.seen == false){
                viewable = true;
              } else{
                viewable = false;
              }
              flag++;
            }
          });
          return Stack(
            children: [
              IconButton(
                icon: Icon(Icons.notifications_none_rounded),
                onPressed: !widget.approved || !user.emailVerified ? null : () async{
                  _openEndDrawer();
                  n.forEach((element) async {
                    await DatabaseService(uid: element.uid).updateNotifSeenCourier(true);
                  });
                },
                iconSize: 25,
              ),
              Visibility(
                maintainSize: true,
                maintainAnimation: true,
                maintainState: true,
                visible: viewable,
                child: Container(
                  margin: EdgeInsets.only(left: 25, top: 5),
                  height: 20,
                  width: 30,
                  decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.red
                  ),
                  child: Center(
                    child: Text(
                      "${notif.length}",
                      style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold
                      ),
                    ),
                  ),
                ),
              )
            ],
          );
        } else return Container();
      },
    );
  }
}
