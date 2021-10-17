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

    bool licenseFront = false;
    bool licenseBack = false;
    bool nbiClearance = false;
    bool vehicleRegOR = false;
    bool vehicleRegCR = false;
    bool vehiclePhoto = false;

    bool approved = widget.courier.approved;
    List credentials = [licenseFront,licenseBack,nbiClearance,vehicleRegOR,vehicleRegCR,vehiclePhoto];

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
                // Credentials
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
                        onPressed: approved ? () async {
                          await DatabaseService(uid: widget.courier.uid).approveCourier(false);
                        } : () async {
                          await DatabaseService(uid: widget.courier.uid).approveCourier(true);
                        },
                        style: ElevatedButton.styleFrom(
                          primary: approved ? Colors.red : Colors.green,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(0)),
                        ),
                        child: Text(
                          approved ? "Disable" : "Approve",
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
                    !widget.courier.approved ? Container(
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
                                builder: (BuildContext context) => StatefulBuilder(
                                  builder: (context, setState){
                                    return AlertDialog(
                                        content: Column(
                                          crossAxisAlignment: CrossAxisAlignment.center,
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            ListTile(
                                              title: Text("Notify the Courier", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),),
                                            ),
                                            SizedBox(height: 20),
                                            SizedBox(
                                              width: 500,
                                              child: TextFormField(
                                                maxLines: 2,
                                                maxLength: 200,
                                                decoration: InputDecoration(
                                                  hintText: 'Type something',
                                                  border: OutlineInputBorder(),
                                                ),
                                                keyboardType: TextInputType.multiline,
                                                onChanged: (val) => setState(() => _adminMessage = val),
                                              ),
                                            ),
                                            Column(
                                              children: [
                                                SizedBox(height: 30),
                                                Text("Select the credential that is invalid.", style: TextStyle(fontWeight: FontWeight.bold),),
                                                CheckboxListTile(
                                                  title: Text('Driver\'s License Front'),
                                                  value: credentials[0],
                                                  onChanged: (bool value) {
                                                    setState(() {
                                                      credentials[0] = value;
                                                    });
                                                  },
                                                ),
                                                CheckboxListTile(
                                                  title: const Text('Driver\'s License Back'),
                                                  value: credentials[1],
                                                  onChanged: (bool value) {
                                                    setState(() {
                                                      credentials[1] = value;
                                                    });
                                                  },
                                                ),
                                                CheckboxListTile(
                                                  title: const Text('NBI Clearance'),
                                                  value: credentials[2],
                                                  onChanged: (bool value) {
                                                    setState(() {
                                                      credentials[2] = value;
                                                    });
                                                  },
                                                ),
                                                CheckboxListTile(
                                                  title: const Text('Vehicle Registration OR'),
                                                  value: credentials[3],
                                                  onChanged: (bool value) {
                                                    setState(() {
                                                      credentials[3] = value;
                                                    });
                                                  },
                                                ),
                                                CheckboxListTile(
                                                  title: const Text('Vehicle Registration CR'),
                                                  value: credentials[4],
                                                  onChanged: (bool value) {
                                                    setState(() {
                                                      credentials[4] = value;
                                                    });
                                                  },
                                                ),
                                                CheckboxListTile(
                                                  title: const Text('Vehicle Photo'),
                                                  value: credentials[5],
                                                  onChanged: (bool value) {
                                                    setState(() {
                                                      credentials[5] = value;
                                                    });
                                                  },
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),

                                        actions: [
                                          TextButton(
                                            child: Text("Send"),
                                            onPressed: () async {
                                              await DatabaseService(uid: widget.courier.uid).updateCourierMessage(_adminMessage);
                                              await DatabaseService(uid: widget.courier.uid).updateCredentials(credentials);
                                              Navigator.pop(context);
                                            },
                                          ),
                                        ]);
                                  },
                                )
                            );
                          },
                        ),
                    ) : Container(),
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