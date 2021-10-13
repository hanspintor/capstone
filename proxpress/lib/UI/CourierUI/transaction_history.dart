import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:proxpress/UI/CourierUI/menu_drawer_courier.dart';
import 'package:proxpress/UI/CourierUI/notif_drawer_courier.dart';
import 'package:proxpress/classes/courier_classes/delivery_list.dart';
import 'package:proxpress/classes/courier_classes/notif_counter_courier.dart';
import 'package:proxpress/classes/courier_classes/transaction_list.dart';
import 'package:proxpress/models/couriers.dart';
import 'package:proxpress/Load/user_load.dart';
import 'package:proxpress/UI/login_screen.dart';
import 'package:proxpress/models/deliveries.dart';
import 'package:proxpress/services/database.dart';
import 'package:proxpress/models/user.dart';
import 'package:provider/provider.dart';

class TransactionHistory extends StatefulWidget {
  @override
  _TransactionHistoryState createState() => _TransactionHistoryState();
}

class _TransactionHistoryState extends State<TransactionHistory> {

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<TheUser>(context);

      return StreamBuilder<Courier>(
          stream: DatabaseService(uid: user.uid).courierData,
          builder: (context,snapshot){
            if(snapshot.hasData){
              Courier courierData = snapshot.data;
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
            } else {
              return UserLoading();
            }
          }
      );
  }
}
