import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart';
import 'package:proxpress/UI/CustomerUI/dashboard_location.dart';
import 'package:proxpress/classes/customer_classes/notif_list_customer.dart';
import 'package:proxpress/models/notifications.dart';
import 'package:proxpress/services/database.dart';
import '../login_screen.dart';

class NotifDrawerCustomer extends StatefulWidget {
  @override
  _NotifDrawerCustomerState createState() => _NotifDrawerCustomerState();
}

class _NotifDrawerCustomerState extends State<NotifDrawerCustomer>{
  bool isClear = false;
  String caption = "";
  int flag = 1;

  @override
  Widget build(BuildContext context) {
    bool approved = false;
    final auth = FirebaseAuth.instance;
    User user = auth.currentUser;

    if(flag <= 0){
      isClear = true;
      caption = "No data found";
      flag++;
    }

    if (user != null) {
      DocumentReference customer = FirebaseFirestore.instance.collection('Customers').doc(user.uid);

      Stream<List<Notifications>> notifList = FirebaseFirestore.instance
          .collection('Notifications')
          .where('Sent To', isEqualTo: customer)
          .snapshots()
          .map(DatabaseService().notifListFromSnapshot);

      return approved ? DashboardLocation() : StreamProvider<List<Notifications>>.value(
        value: notifList,
        initialData: [],
        child: Drawer(
          child: Column(
              mainAxisSize : MainAxisSize.max,
              children: [
                Expanded(
                  child: !isClear ? NotifListCustomer() : Container(),
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
                      var collection = FirebaseFirestore.instance.collection('Notifications').where('Sent To', isEqualTo: customer);
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
      return LoginScreen();
    }
  }

  Future showToast(String message) async {
    await Fluttertoast.cancel();
    Fluttertoast.showToast(msg: message, fontSize: 18, backgroundColor: Colors.green, textColor: Colors.white);
  }
}