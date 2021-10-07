import 'package:flutter/material.dart';
import 'package:proxpress/models/user.dart';
import 'package:provider/provider.dart';

class CustomerCommunityHub extends StatefulWidget {
  @override
  _CustomerCommunityHubState createState() => _CustomerCommunityHubState();
}

class _CustomerCommunityHubState extends State<CustomerCommunityHub> {

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<TheUser>(context);

    return Center(
      child: Column(
        children: [
        ],
      ),
    );
  }
}
