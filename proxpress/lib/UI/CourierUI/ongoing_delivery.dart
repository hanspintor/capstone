import 'dart:async';
import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart' as cloud;
import 'package:flutter/material.dart';
import 'package:flutter_osm_plugin/flutter_osm_plugin.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:page_transition/page_transition.dart';
import 'package:proxpress/UI/CourierUI/menu_drawer_courier.dart';
import 'package:proxpress/UI/CourierUI/notif_drawer_courier.dart';
import 'package:proxpress/UI/CourierUI/proxpress_template_courier.dart';
import 'package:proxpress/classes/chat_page.dart';
import 'package:proxpress/classes/courier_classes/notif_counter_courier.dart';
import 'package:proxpress/classes/directions_model.dart';
import 'package:proxpress/classes/directions_repository.dart';
import 'package:proxpress/classes/view_delivery_details.dart';
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
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  ValueNotifier<bool> trackingNotifier = ValueNotifier(false);
  MapController mapController;
  int counter = 0;

  @override
  void dispose(){
    super.dispose();
    mapController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ValueNotifier<bool> isDialOpen = ValueNotifier(false);
    String notifM = "";

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
                                return FutureBuilder<cloud.DocumentSnapshot>(
                                  future: cloud.FirebaseFirestore.instance.collection('Deliveries').doc(deliveryOngoingUID).get(),
                                  builder: (context, AsyncSnapshot<dynamic> snapshot){
                                    if (snapshot.hasData) {
                                      Map<String, dynamic> data = snapshot.data.data() as Map<String, dynamic>;

                                      GeoPoint _pickup = GeoPoint(latitude: data['Pickup Coordinates'].latitude, longitude: data['Pickup Coordinates'].longitude);
                                      GeoPoint _dropOff = GeoPoint(latitude: data['DropOff Coordinates'].latitude, longitude: data['DropOff Coordinates'].longitude);

                                      Future<double> distanceInMeters = distance2point(_pickup, _dropOff);

                                      return FutureBuilder<double>(
                                          future: distanceInMeters,
                                          builder: (context, AsyncSnapshot<double> snapshot) {
                                            if (snapshot.hasData) {
                                              double distance = snapshot.data;

                                              GeoPoint midpoint = GeoPoint(latitude: ((_pickup.latitude + _dropOff.latitude) / 2), longitude: ((_pickup.longitude + _dropOff.longitude) / 2));

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

                                              mapController = MapController(
                                                initMapWithUserPosition: false,
                                                initPosition: midpoint,
                                                areaLimit: BoundingBox( east: 123.975219, north: 14.129017, south: 13.261474, west: 122.547888,),
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
                                                      showContributorBadgeForOSM: true,
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

                                                          await mapController.currentLocation();
                                                          await mapController.enableTracking();
                                                        }
                                                      },
                                                      staticPoints: [
                                                        pickup,
                                                        dropOff,
                                                      ],
                                                      controller: mapController,
                                                      initZoom: getZoomLevel(distance / 2),
                                                      onLocationChanged: (loc) async {
                                                        if (counter % 50 == 0) {
                                                          print("$counter");
                                                          print("$loc");
                                                          cloud.GeoPoint courierLocation = cloud.GeoPoint(loc.latitude, loc.longitude);
                                                          await DatabaseService(uid: deliveryOngoingUID).updateCourierLocation(courierLocation);
                                                        }
                                                        if (counter == 500) counter = 0;
                                                        counter++;
                                                      },
                                                      userLocationMarker: UserLocationMaker(
                                                        personMarker: MarkerIcon(
                                                          icon: Icon(
                                                            Icons.location_on_rounded,
                                                            color: Colors.blue,
                                                            size: 100,
                                                          ),
                                                        ),
                                                        directionArrowMarker: MarkerIcon(
                                                          icon: Icon(
                                                            Icons.north,
                                                            color: Colors.blue,
                                                            size: 100,
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
                                      return Container();
                                    }
                                  },
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
                                                      mapController.disabledTracking();
                                                      mapController.dispose();
                                                      setState(() {
                                                        mapController = MapController();
                                                      });
                                                      await cloud.FirebaseFirestore.instance
                                                          .collection('Couriers')
                                                          .doc(delivery.courierRef.id)
                                                          .get()
                                                          .then((cloud.DocumentSnapshot documentSnapshot) {
                                                        if (documentSnapshot.exists) {
                                                          notifM = "${documentSnapshot['First Name']} ${documentSnapshot['Last Name']} successfully delivered your item";
                                                        }
                                                      });
                                                      bool isSeen = false;
                                                      bool popsOnce = true;
                                                      await DatabaseService(uid: user.uid).updateCourierWallet(courierData.wallet + delivery.deliveryFee);
                                                      await DatabaseService(uid: delivery.uid).updateApprovalAndDeliveryStatus('Approved', 'Delivered');
                                                      await DatabaseService().createNotificationData(notifM, delivery.courierRef,
                                                          delivery.customerRef, cloud.Timestamp.now(), isSeen, popsOnce);
                                                      await DatabaseService(uid: delivery.uid).updateTime(cloud.Timestamp.now());
                                                      Navigator.push(context, PageTransition(child: AppBarTemp1(currentPage: "Transaction",), type: PageTransitionType.rightToLeftWithFade));
                                                      showToast('Customer Notified');
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
                                            onTap: () async {
                                              await Navigator.push(context, PageTransition(child: ChatPage(delivery: delivery), type: PageTransitionType.rightToLeftWithFade));
                                              setState((){});
                                            }
                                        ),
                                        SpeedDialChild(
                                            child: Icon(Icons.info_rounded, color: Colors.white,),
                                            backgroundColor: Colors.red,
                                            labelBackgroundColor: Colors.red,
                                            labelStyle: TextStyle(color: Colors.white),
                                            label: 'Delivery Info',
                                            onTap: () {
                                              Navigator.push(context, PageTransition(child: DeliveryDetails(
                                                customer: delivery.customerRef,
                                                courier: delivery.courierRef,
                                                pickupAddress: delivery.pickupAddress,
                                                pickupGeoPoint: delivery.pickupCoordinates,
                                                dropOffAddress: delivery.dropOffAddress,
                                                dropOffGeoPoint: delivery.dropOffCoordinates,
                                                itemDescription: delivery.itemDescription,
                                                pickupPointPerson: delivery.pickupPointPerson ,
                                                pickupContactNum: delivery.pickupContactNum ,
                                                dropOffPointPerson: delivery.dropoffPointPerson ,
                                                dropOffContactNum: delivery.dropoffContactNum ,
                                                whoWillPay: delivery.whoWillPay ,
                                                specificInstructions: delivery.specificInstructions ,
                                                paymentOption: delivery.paymentOption ,
                                                deliveryFee: delivery.deliveryFee ,
                                              ),
                                                  type: PageTransitionType.rightToLeftWithFade));
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
