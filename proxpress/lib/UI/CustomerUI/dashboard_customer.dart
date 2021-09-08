import 'dart:async';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:proxpress/UI/login_screen.dart';
import 'package:proxpress/classes/courier_list.dart';
import 'package:proxpress/models/couriers.dart';
import 'package:proxpress/models/user.dart';
import 'package:proxpress/services/auth.dart';
import 'package:proxpress/services/database.dart';

class DashboardCustomer extends StatefulWidget{
  final String pickupAddress;
  final LatLng pickupCoordinates;
  final String dropOffAddress;
  final LatLng dropOffCoordinates;

  DashboardCustomer({
    Key key,
    @required this.pickupAddress,
    @required this.pickupCoordinates,
    @required this.dropOffAddress,
    @required this.dropOffCoordinates,
  }) : super(key: key);

  @override
  _DashboardCustomerState createState() => _DashboardCustomerState();
}

class _DashboardCustomerState extends State<DashboardCustomer> {

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  TextEditingController _searchController = TextEditingController();
  String searched = '';
  final AuthService _auth = AuthService();
  static Timer _sessionTimer;
  static Timer _sessionTimerPrint;
  int count = 0;
  int duration = 60;

  void handleTimeOut() async{
    await _auth.signOut();
  }
  @override
  void initState(){
    super.initState();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  _onSearchChanged() {
    print(_searchController.text);
    searched = _searchController.text;
  }

  // void _openEndDrawer() {
  //   _scaffoldKey.currentState.openEndDrawer();
  // }

  Widget _alertmessage(){
    return Center(
      child: Column(
        children: [
          Container(
            child: Text("Bitch"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    print(widget.pickupAddress);
    print(widget.pickupCoordinates.toString());

    print(widget.dropOffAddress);
    print(widget.dropOffCoordinates.toString());

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
      child: user == null ? LoginScreen() : StreamProvider<List<Courier>>.value(
        value: DatabaseService().courierList,
        initialData: [],
        child: Scaffold(
            drawerEnableOpenDragGesture: false,
            endDrawerEnableOpenDragGesture: false,
            key:_scaffoldKey,
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
            body: SingleChildScrollView(
              child: Container(
                child: Column(
                  children: [
                    SizedBox(height: 10),
                    Align(
                      alignment: Alignment.bottomCenter,
                      child: Text(
                        "Couriers Available",
                        style: TextStyle(
                          fontSize: 25,
                        ),
                      ),
                    ),
                    Card(
                      margin: EdgeInsets.all(20),
                      child: CourierList(
                                pickupAddress: widget.pickupAddress,
                                pickupCoordinates: widget.pickupCoordinates,
                                dropOffAddress: widget.dropOffAddress,
                                dropOffCoordinates: widget.dropOffCoordinates),
                      shadowColor: Colors.black,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(10))),
                    ),
                  ],
                ),
              ),
            )
        ),
      ),
    );
  }
}