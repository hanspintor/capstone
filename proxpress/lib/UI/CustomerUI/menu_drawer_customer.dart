import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:page_transition/page_transition.dart';
import 'package:proxpress/UI/CustomerUI/proxpress_template_customer.dart';
import 'package:proxpress/UI/login_screen.dart';
import 'package:proxpress/Load/user_load.dart';
import 'package:proxpress/services/database.dart';
import 'package:proxpress/models/user.dart';
import 'package:provider/provider.dart';
import 'package:proxpress/models/customers.dart';


class MainDrawerCustomer extends StatefulWidget {
  @override
  _MainDrawerCustomerState createState() => _MainDrawerCustomerState();
}
void selectedItem(BuildContext context, int index,) async {
  Navigator.of(context).pop();
  switch (index){
    case 0:
      Navigator.push(
        context,
        PageTransition(child: AppBarTemp(
          currentPage: "Profile",
        ), type: PageTransitionType.rightToLeft),
      );
      break;
    case 1:
      Navigator.push(
        context,
        PageTransition(child: AppBarTemp(
          currentPage: "Dashboard",
        ), type: PageTransitionType.rightToLeft),
      );
      break;
    case 2:
      Navigator.push(
        context,
        PageTransition(child: AppBarTemp(
          currentPage: "Bookmarks",
        ), type: PageTransitionType.rightToLeft),
      );
      break;
    case 3:
      Navigator.push(
        context,
        PageTransition(child: AppBarTemp(
          currentPage: "Requests",
        ), type: PageTransitionType.rightToLeft),
      );
      break;
    case 4:
      Navigator.push(
        context,
        PageTransition(child: AppBarTemp(
          currentPage: "Community Hub",
        ), type: PageTransitionType.rightToLeft),
      );
      break;
    case 5:
      Navigator.push(
        context,
        PageTransition(child: AppBarTemp(
          currentPage: "Wallet",
        ), type: PageTransitionType.rightToLeft),
      );
      break;
  }
}

class _MainDrawerCustomerState extends State<MainDrawerCustomer> {
  @override
  Widget build(BuildContext context) {
    final auth = FirebaseAuth.instance;
    User user1 = auth.currentUser;
    final user = Provider.of<TheUser>(context);

    return user == null ? LoginScreen() : Drawer(
      child: Column(
        mainAxisSize: MainAxisSize.max,
        children: [
          Expanded(
            child: ListView(
              children: [
                DrawerHeader(
                  child: StreamBuilder<Customer>(
                    stream: DatabaseService(uid: user.uid).customerData,
                    builder: (context, snapshot){
                      if(snapshot.hasData){
                        Customer customerData = snapshot.data;
                        return Column(
                          children: [
                            Stack(
                              children: [
                                Padding(
                                  padding: const EdgeInsets.fromLTRB(0, 6, 0, 0),
                                  child: Center(child: CircularProgressIndicator(),),
                                ),
                                Align(
                                  alignment: Alignment.center,
                                  child: CircleAvatar(
                                    radius: 40,
                                    backgroundImage: NetworkImage(customerData.avatarUrl),
                                    backgroundColor: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 20,),
                            Text('${customerData.fName} ${customerData.lName}', style: TextStyle(fontSize: 20)),
                          ],
                        );
                      }
                      else{
                        return UserLoading();
                      }
                    }
                  ),
                  decoration: BoxDecoration(

                  ),
                ),
                ListTile(
                  leading: Icon(Icons.account_circle_rounded, color: user1.emailVerified ? Color(0xfffb0d0d): Colors.grey,),
                  title: Text('Profile', style: TextStyle(color: user1.emailVerified ? Color(0xfffb0d0d): Colors.grey)),
                  onTap: !user1.emailVerified ? null : () {
                    selectedItem(context, 0);
                  },
                ),
                ListTile(
                  leading: Icon(Icons.place, color: user1.emailVerified ? Color(0xfffb0d0d): Colors.grey,),
                  title: Text('Pin Location', style: TextStyle(color: user1.emailVerified ? Color(0xfffb0d0d): Colors.grey)),
                  onTap: !user1.emailVerified ? null : () {
                    selectedItem(context, 1);
                  },
                ),
                ListTile(
                  leading: Icon(Icons.bookmark, color: user1.emailVerified ? Color(0xfffb0d0d): Colors.grey),
                  title: Text('Courier Bookmarks', style: TextStyle(color: user1.emailVerified ? Color(0xfffb0d0d): Colors.grey)),
                  onTap: !user1.emailVerified ? null : () {
                    selectedItem(context, 2);
                  },
                ),
                ListTile(
                  leading: Icon(Icons.notification_important_rounded, color: user1.emailVerified ? Color(0xfffb0d0d): Colors.grey,),
                  title: Text('Delivery Status', style: TextStyle(color: user1.emailVerified ? Color(0xfffb0d0d): Colors.grey)),
                  onTap: !user1.emailVerified ? null : () {
                    selectedItem(context, 3);
                  },
                ),
                ListTile(
                  leading: Icon(Icons.groups_rounded, color: user1.emailVerified ? Color(0xfffb0d0d): Colors.grey,),
                  title: Text('Community Hub', style: TextStyle(color: user1.emailVerified ? Color(0xfffb0d0d): Colors.grey)),
                  onTap: !user1.emailVerified ? null : () {
                    selectedItem(context, 4);
                  },
                ),
                ListTile(
                  leading: Icon(Icons.account_balance_wallet, color: user1.emailVerified ? Color(0xfffb0d0d): Colors.grey,),
                  title: Text('Wallet', style: TextStyle(color: user1.emailVerified ? Color(0xfffb0d0d): Colors.grey)),
                  onTap: !user1.emailVerified ? null : () {
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
                await auth.signOut();
                Navigator.pushNamed(context, '/loginScreen');
              },
              style: ElevatedButton.styleFrom(primary: Color(0xfffb0d0d), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(0)),),
            ),
          ),
        ],
      ),
    );
  }
}