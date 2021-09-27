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
              child: DefaultTabController(
                length: 2,
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
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                SizedBox(height: 20,),
                                CircleAvatar(
                                  radius: 80,
                                  backgroundImage: NetworkImage(courierData.avatarUrl),
                                  backgroundColor: Colors.white,
                                ),
                                Container(
                                  margin: EdgeInsets.fromLTRB(0, 0, 0, 0),
                                  width: 360,
                                  child: TextButton.icon(
                                    icon: Icon(Icons.edit_rounded, size: 15, color: Colors.red),
                                    label: Text('Edit Profile', style: TextStyle(fontSize: 15, color: Colors.red),),
                                    style : ButtonStyle(
                                      shape: MaterialStateProperty.all(
                                          RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(30.0),
                                          )
                                      ),
                                      side: MaterialStateProperty.all(BorderSide(color: Colors.red))
                                    ),
                                    onPressed: (){
                                      Navigator.pushNamed(context, '/courierUpdate');
                                    },
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
                                      ],
                                    ),
                                ),
                                ),
                              ],
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.all(25),
                            child: Column(
                              children: [
                                StreamBuilder <List<Delivery>>(
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
                                        int fee = 0;

                                        for(int i = 0; i < deliveryData.length; i++){
                                          if(deliveryData[i].courierRef.id == courierData.uid && deliveryData[i].deliveryStatus == 'Delivered'){
                                            fee += deliveryData[i].deliveryFee;
                                            if(deliveryData[i].rating != 0 && deliveryData[i].feedback != ''){
                                              rating += deliveryData[i].rating;
                                              total++;
                                              if(deliveryData[i].rating == 1) star1++;
                                              else if(deliveryData[i].rating == 2) star2++;
                                              else if(deliveryData[i].rating == 3) star3++;
                                              else if(deliveryData[i].rating == 4) star4++;
                                              else if(deliveryData[i].rating == 5) star5++;
                                            }
                                          }
                                        };
                                        stars = (rating/total);
                                        return Column(
                                          children: [
                                            TabBar(
                                              tabs: [
                                                Tab(child: Text("Rating", style: TextStyle(color: Colors.black),)),
                                                Tab(child: Text("Feedbacks", style: TextStyle(color: Colors.black),)),
                                              ],
                                            ),
                                            SizedBox(
                                              height: 320,
                                              child: TabBarView(
                                                children: [
                                                  ListTile(
                                                    subtitle: Column(
                                                      children: [
                                                        ListTile(
                                                          title: Text('Rating', style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold)),
                                                          subtitle: Column(
                                                            crossAxisAlignment: CrossAxisAlignment.start,
                                                            children: [
                                                              Text.rich(
                                                                TextSpan(children: [
                                                                  TextSpan(text:'${stars.ceil()}', style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold, color: Colors.black)),
                                                                  TextSpan(text:'/5', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                                                                ],
                                                                ),
                                                              ),
                                                            ],
                                                          ),
                                                          trailing: Column(
                                                            children: [
                                                              Row(
                                                                mainAxisSize: MainAxisSize.min,
                                                                children: List.generate(5, (index) {
                                                                  return Icon(
                                                                    index < stars ? Icons.star : Icons.star_border, color: Colors.amber,
                                                                  );
                                                                }),
                                                              ),
                                                              Text("Ratings ${total.toInt()}", style: TextStyle(fontWeight: FontWeight.bold),),
                                                            ],
                                                          ),
                                                        ),
                                                        ListTile(
                                                          subtitle: Padding(
                                                            padding: const EdgeInsets.only(top: 20),
                                                            child: Column(
                                                              children: [
                                                                Row(
                                                                  children: [
                                                                    Padding(
                                                                      padding: const EdgeInsets.only(right: 20),
                                                                      child: Text('${star5.toInt()}'),
                                                                    ),
                                                                    Padding(
                                                                      padding: const EdgeInsets.only(right: 20),
                                                                      child: Container(
                                                                        height: 5,
                                                                        width: 120,
                                                                        child: LinearProgressIndicator(
                                                                          backgroundColor: Colors.black12,
                                                                          color: Colors.amber,
                                                                          value: star5 / total,
                                                                        ),
                                                                      ),
                                                                    ),
                                                                    _buildStars(5),
                                                                  ],
                                                                ),
                                                                Row(
                                                                  children: [
                                                                    Padding(
                                                                      padding: const EdgeInsets.only(right: 20),
                                                                      child: Text('${star4.toInt()}'),
                                                                    ),
                                                                    Padding(
                                                                      padding: const EdgeInsets.only(right: 20),
                                                                      child: Container(
                                                                        height: 5,
                                                                        width: 120,
                                                                        child: LinearProgressIndicator(
                                                                          backgroundColor: Colors.black12,
                                                                          color: Colors.amber,
                                                                          value: star4 / total,
                                                                        ),
                                                                      ),
                                                                    ),
                                                                    _buildStars(4),
                                                                  ],
                                                                ),
                                                                Row(
                                                                  children: [
                                                                    Padding(
                                                                      padding: const EdgeInsets.only(right: 20),
                                                                      child: Text('${star3.toInt()}'),
                                                                    ),
                                                                    Padding(
                                                                      padding: const EdgeInsets.only(right: 20),
                                                                      child: Container(
                                                                        height: 5,
                                                                        width: 120,
                                                                        child: LinearProgressIndicator(
                                                                          backgroundColor: Colors.black12,
                                                                          color: Colors.amber,
                                                                          value: star3 / total,
                                                                        ),
                                                                      ),
                                                                    ),
                                                                    _buildStars(3),
                                                                  ],
                                                                ),
                                                                Row(
                                                                  children: [
                                                                    Padding(
                                                                      padding: const EdgeInsets.only(right: 20),
                                                                      child: Text('${star2.toInt()}'),
                                                                    ),
                                                                    Padding(
                                                                      padding: const EdgeInsets.only(right: 20),
                                                                      child: Container(
                                                                        height: 5,
                                                                        width: 120,
                                                                        child: LinearProgressIndicator(
                                                                          backgroundColor: Colors.black12,
                                                                          color: Colors.amber,
                                                                          value: star2 / total,
                                                                        ),
                                                                      ),
                                                                    ),
                                                                    _buildStars(2),
                                                                  ],
                                                                ),
                                                                Row(
                                                                  children: [
                                                                    Padding(
                                                                      padding: const EdgeInsets.only(right: 20),
                                                                      child: Text('${star1.toInt()}'),
                                                                    ),
                                                                    Padding(
                                                                      padding: const EdgeInsets.only(right: 20),
                                                                      child: Container(
                                                                        height: 5,
                                                                        width: 120,
                                                                        child: LinearProgressIndicator(
                                                                          backgroundColor: Colors.black12,
                                                                          color: Colors.amber,
                                                                          value: star1 / total,
                                                                        ),
                                                                      ),
                                                                    ),
                                                                    _buildStars(1),
                                                                  ],
                                                                ),
                                                                // ListTile(
                                                                //   title: Text('Total Earnings', style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold)),
                                                                //   trailing: Text("\₱${fee}", style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold, color: Colors.black)
                                                                //   ),
                                                                // ),
                                                              ],
                                                            ),
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                  SingleChildScrollView(
                                                    child: ListTile(
                                                      title: Text('Feedbacks', style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold)),
                                                      subtitle: Column(
                                                        children: [
                                                          FeedbackList(delivery: deliveryData),
                                                        ],
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ],
                                        );
                                      }
                                      else return Container();
                                    }
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),


                    )
                ),
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