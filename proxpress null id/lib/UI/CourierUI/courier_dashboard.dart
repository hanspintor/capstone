import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:proxpress/classes/user_identifier.dart';
import 'package:proxpress/models/user.dart';
import 'package:proxpress/services/auth.dart';


class CourierDashboard extends StatelessWidget {
  final AuthService _auth = AuthService();

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<TheUser>(context);
    if(user != null){
      return  ElevatedButton.icon(
        icon: Icon(Icons.logout_rounded),
        label: Text('Logout'),
        onPressed: () async{
          await _auth.signOut();

        },
        style: ElevatedButton.styleFrom(primary: Color(0xfffb0d0d), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(0)),),
      );
    }
     else {
      return UserIdentifier();
    }
  }

}
