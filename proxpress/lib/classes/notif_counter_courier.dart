import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:proxpress/models/couriers.dart';
import 'package:proxpress/models/deliveries.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:proxpress/services/database.dart';

class NotifCounter extends StatefulWidget {
  final GlobalKey<ScaffoldState> scaffoldKey;
  final approved;
  NotifCounter({
    Key key,
    @required this.scaffoldKey,
    @required this.approved,
  }) : super(key: key);

  @override
  _NotifCounterState createState() => _NotifCounterState();
}

class _NotifCounterState extends State<NotifCounter> {
  bool viewable;
  void _openEndDrawer() {
    widget.scaffoldKey.currentState.openEndDrawer();
  }
  FlutterLocalNotificationsPlugin localNotication;
  @override
  void initState(){
    super.initState();
    var androidInitialize = new AndroidInitializationSettings('mipmap/ic_launcher');
    var iOSInitialize = new IOSInitializationSettings();
    var initializationSettings = new InitializationSettings(android: androidInitialize, iOS: iOSInitialize);
    localNotication = new FlutterLocalNotificationsPlugin();
    localNotication.initialize(
        initializationSettings, onSelectNotification: notifSelected
    );
  }
  Future notifSelected(String payload) async{

  }

  void showNotifcation() {
    var androidDetails = new AndroidNotificationDetails(
        "Channel ID",
        "Local Notifcation",
        "This is description",
        importance: Importance.high
    );
    var IOSDetails = new IOSNotificationDetails();
    var generalNotif = new NotificationDetails(android: androidDetails, iOS: IOSDetails);
    var schedNotif = DateTime.now().add(Duration(seconds: 5));

    localNotication.schedule(
        0,
        "TRIAL",
        "NOTIF",
        schedNotif,
        generalNotif
    );
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
          showNotifcation();
          if(notifData.currentNotif != delivery.length){
            if(notifData.currentNotif < delivery.length){
              notifs = delivery.length - notifData.currentNotif;
            } else{
              notifs = notifData.currentNotif - delivery.length;
            }
          } else{
            notifs = delivery.length;
          }
          return Stack(
            children: [
              IconButton(
                icon: Icon(Icons.notifications_none_rounded),
                onPressed: !widget.approved ? null : () async{

                    //showNotifcation();
                  setFalse();
                  await DatabaseService(uid: user.uid).updateNotifCounter(delivery.length);
                   await DatabaseService(uid: user.uid).updateNotifStatus(viewable);
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
