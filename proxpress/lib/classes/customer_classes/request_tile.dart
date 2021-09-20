import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:expansion_tile_card/expansion_tile_card.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:proxpress/classes/chat_page.dart';
import 'package:proxpress/UI/CustomerUI/delivery_status.dart';
import 'package:proxpress/UI/login_screen.dart';
import 'package:proxpress/models/couriers.dart';
import 'package:proxpress/models/customers.dart';
import 'package:proxpress/models/deliveries.dart';
import 'package:proxpress/services/database.dart';

class RequestTile extends StatefulWidget {
  final Delivery delivery;

  RequestTile({
    Key key,
    @required this.delivery,
  }) : super(key: key);

  @override
  State<RequestTile> createState() => _RequestTileState();
}

class _RequestTileState extends State<RequestTile> {
  int flag = 0;
  @override
  Widget build(BuildContext context) {
    final FirebaseAuth _auth = FirebaseAuth.instance;
    User user = _auth.currentUser;

    return user == null ? LoginScreen() : StreamBuilder<Delivery>(
      stream: DatabaseService(uid: widget.delivery.uid).deliveryData,
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          Delivery deliveryData = snapshot.data;

          var color;
          if(widget.delivery.deliveryStatus == 'Ongoing'){
            color = Colors.orange;
          }
          else if(widget.delivery.deliveryStatus == 'Pending'){
            color = Colors.blue;
          }
          else if (widget.delivery.deliveryStatus == 'Delivered'){
            color = Colors.green;
          }

          if(widget.delivery.deliveryStatus == 'Ongoing'){
            return Padding(
              padding: const EdgeInsets.all(8.0),
              child: StreamBuilder<Customer>(
                  stream: DatabaseService(uid: widget.delivery.customerRef.id).customerData,
                  builder: (context, snapshot) {
                    if (snapshot.hasData) {
                      Customer customerData = snapshot.data;
                      return Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: StreamBuilder<Courier>(
                            stream: DatabaseService(uid: widget.delivery.courierRef.id).courierData,
                            builder: (context, snapshot) {
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
                                        TextSpan(text: "${deliveryData.deliveryStatus} \n", style: Theme.of(context).textTheme.bodyText2.copyWith(fontWeight: FontWeight.bold, color: color)),
                                        TextSpan(text: "Contact Number: ", style: Theme.of(context).textTheme.bodyText2.copyWith(fontWeight: FontWeight.bold)),
                                        TextSpan(text: courierData.contactNo),
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
                                                      TextSpan(text: "${widget.delivery.pickupAddress}\n", style: Theme.of(context).textTheme.bodyText2),
                                                      TextSpan(text: '\n'),
                                                      TextSpan(text: "Drop Off Address: ", style: Theme.of(context).textTheme.bodyText2.copyWith(fontWeight: FontWeight.bold)),
                                                      TextSpan(text: "${widget.delivery.dropOffAddress}\n", style: Theme.of(context).textTheme.bodyText2),
                                                      TextSpan(text: '\n'),
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
                                                      TextSpan(text: "${widget.delivery.pickupPointPerson}\n",style: Theme.of(context).textTheme.bodyText2),
                                                      TextSpan(text: "Contact Number: ", style: Theme.of(context).textTheme.bodyText2.copyWith(fontWeight: FontWeight.bold)),
                                                      TextSpan(text: "${widget.delivery.pickupContactNum}\n",style: Theme.of(context).textTheme.bodyText2),
                                                      TextSpan(text: "\n"),
                                                      TextSpan(text: "Receiver: ", style: Theme.of(context).textTheme.bodyText2.copyWith(fontWeight: FontWeight.bold)),
                                                      TextSpan(text: "${widget.delivery.dropoffPointPerson}\n",style: Theme.of(context).textTheme.bodyText2),
                                                      TextSpan(text: "Contact Number: ", style: Theme.of(context).textTheme.bodyText2.copyWith(fontWeight: FontWeight.bold)),
                                                      TextSpan(text: "${widget.delivery.dropoffContactNum}\n",style: Theme.of(context).textTheme.bodyText2),
                                                    ],
                                                    ),
                                                  ),
                                                ),
                                              ),
                                              Row(
                                                mainAxisAlignment: MainAxisAlignment.center,
                                                children: [
                                                  Container(
                                                    height: 25,
                                                    child: (() {
                                                      return ElevatedButton(
                                                          child: Text('View Delivery', style: TextStyle(color: Colors.white, fontSize: 10),),
                                                          onPressed: () {
                                                            Navigator.push(context, MaterialPageRoute(builder: (context) => DeliveryStatus(delivery: widget.delivery)));
                                                          }
                                                      );
                                                    }())
                                                  ),
                                                  SizedBox(width: 20,),
                                                  Container(
                                                    height: 25,
                                                    child: (() {
                                                      return ElevatedButton(
                                                          child: Text('Chat Courier', style: TextStyle(color: Colors.white, fontSize: 10),),
                                                          onPressed: () {
                                                            Navigator.push(context, MaterialPageRoute(builder: (context) => ChatPage(delivery: widget.delivery)));
                                                          }
                                                      );
                                                    }())
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                );
                              }
                              else return Container();
                            }
                        ),
                      );
                    }
                    else return Container();
                  }
              ),
            );
          }
          else if(widget.delivery.deliveryStatus == 'Delivered'){
            return Padding(
              padding: const EdgeInsets.all(8.0),
              child: StreamBuilder<Customer>(
                  stream: DatabaseService(uid: widget.delivery.customerRef.id).customerData,
                  builder: (context, snapshot) {
                    if (snapshot.hasData) {
                      Customer customerData = snapshot.data;
                      return Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: StreamBuilder<Courier>(
                              stream: DatabaseService(uid: widget.delivery.courierRef.id).courierData,
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
                                          TextSpan(text: "${widget.delivery.deliveryStatus} \n", style: Theme.of(context).textTheme.bodyText2.copyWith(fontWeight: FontWeight.bold, color: color)),
                                          TextSpan(text: "Contact Number: ", style: Theme.of(context).textTheme.bodyText2.copyWith(fontWeight: FontWeight.bold)),
                                          TextSpan(text: courierData.contactNo),
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
                                                        TextSpan(text: "${widget.delivery.pickupAddress}\n", style: Theme.of(context).textTheme.bodyText2),
                                                        TextSpan(text: '\n'),
                                                        TextSpan(text: "Drop Off Address: ", style: Theme.of(context).textTheme.bodyText2.copyWith(fontWeight: FontWeight.bold)),
                                                        TextSpan(text: "${widget.delivery.dropOffAddress}\n", style: Theme.of(context).textTheme.bodyText2),
                                                        TextSpan(text: '\n'),
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
                                                        TextSpan(text: "${widget.delivery.pickupPointPerson}\n",style: Theme.of(context).textTheme.bodyText2),
                                                        TextSpan(text: "Contact Number: ", style: Theme.of(context).textTheme.bodyText2.copyWith(fontWeight: FontWeight.bold)),
                                                        TextSpan(text: "${widget.delivery.pickupContactNum}\n",style: Theme.of(context).textTheme.bodyText2),
                                                        TextSpan(text: "\n"),
                                                        TextSpan(text: "Receiver: ", style: Theme.of(context).textTheme.bodyText2.copyWith(fontWeight: FontWeight.bold)),
                                                        TextSpan(text: "${widget.delivery.dropoffPointPerson}\n",style: Theme.of(context).textTheme.bodyText2),
                                                        TextSpan(text: "Contact Number: ", style: Theme.of(context).textTheme.bodyText2.copyWith(fontWeight: FontWeight.bold)),
                                                        TextSpan(text: "${widget.delivery.dropoffContactNum}\n",style: Theme.of(context).textTheme.bodyText2),
                                                      ],
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                            Container(
                                                height: 25,
                                                child: (() {
                                                  if (widget.delivery.deliveryStatus == "Delivered") {
                                                    return ElevatedButton(
                                                        child: Text('Send Feedback', style: TextStyle(color: Colors.white, fontSize: 10),),
                                                        onPressed: () {
                                                          showFeedback();
                                                        }
                                                    );
                                                  }
                                                }())
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  );
                                }
                                else return Container();
                              }
                          )
                      );
                    }
                    else return Container();
                  }
              ),
            );
          }
          else if(widget.delivery.courierApproval == 'Pending'){
            return Padding(
              padding: const EdgeInsets.all(8.0),
              child: StreamBuilder<Customer>(
                  stream: DatabaseService(uid: widget.delivery.customerRef.id).customerData,
                  builder: (context, snapshot) {
                    if (snapshot.hasData) {
                      Customer customerData = snapshot.data;
                      return Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: StreamBuilder<Courier>(
                              stream: DatabaseService(uid: widget.delivery.courierRef.id).courierData,
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
                                          TextSpan(text: "${widget.delivery.courierApproval} \n", style: Theme.of(context).textTheme.bodyText2.copyWith(fontWeight: FontWeight.bold, color: color)),
                                          TextSpan(text: "Contact Number: ", style: Theme.of(context).textTheme.bodyText2.copyWith(fontWeight: FontWeight.bold)),
                                          TextSpan(text: courierData.contactNo),
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
                                                        TextSpan(text: "${widget.delivery.pickupAddress}\n", style: Theme.of(context).textTheme.bodyText2),
                                                        TextSpan(text: '\n'),
                                                        TextSpan(text: "Drop Off Address: ", style: Theme.of(context).textTheme.bodyText2.copyWith(fontWeight: FontWeight.bold)),
                                                        TextSpan(text: "${widget.delivery.dropOffAddress}\n", style: Theme.of(context).textTheme.bodyText2),
                                                        TextSpan(text: '\n'),
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
                                                        TextSpan(text: "${widget.delivery.pickupPointPerson}\n",style: Theme.of(context).textTheme.bodyText2),
                                                        TextSpan(text: "Contact Number: ", style: Theme.of(context).textTheme.bodyText2.copyWith(fontWeight: FontWeight.bold)),
                                                        TextSpan(text: "${widget.delivery.pickupContactNum}\n",style: Theme.of(context).textTheme.bodyText2),
                                                        TextSpan(text: "\n"),
                                                        TextSpan(text: "Receiver: ", style: Theme.of(context).textTheme.bodyText2.copyWith(fontWeight: FontWeight.bold)),
                                                        TextSpan(text: "${widget.delivery.dropoffPointPerson}\n",style: Theme.of(context).textTheme.bodyText2),
                                                        TextSpan(text: "Contact Number: ", style: Theme.of(context).textTheme.bodyText2.copyWith(fontWeight: FontWeight.bold)),
                                                        TextSpan(text: "${widget.delivery.dropoffContactNum}\n",style: Theme.of(context).textTheme.bodyText2),
                                                      ],
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                            Container(
                                                height: 25,
                                                child: ElevatedButton(
                                                    child: Text('Cancel', style: TextStyle(color: Colors.white, fontSize: 10),),
                                                    onPressed: () {
                                                    }
                                                )
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  );
                                }
                                else return Container();
                              }
                          )
                      );
                    }
                    else return Container();
                  }
              ),
            );
          }
          else if (widget.delivery.courierApproval == 'Cancelled' || widget.delivery.deliveryStatus == 'Cancelled'){
            return Padding(
              padding: const EdgeInsets.all(8.0),
              child: StreamBuilder<Customer>(
                  stream: DatabaseService(uid: widget.delivery.customerRef.id).customerData,
                  builder: (context, snapshot) {
                    if (snapshot.hasData) {
                      Customer customerData = snapshot.data;
                      return Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: StreamBuilder<Courier>(
                              stream: DatabaseService(uid: widget.delivery.courierRef.id).courierData,
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
                                          TextSpan(text: "${widget.delivery.courierApproval} \n", style: Theme.of(context).textTheme.bodyText2.copyWith(fontWeight: FontWeight.bold, color: color)),
                                          TextSpan(text: "Contact Number: ", style: Theme.of(context).textTheme.bodyText2.copyWith(fontWeight: FontWeight.bold)),
                                          TextSpan(text: courierData.contactNo),
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
                                                        TextSpan(text: "${widget.delivery.pickupAddress}\n", style: Theme.of(context).textTheme.bodyText2),
                                                        TextSpan(text: '\n'),
                                                        TextSpan(text: "Drop Off Address: ", style: Theme.of(context).textTheme.bodyText2.copyWith(fontWeight: FontWeight.bold)),
                                                        TextSpan(text: "${widget.delivery.dropOffAddress}\n", style: Theme.of(context).textTheme.bodyText2),
                                                        TextSpan(text: '\n'),
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
                                                        TextSpan(text: "${widget.delivery.pickupPointPerson}\n",style: Theme.of(context).textTheme.bodyText2),
                                                        TextSpan(text: "Contact Number: ", style: Theme.of(context).textTheme.bodyText2.copyWith(fontWeight: FontWeight.bold)),
                                                        TextSpan(text: "${widget.delivery.pickupContactNum}\n",style: Theme.of(context).textTheme.bodyText2),
                                                        TextSpan(text: "\n"),
                                                        TextSpan(text: "Receiver: ", style: Theme.of(context).textTheme.bodyText2.copyWith(fontWeight: FontWeight.bold)),
                                                        TextSpan(text: "${widget.delivery.dropoffPointPerson}\n",style: Theme.of(context).textTheme.bodyText2),
                                                        TextSpan(text: "Contact Number: ", style: Theme.of(context).textTheme.bodyText2.copyWith(fontWeight: FontWeight.bold)),
                                                        TextSpan(text: "${widget.delivery.dropoffContactNum}\n",style: Theme.of(context).textTheme.bodyText2),
                                                      ],
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  );
                                }
                                else return Container();
                              }
                          )
                      );
                    }
                    else return Container();
                  }
              ),
            );
          }
          else return Container();
        }
        else {
          return Container();
        }
      },
    );
  }

  double rating = 0;
  String feedback  = '';
  void showFeedback(){
    DocumentReference courier = FirebaseFirestore.instance.collection('Couriers').doc(widget.delivery.courierRef.id);
    DocumentReference customer = FirebaseFirestore.instance.collection('Customers').doc(widget.delivery.customerRef.id);

    showDialog(
      context : context,
      builder: (context) => AlertDialog(
        title: Text('How\'s My Service?'),
        content: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            RatingBar.builder(
              minRating: 1,
              itemBuilder: (context, _) => Icon(Icons.star, color: Colors.amber),
              updateOnDrag: true,
              onRatingUpdate: (rating) => setState((){
                this.rating = rating;
              }),
            ),
            Text('Rate Me',
              style: TextStyle(fontSize: 20),
            ),
            SizedBox(height: 10),
            TextFormField(
              maxLines: 2,
              maxLength: 200,
              decoration: InputDecoration(
                hintText: 'Leave a Feedback',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.multiline,
              onChanged: (val) => setState(() => feedback = val),
            ),
          ],
        ),
        actions: [
          TextButton(
              child: Text('OK'),
              onPressed: () async{
                  await DatabaseService().updateFeedback(rating, feedback, courier, customer);
                  Navigator.pop(context);
              }
          ),
        ],
      ),
    );
  }
}