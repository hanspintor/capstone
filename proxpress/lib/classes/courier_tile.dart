import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:proxpress/UI/CustomerUI/customer_remarks.dart';
import 'package:proxpress/UI/login_screen.dart';
import 'package:proxpress/models/couriers.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class CourierTile extends StatelessWidget {
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
  Widget build(BuildContext context) {
    final FirebaseAuth _auth = FirebaseAuth.instance;
    User user = _auth.currentUser;
    var color;
    if (courier.status == "Offline") {
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
                  title: Text("${courier.fName} ${courier.lName}"),
                  leading: Icon(
                    Icons.account_circle_rounded,
                    size: 50,
                  ),
                  subtitle: Text("Vehicle Type: ${courier.vehicleType}"),
                  trailing: Column(
                    children: [
                      Text(
                        "${courier.status}",
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
                                          courierUID: courier.uid,
                                          pickupAddress: pickupAddress,
                                          pickupCoordinates: pickupCoordinates,
                                          dropOffAddress: dropOffAddress,
                                          dropOffCoordinates: dropOffCoordinates),
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
