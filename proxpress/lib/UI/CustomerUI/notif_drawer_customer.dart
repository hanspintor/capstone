import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:proxpress/Load/user_load.dart';
import 'package:proxpress/UI/CustomerUI/dashboard_location.dart';
import 'package:proxpress/classes/customer_classes/notif_list_customer.dart';
import 'package:proxpress/models/couriers.dart';
import 'package:proxpress/models/customers.dart';
import 'package:proxpress/models/deliveries.dart';
import 'package:proxpress/models/user.dart';
import 'package:proxpress/services/database.dart';
import '../login_screen.dart';

class NotifDrawerCustomer extends StatefulWidget {


  @override
  _NotifDrawerCustomerState createState() => _NotifDrawerCustomerState();
}

class _NotifDrawerCustomerState extends State<NotifDrawerCustomer>{
  bool isClear = false;
  String caption = "";
  int flag = 1;
  @override
  Widget build(BuildContext context) {
    bool approved = false;
    final user = Provider.of<TheUser>(context);
    if(flag <= 0){
      isClear = true;
      caption = "No data found";
      flag++;
    }

    return user == null ? LoginScreen() : StreamBuilder<Customer>(
      stream: DatabaseService(uid: user.uid).customerData,
      builder: (context, snapshot){
        if(snapshot.hasData){
          Customer customerData = snapshot.data;

          Stream<List<Delivery>> deliveryList = FirebaseFirestore.instance
              .collection('Deliveries')
              .where('Customer Reference', isEqualTo: FirebaseFirestore.instance.collection('Customers').doc(user.uid))
              .snapshots()
              .map(DatabaseService().deliveryDataListFromSnapshot);

          return approved ? DashboardLocation() : StreamProvider<List<Delivery>>.value(
            value: deliveryList,
            initialData: [],
            child: Drawer(
              child: Column(
                  mainAxisSize : MainAxisSize.max,
                  children: [
                    Expanded(
                      child: !isClear ? NotifListCustomer() : Container(),
                    ),
                    isClear ? Container(
                      height: MediaQuery.of(context).size.height / 2,
                      child: Text(
                        caption,
                        style: TextStyle(

                        ),
                      ),
                    ) : Container(),
                    Container(
                      height: MediaQuery.of(context).size.height / 20,
                      width: MediaQuery.of(context).size.width / 1,
                      child: ElevatedButton.icon(
                        icon: Icon(Icons.clear),
                        label: Text('Clear'),
                        onPressed: (){
                          setState(() {
                            flag = 0;
                          });
                        },
                        style: ElevatedButton.styleFrom(primary: Color(0xfffb0d0d), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(0)),),
                      ),
                    ),
                  ]
              ),
            ),
          );
        } else {
          return Text('asdf');
        }
      },
    );
  }
}
