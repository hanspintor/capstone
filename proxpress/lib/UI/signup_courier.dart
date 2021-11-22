import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter_circle_color_picker/flutter_circle_color_picker.dart';
import 'package:path/path.dart' as Path;
import 'package:proxpress/Load/user_load.dart';
import 'package:proxpress/classes/terms_conditions.dart';
import 'package:proxpress/models/couriers.dart';
import 'package:proxpress/models/customers.dart';
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
  int vehicleColor;

  String error = '';
  File driversLicenseFront;
  File driversLicenseBack;
  File nbiClearancePhoto;
  File vehicleRegistrationOR;
  File vehicleRegistrationCR;
  File vehiclePhoto;
  Color color = Colors.grey;
  bool notValid = true;

  final GlobalKey<FormState> regKey = GlobalKey<FormState>();
  final GlobalKey<FormState> dropKey = GlobalKey<FormState>();

  Widget _buildFName() {
    return SizedBox(
      width: MediaQuery.of(context).size.width * .4,
      child: TextFormField(
        decoration: InputDecoration(labelText: 'First Name'),
        validator: (String value) {
          if (value.isEmpty) {
            return 'First Name is Required';
          }
          else return null;
        },
        onSaved: (String value) {
          fName = value;
        },
        onChanged: (val) {
          setState(() => fName = val);
        },
      ),
    );
  }

  Widget _buildLName() {
    return SizedBox(
      width: MediaQuery.of(context).size.width * .4,
      child: TextFormField(
        decoration: InputDecoration(labelText: 'Last Name'),
        validator: (String value) {
          if (value.isEmpty) {
            return 'Last Name is Required';
          }
          else return null;
        },
        onSaved: (String value) {
          lName = value;
        },
        onChanged: (val) {
          setState(() => lName = val);
        },
      ),
    );
  }

  Widget _buildEmail() {
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
                    validator: (String value) {
                      if (value.isEmpty) {
                        return 'Email is Required';
                      }
                      if (!RegExp(r"[a-z0-9!#$%&'*+/=?^_`{|}~-]+(?:\.[a-z0-9!#$%&'*+/=?^_`{|}~-]+)*@(?:[a-z0-9](?:[a-z0-9-]*[a-z0-9])?\.)+[a-z0-9](?:[a-z0-9-]*[a-z0-9])?").hasMatch(value)) {
                        return 'Please Enter a Valid Email Address';
                      }
                      bool emailTaken = false;
                      bool emailTakenCus = false;

                      customers.forEach((element) {
                        if (element.email == value) {
                          emailTaken = true;
                        }
                      });
                      couriers.forEach((element) {
                        if (element.email == value) {
                          emailTakenCus = true;
                        }
                      });
                      print(emailTaken);
                      print(emailTakenCus);

                      if (emailTaken || emailTakenCus) {
                        return 'Email already taken';
                      }
                      else return null;
                    },
                    onSaved: (String value) {
                      email = value;
                    },
                    onChanged: (val) {
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

  Widget _buildPassword() {
    return TextFormField(
      decoration: InputDecoration(labelText: 'Password'),
      obscureText: true,
      validator: (String value) {
        if (value.length < 8 && value.length > 0) {
          return 'Password should be 8 characters long';
        }
        else if (value.isEmpty) {
          return 'Password is Required';
        }
        else return null;
      },
      onSaved: (String value) {
        password = value;
      },
      onChanged: (val) {
        setState(() => password = val);
      },
    );
  }

  Widget _buildConfirmPassword() {
    return TextFormField(
      decoration: InputDecoration(labelText: 'Confirm Password'),
      obscureText: true,
      validator: (String value) {
        if (password != null) {
          if (value.isEmpty) {
            return "Password does not match";
          } else if (confirmPassword != password) {
            return "Password does not match";
          } else {
            return null;
          }
        }
        else
          return null;
      },
      onSaved: (String value) {
        confirmPassword = value;
      },
      onChanged: (val) {
        setState(() => confirmPassword = val);
      },
    );
  }

  Widget _buildAddress() {
    return TextFormField(
      decoration: InputDecoration(labelText: 'Home Address'),
      keyboardType: TextInputType.streetAddress,
      validator: (String value) {
        if (value.isEmpty) {
          return 'Home Address is Required';
        }
        else return null;
      },
      onSaved: (String value) {
        address = value;
      },
      onChanged: (val) {
        setState(() => address = val);
      },
    );
  }

  Future<bool> _backPressed() {
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
              onPressed: () {
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
              bool picsLoaded = driversLicenseFront != null &&
                  driversLicenseBack != null &&
                  nbiClearancePhoto != null &&
                  vehicleRegistrationOR != null &&
                  vehicleRegistrationCR != null &&
                  vehiclePhoto != null ? true : false;

              return Container(
                margin: EdgeInsets.only(top: 30),
                child: Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: isLastStep && (!agree || !slide) ? null : () async {
                          if (isLastStep) {
                            String defaultProfilePic = 'https://firebasestorage.googleapis.com/v0/b/proxpress-629e3.appspot.com/o/profile-user.png?alt=media&token=6727618b-4289-4438-8a93-a4f14753d92e';
                            await FirebaseFirestore.instance
                                .collection('Delivery Prices')
                                .where('Vehicle Type', isEqualTo: vehicleType)
                                .get()
                                .then((event) {
                              deliveryPriceUid = event.docs.first.id.toString(); //if it is a single document
                            });

                            deliveryPriceRef = FirebaseFirestore.instance.collection('Delivery Prices').doc(deliveryPriceUid);

                            //setState(() => loading = true); // loading = true;
                            String welcomeMessage = "Thank you for registering in PROXpress. "
                                "Please wait for up to 24 hours for the admin to check and verify your uploaded credentials. "
                                "This is to ensure that you are qualified to be a courier in our app.";

                            dynamic result = await _auth.SignUpCourier(email, password, fName, lName, contactNo, address, status, defaultProfilePic, approved, vehicleType, vehicleColor, driversLicenseFront_, driversLicenseBack_, nbiClearancePhoto_, vehicleRegistrationOR_, vehicleRegistrationCR_, vehiclePhoto_, deliveryPriceRef, false, 0, false, 0, welcomeMessage, adminCredentialsResponse, 0, false);
                            if (result == null) {
                              setState(() {
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
                          }
                          else if (currentStep == 1) {
                            if (!picsLoaded) {
                              setState(() => notValid = picsLoaded);
                            } else {
                              setState(() => currentStep += 1);
                            }
                          } else {
                            if (regKey.currentState.validate()) {
                              setState(() => currentStep += 1);
                            }
                          }
                        },
                        child: Text(isLastStep ? 'SIGNUP' : 'NEXT'),
                      ),
                    ),
                    const SizedBox(width: 12,),
                    if (currentStep != 0)
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            setState(() {
                              if (currentStep == 0) {
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
          Padding(
            padding: const EdgeInsets.only(bottom: 5),
            child: OutlinedButton(
              child: ListTile(
                title: Text('Driver\'s License Front'),
                subtitle: Text(driversLicenseFrontFileName),
                trailing: IconButton(
                  icon: Icon(driversLicenseFrontFileName == 'No File Selected' ? Icons.attach_file_rounded: Icons.cancel_rounded, color: Color(0xfffb0d0d),),
                  onPressed:  driversLicenseFrontFileName == 'No File Selected' || driversLicenseFront == null ? null : () {
                    setState(() {
                      driversLicenseFront = null;
                    });
                  },
                ),
              ),
              onPressed: driversLicenseFrontFileName != 'No File Selected' || driversLicenseFront != null ? null : () async{
                final result = await FilePicker.platform.pickFiles(allowMultiple: false, type: FileType.image);
                final path = result.files.single.path;
                setState(() {
                  driversLicenseFront = File(path);
                });
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(bottom: 5),
            child: OutlinedButton(
              child: ListTile(
                title: Text('Driver\'s License Back'),
                subtitle: Text(driversLicenseBackFileName),
                trailing: IconButton(
                  icon: Icon(driversLicenseBackFileName == 'No File Selected' ? Icons.attach_file_rounded: Icons.cancel_rounded, color: Color(0xfffb0d0d),),
                  onPressed:  driversLicenseBackFileName == 'No File Selected' || driversLicenseBack == null ? null : () {
                    setState(() {
                      driversLicenseBack = null;
                    });
                  },
                ),
              ),
              onPressed: driversLicenseBackFileName != 'No File Selected' || driversLicenseBack != null ? null : () async{
                final result = await FilePicker.platform.pickFiles(allowMultiple: false, type: FileType.image);
                final path = result.files.single.path;
                setState(() {
                  driversLicenseBack = File(path);
                });
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(bottom: 5),
            child: OutlinedButton(
              child: ListTile(
                title: Text('NBI Clearance'),
                subtitle: Text(nbiClearancePhotoFileName),
                trailing: IconButton(
                  icon: Icon(nbiClearancePhotoFileName == 'No File Selected' ? Icons.attach_file_rounded: Icons.cancel_rounded, color: Color(0xfffb0d0d),),
                  onPressed:  nbiClearancePhotoFileName == 'No File Selected' || nbiClearancePhoto == null ? null : () {
                    setState(() {
                      nbiClearancePhoto = null;
                    });
                    print(nbiClearancePhoto);
                  },
                ),
              ),
              onPressed: nbiClearancePhotoFileName != 'No File Selected' || nbiClearancePhoto != null ? null : () async{
                final result = await FilePicker.platform.pickFiles(allowMultiple: false, type: FileType.image);
                final path = result.files.single.path;
                setState(() {
                  nbiClearancePhoto = File(path);
                });
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(bottom: 5),
            child: OutlinedButton(
              child: ListTile(
                title: Text('Vehicle Official Receipt (OR)'),
                subtitle: Text(vehicleRegistrationORFileName),
                trailing: IconButton(
                  icon: Icon(vehicleRegistrationORFileName == 'No File Selected' ? Icons.attach_file_rounded: Icons.cancel_rounded, color: Color(0xfffb0d0d),),
                  onPressed:  vehicleRegistrationORFileName == 'No File Selected' || vehicleRegistrationOR == null ? null : () {
                    setState(() {
                      vehicleRegistrationOR = null;
                    });
                    print(vehicleRegistrationOR);
                  },
                ),
              ),
              onPressed: vehicleRegistrationORFileName != 'No File Selected' || vehicleRegistrationOR != null ? null : () async{
                final result = await FilePicker.platform.pickFiles(allowMultiple: false, type: FileType.image);
                final path = result.files.single.path;
                setState(() {
                  vehicleRegistrationOR = File(path);
                });
              },
            ),
          ),

          Padding(
            padding: const EdgeInsets.only(bottom: 5),
            child: OutlinedButton(
              child: ListTile(
                title: Text('Vehicle Official Receipt (CR)'),
                subtitle: Text(vehicleRegistrationCRFileName),
                trailing: IconButton(
                  icon: Icon(vehicleRegistrationCRFileName == 'No File Selected' ? Icons.attach_file_rounded: Icons.cancel_rounded, color: Color(0xfffb0d0d),),
                  onPressed:  vehicleRegistrationCRFileName == 'No File Selected' || vehicleRegistrationCR == null ? null : () {
                    setState(() {
                      vehicleRegistrationCR = null;
                    });
                    print(vehicleRegistrationCR);
                  },
                ),
              ),
              onPressed: vehicleRegistrationCRFileName != 'No File Selected' || vehicleRegistrationCR != null ? null : () async{
                final result = await FilePicker.platform.pickFiles(allowMultiple: false, type: FileType.image);
                final path = result.files.single.path;
                setState(() {
                  vehicleRegistrationCR = File(path);
                });
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(bottom: 5),
            child: OutlinedButton(
              child: ListTile(
                title: Text('Vehicle Photo'),
                subtitle: Text(vehiclePhotoFileName),
                trailing: Padding(
                  padding: const EdgeInsets.only(left: 38),
                  child: IconButton(
                    icon: Icon(vehiclePhotoFileName == 'No File Selected' ? Icons.attach_file_rounded: Icons.cancel_rounded, color: Color(0xfffb0d0d),),
                    onPressed:  vehiclePhotoFileName == 'No File Selected' || vehiclePhoto == null ? null : () {
                      setState(() {
                        vehiclePhoto = null;
                      });
                      print(vehiclePhoto);
                    },
                  ),
                ),
              ),
              onPressed: vehiclePhotoFileName != 'No File Selected' || vehiclePhoto != null ? null : () async{
                final result = await FilePicker.platform.pickFiles(allowMultiple: false, type: FileType.image);
                final path = result.files.single.path;
                setState(() {
                  vehiclePhoto = File(path);
                });
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(bottom: 5),
            child: OutlinedButton(
              child: ListTile(
                title: Text('Vehicle Color'),
                subtitle: Align(
                  alignment: Alignment.bottomLeft,
                  child: Container(
                    width: 20,
                    height: 20,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: color,
                      border: Border.all(),
                    ),
                  ),
                ),
                trailing: IconButton(
                  icon: Icon(Icons.palette, color: Color(0xfffb0d0d),),
                  onPressed: null,
                ),
              ),
              onPressed: () => pickColor(context),
            ),
          ),
          DropdownButtonFormField<String>(
            validator: (value) => value == null ? 'Vehicle type is required' : null,
            decoration: InputDecoration(
              border: new OutlineInputBorder(
                  borderSide: new BorderSide(color: Colors.black)),
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
            items: <String>['Motorcycle', 'Sedan', 'Pickup Truck', 'MPV', 'FB-Type Van', 'Van']
                .map<DropdownMenuItem<String>>((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Text(value),
              );
            }).toList(),
          ),
          Text(notValid ? '': 'Check if your credentials are complete', style: TextStyle(color: Color(0xfffb0d0d))),
        ],
      ),
    ),
    Step(
      state: currentStep > 2 ? StepState.complete: StepState.indexed,
      isActive: currentStep >= 2,
      title: Text('Complete'),
      content: Column(
        children: [
          ListTile(
            leading: Icon(Icons.person_rounded),
            title: Padding(
              padding: const EdgeInsets.only(bottom: 5),
              child: Text('Account Information', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(bottom: 3),
                  child: Text.rich(
                      TextSpan(children: [
                        TextSpan(text: 'Name: ', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),),
                        TextSpan(text: '${fName ?? ''} ${lName ?? ''}', style: TextStyle(fontSize: 15),)
                      ],)
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(bottom: 3),
                  child: Text.rich(
                      TextSpan(children: [
                        TextSpan(text: 'Email: ', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),),
                        TextSpan(text: '${email ?? ''}', style: TextStyle(fontSize: 15),)
                      ],)
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(bottom: 3),
                  child: Text.rich(
                      TextSpan(children: [
                        TextSpan(text: 'Contact Number: ', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),),
                        TextSpan(text: '${contactNo ?? ''}', style: TextStyle(fontSize: 15),)
                      ],)
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(bottom: 3),
                  child: Text.rich(
                      TextSpan(children: [
                        TextSpan(text: 'Home Address: ', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),),
                        TextSpan(text: '${address ?? ''}', style: TextStyle(fontSize: 15),)
                      ],)
                  ),
                ),
              ],
            ),
          ),
          ListTile(
            leading: Icon(Icons.file_present_rounded),
            title: Padding(
              padding: const EdgeInsets.only(bottom: 5),
              child: Text('Credentials', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(bottom: 3),
                  child: Text.rich(
                      TextSpan(children: [
                        TextSpan(text: 'Vehicle Type: ', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),),
                        TextSpan(text: '${vehicleType ?? ''}', style: TextStyle(fontSize: 15),)
                      ],)
                  ),
                ),
                Row(
                  children: [
                    Text('Vehicle Color:', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),),
                    Padding(
                      padding: const EdgeInsets.only(left: 10),
                      child: Container(
                        width: 30,
                        height: 30,
                        decoration: BoxDecoration(
                          border: Border.all(),
                          shape: BoxShape.circle,
                          color: color,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Text('Driver\'s License (Front)', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),),
          if (driversLicenseFront != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 5),
              child: Image.file(driversLicenseFront),
            )
          else Container(),

          Text('Driver\'s License (Back)', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),),
          if (driversLicenseBack != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 5),
              child: Image.file(driversLicenseBack),
            )
          else Container(),

          Text('NBI Clearance', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),),
          if (nbiClearancePhoto != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 5),
              child: Image.file(nbiClearancePhoto),
            )
          else Container(),

          Text('Vehicle Official Receipt (OR)', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),),
          if (vehicleRegistrationOR != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 5),
              child: Image.file(vehicleRegistrationOR),
            )
          else Container(),

          Text('Vehicle Official Receipt (CR)', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),),
          if (vehicleRegistrationCR != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 5),
              child: Image.file(vehicleRegistrationCR),
            )
          else Container(),

          Text('Vehicle Photo', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),),
          if (vehiclePhoto != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 5),
              child: Image.file(vehiclePhoto),
            )
          else Container(),
          Padding(
            padding: const EdgeInsets.only(right: 10),
            child: Row(
              children: [
                Container(
                  child: Checkbox(
                      value: agree,
                      onChanged: (value) {
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
                onSubmit: () {
                  confirm(true);
                },
              ),
            ),
          ),
        ],
      ),
    ),
  ];

  void pickColor(BuildContext context) => showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Choose a color'),
        content: StatefulBuilder(
            builder: (context, setState) {
              return CircleColorPicker(
                  size: const Size(240, 240),
                  strokeWidth: 4,
                  thumbSize: 36,
                  onChanged: (color) {
                    setState(() => this.color = color);
                  },
                  controller: CircleColorPickerController(initialColor: Colors.grey,)
              );
            }
        ),
        actions: [
          TextButton(
              child: Text('SELECT'),
              onPressed: () {
                setState(() => this.color = color);
                Navigator.of(context).pop();
                vehicleColor = color.value;
                print(vehicleColor);
              }
          )
        ],
      ),
  );
}