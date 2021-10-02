import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:proxpress/models/couriers.dart';
import 'package:proxpress/models/deliveries.dart';
import 'package:proxpress/models/notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;
import 'package:proxpress/services/database.dart';
import 'package:proxpress/services/notification.dart';

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
  bool viewable = true;
  int flag = 0;
  void _openEndDrawer() {
    widget.scaffoldKey.currentState.openEndDrawer();
  }


  @override
  void initState(){
    super.initState();

    tz.initializeTimeZones();
  }

  @override
  Widget build(BuildContext context) {
    final notif = Provider.of<List<Notifications>>(context);
    final FirebaseAuth _auth = FirebaseAuth.instance;
    User user = _auth.currentUser;
    int flag = 0;
    int cont = 0;


    DocumentReference courier = FirebaseFirestore.instance.collection('Couriers').doc(user.uid);
    Stream<List<Notifications>> notifList = FirebaseFirestore.instance
        .collection('Notifications')
        .where('Sent To', isEqualTo: courier)
        .snapshots()
        .map(DatabaseService().notifListFromSnapshot);


    return StreamBuilder<List<Notifications>>(
      stream: notifList,
      builder: (context, snapshot) {
       if(snapshot.hasData){
         List<Notifications> n = snapshot.data;

         String title = "";

         for(int x = 0; x<n.length; x++){
           print("${n[x].sentBy.id} ${n[x].seen} ${n.length}");
           if(n[x].seen == false){
             viewable = true;
             break;
           } else {
             viewable = false;
           }
         }

         for(int i = 0; i<n.length; i++){
           if(n[i].seen == false){
             if(n[i].notifMessage.contains("requested")){
               title = "Customer Request";
             }

             NotificationService().showNotification(i, title, n[i].notifMessage, i);
             flag++;

           }
           cont = flag;
         }

         cont = cont ~/ 2;
         if(notif.length == 0 || cont == 0){
           viewable = false;
         }
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

       }else{
         return Container();
       }

      }
    );
  }
}
