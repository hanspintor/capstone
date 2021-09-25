import 'dart:ui';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:proxpress/Load/user_load.dart';
import 'package:proxpress/UI/CustomerUI/customer_remarks.dart';
import 'package:proxpress/UI/login_screen.dart';
import 'package:proxpress/models/couriers.dart';
import 'package:proxpress/models/customers.dart';
import 'package:proxpress/models/delivery_prices.dart';
import 'package:proxpress/services/database.dart';
import 'package:expansion_tile_card/expansion_tile_card.dart';

class CourierBookmarkTile extends StatefulWidget {
  final String pickupAddress;
  final LatLng pickupCoordinates;
  final String dropOffAddress;
  final LatLng dropOffCoordinates;
  final double distance;
  final bool appear;

  CourierBookmarkTile(
      {Key key,
      this.pickupAddress,
      this.pickupCoordinates,
      this.dropOffAddress,
      this.dropOffCoordinates,
      this.distance,
      @required this.appear})
      : super(key: key);

  @override
  _CourierBookmarkTileState createState() => _CourierBookmarkTileState();
}

class _CourierBookmarkTileState extends State<CourierBookmarkTile> {
  String deliveryPriceUid;
  double deliveryFee = 0.0;

  @override
  Widget build(BuildContext context) {
    final FirebaseAuth _auth = FirebaseAuth.instance;
    User user = _auth.currentUser;

    if (user != null) {
      return StreamBuilder<Customer>(
        stream: DatabaseService(uid: user.uid).customerData,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            Customer customer = snapshot.data;

            Map<String, DocumentReference> localBookmarks =
            Map<String, DocumentReference>.from(customer.courier_ref);

            List<DocumentReference> courierRefs =
            localBookmarks.values.toList();

            return Stack(
              alignment: Alignment.center,
              children: [
                ListView.builder(
                  physics: NeverScrollableScrollPhysics(),
                  shrinkWrap: true,
                  itemCount: courierRefs.length,
                  itemBuilder: (context, index) {
                    if (widget.appear) {
                      return StreamBuilder<Courier>(
                          stream: DatabaseService(uid: courierRefs[index].id)
                              .courierData,
                          builder: (context, snapshot) {
                            if (snapshot.hasData) {
                              Courier courier = snapshot.data;
                              deliveryPriceUid = courier.deliveryPriceRef.id;

                              var color;
                              if (courier.status == "Offline") {
                                color = Colors.redAccent;
                              } else {
                                color = Colors.green;
                              }

                              return StreamBuilder<DeliveryPrice>(
                                  stream: DatabaseService(uid: deliveryPriceUid)
                                      .deliveryPriceData,
                                  builder: (context, snapshot) {
                                    if (snapshot.hasData) {
                                      DeliveryPrice deliveryPriceData =
                                          snapshot.data;

                                      deliveryFee = (deliveryPriceData.baseFare
                                          .toDouble() +
                                          (deliveryPriceData.farePerKM.toDouble() *
                                              widget.distance));

                                      return Padding(
                                        padding: EdgeInsets.all(8),
                                        child: ExpansionTileCard(
                                          //expandedColor: Colors.grey,
                                          title: Text(
                                            "${courier.fName} ${courier.lName}",
                                            style: TextStyle(
                                                fontSize: 20,
                                                fontWeight: FontWeight.bold),
                                          ),
                                          leading: ClipOval(
                                            child: SizedBox(
                                              width: 48,
                                              height: 48,
                                              child: Container(
                                                child: CircleAvatar(
                                                  radius: 20,
                                                  backgroundImage: NetworkImage(
                                                      courier.avatarUrl),
                                                  backgroundColor: Colors.white,
                                                ),
                                              ),
                                            ),
                                          ),
                                          subtitle: Container(
                                            padding: EdgeInsets.only(top: 5),
                                            child: Text.rich(
                                              TextSpan(
                                                children: [
                                                  TextSpan(
                                                      text: "Vehicle Type: ",
                                                      style: Theme.of(context)
                                                          .textTheme
                                                          .bodyText2
                                                          .copyWith(
                                                          fontWeight:
                                                          FontWeight.bold)),
                                                  TextSpan(
                                                      text:
                                                      "${courier.vehicleType}\n",
                                                      style: Theme.of(context)
                                                          .textTheme
                                                          .bodyText2),
                                                  TextSpan(
                                                      text: "Delivery Fee: ",
                                                      style: Theme.of(context)
                                                          .textTheme
                                                          .bodyText2
                                                          .copyWith(
                                                          fontWeight:
                                                          FontWeight.bold)),
                                                  TextSpan(
                                                      text:
                                                      "₱${deliveryFee.toInt()}\n",
                                                      style: Theme.of(context)
                                                          .textTheme
                                                          .bodyText2),
                                                  TextSpan(
                                                      text: "Status: ",
                                                      style: Theme.of(context)
                                                          .textTheme
                                                          .bodyText2
                                                          .copyWith(
                                                          fontWeight:
                                                          FontWeight.bold)),
                                                  TextSpan(
                                                      text: "${courier.status}",
                                                      style: TextStyle(
                                                        color: color,
                                                        fontWeight: FontWeight.bold,
                                                      )),
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
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  ListTile(
                                                    leading: Icon(
                                                        Icons.info_rounded,
                                                        color: Colors.red),
                                                    title: Text(
                                                        'Additional Information',
                                                        style: TextStyle(
                                                            fontSize: 20,
                                                            fontWeight:
                                                            FontWeight.bold)),
                                                    subtitle: Container(
                                                      padding:
                                                      EdgeInsets.only(top: 5),
                                                      child: Text.rich(
                                                        TextSpan(
                                                          children: [
                                                            TextSpan(
                                                                text:
                                                                "Contact Number: ",
                                                                style: Theme.of(
                                                                    context)
                                                                    .textTheme
                                                                    .bodyText2
                                                                    .copyWith(
                                                                    fontWeight:
                                                                    FontWeight
                                                                        .bold)),
                                                            TextSpan(
                                                                text:
                                                                "${courier.contactNo}\n",
                                                                style: Theme.of(
                                                                    context)
                                                                    .textTheme
                                                                    .bodyText2),
                                                            TextSpan(
                                                                text:
                                                                "Vehicle Color: ",
                                                                style: Theme.of(
                                                                    context)
                                                                    .textTheme
                                                                    .bodyText2
                                                                    .copyWith(
                                                                    fontWeight:
                                                                    FontWeight
                                                                        .bold)),
                                                            TextSpan(
                                                                text:
                                                                "${courier.vehicleColor}\n",
                                                                style: Theme.of(
                                                                    context)
                                                                    .textTheme
                                                                    .bodyText2),
                                                          ],
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                  Stack(
                                                    children: [
                                                      Container(
                                                        child: const Center(
                                                          child:
                                                          CircularProgressIndicator(),
                                                        ),
                                                        height: 150,
                                                        width: 326,
                                                      ),
                                                      Container(
                                                          padding: EdgeInsets.only(
                                                              right: 40),
                                                          child: Image.network(
                                                            courier.vehiclePhoto_,
                                                            height: 140,
                                                            width: 326,
                                                          )),
                                                    ],
                                                  ),
                                                  SizedBox(
                                                    height: 20,
                                                  ),
                                                  Align(
                                                    alignment:
                                                    Alignment.centerRight,
                                                    child: Container(
                                                        height: 25,
                                                        child: ElevatedButton(
                                                            child: Text(
                                                              'Request',
                                                              style: TextStyle(
                                                                  color:
                                                                  Colors.white,
                                                                  fontSize: 10),
                                                            ),
                                                            onPressed: /*widget.courier.status == "Offline" ? null :*/ () {
                                                              Navigator.push(context, MaterialPageRoute(builder: (context) =>
                                                                  CustomerRemarks(
                                                                    courierUID: courier.uid,
                                                                    pickupAddress: widget.pickupAddress,
                                                                    pickupCoordinates: widget.pickupCoordinates,
                                                                    dropOffAddress: widget.dropOffAddress,
                                                                    dropOffCoordinates: widget.dropOffCoordinates,
                                                                    deliveryFee: deliveryFee.toInt(),),
                                                              ));
                                                            })),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                      );
                                    } else {
                                      return Container();
                                    }
                                  });
                            } else {
                              return Container();
                            }
                          });
                    } else {
                      return Stack(

                        children: [
                          Container(
                            decoration: new BoxDecoration(color: Colors.black.withOpacity(0)),
                            child: StreamBuilder<Courier>(
                                stream: DatabaseService(uid: courierRefs[index].id)
                                    .courierData,
                                builder: (context, snapshot) {
                                  if (snapshot.hasData) {
                                    Courier courier = snapshot.data;

                                    var color;
                                    if (courier.status == "Offline") {
                                      color = Colors.redAccent;
                                    } else {
                                      color = Colors.green;
                                    }
                                    return Padding(
                                      padding: EdgeInsets.all(8),
                                      child: IgnorePointer(
                                        ignoring: true,
                                        child: ExpansionTileCard(
                                          //expandedColor: Colors.grey,
                                          title: Text(
                                            "${courier.fName} ${courier.lName}",
                                            style: TextStyle(
                                                fontSize: 20, fontWeight: FontWeight.bold),
                                          ),
                                          leading: ClipOval(
                                            child: SizedBox(
                                              width: 48,
                                              height: 48,
                                              child: Container(
                                                child: CircleAvatar(
                                                  radius: 20,
                                                  backgroundImage:
                                                  NetworkImage(courier.avatarUrl),
                                                  backgroundColor: Colors.white,
                                                ),
                                              ),
                                            ),
                                          ),
                                          subtitle: Container(
                                            padding: EdgeInsets.only(top: 5),
                                            child: Text.rich(
                                              TextSpan(
                                                children: [
                                                  TextSpan(
                                                      text: "Vehicle Type: ",
                                                      style: Theme.of(context)
                                                          .textTheme
                                                          .bodyText2
                                                          .copyWith(
                                                          fontWeight: FontWeight.bold)),
                                                  TextSpan(
                                                      text: "${courier.vehicleType}\n",
                                                      style: Theme.of(context)
                                                          .textTheme
                                                          .bodyText2),
                                                  TextSpan(
                                                      text: "Status: ",
                                                      style: Theme.of(context)
                                                          .textTheme
                                                          .bodyText2
                                                          .copyWith(
                                                          fontWeight: FontWeight.bold)),
                                                  TextSpan(
                                                      text: "${courier.status}",
                                                      style: TextStyle(
                                                        color: color,
                                                        fontWeight: FontWeight.bold,
                                                      )),
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
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  ListTile(
                                                    leading: Icon(Icons.info_rounded,
                                                        color: Colors.red),
                                                    title: Text('Additional Information',
                                                        style: TextStyle(
                                                            fontSize: 20,
                                                            fontWeight: FontWeight.bold)),
                                                    subtitle: Container(
                                                      padding: EdgeInsets.only(top: 5),
                                                      child: Text.rich(
                                                        TextSpan(
                                                          children: [
                                                            TextSpan(
                                                                text: "Contact Number: ",
                                                                style: Theme.of(context)
                                                                    .textTheme
                                                                    .bodyText2
                                                                    .copyWith(
                                                                    fontWeight:
                                                                    FontWeight
                                                                        .bold)),
                                                            TextSpan(
                                                                text:
                                                                "${courier.contactNo}\n",
                                                                style: Theme.of(context)
                                                                    .textTheme
                                                                    .bodyText2),
                                                            TextSpan(
                                                                text: "Vehicle Color: ",
                                                                style: Theme.of(context)
                                                                    .textTheme
                                                                    .bodyText2
                                                                    .copyWith(
                                                                    fontWeight:
                                                                    FontWeight
                                                                        .bold)),
                                                            TextSpan(
                                                                text:
                                                                "${courier.vehicleColor}\n",
                                                                style: Theme.of(context)
                                                                    .textTheme
                                                                    .bodyText2),
                                                          ],
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                  Stack(
                                                    children: [
                                                      Container(
                                                        child: const Center(
                                                          child:
                                                          CircularProgressIndicator(),
                                                        ),
                                                        height: 150,
                                                        width: 326,
                                                      ),
                                                      Container(
                                                          padding:
                                                          EdgeInsets.only(right: 40),
                                                          child: Image.network(
                                                            courier.vehiclePhoto_,
                                                            height: 140,
                                                            width: 326,
                                                          )),
                                                    ],
                                                  ),
                                                  SizedBox(
                                                    height: 20,
                                                  ),
                                                  // Align(
                                                  //   alignment: Alignment.centerRight,
                                                  //   child: Container(
                                                  //       height: 25,
                                                  //       child: ElevatedButton(
                                                  //           child: Text('Request', style: TextStyle(color: Colors.white, fontSize: 10),),
                                                  //           onPressed: /*widget.courier.status == "Offline" ? null :*/ () {
                                                  //             // Navigator.push(context, MaterialPageRoute(builder: (context) =>
                                                  //             //     CustomerRemarks(
                                                  //             //       courierUID: widget.courier.uid,
                                                  //             //       pickupAddress: widget.pickupAddress,
                                                  //             //       pickupCoordinates: widget.pickupCoordinates,
                                                  //             //       dropOffAddress: widget.dropOffAddress,
                                                  //             //       dropOffCoordinates: widget.dropOffCoordinates,
                                                  //             //       deliveryFee: deliveryFee.toInt(),),
                                                  //             // ));
                                                  //           }
                                                  //       )
                                                  //   ),
                                                  // ),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    );
                                  } else {
                                    return Container();
                                  }
                                }),
                          ),
                          Positioned(
                            top: 100,
                            bottom: 150,
                            left: 200,
                            right: 100,
                            child:  BackdropFilter(
                                filter: ImageFilter.blur(
                                    sigmaX: 5,
                                    sigmaY: 5
                                ),
                                child: Container(

                                  color: Colors.black.withOpacity(0),
                                )
                            ),
                          ),

                        ],
                      );
                    }
                  },
                ),
                Visibility(
                  visible: courierRefs.length == 0
                      || widget.appear
                      ? false : true,
                  child: Container(
                    child: Text(
                      "Pin first the location",
                      style: TextStyle(
                        fontSize: 30,
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ),
                )
              ],
            );
            return Container();
          } else {
            return Container();
          }
        }
      );
    } else {
      return Container();
    }
  }
}