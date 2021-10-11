import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:proxpress/courier_list.dart';
import 'package:proxpress/couriers.dart';
import 'package:proxpress/database.dart';
import 'package:proxpress/delivery_price_list.dart';
import 'package:proxpress/delivery_prices.dart';
import 'package:proxpress/login_screen.dart';
import 'package:proxpress/report_list.dart';
import 'package:proxpress/reports.dart';

import 'auth.dart';

class Dashboard extends StatefulWidget {
  final String savedPassword;
  Dashboard({this.savedPassword});

  @override
  _DashboardState createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> with SingleTickerProviderStateMixin {
  final AuthService _auth = AuthService();
  int activeTab = 0;

  @override
  Widget build(BuildContext context) {
    final FirebaseAuth auth = FirebaseAuth.instance;
    final User user = auth.currentUser;

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.black,
        title: Text("PROExpress Admin"),
        actions: [
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              primary: Colors.black,
            ),
            onPressed: () async {
              print(user.uid);
              if (user != null) {
                await _auth.signOut();
              }
              Navigator.push(context, MaterialPageRoute(builder: (context) => LoginScreen()));
            },
            icon: Icon(Icons.logout_rounded),
            label: Text('Logout')),
        ],
      ),
      body: DefaultTabController(
        length: 3,
        child: NestedScrollView(
          headerSliverBuilder: (context, value) {
            return [
              SliverToBoxAdapter(
                child: TabBar(
                  indicator: BoxDecoration(color: Colors.black),
                  onTap: (index) => setState(() => activeTab = index),
                  tabs: [
                    Tab(child: Text("Couriers", style: TextStyle(color: activeTab == 0 ? Colors.white : Colors.black),)),
                    Tab(child: Text("Delivery Prices", style: TextStyle(color: activeTab == 1 ? Colors.white : Colors.black),)),
                    Tab(child: Text("Reports", style: TextStyle(color: activeTab == 2 ? Colors.white : Colors.black),)),
                  ],
                ),
              ),
            ];
          },
          body: Container(
            child: TabBarView(
              children: [
                StreamProvider<List<Courier>>.value(
                  value: DatabaseService().courierList,
                  initialData: [],
                  child: Column(
                    children: [
                      Container(
                        margin: EdgeInsets.fromLTRB(10, 10, 10, 0),
                        child: Table(
                          border: TableBorder.all(),
                          children: [
                            TableRow(
                              children: [
                                Align(alignment: Alignment.center,child: Text('Name', style: TextStyle(fontWeight: FontWeight.bold),)),
                                Align(alignment: Alignment.center,child: Text('Address', style: TextStyle(fontWeight: FontWeight.bold),)),
                                Align(alignment: Alignment.center,child: Text('Email', style: TextStyle(fontWeight: FontWeight.bold),)),
                                Align(alignment: Alignment.center,child: Text('Contact Number', style: TextStyle(fontWeight: FontWeight.bold),)),
                                Align(alignment: Alignment.center,child: Text('Vehicle Type', style: TextStyle(fontWeight: FontWeight.bold),)),
                                Align(alignment: Alignment.center,child: Text('Vehicle Color', style: TextStyle(fontWeight: FontWeight.bold),)),
                                Align(alignment: Alignment.center,child: Text('Credentials', style: TextStyle(fontWeight: FontWeight.bold),)),
                                Align(alignment: Alignment.center,child: Text('Commands', style: TextStyle(fontWeight: FontWeight.bold),)),
                              ],
                            ),
                          ],
                        ),
                      ),
                      CourierList(savedPassword: widget.savedPassword,),
                    ],
                  ),
                ),
                StreamProvider<List<DeliveryPrice>>.value(
                  value: DatabaseService().deliveryPriceList,
                  initialData: [],
                  child: Column(
                    children: [
                      Container(
                        margin: EdgeInsets.fromLTRB(10, 10, 10, 0),
                        child: Table(
                          border: TableBorder.all(),
                          children: [
                            TableRow(
                              children: [
                                Align(alignment: Alignment.center,child: Text('Vehicle Type', style: TextStyle(fontWeight: FontWeight.bold),)),
                                Align(alignment: Alignment.center,child: Text('Base Fare', style: TextStyle(fontWeight: FontWeight.bold),)),
                                Align(alignment: Alignment.center,child: Text('Fare Per KM', style: TextStyle(fontWeight: FontWeight.bold),)),
                                Align(alignment: Alignment.center,child: Text('Commands', style: TextStyle(fontWeight: FontWeight.bold),)),
                              ],
                            ),
                          ],
                        ),
                      ),
                      DeliveryPriceList(),
                    ],
                  ),
                ),
                StreamProvider<List<Reports>>.value(
                  value: DatabaseService().reportList,
                  initialData: [],
                  child: Column(
                    children: [
                      Container(
                        margin: EdgeInsets.fromLTRB(10, 10, 10, 0),
                        child: Table(
                          border: TableBorder.all(),
                          children: [
                            TableRow(
                              children: [
                                Align(alignment: Alignment.center,child: Text('Report No.', style: TextStyle(fontWeight: FontWeight.bold),)),
                                Align(alignment: Alignment.center,child: Text('Customer Name', style: TextStyle(fontWeight: FontWeight.bold),)),
                                Align(alignment: Alignment.center,child: Text('Courier Name', style: TextStyle(fontWeight: FontWeight.bold),)),
                                Align(alignment: Alignment.center,child: Text('Complaint', style: TextStyle(fontWeight: FontWeight.bold),)),
                                Align(alignment: Alignment.center,child: Text('Time Reported', style: TextStyle(fontWeight: FontWeight.bold),)),

                              ],
                            ),
                          ],
                        ),
                      ),
                      ReportList(),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
