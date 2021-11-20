import 'package:flutter/material.dart';
import 'package:proxpress/UI/login_screen.dart';
import 'package:proxpress/classes/community_list.dart';
import 'package:proxpress/models/community.dart';
import 'package:proxpress/models/couriers.dart';
import 'package:proxpress/models/user.dart';
import 'package:provider/provider.dart';
import 'package:proxpress/services/database.dart';

class CourierCommunityHub extends StatefulWidget {
  @override
  _CourierCommunityHubState createState() => _CourierCommunityHubState();
}

class _CourierCommunityHubState extends State<CourierCommunityHub> {
  Widget _welcomeMessage(String adminMessage) {
    return Column(
      children: [
        Container(
          margin: EdgeInsets.fromLTRB(20, 40, 20, 0),
          child: Align(
            child: Text(adminMessage,
              textAlign: TextAlign.justify,
              style: TextStyle(
                fontSize: 20,
              ),
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<TheUser>(context);

    return user == null ? LoginScreen() : StreamBuilder<Courier>(
      stream: DatabaseService(uid: user.uid).courierData,
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          Courier courier = snapshot.data;

          return !courier.approved ? _welcomeMessage(courier.adminMessage) : StreamProvider<List<Community>>.value(
            value: DatabaseService().communityDataList,
            initialData: [],
            child: SingleChildScrollView(
              child: Center(
                child: Column(
                  children: [
                    SizedBox(height: 10),
                    CommunityList(isCustomer: false,),
                  ],
                ),
              ),
            ),
          );
        } else {
          return Container();
        }
      }
    );
  }
}