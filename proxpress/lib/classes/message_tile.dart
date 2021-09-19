import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:expansion_tile_card/expansion_tile_card.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:proxpress/UI/CustomerUI/customer_chat.dart';
import 'package:proxpress/UI/CustomerUI/delivery_status.dart';
import 'package:proxpress/UI/login_screen.dart';
import 'package:proxpress/models/couriers.dart';
import 'package:proxpress/models/customers.dart';
import 'package:proxpress/models/deliveries.dart';
import 'package:proxpress/models/messages.dart';
import 'package:proxpress/services/database.dart';
import 'package:intl/intl.dart';

class MessageTile extends StatefulWidget {
  final Message message;

  MessageTile({
    Key key,
    @required this.message,
  }) : super(key: key);

  @override
  State<MessageTile> createState() => _MessageTileState();
}

class _MessageTileState extends State<MessageTile> {
  @override
  Widget build(BuildContext context) {
    final FirebaseAuth _auth = FirebaseAuth.instance;
    User user = _auth.currentUser;
    print(widget.message.uid);
    return user == null ? LoginScreen() :  SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: StreamBuilder<Message>(
          stream: DatabaseService(uid: widget.message.uid).messageData,
          builder: (context, snapshot) {
            print(snapshot.hasData);
            if(snapshot.hasData){
              Message message = snapshot.data;
              String time = DateFormat.jm().format(message.timeSent.toDate());
              print('Message: ${message.messageContent} \nSent By: ${message.sentBy.toString()} \nSent To: ${message.sentTo.toString()} \nTime Sent: ${message.timeSent.toDate()}');
              if (message.sentBy.toString().contains('Customers')) {
                return Text('${message.messageContent} :You \nTime Sent: ${time}', textAlign: TextAlign.right,);
              } else if (message.sentBy.toString().contains('Couriers')) {
                return Text('Message: ${message.messageContent} \nTime Sent: ${time}', textAlign: TextAlign.left,);
              } else {
                return Container();
              }

            } else {
              return Container();
            }
          }
        ),
      ),
    );
  }
}