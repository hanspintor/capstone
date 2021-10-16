import 'dart:async';
import 'dart:io';
import 'package:path/path.dart' as path;
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
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
import 'package:proxpress/services/database.dart';
import 'package:proxpress/services/upload_file.dart';

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
  bool picture = true;
  File profilePicture;
  bool uploadedNewPic = false;
  String savedUrl = '';
  String saveDestination = '';
  String fetchedUrl;
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
            suffixIcon: _controller.text != '' ? IconButton(
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
            ) : Container(
              width: 100,
              child: Row(
                children: [
                  IconButton(
                    iconSize: 25,
                    icon: Icon(
                      Icons.insert_photo,
                    ),
                    onPressed:  () async {
                      print("picture here..");

                      CollectionReference messageCollection = FirebaseFirestore.instance.collection('Messages');



                      String datetime = DateTime.now().toString();
                      final result = await FilePicker.platform.pickFiles(allowMultiple: false);
                      final pathProfiePicUploaded = result.files.single.path;
                      setState(() {
                        profilePicture = File(pathProfiePicUploaded);
                      });

                      String MessageUid = "";


                      if (profilePicture != null) {
                        if (isCustomer) {
                          await DatabaseService().createMessageData("Sent a photo", Timestamp.now(), widget.delivery.customerRef, widget.delivery.courierRef);
                        } else {
                          await DatabaseService().createMessageData("Sent a photo", Timestamp.now(), widget.delivery.courierRef, widget.delivery.customerRef);
                        }
                        _scrollController.animateTo(_scrollController.position.maxScrollExtent, duration: Duration(milliseconds: 300), curve: Curves.easeOut);

                        await messageCollection.orderBy("Time Sent", descending: true).limit(1).get().then((value){
                           MessageUid = value.docs.first.id;
                         });

                         final profilePictureDestination = 'Messages/${MessageUid}/profilepic_${MessageUid}_$datetime';

                         print(path.basename(profilePicture.path));
                        await UploadFile.uploadFile(profilePictureDestination, profilePicture);

                        savedUrl = await firebase_storage.FirebaseStorage.instance
                            .ref(profilePictureDestination)
                            .getDownloadURL();



                        if (savedUrl != null || savedUrl == 'null') {
                            print(savedUrl);
                           await DatabaseService(uid: MessageUid).updateMessage(savedUrl);
                        }

                        setState(() {
                          fetchedUrl = savedUrl;
                        });
                      }

                    },
                  ),

                  IconButton(
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

                ],
              ),
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
    Stream<CustomerToCour> messageListCustomerToCour = FirebaseFirestore.instance
        .collection('Messages')
        .where('Sent By', isEqualTo: customer)
        .where('Sent To', isEqualTo: courier)
    //.orderBy('Time Sent', descending: false)
        .snapshots()
        .map(DatabaseService().messageDataListFromSnapshot3);

    Stream<CourToCustomer> messageListCourToCustomer = FirebaseFirestore.instance
        .collection('Messages')
        .where('Sent By', isEqualTo: courier)
        .where('Sent To', isEqualTo: customer)
    //.orderBy('Time Sent', descending: false)
        .snapshots()
        .map(DatabaseService().messageDataListFromSnapshot2);

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
                child: MultiProvider(
                  providers: [
                    StreamProvider<CourToCustomer>.value(initialData: CourToCustomer(), value: messageListCourToCustomer),
                    StreamProvider<CustomerToCour>.value(initialData: CustomerToCour(), value: messageListCustomerToCour),
                  ],
                  child: MessageListCombiner(isCustomer: isCustomer, scrollController: _scrollController),
                ),
              ),
              _buildMessageTextField(),
            ]
        ),
      ),
    );
  }
}

class MessageListCombiner extends StatelessWidget {
  final bool isCustomer;
  final ScrollController scrollController;

  const MessageListCombiner({
    Key key,
    @required this.isCustomer,
    @required this.scrollController,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final customerToCour = Provider.of<CustomerToCour>(context);
    final courToCustomer = Provider.of<CourToCustomer>(context);

    List<Message> mergedMessageList = [];

    if (customerToCour.value != null && courToCustomer.value != null)
      mergedMessageList = courToCustomer.value + customerToCour.value;

    mergedMessageList.sort((a, b) => a.timeSent.compareTo(b.timeSent));

    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        MessageList(messageList: mergedMessageList, isCustomer: isCustomer, scrollController: scrollController),
      ],
    );
  }
}