import 'package:proxpress/Load/user_load.dart';
import 'package:proxpress/UI/dashboard_location.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:proxpress/models/user.dart';
import 'package:proxpress/authenticate.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'courier_UI/courier_dashboard.dart';

class Wrapper extends StatefulWidget {
  @override
  State<Wrapper> createState() => _WrapperState();
}

class _WrapperState extends State<Wrapper> {
  int _userType = 0;

  void _userTypeCustomer() {
    setState(() {
      _userType = 1;
    });
    print('user is customer');
  }

  void _userTypeCourier() {
    setState(() {
      _userType = 2;
    });
    print('user is courier');
  }

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
          _userTypeCustomer();
        } else {
          print('no customer document found');
        }
      });

      FirebaseFirestore.instance
          .collection('Couriers')
          .doc(user.uid)
          .get()
          .then((DocumentSnapshot documentSnapshot) {
        if (documentSnapshot.exists) {
          print('Document data: ${documentSnapshot.data()}');
          _userTypeCourier();
        } else {
          print('no courier document found');
        }
      });

      print(_userType);
      if (_userType == 1) {
        return DashboardLocation();
      } else if (_userType == 2) {
        return CourierDashboard();
      } else {
        return UserLoading();
      }
    } else {
      return Authenticate();
    }
  }
}