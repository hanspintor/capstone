import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:expansion_tile_card/expansion_tile_card.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:proxpress/UI/login_screen.dart';
import 'package:proxpress/models/customers.dart';
import 'package:proxpress/models/deliveries.dart';
import 'package:proxpress/services/database.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:proxpress/services/notification.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;
import 'dart:math';

class DeliveryTile extends StatefulWidget {
  final Delivery delivery;
  final int lengthDelivery;
  final bool notifPopUpStatus;
  final int notifPopUpCounter;


  DeliveryTile({
    Key key,
    @required this.delivery,
    @required this.lengthDelivery,
    @required this.notifPopUpStatus,
    @required this.notifPopUpCounter,
  }) : super(key: key);

  @override
  State<DeliveryTile> createState() => _DeliveryTileState();
}

class _DeliveryTileState extends State<DeliveryTile> {
  String uid;

  @override
  void initState(){
    super.initState();

    tz.initializeTimeZones();
  }

  @override
  Widget build(BuildContext context) {
    uid = widget.delivery.customerRef.id;
    int flag = 0;

    final FirebaseAuth _auth = FirebaseAuth.instance;
    User user = _auth.currentUser;

    Future<bool> gotOngoingDelivery = FirebaseFirestore.instance.collection('Deliveries')
        .where('Courier Approval', isEqualTo: 'Approved')
        .where('Delivery Status', isEqualTo: 'Ongoing')
        .where('Courier Reference', isEqualTo: FirebaseFirestore.instance.collection('Couriers').doc(user.uid))
        .get().then((event) async {
      if (event.docs.isNotEmpty) {
        return true; //if it is a single document
      } else {
        return false;
      }
    });

    return user == null ? LoginScreen() : Padding(
          padding: const EdgeInsets.all(8.0),
          child: StreamBuilder<Customer>(
            stream: DatabaseService(uid: uid).customerData,
            builder: (context, snapshot) {
              if (snapshot.hasData) {

                Customer customerData = snapshot.data;
                String name = "${customerData.fName} ${customerData.lName}";
                String notifDescrip = "have requested a delivery";
                // print("length ${widget.lengthDelivery}");
                // print("flag ${flag}");
                // NotificationService().showNotification(1, name, notifDescrip, 1);
                // NotificationService().showNotification(2, name, notifDescrip, 1);
                //print(name);
                 if(widget.delivery.courierApproval == "Pending" && widget.notifPopUpStatus == true){
                    NotificationService().showNotification(widget.lengthDelivery, name, notifDescrip, 1);
                    DatabaseService(uid: user.uid).updateNotifPopUpStatusCourier(false);
                   // NotificationService().showNotification(2, name, notifDescrip, 2);
                   // if(flag<widget.lengthDelivery){
                   //
                   //   flag++;
                   //   print("flag1 ${flag}");
                   //   print("length ${widget.lengthDelivery}");
                   //
                   //
                   // }
                   // else if(flag == widget.lengthDelivery){
                   //   print("hu ${widget.notifPopUpStatus}");
                   //   DatabaseService(uid: user.uid).updateNotifPopUpCounterCourier(flag);
                   //   DatabaseService(uid: user.uid).updateNotifPopUpStatusCourier(false);
                   // }

                 }
                return Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: ExpansionTileCard(
                    title: Text("${name}",
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),),
                    leading: Container(
                      child: CircleAvatar(
                        radius: 20,
                        backgroundImage: NetworkImage(customerData.avatarUrl),
                        backgroundColor: Colors.white,
                      ),
                    ),
                    subtitle: Container(
                      padding: EdgeInsets.only(top: 5),
                      child: Text.rich(
                        TextSpan(children: [
                          TextSpan(text: "Pick Up Address: ", style: Theme.of(context).textTheme.bodyText2.copyWith(fontWeight: FontWeight.bold)),
                          TextSpan(text: "${widget.delivery.pickupAddress}\n", style: Theme.of(context).textTheme.bodyText2),
                          TextSpan(text: '\n'),
                          TextSpan(text: "Drop Off Address: ", style: Theme.of(context).textTheme.bodyText2.copyWith(fontWeight: FontWeight.bold)),
                          TextSpan(text: "${widget.delivery.dropOffAddress}\n", style: Theme.of(context).textTheme.bodyText2),
                        ],
                        ),
                      ),
                    ),
                    children: <Widget>[
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16.0,
                          vertical: 8.0,
                        ),
                        child: Column(
                          children: [
                            Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                ListTile(
                                  leading: Icon(Icons.info_rounded, color: Colors.red),
                                  title: Text("Additional Information", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),),
                                  subtitle: Container(
                                    padding: EdgeInsets.only(top: 5),
                                    child: Text.rich(
                                      TextSpan(children: [
                                        TextSpan(text: "Item Description: ", style: Theme.of(context).textTheme.bodyText2.copyWith(fontWeight: FontWeight.bold)),
                                        TextSpan(text: "${widget.delivery.itemDescription}\n",style: Theme.of(context).textTheme.bodyText2),
                                        TextSpan(text: "Specific Instructions: \n", style: Theme.of(context).textTheme.bodyText2.copyWith(fontWeight: FontWeight.bold)),
                                        TextSpan(text: "${widget.delivery.specificInstructions}\n",style: Theme.of(context).textTheme.bodyText2),
                                      ],
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                ListTile(
                                  leading: Icon(Icons.phone_rounded, color: Colors.red),
                                  title: Text("Contact Information", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),),
                                  subtitle: Container(
                                    padding: EdgeInsets.only(top: 5),
                                    child: Text.rich(
                                      TextSpan(children: [
                                        TextSpan(text: "Sender: ", style: Theme.of(context).textTheme.bodyText2.copyWith(fontWeight: FontWeight.bold)),
                                        TextSpan(text: "${widget.delivery.pickupPointPerson}\n",style: Theme.of(context).textTheme.bodyText2),
                                        TextSpan(text: "Contact Number: ", style: Theme.of(context).textTheme.bodyText2.copyWith(fontWeight: FontWeight.bold)),
                                        TextSpan(text: "${widget.delivery.pickupContactNum}\n",style: Theme.of(context).textTheme.bodyText2),
                                        TextSpan(text: "\n"),
                                        TextSpan(text: "Receiver: ", style: Theme.of(context).textTheme.bodyText2.copyWith(fontWeight: FontWeight.bold)),
                                        TextSpan(text: "${widget.delivery.dropoffPointPerson}\n",style: Theme.of(context).textTheme.bodyText2),
                                        TextSpan(text: "Contact Number: ", style: Theme.of(context).textTheme.bodyText2.copyWith(fontWeight: FontWeight.bold)),
                                        TextSpan(text: "${widget.delivery.dropoffContactNum}\n",style: Theme.of(context).textTheme.bodyText2),
                                      ],
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                FutureBuilder<bool>(
                                  future: gotOngoingDelivery,
                                  builder: (context, AsyncSnapshot<dynamic> snapshot) {
                                    print(gotOngoingDelivery);
                                    if (snapshot.hasData) {
                                      bool cantConfirm = snapshot.data;

                                      return Container(
                                          height: 25,
                                          child: ElevatedButton(
                                              child: Text('Confirm', style: TextStyle(color: Colors.white, fontSize: 10),),
                                              onPressed: cantConfirm ? null : () async{
                                                await DatabaseService(uid: widget.delivery.uid).updateApprovalAndDeliveryStatus('Approved', 'Ongoing');
                                              }
                                          )
                                      );
                                    } else {
                                      return Container(
                                          height: 25,
                                          child: ElevatedButton(
                                              child: Text('Confirm', style: TextStyle(color: Colors.white, fontSize: 10),),
                                              onPressed: null,
                                          )
                                      );
                                    }
                                  }
                                ),
                                Container(
                                    padding: EdgeInsets.only(left: 10),
                                    height: 25,
                                    child: ElevatedButton(
                                        child: Text('Decline', style: TextStyle(color: Colors.white, fontSize: 10),),
                                        onPressed: () async{
                                          await DatabaseService(uid: widget.delivery.uid).updateApprovalAndDeliveryStatus('Rejected', 'Cancelled');
                                        }
                                    )
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              }
              else return Container();
            }
          ),
        );

    }
}
