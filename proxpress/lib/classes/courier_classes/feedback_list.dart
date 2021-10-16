import 'package:flutter/material.dart';
import 'package:proxpress/Load/user_load.dart';
import 'package:proxpress/classes/courier_classes/feedback_tile.dart';
import 'package:proxpress/models/deliveries.dart';

class FeedbackList extends StatefulWidget {
  final List<Delivery> delivery;

  FeedbackList({
    Key key,
    @required this.delivery,
  }) : super(key: key);

  @override
  _FeedbackListState createState() => _FeedbackListState();
}

class _FeedbackListState extends State<FeedbackList> {
  @override
  Widget build(BuildContext context) {
    //final delivery = Provider.of<List<Delivery>>(context);

    return widget.delivery == null ? UserLoading() : ListView.builder(
      physics: NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      itemCount: widget.delivery.length,
      itemBuilder: (context, index) {
        return FeedbackTile(delivery: widget.delivery[index]);
      },
    );
  }
}
