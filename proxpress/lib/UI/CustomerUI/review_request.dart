import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:proxpress/models/couriers.dart';
import 'package:proxpress/services/database.dart';
import 'package:flutter_paypal/flutter_paypal.dart';

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
    print(widget.paymentOption);
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
          IconButton(icon: Icon(
            Icons.help_outline,
          ),
            onPressed: () {
              showDialog(
                  context: context,
                  builder: (BuildContext context){
                    return AlertDialog(
                      title: Text("Help"),
                      content: Text('Sample Text Here'),
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
                        title: Text('Item Description'),
                        subtitle: Text(widget.itemDescription),
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
                        subtitle: Text("Name: ${widget.whoWillPay}"),
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
                      await Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (BuildContext context) => UsePaypal(
                              sandboxMode: true,
                              clientId: "AWkipu6yPY27RjsDwrzbLeNJUHWUT03QaLP0jN844XGAX5okIhXtYfe2C_vL0gl1IOb-UqsVvow4VP0r",
                              secretKey: "EJvqqFJFsJ4IsSNYp279b2TeQKYgpa-riHjrlxazhoKV4if33xWrR3nwzDn0Y7tIYlslNjlXMyK683-E",
                              returnURL: "https://samplesite.com/return",
                              cancelURL: "https://samplesite.com/cancel",
                              transactions: [
                                {
                                  "amount": {
                                    "total": '${widget.deliveryFee}',
                                    "currency": "PHP",
                                    "details": {
                                      "subtotal": '${widget.deliveryFee}',
                                      "shipping": '0',
                                      "shipping_discount": 0
                                    }
                                  },
                                  "description":
                                  "The payment transaction description.",
                                  // "payment_options": {
                                  //   "allowed_payment_method":
                                  //       "INSTANT_FUNDING_SOURCE"
                                  // },
                                  "item_list": {
                                    "items": [
                                      {
                                        "name": "Delivery",
                                        "quantity": 1,
                                        "price": '${widget.deliveryFee}',
                                        "currency": "PHP"
                                      }
                                    ],

                                    // // shipping address is not required though
                                    // "shipping_address": {
                                    //   "recipient_name": "",
                                    //   "line1": "",
                                    //   "line2": "",
                                    //   "city": "",
                                    //   "country_code": "PH",
                                    //   "postal_code": "",
                                    //   "phone": "",
                                    //   "state": ""
                                    // },
                                  }
                                }
                              ],
                              note: "Contact us for any questions on your order.",
                              onSuccess: (Map params) async {
                                print("onSuccess: $params");
                              },
                              onError: (error) {
                                print("onError: $error");
                              },
                              onCancel: (params) {
                                print('cancelled: $params');
                              }),
                        ),
                      ).then((value) => paymentSuccess = value);
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
                        'Pending',
                        'Pending',
                        GeoPoint(13.621980880497976, 123.19477396693487),
                        0,
                        '',
                        false,
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
                      Navigator.pushNamed(context, '/template');
                      showToast('Your request has been sent.');
                    } else {
                      setState(() {
                        _isLoading = false;
                      });
                      showToast('Payment failed!');
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
}
