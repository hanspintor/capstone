import 'dart:async';
import 'dart:ffi';
import 'dart:math';
import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart' as cloud;
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animarker/flutter_map_marker_animation.dart';
import 'package:flutter_osm_plugin/flutter_osm_plugin.dart';
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
  // GoogleMapController _googleMapController;
  // Marker marker;

  @override
  Widget build(BuildContext context) {
    // LatLng pickup_pos = LatLng(widget.delivery.pickupCoordinates.latitude, widget.delivery.pickupCoordinates.longitude,);
    // Marker _pickup = Marker(
    //   markerId: const MarkerId('pickup'),
    //   infoWindow: const InfoWindow(title: 'Pickup Location'),
    //   icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
    //   position: pickup_pos,
    // );
    //
    // LatLng dropOff_pos = LatLng(widget.delivery.dropOffCoordinates.latitude, widget.delivery.dropOffCoordinates.longitude,);
    // Marker _dropOff = Marker(
    //   markerId: const MarkerId('dropOff'),
    //   infoWindow: const InfoWindow(title: 'Drop Off Location'),
    //   icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
    //   position: dropOff_pos,
    // );
    //
    // Future<Directions> _infoFetch = DirectionsRepository().getDirections(origin: _pickup.position, destination: _dropOff.position);

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

    // CameraPosition _initialCameraPosition = CameraPosition(
    //   target: LatLng(13.621980880497976, 123.19477396693487),
    //   zoom: 15,
    // );

    GeoPoint _pickup = GeoPoint(latitude: widget.delivery.pickupCoordinates.latitude, longitude: widget.delivery.pickupCoordinates.longitude);
    GeoPoint _dropOff = GeoPoint(latitude: widget.delivery.dropOffCoordinates.latitude, longitude: widget.delivery.dropOffCoordinates.longitude);

    Future<double> distanceInMeters = distance2point(_pickup, _dropOff);

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
            FutureBuilder<double>(
              future: distanceInMeters,
              builder: (context, AsyncSnapshot<double> snapshot) {
                if (snapshot.hasData) {
                  double distance = snapshot.data;

                  // mapController.addMarker(GeoPoint(latitude: widget.delivery.pickupCoordinates.latitude, longitude: widget.delivery.pickupCoordinates.longitude));
                  // mapController.addMarker(GeoPoint(latitude: widget.delivery.dropOffCoordinates.latitude, longitude: widget.delivery.dropOffCoordinates.longitude));

                  GeoPoint midpoint = GeoPoint(latitude: ((_pickup.latitude + _dropOff.latitude) / 2), longitude: ((_pickup.longitude + _dropOff.longitude) / 2));

                  MapController mapController = MapController(
                    initMapWithUserPosition: false,
                    initPosition: midpoint,
                    areaLimit: BoundingBox( east: 123.975219, north: 14.129017, south: 13.261474, west: 122.547888,),
                  );

                  StaticPositionGeoPoint pickup = StaticPositionGeoPoint(
                      'pickup',
                      MarkerIcon(
                        icon: Icon(
                          Icons.location_on_rounded,
                          size: 100,
                        ),
                      ),
                      [_pickup]
                  );

                  StaticPositionGeoPoint dropOff = StaticPositionGeoPoint(
                      'dropOff',
                      MarkerIcon(
                        icon: Icon(
                          Icons.location_on_rounded,
                          size: 100,
                        ),
                      ),
                      [_dropOff]
                  );

                  // thanks to gavrbhat from Stackoverflow
                  double getZoomLevel(double radius) {
                    double zoomLevel = 11;
                    if (radius > 0) {
                      double radiusElevated = radius + radius / 2;
                      double scale = radiusElevated / 500;
                      zoomLevel = 16 - log(scale) / log(2);
                    }
                    zoomLevel = num.parse(zoomLevel.toStringAsFixed(2));
                    return zoomLevel;
                  }

                  return Expanded(
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        OSMFlutter(
                          onMapIsReady: (bool) async {
                            if (bool) {
                              RoadInfo roadInfo = await mapController.drawRoad(
                                _pickup, _dropOff,
                                roadType: RoadType.car,
                                roadOption: RoadOption(
                                  roadWidth: 10,
                                  roadColor: Colors.blue,
                                  showMarkerOfPOI: false,
                                ),
                              );

                              print("${roadInfo.distance}km");
                              print("${roadInfo.duration}sec");
                            }
                          },
                          staticPoints: [
                            pickup,
                            dropOff,
                          ],
                          controller: mapController,
                          trackMyPosition: false,
                          initZoom: getZoomLevel(distance / 2),
                          userLocationMarker: UserLocationMaker(
                            personMarker: MarkerIcon(
                              icon: Icon(
                                Icons.location_history_rounded,
                                color: Colors.red,
                                size: 48,
                              ),
                            ),
                            directionArrowMarker: MarkerIcon(
                              icon: Icon(
                                Icons.double_arrow,
                                size: 48,
                              ),
                            ),
                          ),
                          road: Road(
                            startIcon: MarkerIcon(
                              icon: Icon(
                                Icons.person,
                                size: 64,
                                color: Colors.brown,
                              ),
                            ),
                            roadColor: Colors.yellowAccent,
                          ),
                          markerOption: MarkerOption(
                              defaultMarker: MarkerIcon(
                                icon: Icon(
                                  Icons.person_pin_circle,
                                  color: Colors.blue,
                                  size: 56,
                                ),
                              )
                          ),
                        ),
                        // GoogleMap(
                        //   onMapCreated: (controller) {
                        //     _googleMapController = controller;
                        //     _googleMapController.animateCamera(
                        //         CameraUpdate.newLatLngBounds(_info.bounds, 100.0)
                        //     );
                        //
                        //     _googleMapController.showMarkerInfoWindow(MarkerId('pickup'));
                        //     _googleMapController.showMarkerInfoWindow(MarkerId('dropOff'));
                        //   },
                        //   myLocationButtonEnabled: false,
                        //   zoomControlsEnabled: false,
                        //   initialCameraPosition: _initialCameraPosition,
                        //   markers: {
                        //     if (_pickup != null) _pickup,
                        //     if (_dropOff != null) _dropOff,
                        //     if(marker != null) marker,
                        //   },
                        //   polylines: {
                        //     if (_info != null)
                        //       Polyline(
                        //         polylineId: const PolylineId('overview_polyline'),
                        //         color: Colors.red,
                        //         width: 5,
                        //         points: _info.polylinePoints
                        //             .map((e) => LatLng(e.latitude, e.longitude))
                        //             .toList(),
                        //       ),
                        //   },
                        // ),
                        // Positioned(
                        //   top: 20.0,
                        //   child: Container(
                        //     padding: const EdgeInsets.symmetric(
                        //       vertical: 6.0,
                        //       horizontal: 12.0,
                        //     ),
                        //     decoration: BoxDecoration(
                        //       color: Colors.white,
                        //       borderRadius: BorderRadius.circular(20.0),
                        //       boxShadow: const [
                        //         BoxShadow(
                        //           color: Colors.black26,
                        //           offset: Offset(0, 2),
                        //           blurRadius: 6.0,
                        //         )
                        //       ],
                        //     ),
                        //     child: Text(
                        //       '${_info.totalDistance}, ${_info.totalDuration}',
                        //       style: const TextStyle(
                        //         fontSize: 18.0,
                        //         fontWeight: FontWeight.w600,
                        //       ),
                        //     ),
                        //   ),
                        // ),
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
                      // marker = Marker(
                      //   markerId: const MarkerId("courier"),
                      //   icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure),
                      //   infoWindow: const InfoWindow(title: 'Courier Location'),
                      //   position: LatLng(deliveryData.courierLocation.latitude, deliveryData.courierLocation.longitude),
                      // );
                    });
                  });
            } else
              return Container();
          }
      ),
    );
  }
}