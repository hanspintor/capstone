import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:proxpress/UI/CourierUI/notif_drawer_courier.dart';
import 'package:proxpress/UI/login_screen.dart';
import 'package:proxpress/classes/notif_counter.dart';
import 'package:proxpress/models/couriers.dart';
import 'package:proxpress/Load/user_load.dart';
import 'package:proxpress/models/deliveries.dart';
import 'package:proxpress/services/database.dart';
import 'package:proxpress/models/user.dart';
import 'package:provider/provider.dart';


class CourierProfile extends StatelessWidget {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  @override
  Widget build(BuildContext context) {
    final user = Provider.of<TheUser>(context);
    bool approved = false;
    if (user != null) {
      return StreamBuilder<Courier>(
        stream: DatabaseService(uid: user.uid).courierData,
        builder: (context, snapshot) {
          if(snapshot.hasData)
          {
            Courier courierData = snapshot.data;
            approved = courierData.approved;
            Stream<List<Delivery>> deliveryList = FirebaseFirestore.instance
                .collection('Deliveries')
                .where('Courier Reference', isEqualTo: FirebaseFirestore.instance.collection('Couriers').doc(user.uid))
                .snapshots()
                .map(DatabaseService().deliveryDataListFromSnapshot);

            return StreamProvider <List<Delivery>>.value(
              initialData: [],
              value: deliveryList,
              child: Scaffold(
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
                      NotifCounter(scaffoldKey: _scaffoldKey, approved: approved,)
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
                    child:  Center(
                      child: SizedBox(
                        width: 300,
                        height: 500,
                        child: Card(
                          margin: EdgeInsets.fromLTRB(0, 100, 0, 0),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                child: CircleAvatar(
                                  radius: 80,
                                  backgroundImage: NetworkImage(courierData.avatarUrl),
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
                    ),


                  )
              ),
            );
          } else {
            return UserLoading();
          }
        }
      );
    } else {
      return LoginScreen();
    }
  }
}