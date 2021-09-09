import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:expansion_tile_card/expansion_tile_card.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:proxpress/UI/CustomerUI/customer_remarks.dart';
import 'package:proxpress/UI/login_screen.dart';
import 'package:proxpress/models/couriers.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:favorite_button/favorite_button.dart';

class CourierTile extends StatefulWidget {
  final Courier courier;
  final String pickupAddress;
  final LatLng pickupCoordinates;
  final String dropOffAddress;
  final LatLng dropOffCoordinates;

  CourierTile({
    Key key,
    @required this.courier,
    @required this.pickupAddress,
    @required this.pickupCoordinates,
    @required this.dropOffAddress,
    @required this.dropOffCoordinates,
  }) : super(key: key);

  @override
  State<CourierTile> createState() => _CourierTileState();
}

class _CourierTileState extends State<CourierTile> {
  @override
  initState(){
    super.initState();
    setState((){});
  }

  int baseFare;
  int farePerKM;

  // need to get this from distance of 2 geopoints
  int distance = 4;
  int deliveryFee;

  @override
  Widget build(BuildContext context) {
    baseFare ??= 0;
    farePerKM ??= 0;
    deliveryFee ??= 0;

    print(widget.courier.deliveryPriceRef.toString());

    widget.courier.deliveryPriceRef.get().then((DocumentSnapshot doc) {
      baseFare = doc['Base Fare'];
      farePerKM = doc['Fare Per KM'];
    });

    deliveryFee = baseFare + (farePerKM * distance);

    print('${widget.courier.fName} - $baseFare');
    print('${widget.courier.fName} - $farePerKM');

    // Ini dapat mag luwas na delivery fee
    print('${widget.courier.fName} - $deliveryFee');

    final FirebaseAuth _auth = FirebaseAuth.instance;
    User user = _auth.currentUser;
    var color;
    if (widget.courier.status == "Offline") {
      color = Colors.redAccent;
    } else {
      color = Colors.green;
    }

    return user == null
        ? LoginScreen()
        : Padding(
            padding: EdgeInsets.only(top: 0.0),
            child: ExpansionTileCard(
              //expandedColor: Colors.grey,
              title: Text("${widget.courier.fName} ${widget.courier.lName}", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),),
              leading: ClipOval(
                child: SizedBox(
                  width: 48,
                  height: 48,
                  child:Image.network('https://firebasestorage.googleapis.com/v0/b/proxpress-629e3.appspot.com/o/profile-user.png?alt=media&token=6727618b-4289-4438-8a93-a4f14753d92e'),
                ),
              ),
              subtitle: Text.rich(
                TextSpan(children: [
                  TextSpan(text: "Vehicle Type: ", style: Theme.of(context).textTheme.bodyText2.copyWith(fontWeight: FontWeight.bold)),
                  TextSpan(text: "${widget.courier.vehicleType}\n",style: Theme.of(context).textTheme.bodyText2),
                  TextSpan(text: "Delivery Fee: ", style: Theme.of(context).textTheme.bodyText2.copyWith(fontWeight: FontWeight.bold)),
                  TextSpan(text: "₱${deliveryFee}\n",style: Theme.of(context).textTheme.bodyText2),
                  TextSpan(text: "Status: ", style: Theme.of(context).textTheme.bodyText2.copyWith(fontWeight: FontWeight.bold)),
                  TextSpan(text: "${widget.courier.status}", style: TextStyle(color: color, fontWeight: FontWeight.bold,)),
                ],
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
                      Padding(
                        padding: const EdgeInsets.only(right: 7),
                        child: Text.rich(
                          TextSpan(children: [
                            TextSpan(text: "Contact Number: ", style: Theme.of(context).textTheme.bodyText2.copyWith(fontWeight: FontWeight.bold)),
                            TextSpan(text: "${widget.courier.contactNo}\n",style: Theme.of(context).textTheme.bodyText2),
                            TextSpan(text: "Vehicle Color: ", style: Theme.of(context).textTheme.bodyText2.copyWith(fontWeight: FontWeight.bold)),
                            TextSpan(text: "${widget.courier.vehicleColor}\n",style: Theme.of(context).textTheme.bodyText2),
                          ],
                          ),
                        ),
                      ),
                      SizedBox(
                          height: 200,
                          width: 200,
                          child: Image.network(widget.courier.vehiclePhoto_),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(left: 270),
                        child: Container(
                            height: 25,
                            child: ElevatedButton(
                                child: Text('Request', style: TextStyle(color: Colors.white, fontSize: 10),),
                                onPressed: () {
                                  Navigator.push(context, MaterialPageRoute(builder: (context) =>
                                      CustomerRemarks(
                                          courierUID: widget.courier.uid,
                                          pickupAddress: widget.pickupAddress,
                                          pickupCoordinates: widget.pickupCoordinates,
                                          dropOffAddress: widget.dropOffAddress,
                                          dropOffCoordinates: widget.dropOffCoordinates),
                                  ));
                                }
                            )
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            // child: Card(
            //   margin: EdgeInsets.fromLTRB(20.0, 6.0, 20.0, 0.0),
            //   child: ListTile(
            //     isThreeLine: true,
            //     title: Text("${widget.courier.fName} ${widget.courier.lName}"),
            //     leading: Container(
            //       width: 48,
            //       height: 48,
            //       padding: const EdgeInsets.symmetric(vertical: 4.0),
            //       alignment: Alignment.center,
            //       child:Icon(
            //             Icons.account_circle_rounded,
            //             size: 55,
            //           ),
            //     ),
            //     subtitle: Text("Vehicle Type: ${widget.courier.vehicleType}\nDelivery Fee: $deliveryFee"),
            //     trailing: Column(
            //       children: [
            //         Text(
            //           "${widget.courier.status}",
            //           style: TextStyle(
            //             color: color,
            //             fontWeight: FontWeight.bold,
            //           ),
            //         ),
            //         Container(
            //           margin: EdgeInsets.only(top: 5),
            //             height: 25,
            //             child: ElevatedButton(
            //                 child: Text(
            //                   'Request',
            //                   style: TextStyle(
            //                       color: Colors.white, fontSize: 10),
            //                 ),
            //                 style: ElevatedButton.styleFrom(
            //                     primary: Colors.black),
            //                 onPressed: () {
            //                   Navigator.push(
            //                       context,
            //                       MaterialPageRoute(
            //                         builder: (context) =>
            //                             CustomerRemarks(
            //                             courierUID: widget.courier.uid,
            //                             pickupAddress: widget.pickupAddress,
            //                             pickupCoordinates: widget.pickupCoordinates,
            //                             dropOffAddress: widget.dropOffAddress,
            //                             dropOffCoordinates: widget.dropOffCoordinates),
            //                       ));
            //                 }
            //             )
            //         ),
            //
            //       ],
            //     ),
            //   ),
            // ),
          );
  }
}
