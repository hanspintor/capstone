import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:proxpress/Load/user_load.dart';
import 'package:proxpress/classes/customer_classes/community_list.dart';
import 'package:proxpress/models/community.dart';
import 'package:proxpress/models/user.dart';
import 'package:provider/provider.dart';
import 'package:proxpress/services/database.dart';

class CourierCommunityHub extends StatefulWidget {
  @override
  _CourierCommunityHubState createState() => _CourierCommunityHubState();
}

class _CourierCommunityHubState extends State<CourierCommunityHub> {

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<TheUser>(context);

    return StreamBuilder<Community>(
        stream: DatabaseService(uid: user.uid).communityData,
        builder: (context,snapshot){
          if(snapshot.hasData){
            Community communityData = snapshot.data;
            Stream<List<Community>> communityList = FirebaseFirestore.instance
                .collection('Community')
                .snapshots()
                .map(DatabaseService().communityListFromSnapshot);

            return SingleChildScrollView(
              child: Center(
                child: Column(
                  children: [
                    SizedBox(height: 10),
                    Align(
                      alignment: Alignment.bottomCenter,
                      child: Text("Transaction History",
                        style: TextStyle(
                          fontSize: 25,
                        ),
                      ),
                    ),
                    CommunityList(),
                  ],
                ),
              ),
            );
          } else {
            return UserLoading();
          }
        }
    );
  }
}
