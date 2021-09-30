import 'dart:async';
import 'dart:math';
import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart' as cloud;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animarker/flutter_map_marker_animation.dart';
import 'package:flutter_animarker/widgets/animarker.dart';
import 'package:flutter_osm_plugin/flutter_osm_plugin.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:page_transition/page_transition.dart';
import 'package:proxpress/UI/CourierUI/menu_drawer_courier.dart';
import 'package:proxpress/UI/CourierUI/notif_drawer_courier.dart';
import 'package:proxpress/UI/CourierUI/transaction_history.dart';
import 'package:proxpress/classes/chat_page.dart';
import 'package:proxpress/classes/courier_classes/delivery_list.dart';
import 'package:proxpress/classes/courier_classes/notif_counter_courier.dart';
import 'package:proxpress/classes/directions_model.dart';
import 'package:proxpress/classes/directions_repository.dart';
import 'package:proxpress/models/couriers.dart';
import 'package:proxpress/Load/user_load.dart';
import 'package:proxpress/UI/login_screen.dart';
import 'package:proxpress/models/deliveries.dart';
import 'package:proxpress/models/notifications.dart';
import 'package:proxpress/services/database.dart';
import 'package:proxpress/models/user.dart';
import 'package:provider/provider.dart';
import 'package:slide_to_act/slide_to_act.dart';

class OngoingDelivery extends StatefulWidget {
  @override
  _OngoingDeliveryState createState() => _OngoingDeliveryState();
}

class _OngoingDeliveryState extends State<OngoingDelivery> {
  static final _initialCameraPosition = CameraPosition(
      target: LatLng(13.621980880497976, 123.19477396693487),
      zoom: 15
  );

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  StreamSubscription _locationSubscription;
  Location _locationTracker = Location();
  GoogleMapController _controller;
  Marker marker;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
    if (_locationSubscription != null) {
      _locationSubscription.cancel();
    }
  }

  void updateMarker(LocationData newLocalData, String uid) async {
    LatLng latlng = LatLng(newLocalData.latitude, newLocalData.longitude);
    cloud.GeoPoint courierLocation = cloud.GeoPoint(newLocalData.latitude, newLocalData.longitude);

    print("${newLocalData.latitude}, ${newLocalData.longitude}");

    print(uid);

    await DatabaseService(uid: uid).updateCourierLocation(courierLocation);

    this.setState(() {
      marker = Marker(
        markerId: MarkerId("home"),
        position: latlng,
        draggable: false,
        zIndex: 2,
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure),
        infoWindow: const InfoWindow(title: 'Courier Location'),
      );
    });
  }

  void getCurrentLocation(String uid) async {
    try {
      var location = await _locationTracker.getLocation();

      updateMarker(location, uid);

      if (_locationSubscription != null) {
        _locationSubscription.cancel();
      }

      _locationSubscription = _locationTracker.onLocationChanged.listen((newLocalData) {
        if (_controller != null) {
          updateMarker(newLocalData, uid);
        }
      });
    } on PlatformException catch (e) {
      if (e.code == 'PERMISSION_DENIED') {
        debugPrint("Permission Denied");
      }
    }
  }

  bool flag = true;

  @override
  Widget build(BuildContext context) {
    ValueNotifier<bool> isDialOpen = ValueNotifier(false);

    final user = Provider.of<TheUser>(context);
    bool approved = false;

    if(user != null) {
      Future<String> deliveryOngoing = cloud.FirebaseFirestore.instance.collection('Deliveries')
          .where('Courier Approval', isEqualTo: 'Approved')
          .where('Delivery Status', isEqualTo: 'Ongoing')
          .where('Courier Reference', isEqualTo: cloud.FirebaseFirestore.instance.collection('Couriers').doc(user.uid))
          .get().then((event) async {
        if (event.docs.isNotEmpty) {
          return event.docs.first.id.toString(); //if it is a single document
        } else {
          return '';
        }
      });

      return StreamBuilder<Courier>(
          stream: DatabaseService(uid: user.uid).courierData,
          builder: (context,snapshot){
            if(snapshot.hasData){
              Courier courierData = snapshot.data;
              approved = courierData.approved;
              cloud.DocumentReference courier = cloud.FirebaseFirestore.instance.collection('Couriers').doc(user.uid);
              Stream<List<Notifications>> notifList = cloud.FirebaseFirestore.instance
                  .collection('Notifications')
                  .where('Sent To', isEqualTo: courier)
                  .snapshots()
                  .map(DatabaseService().notifListFromSnapshot);

              return Scaffold(
                drawerEnableOpenDragGesture: false,
                endDrawerEnableOpenDragGesture: false,
                key: _scaffoldKey,
                appBar: AppBar(
                  backgroundColor: Colors.white,
                  iconTheme: IconThemeData(color: Color(0xfffb0d0d)
                  ),
                  actions: <Widget>[
                    StreamProvider<List<Notifications>>.value(
                      value: notifList,
                      initialData: [],
                      child:  NotifCounterCourier(scaffoldKey: _scaffoldKey,approved: approved,),
                    )
                  ],
                  flexibleSpace: Container(
                    margin: EdgeInsets.only(top: 10),
                    child: Image.asset(
                      "assets/PROExpress-logo.png",
                      height: 120,
                      width: 120,
                    ),
                  ),
                ),
                drawer: MainDrawerCourier(),
                endDrawer: NotifDrawerCourier(),
                body: Center(
                  child: Column(
                    children: [
                      FutureBuilder<String>(
                          future: deliveryOngoing,
                          builder: (context, AsyncSnapshot<dynamic> snapshot) {
                            if (snapshot.hasData) {
                              String deliveryOngoingUID = snapshot.data;

                              if (deliveryOngoingUID != '') {
                                return StreamBuilder<Delivery>(
                                    stream: DatabaseService(uid: deliveryOngoingUID).deliveryData,
                                    builder: (context, snapshot) {
                                      if (snapshot.hasData) {
                                        Delivery delivery = snapshot.data;

                                        GeoPoint _pickup = GeoPoint(latitude: delivery.pickupCoordinates.latitude, longitude: delivery.pickupCoordinates.longitude);
                                        GeoPoint _dropOff = GeoPoint(latitude: delivery.dropOffCoordinates.latitude, longitude: delivery.dropOffCoordinates.longitude);

                                        Future<double> distanceInMeters = distance2point(_pickup, _dropOff);

                                        return FutureBuilder<double>(
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
                                                return Expanded(
                                                  child: Stack(
                                                    alignment: Alignment.center,
                                                    children: [
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
                                                            'You currently have no ongoing delivery',
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
                                              }
                                            }
                                        );
                                      } else {
                                        return Expanded(
                                          child: Stack(
                                            alignment: Alignment.center,
                                            children: [
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
                                                    'You currently have no ongoing delivery',
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
                                      }
                                    }
                                );
                              } else {
                                return Expanded(
                                  child: Stack(
                                    alignment: Alignment.center,
                                    children: [
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
                                            'You currently have no ongoing delivery',
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
                              }
                            } else {
                              return Expanded(
                                child: Stack(
                                  alignment: Alignment.center,
                                  children: [
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
                                          'You currently have no ongoing delivery',
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
                            }
                          }
                      ),
                    ],
                  ),
                ),
                floatingActionButton: FutureBuilder<String>(
                  future:deliveryOngoing,
                  builder: (context, AsyncSnapshot<dynamic> snapshot){
                    if(snapshot.hasData){
                      String deliveryOngoingUID = snapshot.data;

                      if(deliveryOngoingUID != ""){
                        return StreamBuilder<Delivery>(
                          stream: DatabaseService(uid:deliveryOngoingUID).deliveryData,
                          builder: (context, snapshot){
                            if(snapshot.hasData){
                              Delivery delivery = snapshot.data;

                              if(delivery.deliveryStatus == "Ongoing"){
                                return Column(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    SpeedDial(
                                      animatedIcon: AnimatedIcons.menu_close,
                                      openCloseDial: isDialOpen,
                                      children: [
                                        SpeedDialChild(
                                            child: Icon(Icons.check_rounded, color: Colors.white,),
                                            backgroundColor: Colors.green,
                                            labelBackgroundColor: Colors.green,
                                            labelStyle: TextStyle(color: Colors.white),
                                            label: 'Notify Delivery',
                                          onTap: () async {
                                            showMaterialModalBottomSheet(
                                              context: context,
                                              builder: (context) => Container(
                                                height: 100,
                                                child: Card(
                                                  child:SlideAction(
                                                    child: Text('Slide to Confirm', style: TextStyle(color: Colors.white),),
                                                    elevation: 4,
                                                    innerColor: Colors.white,
                                                    outerColor: Colors.green,
                                                    onSubmit: () async {
                                                      showToast('Customer Notified');
                                                      if (_locationSubscription != null) {
                                                        _locationSubscription.cancel();
                                                      }
                                                      await DatabaseService(uid: delivery.uid).updateApprovalAndDeliveryStatus('Approved', 'Delivered');
                                                      Navigator.push(context, PageTransition(child: TransactionHistory(), type: PageTransitionType.rightToLeftWithFade));
                                                    },
                                                  ),
                                                ),
                                              ),
                                            );
                                          }
                                        ),
                                        SpeedDialChild(
                                            child: Icon(Icons.message_rounded, color: Colors.white,),
                                            backgroundColor: Colors.red,
                                            labelBackgroundColor: Colors.red,
                                            labelStyle: TextStyle(color: Colors.white),
                                            label: 'Message Customer',
                                            onTap: (){
                                              Navigator.push(context, PageTransition(child: ChatPage(delivery: delivery), type: PageTransitionType.rightToLeftWithFade));
                                            }
                                        ),
                                        SpeedDialChild(
                                            child: Icon(Icons.info_rounded, color: Colors.white,),
                                            backgroundColor: Colors.red,
                                            labelBackgroundColor: Colors.red,
                                            labelStyle: TextStyle(color: Colors.white),
                                            label: 'Delivery Info',
                                            onTap: () {
                                              showMaterialModalBottomSheet(
                                                backgroundColor: Colors.white,
                                                context: context,
                                                builder: (context) => SingleChildScrollView(
                                                  controller: ModalScrollController.of(context),
                                                  child: Container(
                                                    height: 500,
                                                    child: Card(
                                                      child: Column(
                                                        children: [
                                                          ListTile(
                                                            leading: Icon(Icons.info_rounded, color: Colors.black,),
                                                            title: Text("Delivery Information",
                                                              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                                                            ),
                                                            subtitle: Text.rich(
                                                              TextSpan(children: [
                                                                TextSpan(text: '\n'),
                                                                TextSpan(text: "Pick Up Address: ", style: Theme.of(context).textTheme.bodyText2.copyWith(fontWeight: FontWeight.bold)),
                                                                TextSpan(text: "${delivery.pickupAddress}\n", style: Theme.of(context).textTheme.bodyText2),
                                                                TextSpan(text: "Drop Off Address: ", style: Theme.of(context).textTheme.bodyText2.copyWith(fontWeight: FontWeight.bold)),
                                                                TextSpan(text: "${delivery.dropOffAddress}\n", style: Theme.of(context).textTheme.bodyText2),
                                                                TextSpan(text: '\n'),
                                                                TextSpan(text: "Payment Method: ", style: Theme.of(context).textTheme.bodyText2.copyWith(fontWeight: FontWeight.bold)),
                                                                TextSpan(text: "${delivery.paymentOption}\n", style: Theme.of(context).textTheme.bodyText2),
                                                                TextSpan(text: "Delivery Fee: ", style: Theme.of(context).textTheme.bodyText2.copyWith(fontWeight: FontWeight.bold)),
                                                                TextSpan(text: "\₱${delivery.deliveryFee}\n", style: Theme.of(context).textTheme.bodyText2),
                                                              ],
                                                              ),
                                                            ),
                                                          ),
                                                          ListTile(
                                                            leading: Icon(Icons.phone_rounded,color: Colors.black,),
                                                            title: Text("Contact Information",
                                                              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                                                            ),
                                                            subtitle: Text.rich(
                                                              TextSpan(children: [
                                                                TextSpan(text: "Pickup Point Person: ", style: Theme.of(context).textTheme.bodyText2.copyWith(fontWeight: FontWeight.bold)),
                                                                TextSpan(text: "${delivery.pickupPointPerson}\n",style: Theme.of(context).textTheme.bodyText2),
                                                                TextSpan(text: "Contact Number: ", style: Theme.of(context).textTheme.bodyText2.copyWith(fontWeight: FontWeight.bold)),
                                                                TextSpan(text: "${delivery.pickupContactNum}\n",style: Theme.of(context).textTheme.bodyText2),
                                                                TextSpan(text: "\n"),
                                                                TextSpan(text: "Drop Off Point Person: ", style: Theme.of(context).textTheme.bodyText2.copyWith(fontWeight: FontWeight.bold)),
                                                                TextSpan(text: "${delivery.dropoffPointPerson}\n",style: Theme.of(context).textTheme.bodyText2),
                                                                TextSpan(text: "Contact Number: ", style: Theme.of(context).textTheme.bodyText2.copyWith(fontWeight: FontWeight.bold)),
                                                                TextSpan(text: "${delivery.dropoffContactNum}\n",style: Theme.of(context).textTheme.bodyText2),
                                                              ],
                                                              ),
                                                            ),
                                                          ),
                                                          ListTile(
                                                            leading: Icon(Icons.description,color: Colors.black,),
                                                            title: Text("Additional Information", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),),
                                                            subtitle: Container(
                                                              padding: EdgeInsets.only(top: 5),
                                                              child: Text.rich(
                                                                TextSpan(children: [
                                                                  TextSpan(text: "Item Description: ", style: Theme.of(context).textTheme.bodyText2.copyWith(fontWeight: FontWeight.bold)),
                                                                  TextSpan(text: "${delivery.itemDescription}\n",style: Theme.of(context).textTheme.bodyText2),
                                                                  TextSpan(text: "Specific Instructions: \n", style: Theme.of(context).textTheme.bodyText2.copyWith(fontWeight: FontWeight.bold)),
                                                                  TextSpan(text: "${delivery.specificInstructions}\n",style: Theme.of(context).textTheme.bodyText2),
                                                                ],
                                                                ),
                                                              ),
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              );
                                            }
                                        ),
                                      ],
                                    ),
                                  ],
                                );
                              }
                              else return Container();
                            }
                            else return Container();
                          },
                        );
                      }
                      else return FloatingActionButton(
                        onPressed: null,
                        child: Icon(Icons.menu),
                        backgroundColor: Colors.grey,
                        heroTag: 'null',
                      );
                    }
                    else return Container();
                  }
                ),
              );
            } else {
              return UserLoading();
            }
          }
      );
    }
    else return LoginScreen();
  }
  Future showToast(String message) async {
    await Fluttertoast.cancel();
    Fluttertoast.showToast(msg: message, fontSize: 18, backgroundColor: Colors.green, textColor: Colors.white);
  }
}
