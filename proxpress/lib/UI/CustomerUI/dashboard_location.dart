import 'package:flutter/material.dart';
import 'package:proxpress/Load/user_load.dart';
import 'package:proxpress/UI/CustomerUI/pin_location_map.dart';
import 'package:proxpress/UI/login_screen.dart';
import 'package:proxpress/services/auth.dart';
import 'menu_drawer_customer.dart';
import 'notif_drawer_customer.dart';
import 'package:proxpress/services/database.dart';
import 'package:proxpress/models/user.dart';
import 'package:provider/provider.dart';
import 'package:proxpress/models/customers.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'dart:async';

class DashboardLocation extends StatefulWidget{
  @override
  _DashboardLocationState createState() => _DashboardLocationState();
}

class _DashboardLocationState extends State<DashboardLocation>{
  String _pickupAddress;
  LatLng pickupCoordinates;

  String _dropOffAddress;
  LatLng dropOffCoordinates;

  int duration = 1;
  int count = 0;
  final AuthService _auth = AuthService();
  final textFieldPickup = TextEditingController();
  final textFieldDropOff = TextEditingController();

  void _validate(){
    if(!locKey.currentState.validate()){
      return;
    }
    locKey.currentState.save();
    print (_pickupAddress);
    print (_dropOffAddress);
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
                                          onTap: () async {
                                            dynamic pickupDetails = await Navigator.pushNamed(context, '/pinLocationMap');

                                            print("niceee ${pickupDetails.address}");
                                            textFieldPickup.text = pickupDetails.address;
                                            textFieldPickup.selection = TextSelection.fromPosition(TextPosition(offset: 0));

                                            print("niceee2 ${pickupDetails.coordinates.toString()}");
                                            pickupCoordinates = pickupDetails.coordinates;
                                          },
                                          decoration: InputDecoration(labelText: 'Pick up location', prefixIcon: Icon(Icons.location_searching_rounded)),
                                          keyboardType: TextInputType.streetAddress,
                                          validator: (String value){
                                            if(value.isEmpty){
                                              return 'Pick up location is required';
                                            } else {
                                              return null;
                                            }
                                          },
                                          onSaved: (String value){
                                            _pickupAddress = value;
                                          },
                                        ),
                                      ),
                                      Container(
                                        margin: EdgeInsets.symmetric(horizontal: 35, vertical: 23),
                                        child: TextFormField(
                                          controller: textFieldDropOff,
                                          onTap: () async {
                                            dynamic dropOffDetails = await Navigator.pushNamed(context, '/pinLocationMap');

                                            print("niceee ${dropOffDetails.address}");
                                            textFieldDropOff.text = dropOffDetails.address;
                                            textFieldDropOff.selection = TextSelection.fromPosition(TextPosition(offset: 0));

                                            print("niceee2 ${dropOffDetails.coordinates.toString()}");
                                            dropOffCoordinates = dropOffDetails.coordinates;
                                          },
                                          decoration: InputDecoration(labelText: 'Pick up location', prefixIcon: Icon(Icons.location_searching_rounded)),
                                          keyboardType: TextInputType.streetAddress,
                                          validator: (String value){
                                            if(value.isEmpty){
                                              return 'Drop off location is required';
                                            } else {
                                              return null;
                                            }
                                          },
                                          onSaved: (String value){
                                            _dropOffAddress = value;
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
                              onPressed: () {
                                if (locKey.currentState.validate()) {
                                  Navigator.pushNamed(context, '/dashboardCustomer');
                                }
                              },
                            ),
                          ],
                        ),
                      ),
                    ))
                );
              } else{
                return UserLoading();
              }
            }
        ),
      );
  }
}