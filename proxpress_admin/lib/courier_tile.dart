import 'package:flutter/material.dart';
import 'package:proxpress/couriers.dart';
import 'package:proxpress/database.dart';
import 'package:url_launcher/url_launcher.dart';

import 'auth.dart';

class CourierTile extends StatefulWidget {
  final Courier courier;
  String savedPassword;
  CourierTile({this.courier, this.savedPassword});

  @override
  State<CourierTile> createState() => _CourierTileState();
}

class _CourierTileState extends State<CourierTile> {
  @override
  Widget build(BuildContext context) {
    String driversLicenseFront_ = widget.courier.driversLicenseFront_;
    String driversLicenseBack_ = widget.courier.driversLicenseBack_;
    String nbiClearancePhoto_ = widget.courier.nbiClearancePhoto_;
    String vehicleRegistrationOR_ = widget.courier.vehicleRegistrationOR_;
    String vehicleRegistrationCR_ = widget.courier.vehicleRegistrationCR_;
    String vehiclePhoto_ = widget.courier.vehiclePhoto_;

    bool approved = widget.courier.approved;

    final AuthService _auth = AuthService();

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 10),
      child: Table(
        border: TableBorder.all(),
        children: [
          TableRow(
            children: [
              Align(child: Text("${widget.courier.fName} ${widget.courier.lName}")),
              Align(child: Text(widget.courier.address)),
              Align(child: Text(widget.courier.email)),
              Align(child: Text(widget.courier.contactNo)),
              Align(child: Text(widget.courier.vehicleType)),
              Align(child: Text(widget.courier.vehicleColor)),
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
                          await DatabaseService(uid: widget.courier.uid).approveCourier();
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
                                            await _auth.deleteUser(widget.courier.email, widget.courier.password, widget.savedPassword);
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
                    Container(
                      margin: EdgeInsets.all(10),
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            primary: Colors.blue,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(0)),
                          ),
                          child: Text('Notify Reason'),
                          onPressed: () {
                            String _adminMessage = " ";
                            showDialog(
                                context: context,
                                builder: (BuildContext context) => AlertDialog(
                                    content: Column(
                                      crossAxisAlignment: CrossAxisAlignment.center,
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Text("Notify the courier for the reason of rejection"),
                                        TextFormField(
                                          maxLines: 2,
                                          maxLength: 200,
                                          decoration: InputDecoration(
                                            border: OutlineInputBorder(),
                                          ),
                                          keyboardType: TextInputType.multiline,
                                          onChanged: (val) => setState(() => _adminMessage = val),
                                        ),
                                      ],
                                    ),

                                    actions: [
                                      TextButton(
                                        child: Text("Send"),
                                        onPressed: () async {
                                          await DatabaseService(uid: widget.courier.uid).updateCourierMessage(_adminMessage);
                                          Navigator.pop(context);
                                        },
                                      ),
                                    ])
                            );
                          },
                        ),
                    )
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