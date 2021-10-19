import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart';
import 'package:proxpress/Load/user_load.dart';
import 'package:proxpress/UI/CourierUI/courier_dashboard.dart';
import 'package:proxpress/UI/login_screen.dart';
import 'package:proxpress/classes/courier_classes/notif_list_courier.dart';
import 'package:proxpress/models/couriers.dart';
import 'package:proxpress/models/notifications.dart';
import 'package:proxpress/models/user.dart';
import 'package:proxpress/services/database.dart';

class NotifDrawerCourier extends StatefulWidget {
  @override
  _NotifDrawerCourierState createState() => _NotifDrawerCourierState();
}

class _NotifDrawerCourierState extends State<NotifDrawerCourier> {
  bool isClear = false;
  String caption = "";
  int flag = 1;
  @override
  Widget build(BuildContext context) {
    bool approved = false;
    final user = Provider.of<TheUser>(context);
    if(flag <= 0){
      isClear = true;
      caption = "No data found";
      flag++;
    }

    return user == null ? LoginScreen() : StreamBuilder<Courier>(
      stream: DatabaseService(uid: user.uid).courierData,
       builder: (context, snapshot){
        if(snapshot.hasData){
          Courier courierData = snapshot.data;
          approved = courierData.approved;

          DocumentReference courier = FirebaseFirestore.instance.collection('Couriers').doc(user.uid);

          Stream<List<Notifications>> notifList = FirebaseFirestore.instance
            .collection('Notifications')
            .where('Sent To', isEqualTo: courier)
            .snapshots()
            .map(DatabaseService().notifListFromSnapshot);

          return !approved ? CourierDashboard() : StreamProvider<List<Notifications>>.value(
            value: notifList,
            initialData: [],
            child: Drawer(
              child: Column(
                  mainAxisSize : MainAxisSize.max,
                  children: [
                    Expanded(
                        child: !isClear ? NotifListCourier() : Container(),
                    ),
                    isClear ? Container(
                      height: MediaQuery.of(context).size.height / 2,
                      child: Text(
                        caption,
                        style: TextStyle(),
                      ),
                    ) : Container(),
                    Container(
                      height: MediaQuery.of(context).size.height / 20,
                      width: MediaQuery.of(context).size.width / 1,
                      child: ElevatedButton.icon(
                        icon: Icon(Icons.clear),
                        label: Text('Clear'),
                        onPressed: () async {
                          var collection = FirebaseFirestore.instance.collection('Notifications').where('Sent To', isEqualTo: courier);
                          var snapshots = await collection.get();
                          for (var doc in snapshots.docs) {
                            await doc.reference.delete();
                          }
                          showToast('Notifications cleared');
                        },
                        style: ElevatedButton.styleFrom(primary: Color(0xfffb0d0d), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(0)),),
                      ),
                    ),
                  ]
              ),
            ),
          );
        } else {
          return UserLoading();
        }
       },
    );
  }
  Future showToast(String message) async {
    await Fluttertoast.cancel();
    Fluttertoast.showToast(msg: message, fontSize: 18, backgroundColor: Colors.green, textColor: Colors.white);
  }
}
