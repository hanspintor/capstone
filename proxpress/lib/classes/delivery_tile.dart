import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:expansion_tile_card/expansion_tile_card.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:proxpress/UI/CustomerUI/customer_remarks.dart';
import 'package:proxpress/UI/login_screen.dart';
import 'package:proxpress/models/couriers.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:proxpress/models/deliveries.dart';

class DeliveryTile extends StatefulWidget {
  final Delivery delivery;

  DeliveryTile({ Key key, this.delivery}) : super(key: key);

  @override
  State<DeliveryTile> createState() => _DeliveryTileState();
}

class _DeliveryTileState extends State<DeliveryTile> {
  @override
  Widget build(BuildContext context) {
    final FirebaseAuth _auth = FirebaseAuth.instance;
    User user = _auth.currentUser;

    return user == null ? LoginScreen() : Padding(
      padding: EdgeInsets.only(top: 0.0),
      child: ExpansionTileCard(
        //expandedColor: Colors.grey,
        title: Text("${widget.delivery.uid}", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),),
        leading: ClipOval(
          child: SizedBox(
            width: 48,
            height: 48,
            child:Image.network('https://firebasestorage.googleapis.com/v0/b/proxpress-629e3.appspot.com/o/profile-user.png?alt=media&token=6727618b-4289-4438-8a93-a4f14753d92e'),
          ),
        ),
        subtitle: Text.rich(
          TextSpan(children: [
            //TextSpan(text: "Vehicle Type: ", style: Theme.of(context).textTheme.bodyText2.copyWith(fontWeight: FontWeight.bold)),
            //TextSpan(text: "${widget.delivery.vehicleType}\n",style: Theme.of(context).textTheme.bodyText2),
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
                Text.rich(
                  TextSpan(children: [
                    //TextSpan(text: "Contact Number: ", style: Theme.of(context).textTheme.bodyText2.copyWith(fontWeight: FontWeight.bold)),
                    //TextSpan(text: "${widget.courier.contactNum}\n",style: Theme.of(context).textTheme.bodyText2),
                  ],
                  ),
                ),
                SizedBox(height: 20,),
                Align(
                  alignment: Alignment.centerRight,
                  child: Container(
                      height: 25,
                      child: ElevatedButton(
                          child: Text('Confirm', style: TextStyle(color: Colors.white, fontSize: 10),),
                          onPressed: () {
                            Navigator.push(context, MaterialPageRoute(builder: (context) =>
                                Text('Nice'),
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