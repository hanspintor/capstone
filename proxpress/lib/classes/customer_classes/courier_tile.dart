import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:expansion_tile_card/expansion_tile_card.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:page_transition/page_transition.dart';
import 'package:proxpress/UI/CustomerUI/customer_remarks.dart';
import 'package:proxpress/UI/login_screen.dart';
import 'package:proxpress/classes/courier_classes/feedback_list.dart';
import 'package:proxpress/models/couriers.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:proxpress/models/deliveries.dart';
import 'package:proxpress/models/delivery_prices.dart';
import 'package:proxpress/services/database.dart';

class CourierTile extends StatefulWidget {
  final Courier courier;
  final String pickupAddress;
  final LatLng pickupCoordinates;
  final String dropOffAddress;
  final LatLng dropOffCoordinates;
  final double distance;

  CourierTile({
    Key key,
    @required this.courier,
    @required this.pickupAddress,
    @required this.pickupCoordinates,
    @required this.dropOffAddress,
    @required this.dropOffCoordinates,
    @required this.distance,
  }) : super(key: key);

  @override
  State<CourierTile> createState() => _CourierTileState();
}

class _CourierTileState extends State<CourierTile> {
  int flag = 0;
  String deliveryPriceUid;
  double deliveryFee = 0.0;

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
  @override
  Widget build(BuildContext context) {
    deliveryPriceUid = widget.courier.deliveryPriceRef.id;

    final FirebaseAuth _auth = FirebaseAuth.instance;
    User user = _auth.currentUser;

    var color;
    if (widget.courier.status == "Offline") {
      color = Colors.redAccent;
    } else {
      color = Colors.green;
    }

    Stream<List<Delivery>> deliveryList = FirebaseFirestore.instance
        .collection('Deliveries')
        .where('Delivery Status', isEqualTo: 'Delivered')
        .where('Courier Reference', isEqualTo: FirebaseFirestore.instance.collection('Couriers').doc(widget.courier.uid))
        .snapshots()
        .map(DatabaseService().deliveryDataListFromSnapshot);

    if (user != null) {
      return StreamBuilder<DeliveryPrice>(
          stream: DatabaseService(uid: deliveryPriceUid).deliveryPriceData,
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              DeliveryPrice deliveryPriceData = snapshot.data;

              deliveryFee = (deliveryPriceData.baseFare.toDouble() + (deliveryPriceData.farePerKM.toDouble() * widget.distance));

              _bottomSheet(){
                return SingleChildScrollView(
                  child: StreamBuilder <List<Delivery>>(
                      stream: deliveryList,
                      builder: (context, snapshot) {
                        if(snapshot.hasData && snapshot.data.length != 0){
                          print("lol ${snapshot.data.length}");
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
                              if(deliveryData[i].courierRef.id == widget.courier.uid && deliveryData[i].deliveryStatus == 'Delivered'){
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
                                Card(
                                  child: ListTile(
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
                                              ],
                                            ),
                                          ),
                                        ),
                                        SizedBox(height: 30,),
                                        ListTile(
                                          title: Text('Feedbacks', style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold)),
                                          subtitle: Column(
                                            children: [
                                              FeedbackList(delivery: deliveryData),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
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
                                Card(
                                  child: ListTile(
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
                                        SizedBox(height: 30,),
                                        ListTile(
                                          title: Text('Feedbacks', style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold)),
                                          subtitle: Column(
                                            children: [

                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            );
                          }
                        }
                        else {
                          double total = 0.0;
                          double stars = 0;
                          double star1 = 0;
                          double star2 = 0;
                          double star3 = 0;
                          double star4 = 0;
                          double star5 = 0;
                          return Column(
                            children: [
                              Card(
                                child: ListTile(
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
                                      SizedBox(height: 30,),
                                      ListTile(
                                        title: Text('Feedbacks', style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold)),
                                        subtitle: Column(
                                          children: [

                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          );
                        }
                      }
                  ),
                );
              }

              return Padding(
                padding: EdgeInsets.all(8),
                child: ExpansionTileCard(
                  //expandedColor: Colors.grey,
                  title: Text("${widget.courier.fName} ${widget.courier.lName}", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),),
                  leading: ClipOval(
                    child: SizedBox(
                      width: 48,
                      height: 48,
                      child: Container(
                        child: CircleAvatar(
                          radius: 20,
                          backgroundImage: NetworkImage(widget.courier.avatarUrl),
                          backgroundColor: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: EdgeInsets.only(top: 5),
                        child: Text.rich(
                          TextSpan(children: [
                            TextSpan(text: "Vehicle Type: ", style: Theme.of(context).textTheme.bodyText2.copyWith(fontWeight: FontWeight.bold)),
                            TextSpan(text: "${widget.courier.vehicleType}\n",style: Theme.of(context).textTheme.bodyText2),
                            TextSpan(text: "Delivery Fee: ", style: Theme.of(context).textTheme.bodyText2.copyWith(fontWeight: FontWeight.bold)),
                            TextSpan(text: "₱${deliveryFee.toInt()}\n",style: Theme.of(context).textTheme.bodyText2),
                            TextSpan(text: "Status: ", style: Theme.of(context).textTheme.bodyText2.copyWith(fontWeight: FontWeight.bold)),
                            TextSpan(text: "${widget.courier.status}", style: TextStyle(color: color, fontWeight: FontWeight.bold,)),
                          ],
                          ),
                        ),
                      ),
                      StreamBuilder <List<Delivery>>(
                          stream: DatabaseService().deliveryList,
                          builder: (context, snapshot) {
                            if(snapshot.hasData){
                              List<Delivery> deliveryData = snapshot.data;
                              double rating = 0.0;
                              double total = 0.0;
                              double stars = 0;


                              for(int i = 0; i < deliveryData.length; i++){
                                if(deliveryData[i].courierRef.id == widget.courier.uid && deliveryData[i].deliveryStatus == 'Delivered'){
                                  if(deliveryData[i].rating != 0 && deliveryData[i].feedback != ''){
                                    rating += deliveryData[i].rating;
                                    total++;
                                  }
                                }
                              };
                              stars = (rating/total);
                              return Column(
                                children: [
                                  Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: List.generate(5, (index) {
                                      return Icon(
                                        index < stars ? Icons.star : Icons.star_border, color: Colors.amber,
                                      );
                                    }),
                                  ),
                                ],
                              );
                            }
                            else return Container();
                          }
                      ),
                    ],
                  ),
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16.0,
                        vertical: 8.0,
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          ListTile(
                            leading: Icon(Icons.info_rounded, color: Colors.red),
                            title: Text('Additional Information', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                            subtitle: Container(
                              padding: EdgeInsets.only(top: 5),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text.rich(
                                    TextSpan(children: [
                                      TextSpan(text: "Contact Number: ", style: Theme.of(context).textTheme.bodyText2.copyWith(fontWeight: FontWeight.bold)),
                                      TextSpan(text: "${widget.courier.contactNo}\n",style: Theme.of(context).textTheme.bodyText2),
                                    ],
                                    ),
                                  ),
                                  Row(
                                    children: [
                                      Text('Vehicle Color:', style: Theme.of(context).textTheme.bodyText2.copyWith(fontWeight: FontWeight.bold)),
                                      Padding(
                                        padding: const EdgeInsets.only(left: 10),
                                        child: Container(
                                          width: 20,
                                          height: 20,
                                          decoration: BoxDecoration(
                                            border: Border.all(),
                                            shape: BoxShape.circle,
                                            color: Color(widget.courier.vehicleColor),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                          Stack(
                            children: [
                              Container(
                                child: const Center(child: CircularProgressIndicator(),),
                                height: 150,
                                width: 326,
                              ),
                              Container(
                                  padding: EdgeInsets.only(right: 40),
                                  child: Image.network(widget.courier.vehiclePhoto_, height: 140, width: 326,)
                              ),
                            ],
                          ),
                          SizedBox(height: 20,),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              Align(
                                child: Container(
                                  height: 25,
                                  child: ElevatedButton(
                                    child: Text('View Feedbacks', style: TextStyle(color: Colors.white, fontSize: 10),),
                                    onPressed: (){
                                      showMaterialModalBottomSheet(
                                        context: context,
                                        builder: (context) => SizedBox(height: 660, child: _bottomSheet()),
                                      );
                                    },
                                  ),
                                ),
                              ),
                              SizedBox(width: 10,),
                              Align(
                                child: Container(
                                    height: 25,
                                    child: ElevatedButton(
                                        child: Text('Request', style: TextStyle(color: Colors.white, fontSize: 10),),
                                        onPressed: /*widget.courier.status == "Offline" ? null :*/ () {

                                          Navigator.push(context, PageTransition(
                                              child: CustomerRemarks(
                                                courierUID: widget.courier.uid,
                                                pickupAddress: widget.pickupAddress,
                                                pickupCoordinates: widget.pickupCoordinates,
                                                dropOffAddress: widget.dropOffAddress,
                                                dropOffCoordinates: widget.dropOffCoordinates,
                                                deliveryFee: deliveryFee.toInt(),),
                                              type: PageTransitionType.bottomToTop
                                          ));
                                        }
                                    )
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            } else {
              return Padding(
                padding: EdgeInsets.all(8),
                child: ExpansionTileCard(
                  title: Text("Loading...", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),),
                  leading: ClipOval(
                    child: SizedBox(
                      width: 48,
                      height: 48,
                      child: Container(
                        child: CircleAvatar(
                          radius: 20,
                          backgroundColor: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  subtitle: Container(
                    padding: EdgeInsets.only(top: 5),
                    child: SizedBox(height: 20),
                  ),
                ),
              );
            }
          }
      );
    } else {
      return LoginScreen();
    }
  }
}