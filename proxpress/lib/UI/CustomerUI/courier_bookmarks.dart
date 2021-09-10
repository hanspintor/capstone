import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:proxpress/UI/login_screen.dart';
import 'package:proxpress/models/couriers.dart';
import 'package:proxpress/services/auth.dart';
import 'package:proxpress/services/database.dart';
import 'menu_drawer_customer.dart';
import 'notif_drawer_customer.dart';
import 'package:proxpress/classes/courier_list.dart';
class CourierBookmarks extends StatefulWidget {
  @override
  _CourierBookmarksState createState() => _CourierBookmarksState();
}

class _CourierBookmarksState extends State<CourierBookmarks> {

  void _openEndDrawer() {
    _scaffoldKey.currentState.openEndDrawer();
  }

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final AuthService _auth = AuthService();
  static Timer _sessionTimer;
  static Timer _sessionTimerPrint;
  int count = 0;
  int duration = 1;
  void handleTimeOut() async{
    await _auth.signOut();
  }
  @override
  Widget build(BuildContext context) {
    final FirebaseAuth _auth = FirebaseAuth.instance;
    User user = _auth.currentUser;
      return new GestureDetector(
        onTap: (){
          if(count != 0){
            print("Session Revived");
          } else {
            print("Session Started");
            count=1;
          }
          _sessionTimer?.cancel();
          _sessionTimer = new Timer(Duration(minutes: duration), handleTimeOut);
          _sessionTimerPrint?.cancel();
          _sessionTimerPrint = new Timer(Duration(minutes: duration), () {
            print("Session Expired");
          });

        },
        child: user == null ? LoginScreen():StreamProvider<List<Courier>>.value(
          value: DatabaseService().courierList,
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
                  IconButton(
                    icon: Icon(
                      Icons.notifications_none_rounded,
                    ),
                    onPressed: () {
                      _openEndDrawer();
                    },
                    iconSize: 25,
                  ),
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
                        child:  Text(
                            "Bookmarked Couriers",
                            style: TextStyle(
                              fontSize: 25,
                            ),
                          ),
                        ),
                      Container(
                        margin: EdgeInsets.only(
                            top: 10, bottom: 10, left: 100, right: 100),
                        child: TextFormField(
                          decoration: InputDecoration(
                              labelText: 'Search',
                              prefixIcon: Icon(Icons.search_rounded)),
                        ),
                      ),
                      //CourierList(),
                    ],
                  ),
                ),
              )),
        ),
      );
  }
}
