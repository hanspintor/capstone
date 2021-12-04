import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:proxpress/UI/login_screen.dart';
import 'package:proxpress/classes/customer_classes/courier_bookmarks_tile.dart';
import 'package:proxpress/models/couriers.dart';
import 'package:proxpress/services/database.dart';

class ratedCouriers extends StatefulWidget {
  @override
  _ratedCouriersState createState() => _ratedCouriersState();
}

class _ratedCouriersState extends State<ratedCouriers> {
  String deliveryPriceUid;
  double deliveryFee = 0.0;
  bool notBookmarks = true;
  final GlobalKey<FormState> locKey = GlobalKey<FormState>();
  final textFieldPickup = TextEditingController();
  final textFieldDropOff = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final FirebaseAuth _auth = FirebaseAuth.instance;
    User user = _auth.currentUser;

    return user == null ? LoginScreen() : StreamProvider<List<Courier>>.value(
      initialData: [],
      value: DatabaseService().courierList,
      child: SingleChildScrollView(
        child: Center(
          child: Column(
            children: [
              SizedBox(height: 20),
              Align(
                alignment: Alignment.bottomCenter,
                child:  Text(
                  "Rated Couriers",
                  style: TextStyle(
                    fontSize: 25,
                  ),
                ),
              ),

            ],
          ),
        ),
      ),
    );
  }
}