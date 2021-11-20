import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:proxpress/models/notifications.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:proxpress/services/database.dart';
import 'package:proxpress/services/notification.dart';

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
  int detector = 0;

  void _openEndDrawer() {
    widget.scaffoldKey.currentState.openEndDrawer();
  }

  @override
  void initState() {
    super.initState();
    tz.initializeTimeZones();
  }

  @override
  Widget build(BuildContext context) {
    final notif = Provider.of<List<Notifications>>(context);
    final FirebaseAuth _auth = FirebaseAuth.instance;
    User user = _auth.currentUser;
    bool viewable;
    int flag = 0;
    int cont = 0;

    DocumentReference customer = FirebaseFirestore.instance.collection('Customers').doc(user.uid);
    Stream<List<Notifications>> notifList = FirebaseFirestore.instance
        .collection('Notifications')
        .where('Sent To', isEqualTo: customer)
        .snapshots()
        .map(DatabaseService().notifListFromSnapshot);

    return StreamBuilder <List<Notifications>>(
      stream: notifList,
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          List<Notifications> n = snapshot.data;

          String title = "";

          for(int x = 0; x<n.length; x++) {
            if (n[x].seen == false) {
              viewable = true;
              break;
            } else {
              viewable = false;
            }
          }

          for(int i = 0; i<n.length; i++) {
            if (n[i].seen == false) {
              if (n[i].notifMessage.contains("successfully")) {
                title = "Item Delivered";
              } else if (n[i].notifMessage.contains("declined")) {
                title = "Request Declined";
              } else if (n[i].notifMessage.contains("accepted")) {
                title = "Request Accepted";
              }

              if (n[i].popsOnce == true) {
                NotificationService().showNotification(i, title, n[i].notifMessage, i == 0? 1 : i);
                DatabaseService(uid: n[i].uid).updateNotifNotchCourier(false);
              }
              flag++;
            }
            cont = flag;
          }

          cont = cont ~/ 2;
          if (notif.length == 0 || cont == 0) {
            viewable = false;
          }

          return Stack(
            children: [
              IconButton(
                icon: Icon(Icons.notifications_none_rounded),
                onPressed: !widget.approved ||  !user.emailVerified && user.phoneNumber == null ? null : () async{
                  _openEndDrawer();
                  n.forEach((element) async {
                    await DatabaseService(uid: element.uid).updateNotifSeenCourier(true);
                  });
                },
              ),
              Visibility(
                maintainSize: true,
                maintainAnimation: true,
                maintainState: true,
                visible: viewable,
                child: Container(
                  padding: EdgeInsets.only(left: 25, top: 0),
                  height: 20,
                  width: 30,
                  decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.red
                  ),
                  child: Center(
                    child: Text(
                      "${cont.toString()}",
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