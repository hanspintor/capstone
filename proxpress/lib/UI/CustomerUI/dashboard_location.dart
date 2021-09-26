import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:proxpress/Load/user_load.dart';
import 'package:proxpress/UI/CustomerUI/dashboard_customer.dart';
import 'package:proxpress/UI/login_screen.dart';
import 'package:proxpress/classes/courier_classes/notif_counter_courier.dart';
import 'package:proxpress/classes/customer_classes/notif_counter_customer.dart';
import 'package:proxpress/classes/customer_classes/pin_widget.dart';
import 'package:proxpress/classes/directions_model.dart';
import 'package:proxpress/classes/directions_repository.dart';
import 'package:proxpress/models/deliveries.dart';
import 'package:proxpress/services/auth.dart';
import 'package:proxpress/services/secrets.dart';
import 'menu_drawer_customer.dart';
import 'notif_drawer_customer.dart';
import 'package:proxpress/services/database.dart';
import 'package:proxpress/models/user.dart';
import 'package:provider/provider.dart';
import 'package:proxpress/models/customers.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'dart:async';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'dart:math' show cos, sqrt, asin;

class DashboardLocation extends StatefulWidget{
  @override
  _DashboardLocationState createState() => _DashboardLocationState();
}

class _DashboardLocationState extends State<DashboardLocation>{

  final bool notBookmarks = false;
  int duration = 60;
  int count = 0;
  final AuthService _auth = AuthService();
  final textFieldPickup = TextEditingController();
  final textFieldDropOff = TextEditingController();



  void _openEndDrawer() {
    _scaffoldKey.currentState.openEndDrawer();
  }

  final GlobalKey<FormState> locKey = GlobalKey<FormState>();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();







  @override
  Widget build(BuildContext context) {
    final user = Provider.of<TheUser>(context);

    bool approved = true;

    return user == null ? LoginScreen() : StreamBuilder<Customer>(
      stream: DatabaseService(uid: user.uid).customerData,
      builder: (context, snapshot) {
        if(snapshot.hasData){
          Customer customerData = snapshot.data;

          Stream<List<Delivery>> deliveryList = FirebaseFirestore.instance
              .collection('Deliveries')
              .where('Customer Reference', isEqualTo: FirebaseFirestore.instance.collection('Customers').doc(user.uid))
              .snapshots()
              .map(DatabaseService().deliveryDataListFromSnapshot);

          return WillPopScope(
            onWillPop: () async {
              print("Back Button pressed");
              return false;
            },
            child: Scaffold(
              drawerEnableOpenDragGesture: false,
              endDrawerEnableOpenDragGesture: false,
              key: _scaffoldKey,
              appBar: AppBar(
                backgroundColor: Colors.white,
                iconTheme: IconThemeData(
                  color: Color(0xfffb0d0d),
                ),
                actions: [
                  StreamProvider<List<Delivery>>.value(
                      value: deliveryList,
                      initialData: [],
                      child: NotifCounterCustomer(scaffoldKey: _scaffoldKey, approved: approved,)
                  )
                ],
                flexibleSpace: Container(
                  margin: EdgeInsets.only(top: 10),
                  child: Image.asset(
                    "assets/PROExpress-logo.png",
                    height: 120,
                    width: 120,
                  ),
                ),
                //title: Text("PROExpress"),
              ),
              drawer: MainDrawerCustomer(),
              endDrawer: NotifDrawerCustomer(),
              body: SingleChildScrollView(
                child: Center(
                  child: Column(
                    children: [
                      SizedBox(height: 10),
                      Align(
                        alignment: Alignment.bottomCenter,
                        child: Text("Welcome, ${customerData.fName}!",
                          style: TextStyle(
                            fontSize: 25,
                          ),
                        ),
                      ),
                      PinLocation(
                        locKey: locKey,
                        textFieldPickup: textFieldPickup,
                        textFieldDropOff: textFieldDropOff,
                        isBookmarks: false,
                      )
                    ],
                  ),
                ),
              ),
            ),
          );
        } else {
          return UserLoading();
        }
      }
    );
  }
}