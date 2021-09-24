import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:proxpress/Load/user_load.dart';
import 'package:proxpress/UI/CustomerUI/courier_bookmarks.dart';
import 'package:proxpress/UI/CustomerUI/dashboard_customer.dart';
import 'package:proxpress/UI/login_screen.dart';
import 'package:proxpress/classes/courier_classes/notif_counter_courier.dart';
import 'package:proxpress/classes/customer_classes/notif_counter_customer.dart';
import 'package:proxpress/classes/directions_model.dart';
import 'package:proxpress/classes/directions_repository.dart';
import 'package:proxpress/models/deliveries.dart';
import 'package:proxpress/services/auth.dart';
import 'package:proxpress/services/secrets.dart';
import 'package:proxpress/services/database.dart';
import 'package:proxpress/models/user.dart';
import 'package:provider/provider.dart';
import 'package:proxpress/models/customers.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'dart:async';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'dart:math' show cos, sqrt, asin;

import 'courier_bookmarks_tile.dart';



class PinLocation extends StatefulWidget {
  final GlobalKey<FormState> locKey;
  final TextEditingController textFieldPickup;
  final TextEditingController textFieldDropOff;
  final bool isBookmarks;
  PinLocation({
    Key key,
    @required this.locKey,
    @required this.textFieldPickup,
    @required this.textFieldDropOff,
    @required this.isBookmarks,
  }) : super(key: key);
  @override
  _PinLocationState createState() => _PinLocationState();
}

class _PinLocationState extends State<PinLocation> {
  String pickupAddress;
  LatLng pickupCoordinates;

  String dropOffAddress;
  LatLng dropOffCoordinates;

  dynamic pickupDetails;
  dynamic dropOffDetails;

  String error = '';

  void _validate(){
    if(!widget.locKey.currentState.validate()){
      return;
    }
    widget.locKey.currentState.save();
    print (pickupAddress);
    print (dropOffAddress);
  }

  Future<bool> checkIfHasPendingRequest(String uid) async {
    bool hasPendingRequest = false;

    await FirebaseFirestore.instance
        .collection('Deliveries')
        .where('Courier Approval', isEqualTo: 'Pending')
        .where('Customer Reference', isEqualTo: FirebaseFirestore.instance.collection('Customers').doc(uid))
        .limit(1)
        .get()
        .then((event) {
      if (event.docs.isNotEmpty) {
        hasPendingRequest = true;
      } else {
        hasPendingRequest = false;
      }
    });

    return hasPendingRequest;
  }

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<TheUser>(context);
    return Column(
      children: [
        Container(
          margin: EdgeInsets.only(
              right: 40, left: 40, bottom: 40, top: 100),
          child: Form(
            key: widget.locKey,
            child: Card(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Container(
                    margin: EdgeInsets.only(top: 10),
                    child: Text(
                      "Pin a Location",
                      style: TextStyle(
                        fontSize: 20,
                      ),
                    ),
                  ),
                  Container(
                    margin: EdgeInsets.symmetric(horizontal: 35),
                    child: TextFormField(
                      controller: widget.textFieldPickup,
                      enableInteractiveSelection: false,
                      onTap: () async {
                        FocusScope.of(context).requestFocus(new FocusNode());

                        pickupDetails = await Navigator.pushNamed(context, '/pinLocationMap');

                        print("niceee ${pickupDetails.address}");
                        widget.textFieldPickup.text = pickupDetails.address;
                        widget.textFieldPickup.selection = TextSelection.fromPosition(TextPosition(offset: 0));

                        print("niceee2 ${pickupDetails.coordinates.toString()}");
                        pickupCoordinates = pickupDetails.coordinates;

                        setState(() => pickupAddress = widget.textFieldPickup.text);
                      },
                      decoration: InputDecoration(labelText: 'Pick up location', prefixIcon: Icon(Icons.place_rounded)),
                      keyboardType: TextInputType.streetAddress,
                      validator: (String value){
                        if(value.isEmpty){
                          return 'Pick up location is required';
                        } else {
                          return null;
                        }
                      },
                      onSaved: (String value){
                        pickupAddress = value;
                      },
                    ),
                  ),
                  Container(
                    margin: EdgeInsets.symmetric(horizontal: 35, vertical: 23),
                    child: TextFormField(
                      controller: widget.textFieldDropOff,
                      enableInteractiveSelection: false,
                      onTap: () async {
                        FocusScope.of(context).requestFocus(new FocusNode());

                        dropOffDetails = await Navigator.pushNamed(context, '/pinLocationMap');

                        print("niceee ${dropOffDetails.address}");
                        widget.textFieldDropOff.text = dropOffDetails.address;
                        widget.textFieldDropOff.selection = TextSelection.fromPosition(TextPosition(offset: 0));

                        print("niceee2 ${dropOffDetails.coordinates.toString()}");
                        dropOffCoordinates = dropOffDetails.coordinates;

                        setState(() => dropOffAddress = widget.textFieldDropOff.text);
                      },
                      decoration: InputDecoration(labelText: 'Drop off location', prefixIcon: Icon(Icons.location_searching_rounded)),
                      keyboardType: TextInputType.streetAddress,
                      validator: (String value){
                        if(value.isEmpty){
                          return 'Drop off location is required';
                        } else {
                          return null;
                        }
                      },
                      onSaved: (String value){
                        dropOffAddress = value;
                      },
                    ),
                  ),
                ],
              ),
              shadowColor: Colors.black,
              shape: RoundedRectangleBorder(
                  borderRadius:
                  BorderRadius.all(Radius.circular(10))),
            ),
          ),
        ),
        ElevatedButton(
          child: Text(
            'Pin Location',
            style:
            TextStyle(color: Colors.white, fontSize: 18),
          ),
          style: ElevatedButton.styleFrom(
              primary: Color(0xfffb0d0d)),
          onPressed: () async {
            if (widget.locKey.currentState.validate()) {
              print("${pickupCoordinates.latitude}, ${pickupCoordinates.longitude}, ${dropOffCoordinates.latitude}, ${dropOffCoordinates.longitude}");

              Directions _infoFetch = await DirectionsRepository().getDirections(origin: pickupCoordinates, destination: dropOffCoordinates);

              print("??? ${_infoFetch.totalDistance}");
              String distanceRemoveKM = '';
              bool isKM = false;

              if (_infoFetch.totalDistance.contains('km')) {
                isKM = true;
                distanceRemoveKM = _infoFetch.totalDistance.substring(0, _infoFetch.totalDistance.length - 3);
              } else {
                distanceRemoveKM = _infoFetch.totalDistance.substring(0, _infoFetch.totalDistance.length - 2);
              }

              bool hasPendingRequest = await checkIfHasPendingRequest(user.uid);

              if (!hasPendingRequest){
                if(!widget.isBookmarks){
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            DashboardCustomer(
                              pickupAddress: pickupAddress,
                              pickupCoordinates: pickupCoordinates,
                              dropOffAddress: dropOffAddress,
                              dropOffCoordinates: dropOffCoordinates,
                              distance: isKM ? double.parse(distanceRemoveKM) : double.parse(distanceRemoveKM) / 1000,
                            ),
                      )
                  );
                } else{
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            CourierBookmarkTile(
                              pickupAddress: pickupAddress,
                              pickupCoordinates: pickupCoordinates,
                              dropOffAddress: dropOffAddress,
                              dropOffCoordinates: dropOffCoordinates,
                              distance: isKM ? double.parse(distanceRemoveKM) : double.parse(distanceRemoveKM) / 1000,
                            ),
                      )
                  );
                }
              } else {
                setState((){
                  error = 'You still have one pending request.';
                });
              }
            }
          },
        ),
        Text(
          error,
          style: TextStyle(color: Colors.red, fontSize: 14.0),
        ),
      ],
    );
  }
}
