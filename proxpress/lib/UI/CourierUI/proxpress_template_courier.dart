import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:proxpress/UI/CourierUI/courier_community_hub.dart';
import 'package:proxpress/UI/CourierUI/courier_dashboard.dart';
import 'package:proxpress/UI/CourierUI/courier_profile.dart';
import 'package:proxpress/UI/CourierUI/menu_drawer_courier.dart';
import 'package:proxpress/UI/CourierUI/notif_drawer_courier.dart';
import 'package:proxpress/UI/CourierUI/transaction_history.dart';
import 'package:proxpress/classes/courier_classes/notif_counter_courier.dart';
import 'package:proxpress/models/couriers.dart';
import 'package:proxpress/Load/user_load.dart';
import 'package:proxpress/UI/login_screen.dart';
import 'package:proxpress/models/notifications.dart';
import 'package:proxpress/services/database.dart';
import 'package:proxpress/models/user.dart';
import 'package:provider/provider.dart';

class AppBarTemp1 extends StatefulWidget {
  final String currentPage;
  AppBarTemp1({this.currentPage});

  @override
  State<AppBarTemp1> createState() => _AppBarTemp1State();
}

class _AppBarTemp1State extends State<AppBarTemp1> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  String currentPage = "Dashboard";
  bool actionButton = false;
  // void _openEndDrawer() {
  //   _scaffoldKey.currentState.openEndDrawer();
  // }

  pagePicker(){
    if(widget.currentPage != null) {
      currentPage = widget.currentPage;
      print(currentPage);
      if (currentPage == "Dashboard") {
        return CourierDashboard();
      }
      else if(currentPage == "Profile"){
        return CourierProfile();
      }
      else if(currentPage == "Ongoing"){
       // return CourierBookmarks();
      }
      else if(currentPage == "Transaction"){
       return TransactionHistory();
      }
      else if(currentPage == "Community Hub"){
        actionButton = true;
        return CourierCommunityHub();
      }
    } else{
      if (currentPage == "Dashboard") {
        return CourierDashboard();
      }
    }
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

              DocumentReference courier = FirebaseFirestore.instance.collection('Couriers').doc(user.uid);
              Stream<List<Notifications>> notifList = FirebaseFirestore.instance
                  .collection('Notifications')
                  .where('Sent To', isEqualTo: courier)
                  .snapshots()
                  .map(DatabaseService().notifListFromSnapshot);

              return WillPopScope(
                  onWillPop: () async {
                    print("Back Button Pressed");
                    return false;
                  },
                  child:  Scaffold(
                    drawerEnableOpenDragGesture: false,
                    endDrawerEnableOpenDragGesture: false,
                    key: _scaffoldKey,
                    appBar: AppBar(
                      leading: Stack(

                        children: [
                          IconButton(
                            icon: Icon(Icons.menu, size: 25,), // change this size and style
                            onPressed: () => _scaffoldKey.currentState.openDrawer(),
                          ),
                        ],
                      ),
                      backgroundColor: Colors.white,
                      iconTheme: IconThemeData(color: Color(0xfffb0d0d)

                      ),
                      actions: <Widget>[
                        StreamProvider<List<Notifications>>.value(
                          value: notifList,
                          initialData: [],
                          child:  NotifCounterCourier(scaffoldKey: _scaffoldKey,approved: approved,),
                        )

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
                    body: pagePicker(),
                    floatingActionButton: !courierData.approved ? null : Visibility(visible: actionButton,
                      child: FloatingActionButton(
                        child: Icon(Icons.add_rounded),
                        onPressed: () {
                          Navigator.pushNamed(context, '/courierCreatePost');
                        },
                      ),
                    ),
                  ),
              );

            } else {
              return UserLoading();
            }
          }
      );
    }
    else return LoginScreen();
  }
}