import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
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
                            Expanded(
                              child: GoogleMap(
                                myLocationButtonEnabled: false,
                                zoomControlsEnabled: false,
                                initialCameraPosition: _initialCameraPosition,
                              ),
                            ),
                            // Container(
                            //   margin: EdgeInsets.symmetric(vertical: 8),
                            //   child: Row(
                            //     mainAxisAlignment: MainAxisAlignment.center,
                            //     children: [
                            //       FutureBuilder<String>(
                            //         future: deliveryOngoing,
                            //         builder: (context, AsyncSnapshot<dynamic> snapshot) {
                            //           if (snapshot.hasData) {
                            //             String deliveryOngoingUID = snapshot.data;
                            //
                            //
                            //              if(deliveryOngoingUID != ""){
                            //                return StreamBuilder<Delivery>(
                            //                    stream: DatabaseService(uid: deliveryOngoingUID).deliveryData,
                            //                    builder: (context, snapshot) {
                            //                      if (snapshot.hasData) {
                            //                        Delivery delivery = snapshot.data;
                            //
                            //                        if(delivery.deliveryStatus == "Ongoing"){
                            //                          return Container(
                            //                              height: 25,
                            //                              child: (() {
                            //                                return ElevatedButton(
                            //                                    child: Text('Chat Courier', style: TextStyle(color: Colors.white, fontSize: 10),),
                            //                                    onPressed: () {
                            //                                      Navigator.push(context, MaterialPageRoute(builder: (context) => ChatPage(delivery: delivery)));
                            //                                    }
                            //                                );
                            //                              }())
                            //                          );
                            //                        } else{
                            //                          return Container(
                            //                              height: 25,
                            //                              child: (() {
                            //                                return ElevatedButton(
                            //                                  child: Text('Chat Courier', style: TextStyle(color: Colors.white, fontSize: 10),),
                            //                                  onPressed: null,
                            //                                );
                            //                              }())
                            //                          );
                            //                        }
                            //                      }
                            //
                            //                      else {
                            //                        return Container(
                            //                            height: 25,
                            //                            child: (() {
                            //                              return ElevatedButton(
                            //                                child: Text('Chat Courier', style: TextStyle(color: Colors.white, fontSize: 10),),
                            //                                onPressed: null,
                            //                              );
                            //                            }())
                            //                        );
                            //                      }
                            //                    }
                            //                );
                            //              } else{
                            //                return Container(
                            //                    height: 25,
                            //                    child: (() {
                            //                      return ElevatedButton(
                            //                        child: Text('Chat Courier', style: TextStyle(color: Colors.white, fontSize: 10),),
                            //                        onPressed: null,
                            //                      );
                            //                    }())
                            //                );
                            //              }
                            //           } else {
                            //             return Container(
                            //                 height: 25,
                            //                 child: (() {
                            //                   return ElevatedButton(
                            //                     child: Text('Chat Courier', style: TextStyle(color: Colors.white, fontSize: 10),),
                            //                     onPressed: null,
                            //                   );
                            //                 }())
                            //             );
                            //           }
                            //         },
                            //
                            //       ),
                            //     ],
                            //   ),
                            // ),
                          ],
                        ),
                      ),
                      floatingActionButton: FutureBuilder<String>(
                        future:deliveryOngoing,
                        builder: (context, AsyncSnapshot<dynamic> snapshot){
                          if(snapshot.hasData){
                            String deliveryOngoingUID = snapshot.data;
                            print(deliveryOngoingUID);

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
                                          SizedBox(height: 10),
                                          FloatingActionButton(
                                            onPressed: (){
                                              showMaterialModalBottomSheet(
                                                backgroundColor: Colors.white,
                                                context: context,
                                                builder: (context) => SingleChildScrollView(
                                                  controller: ModalScrollController.of(context),
                                                  child: Container(
                                                    height: 400,
                                                      child: Card(
                                                        child: Column(
                                                          children: [
                                                            ListTile(
                                                              leading: Icon(Icons.info_rounded, color: Colors.black,),
                                                              title: Text("Delivery Information",
                                                                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                                                              ),
                                                              subtitle: Text.rich(
                                                                TextSpan(children: [
                                                                  TextSpan(text: '\n'),
                                                                  TextSpan(text: "Pick Up Address: ", style: Theme.of(context).textTheme.bodyText2.copyWith(fontWeight: FontWeight.bold)),
                                                                  TextSpan(text: "${delivery.pickupAddress}\n", style: Theme.of(context).textTheme.bodyText2),
                                                                  TextSpan(text: '\n'),
                                                                  TextSpan(text: "Drop Off Address: ", style: Theme.of(context).textTheme.bodyText2.copyWith(fontWeight: FontWeight.bold)),
                                                                  TextSpan(text: "${delivery.dropOffAddress}\n", style: Theme.of(context).textTheme.bodyText2),
                                                                ],
                                                                ),
                                                              ),
                                                            ),
                                                            ListTile(
                                                              leading: Icon(Icons.phone_rounded,color: Colors.black,),
                                                              title: Text("Contact Information",
                                                                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                                                              ),
                                                              subtitle: Text.rich(
                                                                TextSpan(children: [
                                                                  TextSpan(text: "Sender: ", style: Theme.of(context).textTheme.bodyText2.copyWith(fontWeight: FontWeight.bold)),
                                                                  TextSpan(text: "${delivery.pickupPointPerson}\n",style: Theme.of(context).textTheme.bodyText2),
                                                                  TextSpan(text: "Contact Number: ", style: Theme.of(context).textTheme.bodyText2.copyWith(fontWeight: FontWeight.bold)),
                                                                  TextSpan(text: "${delivery.pickupContactNum}\n",style: Theme.of(context).textTheme.bodyText2),
                                                                  TextSpan(text: "\n"),
                                                                  TextSpan(text: "Receiver: ", style: Theme.of(context).textTheme.bodyText2.copyWith(fontWeight: FontWeight.bold)),
                                                                  TextSpan(text: "${delivery.dropoffPointPerson}\n",style: Theme.of(context).textTheme.bodyText2),
                                                                  TextSpan(text: "Contact Number: ", style: Theme.of(context).textTheme.bodyText2.copyWith(fontWeight: FontWeight.bold)),
                                                                  TextSpan(text: "${delivery.dropoffContactNum}\n",style: Theme.of(context).textTheme.bodyText2),
                                                                ],
                                                                ),
                                                              ),
                                                            ),
                                                            ListTile(
                                                              leading: Icon(Icons.description,color: Colors.black,),
                                                              title: Text("Additional Information", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),),
                                                              subtitle: Container(
                                                                padding: EdgeInsets.only(top: 5),
                                                                child: Text.rich(
                                                                  TextSpan(children: [
                                                                    TextSpan(text: "Item Description: ", style: Theme.of(context).textTheme.bodyText2.copyWith(fontWeight: FontWeight.bold)),
                                                                    TextSpan(text: "${delivery.itemDescription}\n",style: Theme.of(context).textTheme.bodyText2),
                                                                    TextSpan(text: "Specific Instructions: \n", style: Theme.of(context).textTheme.bodyText2.copyWith(fontWeight: FontWeight.bold)),
                                                                    TextSpan(text: "${delivery.specificInstructions}\n",style: Theme.of(context).textTheme.bodyText2),
                                                                  ],
                                                                  ),
                                                                ),
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                  ),
                                                ),
                                              );
                                            },
                                            child: Icon(Icons.info_rounded),
                                            heroTag: 'info',
                                          ),
                                          SizedBox(height: 10),
                                          FloatingActionButton(
                                            onPressed: (){
                                              Navigator.push(context, MaterialPageRoute(builder: (context) => ChatPage(delivery: delivery)));
                                            },
                                            child: Icon(Icons.message_rounded),
                                            heroTag: 'message',
                                          ),
                                          SizedBox(height: 10),
                                          FloatingActionButton(
                                            onPressed: (){
                                            },
                                            child: Icon(Icons.check_circle),
                                            backgroundColor: Colors.green,
                                            heroTag: 'check',
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
                            else return Column(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                SizedBox(height: 10),
                                FloatingActionButton(
                                  onPressed: null,
                                  child: Icon(Icons.info_rounded),
                                  backgroundColor: Colors.grey,
                                  heroTag: 'info',
                                ),
                                SizedBox(height: 10),
                                FloatingActionButton(
                                  onPressed: null,
                                  child: Icon(Icons.message_rounded),
                                  backgroundColor: Colors.grey,
                                  heroTag: 'message',
                                ),
                                SizedBox(height: 10),
                                FloatingActionButton(
                                  onPressed: null,
                                  child: Icon(Icons.check_circle),
                                  backgroundColor: Colors.grey,
                                  heroTag: 'check',
                                ),
                              ],
                            );
                          }
                          else return Container();
                        }
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
