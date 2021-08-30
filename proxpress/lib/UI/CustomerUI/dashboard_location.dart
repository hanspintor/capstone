import 'package:flutter/material.dart';
import 'package:proxpress/Load/user_load.dart';
import 'package:proxpress/UI/login_screen.dart';
import 'menu_drawer_customer.dart';
import 'notif_drawer_customer.dart';
import 'package:proxpress/services/database.dart';
import 'package:proxpress/models/user.dart';
import 'package:provider/provider.dart';
import 'package:proxpress/models/customers.dart';
import 'dart:async';


import 'package:google_maps_place_picker/google_maps_place_picker.dart';

class DashboardLocation extends StatefulWidget{
  @override
  _DashboardLocationState createState() => _DashboardLocationState();
}

class _DashboardLocationState extends State<DashboardLocation>{
  String _pickup;
  String _dropoff;
  PickResult _selectedPickup;
  PickResult _selectedDropoff;

  final textFieldController = TextEditingController();

  void _validate(){
    if(!locKey.currentState.validate()){
      return;
    }
    locKey.currentState.save();
    print (_pickup);
    print (_dropoff);
  }

  void _openEndDrawer() {
    _scaffoldKey.currentState.openEndDrawer();
  }

  // Widget _alertmessage(){
  //   return null;
  // }

  final GlobalKey<FormState> locKey = GlobalKey<FormState>();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  Widget _buildPickup(){
    return TextFormField(
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
        _pickup = value;
      },
    );
  }

  Widget _buildDropoff(){
    return TextFormField(
      decoration: InputDecoration(labelText: 'Drop off location', prefixIcon: Icon(Icons.place)),
      keyboardType: TextInputType.streetAddress,
      validator: (String value){
        if(value.isEmpty){
          return 'Drop off location is required';
        } else {
          return null;
        }
      },
      onSaved: (String value){
        _dropoff = value;
      },
    );
  }
  @override
  Widget build(BuildContext context) {
    final user = Provider.of<TheUser>(context);

    if (user != null) {
      return  StreamBuilder<Customer>(
          stream: DatabaseService(uid: user.uid).customerData,
          builder: (context, snapshot) {
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
                                          margin:
                                          EdgeInsets.symmetric(horizontal: 35),
                                          child: TextFormField(
                                            controller: textFieldController,
                                            onTap: () async {
                                              dynamic _pickupPin = await Navigator.pushNamed(context, '/pinLocationMap');
                                              print(_pickupPin);
                                              textFieldController.text = _pickupPin;
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
                                              _pickup = value;
                                            },
                                          ),
                                        ),
                                        Container(
                                          margin: EdgeInsets.symmetric(
                                              horizontal: 35, vertical: 23),
                                          child: _buildDropoff(),
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
                                  // _validate();
                                  Navigator.pushNamed(
                                      context, '/dashboardCustomer');
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
      );
    }
    else {
      return LoginScreen();
    }
  }
}

