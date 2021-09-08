import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:proxpress/UI/CustomerUI/customer_remarks.dart';
import 'package:proxpress/UI/login_screen.dart';
import 'package:proxpress/models/couriers.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class CourierTile extends StatefulWidget {
  final Courier courier;
  final String pickupAddress;
  final LatLng pickupCoordinates;
  final String dropOffAddress;
  final LatLng dropOffCoordinates;

  CourierTile({
    Key key,
    @required this.courier,
    @required this.pickupAddress,
    @required this.pickupCoordinates,
    @required this.dropOffAddress,
    @required this.dropOffCoordinates,
  }) : super(key: key);

  @override
  State<CourierTile> createState() => _CourierTileState();
}

class _CourierTileState extends State<CourierTile> {
  @override
  initState(){
    super.initState();
    setState((){});
  }

  int baseFare;
  int farePerKM;

  // need to get this from distance of 2 geopoints
  int distance = 4;
  int deliveryFee;

  @override
  Widget build(BuildContext context) {
    baseFare ??= 0;
    farePerKM ??= 0;
    deliveryFee ??= 0;

    print(widget.courier.deliveryPriceRef.toString());

    widget.courier.deliveryPriceRef.get().then((DocumentSnapshot doc) {
      baseFare = doc['Base Fare'];
      farePerKM = doc['Fare Per KM'];
    });

    deliveryFee = baseFare + (farePerKM * distance);

    print('${widget.courier.fName} - $baseFare');
    print('${widget.courier.fName} - $farePerKM');

    // Ini dapat mag luwas na delivery fee
    print('${widget.courier.fName} - $deliveryFee');

    final FirebaseAuth _auth = FirebaseAuth.instance;
    User user = _auth.currentUser;
    var color;
    if (widget.courier.status == "Offline") {
      color = Colors.redAccent;
    } else {
      color = Colors.green;
    }

    return user == null
        ? LoginScreen()
        : Padding(
            padding: EdgeInsets.only(top: 8.0),
            child: SingleChildScrollView(
              child: Card(
                margin: EdgeInsets.fromLTRB(20.0, 6.0, 20.0, 0.0),
                child: ListTile(
                  title: Text("${widget.courier.fName} ${widget.courier.lName}"),
                  leading: Icon(
                    Icons.account_circle_rounded,
                    size: 50,
                  ),
                  subtitle: Text("Vehicle Type: ${widget.courier.vehicleType}\nDelivery Fee: $deliveryFee"),
                  trailing: Column(
                    children: [
                      Text(
                        "${widget.courier.status}",
                        style: TextStyle(
                          color: color,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Container(
                          margin: EdgeInsets.only(top: 5),
                          height: 25,
                          child: ElevatedButton(
                              child: Text(
                                'Request',
                                style: TextStyle(
                                    color: Colors.white, fontSize: 10),
                              ),
                              style: ElevatedButton.styleFrom(
                                  primary: Colors.black),
                              onPressed: () {
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          CustomerRemarks(
                                          courierUID: widget.courier.uid,
                                          pickupAddress: widget.pickupAddress,
                                          pickupCoordinates: widget.pickupCoordinates,
                                          dropOffAddress: widget.dropOffAddress,
                                          dropOffCoordinates: widget.dropOffCoordinates),
                                    ));
                              }
                          )
                      ),
                    ],
                  ),
                  onTap: () {

                  },
                ),
              ),
            ),
          );
  }
}
