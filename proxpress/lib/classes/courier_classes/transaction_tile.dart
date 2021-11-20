import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:page_transition/page_transition.dart';
import 'package:proxpress/UI/login_screen.dart';
import 'package:proxpress/classes/view_delivery_details.dart';
import 'package:proxpress/models/customers.dart';
import 'package:proxpress/models/deliveries.dart';
import 'package:proxpress/services/database.dart';
import 'package:intl/intl.dart';

class TransactionTile extends StatefulWidget {
  final Delivery delivery;
  final int index;

  TransactionTile({
    Key key,
    @required this.delivery,
    @required this.index,
  }) : super(key: key);

  @override
  State<TransactionTile> createState() => _TransactionTileState();
}

class _TransactionTileState extends State<TransactionTile> {
  @override
  Widget build(BuildContext context) {
    final FirebaseAuth _auth = FirebaseAuth.instance;
    User user = _auth.currentUser;

    if (user != null) {
      if (widget.index == 0) {
        int rating = widget.delivery.rating;

        return Padding(
          padding: const EdgeInsets.all(8.0),
          child: StreamBuilder<Customer>(
              stream: DatabaseService(uid: widget.delivery.customerRef.id).customerData,
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  Customer customerData = snapshot.data;
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 5),
                    child: Card(
                      child: InkWell(
                        onTap: () {
                          Navigator.push(context, PageTransition(child: DeliveryDetails(
                            customer: widget.delivery.customerRef,
                            courier: widget.delivery.courierRef,
                            pickupAddress: widget.delivery.pickupAddress,
                            pickupGeoPoint: widget.delivery.pickupCoordinates,
                            dropOffAddress: widget.delivery.dropOffAddress,
                            dropOffGeoPoint: widget.delivery.dropOffCoordinates,
                            itemDescription: widget.delivery.itemDescription,
                            pickupPointPerson: widget.delivery.pickupPointPerson ,
                            pickupContactNum: widget.delivery.pickupContactNum ,
                            dropOffPointPerson: widget.delivery.dropoffPointPerson ,
                            dropOffContactNum: widget.delivery.dropoffContactNum ,
                            whoWillPay: widget.delivery.whoWillPay ,
                            specificInstructions: widget.delivery.specificInstructions ,
                            paymentOption: widget.delivery.paymentOption ,
                            deliveryFee: widget.delivery.deliveryFee ,
                          ),
                              type: PageTransitionType.rightToLeftWithFade));
                        },
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: <Widget>[
                            Align(
                              alignment: Alignment.topLeft,
                              child: Padding(
                                padding: const EdgeInsets.only(top: 10, left: 5),
                                child: Text('${DateFormat.yMd().add_jm().format(widget.delivery.time.toDate())}', style: TextStyle(color: Colors.grey)),
                              ),
                            ),
                            Divider(
                              color: Colors.grey,
                              thickness: .5,
                            ),
                            ListTile(
                              isThreeLine: true,
                              leading: Container(
                                child: CircleAvatar(
                                  radius: 20,
                                  backgroundImage: NetworkImage(customerData.avatarUrl),
                                  backgroundColor: Colors.white,
                                ),
                              ),
                              title: Text("${customerData.fName} ${customerData.lName}",
                                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black),),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      ListTile(
                                        title: Text("Rating", style: TextStyle(fontWeight: FontWeight.bold),),
                                        subtitle: Container(
                                          padding: EdgeInsets.only(top: 5),
                                          child: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: List.generate(5, (index) {
                                              return Icon(
                                                index < rating ? Icons.star : Icons.star_border, color: Colors.amber,
                                              );
                                            }),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text('Feedback:',style: TextStyle(color: Colors.black),),
                                        Text(widget.delivery.feedback),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              trailing: Icon(Icons.info_outline_rounded, color: Colors.red,),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                } else return Container();
              }
          ),
        );
      } else if (widget.index == 1) {
        return Padding(
          padding: const EdgeInsets.all(8.0),
          child: StreamBuilder<Customer>(
            stream: DatabaseService(uid: widget.delivery.customerRef.id).customerData,
            builder: (context,snapshot) {
              if (snapshot.hasData) {
                Customer customerData = snapshot.data;

                String status = '';

                if (widget.delivery.courierApproval.contains("Courier")) {
                  status = 'Rejected by You';
                } else {
                  status = widget.delivery.courierApproval;
                }

                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 5),
                  child: Card(
                    child: InkWell(
                      onTap: () {
                        Navigator.push(context, PageTransition(child: DeliveryDetails(
                          customer: widget.delivery.customerRef,
                          courier: widget.delivery.courierRef,
                          pickupAddress: widget.delivery.pickupAddress,
                          pickupGeoPoint: widget.delivery.pickupCoordinates,
                          dropOffAddress: widget.delivery.dropOffAddress,
                          dropOffGeoPoint: widget.delivery.dropOffCoordinates,
                          itemDescription: widget.delivery.itemDescription,
                          pickupPointPerson: widget.delivery.pickupPointPerson ,
                          pickupContactNum: widget.delivery.pickupContactNum ,
                          dropOffPointPerson: widget.delivery.dropoffPointPerson ,
                          dropOffContactNum: widget.delivery.dropoffContactNum ,
                          whoWillPay: widget.delivery.whoWillPay ,
                          specificInstructions: widget.delivery.specificInstructions ,
                          paymentOption: widget.delivery.paymentOption ,
                          deliveryFee: widget.delivery.deliveryFee ,
                        ),
                            type: PageTransitionType.rightToLeftWithFade));
                      },
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          Align(
                            alignment: Alignment.topLeft,
                            child: Padding(
                              padding: const EdgeInsets.only(top: 10, left: 5),
                              child: Text('${DateFormat.yMd().add_jm().format(widget.delivery.time.toDate())}', style: TextStyle(color: Colors.grey)),
                            ),
                          ),
                          Divider(
                            color: Colors.grey,
                            thickness: .5,
                          ),
                          ListTile(
                            isThreeLine: true,
                            leading: Container(
                              child: CircleAvatar(
                                radius: 20,
                                backgroundImage: NetworkImage(customerData.avatarUrl),
                                backgroundColor: Colors.white,
                              ),
                            ),
                            title: Text("${customerData.fName} ${customerData.lName}",
                              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black),),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(status, style: TextStyle(color: Colors.red),),
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text('Cancellation Reason:',style: TextStyle(color: Colors.black),),
                                      Text(widget.delivery.cancellationMessage),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            trailing: Icon(Icons.info_outline_rounded, color: Colors.red,),
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
          )
        );
      } else {
        return Container();
      }
    } else {
      return LoginScreen();
    }
  }
}