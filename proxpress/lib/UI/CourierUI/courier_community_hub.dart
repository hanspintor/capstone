import 'package:flutter/material.dart';
import 'package:proxpress/models/user.dart';
import 'package:provider/provider.dart';

class CourierCommunityHub extends StatefulWidget {
  @override
  _CourierCommunityHubState createState() => _CourierCommunityHubState();
}

class _CourierCommunityHubState extends State<CourierCommunityHub> {

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<TheUser>(context);

    return Container();
  }
}
