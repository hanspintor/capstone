import 'package:flutter/material.dart';
import 'package:proxpress/Load/user_load.dart';
import 'package:proxpress/classes/message_tile.dart';
import 'package:proxpress/models/messages.dart';

class MessageList extends StatefulWidget {
  final List<Message> messageList;
  final bool isCustomer;
  final ScrollController scrollController;

  const MessageList({
    Key key,
    @required this.messageList,
    @required this.isCustomer,
    @required this.scrollController,
  }) : super(key: key);

  @override
  _MessageListState createState() => _MessageListState();
}

class _MessageListState extends State<MessageList> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.messageList.length != 0) {
      return widget.messageList == null ? UserLoading() : Flexible(
        child: ListView.builder(
          shrinkWrap: true,
          controller: widget.scrollController,
          itemCount: widget.messageList.length,
          itemBuilder: (context, index) {
            return MessageTile(message: widget.messageList[index], isCustomer: widget.isCustomer);
          },
        ),
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