import 'package:flutter/material.dart';
import 'package:proxpress/UI/CourierUI/menu_drawer_courier.dart';
import 'package:proxpress/UI/CourierUI/notif_drawer_courier.dart';
import 'package:proxpress/classes/courier_list.dart';
import 'package:proxpress/models/couriers.dart';
import 'package:proxpress/Load/user_load.dart';
import 'package:proxpress/UI/login_screen.dart';
import 'package:proxpress/services/database.dart';
import 'package:proxpress/models/user.dart';
import 'package:provider/provider.dart';


class CourierDashboard extends StatelessWidget {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  void _openEndDrawer() {
    _scaffoldKey.currentState.openEndDrawer();
  }

  Widget _welcomeMessage(){
    String welcomeMessage = "Thank you for registering in PROXpress. "
        "Please wait for up to 24 hours for the admin to check and verify your uploaded credentials. "
        "This is to ensure that you are qualified to be a courier in our app.";

    return Container(
      margin: EdgeInsets.fromLTRB(20, 40, 20, 0),
      child: Align(
        child: Text(welcomeMessage,
          textAlign: TextAlign.justify,
          style: TextStyle(
            fontSize: 20,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<TheUser>(context);
    bool approved = false;

    if(user != null) {
      return StreamBuilder<Courier>(
          stream: DatabaseService(uid: user.uid).courierData,
          builder: (context,snapshot){
            if(snapshot.hasData){
              Courier courierData = snapshot.data;

              approved = courierData.approved;

              return WillPopScope(
                onWillPop: () async {
                  print("Back Button Pressed");
                  return false;
                },
                child: Scaffold(
                  drawerEnableOpenDragGesture: false,
                  endDrawerEnableOpenDragGesture: false,
                  key: _scaffoldKey,
                  appBar: AppBar(
                    backgroundColor: Colors.white,
                    iconTheme: IconThemeData(color: Color(0xfffb0d0d)
                    ),
                    actions:[
                      IconButton(
                        icon: Icon(Icons.notifications_none_rounded),
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
                  ),
                  drawer: MainDrawerCourier(),
                  endDrawer: NotifDrawerCourier(),
                  body: SingleChildScrollView(
                    child: Center(
                      child: Column(
                        children: [
                          SizedBox(height: 10),
                          Align(
                            alignment: Alignment.bottomCenter,
                            child: Text("Welcome, ${courierData.fName}!",
                              style: TextStyle(
                                fontSize: 25,
                              ),
                            ),
                          ),
                          !approved ? _welcomeMessage() : Container(
                            child: Text('Customer Requests Here'),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            }
            else return UserLoading();
          }
      );
    }
    else return LoginScreen();
  }
}
