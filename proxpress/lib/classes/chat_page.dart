import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/scheduler.dart';
import 'package:provider/provider.dart';
import 'package:proxpress/classes/message_list.dart';
import 'package:proxpress/models/couriers.dart';
import 'package:proxpress/models/customers.dart';
import 'package:proxpress/models/deliveries.dart';
import 'package:proxpress/models/messages.dart';
import 'package:proxpress/models/user.dart';
import 'package:proxpress/services/database.dart';
import 'package:rxdart/rxdart.dart';

class ChatPage extends StatefulWidget {
  final Delivery delivery;

  ChatPage({
    Key key,
    @required this.delivery,
  }) : super(key: key);

  @override
  _ChatPageState createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final _controller = TextEditingController();
  String message = '';
  bool isCustomer = false;
  ScrollController _scrollController = new ScrollController();
  Widget _buildMessageTextField() {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.transparent,
            width: 3
        ),
      ),
      padding: EdgeInsets.all(4),
      child: TextField(
        onTap: () {
          SchedulerBinding.instance.addPostFrameCallback((_) {
            _scrollController.animateTo(
              _scrollController.position.maxScrollExtent,
              duration: const Duration(milliseconds: 1000),
              curve: Curves.easeOut,);
          });
        },
        controller: _controller,
        textCapitalization: TextCapitalization.sentences,
        autocorrect: true,
        enableSuggestions: true,
        decoration: InputDecoration(
          filled: true,
          hintText: 'Type your message',
          suffixIcon: IconButton(
            icon: Icon(Icons.send, color: Colors.red),
            onPressed: _controller.text == '' ? null : () async {
                if (isCustomer) {
                  await DatabaseService().createMessageData(message, Timestamp.now(), widget.delivery.customerRef, widget.delivery.courierRef);
                } else {
                  await DatabaseService().createMessageData(message, Timestamp.now(), widget.delivery.courierRef, widget.delivery.customerRef);
                }
                _scrollController.animateTo(_scrollController.position.maxScrollExtent, duration: Duration(milliseconds: 300), curve: Curves.easeOut);
                setState(() {
                  _controller.clear();
                });
            },
          ),
          border: OutlineInputBorder(
            //borderSide: BorderSide(width: 0),
            gapPadding: 10,
            borderRadius: BorderRadius.circular(30),
          ),
        ),
        onChanged: (value) => setState(() {
          message = value;
        }),
      )
    );
  }

  @override
  Widget build(BuildContext context) {
    final FirebaseAuth _auth = FirebaseAuth.instance;
    User user = _auth.currentUser;

    if (widget.delivery.customerRef.id == user.uid) {
      setState((){
        isCustomer = true;
      });
    }

    print("isCustomer?? $isCustomer");

    DocumentReference customer = FirebaseFirestore.instance.collection('Customers').doc(widget.delivery.customerRef.id);
    DocumentReference courier = FirebaseFirestore.instance.collection('Couriers').doc(widget.delivery.courierRef.id);


    //ScrollDown();
    Stream<List<Message>> messageListCustomerToCour = FirebaseFirestore.instance
        .collection('Messages')
        .where('Sent By', isEqualTo: customer)
        .where('Sent To', isEqualTo: courier)
        //.orderBy('Time Sent', descending: false)
        .snapshots()
        .map(DatabaseService().messageDataListFromSnapshot);

    Stream<List<Message>> messageListCourToCustomer = FirebaseFirestore.instance
        .collection('Messages')
        .where('Sent By', isEqualTo: courier)
        .where('Sent To', isEqualTo: customer)
        //.orderBy('Time Sent', descending: false)
        .snapshots()
        .map(DatabaseService().messageDataListFromSnapshot);


    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        iconTheme: IconThemeData(color: Color(0xfffb0d0d),),
        title: isCustomer ? StreamBuilder<Courier>(
            stream: DatabaseService(uid: widget.delivery.courierRef.id).courierData,
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                Courier courier = snapshot.data;

                return Wrap(
                  spacing: 10,
                  children: [
                    CircleAvatar(
                      radius: 15,
                      backgroundImage: NetworkImage(courier.avatarUrl),
                      backgroundColor: Colors.white,
                    ),
                    Text(
                      "${courier.fName} ${courier.lName}",
                      style: TextStyle(
                          fontSize: 25,
                          fontWeight: FontWeight.bold,
                          color: Colors.black
                      ),
                    ),
                  ],
                );
              } else {
                return Text('Loading');
              }
            }
        ) : StreamBuilder<Customer>(
            stream: DatabaseService(uid: widget.delivery.customerRef.id).customerData,
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                Customer customer = snapshot.data;

                return Wrap(
                  spacing: 10,
                  children: [
                    CircleAvatar(
                      radius: 15,
                      backgroundImage: NetworkImage(customer.avatarUrl),
                      backgroundColor: Colors.white,
                    ),
                    Text(
                      "${customer.fName} ${customer.lName}",
                      style: TextStyle(
                          fontSize: 25,
                          fontWeight: FontWeight.bold,
                          color: Colors.black
                      ),

                    ),
                  ],
                );
              } else {
                return Text('Loading');
              }
            }
        ),
        actions: [
          IconButton(icon: Icon(
            Icons.help_outline,
          ),
            onPressed: (){

              showDialog(
                  context: context,
                  builder: (BuildContext context){
                    return AlertDialog(
                      title: Text("Help"),
                      content: Text('nice'),
                      actions: [
                        TextButton(
                          child: Text("OK"),
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                        ),
                      ],
                    );
                  }
              );
            },
            iconSize: 25,
          ),
        ],
        //title: Text("PROExpress"),
      ),
      body: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Container(
              height: MediaQuery.of(context).size.height - MediaQuery.of(context).size.height * .25,
              color: Colors.white70,
              child:
              // StreamProvider<List<Message>>.value(
              //   value: messageListCustomerToCour,
              //   initialData: [],
              //   child: MessageList(),
              // ),
              StreamBuilder(
                stream: CombineLatestStream.list([
                  messageListCustomerToCour,
                  messageListCourToCustomer,
                ]),
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    List<List<Message>> twoMessageLists = snapshot.data;

                    List<Message> mergedMessageList = twoMessageLists[0] + twoMessageLists[1];

                    mergedMessageList.sort((a, b) => a.timeSent.compareTo(b.timeSent));

                    return Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        MessageList(messageList: mergedMessageList, isCustomer: isCustomer, scrollController: _scrollController),
                      ],
                    );
                  } else {
                    return Text('');
                  }
                }
              ),
            ),
            _buildMessageTextField(),
          ]
        ),
      ),
    );
  }
}