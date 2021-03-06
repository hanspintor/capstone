import 'package:flutter/material.dart';
import 'package:flutter_osm_plugin/flutter_osm_plugin.dart';
import 'package:loader_overlay/loader_overlay.dart';
import 'package:page_transition/page_transition.dart';
import 'package:proxpress/UI/CustomerUI/pin_location_map.dart';
import 'package:proxpress/classes/customer_classes/vehicle_type.dart';
import 'package:proxpress/classes/directions_model.dart';
import 'package:proxpress/classes/directions_repository.dart';
import 'package:proxpress/UI/CustomerUI/dashboard_customer.dart';
import 'package:cloud_firestore/cloud_firestore.dart' as cloud;

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
  MapController controller;

  String pickupAddress;
  GeoPoint pickupCoordinates;

  String dropOffAddress;
  GeoPoint dropOffCoordinates;

  dynamic pickupDetails;
  dynamic dropOffDetails;

  String errorPickup = '';
  String errorDropOff = '';

  bool isKM = false;
  bool appear = false;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          margin: widget.isBookmarks ? EdgeInsets.fromLTRB(40, 0, 40, 0) : EdgeInsets.fromLTRB(40, 40, 40, 40),
          child: Form(
            key: widget.locKey,
            child: Column(
              children: [
                Card(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Container(
                        margin: EdgeInsets.only(top: 10),
                        child: Text(
                          "Pick-up Location",
                          style: TextStyle(
                            fontSize: 20,
                          ),
                        ),
                      ),
                      Container(
                        margin: EdgeInsets.symmetric(horizontal: 35),
                        child: TextFormField(
                          decoration: InputDecoration(labelText: 'Address', prefixIcon: Icon(Icons.location_on_rounded), hintText: 'Type exact address'),
                          keyboardType: TextInputType.streetAddress,
                          validator: (String value) {
                            if (value.isEmpty) {
                              return 'Pick up location is required';
                            } else {
                              return null;
                            }
                          },
                          onSaved: (String value) {
                            pickupAddress = value;
                          },
                          onChanged: (String value) {
                            setState(() => pickupAddress = value);
                          },
                        ),
                      ),
                      Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                  margin: EdgeInsets.symmetric(vertical: 10),
                                  child: TextButton.icon(
                                    style: TextButton.styleFrom(
                                      side: BorderSide(color: pickupDetails == null ? Colors.red : Colors.grey, width: 2),
                                    ),
                                    icon: Icon(Icons.location_searching_rounded),
                                    label: Text(pickupDetails == null ? 'Pin Location' : 'Location Pinned'),
                                    onPressed: pickupDetails != null ? null : () async {
                                      pickupDetails = await Navigator.push(context, PageTransition(child: SearchPage(), type: PageTransitionType.bottomToTop));

                                      setState(() {});

                                      if (pickupDetails != null) {
                                        setState(() => errorPickup = '');
                                        pickupCoordinates = GeoPoint(latitude: pickupDetails.latitude, longitude: pickupDetails.longitude);
                                      }
                                    },
                                  )
                              ),
                              pickupDetails == null ? Container() : IconButton(
                                color: Colors.red,
                                icon: Icon(Icons.clear),
                                onPressed: () {
                                  setState(() {
                                    pickupCoordinates = null;
                                    pickupDetails = null;
                                  });
                                },
                              ),
                            ],
                          ),
                        ],
                      ),
                      Container(
                        margin: EdgeInsets.fromLTRB(0, 0, 0, 10),
                        child: Text(errorPickup, style: TextStyle(color: Colors.red),)
                      ),
                    ],
                  ),
                  shadowColor: Colors.black,
                  shape: RoundedRectangleBorder(
                      borderRadius:
                      BorderRadius.all(Radius.circular(10))),
                ),
                Card(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Container(
                        margin: EdgeInsets.only(top: 10),
                        child: Text(
                          "Drop-off Location",
                          style: TextStyle(
                            fontSize: 20,
                          ),
                        ),
                      ),
                      Container(
                        margin: EdgeInsets.symmetric(horizontal: 35),
                        child: TextFormField(
                          decoration: InputDecoration(labelText: 'Address', prefixIcon: Icon(Icons.location_on_rounded), hintText: 'Type exact address'),
                          keyboardType: TextInputType.streetAddress,
                          validator: (String value) {
                            if (value.isEmpty) {
                              return 'Drop-off location is required';
                            } else {
                              return null;
                            }
                          },
                          onSaved: (String value) {
                            dropOffAddress = value;
                          },
                          onChanged: (String value) {
                            setState(() => dropOffAddress = value);
                          },
                        ),
                      ),
                      Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                margin: EdgeInsets.symmetric(vertical: 10),
                                child: TextButton.icon(
                                  style: TextButton.styleFrom(
                                    side: BorderSide(color: dropOffDetails == null ? Colors.red : Colors.grey, width: 2),
                                  ),
                                  icon: Icon(Icons.location_searching_rounded),
                                  label: Text(dropOffDetails == null ? 'Pin Location' : 'Location Pinned'),
                                  onPressed: dropOffDetails != null ? null : () async {
                                    dropOffDetails = await Navigator.push(context, PageTransition(child: SearchPage(), type: PageTransitionType.bottomToTop));

                                    setState(() {});

                                    if (dropOffDetails != null) {
                                      setState(() => errorDropOff = '');
                                      dropOffCoordinates = GeoPoint(latitude: dropOffDetails.latitude, longitude: dropOffDetails.longitude);
                                    }
                                  },
                                )
                              ),
                              dropOffDetails == null ? Container() : IconButton(
                                color: Colors.red,
                                icon: Icon(Icons.clear),
                                onPressed: () {
                                  setState(() {
                                    dropOffCoordinates = null;
                                    dropOffDetails = null;
                                  });
                                },
                              ),
                            ],
                          ),
                          Container(
                            margin: EdgeInsets.fromLTRB(0, 0, 0, 10),
                            child: Text(errorDropOff, style: TextStyle(color: Colors.red),)),
                        ],
                      ),
                    ],
                  ),
                  shadowColor: Colors.black,
                  shape: RoundedRectangleBorder(
                      borderRadius:
                      BorderRadius.all(Radius.circular(10))),
                ),
              ],
            ),
          ),
        ),
        LoaderOverlay(
          child: Container(
            width: double.infinity,
            margin: EdgeInsets.fromLTRB(40, 0, 40, 40),
            child: ElevatedButton(
              child: Text(
                'Select Vehicle',
                style:
                TextStyle(color: Colors.white, fontSize: 18),
              ),
              style: ElevatedButton.styleFrom(
                  primary: Color(0xfffb0d0d)),
              onPressed: () async {
                bool gotError = false;

                if (pickupCoordinates == null) {
                  gotError = true;
                  setState(() => errorPickup = 'Please pin location');
                }

                if (dropOffCoordinates == null) {
                  gotError = true;
                  setState(() => errorDropOff = 'Please pin location');
                }

                if (widget.locKey.currentState.validate() && !gotError) {
                  context.loaderOverlay.show();
                  GeoPoint pickupCoordinates_ = GeoPoint(latitude: pickupCoordinates.latitude, longitude: pickupCoordinates.longitude);
                  GeoPoint dropOffCoordinates_ = GeoPoint(latitude: dropOffCoordinates.latitude, longitude: dropOffCoordinates.longitude);

                  Directions _infoFetch = await DirectionsRepository().getDirections(origin: pickupCoordinates_, destination: dropOffCoordinates_);

                  if (!widget.isBookmarks) {
                    context.loaderOverlay.hide();
                    Navigator.push(
                        context, PageTransition(
                        child: VehicleType(
                          pickupAddress: pickupAddress,
                          pickupCoordinates: cloud.GeoPoint(pickupCoordinates.latitude, pickupCoordinates.longitude),
                          dropOffAddress: dropOffAddress,
                          dropOffCoordinates: cloud.GeoPoint(dropOffCoordinates.latitude, dropOffCoordinates.longitude),
                          distance: _infoFetch.totalDistance,),
                        type: PageTransitionType.rightToLeftWithFade)
                    );
                  }

                  setState(() {
                    errorPickup = '';
                    errorDropOff = '';
                  });
                }
              },
            ),
          ),
        ),
      ],
    );
  }
}

class LocalDataBookmark{
  bool appear;
  double distance;
  String pickupAddress;
  GeoPoint pickupCoordinates;
  String dropOffAddress;
  GeoPoint dropOffCoordinates;

  LocalDataBookmark({
    this.appear,
    this.distance,
    this.pickupAddress,
    this.pickupCoordinates,
    this.dropOffAddress,
    this.dropOffCoordinates
  });
}