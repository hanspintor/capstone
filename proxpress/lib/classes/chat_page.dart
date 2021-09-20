import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
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
    return Align(
      alignment: Alignment.bottomCenter,
      child: Container(
        padding: EdgeInsets.all(10),
        child: TextField(
          controller: _controller,
          textCapitalization: TextCapitalization.sentences,
          autocorrect: true,
          enableSuggestions: true,
          decoration: InputDecoration(
            filled: true,
            hintText: 'Type your message',
            suffixIcon: IconButton(
              icon: Icon(Icons.send),
              onPressed: () async {
                if (isCustomer) {
                  await DatabaseService().createMessageData(message, Timestamp.now(), widget.delivery.customerRef, widget.delivery.courierRef);
                } else {
                  await DatabaseService().createMessageData(message, Timestamp.now(), widget.delivery.courierRef, widget.delivery.customerRef);
                }
                _scrollController.animateTo(_scrollController.position.maxScrollExtent, duration: Duration(milliseconds: 300), curve: Curves.easeOut);
                setState((){
                  _controller.text = '';
                });
              },
            ),
            border: OutlineInputBorder(
              borderSide: BorderSide(width: 0),
              gapPadding: 10,
              borderRadius: BorderRadius.circular(25),
            ),
          ),
          onChanged: (value) => setState(() {
            message = value;
          }),
        )
      ),
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
        flexibleSpace: Container(
          margin: EdgeInsets.only(top: 10),
          child: Image.asset(
            "assets/PROExpress-logo.png",
            height: 120,
            width: 120,
          ),
        ),
        //title: Text("PROExpress"),
      ),
      body: SingleChildScrollView(
        physics: BouncingScrollPhysics(),
        child: Column(
          children: [
            Container(
              decoration: BoxDecoration(border: Border.all(), color: Colors.red),
              child: isCustomer ? StreamBuilder<Courier>(
                  stream: DatabaseService(uid: widget.delivery.courierRef.id).courierData,
                  builder: (context, snapshot) {
                    if (snapshot.hasData) {
                      Courier courier = snapshot.data;

                      return Text("${courier.fName} ${courier.lName}");
                    } else {
                      return Text('Loading');
                    }
                  }
              ) : StreamBuilder<Customer>(
                  stream: DatabaseService(uid: widget.delivery.customerRef.id).customerData,
                  builder: (context, snapshot) {
                    if (snapshot.hasData) {
                      Customer customer = snapshot.data;

                      return Text("${customer.fName} ${customer.lName}");
                    } else {
                      return Text('Loading');
                    }
                  }
              ),
            ),
            Container(
              height: MediaQuery.of(context).size.height - MediaQuery.of(context).size.height * .28,
              decoration: BoxDecoration(border: Border.all()),
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

                    return MessageList(messageList: mergedMessageList, isCustomer: isCustomer, scrollController: _scrollController);
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