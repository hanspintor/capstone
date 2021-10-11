import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:proxpress/courier_tile.dart';
import 'package:proxpress/couriers.dart';

class CourierList extends StatefulWidget {
  final String savedPassword;
  CourierList({this.savedPassword});

  @override
  _CourierListState createState() => _CourierListState();
}

class _CourierListState extends State<CourierList> {
  @override
  Widget build(BuildContext context) {
    final courier = Provider.of<List<Courier>>(context);

    if (courier != null && courier.length > 0) {
      return SizedBox(
        child: ListView.builder(
          shrinkWrap: true,
          itemBuilder: (context, index) {
            return CourierTile(courier: courier[index], savedPassword: widget.savedPassword,);
          },
          itemCount: courier.length,
        ),
      );
    } else return Container();
  }
}
