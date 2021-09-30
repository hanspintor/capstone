import 'package:cloud_firestore/cloud_firestore.dart' as cloud;
import 'package:flutter/material.dart';
import 'package:flutter_osm_plugin/flutter_osm_plugin.dart';
import 'package:geocoding/geocoding.dart';
import 'package:proxpress/UI/CustomerUI/pin_location_map.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'dart:async';
import 'courier_bookmarks_tile.dart';
import 'package:proxpress/classes/directions_model.dart';
import 'package:proxpress/classes/directions_repository.dart';
import 'package:proxpress/UI/CustomerUI/dashboard_customer.dart';
import 'package:proxpress/models/user.dart';
import 'package:provider/provider.dart';

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
  LatLng pickupCoordinates;

  String dropOffAddress;
  LatLng dropOffCoordinates;

  dynamic pickupDetails;
  dynamic dropOffDetails;

  bool isKM = false;
  bool appear = false;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          margin: widget.isBookmarks ? EdgeInsets.fromLTRB(40, 0, 40, 0) : EdgeInsets.fromLTRB(40, 100, 40, 40),
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

                        pickupDetails = await Navigator.push(context, MaterialPageRoute(builder: (context) => SearchPage()));

                        if (pickupDetails != null) {
                          List<Placemark> placemarks = await placemarkFromCoordinates(pickupDetails.latitude, pickupDetails.longitude);
                          widget.textFieldPickup.text = "${placemarks[0].street}, ${placemarks[0].locality}";
                          widget.textFieldPickup.selection = TextSelection.fromPosition(TextPosition(offset: 0));
                          pickupCoordinates = LatLng(pickupDetails.latitude, pickupDetails.longitude);
                        }

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

                        dropOffDetails = await Navigator.push(context, MaterialPageRoute(builder: (context) => SearchPage()));

                        if (dropOffDetails != null) {
                          List<Placemark> placemarks = await placemarkFromCoordinates(dropOffDetails.latitude, dropOffDetails.longitude);
                          widget.textFieldDropOff.text = "${placemarks[0].street}, ${placemarks[0].locality}";
                          widget.textFieldDropOff.selection = TextSelection.fromPosition(TextPosition(offset: 0));
                          dropOffCoordinates = LatLng(dropOffDetails.latitude, dropOffDetails.longitude);
                        }

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
        Visibility(
          visible: widget.isBookmarks,
          child: ElevatedButton(
            child: Text(
              'Pin Location',
              style:
              TextStyle(color: Colors.white, fontSize: 18),
            ),
            style: ElevatedButton.styleFrom(
                primary: Color(0xfffb0d0d)),
            onPressed: () async {
              if (widget.locKey.currentState.validate()) {
                //Directions _infoFetch = await DirectionsRepository().getDirections(origin: pickupCoordinates, destination: dropOffCoordinates);

                // if (_infoFetch.totalDistance.contains('km')) {
                //   setState((){
                //     isKM = true;
                //     distanceRemoveKM = _infoFetch.totalDistance.substring(0, _infoFetch.totalDistance.length - 3);
                //   });
                // } else {
                //   setState((){
                //     distanceRemoveKM = _infoFetch.totalDistance.substring(0, _infoFetch.totalDistance.length - 2);
                //   });
                // }

                // setState((){
                //   distance = isKM ? double.parse(
                //       distanceRemoveKM) : double.parse(
                //       distanceRemoveKM) / 1000;
                // });

                GeoPoint pickupCoordinates_ = GeoPoint(latitude: pickupCoordinates.latitude, longitude: pickupCoordinates.longitude);
                GeoPoint dropOffCoordinates_ = GeoPoint(latitude: dropOffCoordinates.latitude, longitude: dropOffCoordinates.longitude);

                Directions _infoFetch = await DirectionsRepository().getDirections(origin: LatLng(pickupCoordinates_.latitude, pickupCoordinates_.longitude), destination: LatLng(dropOffCoordinates_.latitude, dropOffCoordinates_.longitude));

                if (!widget.isBookmarks) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                        DashboardCustomer(
                          pickupAddress: pickupAddress,
                          pickupCoordinates: pickupCoordinates,
                          dropOffAddress: dropOffAddress,
                          dropOffCoordinates: dropOffCoordinates,
                          distance: _infoFetch.totalDistance,
                        ),
                    )
                  );
                } else {
                  setState((){
                    appear = true;
                    widget.textFieldPickup.clear();
                    widget.textFieldDropOff.clear();
                  });

                  Navigator.pop(context,
                    LocalDataBookmark(
                      appear: appear,
                      distance: _infoFetch.totalDistance,
                      pickupAddress: pickupAddress,
                      pickupCoordinates: pickupCoordinates,
                      dropOffAddress: dropOffAddress,
                      dropOffCoordinates: dropOffCoordinates
                    )
                  );
                }
              }
            },
          ),
        ),
        !widget.isBookmarks ? Visibility(
          visible: !widget.isBookmarks,
          child: ElevatedButton(
            child: Text(
              'Pin Location',
              style:
              TextStyle(color: Colors.white, fontSize: 18),
            ),
            style: ElevatedButton.styleFrom(
                primary: Color(0xfffb0d0d)),
            onPressed: () async {
              if (widget.locKey.currentState.validate()) {
                // Directions _infoFetch = await DirectionsRepository().getDirections(origin: pickupCoordinates, destination: dropOffCoordinates);
                //
                // String distanceRemoveKM = '';
                // bool isKM = false;
                //
                // if (_infoFetch.totalDistance.contains('km')) {
                //   isKM = true;
                //   distanceRemoveKM = _infoFetch.totalDistance.substring(0, _infoFetch.totalDistance.length - 3);
                // } else {
                //   distanceRemoveKM = _infoFetch.totalDistance.substring(0, _infoFetch.totalDistance.length - 2);
                // }

                GeoPoint pickupCoordinates_ = GeoPoint(latitude: pickupCoordinates.latitude, longitude: pickupCoordinates.longitude);
                GeoPoint dropOffCoordinates_ = GeoPoint(latitude: dropOffCoordinates.latitude, longitude: dropOffCoordinates.longitude);

                Directions _infoFetch = await DirectionsRepository().getDirections(origin: LatLng(pickupCoordinates_.latitude, pickupCoordinates_.longitude), destination: LatLng(dropOffCoordinates_.latitude, dropOffCoordinates_.longitude));

                print(_infoFetch.totalDistance);

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
                          distance: _infoFetch.totalDistance,
                        ),
                    )
                  );
                }
              }
            },
          ),
        ) : Container(),
      ],
    );
  }
}

class LocalDataBookmark{
  bool appear;
  double distance;
  String pickupAddress;
  LatLng pickupCoordinates;
  String dropOffAddress;
  LatLng dropOffCoordinates;

  LocalDataBookmark({
    this.appear,
    this.distance,
    this.pickupAddress,
    this.pickupCoordinates,
    this.dropOffAddress,
    this.dropOffCoordinates
  });
}