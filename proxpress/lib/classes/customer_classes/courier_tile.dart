import 'package:expansion_tile_card/expansion_tile_card.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:proxpress/UI/CustomerUI/customer_remarks.dart';
import 'package:proxpress/UI/login_screen.dart';
import 'package:proxpress/models/couriers.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:proxpress/models/delivery_prices.dart';
import 'package:proxpress/services/database.dart';

class CourierTile extends StatefulWidget {
  final Courier courier;
  final String pickupAddress;
  final LatLng pickupCoordinates;
  final String dropOffAddress;
  final LatLng dropOffCoordinates;
  final double distance;

  CourierTile({
    Key key,
    @required this.courier,
    @required this.pickupAddress,
    @required this.pickupCoordinates,
    @required this.dropOffAddress,
    @required this.dropOffCoordinates,
    @required this.distance,
  }) : super(key: key);

  @override
  State<CourierTile> createState() => _CourierTileState();
}

class _CourierTileState extends State<CourierTile> {
  int flag = 0;
  String deliveryPriceUid;
  double deliveryFee = 0.0;

  @override
  Widget build(BuildContext context) {
    deliveryPriceUid = widget.courier.deliveryPriceRef.id;

    final FirebaseAuth _auth = FirebaseAuth.instance;
    User user = _auth.currentUser;

    var color;
    if (widget.courier.status == "Offline") {
      color = Colors.redAccent;
    } else {
      color = Colors.green;
    }

    return user == null ? LoginScreen() : StreamBuilder<DeliveryPrice>(
      stream: DatabaseService(uid: deliveryPriceUid).deliveryPriceData,
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          DeliveryPrice deliveryPriceData = snapshot.data;

          deliveryFee = (deliveryPriceData.baseFare.toDouble() + (deliveryPriceData.farePerKM.toDouble() * widget.distance));
          print('(${deliveryPriceData.baseFare} + (${deliveryPriceData.farePerKM} * ${widget.distance})) = $deliveryFee');

          return Padding(
            padding: EdgeInsets.all(8),
            child: ExpansionTileCard(
              //expandedColor: Colors.grey,
              title: Text("${widget.courier.fName} ${widget.courier.lName}", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),),
              leading: ClipOval(
                child: SizedBox(
                  width: 48,
                  height: 48,
                  child: Container(
                    child: CircleAvatar(
                      radius: 20,
                      backgroundImage: NetworkImage(widget.courier.avatarUrl),
                      backgroundColor: Colors.white,
                    ),
                  ),
                ),
              ),
              subtitle: Container(
                padding: EdgeInsets.only(top: 5),
                child: Text.rich(
                  TextSpan(children: [
                    TextSpan(text: "Vehicle Type: ", style: Theme.of(context).textTheme.bodyText2.copyWith(fontWeight: FontWeight.bold)),
                    TextSpan(text: "${widget.courier.vehicleType}\n",style: Theme.of(context).textTheme.bodyText2),
                    TextSpan(text: "Delivery Fee: ", style: Theme.of(context).textTheme.bodyText2.copyWith(fontWeight: FontWeight.bold)),
                    TextSpan(text: "₱${deliveryFee.toInt()}\n",style: Theme.of(context).textTheme.bodyText2),
                    TextSpan(text: "Status: ", style: Theme.of(context).textTheme.bodyText2.copyWith(fontWeight: FontWeight.bold)),
                    TextSpan(text: "${widget.courier.status}", style: TextStyle(color: color, fontWeight: FontWeight.bold,)),
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
                        leading: Icon(Icons.info_rounded, color: Colors.red),
                        title: Text('Additional Information', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                        subtitle: Container(
                          padding: EdgeInsets.only(top: 5),
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
                      ),
                      Container(
                          padding: EdgeInsets.only(right: 40),
                          child: Image.network(widget.courier.vehiclePhoto_, height: 140, width: 326,)
                      ),
                      SizedBox(height: 20,),
                      Align(
                        alignment: Alignment.centerRight,
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
                                        dropOffCoordinates: widget.dropOffCoordinates,
                                        deliveryFee: deliveryFee.toInt(),),
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
          );
        } else {
          return Padding(
            padding: EdgeInsets.all(8),
            child: ExpansionTileCard(
              //expandedColor: Colors.grey,
              title: Text("Loading...", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),),
              leading: ClipOval(
                child: SizedBox(
                  width: 48,
                  height: 48,
                  child: Container(
                    child: CircleAvatar(
                      radius: 20,
                      backgroundColor: Colors.white,
                    ),
                  ),
                ),
              ),
              subtitle: Container(
                padding: EdgeInsets.only(top: 5),
                child: SizedBox(height: 20),
              ),
            ),
          );
        }
      }
    );
  }
}