import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:proxpress/UI/login_screen.dart';
import 'package:proxpress/classes/courier_tile.dart';
import 'package:proxpress/models/couriers.dart';

class CourierList extends StatefulWidget {

  @override
  _CourierListState createState() => _CourierListState();
}

class _CourierListState extends State<CourierList> {
  @override
  Widget build(BuildContext context) {
    final courier = Provider.of<List<Courier>>(context);
    final FirebaseAuth _auth = FirebaseAuth.instance;
    User user = _auth.currentUser;
    print(courier.length);
    return user == null ? LoginScreen() : SingleChildScrollView(
      child: SizedBox(
        height: 600,
        child: ListView.builder(
            itemCount: courier.length,
            itemBuilder: (context, index) {
              return CourierTile(courier: courier[index]);
            },
        ),
      ),
    );
    return Container();
  }
}
