import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:proxpress/classes/message_list.dart';
import 'package:proxpress/models/couriers.dart';
import 'package:proxpress/models/deliveries.dart';
import 'package:proxpress/models/messages.dart';
import 'package:proxpress/models/user.dart';
import 'package:proxpress/services/database.dart';
import 'package:rxdart/rxdart.dart';

class CustomerChat extends StatefulWidget {
  final Delivery delivery;

  CustomerChat({
    Key key,
    @required this.delivery,
  }) : super(key: key);

  @override
  _CustomerChatState createState() => _CustomerChatState();
}

class _CustomerChatState extends State<CustomerChat> {
  final _controller = TextEditingController();
  String message = '';

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
                await DatabaseService().createMessageData(message, Timestamp.now(), widget.delivery.customerRef, widget.delivery.courierRef);
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
    DocumentReference customer = FirebaseFirestore.instance.collection('Customers').doc(widget.delivery.customerRef.id);
    DocumentReference courier = FirebaseFirestore.instance.collection('Couriers').doc(widget.delivery.courierRef.id);

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
        child: Column(
          children: [
            Container(
              decoration: BoxDecoration(border: Border.all(), color: Colors.red),
              child: StreamBuilder<Courier>(
                  stream: DatabaseService(uid: widget.delivery.courierRef.id).courierData,
                  builder: (context, snapshot) {
                    if (snapshot.hasData) {
                      Courier courier = snapshot.data;

                      return Text("${courier.fName} ${courier.lName}");
                    } else {
                      return Text('Loading');
                    }
                  }
              ),
            ),
            Container(
              height: 500,
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

                    return MessageList(messageList: mergedMessageList);
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