import 'package:flutter/material.dart';
import 'package:proxpress/UI/CourierUI/notif_drawer_courier.dart';
import 'package:proxpress/UI/login_screen.dart';
import 'package:proxpress/models/couriers.dart';
import 'package:proxpress/Load/user_load.dart';
import 'package:proxpress/services/database.dart';
import 'package:proxpress/models/user.dart';
import 'package:provider/provider.dart';
import 'package:proxpress/services/default_profile_pic.dart';


class CourierProfile extends StatelessWidget {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  void _openEndDrawer() {
    _scaffoldKey.currentState.openEndDrawer();
  }
  // Future _getDefaultProfile(BuildContext context, String imageName) async {
  //   Image image;
  //   await FireStorageService.loadImage(context, imageName).then((value) {
  //     image = Image.network(
  //       value.toString(),
  //       // fit: BoxFit.scaleDown,
  //     );
  //   });
  //   return image;
  // }

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<TheUser>(context);

    if (user != null) {
      return Scaffold(
          drawerEnableOpenDragGesture: false,
          endDrawerEnableOpenDragGesture: false,
          key:_scaffoldKey,
          appBar: AppBar(
            backgroundColor: Colors.white,
            iconTheme: IconThemeData(color: Color(0xfffb0d0d),),
            leading: IconButton(icon: Icon(
              Icons.arrow_back,
            ),
              onPressed: (){
                Navigator.pop(context, false);

              },
              iconSize: 25,
            ),
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
          endDrawer: NotifDrawerCourier(),
          body: SingleChildScrollView(
            child: StreamBuilder<Courier>(
                stream: DatabaseService(uid: user.uid).courierData,
                builder: (context,snapshot){
                  if(snapshot.hasData){
                    Courier courierData = snapshot.data;
                    return Center(
                      child: SizedBox(
                        width: 300,
                        height: 500,
                        child: Card(
                          margin: EdgeInsets.fromLTRB(0, 100, 0, 0),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                child: ClipOval(
                                  child: Image.network('https://firebasestorage.googleapis.com/v0/b/proxpress-629e3.appspot.com/o/profile-user.png?alt=media&token=6727618b-4289-4438-8a93-a4f14753d92e',
                                    width:100,
                                    height: 100,
                                  ),
                                ),
                              ),
                              Container(
                                margin: EdgeInsets.fromLTRB(0, 10, 0, 0),
                                child: Text(
                                  '${courierData.fName} ${courierData.lName}',
                                  style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
                                ),
                              ),
                              Container(
                                margin: EdgeInsets.fromLTRB(0, 10, 0, 0),
                                child: Text(
                                    courierData.address,
                                    style: TextStyle(fontSize: 15)
                                ),
                              ),
                              Container(
                                margin: EdgeInsets.fromLTRB(0, 10, 0, 0),
                                child: Text(
                                    courierData.email,
                                    style: TextStyle(fontSize: 15)
                                ),
                              ),
                              Container(
                                margin: EdgeInsets.fromLTRB(0, 10, 0, 0),
                                child: Text(
                                    courierData.contactNo,
                                    style: TextStyle(fontSize: 15)
                                ),
                              ),
                              Container(
                                margin: EdgeInsets.fromLTRB(0, 20, 0, 20),
                                child: ElevatedButton.icon(
                                  icon: Icon(Icons.edit_rounded),
                                  label: Text('Edit Profile'),
                                  style : ElevatedButton.styleFrom(primary: Color(0xfffb0d0d)),
                                  onPressed: (){
                                    Navigator.pushNamed(context, '/courierUpdate');
                                  },
                                ),
                              ),
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
      );
    } else {
      return LoginScreen();
    }
  }
}