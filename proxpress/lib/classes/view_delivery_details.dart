import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:proxpress/models/couriers.dart';
import 'package:proxpress/services/database.dart';

class DeliveryDetails extends StatefulWidget {
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

  DeliveryDetails({
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
  _DeliveryDetailsState createState() => _DeliveryDetailsState();
}

class _DeliveryDetailsState extends State<DeliveryDetails> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  String notifM = "";
  bool paymentSuccess = false;

  @override
  Widget build(BuildContext context) {
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
                  child: Text("Delivery Details",
                    style: TextStyle(
                      fontSize: 25,
                    ),
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
                            Text("Item Weight: ${widget.itemWeight.toString()}")
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