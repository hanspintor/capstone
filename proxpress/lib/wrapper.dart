import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:proxpress/Load/load_screen.dart';
import 'package:proxpress/Load/user_load.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:proxpress/UI/dashboard_location.dart';
import 'package:proxpress/UI/login_screen.dart';
import 'package:proxpress/courier_UI/courier_dashboard.dart';
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
            isCustomer =documentSnapshot.exists;
        if (isCustomer) {
          print('Document data: ${documentSnapshot.data()}');
          print('customer document found');
          //Navigator.pushNamed(context, '/dashboardLocation');

        } else {
          print('no customer document found');
          if(!isCourier){
            return LoginScreen();
          }
        }
      });

      FirebaseFirestore.instance
          .collection('Couriers')
          .doc(user.uid)
          .get()
          .then((DocumentSnapshot documentSnapshot) {
            isCourier = documentSnapshot.exists;
        if (isCourier) {
          print('Document data: ${documentSnapshot.data()}');
          print('courier document found');
          //Navigator.pushNamed(context, '/courierDashboard');

        } else {
          print('no courier document found');
        }
      });
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