import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:expansion_tile_card/expansion_tile_card.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:proxpress/UI/CustomerUI/customer_remarks.dart';
import 'package:proxpress/UI/login_screen.dart';
import 'package:proxpress/models/couriers.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

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
  int baseFare = 0;
  int farePerKM = 0;

  // need to get this from distance of 2 geopoints
  var deliveryFee = 0.0;

  @override
  Widget build(BuildContext context) {
    widget.courier.deliveryPriceRef.get().then((DocumentSnapshot doc) {
      if(flag <= 0){
        setState((){
          baseFare = doc['Base Fare'];
          farePerKM = doc['Fare Per KM'];
        });
        flag++;
      }
    });

    print('Base Fare: $baseFare');
    print('Fare Per KM: $farePerKM');

    var baseFareDouble = baseFare;
    var farePerKMDouble = farePerKM;

    // deliveryFeeInt = (baseFare + (farePerKM * widget.distance)) as int;
    // print('Int: $deliveryFeeInt');
    deliveryFee = (baseFareDouble + (farePerKMDouble * widget.distance));
    print('Double: ${deliveryFee.toInt()}');

    final FirebaseAuth _auth = FirebaseAuth.instance;
    User user = _auth.currentUser;
    var color;
    if (widget.courier.status == "Offline") {
      color = Colors.redAccent;
    } else {
      color = Colors.green;
    }
    return user == null ? LoginScreen() : Padding(
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
  }
}