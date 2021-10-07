import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:proxpress/courier_tile.dart';
import 'package:proxpress/delivery_price_tile.dart';
import 'package:proxpress/delivery_prices.dart';

class DeliveryPriceList extends StatefulWidget {
  @override
  _DeliveryPriceListState createState() => _DeliveryPriceListState();
}

class _DeliveryPriceListState extends State<DeliveryPriceList> {
  @override
  Widget build(BuildContext context) {
    final deliveryPrice = Provider.of<List<DeliveryPrice>>(context);

    if (deliveryPrice != null && deliveryPrice.length > 0) {
      return SizedBox(
        child: ListView.builder(
          shrinkWrap: true,
          itemBuilder: (context, index) {
            return DeliveryPriceTile(deliveryPrice: deliveryPrice[index]);
          },
          itemCount: deliveryPrice.length,
        ),
      );
    } else return Container();
  }
}
