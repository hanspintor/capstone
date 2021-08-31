import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:proxpress/Load/user_load.dart';
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
    return courier == null ? UserLoading() : SingleChildScrollView(
      child: SizedBox(
        height: 650,
        child: ListView.builder(
            itemCount: courier.length,
            itemBuilder: (context, index) {
              return CourierTile(courier: courier[index]);
            },
        ),
      ),
    );
  }
}
