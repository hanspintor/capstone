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
  @override
  Widget build(BuildContext context) {
    final user = Provider.of<TheUser>(context);

    if (user != null) {
      print("user id is ${user.uid}");

      FirebaseFirestore.instance
          .collection('Customers')
          .doc(user.uid)
          .get()
          .then((DocumentSnapshot documentSnapshot) {
        if (documentSnapshot.exists) {
          print('Document data: ${documentSnapshot.data()}');
          print('customer document found');
          Navigator.pushNamed(context, '/dashboardLocation');
        } else {
          print('no customer document found');
          Navigator.pushNamed(context, '/courierDashboard');
        }
      });

      return UserLoading();
    } else {
      return Authenticate();
    }
  }
}
