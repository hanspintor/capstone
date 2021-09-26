import 'package:expansion_tile_card/expansion_tile_card.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:proxpress/Load/user_load.dart';
import 'package:proxpress/classes/customer_classes/request_tile.dart';
import 'package:proxpress/models/couriers.dart';
import 'package:proxpress/models/customers.dart';
import 'package:proxpress/models/deliveries.dart';
import 'package:proxpress/services/database.dart';
import '../login_screen.dart';

class PendingDeliveryRequest extends StatefulWidget {
  @override
  _PendingDeliveryRequestState createState() => _PendingDeliveryRequestState();
}

class _PendingDeliveryRequestState extends State<PendingDeliveryRequest> {
  @override
  Widget build(BuildContext context) {
    final delivery = Provider.of<List<Delivery>>(context);

    if (delivery.length != 0) {
      return delivery == null ? UserLoading() : ListView.builder(
        physics: NeverScrollableScrollPhysics(),
        shrinkWrap: true,
        itemCount: delivery.length,
        itemBuilder: (context, index) {
          final FirebaseAuth _auth = FirebaseAuth.instance;
          User user = _auth.currentUser;

          return user == null ? LoginScreen() : StreamBuilder<Delivery>(
              stream: DatabaseService(uid: delivery[index].uid).deliveryData,
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  String delivery_uid = delivery[index].uid;

                  var color;
                  if(delivery[index].deliveryStatus == 'Ongoing'){
                    color = Colors.orange;
                  }
                  else if(delivery[index].deliveryStatus == 'Pending'){
                    color = Colors.blue;
                  }
                  else if (delivery[index].deliveryStatus == 'Delivered'){
                    color = Colors.green;
                  }
                  else return null;

                  return Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: StreamBuilder<Courier>(
                          stream: DatabaseService(uid: delivery[index].courierRef.id).courierData,
                          builder: (context,snapshot){
                            if(snapshot.hasData){
                              Courier courierData = snapshot.data;
                              return ExpansionTileCard(
                                title: Text("${courierData.fName} ${courierData.lName}",
                                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),),
                                leading: Container(
                                  child: CircleAvatar(
                                    radius: 20,
                                    backgroundImage: NetworkImage(courierData.avatarUrl),
                                    backgroundColor: Colors.white,
                                  ),
                                ),
                                subtitle: Container(
                                  padding: EdgeInsets.only(top: 5),
                                  child: Text.rich(
                                    TextSpan(children: [
                                      TextSpan(text: "Status: ", style: Theme.of(context).textTheme.bodyText2.copyWith(fontWeight: FontWeight.bold)),
                                      TextSpan(text: "${delivery[index].courierApproval} \n", style: Theme.of(context).textTheme.bodyText2.copyWith(fontWeight: FontWeight.bold, color: color)),
                                      TextSpan(text: "Payment Method: ", style: Theme.of(context).textTheme.bodyText2.copyWith(fontWeight: FontWeight.bold)),
                                      TextSpan(text: "${delivery[index].paymentOption}\n", style: TextStyle(color: Colors.black)),
                                      TextSpan(text: "Delivery Fee: ", style: Theme.of(context).textTheme.bodyText2.copyWith(fontWeight: FontWeight.bold)),
                                      TextSpan(text: "\₱${delivery[index].deliveryFee}\n", style: TextStyle(color: Colors.black)),
                                      TextSpan(text: "Contact Number: ", style: Theme.of(context).textTheme.bodyText2.copyWith(fontWeight: FontWeight.bold)),
                                      TextSpan(text: courierData.contactNo, style: TextStyle(color: Colors.black)),
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
                                                    TextSpan(text: "Pick Up Address: ", style: Theme.of(context).textTheme.bodyText2.copyWith(fontWeight: FontWeight.bold)),
                                                    TextSpan(text: "${delivery[index].pickupAddress}\n", style: Theme.of(context).textTheme.bodyText2),
                                                    TextSpan(text: '\n'),
                                                    TextSpan(text: "Drop Off Address: ", style: Theme.of(context).textTheme.bodyText2.copyWith(fontWeight: FontWeight.bold)),
                                                    TextSpan(text: "${delivery[index].dropOffAddress}\n", style: Theme.of(context).textTheme.bodyText2),
                                                    TextSpan(text: '\n'),
                                                    TextSpan(text: "Item Description: ", style: Theme.of(context).textTheme.bodyText2.copyWith(fontWeight: FontWeight.bold)),
                                                    TextSpan(text: "${delivery[index].itemDescription}\n",style: Theme.of(context).textTheme.bodyText2),
                                                    TextSpan(text: "Specific Instructions: \n", style: Theme.of(context).textTheme.bodyText2.copyWith(fontWeight: FontWeight.bold)),
                                                    TextSpan(text: "${delivery[index].specificInstructions}\n",style: Theme.of(context).textTheme.bodyText2),
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
                                                    TextSpan(text: "${delivery[index].pickupPointPerson}\n",style: Theme.of(context).textTheme.bodyText2),
                                                    TextSpan(text: "Contact Number: ", style: Theme.of(context).textTheme.bodyText2.copyWith(fontWeight: FontWeight.bold)),
                                                    TextSpan(text: "${delivery[index].pickupContactNum}\n",style: Theme.of(context).textTheme.bodyText2),
                                                    TextSpan(text: "\n"),
                                                    TextSpan(text: "Receiver: ", style: Theme.of(context).textTheme.bodyText2.copyWith(fontWeight: FontWeight.bold)),
                                                    TextSpan(text: "${delivery[index].dropoffPointPerson}\n",style: Theme.of(context).textTheme.bodyText2),
                                                    TextSpan(text: "Contact Number: ", style: Theme.of(context).textTheme.bodyText2.copyWith(fontWeight: FontWeight.bold)),
                                                    TextSpan(text: "${delivery[index].dropoffContactNum}\n",style: Theme.of(context).textTheme.bodyText2),
                                                  ],
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                        Container(
                                          height: 25,
                                          child: ElevatedButton.icon(
                                            icon: Icon(Icons.cancel, size: 20),
                                            label: Text('Cancel', style: TextStyle(color: Colors.white, fontSize: 10),),
                                            onPressed: () async {
                                              await DatabaseService(uid: delivery_uid).customerCancelRequest();
                                            }
                                          )
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              );
                            } else return Container();
                          }
                      )
                  );
                } else return Container();
              }
          );
        },
      );
    } else {
      return Row(
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Text(
                'You currently have no request.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 18,
                ),
              ),
            ),
          ),
        ],
      );
    }
  }
}