import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:expansion_tile_card/expansion_tile_card.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:page_transition/page_transition.dart';
import 'package:proxpress/UI/CustomerUI/delivery_status.dart';
import 'package:proxpress/UI/login_screen.dart';
import 'package:proxpress/classes/chat_page.dart';
import 'package:proxpress/classes/view_delivery_details.dart';
import 'package:proxpress/models/customers.dart';
import 'package:proxpress/models/deliveries.dart';
import 'package:proxpress/services/database.dart';
import 'package:proxpress/services/notification.dart';
import 'package:timezone/data/latest.dart' as tz;

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
  bool isSeen = false;
  bool popsOnce = true;
  String notifM = "";
  @override
  void initState(){
    super.initState();

    tz.initializeTimeZones();
  }

  @override
  Widget build(BuildContext context) {
    uid = widget.delivery.customerRef.id;

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

    if (user != null) {
      return StreamBuilder<Customer>(
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
                padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 5),
                child: Card(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      ListTile(
                        isThreeLine: true,
                        leading: Container(
                          child: CircleAvatar(
                            radius: 20,
                            backgroundImage: NetworkImage(customerData.avatarUrl),
                            backgroundColor: Colors.white,
                          ),
                        ),
                        title: Text("${customerData.fName} ${customerData.lName}",
                          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black),),

                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Text('Contact Number: ', style: TextStyle(color: Colors.black),),
                                Text(customerData.contactNo),
                              ],
                            ),
                            Row(
                              children: [
                                Text('Delivery Fee: ',style: TextStyle(color: Colors.black),),
                                Text('\₱${widget.delivery.deliveryFee}.00',style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black)),
                              ],
                            ),
                          ],
                        ),
                        trailing: Icon(Icons.info_outline_rounded, color: Colors.red,),
                        onTap: (){
                          Navigator.push(context, PageTransition(child: DeliveryDetails(
                            customer: widget.delivery.customerRef,
                            courier: widget.delivery.courierRef,
                            pickupAddress: widget.delivery.pickupAddress,
                            pickupGeoPoint: widget.delivery.pickupCoordinates,
                            dropOffAddress: widget.delivery.dropOffAddress,
                            dropOffGeoPoint: widget.delivery.dropOffCoordinates,
                            itemDescription: widget.delivery.itemDescription,
                            pickupPointPerson: widget.delivery.pickupPointPerson ,
                            pickupContactNum: widget.delivery.pickupContactNum ,
                            dropOffPointPerson: widget.delivery.dropoffPointPerson ,
                            dropOffContactNum: widget.delivery.dropoffContactNum ,
                            whoWillPay: widget.delivery.whoWillPay ,
                            specificInstructions: widget.delivery.specificInstructions ,
                            paymentOption: widget.delivery.paymentOption ,
                            deliveryFee: widget.delivery.deliveryFee ,
                          ),
                              type: PageTransitionType.rightToLeftWithFade));
                        },
                      ),
                      Divider(
                        color: Colors.grey,
                        thickness: .5,
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

                                  return TextButton(
                                      child: Text('CONFIRM'),
                                      onPressed: cantConfirm ? null : () async{
                                        bool isSeen = false;

                                        await FirebaseFirestore.instance
                                            .collection('Couriers')
                                            .doc(widget.delivery.courierRef.id)
                                            .get()
                                            .then((DocumentSnapshot documentSnapshot) {
                                          if (documentSnapshot.exists) {
                                            notifM = "${documentSnapshot['First Name']} ${documentSnapshot['Last Name']} accepted your request";
                                          }
                                        });
                                        await DatabaseService().createNotificationData(notifM, widget.delivery.courierRef,
                                            widget.delivery.customerRef, Timestamp.now(), isSeen, popsOnce);
                                        await DatabaseService(uid: widget.delivery.uid).updateApprovalAndDeliveryStatus('Approved', 'Ongoing');
                                      }
                                  );
                                } else {
                                  return TextButton(
                                    child: Text('CONFIRM'),
                                    onPressed: null,
                                  );
                                }
                              }
                          ),
                          TextButton(
                              child: Text('DECLINE'),
                              onPressed: () async{

                                await FirebaseFirestore.instance
                                    .collection('Couriers')
                                    .doc(widget.delivery.courierRef.id)
                                    .get()
                                    .then((DocumentSnapshot documentSnapshot) {
                                  if (documentSnapshot.exists) {
                                    notifM = "${documentSnapshot['First Name']} ${documentSnapshot['Last Name']} declined your request";
                                  }
                                });
                                await DatabaseService().createNotificationData(notifM, widget.delivery.courierRef,
                                    widget.delivery.customerRef, Timestamp.now(), isSeen, popsOnce);
                                await DatabaseService(uid: widget.delivery.uid).updateApprovalAndDeliveryStatus('Declined by Courier', 'Cancelled');
                              }
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            }
            else return Container();
          }
      );
    } else {
      return LoginScreen();
    }
  }
}