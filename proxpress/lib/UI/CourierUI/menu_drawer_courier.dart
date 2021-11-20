import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:page_transition/page_transition.dart';
import 'package:provider/provider.dart';
import 'package:proxpress/Load/user_load.dart';
import 'package:proxpress/UI/CourierUI/proxpress_template_courier.dart';
import 'package:proxpress/models/couriers.dart';
import 'package:proxpress/models/user.dart';
import 'package:proxpress/services/database.dart';

class MainDrawerCourier extends StatefulWidget {
  @override
  _MainDrawerCourierState createState() => _MainDrawerCourierState();
}

void selectedItem(BuildContext context, int index){
  Navigator.of(context).pop();
  switch (index){
    case 0:
      Navigator.push(
        context,
        PageTransition(child: AppBarTemp1(
          currentPage: "Profile",
        ), type: PageTransitionType.rightToLeft),
      );
      break;
    case 1:
      Navigator.push(
        context,
        PageTransition(child: AppBarTemp1(
          currentPage: "Dashboard",
        ), type: PageTransitionType.rightToLeft),
      );
      break;
    case 2:
      Navigator.pushNamed(context, '/ongoingDelivery');
      break;
    case 3:
      Navigator.push(
        context,
        PageTransition(child: AppBarTemp1(
          currentPage: "Transaction",
        ), type: PageTransitionType.rightToLeft),
      );
      break;
    case 4:
      Navigator.push(
        context,
        PageTransition(child: AppBarTemp1(
          currentPage: "Community Hub",
        ), type: PageTransitionType.rightToLeft),
      );
      break;
    case 5:
      Navigator.push(
        context,
        PageTransition(child: AppBarTemp1(
          currentPage: "Wallet",
        ), type: PageTransitionType.rightToLeft),
      );
      break;
  }
}

class _MainDrawerCourierState extends State<MainDrawerCourier> {
  String status = "Active";

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<TheUser>(context);
    bool approved = false;
    final auth = FirebaseAuth.instance;
    User user1 = auth.currentUser;

    return Drawer(
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
                              child: CircleAvatar(
                                radius: 40,
                                backgroundImage: NetworkImage(courierData.avatarUrl),
                                backgroundColor: Colors.white,
                              ),
                            ),
                            SizedBox(height: 20,),
                            Text('${courierData.fName} ${courierData.lName}', style: TextStyle(fontSize: 20)),
                          ],
                        ),
                      ),
                      ListTile(
                        leading: Icon(Icons.account_circle_rounded, color: approved || user1.emailVerified && user1.phoneNumber != null ? Color(0xfffb0d0d) : Colors.grey,),
                        title: Text('Profile', style: TextStyle(color: approved || user1.emailVerified && user1.phoneNumber != null ? Color(0xfffb0d0d) : Colors.grey)),
                        onTap: !approved || !user1.emailVerified && user1.phoneNumber == null ? null : () {
                          selectedItem(context, 0);
                        },
                      ),
                      ListTile(
                        leading: Icon(Icons.pending_actions_rounded, color: approved || user1.emailVerified && user1.phoneNumber != null ? Color(0xfffb0d0d) : Colors.grey,),
                        title: Text('Pending Requests', style: TextStyle(color: approved || user1.emailVerified && user1.phoneNumber != null ? Color(0xfffb0d0d) : Colors.grey)),
                        onTap: !approved || !user1.emailVerified && user1.phoneNumber == null ? null : () {
                          selectedItem(context, 1);
                        },
                      ),
                      ListTile(
                        leading: Icon(Icons.published_with_changes_rounded, color: approved || user1.emailVerified && user1.phoneNumber != null ? Color(0xfffb0d0d) : Colors.grey,),
                        title: Text('Ongoing Delivery', style: TextStyle(color: approved || user1.emailVerified && user1.phoneNumber != null ? Color(0xfffb0d0d) : Colors.grey)),
                        onTap: !approved || !user1.emailVerified && user1.phoneNumber == null ?  null : () {
                          selectedItem(context, 2);
                        },
                      ),
                      ListTile(
                        leading: Icon(Icons.history, color: approved || user1.emailVerified && user1.phoneNumber != null ? Color(0xfffb0d0d) : Colors.grey,),
                        title: Text('Transaction History', style: TextStyle(color: approved || user1.emailVerified && user1.phoneNumber != null ? Color(0xfffb0d0d) : Colors.grey)),
                        onTap: !approved || !user1.emailVerified && user1.phoneNumber == null ? null : () {
                          selectedItem(context, 3);
                        },
                      ),
                      ListTile(
                        leading: Icon(Icons.groups_rounded, color: approved || user1.emailVerified && user1.phoneNumber != null ? Color(0xfffb0d0d): Colors.grey,),
                        title: Text('Community Hub', style: TextStyle(color: approved || user1.emailVerified && user1.phoneNumber != null ? Color(0xfffb0d0d): Colors.grey)),
                        onTap: !approved || !user1.emailVerified && user1.phoneNumber == null ? null : () {
                          selectedItem(context, 4);
                        },
                      ),
                      ListTile(
                        leading: Icon(Icons.account_balance_wallet, color: approved || user1.emailVerified && user1.phoneNumber != null ? Color(0xfffb0d0d): Colors.grey,),
                        title: Text('Wallet', style: TextStyle(color: approved || user1.emailVerified && user1.phoneNumber != null ? Color(0xfffb0d0d): Colors.grey)),
                        onTap: !approved || !user1.emailVerified && user1.phoneNumber == null ? null : () {
                          selectedItem(context, 5);
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
                      Navigator.pushNamed(context, '/loginScreen');
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