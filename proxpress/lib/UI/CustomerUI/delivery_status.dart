import 'dart:async';
import 'dart:ffi';
import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
  double rating = 0;
  StreamSubscription _locationSubscription;
  Location _locationTracker = Location();
  Marker marker;
  Circle circle;

  void updateMarkerAndCircle(LocationData newLocalData, Uint8List imageData){
    LatLng latlng = LatLng(newLocalData.latitude, newLocalData.longitude);

    this.setState(() {
      marker = Marker(
        markerId: MarkerId("home"),
        position: latlng,
        rotation: newLocalData.heading,
        draggable: false,
        zIndex: 2,
        flat: true,
        //anchor: Offset()
        icon: BitmapDescriptor.fromBytes(imageData),
      );
      circle = Circle(
        circleId: CircleId("courier"),
        radius: newLocalData.accuracy,
        zIndex: 1,
        strokeColor: Colors.red,
        center: latlng,
        fillColor: Colors.redAccent.withAlpha(70),
      );
    });
  }

  Future<Uint8List> getMarker() async{
    ByteData byteData = await DefaultAssetBundle.of(context).load("assets/courier.png");
    return byteData.buffer.asUint8List();
  }

  void getCurrentLocation() async {
    try{
      Uint8List imageData = await getMarker();
      var location = await _locationTracker.getLocation();

      updateMarkerAndCircle(location, imageData);

      if(_locationSubscription != null){
        _locationSubscription.cancel();
      }

      _locationSubscription = _locationTracker.onLocationChanged.listen((newLocalData) {
        if(_googleMapController != null) {
          _googleMapController.animateCamera(CameraUpdate.newCameraPosition(new CameraPosition(
            bearing: 192.8334901295799,
            target: LatLng(newLocalData.latitude, newLocalData.longitude),
            tilt: 0,
            zoom: 15,
          )));
          updateMarkerAndCircle(newLocalData, imageData);
        }
      });
    } on PlatformException catch (e){
      if (e.code == 'PERMISSION_DENIED'){
        debugPrint("Permission Denied");
      }
    }
  }

  @override
  void dispose(){
    if(_locationSubscription != null){
      _locationSubscription.cancel();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<TheUser>(context);
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
    Stream<List<Delivery>> deliveryList = FirebaseFirestore.instance
        .collection('Deliveries')
        .where('Customer Reference', isEqualTo: FirebaseFirestore.instance.collection('Customers').doc(user.uid))
        .snapshots()
        .map(DatabaseService().deliveryDataListFromSnapshot);

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
        // child: Column(
        //   children: [
        //     Container(
        //       margin: EdgeInsets.fromLTRB(0, 20, 40, 10),
        //         child: Lottie.asset('assets/delivery.json')
        //     ),
        //     Row(
        //       children: [
        //         Container(
        //           margin: EdgeInsets.fromLTRB(50, 0, 0, 10),
        //           child: Text('Delivery in Progress',
        //             style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
        //           ),
        //         ),
        //         Container(
        //           margin: EdgeInsets.only(top: 6),
        //           child: SizedBox(
        //             height: 50,
        //               width: 50,
        //               child: Lottie.asset('assets/dots.json')
        //           ),
        //         ),
        //       ],
        //     ),
        //   ],
        // ),
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
                            // _googleMapController.animateCamera(
                            //   CameraUpdate.newLatLngBounds(_info.bounds, 100.0)
                            // );

                            _googleMapController.showMarkerInfoWindow(MarkerId('pickup'));
                            //_googleMapController.showMarkerInfoWindow(MarkerId('dropOff'));
                          },
                          myLocationButtonEnabled: false,
                          zoomControlsEnabled: false,
                          initialCameraPosition: _initialCameraPosition,
                          //markers: Set.of((marker != null) ? [marker] : []),
                          circles: Set.of((circle != null) ? [circle] : []),
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
        floatingActionButton: FloatingActionButton(
            child: Icon(Icons.local_shipping_rounded),
          onPressed: (){
              getCurrentLocation();
            }),
    );
  }
}
