import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:proxpress/Load/user_load.dart';
import 'package:proxpress/UI/CustomerUI/dashboard_customer.dart';
import 'package:proxpress/UI/login_screen.dart';
import 'package:proxpress/classes/courier_classes/notif_counter_courier.dart';
import 'package:proxpress/classes/customer_classes/notif_counter_customer.dart';
import 'package:proxpress/classes/directions_model.dart';
import 'package:proxpress/classes/directions_repository.dart';
import 'package:proxpress/models/deliveries.dart';
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

  String error = '';

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<TheUser>(context);

    bool approved = true;
    // must get this from cloud firestore
    Map currentBookmarks = {};

    // this what happens when clicking bookmark button (1st time)
    print(currentBookmarks.length);
    Map addBookmark = {'courier${currentBookmarks.length}': 'courier${currentBookmarks.length}\'s UID'};
    currentBookmarks.addAll(addBookmark);
    print(currentBookmarks);

    // this what happens when clicking bookmark button (2nd time)
    print(currentBookmarks.length);
    Map addBookmark2 = {'courier${currentBookmarks.length}': 'courier${currentBookmarks.length}\'s UID'};
    currentBookmarks.addAll(addBookmark2);

    print(currentBookmarks.length);
    print(currentBookmarks);
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
          if(snapshot.hasData){
            Customer customerData = snapshot.data;

            Stream<List<Delivery>> deliveryList = FirebaseFirestore.instance
                .collection('Deliveries')
                .where('Customer Reference', isEqualTo: FirebaseFirestore.instance.collection('Customers').doc(user.uid))
                .snapshots()
                .map(DatabaseService().deliveryDataListFromSnapshot);

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
                    StreamProvider<List<Delivery>>.value(
                        value: deliveryList,
                        initialData: [],
                        child: NotifCounterCustomer(scaffoldKey: _scaffoldKey, approved: approved,)
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
                          child: Text("Welcome, ${customerData.fName}!",
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
                    ),
                  ),
                ),
              ),
            );
          } else {
            return UserLoading();
          }
        }
      ),
    );
  }
}