import 'dart:async';
import 'dart:ffi';
import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animarker/flutter_map_marker_animation.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'package:provider/provider.dart';
import 'package:proxpress/classes/directions_model.dart';
import 'package:proxpress/classes/directions_repository.dart';
//import 'package:lottie/lottie.dart';
import 'package:proxpress/models/deliveries.dart';
import 'package:proxpress/models/user.dart';
import 'package:proxpress/services/database.dart';

class DeliveryStatus extends StatefulWidget {
  final Delivery delivery;

  DeliveryStatus({
    Key key,
    @required this.delivery,
  }) : super(key: key);

  @override
  _DeliveryStatusState createState() => _DeliveryStatusState();
}

class _DeliveryStatusState extends State<DeliveryStatus> {
  GoogleMapController _googleMapController;
  Marker marker;

  @override
  Widget build(BuildContext context) {
    LatLng pickup_pos = LatLng(widget.delivery.pickupCoordinates.latitude, widget.delivery.pickupCoordinates.longitude,);
    Marker _pickup = Marker(
      markerId: const MarkerId('pickup'),
      infoWindow: const InfoWindow(title: 'Pickup Location'),
      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
      position: pickup_pos,
    );

    LatLng dropOff_pos = LatLng(widget.delivery.dropOffCoordinates.latitude, widget.delivery.dropOffCoordinates.longitude,);
    Marker _dropOff = Marker(
      markerId: const MarkerId('dropOff'),
      infoWindow: const InfoWindow(title: 'Drop Off Location'),
      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
      position: dropOff_pos,
    );

    Future<Directions> _infoFetch = DirectionsRepository().getDirections(origin: _pickup.position, destination: _dropOff.position);

    // Stream<Delivery> getUpdatedCourLoc = DatabaseService(uid: widget.delivery.uid).deliveryData;
    //
    // getUpdatedCourLoc.listen((event) {
    //   setState((){
    //     marker = Marker(
    //       markerId: const MarkerId("courier"),
    //       icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure),
    //       infoWindow: const InfoWindow(title: 'Courier Location'),
    //       position: LatLng(event.courierLocation.latitude, event.courierLocation.longitude),
    //     );
    //   });
    // });

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        iconTheme: IconThemeData(color: Color(0xfffb0d0d),),
        actions: [
          IconButton(icon: Icon(
            Icons.help_outline,
          ),
            onPressed: (){
              showDialog(
                  context: context,
                  builder: (BuildContext context){
                    return AlertDialog(
                      title: Text("Help"),
                      content: Text('nice'),
                      actions: [
                        TextButton(
                          child: Text("OK"),
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                        ),
                      ],
                    );
                  }
              );
            },
            iconSize: 25,
          ),
        ],
        flexibleSpace: Container(
          margin: EdgeInsets.only(top: 10),
          child: Image.asset(
            "assets/PROExpress-logo.png",
            height: 120,
            width: 120,
          ),
        ),
        //title: Text("PROExpress"),
      ),
      body: Center(
        child: Column(
          children: [
            FutureBuilder<Directions>(
                future: _infoFetch,
                builder: (context, AsyncSnapshot<Directions> snapshot) {
                  if (snapshot.hasData) {
                    Directions _info = snapshot.data;

                    CameraPosition _initialCameraPosition = CameraPosition(
                      target: LatLng(13.621980880497976, 123.19477396693487),
                      zoom: 15,
                    );

                    return Expanded(
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          GoogleMap(
                            onMapCreated: (controller) {
                              _googleMapController = controller;
                              _googleMapController.animateCamera(
                                  CameraUpdate.newLatLngBounds(_info.bounds, 100.0)
                              );

                              _googleMapController.showMarkerInfoWindow(MarkerId('pickup'));
                              _googleMapController.showMarkerInfoWindow(MarkerId('dropOff'));
                            },
                            myLocationButtonEnabled: false,
                            zoomControlsEnabled: false,
                            initialCameraPosition: _initialCameraPosition,
                            markers: {
                              if (_pickup != null) _pickup,
                              if (_dropOff != null) _dropOff,
                              if(marker != null) marker,
                            },
                            polylines: {
                              if (_info != null)
                                Polyline(
                                  polylineId: const PolylineId('overview_polyline'),
                                  color: Colors.red,
                                  width: 5,
                                  points: _info.polylinePoints
                                      .map((e) => LatLng(e.latitude, e.longitude))
                                      .toList(),
                                ),
                            },
                          ),
                          Positioned(
                            top: 20.0,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                vertical: 6.0,
                                horizontal: 12.0,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(20.0),
                                boxShadow: const [
                                  BoxShadow(
                                    color: Colors.black26,
                                    offset: Offset(0, 2),
                                    blurRadius: 6.0,
                                  )
                                ],
                              ),
                              child: Text(
                                '${_info.totalDistance}, ${_info.totalDuration}',
                                style: const TextStyle(
                                  fontSize: 18.0,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  } else {
                    return SizedBox(
                      height: MediaQuery.of(context).size.height - MediaQuery.of(context).size.height * 0.3,
                      width: MediaQuery.of(context).size.width,
                      child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [CircularProgressIndicator()]
                      ),
                    );
                  }
                }
            ),
          ],
        ),
      ),
      floatingActionButton: StreamBuilder<Delivery>(
          stream: DatabaseService(uid: widget.delivery.uid).deliveryData,
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              Delivery deliveryData = snapshot.data;
              return FloatingActionButton.extended(
                  label: Text('Courier Location'),
                  icon: Container(
                      height: 20,
                      width: 20,
                      child: Image.asset('assets/courier.png')
                  ),
                  onPressed: () {
                    setState((){
                      marker = Marker(
                        markerId: const MarkerId("courier"),
                        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure),
                        infoWindow: const InfoWindow(title: 'Courier Location'),
                        position: LatLng(deliveryData.courierLocation.latitude, deliveryData.courierLocation.longitude),
                      );
                    });
                  });
            } else
              return Container();
          }
      ),
    );
  }
}