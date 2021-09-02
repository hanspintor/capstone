import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:proxpress/classes/courier_list.dart';
import 'package:proxpress/models/couriers.dart';
import 'package:proxpress/services/database.dart';

class DashboardCustomer extends StatefulWidget{
  @override
  _DashboardCustomerState createState() => _DashboardCustomerState();
}

class Couriers {
  String firstName = '';
  String lastName = '';
  String vehicleType = '';
  String vehicleColor= '';
  double price = 0;
  String icon = '';

  Couriers({ this.firstName, this.lastName, this.vehicleType, this.vehicleColor, this.price, this.icon });
}

class _DashboardCustomerState extends State<DashboardCustomer> {
  List<Couriers> couriers = [
    Couriers(firstName: 'Pedro', lastName: 'Penduko', vehicleType: 'Sedan', vehicleColor: 'Red', price: 120,),
    Couriers(firstName: 'Pedro', lastName: 'Penduko', vehicleType: 'Sedan', vehicleColor: 'Red', price: 120,),
  ];

  void _openEndDrawer() {
    _scaffoldKey.currentState.openEndDrawer();
  }

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

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  Widget _buildInfo(){
    return Center(
      child: Card(
        margin:EdgeInsets.only(bottom: 30),
        child: InkWell(
          onTap: (){
            showDialog(
                context: context, builder: (BuildContext context) => AlertDialog(
              content: (_alertmessage()),
            )
            );
          },
          child: SizedBox(
            width: 110,
            height: 50,
            child: Container(
              margin:EdgeInsets.only(left: 10),
              child: Text("Name:  \nVehicle:  \nDescription: \nPrice: ",textAlign: TextAlign.justify, style: TextStyle(fontSize: 10)),
            ),
          ),
        ),
        shadowColor: Colors.black,
        color:Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(10)),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return StreamProvider<List<Courier>>.value(
      value: DatabaseService().courierList,
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
            child: Center(
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
                    child: Column(
                      children: [
                        Container(
                          margin: EdgeInsets.only(top: 25),
                          child: SizedBox(
                            height: 40,
                            width: 250,
                            child: TextField(
                              decoration: InputDecoration(
                                  hintText: 'Search',
                                  hintStyle: TextStyle(
                                    fontSize: 16.0,
                                    color: Colors.black54,
                                  ),
                                  contentPadding: EdgeInsets.all(10.0),
                                  prefixIcon: Icon(Icons.search_rounded),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(20.0),
                                  borderSide: BorderSide(
                                      color: Colors.grey,
                                      width: 2.0,

                                  ),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(20.0),
                                  borderSide: BorderSide(
                                    color: Colors.redAccent,
                                    width: 2.0,

                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                        CourierList(),
                      ],
                    ),
                  shadowColor: Colors.black,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(10))),
                  ),
                ],
              ),
            ),
          )
      ),
    );
  }
}