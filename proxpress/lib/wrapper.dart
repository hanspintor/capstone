import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:proxpress/Load/user_load.dart';
import 'package:proxpress/models/user.dart';
import 'package:proxpress/authenticate.dart';
import 'package:proxpress/services/database.dart';

class Wrapper extends StatelessWidget {
  int count = 0;
  String status = "Active";

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
          print('customer document found');

          print("Customer $count");
          if(count <= 0) {
            Navigator.pushNamed(context, '/template');
            count++;
          }
        } else {
          print('no customer document found');
          print("Courier $count");
          DatabaseService(uid: user.uid).updateStatus(status);
          if(count <= 0) {
            Navigator.pushNamed(context, '/template1');
            count++;
          }
        }
      });
      return UserLoading();
    } else {
      count = 0;
      return Authenticate();
    }
  }
}