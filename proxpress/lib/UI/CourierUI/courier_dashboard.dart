import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:proxpress/UI/CourierUI/menu_drawer_courier.dart';
import 'package:proxpress/UI/CourierUI/notif_drawer_courier.dart';
import 'package:proxpress/classes/courier_classes/delivery_list.dart';
import 'package:proxpress/classes/courier_classes/notif_counter_courier.dart';
import 'package:proxpress/models/couriers.dart';
import 'package:proxpress/Load/user_load.dart';
import 'package:proxpress/UI/login_screen.dart';
import 'package:proxpress/models/deliveries.dart';
import 'package:proxpress/services/database.dart';
import 'package:proxpress/models/user.dart';
import 'package:provider/provider.dart';
import 'package:proxpress/classes/verify.dart';

class CourierDashboard extends StatefulWidget {
  @override
  State<CourierDashboard> createState() => _CourierDashboardState();
}

class _CourierDashboardState extends State<CourierDashboard> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();


  @override
  Widget build(BuildContext context) {
    final user = Provider.of<TheUser>(context);
    final auth = FirebaseAuth.instance;
    User user1 = auth.currentUser;

    bool approved = false;
    bool notifPopUpStatus = false;
    int notifCounter = 0;
      return StreamBuilder<Courier>(
          stream: DatabaseService(uid: user.uid).courierData,
          builder: (context,snapshot){
            if(snapshot.hasData){
              Courier courierData = snapshot.data;
              approved = courierData.approved;
              notifPopUpStatus = courierData.NotifPopStatus;
              notifCounter = courierData.NotifPopCounter;
              Stream<List<Delivery>> deliveryList = FirebaseFirestore.instance
                  .collection('Deliveries')
                  .where('Courier Approval', isEqualTo: 'Pending')
                  .where('Courier Reference', isEqualTo: FirebaseFirestore.instance.collection('Couriers').doc(user.uid))
                  .snapshots()
                  .map(DatabaseService().deliveryDataListFromSnapshot);
              print(courierData.adminMessage);

              Widget _welcomeMessage(){
                String welcomeMessage = courierData.adminMessage;
                print(welcomeMessage);
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

              return StreamProvider<List<Delivery>>.value(
                initialData: [],
                value: deliveryList,
                child: SingleChildScrollView(
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
                        !approved || !user1.emailVerified ? Container(
                          child: Column(
                            children: [
                              !approved ? Container(
                                child: _welcomeMessage(),
                              ) : Visibility(
                                visible: false,
                                child: Container(),
                              ),
                              !user1.emailVerified ? Container(
                                margin: EdgeInsets.all(20),
                                child: Column(
                                  children: [
                                    Container(
                                      decoration: BoxDecoration(
                                          border: Border.all(color: Colors.black)
                                      ),
                                      child: ListTile(
                                        leading: Icon(
                                          Icons.info,
                                          color: Colors.red,
                                        ),
                                        title: Text(
                                          "Kindly verify your email ${user1.email} to use the app.",
                                          style: TextStyle(
                                              fontSize: 15,
                                              fontStyle: FontStyle.italic,
                                              fontWeight: FontWeight.bold
                                          ),
                                        ),

                                      ),
                                    ),
                                    Container(
                                      decoration: BoxDecoration(
                                          border: Border.all(color: Colors.black)
                                      ),
                                      child: ListTile(
                                        leading: Icon(
                                          Icons.quiz,
                                          color: Colors.red,
                                        ),
                                        title: Text(
                                          "After verifying please relogin to access our features",
                                          style: TextStyle(
                                              fontSize: 15,
                                              fontStyle: FontStyle.italic,
                                              fontWeight: FontWeight.bold
                                          ),
                                        ),

                                      ),
                                    ),
                                    //verifyCond(),
                                    VerifyEmail()
                                  ],
                                ),
                              ) : Visibility(
                                visible: false,
                                child: Container(),
                              ),
                            ],
                          ),
                        )
                            : Card(
                          margin: EdgeInsets.all(20),
                          child:  DeliveryList(notifPopUpStatus: notifPopUpStatus,notifPopUpCounter: notifCounter,),
                        ),

                      ],
                    ),
                  ),
              );
            } else {
              return UserLoading();
            }
          }
      );
  }
}