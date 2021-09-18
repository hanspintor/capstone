import 'package:expansion_tile_card/expansion_tile_card.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:proxpress/UI/login_screen.dart';
import 'package:proxpress/models/customers.dart';
import 'package:proxpress/models/deliveries.dart';
import 'package:proxpress/services/database.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class TransactionTile extends StatefulWidget {
  final Delivery delivery;

  TransactionTile({
    Key key,
    @required this.delivery,
  }) : super(key: key);

  @override
  State<TransactionTile> createState() => _TransactionTileState();
}

class _TransactionTileState extends State<TransactionTile> {
  String uid;

  @override
  Widget build(BuildContext context) {
    uid = widget.delivery.customerRef.id;

    final FirebaseAuth _auth = FirebaseAuth.instance;
    User user = _auth.currentUser;
    return user == null ? LoginScreen() : StreamBuilder<Delivery>(
      stream: DatabaseService(uid: widget.delivery.uid).deliveryData,
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          //Delivery deliveryData = snapshot.data;

          return Padding(
            padding: const EdgeInsets.all(8.0),
            child: StreamBuilder<Customer>(
                stream: DatabaseService(uid: uid).customerData,
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    Customer customerData = snapshot.data;
                    int rating = widget.delivery.rating;
                    return Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: ExpansionTileCard(
                        title: Text("${customerData.fName} ${customerData.lName}",
                          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),),
                        leading: Container(
                          child: CircleAvatar(
                            radius: 20,
                            backgroundImage: NetworkImage(customerData.avatarUrl),
                            backgroundColor: Colors.white,
                          ),
                        ),
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
                                      title: Text("Delivery Information", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),),
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
                                      leading: Icon(Icons.star_rounded, color: Colors.red),
                                      title: Text("Rating", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),),
                                      subtitle: Container(
                                        padding: EdgeInsets.only(top: 5),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: List.generate(5, (index) {
                                            return Icon(
                                              index < rating ? Icons.star : Icons.star_border, color: Colors.amber,
                                            );
                                          }),
                                        )
                                      ),
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
                  else return Container();
                }
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