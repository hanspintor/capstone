import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:expansion_tile_card/expansion_tile_card.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:proxpress/UI/CustomerUI/customer_remarks.dart';
import 'package:proxpress/UI/login_screen.dart';
import 'package:proxpress/models/couriers.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:proxpress/models/deliveries.dart';

class DeliveryTile extends StatefulWidget {
  final Delivery delivery;

  DeliveryTile({
    Key key,
    @required this.delivery,
  }) : super(key: key);


  @override
  _DeliveryTileState createState() => _DeliveryTileState();
}

class _DeliveryTileState extends State<DeliveryTile> {
  @override
  Widget build(BuildContext context) {
    print (widget.delivery.uid);
    final FirebaseAuth _auth = FirebaseAuth.instance;
    User user = _auth.currentUser;
    return user == null
        ? LoginScreen()
        : Padding(
      padding: EdgeInsets.only(top: 0.0),
      child: ExpansionTileCard(
        title: Text("Test", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),),
      ),
    );
  }
}
