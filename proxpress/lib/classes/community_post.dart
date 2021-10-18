import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:proxpress/UI/login_screen.dart';
import 'package:proxpress/models/comments.dart';
import 'package:proxpress/models/community.dart';
import 'package:proxpress/models/couriers.dart';
import 'package:proxpress/models/customers.dart';
import 'package:proxpress/services/database.dart';
import 'package:intl/intl.dart';

class CommunityPost extends StatefulWidget {
  final Community community;
  final bool isCustomer;

  CommunityPost({
    Key key,
    @required this.community,
    @required this.isCustomer,
  }) : super(key: key);

  @override
  _CommunityPostState createState() => _CommunityPostState();
}

class _CommunityPostState extends State<CommunityPost> {
  final _controller = TextEditingController();
  String comment = '';

  Widget _buildCommentTextField(String uid) {
    DocumentReference commentBy;

    if (widget.isCustomer) {
      commentBy = FirebaseFirestore.instance.collection('Customers').doc(uid);
    } else {
      commentBy = FirebaseFirestore.instance.collection('Couriers').doc(uid);
    }

    return SizedBox(
      height: 70,
      child: Container(
          decoration: BoxDecoration(
            border: Border.all(color: Colors.transparent,
                width: 3
            ),
          ),
          padding: EdgeInsets.all(4),
          child: TextField(
            controller: _controller,
            textCapitalization: TextCapitalization.sentences,
            autocorrect: true,
            enableSuggestions: true,
            decoration: InputDecoration(
              filled: true,
              hintText: 'Type your comment',
              hintStyle: TextStyle(fontSize: 13),
              suffixIcon: IconButton(
                icon: Icon(Icons.send, color: Colors.red, size: 20,),
                onPressed: _controller.text == '' ? null : () async {
                  await DatabaseService(uid: widget.community.uid).createCommentData(comment, commentBy, Timestamp.now());
                  setState(() {
                    _controller.clear();
                  });
                },
              ),
              border: OutlineInputBorder(
                //borderSide: BorderSide(width: 0),
                gapPadding: 10,
              ),
            ),
            onChanged: (value) => setState(() {
              comment = value;
            }),
          )
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final FirebaseAuth _auth = FirebaseAuth.instance;
    User user = _auth.currentUser;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        iconTheme: IconThemeData(color: Colors.red),
      ),
      body: user == null ? LoginScreen() : SingleChildScrollView(
        child: Column(
          children: [
            StreamBuilder<Community>(
              stream: DatabaseService(uid: widget.community.uid).communityData,
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  String time = DateFormat.yMMMMd('en_US').format(widget.community.timeSent.toDate());

                  if (widget.community.sentBy.toString().contains('Customers')) {
                    return StreamBuilder<Customer>(
                        stream: DatabaseService(uid: widget.community.sentBy.id).customerData,
                        builder: (context, snapshot) {
                          if(snapshot.hasData){
                            Customer customer = snapshot.data;
                            return Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 20.0, vertical: 5),
                              child: Card(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    ListTile(
                                      title: Row(
                                        children: [
                                          Container(
                                            child: CircleAvatar(
                                              radius: 15,
                                              backgroundImage: NetworkImage(customer.avatarUrl),
                                              backgroundColor: Colors.white,
                                            ),
                                          ),
                                          Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Padding(
                                                padding: const EdgeInsets.symmetric(horizontal: 10),
                                                child: Text("${customer.fName} ${customer.lName}",style: TextStyle(fontWeight: FontWeight.bold),),
                                              ),
                                              Padding(
                                                padding: const EdgeInsets.symmetric(horizontal: 10),
                                                child: Text("${time}", style: TextStyle(color: Colors.grey, fontSize: 12),),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                    ListTile(
                                      title: ListTile(
                                        title: Text("${widget.community.title}", style: TextStyle(fontWeight: FontWeight.bold),),
                                        subtitle: Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: Text("${widget.community.content}"),
                                        ),),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          }
                          else return Container();
                        }
                    );
                  } else if (widget.community.sentBy.toString().contains('Couriers')) {
                    return StreamBuilder<Courier>(
                        stream: DatabaseService(uid: widget.community.sentBy.id).courierData,
                        builder: (context, snapshot) {
                          if(snapshot.hasData){
                            Courier courier = snapshot.data;
                            return Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 20.0, vertical: 5),
                              child: Card(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    ListTile(
                                      title: Row(
                                        children: [
                                          Container(
                                            child: CircleAvatar(
                                              radius: 15,
                                              backgroundImage: NetworkImage(courier.avatarUrl),
                                              backgroundColor: Colors.white,
                                            ),
                                          ),
                                          Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Padding(
                                                padding: const EdgeInsets.symmetric(horizontal: 10),
                                                child: Text("${courier.fName} ${courier.lName}",style: TextStyle(fontWeight: FontWeight.bold),),
                                              ),
                                              Padding(
                                                padding: const EdgeInsets.symmetric(horizontal: 10),
                                                child: Text("${time}", style: TextStyle(color: Colors.grey, fontSize: 12),),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                    ListTile(
                                      title: ListTile(
                                        title: Text("${widget.community.title}", style: TextStyle(fontWeight: FontWeight.bold),),
                                        subtitle: Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: Text("${widget.community.content}"),
                                        ),),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          }
                          else return Container();
                        }
                    );
                  }
                  return Container();
                }
                else {
                  return Container();
                }
              },
            ),
            StreamBuilder<List<Comment>>(
                stream: DatabaseService(uid: widget.community.uid).commentDataList,
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    List<Comment> comments = snapshot.data;

                    comments.sort((a, b) => a.timeSent.compareTo(b.timeSent));

                    return ListView.builder(
                      physics: NeverScrollableScrollPhysics(),
                      shrinkWrap: true,
                      itemCount: comments.length,
                      itemBuilder: (context, index) {
                        String time = DateFormat.jm().format(comments[index].timeSent.toDate());

                        if (comments[index].commentBy.toString().contains('Customers')) {
                          return StreamBuilder<Customer>(
                              stream: DatabaseService(uid: comments[index].commentBy.id).customerData,
                              builder: (context, snapshot) {
                                if (snapshot.hasData) {
                                  Customer customer = snapshot.data;

                                  return Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 20),
                                    child: Card(
                                      child: ListTile(
                                        title: Text('${customer.fName} ${customer.lName}'),
                                        subtitle: Text('${comments[index].comment}'),
                                        trailing: Text('${time}'),
                                      ),
                                    ),
                                  );
                                } else {
                                  return Container();
                                }
                              }
                          );
                        } else {
                          return StreamBuilder<Courier>(
                              stream: DatabaseService(uid: comments[index].commentBy.id).courierData,
                              builder: (context, snapshot) {
                                if (snapshot.hasData) {
                                  Courier courier = snapshot.data;

                                  return Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 20),
                                    child: Card(
                                      child: ListTile(
                                        title: Text('${courier.fName} ${courier.lName}'),
                                        subtitle: Text('${comments[index].comment}'),
                                        trailing: Text('${time}'),
                                      ),
                                    ),
                                  );
                                } else {
                                  return Container();
                                }
                              }
                          );
                        }
                      },
                    );
                  } else {
                    return Container();
                  }
                }
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 5),
              child: _buildCommentTextField(user.uid),
            ),
          ],
        ),
      ),
    );
  }
}
