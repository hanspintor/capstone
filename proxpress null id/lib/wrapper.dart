import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:proxpress/Load/user_load.dart';
import 'package:proxpress/UI/CustomerUI/dashboard_location.dart';
import 'package:proxpress/UI/login_screen.dart';
import 'package:proxpress/UI/CourierUI/courier_dashboard.dart';
import 'package:proxpress/models/user.dart';
import 'package:proxpress/authenticate.dart';

class Wrapper extends StatelessWidget {

  bool isCustomer;
  Wrapper({this.isCustomer});

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<TheUser>(context);


    if (user != null) {
      print("Customer Wrapper: $isCustomer");
      if(isCustomer){
        return DashboardLocation();
      } else {
        return CourierDashboard();
      }
    } else {
      return Authenticate();
    }
  }
}
