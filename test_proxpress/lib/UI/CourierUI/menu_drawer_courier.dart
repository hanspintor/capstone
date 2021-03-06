import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:proxpress/Load/user_load.dart';
import 'package:proxpress/UI/login_screen.dart';
import 'package:proxpress/models/couriers.dart';
import 'package:proxpress/models/user.dart';
import 'package:proxpress/services/auth.dart';
import 'package:proxpress/services/database.dart';
import 'package:proxpress/services/default_profile_pic.dart';

class MainDrawerCourier extends StatefulWidget {

  @override
  _MainDrawerCourierState createState() => _MainDrawerCourierState();
}
void selectedItem(BuildContext context, int index){
  Navigator.of(context).pop();
  switch (index){
    case 0:
      Navigator.pushNamed(context, '/courierProfile');
      break;
    case 1:
      Navigator.pushNamed(context, '/courierDashboard');
      break;
    case 2:
      Navigator.pushNamed(context, '/pendingDeliveries');
      break;
    case 3:
      Navigator.pop(context);
      break;
  }
}

class _MainDrawerCourierState extends State<MainDrawerCourier> {
  final AuthService _auth = AuthService();
  String status = "Active";

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<TheUser>(context);
    bool approved = false;

    return user == null ? LoginScreen() :Drawer(
      child: StreamBuilder<Courier>(
        stream: DatabaseService(uid: user.uid).courierData,
        builder: (context, snapshot) {
          if(snapshot.hasData){
            Courier courierData = snapshot.data;

            approved = courierData.approved;

            return Column(
              mainAxisSize: MainAxisSize.max,
              children: [
                Expanded(
                  child: ListView(
                    children: [
                      DrawerHeader(
                        child: Column(
                          children: [
                            Container(
                              child: ClipOval(
                                child: Image.network('https://firebasestorage.googleapis.com/v0/b/proxpress-629e3.appspot.com/o/profile-user.png?alt=media&token=6727618b-4289-4438-8a93-a4f14753d92e',
                                  width:80,
                                  height: 80,
                                ),
                              ),
                            ),
                            SizedBox(height: 20,),
                            Text('${courierData.fName} ${courierData.lName}', style: TextStyle(fontSize: 20)),
                          ],
                        ),
                      ),
                      ListTile(
                        leading: Icon(Icons.account_circle_rounded, color: approved ? Color(0xfffb0d0d) : Colors.grey,),
                        title: Text('Profile', style: TextStyle(color: approved ? Color(0xfffb0d0d) : Colors.grey)),
                        onTap: !approved ? null : () {
                          selectedItem(context, 0);
                        },
                      ),
                      ListTile(
                        leading: Icon(Icons.home_rounded, color: approved ? Color(0xfffb0d0d) : Colors.grey,),
                        title: Text('Home', style: TextStyle(color: approved ? Color(0xfffb0d0d) : Colors.grey)),
                        onTap: !approved ? null : () {
                          selectedItem(context, 1);
                        },
                      ),
                      ListTile(
                        leading: Icon(Icons.pending_actions_rounded, color: approved ? Color(0xfffb0d0d) : Colors.grey,),
                        title: Text('Pending Deliveries', style: TextStyle(color: approved ? Color(0xfffb0d0d) : Colors.grey)),
                        onTap: !approved ? null : () {
                          selectedItem(context, 2);
                        },
                      ),
                      ListTile(
                        leading: Icon(Icons.history, color: approved ? Color(0xfffb0d0d) : Colors.grey,),
                        title: Text('Transaction History', style: TextStyle(color: approved ? Color(0xfffb0d0d) : Colors.grey)),
                        onTap: !approved ? null : () {
                          selectedItem(context, 3);
                        },
                      ),
                    ],
                  ),
                ),
                Container(
                  height: MediaQuery.of(context).size.height / 20,
                  width: MediaQuery.of(context).size.width / 1,
                  child: ElevatedButton.icon(
                    icon: Icon(Icons.logout_rounded),
                    label: Text('Logout'),
                    onPressed: () async{
                      setState(() {
                        status = "Offline";
                      });
                      final FirebaseAuth _auth = FirebaseAuth.instance;
                      User user = _auth.currentUser;
                      await DatabaseService(uid: user.uid).updateStatus(status);
                      await _auth.signOut();
                      //Navigator.pushNamed(context, '/loginScreen');
                      // if(result == null){
                      //   return LoadScreen();
                      // }
                    },
                    style: ElevatedButton.styleFrom(primary: Color(0xfffb0d0d), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(0)),),
                  ),
                ),
              ],
            );
          } else {
            return UserLoading();
          }
        }
      ),
    );
  }
}
