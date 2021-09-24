import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:proxpress/UI/CourierUI/menu_drawer_courier.dart';
import 'package:proxpress/UI/CourierUI/notif_drawer_courier.dart';
import 'package:proxpress/UI/login_screen.dart';
import 'package:proxpress/classes/courier_classes/feedback_list.dart';
import 'package:proxpress/classes/courier_classes/notif_counter_courier.dart';
import 'package:proxpress/models/couriers.dart';
import 'package:proxpress/Load/user_load.dart';
import 'package:proxpress/models/deliveries.dart';
import 'package:proxpress/services/database.dart';
import 'package:proxpress/models/user.dart';
import 'package:provider/provider.dart';


class CourierProfile extends StatelessWidget {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  @override

  Widget _buildStars(int rate){
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(5, (index) {
        return Icon(
          index < rate ? Icons.star : Icons.star_border, color: Colors.amber,
        );
      }),
    );
  }


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
                .where('Delivery Status', isEqualTo: 'Delivered')
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
                    actions: [
                      NotifCounterCourier(scaffoldKey: _scaffoldKey, approved: approved,)
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
                  drawer: MainDrawerCourier(),
                  endDrawer: NotifDrawerCourier(),
                  body: SingleChildScrollView(
                    child:  Column(
                      children: [
                        Center(
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
                                      backgroundImage: NetworkImage(courierData.avatarUrl),
                                      backgroundColor: Colors.white,
                                    ),
                                  ),
                                  ListTile(
                                    title: Text(
                                      '${courierData.fName} ${courierData.lName}',
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
                                              Text(courierData.address, style: TextStyle(fontSize: 15)),
                                            ],
                                          ),
                                          Row(
                                            children: [
                                              Container(padding:  EdgeInsets.only(right: 5), child: Icon(Icons.alternate_email_rounded, size: 20,)),
                                              Text(courierData.email, style: TextStyle(fontSize: 15)),
                                            ],
                                          ),
                                          Row(
                                            children: [
                                              Container(padding:  EdgeInsets.only(right: 5), child: Icon(Icons.phone_rounded, size: 20,)),
                                              Text(courierData.contactNo, style: TextStyle(fontSize: 15)),
                                            ],
                                          ),
                                          Row(
                                            children: [
                                              Container(padding:  EdgeInsets.only(right: 5), child: Icon(Icons.local_shipping_rounded, size: 20,)),
                                              Text(courierData.vehicleType, style: TextStyle(fontSize: 15)),
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
                                                Navigator.pushNamed(context, '/courierUpdate');
                                              },
                                            ),
                                          ),
                                        ],
                                      ),
                                  ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.all(25),
                          child: Card(
                            child: StreamBuilder <List<Delivery>>(
                                stream: DatabaseService().deliveryList,
                                builder: (context, snapshot) {
                                  if(snapshot.hasData){
                                    List<Delivery> deliveryData = snapshot.data;
                                    double rating = 0.0;
                                    double total = 0.0;
                                    double stars = 0;
                                    double star1 = 0;
                                    double star2 = 0;
                                    double star3 = 0;
                                    double star4 = 0;
                                    double star5 = 0;

                                    for(int i = 0; i < deliveryData.length; i++){
                                      if(deliveryData[i].rating != 0 && deliveryData[i].feedback != ''){
                                        if(deliveryData[i].courierRef.id == courierData.uid){
                                          rating += deliveryData[i].rating;
                                          total++;
                                          if(deliveryData[i].rating == 1) star1++;
                                          else if(deliveryData[i].rating == 2) star2++;
                                          else if(deliveryData[i].rating == 3) star3++;
                                          else if(deliveryData[i].rating == 4) star4++;
                                          else if(deliveryData[i].rating == 5) star5++;
                                          print('instance');
                                        }
                                      }
                                    };
                                    stars = (rating/total);
                                    return ListTile(
                                      title: Text('Rating', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                                      subtitle: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text('${stars.ceil()}', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                                          Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: List.generate(5, (index) {
                                              return Icon(
                                                index < stars ? Icons.star : Icons.star_border, color: Colors.amber,
                                              );
                                            }),
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.only(left: 4),
                                            child: Text("Ratings ${total.toInt()}", style: TextStyle(fontWeight: FontWeight.bold),),
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.only(top: 20),
                                            child: Column(
                                              children: [
                                                Row(
                                                  children: [
                                                    _buildStars(5),
                                                    Padding(
                                                      padding: const EdgeInsets.only(left: 10),
                                                      child: Text('${star5.toInt()}'),
                                                    ),
                                                  ],
                                                ),
                                                Row(
                                                  children: [
                                                    _buildStars(4),
                                                    Padding(
                                                      padding: const EdgeInsets.only(left: 10),
                                                      child: Text('${star4.toInt()}'),
                                                    ),
                                                  ],
                                                ),
                                                Row(
                                                  children: [
                                                    _buildStars(3),
                                                    Padding(
                                                      padding: const EdgeInsets.only(left: 10),
                                                      child: Text('${star3.toInt()}'),
                                                    ),
                                                  ],
                                                ),
                                                Row(
                                                  children: [
                                                    _buildStars(2),
                                                    Padding(
                                                      padding: const EdgeInsets.only(left: 10),
                                                      child: Text('${star2.toInt()}'),
                                                    ),
                                                  ],
                                                ),
                                                Row(
                                                  children: [
                                                    _buildStars(1),
                                                    Padding(
                                                      padding: const EdgeInsets.only(left: 10),
                                                      child: Text('${star1.toInt()}'),
                                                    ),
                                                  ],
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    );
                                  }
                                  else return Container();
                                }
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(25),
                          child: Card(
                              child: ListTile(
                                title: Text('Feedbacks', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                                subtitle: Column(
                                  children: [
                                    FeedbackList(),
                                  ],
                                ),
                              ),
                          ),
                        ),
                      ],
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