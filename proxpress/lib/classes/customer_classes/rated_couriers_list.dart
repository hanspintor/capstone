import 'package:proxpress/classes/customer_classes/rated_couriers_tile.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:proxpress/Load/user_load.dart';
import 'package:proxpress/models/deliveries.dart';

class RatedCourierList extends StatefulWidget {
  RatedCourierList({
    Key key,
  }) : super(key: key);

  @override
  _RatedCourierListState createState() => _RatedCourierListState();
}

class _RatedCourierListState extends State<RatedCourierList> {
  @override
  Widget build(BuildContext context) {
    final delivery = Provider.of<List<Delivery>>(context);

    if (delivery.length != 0) {
      return delivery == null ? UserLoading() : ListView.builder(
        itemCount: delivery.length,
        shrinkWrap: true,
        physics: NeverScrollableScrollPhysics(),
        itemBuilder: (context, index) {
          return RatedCourierTile(
            delivery: delivery[index],
          );
        },
      );
    } else {
      return Row(
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Text(
                'You currently have no rated couriers.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 18,
                ),
              ),
            ),
          ),
        ],
      );
    }
  }
}