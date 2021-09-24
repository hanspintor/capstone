import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:proxpress/UI/login_screen.dart';
import 'package:proxpress/models/customers.dart';
import 'package:proxpress/models/deliveries.dart';
import 'package:proxpress/services/database.dart';

class FeedbackTile extends StatefulWidget {
  final Delivery delivery;

  FeedbackTile({
    Key key,
    @required this.delivery,
  }) : super(key: key);

  @override
  State<FeedbackTile> createState() => _FeedbackTileState();
}

class _FeedbackTileState extends State<FeedbackTile> {
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
          int rating = widget.delivery.rating;
          String feedback = widget.delivery.feedback;

          if(widget.delivery.rating != 0 && widget.delivery.feedback != ""){
            return Padding(
              padding: const EdgeInsets.all(8.0),
              child: StreamBuilder<Customer>(
                  stream: DatabaseService(uid: uid).customerData,
                  builder: (context, snapshot) {
                    if (snapshot.hasData) {
                      return Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Card(
                          child: ListTile(
                              title: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: List.generate(5, (index) {
                                  return Icon(
                                    index < rating ? Icons.star : Icons.star_border, color: Colors.amber,
                                  );
                                }),
                              ),
                              subtitle: Text(feedback)
                          ),
                        ),
                      );
                    }
                    else return Container();
                  }
              ),
            );
          }
          return Container();
        }
        else {
          return Container();
        }
      },
    );
  }
}