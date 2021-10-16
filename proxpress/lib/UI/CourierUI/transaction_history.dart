import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:proxpress/classes/courier_classes/transaction_list.dart';
import 'package:proxpress/models/deliveries.dart';
import 'package:proxpress/services/database.dart';
import 'package:proxpress/models/user.dart';
import 'package:provider/provider.dart';

class TransactionHistory extends StatefulWidget {
  @override
  _TransactionHistoryState createState() => _TransactionHistoryState();
}

class _TransactionHistoryState extends State<TransactionHistory> {
  @override
  Widget build(BuildContext context) {
    final user = Provider.of<TheUser>(context);

    Stream<List<Delivery>> deliveryList = FirebaseFirestore.instance
        .collection('Deliveries')
        .where('Delivery Status', isEqualTo: 'Delivered')
        .where('Courier Reference', isEqualTo: FirebaseFirestore.instance.collection('Couriers').doc(user.uid))
        .snapshots()
        .map(DatabaseService().deliveryDataListFromSnapshot);

    return StreamProvider<List<Delivery>>.value(
      initialData: [],
      value: deliveryList,
      child: SingleChildScrollView(
        child: Center(
          child: Column(
            children: [
              SizedBox(height: 10),
              Align(
                alignment: Alignment.bottomCenter,
                child: Text("Transaction History",
                  style: TextStyle(
                    fontSize: 25,
                  ),
                ),
              ),
              TransactionList(),

            ],
          ),
        ),
      ),
    );
  }
}
