import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:proxpress/models/couriers.dart';
import 'package:proxpress/models/deliveries.dart';

import 'package:proxpress/services/database.dart';

class NotifCounterCourier extends StatefulWidget {
  final GlobalKey<ScaffoldState> scaffoldKey;
  final approved;
  NotifCounterCourier({
    Key key,
    @required this.scaffoldKey,
    @required this.approved,
  }) : super(key: key);

  @override
  _NotifCounterCourierState createState() => _NotifCounterCourierState();
}

class _NotifCounterCourierState extends State<NotifCounterCourier> {
  bool viewable;
  void _openEndDrawer() {
    widget.scaffoldKey.currentState.openEndDrawer();
  }

  void setFalse(){
    setState(() {
      viewable = false;
    });
  }
  int notifs;


  @override
  Widget build(BuildContext context) {
    final delivery = Provider.of<List<Delivery>>(context);
    final FirebaseAuth _auth = FirebaseAuth.instance;
    User user = _auth.currentUser;


    return StreamBuilder <Courier>(
      stream: DatabaseService(uid: user.uid).courierData,
      builder: (context, snapshot){
        if(snapshot.hasData){
          Courier notifData = snapshot.data;
          //showNotifcation();
          if(notifData.currentNotif != delivery.length){
            if(notifData.currentNotif < delivery.length){
              notifs = delivery.length - notifData.currentNotif;
            } else{
              notifs = notifData.currentNotif - delivery.length;
            }
          } else{
            notifs = delivery.length;
          }

          if(notifs == 0){
            viewable = false;
          }
          return Stack(
            children: [
              IconButton(
                icon: Icon(Icons.notifications_none_rounded),
                onPressed: !widget.approved ? null : () async{
                  setFalse();
                  await DatabaseService(uid: user.uid).updateNotifCounterCourier(delivery.length);
                  await DatabaseService(uid: user.uid).updateNotifStatusCourier(viewable);
                  _openEndDrawer();
                  //print("flag inC: $flag");
                },
                iconSize: 25,
              ),
              Visibility(
                maintainSize: true,
                maintainAnimation: true,
                maintainState: true,
                visible: notifData.notifStatus,
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
                      notifs.toString(),
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
