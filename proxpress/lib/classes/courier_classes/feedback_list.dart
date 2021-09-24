import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:proxpress/Load/user_load.dart';
import 'package:proxpress/classes/courier_classes/feedback_tile.dart';
import 'package:proxpress/classes/courier_classes/transaction_tile.dart';
import 'package:proxpress/models/deliveries.dart';

class FeedbackList extends StatefulWidget {

  @override
  _FeedbackListState createState() => _FeedbackListState();
}

class _FeedbackListState extends State<FeedbackList> {
  @override
  Widget build(BuildContext context) {
    final delivery = Provider.of<List<Delivery>>(context);

    return delivery == null ? UserLoading() : ListView.builder(
      physics: NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      itemCount: delivery.length,
      itemBuilder: (context, index) {
        return FeedbackTile(delivery: delivery[index]);
      },
    );
  }
}
