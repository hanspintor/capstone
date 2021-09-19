import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:proxpress/classes/firestore_search.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:proxpress/Load/user_load.dart';
import 'package:proxpress/classes/customer_classes/courier_tile.dart';
import 'package:proxpress/classes/message_tile.dart';
import 'package:proxpress/models/couriers.dart';
import 'package:proxpress/models/messages.dart';
import 'package:proxpress/services/database.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class MessageList extends StatefulWidget {
  @override
  _MessageListState createState() => _MessageListState();
}

class _MessageListState extends State<MessageList> {
  @override
  Widget build(BuildContext context) {
    final message = Provider.of<List<Message>>(context);

    if(message.length != 0){
      return message == null ? UserLoading() : ListView.builder(
        shrinkWrap: true,
        itemCount: message.length,
        itemBuilder: (context, index) {
          return MessageTile(message: message[index]);
        },
      );
    } else {
      return Row(
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Text(
                'No message has been sent yet.',
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
