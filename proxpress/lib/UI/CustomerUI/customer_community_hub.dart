import 'package:flutter/material.dart';
import 'package:proxpress/UI/login_screen.dart';
import 'package:proxpress/classes/community_list.dart';
import 'package:proxpress/models/community.dart';
import 'package:proxpress/models/user.dart';
import 'package:provider/provider.dart';
import 'package:proxpress/services/database.dart';

class CustomerCommunityHub extends StatefulWidget {
  @override
  _CustomerCommunityHubState createState() => _CustomerCommunityHubState();
}

class _CustomerCommunityHubState extends State<CustomerCommunityHub> {
  @override
  Widget build(BuildContext context) {
    final user = Provider.of<TheUser>(context);

    return user == null ? LoginScreen() : StreamProvider<List<Community>>.value(
      value: DatabaseService().communityDataList,
      initialData: [],
      child: SingleChildScrollView(
        child: Center(
          child: Column(
            children: [
              SizedBox(height: 10),
              CommunityList(isCustomer: true,),
            ],
          ),
        ),
      ),
    );
  }
}