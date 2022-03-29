import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:page_transition/page_transition.dart';
import 'package:proxpress/UI/CustomerUI/delivery_status_class.dart';
import 'package:proxpress/UI/CustomerUI/proxpress_template_customer.dart';
import 'package:proxpress/UI/CustomerUI/top_up_page.dart';
import 'package:proxpress/models/couriers.dart';
import 'package:proxpress/models/customers.dart';
import 'package:proxpress/services/database.dart';

class ReviewRequest extends StatefulWidget {
  final DocumentReference customer;
  final DocumentReference courier;
  final String pickupAddress;
  final GeoPoint pickupGeoPoint;
  final String dropOffAddress;
  final GeoPoint dropOffGeoPoint;
  final String itemDescription;
  final String pickupPointPerson;
  final String pickupContactNum;
  final String dropOffPointPerson;
  final String dropOffContactNum;
  final String whoWillPay;
  final String specificInstructions;
  final String paymentOption;
  final int deliveryFee;
  final int itemWeight;

  ReviewRequest({
    Key key,
    @required this.customer,
    @required this.courier,
    @required this.pickupAddress,
    @required this.pickupGeoPoint,
    @required this.dropOffAddress,
    @required this.dropOffGeoPoint,
    @required this.itemDescription,
    @required this.pickupPointPerson,
    @required this.pickupContactNum,
    @required this.dropOffPointPerson,
    @required this.dropOffContactNum,
    @required this.whoWillPay,
    @required this.specificInstructions,
    @required this.paymentOption,
    @required this.deliveryFee,
    @required this.itemWeight,
  }) : super(key: key);

  @override
  _ReviewRequestState createState() => _ReviewRequestState();
}

class _ReviewRequestState extends State<ReviewRequest> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  bool _isLoading = false;
  String notifM = "";
  bool paymentSuccess = false;

  @override
  Widget build(BuildContext context) {
    final FirebaseAuth _auth = FirebaseAuth.instance;
    User user = _auth.currentUser;

    return Scaffold(
      drawerEnableOpenDragGesture: false,
      endDrawerEnableOpenDragGesture: false,
      key: _scaffoldKey,
      appBar: AppBar(
        backgroundColor: Colors.white,
        iconTheme: IconThemeData(
          color: Color(0xfffb0d0d),
        ),
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
          child: Padding(
            padding: const EdgeInsets.fromLTRB(10, 0, 10, 0),
            child: Column(
              children: [
                SizedBox(height: 10),
                Align(
                  alignment: Alignment.bottomCenter,
                  child: Text("Review Request",
                    style: TextStyle(
                      fontSize: 25,
                    ),
                  ),
                ),
                SizedBox(height: 10),
                Card(
                  child: Column(
                    children: [
                      ListTile(
                        leading: Icon(Icons.place_rounded),
                        title: Text('Pickup Address'),
                        subtitle: Text(widget.pickupAddress),
                      ),
                      ListTile(
                        leading: Icon(Icons.location_searching_rounded),
                        title: Text('Drop Off Address'),
                        subtitle: Text(widget.dropOffAddress),
                      ),
                    ],
                  ),
                ),
                StreamBuilder<Courier>(
                    stream: DatabaseService(uid: widget.courier.id).courierData,
                    builder: (context, snapshot) {
                      if (snapshot.hasData) {
                        Courier chosenCourier = snapshot.data;

                        String courierDetails =
                            "Name: ${chosenCourier.fName} ${chosenCourier.lName} "
                            "\nVehicle Type: ${chosenCourier.vehicleType} "
                            "\nDelivery Fee: ₱${widget.deliveryFee}";

                        return Card(
                          child: ListTile(
                            leading: Icon(Icons.perm_contact_cal_outlined),
                            title: Text('Chosen Courier'),
                            subtitle: Text(courierDetails),
                            isThreeLine: true,
                          ),
                        );
                      } else {
                        return Card(
                          child: ListTile(
                            leading: Icon(Icons.perm_contact_cal_outlined),
                            title: Text('Chosen Courier'),
                            subtitle: Text(""),
                            isThreeLine: true,
                          ),
                        );
                      }
                    }
                ),
                Card(
                  child: Column(
                    children: [
                      ListTile(
                        leading: Icon(Icons.description_rounded),
                        title: Text('About Item'),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("Item Description: ${widget.itemDescription}"),
                            Text('Item Weight: ${widget.itemWeight.toString()}kg'),
                          ],
                        )
                      ),
                      ListTile(
                        leading: Icon(Icons.person_rounded),
                        title: Text('Pickup Point Person'),
                        subtitle: Text("Name: ${widget.pickupPointPerson} \nContact Number: ${widget.pickupContactNum}"),
                      ),
                      ListTile(
                        leading: Icon(Icons.person_rounded),
                        title: Text('Drop Off Point Person'),
                        subtitle: Text("Name: ${widget.dropOffPointPerson} \nContact Number: ${widget.dropOffContactNum}"),
                      ),
                      ListTile(
                        leading: Icon(Icons.person_pin_circle_rounded),
                        title: Text('Who Will Pay?'),
                        subtitle: Text("${widget.whoWillPay}"),
                      ),
                      ListTile(
                        leading: Icon(Icons.workspaces_rounded),
                        title: Text('Specific Instructions'),
                        subtitle: Text("${widget.specificInstructions}"),
                      ),
                      ListTile(
                        leading: Icon(Icons.payment_rounded),
                        title: Text('Payment Option'),
                        subtitle: Text("${widget.paymentOption}"),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 20),
                ElevatedButton.icon(
                  icon: _isLoading ? CircularProgressIndicator() : Icon(Icons.send),
                  label: Text(
                    _isLoading ? 'Sending...' : widget.paymentOption == 'Online Payment' ? 'Pay and Send Request' : 'Send Request',
                    style: TextStyle(color: Colors.white, fontSize: 18),
                  ),
                  style: ElevatedButton.styleFrom(primary: Color(0xfffb0d0d)),
                  onPressed: _isLoading ? null : () async {
                    setState(() {
                      _isLoading = true;
                    });
                    if (widget.paymentOption == 'Online Payment') {
                      int currentBalance = 0;

                      await FirebaseFirestore.instance
                          .collection('Customers')
                          .doc(user.uid)
                          .get()
                          .then((DocumentSnapshot documentSnapshot) {
                        if (documentSnapshot.exists) {
                          currentBalance = documentSnapshot['Wallet'];
                        }
                      });

                      if (currentBalance >= widget.deliveryFee) {
                        DatabaseService(uid: user.uid).updateCustomerWallet(currentBalance - widget.deliveryFee);
                        paymentSuccess = true;
                      } else {
                        paymentSuccess = false;
                      }
                    } else {
                      paymentSuccess = true;
                    }

                    if (paymentSuccess) {
                      await DatabaseService().updateDelivery(
                        widget.customer,
                        widget.courier,
                        widget.pickupAddress,
                        widget.pickupGeoPoint,
                        widget.dropOffAddress,
                        widget.dropOffGeoPoint,
                        widget.itemDescription,
                        widget.pickupPointPerson,
                        widget.pickupContactNum,
                        widget.dropOffPointPerson,
                        widget.dropOffContactNum,
                        widget.whoWillPay,
                        widget.specificInstructions,
                        widget.paymentOption,
                        widget.deliveryFee,
                        widget.itemWeight,
                        'Pending',
                        'Pending',
                        GeoPoint(13.621980880497976, 123.19477396693487),
                        0,
                        '',
                        false,
                        '',
                        Timestamp.now(),
                      );
                      await FirebaseFirestore.instance
                          .collection('Customers')
                          .doc(widget.customer.id)
                          .get()
                          .then((DocumentSnapshot documentSnapshot) {
                        if (documentSnapshot.exists) {
                          notifM = "${documentSnapshot['First Name']} ${documentSnapshot['Last Name']} requested a delivery";
                        }
                      });
                      bool isSeen = false;
                      bool popsOnce = true;
                      await DatabaseService().createNotificationData(notifM, widget.customer, widget.courier,
                          Timestamp.now(), isSeen, popsOnce);
                      Navigator.push(
                          context,
                          PageTransition(
                            child: AppBarTemp(currentPage: 'Requests', ),
                            type: PageTransitionType.rightToLeftWithFade
                          )
                      );
                      showToast('Your request has been sent.');
                    } else {
                      setState(() {
                        _isLoading = false;
                      });
                      showToast('Insufficient wallet balance!');
                      topUp();
                    }
                  },
                ),
                SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future showToast(String message) async {
    await Fluttertoast.cancel();
    Fluttertoast.showToast(msg: message, fontSize: 18, backgroundColor: Colors.green, textColor: Colors.white);
  }

  Future topUp() {
    return showMaterialModalBottomSheet(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(20),
        ),
      ),
      context: context,
      builder: (context) => Container(
        height: 250,
        child: Padding(
          padding: const EdgeInsets.all(50),
          child: Container(
            child: StreamBuilder<Customer>(
                stream: DatabaseService(uid: widget.customer.id).customerData,
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    Customer customer = snapshot.data;
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Balance', style: TextStyle(color: Colors.grey),),
                        Text('\₱${customer.wallet}', style: TextStyle(fontSize: 40),), // ${customer.wallet}
                        ElevatedButton(
                          onPressed: () async {
                            dynamic result = await Navigator.push(
                                context,
                                PageTransition(
                                    child: TopUpPage(),
                                    type: PageTransitionType.bottomToTop
                                )
                            );

                            if (result != null) {
                              // add value to customer wallet
                              DatabaseService(uid: widget.customer.id).updateCustomerWallet(customer.wallet + result);
                            }
                          },
                          child: Text('+ Top-up'),
                        ),
                      ],
                    );
                  } else {
                    return Container();
                  }
                }
            ),
          ),
        ),
      ),
    );
  }
}