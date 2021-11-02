import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:proxpress/UI/login_screen.dart';
import 'package:proxpress/classes/courier_classes/transaction_list.dart';
import 'package:proxpress/models/couriers.dart';
import 'package:proxpress/models/deliveries.dart';
import 'package:proxpress/services/database.dart';
import 'package:proxpress/models/user.dart';
import 'package:provider/provider.dart';

class TransactionHistory extends StatefulWidget {
  @override
  _TransactionHistoryState createState() => _TransactionHistoryState();
}

class _TransactionHistoryState extends State<TransactionHistory> {
  Widget _welcomeMessage(String adminMessage){
    return Column(
      children: [
        Container(
          margin: EdgeInsets.fromLTRB(20, 40, 20, 0),
          child: Align(
            child: Text(adminMessage,
              textAlign: TextAlign.justify,
              style: TextStyle(
                fontSize: 20,
              ),
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<TheUser>(context);

    Stream<List<Delivery>> deliveryListEarnings = FirebaseFirestore.instance
        .collection('Deliveries')
        .where('Delivery Status', isEqualTo: 'Delivered')
        .where('Courier Reference', isEqualTo: FirebaseFirestore.instance.collection('Couriers').doc(user.uid))
        .snapshots()
        .map(DatabaseService().deliveryDataListFromSnapshot);

    Stream<List<Delivery>> deliveryListFinished = FirebaseFirestore.instance
        .collection('Deliveries')
        .where('Delivery Status', isEqualTo: 'Delivered')
        .where('Courier Reference', isEqualTo: FirebaseFirestore.instance.collection('Couriers').doc(user.uid))
        .snapshots()
        .map(DatabaseService().deliveryDataListFromSnapshot);

    Stream<List<Delivery>> deliveryListCancelled = FirebaseFirestore.instance
        .collection('Deliveries')
        .where('Delivery Status', isEqualTo: 'Cancelled')
        .where('Courier Reference', isEqualTo: FirebaseFirestore.instance.collection('Couriers').doc(user.uid))
        .snapshots()
        .map(DatabaseService().deliveryDataListFromSnapshot);

    return user == null ? LoginScreen() : StreamBuilder<Courier>(
      stream: DatabaseService(uid: user.uid).courierData,
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          Courier courier = snapshot.data;

          return !courier.approved ? _welcomeMessage(courier.adminMessage) : DefaultTabController(
            length: 2,
            child: NestedScrollView(
              headerSliverBuilder: (context, value) {
                return [
                  SliverToBoxAdapter(
                    child: StreamBuilder<List<Delivery>>(
                      stream: deliveryListEarnings,
                      builder: (context, snapshot) {
                        if (snapshot.hasData) {
                          List<Delivery> deliveries = snapshot.data;

                          int earnings = 0;

                          deliveries.forEach((element) {earnings += element.deliveryFee;});

                          return ListTile(
                            title: Text('Total Earnings', style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold)),
                            trailing: Text("\₱${earnings}", style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold, color: Colors.black)
                            ),
                          );
                        } else {
                          return Container();
                        }
                      },
                    ),
                  ),
                  SliverToBoxAdapter(
                    child: TabBar(
                      tabs: [
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
                        value: deliveryListFinished,
                        child: Card(
                          child: TransactionList(message: 'You currently have no finished transaction.', index: 0),
                        )
                    ),
                    StreamProvider<List<Delivery>>.value(
                      initialData: [],
                      value: deliveryListCancelled,
                      child: Card(
                        child: TransactionList(message: 'You currently have no cancelled transaction.', index: 1),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        } else {
          return Container();
        }
      }
    );
  }
}
