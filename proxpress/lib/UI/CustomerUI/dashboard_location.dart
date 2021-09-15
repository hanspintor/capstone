import 'package:flutter/material.dart';
import 'package:proxpress/Load/user_load.dart';
import 'package:proxpress/UI/CustomerUI/dashboard_customer.dart';
import 'package:proxpress/UI/login_screen.dart';
import 'package:proxpress/services/auth.dart';
import 'package:proxpress/services/secrets.dart';
import 'menu_drawer_customer.dart';
import 'notif_drawer_customer.dart';
import 'package:proxpress/services/database.dart';
import 'package:proxpress/models/user.dart';
import 'package:provider/provider.dart';
import 'package:proxpress/models/customers.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'dart:async';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'dart:math' show cos, sqrt, asin;

class DashboardLocation extends StatefulWidget{
  @override
  _DashboardLocationState createState() => _DashboardLocationState();
}

class _DashboardLocationState extends State<DashboardLocation>{
  // Object for PolylinePoints
  PolylinePoints polylinePoints;

  // List of coordinates to join
  List<LatLng> polylineCoordinates = [];

  // Map storing polylines created by connecting two points
  Map<PolylineId, Polyline> polylines = {};

  // Create the polylines for showing the route between two places
  Future<double> _createPolylines(
      double startLatitude,
      double startLongitude,
      double destinationLatitude,
      double destinationLongitude,
      ) async {
    // Initializing PolylinePoints
    polylinePoints = PolylinePoints();

    // Generating the list of coordinates to be used for
    // drawing the polylines
    PolylineResult result = await polylinePoints.getRouteBetweenCoordinates(
      Secrets.API_KEY, // Google Maps API Key
      PointLatLng(startLatitude, startLongitude),
      PointLatLng(destinationLatitude, destinationLongitude),
      travelMode: TravelMode.transit,
    );

    // Adding the coordinates to the list
    if (result.points.isNotEmpty) {
      result.points.forEach((PointLatLng point) {
        polylineCoordinates.add(LatLng(point.latitude, point.longitude));
      });
    }

    // Defining an ID
    PolylineId id = PolylineId('poly');

    // Initializing Polyline
    Polyline polyline = Polyline(
      polylineId: id,
      color: Colors.red,
      points: polylineCoordinates,
      width: 3,
    );

    // Adding the polyline to the map
    polylines[id] = polyline;

    // Calculating the total distance by adding the distance between small segments
    for (int i = 0; i < polylineCoordinates.length - 1; i++) {
      totalDistance += _coordinateDistance(
        polylineCoordinates[i].latitude,
        polylineCoordinates[i].longitude,
        polylineCoordinates[i + 1].latitude,
        polylineCoordinates[i + 1].longitude,
      );
    }

    return totalDistance;
  }

  double _coordinateDistance(lat1, lon1, lat2, lon2) {
    var p = 0.017453292519943295;
    var c = cos;
    var a = 0.5 -
        c((lat2 - lat1) * p) / 2 +
        c(lat1 * p) * c(lat2 * p) * (1 - c((lon2 - lon1) * p)) / 2;
    return 12742 * asin(sqrt(a));
  }

  double totalDistance = 0.0;

  String pickupAddress;
  LatLng pickupCoordinates;

  String dropOffAddress;
  LatLng dropOffCoordinates;

  dynamic pickupDetails;
  dynamic dropOffDetails;

  int duration = 60;
  int count = 0;
  final AuthService _auth = AuthService();
  final textFieldPickup = TextEditingController();
  final textFieldDropOff = TextEditingController();

  void _validate(){
    if(!locKey.currentState.validate()){
      return;
    }
    locKey.currentState.save();
    print (pickupAddress);
    print (dropOffAddress);
  }

  void _openEndDrawer() {
    _scaffoldKey.currentState.openEndDrawer();
  }

  final GlobalKey<FormState> locKey = GlobalKey<FormState>();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  static Timer _sessionTimer;
  static Timer _sessionTimerPrint;
  void handleTimeOut() async{
    await _auth.signOut();
  }

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<TheUser>(context);

      return new GestureDetector(
        onTap: (){
          if(count != 0){
            print("Session Revived");
          } else {
            print("Session Started");
            count=1;
          }
          _sessionTimer?.cancel();
          _sessionTimer = new Timer(Duration(minutes: duration), handleTimeOut);
          _sessionTimerPrint?.cancel();
          _sessionTimerPrint = new Timer(Duration(minutes: duration), () {
            print("Session Expired");
          });

        },
        child: user == null ? LoginScreen() : StreamBuilder<Customer>(
            stream: DatabaseService(uid: user.uid).customerData,
            builder: (context, snapshot) {
              //print('yoyo ${snapshot.hasData} ${user.uid}');
              if(snapshot.hasData){
                Customer customerData = snapshot.data;
                return WillPopScope(
                  onWillPop: () async {
                    print("Back Button pressed");
                    return false;
                  },
                  child: Scaffold(
                    drawerEnableOpenDragGesture: false,
                    endDrawerEnableOpenDragGesture: false,
                    key: _scaffoldKey,
                    appBar: AppBar(
                      backgroundColor: Colors.white,
                      iconTheme: IconThemeData(
                        color: Color(0xfffb0d0d),
                      ),
                      actions: [
                        IconButton(
                          icon: Icon(
                            Icons.notifications_none_rounded,
                          ),
                          onPressed: () {
                            _openEndDrawer();
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
                    drawer: MainDrawerCustomer(),
                    endDrawer: NotifDrawerCustomer(),
                    body: SingleChildScrollView(
                      child: Center(
                        child: Column(
                          children: [
                            SizedBox(height: 10),
                            Align(
                              alignment: Alignment.bottomCenter,
                              child: Text("Welcome ${customerData.fName}",
                                style: TextStyle(
                                  fontSize: 25,
                                ),
                              ),
                            ),
                            Container(
                              margin: EdgeInsets.only(
                                  right: 40, left: 40, bottom: 40, top: 100),
                              child: Form(
                                key: locKey,
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
                                          controller: textFieldPickup,
                                          enableInteractiveSelection: false,
                                          onTap: () async {
                                            FocusScope.of(context).requestFocus(new FocusNode());

                                            pickupDetails = await Navigator.pushNamed(context, '/pinLocationMap');

                                            print("niceee ${pickupDetails.address}");
                                            textFieldPickup.text = pickupDetails.address;
                                            textFieldPickup.selection = TextSelection.fromPosition(TextPosition(offset: 0));

                                            print("niceee2 ${pickupDetails.coordinates.toString()}");
                                            pickupCoordinates = pickupDetails.coordinates;

                                            setState(() => pickupAddress = textFieldPickup.text);
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
                                          controller: textFieldDropOff,
                                          enableInteractiveSelection: false,
                                          onTap: () async {
                                            FocusScope.of(context).requestFocus(new FocusNode());

                                            dropOffDetails = await Navigator.pushNamed(context, '/pinLocationMap');

                                            print("niceee ${dropOffDetails.address}");
                                            textFieldDropOff.text = dropOffDetails.address;
                                            textFieldDropOff.selection = TextSelection.fromPosition(TextPosition(offset: 0));

                                            print("niceee2 ${dropOffDetails.coordinates.toString()}");
                                            dropOffCoordinates = dropOffDetails.coordinates;

                                            setState(() => dropOffAddress = textFieldDropOff.text);
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
                                if (locKey.currentState.validate()) {
                                  print("${pickupCoordinates.latitude}, ${pickupCoordinates.longitude}, ${dropOffCoordinates.latitude}, ${dropOffCoordinates.longitude}");

                                  double distance = await _createPolylines(pickupCoordinates.latitude, pickupCoordinates.longitude, dropOffCoordinates.latitude, dropOffCoordinates.longitude);
                                  totalDistance = 0.0;
                                  polylinePoints = PolylinePoints();
                                  polylineCoordinates = [];
                                  polylines = {};

                                  print("${distance} KM");

                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            DashboardCustomer(
                                                      pickupAddress:
                                                          pickupAddress,
                                                      pickupCoordinates:
                                                          pickupCoordinates,
                                                      dropOffAddress:
                                                          dropOffAddress,
                                                      dropOffCoordinates:
                                                          dropOffCoordinates,
                                                      distance:
                                                          distance,),
                                      ));
                                }
                              },
                            ),
                          ],
                        ),
                      ),
                    ))
                );
              } else {
                return UserLoading();
              }
            }
        ),
      );
  }
}