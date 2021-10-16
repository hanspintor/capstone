import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:proxpress/Load/user_load.dart';
import 'package:proxpress/classes/customer_classes/pin_widget.dart';
import 'package:proxpress/classes/verify.dart';
import 'package:proxpress/services/database.dart';
import 'package:proxpress/models/customers.dart';

class DashboardLocation extends StatefulWidget{
  @override
  _DashboardLocationState createState() => _DashboardLocationState();
}

class _DashboardLocationState extends State<DashboardLocation>{
  final bool notBookmarks = false;
  int duration = 60;
  int flag = 0;
  final textFieldPickup = TextEditingController();
  final textFieldDropOff = TextEditingController();

  final GlobalKey<FormState> locKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    final auth = FirebaseAuth.instance;
    User user = auth.currentUser;

    return  StreamBuilder<Customer>(
      stream: DatabaseService(uid: user.uid).customerData,
      builder: (context, snapshot) {
        if(snapshot.hasData){
          Customer customerData = snapshot.data;

          return SingleChildScrollView(
            child: Column(
                children: [
                  SizedBox(height: 10),
                  Align(
                    alignment: Alignment.bottomCenter,
                    child: Text("Welcome, ${customerData.fName}!",
                      style: TextStyle(
                        fontSize: 25,
                      ),
                    ),
                  ),
                  !user.emailVerified ? Container(
                    margin: EdgeInsets.all(20),
                    child: Column(
                      children: [
                        Container(
                          decoration: BoxDecoration(
                              border: Border.all(color: Colors.black)
                          ),
                          child: ListTile(
                            leading: Icon(
                              Icons.info,
                              color: Colors.red,
                            ),
                            title: Text(
                              "Kindly verify your email ${user.email} to use the app.",
                              style: TextStyle(
                                fontSize: 15,
                                fontStyle: FontStyle.italic,
                                fontWeight: FontWeight.bold
                              ),
                            ),

                          ),
                        ),
                        //verifyCond(),
                        VerifyEmail()
                      ],
                    ),
                  )
                      : SingleChildScrollView(
                    child: Center(
                      child: Column(
                        children: [
                          PinLocation(
                            locKey: locKey,
                            textFieldPickup: textFieldPickup,
                            textFieldDropOff: textFieldDropOff,
                            isBookmarks: false,
                          )
                        ],
                      ),
                    ),
                  ),
                ],
              ),
          );
        } else {
          return UserLoading();
        }
      }
    );
  }
}





