import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:page_transition/page_transition.dart';
import 'package:proxpress/UI/login_screen.dart';
import 'package:proxpress/classes/view_delivery_details.dart';
import 'package:proxpress/models/customers.dart';
import 'package:proxpress/models/deliveries.dart';
import 'package:proxpress/services/database.dart';
import 'package:proxpress/services/notification.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:intl/intl.dart';

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
  GlobalKey<FormState> _keyCancel = GlobalKey<FormState>();
  String cancellationMessage = "";

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

              if(widget.delivery.courierApproval == "Pending" && widget.notifPopUpStatus == true){
                NotificationService().showNotification(widget.lengthDelivery, name, notifDescrip, 1);
              }
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 5),
                child: Card(
                  child: InkWell(
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
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        Align(
                          alignment: Alignment.topLeft,
                          child: Padding(
                            padding: const EdgeInsets.only(top: 10, left: 5),
                            child: Text('${DateFormat.yMd().add_jm().format(widget.delivery.time.toDate())}', style: TextStyle(color: Colors.grey)),
                          ),
                        ),
                        Divider(
                          color: Colors.grey,
                          thickness: .5,
                        ),
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
                                          await DatabaseService(uid: widget.delivery.uid).updateTime(Timestamp.now());
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
                                  await showDialog(
                                      context: context,
                                      builder: (context) => StatefulBuilder(
                                        builder: (context, setState){
                                          return AlertDialog(
                                            title: Row(
                                              mainAxisSize: MainAxisSize.min,
                                              mainAxisAlignment: MainAxisAlignment.center,
                                              children: [
                                                Container(
                                                  margin: EdgeInsets.only(right: 10),
                                                  child: Icon(
                                                    Icons.cancel,
                                                    color: Colors.redAccent,
                                                  ),
                                                ),
                                                Text("Cancellation Reason"),
                                              ],
                                            ),
                                            content: Form(
                                              key: _keyCancel,
                                              child: SingleChildScrollView(
                                                child: Column(
                                                  mainAxisSize: MainAxisSize.min,
                                                  children: [
                                                    TextFormField(
                                                      validator: (value){
                                                        cancellationMessage = value;
                                                        return value.isNotEmpty ? null : "Please provide a reason";
                                                      },
                                                      minLines: 3,
                                                      maxLines: null,
                                                      maxLength: 100,
                                                      keyboardType: TextInputType.multiline,
                                                      onChanged: (val) => setState(() => cancellationMessage = val),
                                                      decoration:  InputDecoration(
                                                        hintText: "Reason why",
                                                        hintStyle: TextStyle(
                                                            fontStyle: FontStyle.italic
                                                        ),
                                                        filled: true,
                                                        border: InputBorder.none,
                                                        fillColor: Colors.grey[300],
                                                        contentPadding: const EdgeInsets.all(30),
                                                        focusedBorder: OutlineInputBorder(
                                                          borderSide: BorderSide(
                                                            color: Colors.red,
                                                            width: 2,
                                                          ),
                                                          borderRadius: BorderRadius.circular(10.0),
                                                        ),
                                                        enabledBorder: UnderlineInputBorder(
                                                          borderSide: BorderSide(color: Colors.white),
                                                          borderRadius: BorderRadius.circular(10.0),
                                                        ),
                                                      ),
                                                    )
                                                  ],
                                                ),
                                              ),
                                            ),
                                            actions: <Widget> [
                                              Row(
                                                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                                children: [
                                                  ElevatedButton(
                                                    child: Text("Discard"),
                                                    style: ButtonStyle(
                                                      backgroundColor: MaterialStateProperty.all(Colors.grey),
                                                    ),
                                                    onPressed: () {
                                                      Navigator.pop(context);
                                                    },
                                                  ),
                                                  ElevatedButton(
                                                    child: Text("Send"),
                                                    onPressed: () async {
                                                      if(_keyCancel.currentState.validate()){
                                                        await FirebaseFirestore.instance
                                                            .collection('Couriers')
                                                            .doc(widget.delivery.courierRef.id)
                                                            .get()
                                                            .then((DocumentSnapshot documentSnapshot) {
                                                          if (documentSnapshot.exists) {
                                                            notifM = "${documentSnapshot['First Name']} ${documentSnapshot['Last Name']} declined your request";
                                                          }
                                                        });

                                                        await DatabaseService(uid: widget.delivery.uid).updateApprovalAndDeliveryStatus('Declined by Courier', 'Cancelled');
                                                        await DatabaseService(uid: widget.delivery.uid).customerCancelRequest(cancellationMessage);
                                                        await DatabaseService().createNotificationData(
                                                            notifM,
                                                            widget.delivery.courierRef,
                                                            widget.delivery.customerRef,
                                                            Timestamp.now(),
                                                            isSeen,
                                                            popsOnce
                                                        );
                                                        await DatabaseService(uid: widget.delivery.uid).updateTime(Timestamp.now());

                                                        if (widget.delivery.paymentOption == 'Online Payment') {
                                                          int currentBalance = 0;

                                                          await FirebaseFirestore.instance
                                                              .collection('Customers')
                                                              .doc(widget.delivery.customerRef.id)
                                                              .get()
                                                              .then((DocumentSnapshot documentSnapshot) {
                                                            if (documentSnapshot.exists) {
                                                              currentBalance = documentSnapshot['Wallet'];
                                                            }
                                                          });

                                                          await DatabaseService(uid: widget.delivery.customerRef.id).updateCustomerWallet(currentBalance + widget.delivery.deliveryFee);
                                                          await DatabaseService(uid: widget.delivery.uid).updateTime(Timestamp.now());
                                                        }

                                                        Navigator.of(context).pop();
                                                        showToast("Request cancelled");
                                                      }
                                                    },
                                                  ),
                                                ],
                                              )
                                            ],
                                          );
                                        },
                                      )
                                  );
                                }
                            ),
                          ],
                        ),
                      ],
                    ),
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

  Future showToast(String message) async {
    await Fluttertoast.cancel();
    Fluttertoast.showToast(msg: message, fontSize: 18, backgroundColor: Colors.green, textColor: Colors.white);
  }
}