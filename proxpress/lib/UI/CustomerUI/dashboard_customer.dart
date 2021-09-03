import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:proxpress/classes/courier_list.dart';
import 'package:proxpress/models/couriers.dart';
import 'package:proxpress/services/auth.dart';
import 'package:proxpress/services/database.dart';

class DashboardCustomer extends StatefulWidget{
  @override
  _DashboardCustomerState createState() => _DashboardCustomerState();
}


class _DashboardCustomerState extends State<DashboardCustomer> {

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  TextEditingController _searchController = TextEditingController();
  final AuthService _auth = AuthService();
  static Timer _sessionTimer;
  static Timer _sessionTimerPrint;
  int count = 0;
  int duration = 1;
  void handleTimeOut() async{
    await _auth.signOut();
  }
  Widget build(BuildContext context) {
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
      child: StreamProvider<List<Courier>>.value(
        value: DatabaseService().courierList,
        initialData: [],
        child: Scaffold(
            drawerEnableOpenDragGesture: false,
            endDrawerEnableOpenDragGesture: false,
            key:_scaffoldKey,
            appBar: AppBar(
              backgroundColor: Colors.white,
              iconTheme: IconThemeData(color: Color(0xfffb0d0d),),
              actions: [
                IconButton(icon: Icon(
                  Icons.help_outline,
                ),
                  onPressed: (){
                    showDialog(
                      context: context,
                      builder: (BuildContext context){
                        return AlertDialog(
                          title: Text("Help"),
                          content: Text('nice'),
                          actions: [
                            TextButton(
                              child: Text("OK"),
                              onPressed: () {
                                Navigator.of(context).pop();
                              },
                            ),
                          ],
                        );
                      }
                    );
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
            body: SingleChildScrollView(
              child: Center(
                child: Column(
                  children: [
                    SizedBox(height: 10),
                    Align(
                      alignment: Alignment.bottomCenter,
                      child: Text(
                        "Couriers Available",
                        style: TextStyle(
                          fontSize: 25,
                        ),
                      ),
                    ),
                    Card(
                      margin: EdgeInsets.all(20),
                      child: Column(
                        children: [
                          Container(
                            margin: EdgeInsets.only(top: 25),
                            child: SizedBox(
                              height: 40,
                              width: 250,
                              child: TextField(
                                controller: _searchController,
                                decoration: InputDecoration(
                                    hintText: 'Search',
                                    hintStyle: TextStyle(
                                      fontSize: 16.0,
                                      color: Colors.black54,
                                    ),
                                    contentPadding: EdgeInsets.all(10.0),
                                    prefixIcon: Icon(Icons.search_rounded),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(20.0),
                                    borderSide: BorderSide(
                                        color: Colors.grey,
                                        width: 2.0,

                                    ),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(20.0),
                                    borderSide: BorderSide(
                                      color: Colors.redAccent,
                                      width: 2.0,

                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          CourierList(),
                        ],
                      ),
                    shadowColor: Colors.black,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(10))),
                    ),
                  ],
                ),
              ),
            )
        ),
      ),
    );
  }
}