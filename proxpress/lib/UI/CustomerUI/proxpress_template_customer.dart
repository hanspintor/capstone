import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:proxpress/UI/CustomerUI/courier_bookmarks.dart';
import 'package:proxpress/UI/CustomerUI/customer_community_hub.dart';
import 'package:proxpress/UI/CustomerUI/customer_wallet.dart';
import 'package:proxpress/UI/CustomerUI/dashboard_location.dart';
import 'package:proxpress/UI/CustomerUI/delivery_status_class.dart';
import 'package:proxpress/UI/login_screen.dart';
import 'package:proxpress/classes/customer_classes/notif_counter_customer.dart';
import 'package:proxpress/models/notifications.dart';
import 'customer_profile.dart';
import 'menu_drawer_customer.dart';
import 'notif_drawer_customer.dart';
import 'package:proxpress/services/database.dart';
import 'package:provider/provider.dart';
import 'dart:async';

class AppBarTemp extends StatefulWidget{
  final String currentPage;
  AppBarTemp({this.currentPage});

  @override
  _AppBarTempState createState() => _AppBarTempState();
}

class _AppBarTempState extends State<AppBarTemp>{
  final bool notBookmarks = false;
  int duration = 60;
  int flag = 0;
  final textFieldPickup = TextEditingController();
  final textFieldDropOff = TextEditingController();
  String currentPage = "Dashboard";
  bool actionButton = false;

  final GlobalKey<FormState> locKey = GlobalKey<FormState>();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  pagePicker(){
    if(widget.currentPage != null) {
      currentPage = widget.currentPage;
      print(currentPage);
      if (currentPage == "Dashboard") {
        return DashboardLocation();
      }
      else if(currentPage == "Profile"){
        return CustomerProfile();
      }
      else if(currentPage == "Bookmarks"){
        return CourierBookmarks();
      }
      else if(currentPage == "Requests"){
        return MyRequests();
      }
      else if(currentPage == "Community Hub"){
        actionButton = true;
        return CustomerCommunityHub();
      }
      else if(currentPage == "Wallet"){
        return CustomerWallet();
      }
    } else{
      if (currentPage == "Dashboard"){
        return DashboardLocation();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = FirebaseAuth.instance;
    User user = auth.currentUser;
    bool approved = true;

    if(user != null){
      DocumentReference customer = FirebaseFirestore.instance.collection('Customers').doc(user.uid);
      Stream<List<Notifications>> notifList = FirebaseFirestore.instance
          .collection('Notifications')
          .where('Sent To', isEqualTo: customer)
          .snapshots()
          .map(DatabaseService().notifListFromSnapshot);

      return WillPopScope(
        onWillPop: () async {
          print("Back Button pressed");
          return currentPage == "Dashboard" ? false : true;
        },
        child: Scaffold(
            drawerEnableOpenDragGesture: false,
            endDrawerEnableOpenDragGesture: false,
            key: _scaffoldKey,
            appBar: AppBar(
              leading: Stack(
                 children: [
                   IconButton(
                     icon: Icon(Icons.menu, size: 25,), // change this size and style
                     onPressed: () => _scaffoldKey.currentState.openDrawer(),
                   ),
                 ],
              ),
              backgroundColor: Colors.white,
              iconTheme: IconThemeData(
                color: Color(0xfffb0d0d),
              ),
              actions: [
                 StreamProvider<List<Notifications>>.value(
                    value: notifList,
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
            ),
            drawer: MainDrawerCustomer(),
            endDrawer: NotifDrawerCustomer(),
            body: pagePicker(),
            floatingActionButton: Visibility(visible: actionButton,
            child: FloatingActionButton(
              child: Icon(Icons.post_add_rounded),
              onPressed: (){
                Navigator.pushNamed(context, '/customerCreatePost');
              },
            ),
            ),
        ),
      );
    } else return LoginScreen();
  }
}