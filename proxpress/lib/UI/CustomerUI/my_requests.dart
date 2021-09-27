import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:proxpress/Load/user_load.dart';
import 'package:proxpress/UI/CourierUI/menu_drawer_courier.dart';
import 'package:proxpress/UI/CourierUI/notif_drawer_courier.dart';
import 'package:proxpress/UI/CustomerUI/menu_drawer_customer.dart';
import 'package:proxpress/UI/CustomerUI/notif_drawer_customer.dart';
import 'package:proxpress/UI/CustomerUI/pending_delivery_request.dart';
import 'package:proxpress/classes/courier_classes/delivery_list.dart';
import 'package:proxpress/classes/courier_classes/delivery_tile.dart';
import 'package:proxpress/classes/courier_classes/notif_counter_courier.dart';
import 'package:proxpress/classes/customer_classes/notif_counter_customer.dart';
import 'package:proxpress/classes/customer_classes/request_list.dart';
import 'package:proxpress/models/couriers.dart';
import 'package:proxpress/models/customers.dart';
import 'package:proxpress/models/deliveries.dart';
import 'package:proxpress/models/user.dart';
import 'package:proxpress/services/database.dart';

import '../login_screen.dart';

class MyRequests extends StatefulWidget {
  @override
  _MyRequestsState createState() => _MyRequestsState();
}

class _MyRequestsState extends State<MyRequests> {

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<TheUser>(context);
    bool approved = true;
    if(user != null) {
      return StreamBuilder<Customer>(
          stream: DatabaseService(uid: user.uid).customerData,
          builder: (context,snapshot){
            if(snapshot.hasData){
              Customer customerData = snapshot.data;

              Stream<List<Delivery>> deliveryList = FirebaseFirestore.instance
                  .collection('Deliveries')
                  .where('Customer Reference', isEqualTo: FirebaseFirestore.instance.collection('Customers').doc(user.uid))
                  .snapshots()
                  .map(DatabaseService().deliveryDataListFromSnapshot);

              Stream<List<Delivery>> deliveryRequestPending = FirebaseFirestore.instance
                  .collection('Deliveries')
                  .where('Courier Approval', isEqualTo: 'Pending')
                  .where('Customer Reference', isEqualTo: FirebaseFirestore.instance.collection('Customers').doc(user.uid))
                  .limit(1)
                  .snapshots()
                  .map(DatabaseService().deliveryDataListFromSnapshot);

              Stream<List<Delivery>> deliveryListOngoing = FirebaseFirestore.instance
                  .collection('Deliveries')
                  .where('Delivery Status', isEqualTo: 'Ongoing')
                  .where('Customer Reference', isEqualTo: FirebaseFirestore.instance.collection('Customers').doc(user.uid))
                  .snapshots()
                  .map(DatabaseService().deliveryDataListFromSnapshot);

              Stream<List<Delivery>> deliveryListDelivered = FirebaseFirestore.instance
                  .collection('Deliveries')
                  .where('Delivery Status', isEqualTo: 'Delivered')
                  .where('Customer Reference', isEqualTo: FirebaseFirestore.instance.collection('Customers').doc(user.uid))
                  .snapshots()
                  .map(DatabaseService().deliveryDataListFromSnapshot);

              Stream<List<Delivery>> deliveryListCancelled = FirebaseFirestore.instance
                  .collection('Deliveries')
                  .where('Delivery Status', isEqualTo: 'Cancelled')
                  .where('Courier Approval', isEqualTo: 'Cancelled')
                  .where('Customer Reference', isEqualTo: FirebaseFirestore.instance.collection('Customers').doc(user.uid))
                  .snapshots()
                  .map(DatabaseService().deliveryDataListFromSnapshot);

              return WillPopScope(
                  onWillPop: () async {
                    print("Back Button Pressed");
                    return false;
                  },
                  child: DefaultTabController(
                    length: 4,
                    child: Scaffold(
                      drawerEnableOpenDragGesture: false,
                      endDrawerEnableOpenDragGesture: false,
                      key: _scaffoldKey,
                      appBar: AppBar(
                        backgroundColor: Colors.white,
                        iconTheme: IconThemeData(color: Color(0xfffb0d0d)
                        ),
                        actions: <Widget>[
                          StreamProvider<List<Delivery>>.value(
                              value: deliveryList,
                              initialData: [],
                              child: NotifCounterCustomer(scaffoldKey: _scaffoldKey, approved: approved,)
                          )
                          //NotifCounter(scaffoldKey: _scaffoldKey,approved: approved,)
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
                      body: SingleChildScrollView(
                        child: Center(
                          child: Column(
                            children: [
                              TabBar(
                                tabs: [
                                  Tab(child: Text("Pending", style: TextStyle(color: Colors.black),)),
                                  Tab(child: Text("Ongoing", style: TextStyle(color: Colors.black),)),
                                  Tab(child: Text("Finished", style: TextStyle(color: Colors.black),)),
                                  Tab(child: Text("Cancelled", style: TextStyle(color: Colors.black),)),
                                ],
                              ),
                              SizedBox(
                                height: 560,
                                child: TabBarView(
                                    children: [
                                      SingleChildScrollView(
                                        child: StreamProvider<List<Delivery>>.value(
                                          initialData: [],
                                          value: deliveryRequestPending,
                                          child: Card(
                                            child: RequestList(message: 'You currently have no pending requests.',),
                                          ),
                                        ),
                                      ),
                                      SingleChildScrollView(
                                        child: StreamProvider<List<Delivery>>.value(
                                          initialData: [],
                                          value: deliveryListDelivered,
                                          child: Card(
                                            child: RequestList(message: 'You currently have no ongoing deliveries.'),
                                          ),
                                        ),
                                      ),
                                      SingleChildScrollView(
                                        child: StreamProvider<List<Delivery>>.value(
                                          initialData: [],
                                          value: deliveryListOngoing,
                                          child: Card(
                                            child: RequestList(message: 'You have no finished transactions.'),
                                          ),
                                        ),
                                      ),
                                      SingleChildScrollView(
                                        child: StreamProvider<List<Delivery>>.value(
                                          initialData: [],
                                          value: deliveryListCancelled,
                                          child: Card(
                                            child: RequestList(message: 'You have no cancelled transactions.'),
                                          ),
                                        ),
                                      ),
                                    ]
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  )
              );
            } else {
              return UserLoading();
            }
          }
      );
    }
    else return LoginScreen();
  }
}
