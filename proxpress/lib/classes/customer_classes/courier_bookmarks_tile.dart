import 'dart:ui';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:proxpress/Load/user_load.dart';
import 'package:proxpress/UI/CustomerUI/customer_remarks.dart';
import 'package:proxpress/UI/login_screen.dart';
import 'package:proxpress/classes/customer_classes/pin_widget.dart';
import 'package:proxpress/models/couriers.dart';
import 'package:proxpress/models/customers.dart';
import 'package:proxpress/models/delivery_prices.dart';
import 'package:proxpress/services/database.dart';
import 'package:expansion_tile_card/expansion_tile_card.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:proxpress/classes/customer_classes/pin_widget.dart';

class CourierBookmarkTile extends StatefulWidget {

  final bool appear;
  CourierBookmarkTile(
      {Key key,
      @required this.appear})
      : super(key: key);

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
  LatLng pickupCoordinates;
  String dropOffAddress;
  LatLng dropOffCoordinates;
  double tempD = 0.0;
  String tempPA;
  LatLng tempPC;
  String tempDA;
  LatLng tempDC;


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

            Map<String, DocumentReference> localBookmarks = Map<String, DocumentReference>.from(customer.courier_ref);

            List<DocumentReference> courierRefs = localBookmarks.values.toList();

            if(courierRefs.length == 0){
              return Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                   Container(
                     child: Text(
                        "You currently have no courier bookmarks",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                   ),

                ],
              );
            } else{
              return Stack(
                alignment: Alignment.center,
                children: [
                  ListView.builder(
                      physics: NeverScrollableScrollPhysics(),
                      shrinkWrap: true,
                      itemCount: courierRefs.length,
                      itemBuilder: (context, index) {
                        return Stack(

                          children: [
                            Container(
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

                                            if(temp)
                                              deliveryFee = (deliveryPriceData.baseFare.toDouble() + (deliveryPriceData.farePerKM.toDouble() * distance));

                                            if(snapshot.hasData){
                                              return Padding(
                                                padding: EdgeInsets.all(8),
                                                child: ExpansionTileCard(
                                                  //expandedColor: Colors.grey,
                                                  title: Text(
                                                    "${courier.fName} ${courier.lName}",
                                                    style: TextStyle(
                                                        fontSize: 20, fontWeight: FontWeight.bold),
                                                  ),
                                                  leading: ClipOval(
                                                    child: SizedBox(
                                                      width: 48,
                                                      height: 48,
                                                      child: Container(
                                                        child: CircleAvatar(
                                                          radius: 20,
                                                          backgroundImage:
                                                          NetworkImage(courier.avatarUrl),
                                                          backgroundColor: Colors.white,
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                  subtitle: Container(
                                                    padding: EdgeInsets.only(top: 5),
                                                    child: Text.rich(
                                                      TextSpan(
                                                        children: [
                                                          TextSpan(text: "Vehicle Type: ", style: Theme.of(context).textTheme.bodyText2.copyWith(fontWeight: FontWeight.bold)),
                                                          TextSpan(text: "${courier.vehicleType}\n", style: Theme.of(context).textTheme.bodyText2),
                                                          if(temp)
                                                            TextSpan(text: "Delivery Fee: ", style: Theme.of(context).textTheme.bodyText2.copyWith(fontWeight: FontWeight.bold)),
                                                          if(temp)
                                                            TextSpan(text: "₱${deliveryFee.toInt()}\n", style: Theme.of(context).textTheme.bodyText2),
                                                          TextSpan(text: "Status: ", style: Theme.of(context).textTheme.bodyText2.copyWith(fontWeight: FontWeight.bold)),
                                                          TextSpan(text: "${courier.status}", style: TextStyle(color: color, fontWeight: FontWeight.bold,)),
                                                        ],
                                                      ),
                                                    ),
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
                                                            leading: Icon(Icons.info_rounded,
                                                                color: Colors.red),
                                                            title: Text('Additional Information',
                                                                style: TextStyle(
                                                                    fontSize: 20,
                                                                    fontWeight: FontWeight.bold)),
                                                            subtitle: Container(
                                                              padding: EdgeInsets.only(top: 5),
                                                              child: Text.rich(
                                                                TextSpan(
                                                                  children: [
                                                                    TextSpan(
                                                                        text: "Contact Number: ",
                                                                        style: Theme.of(context)
                                                                            .textTheme
                                                                            .bodyText2
                                                                            .copyWith(
                                                                            fontWeight:
                                                                            FontWeight
                                                                                .bold)),
                                                                    TextSpan(
                                                                        text:
                                                                        "${courier.contactNo}\n",
                                                                        style: Theme.of(context)
                                                                            .textTheme
                                                                            .bodyText2),
                                                                    TextSpan(
                                                                        text: "Vehicle Color: ",
                                                                        style: Theme.of(context)
                                                                            .textTheme
                                                                            .bodyText2
                                                                            .copyWith(
                                                                            fontWeight:
                                                                            FontWeight
                                                                                .bold)),
                                                                    TextSpan(
                                                                        text:
                                                                        "${courier.vehicleColor}\n",
                                                                        style: Theme.of(context)
                                                                            .textTheme
                                                                            .bodyText2),
                                                                  ],
                                                                ),
                                                              ),
                                                            ),
                                                          ),
                                                          Stack(
                                                            children: [
                                                              Container(
                                                                child: const Center(
                                                                  child:
                                                                  CircularProgressIndicator(),
                                                                ),
                                                                height: 150,
                                                                width: 326,
                                                              ),
                                                              Container(
                                                                  padding:
                                                                  EdgeInsets.only(right: 40),
                                                                  child: Image.network(
                                                                    courier.vehiclePhoto_,
                                                                    height: 140,
                                                                    width: 326,
                                                                  )),
                                                            ],
                                                          ),
                                                          SizedBox(
                                                            height: 20,
                                                          ),
                                                          Row(
                                                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                                            children: [
                                                              Container(

                                                                  height: 25,
                                                                  child: ElevatedButton(
                                                                      child: Text('Pin Location', style: TextStyle(color: Colors.white, fontSize: 10),),
                                                                      onPressed: /*widget.courier.status == "Offline" ? null :*/ () async {
                                                                        print("check ${widget.appear}");
                                                                        await showMaterialModalBottomSheet(
                                                                          context: context,
                                                                          builder: (context) => Container(
                                                                              height: 300,
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
                                                                          if(value != null){
                                                                            show = localDataBookmark.appear;
                                                                            print("Outside then: ${show}");
                                                                            tempD = localDataBookmark.distance;
                                                                            print("Outside then: ${tempD}");
                                                                            tempPA = localDataBookmark.pickupAddress;
                                                                            print("Outside then: ${tempPA}");
                                                                            tempPC = localDataBookmark.pickupCoordinates;
                                                                            print("Outside then: ${tempPC}");
                                                                            tempDA = localDataBookmark.dropOffAddress;
                                                                            print("Outside then: ${tempDA}");
                                                                            tempDC = localDataBookmark.dropOffCoordinates;
                                                                            print("Outside then: ${tempDC}");
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

                                                                      }
                                                                  )
                                                              ),
                                                              Container(
                                                                  height: 25,
                                                                  child: ElevatedButton(
                                                                      child: Text('Request', style: TextStyle(color: Colors.white, fontSize: 10),),
                                                                      onPressed: !temp ? null : () {
                                                                        Navigator.push(context, MaterialPageRoute(builder: (context) =>
                                                                            CustomerRemarks(
                                                                              courierUID: courierRefs[index].id,
                                                                              pickupAddress: pickupAddress,
                                                                              pickupCoordinates: pickupCoordinates,
                                                                              dropOffAddress: dropOffAddress,
                                                                              dropOffCoordinates: dropOffCoordinates,
                                                                              deliveryFee: deliveryFee.toInt(),),
                                                                        ));
                                                                      }
                                                                  )
                                                              ),
                                                            ],
                                                          )
                                                        ],
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              );
                                            } else{
                                              return Container();
                                            }
                                          }
                                      );
                                    } else {
                                      return Container();
                                    }
                                  }),
                            ),
                          ],
                        );
                      }
                  ),

                ],
              );
            }


            return Container();
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