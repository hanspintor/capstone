import 'package:flutter/material.dart';
import 'menu_drawer.dart';
import 'notif_drawer.dart';
import 'package:proxpress/services/database.dart';
import 'package:provider/provider.dart';
import 'package:proxpress/List/customer_list.dart';
import 'package:proxpress/models/customers.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class DashboardLocation extends StatefulWidget{
  @override
  _DashboardLocationState createState() => _DashboardLocationState();
}

class _DashboardLocationState extends State<DashboardLocation>{
  String _pickup;
  String _dropoff;
  final Customer customer;
  _DashboardLocationState({ this.customer});

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

  Widget _alertmessage(){
    return null;
  }

  final GlobalKey<FormState> locKey = GlobalKey<FormState>();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  Widget _buildPickup(){
    return TextFormField(
      decoration: InputDecoration(labelText: 'Pick up location', prefixIcon: Icon(Icons.location_searching_rounded)),
      keyboardType: TextInputType.streetAddress,
      validator: (String value){
        if(value.isEmpty){
          return 'Pick up location is required';
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
        }
      },
      onSaved: (String value){
        _dropoff = value;
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return StreamProvider<List<Customer>>.value(
      value: DatabaseService().Customers,
      child: WillPopScope(
        onWillPop: () async {
          print("Back Button pressed");
          return false;
        },
        child: StreamBuilder(
            stream: FirebaseFirestore.instance.collection('Customers').snapshots(),
            builder: (context, snapshot){
              if(!snapshot.hasData)
                return Text('Loading data.. Please wait');
              return Scaffold(
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
                  drawer: MainDrawer(),
                  endDrawer: NotifDrawer(),
                  body: SingleChildScrollView(
                    child: Center(
                      child: Column(
                        children: [
                          SizedBox(height: 10),
                          Align(
                            alignment: Alignment.bottomCenter,
                            child: Text(
                              "Welcome ${snapshot.data.docs[0]['First Name']}",
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
                                      child: _buildPickup(),
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
                              'Proceed',
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
                  ));

            }
        ),
      ),
    );
  }
}

