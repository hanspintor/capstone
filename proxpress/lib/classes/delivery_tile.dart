import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:expansion_tile_card/expansion_tile_card.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:proxpress/UI/login_screen.dart';
import 'package:proxpress/models/customers.dart';
import 'package:proxpress/models/deliveries.dart';
import 'package:proxpress/services/database.dart';

class DeliveryTile extends StatefulWidget {
  final Delivery delivery;
  final String pickupAddress;
  final GeoPoint pickupCoordinates;
  final String dropOffAddress;
  final GeoPoint dropOffCoordinates;
  final String itemDescription;
  final String senderName;
  final String senderContactNum;
  final String receiverName;
  final String receiverContactNum;
  final String whoWillPay;
  final String specificInstructions;
  final String paymentOption;

  DeliveryTile({
    Key key,
    @required this.delivery,
    @required this.pickupAddress,
    @required this.pickupCoordinates,
    @required this.dropOffAddress,
    @required this.dropOffCoordinates,
    @required this.itemDescription,
    @required this.senderName,
    @required this.senderContactNum,
    @required this.receiverName,
    @required this.receiverContactNum,
    @required this.whoWillPay,
    @required this.specificInstructions,
    @required this.paymentOption,

  }) : super(key: key);

  @override
  State<DeliveryTile> createState() => _DeliveryTileState();
}

class _DeliveryTileState extends State<DeliveryTile> {
  int flag = 0;
  String uid;

  @override

  Widget build(BuildContext context) {
    widget.delivery.customerRef.get().then((DocumentSnapshot doc) {
      if(flag <= 0){
        setState(() {
          uid = doc.id;
        });
        flag++;
      }
    });

    final FirebaseAuth _auth = FirebaseAuth.instance;
    User user = _auth.currentUser;
    return user == null ? LoginScreen() : StreamBuilder<Customer>(
      stream: DatabaseService(uid: uid).customerData,
    builder: (context, snapshot) {
      if (snapshot.hasData) {
        Customer customerData = snapshot.data;

        return Padding(
          padding: const EdgeInsets.all(8.0),
          child: ExpansionTileCard(
            title: Text("${customerData.fName} ${customerData.lName}",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),),
            leading: Container(
              child: CircleAvatar(
                radius: 20,
                backgroundImage: NetworkImage(customerData.avatarUrl),
              ),
            ),
            subtitle: Container(
              padding: EdgeInsets.only(top: 5),
              child: Text.rich(
                TextSpan(children: [
                  TextSpan(text: "Pick Up Address: ", style: Theme.of(context).textTheme.bodyText2.copyWith(fontWeight: FontWeight.bold)),
                  TextSpan(text: "${widget.delivery.pickupAddress}\n", style: Theme.of(context).textTheme.bodyText2),
                  TextSpan(text: '\n'),
                  TextSpan(text: "Drop Off Address: ", style: Theme.of(context).textTheme.bodyText2.copyWith(fontWeight: FontWeight.bold)),
                  TextSpan(text: "${widget.delivery.dropOffAddress}\n", style: Theme.of(context).textTheme.bodyText2),
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
                  children: [
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        ListTile(
                          leading: Icon(Icons.info_rounded, color: Colors.red),
                          title: Text("Additional Information", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),),
                          subtitle: Container(
                            padding: EdgeInsets.only(top: 5),
                            child: Text.rich(
                              TextSpan(children: [
                                TextSpan(text: "Item Description: ", style: Theme.of(context).textTheme.bodyText2.copyWith(fontWeight: FontWeight.bold)),
                                TextSpan(text: "${widget.delivery.itemDescription}\n",style: Theme.of(context).textTheme.bodyText2),
                                TextSpan(text: "Specific Instructions: \n", style: Theme.of(context).textTheme.bodyText2.copyWith(fontWeight: FontWeight.bold)),
                                TextSpan(text: "${widget.delivery.specificInstructions}\n",style: Theme.of(context).textTheme.bodyText2),
                              ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        ListTile(
                          leading: Icon(Icons.phone_rounded, color: Colors.red),
                          title: Text("Contact Information", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),),
                          subtitle: Container(
                            padding: EdgeInsets.only(top: 5),
                            child: Text.rich(
                              TextSpan(children: [
                                TextSpan(text: "Sender: ", style: Theme.of(context).textTheme.bodyText2.copyWith(fontWeight: FontWeight.bold)),
                                TextSpan(text: "${widget.delivery.senderName}\n",style: Theme.of(context).textTheme.bodyText2),
                                TextSpan(text: "Contact Number: ", style: Theme.of(context).textTheme.bodyText2.copyWith(fontWeight: FontWeight.bold)),
                                TextSpan(text: "${widget.delivery.senderContactNum}\n",style: Theme.of(context).textTheme.bodyText2),
                                TextSpan(text: "\n"),
                                TextSpan(text: "Receiver: ", style: Theme.of(context).textTheme.bodyText2.copyWith(fontWeight: FontWeight.bold)),
                                TextSpan(text: "${widget.delivery.receiverName}\n",style: Theme.of(context).textTheme.bodyText2),
                                TextSpan(text: "Contact Number: ", style: Theme.of(context).textTheme.bodyText2.copyWith(fontWeight: FontWeight.bold)),
                                TextSpan(text: "${widget.delivery.receiverContactNum}\n",style: Theme.of(context).textTheme.bodyText2),
                              ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Container(
                            height: 25,
                            child: ElevatedButton(
                                child: Text('Confirm', style: TextStyle(color: Colors.white, fontSize: 10),),
                                onPressed: () {
                                }
                            )
                        ),
                        Container(
                            padding: EdgeInsets.only(left: 10),
                            height: 25,
                            child: ElevatedButton(
                                child: Text('Decline', style: TextStyle(color: Colors.white, fontSize: 10),),
                                onPressed: () {
                                }
                            )
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      }
      else {
        return Container();
      }
    },
    );
  }
}