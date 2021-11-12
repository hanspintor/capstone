import 'dart:async';
import 'dart:io';
import 'dart:isolate';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:proxpress/Load/user_load.dart';
import 'package:proxpress/models/couriers.dart';
import 'package:proxpress/models/customers.dart';
import 'package:proxpress/services/auth.dart';
import 'package:proxpress/classes/terms_conditions.dart';
import 'package:proxpress/services/database.dart';
import 'package:slide_to_act/slide_to_act.dart';

class SignupCustomer extends StatefulWidget{
  @override
  _SignupCustomerState createState() => _SignupCustomerState();
}

class _SignupCustomerState extends State<SignupCustomer> {
  int currentStep = 0;
  int step = 0;
  String fName;
  String lName;
  String email;
  String contactNo;
  String password;
  String confirmPassword;
  String address;
  bool agree = false;
  bool slide = false;
  Map courier_ref = {};

  bool loading = false;
  final AuthService _auth = AuthService();
  String error = '';

  final GlobalKey<FormState> regKey = GlobalKey<FormState>();
  List<GlobalKey<FormState>> formKeys = [GlobalKey<FormState>(), GlobalKey<FormState>(), GlobalKey<FormState>(), GlobalKey<FormState>(), GlobalKey<FormState>(),];

  Widget _buildFName(){
    return SizedBox(
      width: MediaQuery.of(context).size.width * .35,
      child: TextFormField(
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
      ),
    );
  }

  Widget _buildLName(){
    return SizedBox(
      width: MediaQuery.of(context).size.width * .35,
      child: TextFormField(
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
      ),
    );
  }

  Widget _buildEmail(){
    return StreamBuilder<List<Customer>>(
      stream: DatabaseService().customerList,
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          List<Customer> customers = snapshot.data;

          return StreamBuilder<List<Courier>>(
            stream: DatabaseService().courierList,
            builder: (context, snapshot) {
              List<Courier> couriers = snapshot.data;
              return TextFormField(
                  decoration: InputDecoration(labelText: 'Email'),
                  validator: (String value){
                    if(value.isEmpty){
                      return 'Email is Required';
                    }
                    if (!RegExp(r"[a-z0-9!#$%&'*+/=?^_`{|}~-]+(?:\.[a-z0-9!#$%&'*+/=?^_`{|}~-]+)*@(?:[a-z0-9](?:[a-z0-9-]*[a-z0-9])?\.)+[a-z0-9](?:[a-z0-9-]*[a-z0-9])?").hasMatch(value)){
                      return 'Please Enter a Valid Email Address';
                    }
                    bool emailTaken = false;
                    bool emailTakenCus = false;

                    customers.forEach((element) {
                      if (element.email == value){
                        emailTaken = true;
                      }
                    });
                    couriers.forEach((element) {
                      if (element.email == value){
                       emailTakenCus = true;
                      }
                    });
                    print(emailTaken);
                    print(emailTakenCus);

                    if (emailTaken || emailTakenCus){
                      return 'Email already taken';
                    }
                    else return null;
                  },
                  onSaved: (String value){
                    email = value;
                  },
                  onChanged: (val){
                    setState(() => email = val);
                  },
              );
            }
          );
        } else {
          return Container();
        }
      }
    );
  }
  Widget _buildContactNo() {
    return StreamBuilder<List<Courier>>(
        stream: DatabaseService().courierList,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            List<Courier> couriers = snapshot.data;
            return StreamBuilder<List<Customer>>(
                stream: DatabaseService().customerList,
                builder: (context, snapshot) {
                  List<Customer> customers = snapshot.data;
                  return TextFormField(
                    decoration: InputDecoration(labelText: 'Contact Number'),
                    maxLength: 11,
                    keyboardType: TextInputType.number,
                    validator: (String value) {
                      if (value.length < 11 && value.length > 0) {
                        return 'Your contact number should be 11 digits';
                      }
                      else if (value.isEmpty) {
                        return 'Contact Number is Required';
                      }
                      bool contactNoTaken = false;
                      bool contactNoTakeCus = false;
                      couriers.forEach((element) {
                        if (element.contactNo == value) {
                          contactNoTaken = true;
                        }
                      });
                      customers.forEach((element) {
                        if (element.contactNo == value) {
                          contactNoTakeCus = true;
                        }
                      });
                      print(contactNoTaken);
                      print(contactNoTakeCus);
                      if (contactNoTaken || contactNoTakeCus) {
                        return "Contact number already taken";
                      }
                      else
                        return null;
                    },
                    onSaved: (String value) {
                      contactNo = value;
                    },
                    onChanged: (val) {
                      setState(() => contactNo = val);
                    },
                  );
                }
            );
          } else {
            return Container();
          }
        }
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

  Widget _buildConfirmPassword(){
    return TextFormField(
      decoration: InputDecoration(labelText: 'Confirm Password'),
      obscureText: true,
      validator: (String value){
        if(password != null){
          if(value.isEmpty){
            return "Password does not match";
          } else if(confirmPassword != password){
            return "Password does not match";
          } else {
            return null;
          }
        }
        else
          return null;
      },
      onSaved: (String value){
        confirmPassword = value;
      },
      onChanged: (val){
        setState(() => confirmPassword = val);
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
        TextButton(
          child: Text("No"),
          onPressed: ()=>Navigator.pop(context, false),
        ),
        TextButton(
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
    final isLastStep = currentStep == getSteps().length - 1;
    print(getSteps().length);

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
            child: Column(
              children: [
                Form(
                  key: regKey,
                  child: Stepper(
                    type: StepperType.vertical,
                    steps: getSteps(),
                    currentStep: currentStep,
                    physics: NeverScrollableScrollPhysics(),

                    controlsBuilder: (context, ControlsDetails) {
                      return Container(
                        margin: EdgeInsets.only(top: 30),
                        child: Row(
                          children: [
                            Expanded(
                              child: ElevatedButton(
                                onPressed: isLastStep && (!agree || !slide) ? null : () async {
                                  if(isLastStep){
                                    String defaultProfilePic = 'https://firebasestorage.googleapis.com/v0/b/proxpress-629e3.appspot.com/o/profile-user.png?alt=media&token=6727618b-4289-4438-8a93-a4f14753d92e';

                                    if (regKey.currentState.validate()){
                                      setState(() => loading = true);
                                      dynamic result = await _auth.SignUpCustomer(email, password, fName, lName,
                                          contactNo, address, defaultProfilePic, false, 0, {}, 0);


                                      if(result == null){
                                        setState((){
                                          error = 'Email already taken';
                                          slide = false;
                                          loading = false;
                                        });
                                      } else{
                                        // ScaffoldMessenger.of(context)..removeCurrentSnackBar()
                                        //   ..showSnackBar(SnackBar(content: Text("We have sent you an email to ${email} kindly verify to complete the registration.")));
                                      }
                                    }
                                  }
                                  else
                                  {
                                    if(formKeys[currentStep].currentState.validate()) {
                                      setState(() => currentStep += 1);
                                    }
                                  }
                                },
                                child: Text(isLastStep ? 'SIGNUP' : 'NEXT'),
                              ),
                            ),
                            const SizedBox(width: 12,),
                            if(currentStep != 0)
                            Expanded(
                              child: ElevatedButton(
                                onPressed: (){
                                  setState(() {
                                    if(currentStep == 0){
                                      return null;
                                    }
                                    else currentStep -= 1;
                                  });
                                },
                                child: Text('BACK'),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          )
      ),
    );
  }
  List<Step> getSteps() => [
    Step(
      state: currentStep > 0 ? StepState.complete: StepState.indexed,
      isActive: currentStep >= 0,
      title: Text('Name'),
      content: Form(
        key: formKeys[0],
        child: Row(
          children: [
            Padding(
              padding: const EdgeInsets.only(right: 19),
              child: _buildFName(),
            ),
            _buildLName(),
          ],
        ),
      ),
    ),
    Step(
      state: currentStep > 1 ? StepState.complete: StepState.indexed,
      isActive: currentStep >= 1,
      title: Text('Email'),
      content: Form(
        key: formKeys[1],
        child: Padding(
          padding: const EdgeInsets.only(right: 30),
          child: Column(
            children: [
              _buildEmail(),
            ],
          ),
        ),
      ),
    ),
    Step(
      state: currentStep > 2 ? StepState.complete: StepState.indexed,
      isActive: currentStep >= 2,
      title: Text('Address'),
      content: Form(
        key: formKeys[2],
        child: Padding(
          padding: const EdgeInsets.only(right: 30),
          child: Column(
            children: [
              _buildAddress(),
            ],
          ),
        ),
      ),
    ),
    Step(
      state: currentStep > 3 ? StepState.complete: StepState.indexed,
      isActive: currentStep >= 3,
      title: Text('Contact Number'),
      content: Form(
        key: formKeys[3],
        child: Padding(
          padding: const EdgeInsets.only(right: 30),
          child: Column(
            children: [
              _buildContactNo(),
            ],
          ),
        ),
      ),
    ),
    Step(
      state: currentStep > 4 ? StepState.complete: StepState.indexed,
      isActive: currentStep >= 4,
      title: Text('Password'),
      content: Form(
        key: formKeys[4],
        child: Padding(
          padding: const EdgeInsets.only(right: 30),
          child: Column(
            children: [
              _buildPassword(),
              _buildConfirmPassword(),
            ],
          ),
        ),
      ),
    ),
    Step(
      state: currentStep > 5 ? StepState.complete: StepState.indexed,
      isActive: currentStep >= 5,
      title: Text('Complete'),
      content: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.only(right: 3),
          child: Column(
            children: [
              Row(children: [
                Padding(
                  padding: const EdgeInsets.only(right: 10),
                  child: Text('Name', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),),
                ),
                Text.rich(
                  TextSpan(children: [
                    TextSpan(text: fName ?? '', style: TextStyle(fontSize: 15),),
                    TextSpan(text: ' '),
                    TextSpan(text: lName ?? '', style: TextStyle(fontSize: 15),)
                  ],)
                ),
              ],
              ),
              Row(children: [
                Padding(
                  padding: const EdgeInsets.only(right: 10),
                  child: Text('Email', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),),
                ),
                Text(email ?? '', style: TextStyle(fontSize: 15),),
              ],
              ),
              Row(children: [
                Padding(
                  padding: const EdgeInsets.only(right: 10),
                  child: Text('Address', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),),
                ),
                Text(address ?? '', style: TextStyle(fontSize: 15),),
              ],
              ),
              Row(children: [
                Padding(
                  padding: const EdgeInsets.only(right: 10),
                  child: Text('Contact Number', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),),
                ),
                Text(contactNo ?? '', style: TextStyle(fontSize: 15),),
              ],
              ),

              Padding(
                padding: const EdgeInsets.only(right: 10),
                child: Row(
                  children: [
                    Container(
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
              ),
              Padding(
                padding: const EdgeInsets.only(top: 10),
                child: Container(
                  child: SlideAction(
                    child: Container(
                      padding: EdgeInsets.only(left: 30),
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
              ),
            ],
          ),
        ),
      ),
    ),
  ];
}



