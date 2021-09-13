import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:proxpress/models/deliveries.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

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

  Future showNotifcation() async{
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
  int del = 0;
  int flag = 0;

  @override
  Widget build(BuildContext context) {
    final delivery = Provider.of<List<Delivery>>(context);

    // flag = 0;
    //print("Notifs ${notifs}");
    print("flag ${flag}");
    if(flag <= 0){
      viewable = true;
      flag++;
    }
    // if(flag <= 0){
    //   viewable  = true;
    //
    //   flag++;
    // }
    notifs = delivery.length;
    // if(notifs == 0)
    //   viewable = false;
    if(!widget.approved || notifs == 0){
      viewable = false;
    }
    return Stack(
      children: [
        IconButton(
          icon: Icon(Icons.notifications_none_rounded),
          onPressed: !widget.approved ? null : (){
            if(notifs != 0)
              showNotifcation();
             // setFalse();
            _openEndDrawer();
            //print("flag inC: $flag");
            print("V:  ${viewable}");
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

  }
}
