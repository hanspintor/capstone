import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:proxpress/UI/login_screen.dart';
import 'package:proxpress/models/community.dart';
import 'package:proxpress/models/customers.dart';
import 'package:proxpress/models/deliveries.dart';
import 'package:proxpress/services/database.dart';

class CommunityTile extends StatefulWidget {
  final Community community;

  CommunityTile({
    Key key,
    @required this.community,
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
          return Container(
            child: Column(
              children: [
                Text("${widget.community.title}"),
                Text("${widget.community.content}"),
              ],
            ),
          );
        }
        else {
          return Container();
        }
      },
    );
  }
}