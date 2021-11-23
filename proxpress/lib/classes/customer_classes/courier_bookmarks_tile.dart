import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:page_transition/page_transition.dart';
import 'package:proxpress/UI/CustomerUI/customer_remarks.dart';
import 'package:proxpress/classes/customer_classes/pin_widget.dart';
import 'package:proxpress/classes/customer_classes/view_courier_profile.dart';
import 'package:proxpress/models/couriers.dart';
import 'package:proxpress/models/customers.dart';
import 'package:proxpress/models/deliveries.dart';
import 'package:proxpress/models/delivery_prices.dart';
import 'package:proxpress/services/database.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';

class CourierBookmarkTile extends StatefulWidget {
  final bool appear;

  CourierBookmarkTile({
    Key key,
    @required this.appear
  }) : super(key: key);

  @override
  _CourierBookmarkTileState createState() => _CourierBookmarkTileState();
}

class _CourierBookmarkTileState extends State<CourierBookmarkTile> {
  bool show = false;
  String deliveryPriceUid;
  double deliveryFee = 0.0;
  bool bottomSheetControl = false;
  bool temp = false;
  final GlobalKey<FormState> locKey = GlobalKey<FormState>();
  final textFieldPickup = TextEditingController();
  final textFieldDropOff = TextEditingController();
  double distance = 0.0;
  String pickupAddress;
  GeoPoint pickupCoordinates;
  String dropOffAddress;
  GeoPoint dropOffCoordinates;
  double tempD = 0.0;
  String tempPA;
  GeoPoint tempPC;
  String tempDA;
  GeoPoint tempDC;

  @override
  Widget build(BuildContext context) {
    final FirebaseAuth _auth = FirebaseAuth.instance;
    User user = _auth.currentUser;

    if (user != null) {
      return StreamBuilder<Customer>(
        stream: DatabaseService(uid: user.uid).customerData,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            Customer customer = snapshot.data;

            Map<String, DocumentReference> localBookmarks;
            List<DocumentReference> courierRefs;

            if (customer.courier_ref != null) {
              localBookmarks = Map<String, DocumentReference>.from(customer.courier_ref);
              courierRefs = localBookmarks.values.toList();
            } else {
              localBookmarks = {};
              courierRefs = [];
            }

            if (courierRefs.length == 0) {
              return Row(
                children: [
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Text('You currently have no bookmarked couriers.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 18,
                        ),
                      ),
                    ),
                  ),
                ],
              );
            } else {
              return ListView.builder(
                physics: NeverScrollableScrollPhysics(),
                shrinkWrap: true,
                itemCount: courierRefs.length,
                itemBuilder: (context, index) {
                  return Container(
                    decoration: new BoxDecoration(color: Colors.black.withOpacity(0)),
                    child: StreamBuilder<Courier>(
                      stream: DatabaseService(uid: courierRefs[index].id).courierData,
                      builder: (context, snapshot) {
                        if (snapshot.hasData) {
                          Courier courier = snapshot.data;
                          deliveryPriceUid = courier.deliveryPriceRef.id;

                          var color;
                          if (courier.status == "Offline") {
                            color = Colors.redAccent;
                          } else {
                            color = Colors.green;
                          }
                          return StreamBuilder<DeliveryPrice>(
                              stream: DatabaseService(uid: deliveryPriceUid).deliveryPriceData,
                              builder: (context, snapshot) {
                                DeliveryPrice deliveryPriceData = snapshot.data;

                                if (temp)
                                  deliveryFee = (deliveryPriceData.baseFare.toDouble() + (deliveryPriceData.farePerKM.toDouble() * distance));

                                if (snapshot.hasData) {
                                  return Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child:Card(
                                      child: InkWell(
                                        onTap : () {
                                          Navigator.push(context, PageTransition(
                                              child: ViewCourierProfile(
                                                courierUID: courier.uid,
                                              ),
                                              type: PageTransitionType.fade
                                          ));
                                        },
                                        child: Column(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            ListTile(
                                              isThreeLine: true,
                                              leading: ClipOval(
                                                child: SizedBox(
                                                  width: 48,
                                                  height: 48,
                                                  child: Container(
                                                    child: CircleAvatar(
                                                      radius: 20,
                                                      backgroundImage: NetworkImage(courier.avatarUrl),
                                                      backgroundColor: Colors.white,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                              title: Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  Text("${courier.fName} ${courier.lName}", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),),
                                                  StreamBuilder <List<Delivery>>(
                                                      stream: DatabaseService().deliveryList,
                                                      builder: (context, snapshot) {
                                                        if (snapshot.hasData) {
                                                          List<Delivery> deliveryData = snapshot.data;
                                                          double rating = 0.0;
                                                          double total = 0.0;
                                                          double stars = 0;


                                                          for(int i = 0; i < deliveryData.length; i++) {
                                                            if (deliveryData[i].courierRef.id == courier.uid && deliveryData[i].deliveryStatus == 'Delivered') {
                                                              if (deliveryData[i].rating != 0 && deliveryData[i].feedback != '') {
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
                                                        } else return Container();
                                                      }
                                                  ),
                                                ],
                                              ),
                                              subtitle: Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  Row(
                                                    children: [
                                                      Text('Vehicle Type: ', style: TextStyle(color: Colors.black),),
                                                      Text('${courier.vehicleType}'),
                                                    ],
                                                  ),
                                                  Row(
                                                    children: [
                                                      Text('Delivery Fee: ', style: TextStyle(color: Colors.black),),
                                                      Text('₱${deliveryFee.toInt()}.00', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
                                                    ],
                                                  ),
                                                ],
                                              ),
                                              trailing: Column(
                                                children: [
                                                  Text('${courier.status}', style: TextStyle(color: color, fontWeight: FontWeight.bold,)),
                                                  Padding(
                                                    padding: const EdgeInsets.symmetric(vertical: 8),
                                                    child: Icon(Icons.info_outline_rounded, color: Colors.red),
                                                  ),
                                                ],
                                              ),
                                            ),
                                            Divider(
                                              color: Colors.grey,
                                              thickness: .5,
                                            ),
                                            Wrap(
                                              children: [
                                                Padding(
                                                  padding: const EdgeInsets.only(right: 100),
                                                  child: TextButton(
                                                    child: Text('REMOVE'),
                                                    onPressed: () {
                                                      showDialog(
                                                          context: context,
                                                          builder: (BuildContext context) {
                                                            return AlertDialog(
                                                              content: Text('Are you sure you want to remove this courier from your bookmarks?'),
                                                              actions: [
                                                                Row(
                                                                  mainAxisAlignment: MainAxisAlignment.center,
                                                                  children: [
                                                                    TextButton(
                                                                      style: TextButton.styleFrom(
                                                                        side: BorderSide(color: Colors.red),
                                                                      ),
                                                                      child: Text("YES"),
                                                                      onPressed: () async {
                                                                        Map<String, DocumentReference> localBookmarks = Map<String, DocumentReference>.from(customer.courier_ref);
                                                                        Map<String, DocumentReference> newBookmarks = {};

                                                                        DocumentReference courierToRemove = FirebaseFirestore.instance.collection('Couriers').doc(courier.uid);

                                                                        localBookmarks.removeWhere((key, value) => value == courierToRemove);

                                                                        int i = 0;
                                                                        localBookmarks.forEach((key, value) {
                                                                          newBookmarks.addAll({"Courier$i": value});
                                                                          i++;
                                                                        });

                                                                        await DatabaseService(uid: customer.uid).updateCustomerCourierRef(newBookmarks);

                                                                        Navigator.of(context).pop();
                                                                      },
                                                                    ),
                                                                    TextButton(
                                                                      child: Text("NO"),
                                                                      onPressed: () {
                                                                        Navigator.of(context).pop();
                                                                      },
                                                                    ),
                                                                  ],
                                                                ),
                                                              ],
                                                            );
                                                          }
                                                      );
                                                    },
                                                  ),
                                                ),
                                                TextButton(
                                                  child: const Text('PIN LOCATION'),
                                                  onPressed: /*widget.courier.status == "Offline" ? null :*/ () async {
                                                    await showMaterialModalBottomSheet(
                                                      context: context,
                                                      builder: (context) => Container(
                                                          height: MediaQuery.of(context).size.height * .8,
                                                          child: Column(
                                                            mainAxisAlignment: MainAxisAlignment.center,
                                                            children: [
                                                              PinLocation(
                                                                locKey: locKey,
                                                                textFieldPickup: textFieldPickup,
                                                                textFieldDropOff: textFieldDropOff,
                                                                isBookmarks: true,
                                                              ),
                                                            ],
                                                          )
                                                      ),
                                                    ).then((value) {
                                                      LocalDataBookmark localDataBookmark = value;
                                                      if (value != null) {
                                                        show = localDataBookmark.appear;
                                                        tempD = localDataBookmark.distance;
                                                        tempPA = localDataBookmark.pickupAddress;
                                                        tempPC = GeoPoint(localDataBookmark.pickupCoordinates.latitude, localDataBookmark.pickupCoordinates.longitude);
                                                        tempDA = localDataBookmark.dropOffAddress;
                                                        tempDC = GeoPoint(localDataBookmark.dropOffCoordinates.latitude, localDataBookmark.dropOffCoordinates.longitude);
                                                      }
                                                    });

                                                    setState(() {
                                                      temp = show;
                                                      distance = tempD;
                                                      pickupAddress = tempPA;
                                                      pickupCoordinates = tempPC;
                                                      dropOffAddress = tempDA;
                                                      dropOffCoordinates = tempDC;
                                                    });
                                                  },
                                                ),
                                                TextButton(
                                                  child: const Text('REQUEST'),
                                                  onPressed: !temp ? null : () {
                                                    Navigator.push(context, PageTransition(
                                                        child: CustomerRemarks(
                                                          courierUID: courierRefs[index].id,
                                                          pickupAddress: pickupAddress,
                                                          pickupCoordinates: pickupCoordinates,
                                                          dropOffAddress: dropOffAddress,
                                                          dropOffCoordinates: dropOffCoordinates,
                                                          deliveryFee: deliveryFee.toInt(),),
                                                        type: PageTransitionType.bottomToTop
                                                    ));
                                                  },
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  );
                                } else {
                                  return Container();
                                }
                              }
                          );
                        } else {
                          return Container();
                        }
                      }
                    ),
                  );
                }
              );
            }
          } else {
            return Container();
          }
        }
      );
    } else {
      return Container();
    }
  }
}