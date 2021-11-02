import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:proxpress/classes/customer_classes/request_list.dart';
import 'package:proxpress/models/deliveries.dart';
import 'package:proxpress/models/user.dart';
import 'package:proxpress/services/database.dart';
import 'package:proxpress/UI/login_screen.dart';

class MyRequests extends StatefulWidget {
  @override
  _MyRequestsState createState() => _MyRequestsState();
}

class _MyRequestsState extends State<MyRequests> with SingleTickerProviderStateMixin {
  @override
  Widget build(BuildContext context) {
    final user = Provider.of<TheUser>(context);

    if(user != null) {
      Stream<List<Delivery>> deliveryRequestPending = FirebaseFirestore.instance
          .collection('Deliveries')
          .where('Courier Approval', isEqualTo: 'Pending')
          .where('Customer Reference', isEqualTo: FirebaseFirestore.instance.collection('Customers').doc(user.uid))
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
          .where('Customer Reference', isEqualTo: FirebaseFirestore.instance.collection('Customers').doc(user.uid))
          .snapshots()
          .map(DatabaseService().deliveryDataListFromSnapshot);

      // https://stackoverflow.com/questions/54642710/tabbarview-with-dynamic-container-height
      return DefaultTabController(
        length: 4,
        child: NestedScrollView(
          headerSliverBuilder: (context, value) {
            return [
              SliverToBoxAdapter(
                child: TabBar(
                  tabs: [
                    Tab(child: Text("Pending", style: TextStyle(color: Colors.black),)),
                    Tab(child: Text("Ongoing", style: TextStyle(color: Colors.black),)),
                    Tab(child: Text("Finished", style: TextStyle(color: Colors.black),)),
                    Tab(child: Text("Cancelled", style: TextStyle(color: Colors.black),)),
                  ],
                ),
              ),
            ];
          },
          body: Container(
            child: TabBarView(
              children: [
                StreamProvider<List<Delivery>>.value(
                    initialData: [],
                    value: deliveryRequestPending,
                    child: Card(
                      child: RequestList(message: 'You currently have no pending requests.',),
                    )
                ),
                StreamProvider<List<Delivery>>.value(
                  initialData: [],
                  value: deliveryListOngoing,
                  child: Card(
                    child: RequestList(message: 'You currently have no ongoing deliveries.'),
                  ),
                ),
                StreamProvider<List<Delivery>>.value(
                  initialData: [],
                  value: deliveryListDelivered,
                  child: Card(
                    child: RequestList(message: 'You have no finished transactions.'),
                  ),
                ),
                StreamProvider<List<Delivery>>.value(
                  initialData: [],
                  value: deliveryListCancelled,
                  child: Card(
                    child: RequestList(message: 'You have no cancelled transactions.'),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }
    else return LoginScreen();
  }
}
