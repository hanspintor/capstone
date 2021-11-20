import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:page_transition/page_transition.dart';
import 'package:proxpress/classes/community_post.dart';
import 'package:proxpress/UI/login_screen.dart';
import 'package:proxpress/models/community.dart';
import 'package:proxpress/models/couriers.dart';
import 'package:proxpress/models/customers.dart';
import 'package:proxpress/services/database.dart';
import 'package:intl/intl.dart';

class CommunityTile extends StatefulWidget {
  final Community community;
  final bool isCustomer;

  CommunityTile({
    Key key,
    @required this.community,
    @required this.isCustomer,
  }) : super(key: key);

  @override
  State<CommunityTile> createState() => _CommunityTileState();
}

class _CommunityTileState extends State<CommunityTile> {
  String uid;

  @override
  Widget build(BuildContext context) {
    uid = widget.community.uid;

    final FirebaseAuth _auth = FirebaseAuth.instance;
    User user = _auth.currentUser;

    return user == null ? LoginScreen() : StreamBuilder<Community>(
      stream: DatabaseService(uid: uid).communityData,
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
                    padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 5),
                    child: Card(
                      child: InkWell(
                        onTap: (){
                          Navigator.push(context, PageTransition(
                              child: CommunityPost(community: widget.community, isCustomer: widget.isCustomer),
                              type: PageTransitionType.bottomToTop
                          ));
                        },
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
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: ListTile(
                                title: Text("${widget.community.title}", style: TextStyle(fontWeight: FontWeight.bold),),
                                subtitle: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Text("${widget.community.content}"),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                } else return Container();
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
                      child: InkWell(
                        onTap: () {
                          Navigator.push(context, PageTransition(
                              child: CommunityPost(community: widget.community, isCustomer: widget.isCustomer,),
                              type: PageTransitionType.bottomToTop
                          ));
                        },
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
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: ListTile(
                                title: Text("${widget.community.title}", style: TextStyle(fontWeight: FontWeight.bold),),
                                subtitle: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Text("${widget.community.content}"),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                } else return Container();
              }
            );
          }
          return Container();
        } else {
          return Container();
        }
      },
    );
  }
}