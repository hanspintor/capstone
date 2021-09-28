import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:proxpress/Load/user_load.dart';
import 'package:proxpress/models/couriers.dart';
import 'package:proxpress/services/auth.dart';
import 'package:proxpress/classes/terms_conditions.dart';
import 'package:slide_to_act/slide_to_act.dart';
import 'package:slide_to_confirm/slide_to_confirm.dart';

class SignupCustomer extends StatefulWidget{
  @override
  _SignupCustomerState createState() => _SignupCustomerState();
}

class _SignupCustomerState extends State<SignupCustomer> {
  String fName;
  String lName;
  String email;
  String contactNo;
  String password;
  String address;
  bool agree = false;
  bool slide = false;
  Map  courier_ref;

  bool loading = false;
  final AuthService _auth = AuthService();
  String error = '';
  int _counter = 0;

  final GlobalKey<FormState> regKey = GlobalKey<FormState>();

  Widget _buildFName(){
    return TextFormField(
      decoration: InputDecoration(labelText: 'First Name'),
      validator: (String value){
        if(value.isEmpty){
          return 'First Name is Required';
        }
        else return null;
      },
      onSaved: (String value){
        fName = value;
      },
      onChanged: (val){
        setState(() => fName = val);
      },
    );
  }

  Widget _buildLName(){
    return TextFormField(
      decoration: InputDecoration(labelText: 'Last Name'),
      validator: (String value){
        if(value.isEmpty){
          return 'Last Name is Required';
        }
        else return null;
      },
      onSaved: (String value){
        lName = value;
      },
      onChanged: (val){
        setState(() => lName = val);
      },
    );
  }

  Widget _buildEmail(){
    return TextFormField(
      decoration: InputDecoration(labelText: 'Email'),
      validator: (String value){
        if(value.isEmpty){
          return 'Email is Required';
        }
        if (!RegExp(r"[a-z0-9!#$%&'*+/=?^_`{|}~-]+(?:\.[a-z0-9!#$%&'*+/=?^_`{|}~-]+)*@(?:[a-z0-9](?:[a-z0-9-]*[a-z0-9])?\.)+[a-z0-9](?:[a-z0-9-]*[a-z0-9])?").hasMatch(value)){
          return 'Please Enter a Valid Email Address';
        }
        else return null;
      },
      onSaved: (String value){
        email = value;
      },
        onChanged: (val){
          setState(() => email = val);
        }
    );
  }
  Widget _buildContactNo(){
    return TextFormField(
      decoration: InputDecoration(labelText: 'Contact Number'),
      maxLength: 11,
      keyboardType: TextInputType.number,
      validator: (String value){
        if(value.length < 11 && value.length > 0){
          return 'Your contact number should be 11 digits';
        }
        else if(value.isEmpty){
          return 'Contact Number is Required';
        }
        else return null;
      },
      onSaved: (String value){
        contactNo = value;
      },
      onChanged: (val){
        setState(() => contactNo = val);
      },
    );
  }

  Widget _buildPassword(){
    return TextFormField(
      decoration: InputDecoration(labelText: 'Password'),
      obscureText: true,
      validator: (String value){
        if(value.length < 8 && value.length > 0){
          return 'Password should be 8 characters long';
        }
        else if(value.isEmpty){
          return 'Password is Required';
        }
        else return null;
      },
      onSaved: (String value){
        password = value;
      },
      onChanged: (val){
          setState(() => password = val);
      },
    );
  }
  Widget _buildAddress(){
    return TextFormField(
      decoration: InputDecoration(labelText: 'Home Address'),
      keyboardType: TextInputType.streetAddress,
      validator: (String value){
        if(value.isEmpty){
          return 'Home Address is Required';
        }
        else return null;
      },
      onSaved: (String value){
       address = value;
      },
      onChanged: (val){
        setState(() => address = val);
      },
    );
  }
  Future<bool> _backPressed(){
    return showDialog(context: context, builder: (context)
    =>AlertDialog(
      title: Text("Are you sure you want to go back? All data you placed will be loss"),
      actions: <Widget> [
        FlatButton(
          child: Text("No"),
          onPressed: ()=>Navigator.pop(context, false),
        ),
        FlatButton(
          child: Text("Yes"),
          onPressed: ()=>Navigator.pop(context, true),
        )
      ],
    ));
  }

  void confirm(value) {
    setState(() {
      slide = value;
    });
  }


  @override
  Widget build(BuildContext context) {
    return loading ? UserLoading() : WillPopScope(
      onWillPop: _backPressed,
      child: Scaffold(
          appBar: AppBar(
            centerTitle: true,
            leading: IconButton(icon: Icon(
              Icons.arrow_back,
              color: Colors.black,
            ),
              onPressed: (){
                Navigator.pop(context, false);
              },
              iconSize: 25,
            ),
            title: Text('Customer Signup', style: TextStyle(color: Colors.black),),
            automaticallyImplyLeading: false,
            backgroundColor: Colors.white,
            flexibleSpace: Container(margin: EdgeInsets.only(top: 10),),
          ),
          body: SingleChildScrollView(
            child: Center(
              child: Column(
                children: [
                  Container(
                    margin: EdgeInsets.all(50),
                    child: Form(
                      key: regKey,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          SizedBox(height: 12,),
                          Text(
                            error,
                            style: TextStyle(color: Colors.red, fontSize: 20.0),
                          ),
                          _buildFName(),
                          _buildLName(),
                          _buildEmail(),
                          _buildContactNo(),
                          _buildPassword(),
                          _buildAddress(),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container (
                                child: Checkbox(
                                    value: agree,
                                    onChanged: (value){
                                      setState(() {
                                        agree = value;
                                      });
                                    }
                                ),
                              ),
                              Container(
                                child: Text(
                                    'I do accept the '
                                ),
                              ),
                              Container(
                                child: InkWell(
                                  onTap: () {
                                    showDialog(
                                        barrierDismissible: false,
                                        context: context, builder: (BuildContext context) => AlertDialog(
                                        title: Text('Terms and Conditions', style: TextStyle(fontWeight: FontWeight.bold)),
                                        content: (AlertTermsConditions()),
                                    )
                                    );
                                  },
                                  child: Text(
                                    "Terms and Conditions",
                                    style: TextStyle(
                                      color: Color(0xffFD3F40),
                                      decoration: TextDecoration.underline,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        Container(
                          margin: EdgeInsets.symmetric(horizontal: 30),
                          child: SlideAction(
                            child: Container(
                              margin: EdgeInsets.only(left: 40),
                              child: Text('SLIDE IF YOU ARE NOT A BOT', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white),),
                            ),
                            elevation: 4,
                            height:60,
                            sliderRotate: true,
                            sliderButtonIconPadding: 13,
                            onSubmit: (){
                              confirm(true);
                            },
                          ),
                        ),

                          ElevatedButton(
                            child: Text(
                              'Signup', style: TextStyle(color: Colors.white, fontSize:18),
                            ),
                            style: ElevatedButton.styleFrom(
                              primary: Color(0xfffb0d0d),
                            ),
                            onPressed: !agree || !slide ? null : () async {
                              String defaultProfilePic = 'https://firebasestorage.googleapis.com/v0/b/proxpress-629e3.appspot.com/o/profile-user.png?alt=media&token=6727618b-4289-4438-8a93-a4f14753d92e';

                              if (regKey.currentState.validate()){
                                ScaffoldMessenger.of(context)..removeCurrentSnackBar()
                                  ..showSnackBar(SnackBar(content: Text("We have sent you an email to ${email} kindly verify to complete the registration.")));
                                setState(() => loading = true); // loading = true;
                                dynamic result = await _auth.SignUpCustomer(email, password, fName, lName,
                                    contactNo, address, defaultProfilePic, false, 0, courier_ref);

                                if(result == null){
                                  setState((){
                                    error = 'Email already taken';
                                    loading = false;
                                  });
                                }
                              }
                            }
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          )
      ),
    );
  }
}



