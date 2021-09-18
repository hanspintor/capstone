import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:proxpress/Load/user_load.dart';
import 'package:proxpress/classes/courier_classes/transaction_tile.dart';
import 'package:proxpress/models/deliveries.dart';

class TransactionList extends StatefulWidget {

  @override
  _TransactionListState createState() => _TransactionListState();
}

class _TransactionListState extends State<TransactionList> {
  @override
  Widget build(BuildContext context) {
    final delivery = Provider.of<List<Delivery>>(context);
    print(delivery.length.toString());
    return delivery == null ? UserLoading() : SingleChildScrollView(
      child: SizedBox(
        height: 500,
        width: 500,
        child: ListView.builder(
          itemCount: delivery.length,
          itemBuilder: (context, index) {
            return TransactionTile(delivery: delivery[index]);
          },
        ),
      ),
    );
  }
}
