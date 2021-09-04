import 'package:flutter/material.dart';
import 'package:proxpress/couriers.dart';
import 'package:proxpress/database.dart';
import 'package:url_launcher/url_launcher.dart';

import 'auth.dart';

class CourierTile extends StatelessWidget {
  final Courier courier;
  String savedPassword;
  CourierTile({this.courier, this.savedPassword});

  @override
  Widget build(BuildContext context) {
    String driversLicenseFront_ = courier.driversLicenseFront_;
    String driversLicenseBack_ = courier.driversLicenseBack_;
    String nbiClearancePhoto_ = courier.nbiClearancePhoto_;
    String vehicleRegistrationOR_ = courier.vehicleRegistrationOR_;
    String vehicleRegistrationCR_ = courier.vehicleRegistrationCR_;
    String vehiclePhoto_ = courier.vehiclePhoto_;

    bool approved = courier.approved;

    final AuthService _auth = AuthService();

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 10),
      child: Table(
        border: TableBorder.all(),
        children: [
          TableRow(
            children: [
              Align(child: Text("${courier.fName} ${courier.lName}")),
              Align(child: Text(courier.address)),
              Align(child: Text(courier.email)),
              Align(child: Text(courier.contactNo)),
              Align(child: Text(courier.vehicleType)),
              Align(child: Text(courier.vehicleColor)),
              Align(
                child: Column(
                  children: [
                    InkWell(
                      child: new Text('Driver\'s License Front', style: TextStyle(color: Colors.blue, decoration: TextDecoration.underline,),),
                      onTap: () => launch(driversLicenseFront_),
                    ),
                    InkWell(
                      child: new Text('Driver\'s License Back', style: TextStyle(color: Colors.blue, decoration: TextDecoration.underline,),),
                      onTap: () => launch(driversLicenseBack_),
                    ),
                    InkWell(
                      child: new Text('NBI Clearance', style: TextStyle(color: Colors.blue, decoration: TextDecoration.underline,),),
                      onTap: () => launch(nbiClearancePhoto_),
                    ),
                    InkWell(
                      child: new Text('Vehicle Registration OR', style: TextStyle(color: Colors.blue, decoration: TextDecoration.underline,),),
                      onTap: () => launch(vehicleRegistrationOR_),
                    ),
                    InkWell(
                      child: new Text('Vehicle Registration CR', style: TextStyle(color: Colors.blue, decoration: TextDecoration.underline,),),
                      onTap: () => launch(vehicleRegistrationCR_),
                    ),
                    InkWell(
                      child: new Text('Vehicle Photo', style: TextStyle(color: Colors.blue, decoration: TextDecoration.underline,),),
                      onTap: () => launch(vehiclePhoto_),
                    ),
                  ],
                ),
              ),
              Align(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Container(
                      margin: EdgeInsets.all(10),
                      child: ElevatedButton(
                        onPressed: approved ? null : () async {
                          await DatabaseService(uid: courier.uid).approveCourier();
                        },
                        style: ElevatedButton.styleFrom(
                          primary: Colors.green,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(0)),
                        ),
                        child: Text(
                          "Approve",
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 18
                          ),
                        ),
                      ),
                    ),
                    Container(
                      margin: EdgeInsets.all(10),
                      child: ElevatedButton(
                        onPressed: () async {
                          showDialog(
                              context: context,
                              builder: (BuildContext context) => AlertDialog(
                                      content: Text(
                                          "Delete courier?"),
                                      actions: [
                                        TextButton(
                                          child: Text("Yes"),
                                          onPressed: () async {
                                            await _auth.deleteUser(courier.email, courier.password, savedPassword);
                                            Navigator.pop(context);
                                          },
                                        ),
                                        TextButton(
                                          child: Text("No"),
                                          onPressed: () {
                                            Navigator.pop(context);
                                          },
                                        ),
                                      ])
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          primary: Colors.red,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(0)),
                        ),
                        child: Text(
                          "Delete",
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 18
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}