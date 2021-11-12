import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:page_transition/page_transition.dart';
import 'package:paymongo_sdk/paymongo_sdk.dart';
import 'package:proxpress/UI/CustomerUI/top_up_page.dart';
import 'package:proxpress/models/couriers.dart';
import 'package:proxpress/models/customers.dart';
import 'package:proxpress/services/database.dart';
import 'package:webview_flutter/webview_flutter.dart';

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
                child: StreamBuilder<Courier>(
                    stream: DatabaseService(uid: user.uid).courierData,
                    builder: (context, snapshot) {
                      if (snapshot.hasData) {
                        Courier courier = snapshot.data;

                        return Column(
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
                        );
                      } else {
                        return Container();
                      }
                    }
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future showToast(String message) async {
    await Fluttertoast.cancel();
    Fluttertoast.showToast(msg: message, fontSize: 18, backgroundColor: Colors.green, textColor: Colors.white);
  }
}