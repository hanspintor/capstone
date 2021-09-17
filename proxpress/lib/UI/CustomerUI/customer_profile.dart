import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:proxpress/Load/user_load.dart';
import 'package:proxpress/UI/CustomerUI/menu_drawer_customer.dart';
import 'package:proxpress/UI/login_screen.dart';
import 'package:proxpress/services/auth.dart';
import 'package:proxpress/services/default_profile_pic.dart';
import 'notif_drawer_customer.dart';
import 'package:proxpress/services/database.dart';
import 'package:proxpress/models/user.dart';
import 'package:provider/provider.dart';
import 'package:proxpress/models/customers.dart';

class CustomerProfile extends StatefulWidget {

  @override
  _CustomerProfileState createState() => _CustomerProfileState();
}
class _CustomerProfileState extends State<CustomerProfile> {

  void _openEndDrawer() {
    _scaffoldKey.currentState.openEndDrawer();
  }

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final AuthService _auth = AuthService();
  static Timer _sessionTimer;
  static Timer _sessionTimerPrint;
  int count = 0;
  int duration = 1;
  void handleTimeOut() async{
    await _auth.signOut();
  }
  @override
  Widget build(BuildContext context) {
    final user = Provider.of<TheUser>(context);

      return new GestureDetector(
        onTap: (){
          if(count != 0){
            print("Session Revived");
          } else {
            print("Session Started");
            count=1;
          }
          _sessionTimer?.cancel();
          _sessionTimer = new Timer(Duration(minutes: duration), handleTimeOut);
          _sessionTimerPrint?.cancel();
          _sessionTimerPrint = new Timer(Duration(minutes: duration), () {
            print("Session Expired");
          });

        },
        child: user == null ? LoginScreen() : Scaffold(
            drawerEnableOpenDragGesture: false,
            endDrawerEnableOpenDragGesture: false,
            key:_scaffoldKey,
            appBar: AppBar(
              backgroundColor: Colors.white,
              iconTheme: IconThemeData(color: Color(0xfffb0d0d),),
              actions: [
                IconButton(icon: Icon(
                  Icons.notifications_none_rounded,
                ),
                  onPressed: (){
                    _openEndDrawer();
                  },
                  iconSize: 25,
                ),
              ],
              flexibleSpace: Container(
                margin: EdgeInsets.only(top: 10),
                child: Image.asset(
                  "assets/PROExpress-logo.png",
                  height: 120,
                  width: 120,
                ),
              ),
              //title: Text("PROExpress"),
            ),
            drawer: MainDrawerCustomer(),
            endDrawer: NotifDrawerCustomer(),
            body: SingleChildScrollView(
              child: StreamBuilder<Customer>(
                  stream: DatabaseService(uid: user.uid).customerData,
                  builder: (context,snapshot){
                    if(snapshot.hasData){
                      Customer customerData = snapshot.data;
                      return Center(
                        child: Container(
                          width: 350,
                          child: Card(
                            margin: EdgeInsets.fromLTRB(0, 100, 0, 0),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Container(
                                  child: CircleAvatar(
                                    radius: 80,
                                    backgroundImage: NetworkImage(customerData.avatarUrl),
                                    backgroundColor: Colors.white,
                                  ),
                                ),
                                ListTile(
                                  title: Text(
                                    '${customerData.fName} ${customerData.lName}',
                                    style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
                                  ),
                                  subtitle: Container(
                                    padding: EdgeInsets.only(top: 5, left: 2),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.end,
                                      children: [
                                        Row(
                                          children: [
                                            Container(padding:  EdgeInsets.only(right: 5), child: Icon(Icons.home_rounded, size: 20,)),
                                            Text(customerData.address, style: TextStyle(fontSize: 15)),
                                          ],
                                        ),
                                        Row(
                                          children: [
                                            Container(padding:  EdgeInsets.only(right: 5), child: Icon(Icons.alternate_email_rounded, size: 20,)),
                                            Text(customerData.email, style: TextStyle(fontSize: 15)),
                                          ],
                                        ),
                                        Row(
                                          children: [
                                            Container(padding:  EdgeInsets.only(right: 5), child: Icon(Icons.phone_rounded, size: 20,)),
                                            Text(customerData.contactNo, style: TextStyle(fontSize: 15)),
                                          ],
                                        ),
                                        Container(
                                          margin: EdgeInsets.fromLTRB(0, 20, 0, 10),
                                          width: 125,
                                          child: ElevatedButton.icon(
                                            icon: Icon(Icons.edit_rounded, size: 15),
                                            label: Text('Edit Profile', style: TextStyle(fontSize: 15),),
                                            style : ElevatedButton.styleFrom(primary: Color(0xfffb0d0d)),
                                            onPressed: (){
                                              Navigator.pushNamed(context, '/customerUpdate');
                                            },
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                )
                              ],
                            ),
                          ),
                        ),
                      );
                    }
                    else{
                      return UserLoading();
                    }
                  }
              ),

            )
        ),
      );
  }
}