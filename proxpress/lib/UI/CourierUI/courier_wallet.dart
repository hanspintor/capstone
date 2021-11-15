import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:proxpress/models/couriers.dart';
import 'package:proxpress/services/database.dart';

class CourierWallet extends StatefulWidget {
  const CourierWallet({Key key}) : super(key: key);

  @override
  _CourierWalletState createState() => _CourierWalletState();
}

class _CourierWalletState extends State<CourierWallet> {
  @override
  Widget build(BuildContext context) {
    final FirebaseAuth _auth = FirebaseAuth.instance;
    User user = _auth.currentUser;

    return StreamBuilder<Courier>(
      stream: DatabaseService(uid: user.uid).courierData,
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          Courier courier = snapshot.data;

          return Center(
            child: Column(
              children: [
                SizedBox(height: 10,),
                Container(
                  width: MediaQuery.of(context).size.width * .95,
                  height: MediaQuery.of(context).size.height * .30,
                  child: Card(
                    elevation: 5,
                    child: Padding(
                      padding: const EdgeInsets.all(40),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Balance', style: TextStyle(color: Colors.grey),),
                          Text('\₱${courier.wallet}', style: TextStyle(fontSize: 40),), // ${customer.wallet}
                          ElevatedButton(
                            onPressed: courier.requestedCashout ? null : () async {
                              await DatabaseService(uid: user.uid).courierRequestCashout(true);
                              showToast('Request sent');
                            },
                            child: Text('Request Cash-out'),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                courier.requestedCashout ? Container(
                  width: MediaQuery.of(context).size.width * .95,
                  child: Card(
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text('You have recently requested for a cash-out. Please wait for the admin to handle your request.'),
                    )
                  ),
                ) : Container(),
              ],
            ),
          );
        } else {
          return Container();
        }
      }
    );
  }

  Future showToast(String message) async {
    await Fluttertoast.cancel();
    Fluttertoast.showToast(msg: message, fontSize: 18, backgroundColor: Colors.green, textColor: Colors.white);
  }
}