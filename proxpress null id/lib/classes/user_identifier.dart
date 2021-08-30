import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:proxpress/authenticate.dart';
import 'package:proxpress/models/user.dart';
import 'package:proxpress/services/auth.dart';
import 'package:proxpress/wrapper.dart';


final FirebaseAuth _auth = FirebaseAuth.instance;
User user = _auth.currentUser;

bool isCustomer = false;
StreamSubscription<DocumentSnapshot> subscription;

class UserIdentifier extends StatefulWidget {

  @override
  _UserIdentifierState createState() => _UserIdentifierState();
}

class _UserIdentifierState extends State<UserIdentifier> {

  //final FirebaseAuth _auth = FirebaseAuth.instance;
  //final AuthService _auth = AuthService();
  final TheUser identifier = TheUser();

  // Future<bool> identify(bool isCustomer) async{
  //   return isCustomer = await identifier.UserIdentifier(isCustomer);
  // }
  void initState(){
    super.initState();

    if(user.uid != null){
      final DocumentReference documentReference =
      FirebaseFirestore.instance.collection('Customers').doc(user.uid);
      print("trip lang");
      subscription = documentReference.snapshots().listen((datasnapshot) {
        if(datasnapshot.exists){
          setState(() {
            isCustomer = true;
          });
        } else if(!datasnapshot.exists){
          setState(() {
            isCustomer = false;
          });
        }
      });
    }else {

      Authenticate();
    }
  }
  @override
  Widget build(BuildContext context) {

    print("hi");
    //identify(isCustomer);
    // final user = Provider.of<TheUser>(context);
    // print("user id is ${user.uid}");
    //
    // FirebaseFirestore.instance
    //     .collection('Customers')
    //     .doc(user.uid)
    //     .get()
    //     .then((DocumentSnapshot documentSnapshot) {
    //   if (documentSnapshot.exists) {
    //     // customer = true; pass data to wrapper
    //     setState(() {
    //       isCustomer = true;
    //     });
    //     print('Document data: ${documentSnapshot.data()}');
    //     print('customer document found');
    //     //Navigator.pushNamed(context, '/dashboardLocation');
    //   } else {
    //     setState(() {
    //       isCustomer = false;
    //     });
    //     // customer = false; pass data to wrapper
    //     print('no customer document found');
    //     //.pushNamed(context, '/courierDashboard');
    //   }
    // });
    print("Customer Identifier: $isCustomer");
    return Wrapper(isCustomer: isCustomer);

  }
}
