import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:proxpress/Load/user_load.dart';
import 'package:proxpress/services/database.dart';
import 'package:proxpress/models/user.dart';
import 'package:provider/provider.dart';
import 'package:proxpress/models/customers.dart';
import  'package:proxpress/UI/notif_drawer.dart';



class CustomerUpdate extends StatefulWidget {

  @override
  _CustomerUpdateState createState() => _CustomerUpdateState();
}

class _CustomerUpdateState extends State<CustomerUpdate> {
  void _openEndDrawer() {
    _scaffoldKey.currentState.openEndDrawer();
  }

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final GlobalKey<FormState> _updateKey = GlobalKey<FormState>();

  String _currentFName;
  String _currentLName;
  String _currentAddress;
  String _currentEmail;
  String _currentContactNo;
  String _currentPassword;
  String _confirmPassword;


  @override
  Widget build(BuildContext context) {
    final user = Provider.of<TheUser>(context);

    return Scaffold(
        drawerEnableOpenDragGesture: false,
        endDrawerEnableOpenDragGesture: false,
        key:_scaffoldKey,
        appBar: AppBar(
          backgroundColor: Colors.white,
          iconTheme: IconThemeData(color: Color(0xfffb0d0d),),
          leading: IconButton(icon: Icon(
            Icons.arrow_back,
          ),
            onPressed: (){
              Navigator.pop(context, false);
            },
            iconSize: 25,
          ),
          actions: [
            IconButton(icon: Icon(
              Icons.notifications_none_rounded,
            ),
              onPressed: (){
                _openEndDrawer();
              },
              iconSize: 25,
            ),
          ],
          flexibleSpace: Container(
            margin: EdgeInsets.only(top: 10),
            child: Image.asset(
              "assets/PROExpress-logo.png",
              height: 120,
              width: 120,
            ),
          ),
          //title: Text("PROExpress"),
        ),
        endDrawer: NotifDrawer(),
        body: SingleChildScrollView(
          child: StreamBuilder<Customer>(
              stream: DatabaseService(uid: user.uid).customerData,
              builder: (context,snapshot){
                if(snapshot.hasData){
                  Customer customerData = snapshot.data;

                  return Form(
                    key: _updateKey,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Container(
                          // temporary not yet configured
                          child: Align(
                            alignment: Alignment.bottomCenter,
                            child: Text(
                              "Edit Profile",
                              style: TextStyle(
                                fontSize: 25,
                              ),
                            ),
                          ),
                        ),
                        Container(
                          child: TextFormField(
                            decoration: InputDecoration(labelText: 'First Name:'),
                            validator: (String val) => val.isEmpty ? 'Enter your new first name' : null,
                            initialValue: "${customerData.fName}",
                            onChanged: (val) => setState(() => _currentFName = val),
                          ),
                        ),
                        Container(
                          child: TextFormField(
                            decoration: InputDecoration(labelText: 'Last Name:'),
                            validator: (String val) => val.isEmpty ? 'Enter your new last name' : null,
                            initialValue: "${customerData.lName}",
                            onChanged: (val) => setState(() => _currentLName = val),
                          ),
                        ),
                        Container(
                          child: TextFormField(
                            decoration: InputDecoration(labelText: 'Address:'),
                            keyboardType: TextInputType.streetAddress,
                            validator: (String val) => val.isEmpty ? 'Enter your new address' : null,
                            initialValue: "${customerData.address}",
                            onChanged: (val) => setState(() => _currentAddress = val),
                          ),
                        ),
                        Container(
                          child: TextFormField(
                            decoration: InputDecoration(labelText: 'Email:'),
                            validator: (String val){
                              if(val.isEmpty){
                                return 'Email is Required';
                              }
                              else if (!RegExp(r"[a-z0-9!#$%&'*+/=?^_`{|}~-]+(?:\.[a-z0-9!#$%&'*+/=?^_`{|}~-]+)*@(?:[a-z0-9](?:[a-z0-9-]*[a-z0-9])?\.)+[a-z0-9](?:[a-z0-9-]*[a-z0-9])?").hasMatch(val)){
                                return 'Please Enter a Valid Email Address';
                              }
                              else
                                return null;
                            },
                            initialValue: "${customerData.email}",
                            onChanged: (val) => setState(() => _currentEmail = val),
                          ),
                        ),
                        Container(
                          child: TextFormField(
                            decoration: InputDecoration(labelText: 'Contact No:'),
                            maxLength: 11,
                            keyboardType: TextInputType.number,
                            validator: (String val){
                              if(val.length < 11 && val.length > 0){
                                return 'Your contact number should be 11 digits';
                              }
                              else if(val.isEmpty){
                                return 'Contact Number is Required';
                              }
                              else
                                return null;
                            },
                            initialValue: "${customerData.contactNo}",
                            onChanged: (val) => setState(() => _currentContactNo = val),
                          ),
                        ),
                        Container(
                          child: TextFormField(
                            obscureText: true,
                            decoration: InputDecoration(labelText: 'Password:'),
                            validator: (String val){
                              if(val.length < 8 && val.length > 0){
                                return 'Password should be 8 characters long';
                              }
                              else if(val.isEmpty){
                                return 'Password is Required';
                              }
                              else
                                return null;
                            },
                            initialValue: "${customerData.password}",
                            onChanged: (val) => setState(() => _currentPassword = val),
                          ),
                        ),
                        // Container(
                        //   child: TextFormField(
                        //     obscureText: true,
                        //     validator: (val) => val.isEmpty ? 'Enter your new name' : null,
                        //     decoration: InputDecoration(labelText: 'Confirmation Password:'),
                        //   ),
                        // ),
                        ElevatedButton(
                            child: Text(
                              'Save Changes', style: TextStyle(color: Colors.white, fontSize:18),
                            ),
                            style: ElevatedButton.styleFrom(
                              primary: Color(0xfffb0d0d),
                            ),
                            onPressed: () async {
                              if(_updateKey.currentState.validate()){
                                await DatabaseService(uid: user.uid).updateCustomerData(
                                  _currentFName ?? customerData.fName,
                                  _currentLName ?? customerData.lName,
                                  _currentAddress ?? customerData.address,
                                  _currentEmail ?? customerData.email,
                                  _currentContactNo ?? customerData.contactNo,
                                  _currentPassword ?? customerData.password,
                                );
                              }
                            }
                        ),
                      ],
                    ),
                  );
                }

                else{
                  return UserLoading();
                }
              }
          ),

        )
    );
  }
}
