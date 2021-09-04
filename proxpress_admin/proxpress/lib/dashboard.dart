import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:proxpress/courier_list.dart';
import 'package:proxpress/couriers.dart';
import 'package:proxpress/database.dart';
import 'package:proxpress/login_screen.dart';

import 'auth.dart';

class Dashboard extends StatefulWidget {
  String savedPassword;
  Dashboard({this.savedPassword});

  @override
  _DashboardState createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  String savedPassword;
  _DashboardState({this.savedPassword});

  final AuthService _auth = AuthService();

  @override
  Widget build(BuildContext context) {
    final FirebaseAuth auth = FirebaseAuth.instance;
    final User user = auth.currentUser;

    return StreamProvider<List<Courier>>.value(
      value: DatabaseService().courierList,
      initialData: null,
      child: Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          backgroundColor: Colors.black,
          title: Text("PROExpress Admin"),
          actions: [
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                primary: Colors.black,
              ),
              onPressed: () async {
                print(user.uid);
                if (user != null) {
                  await _auth.signOut();
                }
                Navigator.push(context, MaterialPageRoute(builder: (context) => LoginScreen()));
              },
              icon: Icon(Icons.logout_rounded),
              label: Text('Logout')),
          ],
        ),
        body: SingleChildScrollView(
          child: Column(
            children: [
              Container(
                margin: EdgeInsets.fromLTRB(10, 10, 10, 0),
                child: Table(
                  border: TableBorder.all(),
                  children: [
                    TableRow(
                      children: [
                        Align(alignment: Alignment.center,child: Text('Name', style: TextStyle(fontWeight: FontWeight.bold),)),
                        Align(alignment: Alignment.center,child: Text('Address', style: TextStyle(fontWeight: FontWeight.bold),)),
                        Align(alignment: Alignment.center,child: Text('Email', style: TextStyle(fontWeight: FontWeight.bold),)),
                        Align(alignment: Alignment.center,child: Text('Contact Number', style: TextStyle(fontWeight: FontWeight.bold),)),
                        Align(alignment: Alignment.center,child: Text('Vehicle Type', style: TextStyle(fontWeight: FontWeight.bold),)),
                        Align(alignment: Alignment.center,child: Text('Vehicle Color', style: TextStyle(fontWeight: FontWeight.bold),)),
                        Align(alignment: Alignment.center,child: Text('Credentials', style: TextStyle(fontWeight: FontWeight.bold),)),
                        Align(alignment: Alignment.center,child: Text('Commands', style: TextStyle(fontWeight: FontWeight.bold),)),
                      ],
                    ),
                  ],
                ),
              ),
              CourierList(savedPassword: widget.savedPassword,),
            ],
          ),
        ),
      ),
    );
  }
}
