import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:path/path.dart' as Path;
import 'package:proxpress/Load/user_load.dart';
import 'package:proxpress/classes/terms_conditions.dart';
import 'package:proxpress/services/auth.dart';
import 'package:proxpress/services/database.dart';
import 'package:proxpress/services/upload_file.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:slide_to_act/slide_to_act.dart';

class SignupCourier extends StatefulWidget{
  @override
  _SignupCourierState createState() => _SignupCourierState();
}

class _SignupCourierState extends State<SignupCourier> {
  int currentStep = 0;
  String fName;
  String lName;
  String email;
  String contactNo;
  String password;
  String confirmPassword;
  String address;
  bool loading = false;
  bool agree = false;
  bool slide = false;
  String status = 'Active';
  bool approved = false;
  String driversLicenseFront_ = '';
  String driversLicenseBack_ = '';
  String nbiClearancePhoto_ = '';
  String vehicleRegistrationOR_ = '';
  String vehicleRegistrationCR_ = '';
  String vehiclePhoto_ = '';
  DocumentReference deliveryPriceRef;
  String deliveryPriceUid;
  List adminCredentialsResponse = [false,false,false,false,false,false];
  final AuthService _auth = AuthService();

  String vehicleType;
  String vehicleColor;

  String error = '';
  File driversLicenseFront;
  File driversLicenseBack;
  File nbiClearancePhoto;
  File vehicleRegistrationOR;
  File vehicleRegistrationCR;
  File vehiclePhoto;

  final GlobalKey<FormState> regKey = GlobalKey<FormState>();

  Widget _buildFName(){
    return SizedBox(
      width: MediaQuery.of(context).size.width * .4,
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
      width: MediaQuery.of(context).size.width * .4,
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

  Widget _buildColor(){
    return TextFormField(
      decoration: InputDecoration(labelText: 'Vehicle Color'),
      keyboardType: TextInputType.text,
      validator: (String value){
        if(value.isEmpty){
          return 'Vehicle color is required';
        }
        else return null;
      },
      onSaved: (String value){
        vehicleColor = value;
      },
      onChanged: (val){
        setState(() => vehicleColor = val);
      },
    );
  }

  Future<bool> _backPressed(){
    return showDialog(context: context, builder: (context)
    =>AlertDialog(
      title: Text("Are you sure you want to go back? All data you placed will be loss."),
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
    final driversLicenseFrontFileName =  driversLicenseFront != null ? Path.basename(driversLicenseFront.path) : 'No File Selected';
    final driversLicenseBackFileName =  driversLicenseBack != null ? Path.basename(driversLicenseBack.path) : 'No File Selected';
    final nbiClearancePhotoFileName =  nbiClearancePhoto != null ? Path.basename(nbiClearancePhoto.path) : 'No File Selected';
    final vehicleRegistrationORFileName =  vehicleRegistrationOR != null ? Path.basename(vehicleRegistrationOR.path) : 'No File Selected';
    final vehicleRegistrationCRFileName =  vehicleRegistrationCR != null ? Path.basename(vehicleRegistrationCR.path) : 'No File Selected';
    final vehiclePhotoFileName =  vehiclePhoto != null ? Path.basename(vehiclePhoto.path) : 'No File Selected';

    final isLastStep = currentStep == getSteps(
        driversLicenseFrontFileName,
        driversLicenseBackFileName,
        nbiClearancePhotoFileName,
        vehicleRegistrationORFileName,
        vehicleRegistrationCRFileName,
        vehiclePhotoFileName).length - 1;

    return loading ? UserLoading(): WillPopScope(
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
            title: Text('Courier Signup', style: TextStyle(color: Colors.black),),
            automaticallyImplyLeading: false,
            backgroundColor: Colors.white,
            flexibleSpace: Container(margin: EdgeInsets.only(top: 10),),
          ),
          body: Stepper(
            type: StepperType.horizontal,
            steps: getSteps(
                driversLicenseFrontFileName,
                driversLicenseBackFileName,
                nbiClearancePhotoFileName,
                vehicleRegistrationORFileName,
                vehicleRegistrationCRFileName,
                vehiclePhotoFileName
            ),
            currentStep: currentStep,
            controlsBuilder: (context, ControlsDetails) {
              return Container(
                margin: EdgeInsets.only(top: 30),
                child: Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () async {///isLastStep && (!agree || !slide) ? null :
                          if(isLastStep){
                            print('Done');
                          }
                          else if(currentStep == 1){
                            bool picsLoaded = driversLicenseFront != null &&
                                driversLicenseBack != null &&
                                nbiClearancePhoto != null &&
                                vehicleRegistrationOR != null &&
                                vehicleRegistrationCR != null &&
                                vehiclePhoto != null ? true : false;
                            if(picsLoaded){
                              setState(() => currentStep += 1);
                            }
                            else {
                              print('try again baby!!!!!!!!!');
                            }
                          }
                          else
                          {
                            if(regKey.currentState.validate()) {
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
    );
  }

  List <Step> getSteps(
      String driversLicenseFrontFileName,
      String driversLicenseBackFileName,
      String nbiClearancePhotoFileName,
      String vehicleRegistrationORFileName,
      String vehicleRegistrationCRFileName,
      String vehiclePhotoFileName) => [
    Step(
        state: currentStep > 0 ? StepState.complete: StepState.indexed,
        isActive: currentStep >= 0,
        title: Text('Account'),
        content: Center(
          child: Form(
            key: regKey,
            child: Column(
              children: [
                Row(
                  children: [
                    _buildFName(),
                    Padding(
                      padding: const EdgeInsets.only(left: 30),
                      child: _buildLName(),
                    ),
                  ],
                ),
                _buildEmail(),
                _buildAddress(),
                _buildContactNo(),
                _buildPassword(),
                _buildConfirmPassword(),
              ],
            ),
          ),
        ),
    ),
    Step(
      state: currentStep > 1 ? StepState.complete: StepState.indexed,
      isActive: currentStep >= 1,
      title: Text('Credentials'),
      content: Column(
        children: [
          SizedBox(
            height: 20,
          ),
          Align(
            alignment: Alignment.bottomLeft,
            child: Text('Driver\'s License Front',
              style: TextStyle(fontSize: 15, color: Colors.black54),
            ),
          ),
          Align(
            alignment: Alignment.bottomLeft,
            child: Column(
              children: [
                Align(
                  alignment: Alignment.bottomLeft,
                  child: ElevatedButton.icon(
                    icon: Icon(Icons.upload_rounded, color: Color(0xfffb0d0d)),
                    label: Text(
                      'Add File',
                      style: TextStyle(color: Color(0xfffb0d0d)),
                    ),
                    onPressed: () async {
                      final result = await FilePicker.platform.pickFiles(allowMultiple: false);

                      final path = result.files.single.path;
                      setState(() {
                        driversLicenseFront = File(path);
                      });
                    },
                    style: ElevatedButton.styleFrom(
                      primary: Colors.white,
                    ),
                  ),
                ),
                Align(
                  alignment: Alignment.bottomLeft,
                  child: Text(driversLicenseFrontFileName),
                ),
                SizedBox(height: 20,),
              ],
            ),
          ),
          Align(
            alignment: Alignment.bottomLeft,
            child: Text('Driver\'s License Back',
              style: TextStyle(fontSize: 15, color: Colors.black54),
            ),
          ),
          Align(
            alignment: Alignment.bottomLeft,
            child: Column(
              children: [
                Align(
                  alignment: Alignment.bottomLeft,
                  child: ElevatedButton.icon(
                    icon: Icon(Icons.upload_rounded, color: Color(0xfffb0d0d)),
                    label: Text(
                      'Add File',
                      style: TextStyle(color: Color(0xfffb0d0d)),
                    ),
                    onPressed: () async {
                      final result = await FilePicker.platform.pickFiles(allowMultiple: false);

                      final path = result.files.single.path;
                      setState(() {
                        driversLicenseBack = File(path);
                      });
                    },
                    style: ElevatedButton.styleFrom(
                      primary: Colors.white,
                    ),
                  ),
                ),
                Align(
                  alignment: Alignment.bottomLeft,
                  child: Text(driversLicenseBackFileName),
                ),
                SizedBox(height: 20,),
              ],
            ),
          ),
          Align(
            alignment: Alignment.bottomLeft,
            child: Text('NBI Clearance',
              style: TextStyle(fontSize: 15, color: Colors.black54),
            ),
          ),
          Align(
            alignment: Alignment.bottomLeft,
            child: Column(
              children: [
                Align(
                  alignment: Alignment.bottomLeft,
                  child: ElevatedButton.icon(
                    icon: Icon(Icons.upload_rounded, color: Color(0xfffb0d0d)),
                    label: Text(
                      'Add File',
                      style: TextStyle(color: Color(0xfffb0d0d)),
                    ),
                    onPressed: () async {
                      final result = await FilePicker.platform.pickFiles(allowMultiple: false);

                      final path = result.files.single.path;
                      setState(() {
                        nbiClearancePhoto = File(path);
                      });
                    },
                    style: ElevatedButton.styleFrom(
                      primary: Colors.white,
                    ),
                  ),
                ),
                Align(
                  alignment: Alignment.bottomLeft,
                  child: Text(nbiClearancePhotoFileName),
                ),
                SizedBox(height: 20,),
              ],
            ),
          ),
          Align(
            alignment: Alignment.bottomLeft,
            child: Text('Vehicle Official Receipt (OR)',
              style: TextStyle(fontSize: 15, color: Colors.black54),
            ),
          ),
          Align(
            alignment: Alignment.bottomLeft,
            child: Column(
              children: [
                Align(
                  alignment: Alignment.bottomLeft,
                  child: ElevatedButton.icon(
                    icon: Icon(Icons.upload_rounded, color: Color(0xfffb0d0d)),
                    label: Text(
                      'Add File',
                      style: TextStyle(color: Color(0xfffb0d0d)),
                    ),
                    onPressed: () async {
                      final result = await FilePicker.platform.pickFiles(allowMultiple: false);

                      final path = result.files.single.path;
                      setState(() {
                        vehicleRegistrationOR = File(path);
                      });
                    },
                    style: ElevatedButton.styleFrom(
                      primary: Colors.white,
                    ),
                  ),
                ),
                Align(
                  alignment: Alignment.bottomLeft,
                  child: Text(vehicleRegistrationORFileName),
                ),
                SizedBox(height: 20,),
              ],
            ),
          ),
          Align(
            alignment: Alignment.bottomLeft,
            child: Text('Vehicle Certificate of Registration (CR)',
              style: TextStyle(fontSize: 15, color: Colors.black54),
            ),
          ),
          Align(
            alignment: Alignment.bottomLeft,
            child: Column(
              children: [
                Align(
                  alignment: Alignment.bottomLeft,
                  child: ElevatedButton.icon(
                    icon: Icon(Icons.upload_rounded, color: Color(0xfffb0d0d)),
                    label: Text(
                      'Add File',
                      style: TextStyle(color: Color(0xfffb0d0d)),
                    ),
                    onPressed: () async {
                      final result = await FilePicker.platform.pickFiles(allowMultiple: false);

                      final path = result.files.single.path;
                      setState(() {
                        vehicleRegistrationCR = File(path);
                      });
                    },
                    style: ElevatedButton.styleFrom(
                      primary: Colors.white,
                    ),
                  ),
                ),
                Align(
                  alignment: Alignment.bottomLeft,
                  child: Text(vehicleRegistrationCRFileName),
                ),
                SizedBox(height: 20,),
              ],
            ),
          ),
          Align(
            alignment: Alignment.bottomLeft,
            child: Text('Vehicle Photo',
              style: TextStyle(fontSize: 15, color: Colors.black54),
            ),
          ),
          Align(
            alignment: Alignment.bottomLeft,
            child: Column(
              children: [
                Align(
                  alignment: Alignment.bottomLeft,
                  child: ElevatedButton.icon(
                    icon: Icon(Icons.upload_rounded, color: Color(0xfffb0d0d)),
                    label: Text(
                      'Add File',
                      style: TextStyle(color: Color(0xfffb0d0d)),
                    ),
                    onPressed: () async {
                      final result = await FilePicker.platform.pickFiles(allowMultiple: false);

                      final path = result.files.single.path;
                      setState(() {
                        vehiclePhoto = File(path);
                      });
                    },
                    style: ElevatedButton.styleFrom(
                      primary: Colors.white,
                    ),
                  ),
                ),
                Align(
                  alignment: Alignment.bottomLeft,
                  child: Text(vehiclePhotoFileName),
                ),
                SizedBox(height: 20,),
              ],
            ),
          ),
        ],
      ),
    ),
    Step(
      state: currentStep > 2 ? StepState.complete: StepState.indexed,
      isActive: currentStep >= 2,
      title: Text('Complete'),
      content: Text('gg'),
    ),
  ];
}