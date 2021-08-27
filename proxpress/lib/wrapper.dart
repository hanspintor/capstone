import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:proxpress/UI/CustomerUI/dashboard_location.dart';
import 'package:proxpress/UI/login_screen.dart';
import 'package:proxpress/UI/CourierUI/courier_dashboard.dart';
import 'package:proxpress/models/user.dart';
import 'package:proxpress/authenticate.dart';

class Wrapper extends StatelessWidget{
  @override
  Widget build(BuildContext context) {
    final user = Provider.of<TheUser>(context);
    bool isCustomer = true;
    bool isCourier = true;
    if(user != null){
      print("user id is ${user.uid}");
      FirebaseFirestore.instance
          .collection('Customers')
          .doc(user.uid)
          .get()
          .then((DocumentSnapshot documentSnapshot) {
            isCustomer=documentSnapshot.exists;
            print("Customer: $isCustomer");
        if (isCustomer) {
          //isCustomer = false;
          //print("Customer: $isCustomer");
          print('Document data: ${documentSnapshot.data()}');
          print('customer document found');
          //Navigator.pushNamed(context, '/dashboardLocation');

        } else {
          //print("Customer: $isCustomer");
          print('no customer document found');
        }
      });

      FirebaseFirestore.instance
          .collection('Couriers')
          .doc(user.uid)
          .get()
          .then((DocumentSnapshot documentSnapshot) {
            isCourier = documentSnapshot.exists;
            print("Customer: $isCustomer");
        if (isCourier) {
          //isCustomer = false;
          //print("Courier: $isCourier");
          print('Document data: ${documentSnapshot.data()}');
          print('courier document found');
          //Navigator.pushNamed(context, '/courierDashboard');

        } else {
          //print("Courier: $isCourier");
          print('no courier document found');
        }
      });
      print("Customer2: $isCustomer");
      print("Courier2: $isCourier");
      if(isCustomer){
        return DashboardLocation();
      } else if(isCourier){
        return CourierDashboard();
      }
    } else{
      return Authenticate();
    }
  }
}