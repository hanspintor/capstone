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
  final List<Message> messageList;
  final bool isCustomer;

  const MessageList({
    Key key,
    @required this.messageList,
    @required this.isCustomer
  }) : super(key: key);

  @override
  _MessageListState createState() => _MessageListState();
}

class _MessageListState extends State<MessageList> {
  @override
  Widget build(BuildContext context) {
    print(widget.messageList.length);

    if(widget.messageList.length != 0){
      return widget.messageList == null ? UserLoading() : ListView.builder(
        shrinkWrap: true,
        itemCount: widget.messageList.length,
        itemBuilder: (context, index) {
          return MessageTile(message: widget.messageList[index], isCustomer: widget.isCustomer);
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
