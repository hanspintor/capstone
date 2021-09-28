import 'package:chat_bubbles/chat_bubbles.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:expansion_tile_card/expansion_tile_card.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
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
  final bool isCustomer;

  MessageTile({
    Key key,
    @required this.message,
    @required this.isCustomer,
  }) : super(key: key);

  @override
  State<MessageTile> createState() => _MessageTileState();
}

class _MessageTileState extends State<MessageTile> {
  @override
  Widget build(BuildContext context) {
    final FirebaseAuth _auth = FirebaseAuth.instance;
    User user = _auth.currentUser;

    return user == null ? LoginScreen() :  Padding(
      padding: const EdgeInsets.all(20),
      child: StreamBuilder<Message>(
        stream: DatabaseService(uid: widget.message.uid).messageData,
        builder: (context, snapshot) {
          if(snapshot.hasData){
            Message message = snapshot.data;
            String time = DateFormat.jm().format(message.timeSent.toDate());
            //print('Message: ${message.messageContent} \nSent By: ${message.sentBy.toString()} \nSent To: ${message.sentTo.toString()} \nTime Sent: ${message.timeSent.toDate()}');

          if (widget.isCustomer) {
            if (message.sentBy.toString().contains('Customers')) {
              return BubbleNormal(
                color: Colors.red,
                textStyle: TextStyle(color: Colors.white),
                isSender: true,
                text: '${message.messageContent} \n${time}',
              );
            } else if (message.sentBy.toString().contains('Couriers')) {
              return BubbleNormal(
                color: Colors.black26,
                textStyle: TextStyle(color: Colors.black),
                isSender: false,
                text: '${message.messageContent} \n${time}',
              );
            } else {
              return Container();
            }
          } else {
            if (message.sentBy.toString().contains('Couriers')) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  BubbleNormal(
                    color: Colors.red,
                    textStyle: TextStyle(color: Colors.white),
                    isSender: true,
                    text: '${message.messageContent}',
                  ),
                  Text("$time"),
                ],
              );
            } else if (message.sentBy.toString().contains('Customers')) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  BubbleNormal(
                    color: Colors.black26,
                    textStyle: TextStyle(color: Colors.black),
                    isSender: false,
                    text: '${message.messageContent}',
                  ),
                  Text("$time"),
                ],
              );
            } else {
              return Container();
            }
          }
        } else {
          return Container();
        }
      }
        ),
    );
  }
}