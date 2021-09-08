import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:path/path.dart' as Path;
import 'package:proxpress/Load/user_load.dart';
import 'package:proxpress/classes/terms_conditions.dart';
import 'package:proxpress/models/couriers.dart';
import 'package:proxpress/services/auth.dart';
import 'package:proxpress/services/database.dart';
import 'package:proxpress/services/upload_file.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;

class SignupCourier extends StatefulWidget{
  //final Function uploadfile;
  //SignupCourier({this.uploadfile});

  @override
  _SignupCourierState createState() => _SignupCourierState();
}

class _SignupCourierState extends State<SignupCourier> {

  String fName;
  String lName;
  String email;
  String contactNo;
  String password;
  String address;
  bool loading = false;
  bool agree = false;
  String status = 'Active';
  bool approved = false;
  String driversLicenseFront_ = '';
  String driversLicenseBack_ = '';
  String nbiClearancePhoto_ = '';
  String vehicleRegistrationOR_ = '';
  String vehicleRegistrationCR_ = '';
  String vehiclePhoto_ = '';

  final AuthService _auth = AuthService();
  final Courier _courier = Courier();

  String vehicleType;
  String vehicleColor;

  String error = '';
  File driversLicenseFront;
  File driversLicenseBack;
  File nbiClearancePhoto;
  File vehicleRegistrationOR;
  File vehicleRegistrationCR;
  File vehiclePhoto;

  void _validate(){
    if(!regKey.currentState.validate()){
      return;
    }
    regKey.currentState.save();

    print (fName);
    print (lName);
    print (contactNo);
    print (password);
    print (address);
  }

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

  @override
  Widget build(BuildContext context) {
    final driversLicenseFrontFileName =  driversLicenseFront != null ? Path.basename(driversLicenseFront.path) : 'No File Selected';
    final driversLicenseBackFileName =  driversLicenseBack != null ? Path.basename(driversLicenseBack.path) : 'No File Selected';
    final nbiClearancePhotoFileName =  nbiClearancePhoto != null ? Path.basename(nbiClearancePhoto.path) : 'No File Selected';
    final vehicleRegistrationORFileName =  vehicleRegistrationOR != null ? Path.basename(vehicleRegistrationOR.path) : 'No File Selected';
    final vehicleRegistrationCRFileName =  vehicleRegistrationCR != null ? Path.basename(vehicleRegistrationCR.path) : 'No File Selected';
    final vehiclePhotoFileName =  vehiclePhoto != null ? Path.basename(vehiclePhoto.path) : 'No File Selected';

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
                          Container(
                            child: Column(
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
                          DropdownButtonFormField<String>(
                            validator: (value) => value == null ? 'Vehicle type is required' : null,
                            decoration: InputDecoration(
                              labelText: 'Select Your Vehicle Type',
                            ),
                            isExpanded: true,
                            icon: const Icon(Icons.arrow_downward),
                            iconSize: 24,
                            elevation: 16,
                            onChanged: (String newValue) {
                              setState(() {
                                vehicleType = newValue;
                              });
                            },
                            items: <String>['Motorcycle', 'Sedan', 'Pickup Truck', 'Multi-purpose Vehicle', 'Family-business Van', 'Multi-purpose Van']
                                .map<DropdownMenuItem<String>>((String value) {
                              return DropdownMenuItem<String>(
                                value: value,
                                child: Text(value),
                              );
                            }).toList(),
                          ),
                          _buildColor(),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.start,
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
                          ElevatedButton(
                              child: Text(
                                'Signup', style: TextStyle(color: Colors.white, fontSize:18),
                              ),
                              style: ElevatedButton.styleFrom(
                                primary: Color(0xfffb0d0d),
                              ),
                              onPressed: !agree ? null : () async {
                                String defaultProfilePic = 'https://firebasestorage.googleapis.com/v0/b/proxpress-629e3.appspot.com/o/profile-user.png?alt=media&token=6727618b-4289-4438-8a93-a4f14753d92e';

                                bool picsLoaded = driversLicenseFront != null &&
                                                  driversLicenseBack != null &&
                                                  nbiClearancePhoto != null &&
                                                  vehicleRegistrationOR != null &&
                                                  vehicleRegistrationCR != null &&
                                                  vehiclePhoto != null ? true : false;

                                if (regKey.currentState.validate() && picsLoaded){
                                  //setState(() => loading = true); // loading = true;
                                  dynamic result = await _auth.SignUpCourier(email, password, fName, lName, contactNo, address, status, approved, vehicleType, vehicleColor, defaultProfilePic, driversLicenseFront_, driversLicenseBack_, nbiClearancePhoto_, vehicleRegistrationOR_, vehicleRegistrationCR_, vehiclePhoto_);
                                  if(result == null){
                                    setState((){
                                      error = 'Email already taken';
                                      loading = false;
                                    });
                                  } else {
                                    final FirebaseAuth auth = FirebaseAuth.instance;

                                    final User user = auth.currentUser;

                                    if (user != null) {
                                      final driversLicenseFrontDestination = 'Couriers/${user.uid}/$driversLicenseFrontFileName';
                                      final driversLicenseBackDestination = 'Couriers/${user.uid}/$driversLicenseBackFileName';
                                      final nbiClearancePhotoDestination = 'Couriers/${user.uid}/$nbiClearancePhotoFileName';
                                      final vehicleRegistrationORDestination = 'Couriers/${user.uid}/$vehicleRegistrationORFileName';
                                      final vehicleRegistrationCRDestination = 'Couriers/${user.uid}/$vehicleRegistrationCRFileName';
                                      final vehiclePhotoDestination = 'Couriers/${user.uid}/$vehiclePhotoFileName';

                                      try {
                                        await UploadFile.uploadFile(driversLicenseFrontDestination, driversLicenseFront);
                                        driversLicenseFront_ = await firebase_storage.FirebaseStorage.instance
                                            .ref(driversLicenseFrontDestination)
                                            .getDownloadURL();

                                        await UploadFile.uploadFile(driversLicenseBackDestination, driversLicenseBack);
                                        driversLicenseBack_ = await firebase_storage.FirebaseStorage.instance
                                            .ref(driversLicenseBackDestination)
                                            .getDownloadURL();

                                        await UploadFile.uploadFile(nbiClearancePhotoDestination, nbiClearancePhoto);
                                        nbiClearancePhoto_ = await firebase_storage.FirebaseStorage.instance
                                            .ref(nbiClearancePhotoDestination)
                                            .getDownloadURL();

                                        await UploadFile.uploadFile(vehicleRegistrationORDestination, vehicleRegistrationOR);
                                        vehicleRegistrationOR_ = await firebase_storage.FirebaseStorage.instance
                                            .ref(vehicleRegistrationORDestination)
                                            .getDownloadURL();

                                        await UploadFile.uploadFile(vehicleRegistrationCRDestination, vehicleRegistrationCR);
                                        vehicleRegistrationCR_ = await firebase_storage.FirebaseStorage.instance
                                            .ref(vehicleRegistrationCRDestination)
                                            .getDownloadURL();

                                        await UploadFile.uploadFile(vehiclePhotoDestination, vehiclePhoto);
                                        vehiclePhoto_ = await firebase_storage.FirebaseStorage.instance
                                            .ref(vehiclePhotoDestination)
                                            .getDownloadURL();

                                        await DatabaseService(uid: user.uid).updateCourierCredentials(driversLicenseFront_, driversLicenseBack_, nbiClearancePhoto_, vehicleRegistrationOR_, vehicleRegistrationCR_, vehiclePhoto_);
                                      } catch(e) {
                                        print(e.toString());
                                      }
                                    }
                                  }
                                } else {
                                  print('WTF');
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