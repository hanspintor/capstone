import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:proxpress/UI/CourierUI/menu_drawer_courier.dart';
import 'package:proxpress/UI/CourierUI/notif_drawer_courier.dart';
import 'package:proxpress/classes/chat_page.dart';
import 'package:proxpress/classes/courier_classes/delivery_list.dart';
import 'package:proxpress/classes/courier_classes/notif_counter_courier.dart';
import 'package:proxpress/models/couriers.dart';
import 'package:proxpress/Load/user_load.dart';
import 'package:proxpress/UI/login_screen.dart';
import 'package:proxpress/models/deliveries.dart';
import 'package:proxpress/services/database.dart';
import 'package:proxpress/models/user.dart';
import 'package:provider/provider.dart';

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

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<TheUser>(context);
    bool approved = false;
    if(user != null) {
      return StreamBuilder<Courier>(
          stream: DatabaseService(uid: user.uid).courierData,
          builder: (context,snapshot){
            if(snapshot.hasData){
              Courier courierData = snapshot.data;
              approved = courierData.approved;
              Stream<List<Delivery>> deliveryList = FirebaseFirestore.instance
                  .collection('Deliveries')
                  .where('Courier Approval', isEqualTo: 'Pending')
                  .where('Courier Reference', isEqualTo: FirebaseFirestore.instance.collection('Couriers').doc(user.uid))
                  .snapshots()
                  .map(DatabaseService().deliveryDataListFromSnapshot);

              Future<String> deliveryOngoing = FirebaseFirestore.instance.collection('Deliveries')
                  .where('Courier Approval', isEqualTo: 'Approved')
                  .where('Delivery Status', isEqualTo: 'Ongoing')
                  .where('Courier Reference', isEqualTo: FirebaseFirestore.instance.collection('Couriers').doc(user.uid))
                  .get().then((event) async {
                if (event.docs.isNotEmpty) {
                  return event.docs.first.id.toString(); //if it is a single document
                } else {
                  return '';
                }
              });

              return WillPopScope(
                  onWillPop: () async {
                    print("Back Button Pressed");
                    return false;
                  },
                  child: StreamProvider<List<Delivery>>.value(
                    initialData: [],
                    value: deliveryList,
                    child: Scaffold(
                      drawerEnableOpenDragGesture: false,
                      endDrawerEnableOpenDragGesture: false,
                      key: _scaffoldKey,
                      appBar: AppBar(
                        backgroundColor: Colors.white,
                        iconTheme: IconThemeData(color: Color(0xfffb0d0d)
                        ),
                        actions: <Widget>[
                          NotifCounterCourier(scaffoldKey: _scaffoldKey,approved: approved,)
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
                            SizedBox(height: 10),
                            Align(
                              alignment: Alignment.bottomCenter,
                              child: Text("Ongoing Delivery",
                                style: TextStyle(
                                  fontSize: 25,
                                ),
                              ),
                            ),
                            SizedBox(height: 10),
                            Container(
                              height: 400,
                              width: 400,
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.black, width: 3),
                                borderRadius: BorderRadius.all(Radius.circular(5)),
                                color: Colors.black
                              ),
                              child: GoogleMap(
                                myLocationButtonEnabled: false,
                                zoomControlsEnabled: false,
                                initialCameraPosition: _initialCameraPosition,
                              ),
                            ),
                            Container(
                              margin: EdgeInsets.symmetric(vertical: 8),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  FutureBuilder<String>(
                                    future: deliveryOngoing,
                                    builder: (context, AsyncSnapshot<dynamic> snapshot) {
                                      if (snapshot.hasData) {
                                        String deliveryOngoingUID = snapshot.data;

                                        return StreamBuilder<Delivery>(
                                            stream: DatabaseService(uid: deliveryOngoingUID).deliveryData,
                                            builder: (context, snapshot) {
                                              if (snapshot.hasData) {
                                                Delivery delivery = snapshot.data;

                                                if(delivery.deliveryStatus == "Ongoing"){
                                                  return Container(
                                                      height: 25,
                                                      child: (() {
                                                        return ElevatedButton(
                                                            child: Text('Chat Courier', style: TextStyle(color: Colors.white, fontSize: 10),),
                                                            onPressed: () {
                                                              Navigator.push(context, MaterialPageRoute(builder: (context) => ChatPage(delivery: delivery)));
                                                            }
                                                        );
                                                      }())
                                                  );
                                                } else{
                                                  return Container(
                                                      height: 25,
                                                      child: (() {
                                                        return ElevatedButton(
                                                          child: Text('Chat Courier', style: TextStyle(color: Colors.white, fontSize: 10),),
                                                          onPressed: null,
                                                        );
                                                      }())
                                                  );
                                                }
                                              }

                                              else {
                                                return Container(
                                                    height: 25,
                                                    child: (() {
                                                      return ElevatedButton(
                                                        child: Text('Chat Courier', style: TextStyle(color: Colors.white, fontSize: 10),),
                                                        onPressed: null,
                                                      );
                                                    }())
                                                );
                                              }
                                            }
                                        );
                                      } else {
                                        return Container(
                                            height: 25,
                                            child: (() {
                                              return ElevatedButton(
                                                child: Text('Chat Courier', style: TextStyle(color: Colors.white, fontSize: 10),),
                                                onPressed: null,
                                              );
                                            }())
                                        );
                                      }
                                    },

                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  )
              );
            } else {
              return UserLoading();
            }
          }
      );
    }
    else return LoginScreen();
  }
}
