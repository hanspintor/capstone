import 'package:flutter/material.dart';
import 'package:proxpress/couriers.dart';


class CourierTile extends StatelessWidget {
  final Courier courier;
  CourierTile({this.courier});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          margin: EdgeInsets.symmetric(horizontal: 10),
          child: Table(
            border: TableBorder.all(),
            children: [
              TableRow(
                children: [
                  //Align(child: Text(courier.uid, style: TextStyle(fontWeight: FontWeight.bold),)),
                  Align(child: Text("${courier.fName} ${courier.lName}")),
                  Align(child: Text(courier.address)),
                  Align(child: Text(courier.email)),
                  Align(child: Text(courier.contactNo)),
                  Align(child: Text(courier.vehicleType)),
                  Align(child: Text(courier.vehicleColor)),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}
// alignment: Alignment.centerLeft,
