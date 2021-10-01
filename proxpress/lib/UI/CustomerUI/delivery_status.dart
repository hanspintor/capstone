import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_osm_plugin/flutter_osm_plugin.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import 'package:proxpress/classes/directions_model.dart';
import 'package:proxpress/classes/directions_repository.dart';
import 'package:proxpress/models/deliveries.dart';
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
  @override
  Widget build(BuildContext context) {
    GeoPoint _pickup = GeoPoint(latitude: widget.delivery.pickupCoordinates.latitude, longitude: widget.delivery.pickupCoordinates.longitude);
    GeoPoint _dropOff = GeoPoint(latitude: widget.delivery.dropOffCoordinates.latitude, longitude: widget.delivery.dropOffCoordinates.longitude);
    GeoPoint _courierLoc = GeoPoint(latitude: widget.delivery.courierLocation.latitude, longitude: widget.delivery.courierLocation.longitude);

    print(_pickup);
    print(_dropOff);
    //router.project-osrm.org/route/v1/car/123.19728299999997,13.626521;123.20324700000003,13.62737
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

                  StaticPositionGeoPoint courier = StaticPositionGeoPoint(
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

                  Future<Directions> _infoFetch = DirectionsRepository().getDirections(origin: LatLng(_pickup.latitude, _pickup.longitude), destination: LatLng(_dropOff.latitude, _dropOff.longitude));

                  return Expanded(
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        OSMFlutter(
                          onMapIsReady: (bool) async {
                            if (bool) {
                              await mapController.drawRoad(
                                _pickup, _dropOff,
                                roadType: RoadType.car,
                                roadOption: RoadOption(
                                  roadWidth: 10,
                                  roadColor: Colors.blue,
                                  showMarkerOfPOI: false,
                                ),
                              );
                            }
                          },
                          staticPoints: [
                            pickup,
                            dropOff,
                          ],
                          controller: mapController,
                          trackMyPosition: false,
                          initZoom: getZoomLevel(distance / 2),
                        ),
                        FutureBuilder<Directions>(
                          future: _infoFetch,
                          builder: (context, AsyncSnapshot<Directions> snapshot) {
                            if (snapshot.hasData) {
                              Directions info = snapshot.data;

                              return Positioned(
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
                                    '${double.parse((info.totalDistance).toStringAsFixed(2))} km, ${info.totalDuration.toInt()} mins',
                                    style: const TextStyle(
                                      fontSize: 18.0,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              );
                            } else {
                              return Container();
                            }
                          }
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
      floatingActionButton: StreamProvider<Delivery>.value(
        initialData: Delivery(),
        value: DatabaseService(uid: widget.delivery.uid).deliveryData,
        child: CourierLocationButton(),
      ),
    );
  }
}

class CourierLocationButton extends StatefulWidget {
  const CourierLocationButton({Key key}) : super(key: key);

  @override
  State<CourierLocationButton> createState() => _CourierLocationButtonState();
}

class _CourierLocationButtonState extends State<CourierLocationButton> {
  @override
  Widget build(BuildContext context) {
    final delivery = Provider.of<Delivery>(context);

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
            //   position: LatLng(delivery.courierLocation.latitude, delivery.courierLocation.longitude),
            // );
          });
        }
    );
  }
}
