import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:proxpress/Load/user_load.dart';
import 'package:proxpress/UI/CourierUI/courier_dashboard.dart';
import 'package:proxpress/UI/login_screen.dart';
import 'package:proxpress/classes/delivery_list.dart';
import 'package:proxpress/classes/notif_list.dart';
import 'package:proxpress/models/couriers.dart';
import 'package:proxpress/models/deliveries.dart';
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
    //print("flag out: $flag");
    return user == null ? LoginScreen() : StreamBuilder<Courier>(
      stream: DatabaseService(uid: user.uid).courierData,
       builder: (context, snapshot){
        if(snapshot.hasData){
          Courier courierData = snapshot.data;
          approved = courierData.approved;

          Stream<List<Delivery>> deliveryList = FirebaseFirestore.instance
              .collection('Deliveries')
              .where('Courier Reference', isEqualTo: FirebaseFirestore.instance.collection('Couriers').doc(user.uid))
              .snapshots()
              .map(DatabaseService().deliveryDataListFromSnapshot);

          return !approved ? CourierDashboard() : StreamProvider<List<Delivery>>.value(
            value: deliveryList,
            initialData: [],
            child: Drawer(
              child: Column(
                  mainAxisSize : MainAxisSize.max,
                  children: [

                    Expanded(
                        child: !isClear ? NotifList() : Container(),
                    ),
                    Container(
                      height: MediaQuery.of(context).size.height / 2,
                      child: Text(
                        caption,
                        style: TextStyle(

                        ),
                      ),
                    ),
                    Container(
                      height: MediaQuery.of(context).size.height / 20,
                      width: MediaQuery.of(context).size.width / 1,
                      child: ElevatedButton.icon(
                        icon: Icon(Icons.clear),
                        label: Text('Clear'),
                        onPressed: (){
                          setState(() {
                            flag = 0;
                          });

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
}
