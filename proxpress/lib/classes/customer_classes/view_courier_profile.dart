import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:proxpress/classes/courier_classes/feedback_list.dart';
import 'package:proxpress/models/couriers.dart';
import 'package:proxpress/Load/user_load.dart';
import 'package:proxpress/models/deliveries.dart';
import 'package:proxpress/services/database.dart';
import 'package:proxpress/models/user.dart';
import 'package:provider/provider.dart';

class ViewCourierProfile extends StatelessWidget {
  final String courierUID;

  ViewCourierProfile({
    Key key,
    @required this.courierUID,

  }) : super(key: key);

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

  Widget _welcomeMessage(String adminMessage){
    return Column(
      children: [
        Container(
          margin: EdgeInsets.fromLTRB(20, 40, 20, 0),
          child: Align(
            child: Text(adminMessage,
              textAlign: TextAlign.justify,
              style: TextStyle(
                fontSize: 20,
              ),
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<TheUser>(context);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        iconTheme: IconThemeData(color: Colors.red),
        flexibleSpace: Container(
          margin: EdgeInsets.only(top: 10),
          child: Image.asset(
            "assets/PROExpress-logo.png",
            height: 120,
            width: 120,
          ),
        ),
      ),
      body: StreamBuilder<Courier>(
          stream: DatabaseService(uid: courierUID).courierData,
          builder: (context, snapshot) {
            if(snapshot.hasData) {
              Courier courierData = snapshot.data;
              Stream<List<Delivery>> deliveryList = FirebaseFirestore.instance
                  .collection('Deliveries')
                  .where('Delivery Status', isEqualTo: 'Delivered')
                  .where('Courier Reference', isEqualTo: FirebaseFirestore.instance.collection('Couriers').doc(user.uid))
                  .snapshots()
                  .map(DatabaseService().deliveryDataListFromSnapshot);

              return !courierData.approved ? _welcomeMessage(courierData.adminMessage) : DefaultTabController(
                length: 2,
                child: SingleChildScrollView(
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
                                    Row(
                                      children: [
                                        Container(padding:  EdgeInsets.only(right: 5), child: Icon(Icons.color_lens_rounded, size: 20,)),
                                        Container(
                                          width: 20,
                                          height: 20,
                                          decoration: BoxDecoration(
                                            border: Border.all(),
                                            shape: BoxShape.circle,
                                            color: Color(courierData.vehicleColor),
                                          ),
                                        ),
                                      ],
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Image.network(courierData.vehiclePhoto_),
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
                                stream:   deliveryList,
                                builder: (context, snapshot) {
                                  if(snapshot.hasData && snapshot.data.length != 0){
                                    List<Delivery> deliveryData = snapshot.data;
                                    List<Delivery> toRemove = [];

                                    deliveryData.forEach((element) {
                                      if (element.rating == 0)
                                        toRemove.add(element);
                                    });

                                    deliveryData.removeWhere((e) => toRemove.contains(e));

                                    if (deliveryData.length != 0) {
                                      double rating = 0.0;
                                      double total = 0.0;
                                      double stars = 0;
                                      double star1 = 0;
                                      double star2 = 0;
                                      double star3 = 0;
                                      double star4 = 0;
                                      double star5 = 0;

                                      for(int i = 0; i < deliveryData.length; i++){
                                        if(deliveryData[i].courierRef.id == courierData.uid && deliveryData[i].deliveryStatus == 'Delivered'){
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
                                              Tab(child: Text("Rating")),
                                              Tab(child: Text("Feedbacks")),
                                            ],
                                            labelColor: Colors.red,
                                            unselectedLabelColor: Colors.grey[700],
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
                                                                    padding: const EdgeInsets.only(right: 10),
                                                                    child: Text('${star5.toInt()}'),
                                                                  ),
                                                                  Padding(
                                                                    padding: const EdgeInsets.only(right: 10),
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
                                                                    padding: const EdgeInsets.only(right: 10),
                                                                    child: Text('${star4.toInt()}'),
                                                                  ),
                                                                  Padding(
                                                                    padding: const EdgeInsets.only(right: 10),
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
                                                                    padding: const EdgeInsets.only(right: 10),
                                                                    child: Text('${star3.toInt()}'),
                                                                  ),
                                                                  Padding(
                                                                    padding: const EdgeInsets.only(right: 10),
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
                                                                    padding: const EdgeInsets.only(right: 10),
                                                                    child: Text('${star2.toInt()}'),
                                                                  ),
                                                                  Padding(
                                                                    padding: const EdgeInsets.only(right: 10),
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
                                                                    padding: const EdgeInsets.only(right: 10),
                                                                    child: Text('${star1.toInt()}'),
                                                                  ),
                                                                  Padding(
                                                                    padding: const EdgeInsets.only(right: 10),
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
                                    } else {
                                      double total = 0.0;
                                      double stars = 0;
                                      double star1 = 0;
                                      double star2 = 0;
                                      double star3 = 0;
                                      double star4 = 0;
                                      double star5 = 0;

                                      return Column(
                                        children: [
                                          TabBar(
                                            tabs: [
                                              Tab(child: Text("Rating")),
                                              Tab(child: Text("Feedbacks")),
                                            ],
                                            labelColor: Colors.red,
                                            unselectedLabelColor: Colors.grey[700],
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
                                                                    padding: const EdgeInsets.only(right: 10),
                                                                    child: Text('${star5.toInt()}'),
                                                                  ),
                                                                  Padding(
                                                                    padding: const EdgeInsets.only(right: 10),
                                                                    child: Container(
                                                                      height: 5,
                                                                      width: 120,
                                                                      child: LinearProgressIndicator(
                                                                        backgroundColor: Colors.black12,
                                                                        color: Colors.amber,
                                                                        value: total,
                                                                      ),
                                                                    ),
                                                                  ),
                                                                  _buildStars(5),
                                                                ],
                                                              ),
                                                              Row(
                                                                children: [
                                                                  Padding(
                                                                    padding: const EdgeInsets.only(right: 10),
                                                                    child: Text('${star4.toInt()}'),
                                                                  ),
                                                                  Padding(
                                                                    padding: const EdgeInsets.only(right: 10),
                                                                    child: Container(
                                                                      height: 5,
                                                                      width: 120,
                                                                      child: LinearProgressIndicator(
                                                                        backgroundColor: Colors.black12,
                                                                        color: Colors.amber,
                                                                        value: total,
                                                                      ),
                                                                    ),
                                                                  ),
                                                                  _buildStars(4),
                                                                ],
                                                              ),
                                                              Row(
                                                                children: [
                                                                  Padding(
                                                                    padding: const EdgeInsets.only(right: 10),
                                                                    child: Text('${star3.toInt()}'),
                                                                  ),
                                                                  Padding(
                                                                    padding: const EdgeInsets.only(right: 10),
                                                                    child: Container(
                                                                      height: 5,
                                                                      width: 120,
                                                                      child: LinearProgressIndicator(
                                                                        backgroundColor: Colors.black12,
                                                                        color: Colors.amber,
                                                                        value: total,
                                                                      ),
                                                                    ),
                                                                  ),
                                                                  _buildStars(3),
                                                                ],
                                                              ),
                                                              Row(
                                                                children: [
                                                                  Padding(
                                                                    padding: const EdgeInsets.only(right: 10),
                                                                    child: Text('${star2.toInt()}'),
                                                                  ),
                                                                  Padding(
                                                                    padding: const EdgeInsets.only(right: 10),
                                                                    child: Container(
                                                                      height: 5,
                                                                      width: 120,
                                                                      child: LinearProgressIndicator(
                                                                        backgroundColor: Colors.black12,
                                                                        color: Colors.amber,
                                                                        value: total,
                                                                      ),
                                                                    ),
                                                                  ),
                                                                  _buildStars(2),
                                                                ],
                                                              ),
                                                              Row(
                                                                children: [
                                                                  Padding(
                                                                    padding: const EdgeInsets.only(right: 10),
                                                                    child: Text('${star1.toInt()}'),
                                                                  ),
                                                                  Padding(
                                                                    padding: const EdgeInsets.only(right: 10),
                                                                    child: Container(
                                                                      height: 5,
                                                                      width: 120,
                                                                      child: LinearProgressIndicator(
                                                                        backgroundColor: Colors.black12,
                                                                        color: Colors.amber,
                                                                        value: total,
                                                                      ),
                                                                    ),
                                                                  ),
                                                                  _buildStars(1),
                                                                ],
                                                              ),
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
                                  } else {
                                    double total = 0.0;
                                    double stars = 0;
                                    double star1 = 0;
                                    double star2 = 0;
                                    double star3 = 0;
                                    double star4 = 0;
                                    double star5 = 0;

                                    return Column(
                                      children: [
                                        TabBar(
                                          tabs: [
                                            Tab(child: Text("Rating")),
                                            Tab(child: Text("Feedbacks")),
                                          ],
                                          labelColor: Colors.red,
                                          unselectedLabelColor: Colors.grey[700],
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
                                                                  padding: const EdgeInsets.only(right: 10),
                                                                  child: Text('${star5.toInt()}'),
                                                                ),
                                                                Padding(
                                                                  padding: const EdgeInsets.only(right: 10),
                                                                  child: Container(
                                                                    height: 5,
                                                                    width: 120,
                                                                    child: LinearProgressIndicator(
                                                                      backgroundColor: Colors.black12,
                                                                      color: Colors.amber,
                                                                      value: total,
                                                                    ),
                                                                  ),
                                                                ),
                                                                _buildStars(5),
                                                              ],
                                                            ),
                                                            Row(
                                                              children: [
                                                                Padding(
                                                                  padding: const EdgeInsets.only(right: 10),
                                                                  child: Text('${star4.toInt()}'),
                                                                ),
                                                                Padding(
                                                                  padding: const EdgeInsets.only(right: 10),
                                                                  child: Container(
                                                                    height: 5,
                                                                    width: 120,
                                                                    child: LinearProgressIndicator(
                                                                      backgroundColor: Colors.black12,
                                                                      color: Colors.amber,
                                                                      value: total,
                                                                    ),
                                                                  ),
                                                                ),
                                                                _buildStars(4),
                                                              ],
                                                            ),
                                                            Row(
                                                              children: [
                                                                Padding(
                                                                  padding: const EdgeInsets.only(right: 10),
                                                                  child: Text('${star3.toInt()}'),
                                                                ),
                                                                Padding(
                                                                  padding: const EdgeInsets.only(right: 10),
                                                                  child: Container(
                                                                    height: 5,
                                                                    width: 120,
                                                                    child: LinearProgressIndicator(
                                                                      backgroundColor: Colors.black12,
                                                                      color: Colors.amber,
                                                                      value: total,
                                                                    ),
                                                                  ),
                                                                ),
                                                                _buildStars(3),
                                                              ],
                                                            ),
                                                            Row(
                                                              children: [
                                                                Padding(
                                                                  padding: const EdgeInsets.only(right: 10),
                                                                  child: Text('${star2.toInt()}'),
                                                                ),
                                                                Padding(
                                                                  padding: const EdgeInsets.only(right: 10),
                                                                  child: Container(
                                                                    height: 5,
                                                                    width: 120,
                                                                    child: LinearProgressIndicator(
                                                                      backgroundColor: Colors.black12,
                                                                      color: Colors.amber,
                                                                      value: total,
                                                                    ),
                                                                  ),
                                                                ),
                                                                _buildStars(2),
                                                              ],
                                                            ),
                                                            Row(
                                                              children: [
                                                                Padding(
                                                                  padding: const EdgeInsets.only(right: 10),
                                                                  child: Text('${star1.toInt()}'),
                                                                ),
                                                                Padding(
                                                                  padding: const EdgeInsets.only(right: 10),
                                                                  child: Container(
                                                                    height: 5,
                                                                    width: 120,
                                                                    child: LinearProgressIndicator(
                                                                      backgroundColor: Colors.black12,
                                                                      color: Colors.amber,
                                                                      value: total,
                                                                    ),
                                                                  ),
                                                                ),
                                                                _buildStars(1),
                                                              ],
                                                            ),
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
                                                    children: [],
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    );
                                  }
                                }
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            } else {
              return UserLoading();
            }
          }
      ),
    );
  }
}