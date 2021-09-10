import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:proxpress/UI/CourierUI/menu_drawer_courier.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:proxpress/UI/CourierUI/notif_drawer_courier.dart';
import 'package:proxpress/classes/courier_list.dart';
import 'package:proxpress/classes/delivery_list.dart';
import 'package:proxpress/models/couriers.dart';
import 'package:proxpress/Load/user_load.dart';
import 'package:proxpress/UI/login_screen.dart';
import 'package:proxpress/models/deliveries.dart';
import 'package:proxpress/services/database.dart';
import 'package:proxpress/models/user.dart';
import 'package:provider/provider.dart';


class CourierDashboard extends StatefulWidget {
  final String pickupAddress;
  final LatLng pickupCoordinates;
  final String dropOffAddress;
  final LatLng dropOffCoordinates;
  final double distance;

  CourierDashboard({
    Key key,
    @required this.pickupAddress,
    @required this.pickupCoordinates,
    @required this.dropOffAddress,
    @required this.dropOffCoordinates,
    @required this.distance,
  }) : super(key: key);

  @override
  State<CourierDashboard> createState() => _CourierDashboardState();
}

class _CourierDashboardState extends State<CourierDashboard> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  void _openEndDrawer() {
    _scaffoldKey.currentState.openEndDrawer();
  }

  Widget _welcomeMessage(){
    String welcomeMessage = "Thank you for registering in PROXpress. "
        "Please wait for up to 24 hours for the admin to check and verify your uploaded credentials. "
        "This is to ensure that you are qualified to be a courier in our app.";

    return Container(
      margin: EdgeInsets.fromLTRB(20, 40, 20, 0),
      child: Align(
        child: Text(welcomeMessage,
          textAlign: TextAlign.justify,
          style: TextStyle(
            fontSize: 20,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final FirebaseAuth _auth = FirebaseAuth.instance;
    User user = _auth.currentUser;
    bool approved = false;

    if(user != null) {
      return StreamBuilder<Courier>(
          stream: DatabaseService(uid: user.uid).courierData,
          builder: (context,snapshot){
            if(snapshot.hasData){
              Courier courierData = snapshot.data;

              approved = courierData.approved;

              return WillPopScope(
                onWillPop: () async {
                  print("Back Button Pressed");
                  return false;
                },
                child: StreamProvider<List<Delivery>>.value(
                  value: FirebaseFirestore.instance
                      .collection('Deliveries')
                      .where('Courier Reference', isEqualTo: FirebaseFirestore.instance.collection('Couriers').doc(user.uid))
                      .snapshots()
                      .map(DatabaseService().deliveryDataListFromSnapshot),
                  initialData: [],
                  child: Scaffold(
                    drawerEnableOpenDragGesture: false,
                    endDrawerEnableOpenDragGesture: false,
                    key: _scaffoldKey,
                    appBar: AppBar(
                      backgroundColor: Colors.white,
                      iconTheme: IconThemeData(color: Color(0xfffb0d0d)
                      ),
                      actions:[
                        IconButton(
                          icon: Icon(Icons.notifications_none_rounded),
                          onPressed: (){
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
                    ),
                    drawer: MainDrawerCourier(),
                    endDrawer: NotifDrawerCourier(),
                    body: SingleChildScrollView(
                      child: Center(
                        child: Column(
                          children: [
                            SizedBox(height: 10),
                            Align(
                              alignment: Alignment.bottomCenter,
                              child: Text("Welcome, ${courierData.fName}!",
                                style: TextStyle(
                                  fontSize: 25,
                                ),
                              ),
                            ),
                            !approved ? _welcomeMessage() : Container(
                              child: Text('Customer Requests Here'),
                            ),
                            Card(
                              margin: EdgeInsets.all(20),
                              // child: DeliveryList(),
                              // shadowColor: Colors.black,
                              // shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(10))),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              );
            }
            else return UserLoading();
          }
      );
    }
    else return LoginScreen();
  }
}
