import 'package:chat_bubbles/chat_bubbles.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:page_transition/page_transition.dart';
import 'package:proxpress/UI/login_screen.dart';
import 'package:proxpress/classes/hero_page.dart';
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
          if (snapshot.hasData) {
            Message message = snapshot.data;
            String time = DateFormat.jm().format(message.timeSent.toDate());
            bool _validURL = Uri.parse(message.messageContent).isAbsolute;
          if (widget.isCustomer) {
            if (message.sentBy.toString().contains('Customers')) {

              return Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  !_validURL ? BubbleNormal(
                    color: Colors.red,
                    textStyle: TextStyle(color: Colors.white),
                    isSender: true,
                    text: '${message.messageContent}',
                  ) : GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        PageTransition(child: HeroPage(url: message.messageContent,), type: PageTransitionType.fade),
                      );
                    },
                    child: Hero(
                      tag: message.uid,
                      child: Image.network(
                        message.messageContent,
                        width: 200,

                      ),
                    ),
                  ),
                  Text("$time", style: TextStyle(fontSize: 10))
                ],
              );
            } else if (message.sentBy.toString().contains('Couriers')) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  !_validURL ? BubbleNormal(
                    color: Colors.black26,
                    textStyle: TextStyle(color: Colors.black),
                    isSender: false,
                    text: '${message.messageContent}',
                  ) : GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        PageTransition(child: HeroPage(url: message.messageContent,), type: PageTransitionType.fade),
                      );
                    },
                    child: Hero(
                      tag: message.uid,
                      child: Image.network(
                        message.messageContent,
                        width: 200,
                      ),
                    ),
                  ),
                  Text("$time", style: TextStyle(fontSize: 10))
                ],
              );
            } else {
              return Container();
            }
          } else {
            if (message.sentBy.toString().contains('Couriers')) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  !_validURL ? BubbleNormal(
                    color: Colors.red,
                    textStyle: TextStyle(color: Colors.white),
                    isSender: true,
                    text: '${message.messageContent}',
                  ) : Hero(
                    tag: message.uid,
                    child: Image.network(
                      message.messageContent,
                      width: 200,
                      height: 200,
                    ),
                  ),
                  Text("$time", style: TextStyle(fontSize: 10)),
                ],
              );
            } else if (message.sentBy.toString().contains('Customers')) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  !_validURL ? BubbleNormal(
                    color: Colors.black26,
                    textStyle: TextStyle(color: Colors.black),
                    isSender: false,
                    text: '${message.messageContent}',
                  ) : Hero(
                    tag: message.uid,
                    child: Image.network(
                      message.messageContent,
                      width: 200,
                      height: 200,
                    ),
                  ),
                  Text("$time", style: TextStyle(fontSize: 10),),
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