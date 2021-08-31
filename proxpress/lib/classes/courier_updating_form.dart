import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:proxpress/Load/user_load.dart';
import 'package:proxpress/UI/CourierUI/notif_drawer_courier.dart';
import 'package:proxpress/UI/login_screen.dart';
import 'package:proxpress/models/couriers.dart';
import 'package:proxpress/services/auth.dart';
import 'package:proxpress/services/database.dart';
import 'package:proxpress/models/user.dart';
import 'package:provider/provider.dart';
import 'package:proxpress/models/couriers.dart';
import 'package:proxpress/UI/CustomerUI/notif_drawer_customer.dart';
import 'package:proxpress/services/default_profile_pic.dart';
import 'package:proxpress/services/file_storage.dart';



class CourierUpdate extends StatefulWidget {

  @override
  _CourierUpdateState createState() => _CourierUpdateState();
}

class _CourierUpdateState extends State<CourierUpdate> {
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
  String _newPassword;
  String _confirmPassword;
  String _status = "Active";
  bool _approved = false;
  bool checkCurrentPassword = true;
  String _vehicleType;
  String _vehicleColor;

  final AuthService _auth = AuthService();

  String dots(int Dotlength){
    String dot = "•";
    for(var i = 0; i<Dotlength; i++){
      dot += "•";
    }
    return dot;
  }
  // Future _getDefaultProfile(BuildContext context, String imageName) async {
  //   Image image;
  //   await FireStorageService.loadImage(context, imageName).then((value) {
  //     image = Image.network(
  //       value.toString(),
  //       // fit: BoxFit.scaleDown,
  //     );
  //   });
  //   return image;
  // }

  @override
  Widget build(BuildContext context) {
    final FirebaseAuth _auth = FirebaseAuth.instance;
    User user = _auth.currentUser;

    if (user != null) {
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

                // Navigator.pushNamed(context, '/customerProfile');
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
          endDrawer: NotifDrawerCourier(),
          body: SingleChildScrollView(
            child: StreamBuilder<Courier>(
                stream: DatabaseService(uid: user.uid).courierData,
                builder: (context,snapshot){
                  if(snapshot.hasData){
                    Courier courierData = snapshot.data;
                    return Form(
                      key: _updateKey,
                      child: Column(
                        children: <Widget>[
                          Container(
                            margin: EdgeInsets.only(top: 10),
                            child: Text(
                              "Edit Profile",
                              style: TextStyle(
                                fontSize: 25,
                              ),
                            ),
                          ),
                          Container(
                            margin: EdgeInsets.only(top: 10),
                            child: Stack(
                              children: [
                                Container(
                                  child: ClipOval(
                                    child: Image.network('https://firebasestorage.googleapis.com/v0/b/proxpress-629e3.appspot.com/o/profile-user.png?alt=media&token=6727618b-4289-4438-8a93-a4f14753d92e',
                                      width:100,
                                      height: 100,
                                    ),
                                  ),
                                ),
                                Positioned(
                                  bottom: 0,
                                  //right : 10,
                                  left: 70,
                                  child: ClipOval(
                                    child: SizedBox(
                                      height: 30,
                                      width: 30,
                                      child: Container(
                                        color: Color(0xfffb0d0d),
                                        child: IconButton(
                                            iconSize: 16,
                                            icon: Icon(Icons.edit_rounded,color: Colors.white,),
                                            onPressed: () async{
                                              // XFile image = await ImagePicker().pickImage(source: ImageSource.gallery);
                                              // print(image.path);
                                              //  await _auth.uploadProfilePicture(File(image.path));
                                              //  setState(() {
                                              //
                                              //  });
                                            }
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            child: TextFormField(
                              initialValue: "${courierData.fName}",
                              decoration: InputDecoration(labelText:
                              'First Name:',
                                hintText: "${courierData.fName}",
                                floatingLabelBehavior: FloatingLabelBehavior.always,
                                labelStyle: TextStyle(
                                    fontStyle: FontStyle.italic,
                                    color: Colors.green
                                ),
                              ),
                              validator: (String val) => val.isEmpty ? 'Enter your new first name' : null,
                              onChanged: (val) => setState(() => _currentFName = val),
                            ),
                          ),
                          Container(
                            child: TextFormField(
                              initialValue: "${courierData.lName}",
                              decoration: InputDecoration(labelText:
                              'Last Name:',
                                hintText: "${courierData.lName}",
                                floatingLabelBehavior: FloatingLabelBehavior.always,
                                labelStyle: TextStyle(
                                    fontStyle: FontStyle.italic,
                                    color: Colors.green
                                ),
                              ),
                              validator: (String val) => val.isEmpty ? 'Enter your new last name' : null,
                              onChanged: (val) => setState(() => _currentLName = val),
                            ),
                          ),
                          Container(
                            child: TextFormField(
                              initialValue: "${courierData.address}",
                              decoration: InputDecoration(labelText:
                              'Address:',
                                hintText: "${courierData.address}",
                                floatingLabelBehavior: FloatingLabelBehavior.always,
                                labelStyle: TextStyle(
                                    fontStyle: FontStyle.italic,
                                    color: Colors.green
                                ),
                              ),
                              keyboardType: TextInputType.streetAddress,
                              validator: (String val) => val.isEmpty ? 'Enter your new address' : null,
                              onChanged: (val) => setState(() => _currentAddress = val),
                            ),
                          ),
                          Container(
                            child: TextFormField(
                              initialValue: "${courierData.email}",
                              decoration: InputDecoration(labelText:
                              'Email:',
                                hintText: "${courierData.email}",
                                floatingLabelBehavior: FloatingLabelBehavior.always,
                                labelStyle: TextStyle(
                                    fontStyle: FontStyle.italic,
                                    color: Colors.green
                                ),
                              ),
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
                              onChanged: (val) => setState(() => _currentEmail = val),
                            ),
                          ),
                          Container(
                            child: TextFormField(
                              initialValue: "${courierData.contactNo}",
                              decoration: InputDecoration(labelText:
                              'Contact No:',
                                hintText: "${courierData.contactNo}",
                                floatingLabelBehavior: FloatingLabelBehavior.always,
                                labelStyle: TextStyle(
                                    fontStyle: FontStyle.italic,
                                    color: Colors.green
                                ),
                              ),
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
                              onChanged: (val) => setState(() => _currentContactNo = val),
                            ),
                          ),
                          // DropdownButtonFormField<String>(
                          //   validator: (value) => value == null ? 'Vehicle type is required' : null,
                          //   decoration: InputDecoration(
                          //     labelText: 'Vehicle Type:',
                          //     hintText: "${courierData.vehicleType}",
                          //     floatingLabelBehavior: FloatingLabelBehavior.always,
                          //     labelStyle: TextStyle(
                          //         fontStyle: FontStyle.italic,
                          //         color: Colors.green
                          //     ),
                          //   ),
                          //   isExpanded: true,
                          //   icon: const Icon(Icons.arrow_downward),
                          //   iconSize: 24,
                          //   elevation: 16,
                          //   onChanged: (String newValue) {
                          //     setState(() {
                          //       _vehicleType = newValue;
                          //     });
                          //   },
                          //   items: <String>['Motorcycle', 'Sedan', 'Pickup Truck', 'Multi-purpose Vehicle', 'Family-business Van', 'Multi-purpose Van']
                          //       .map<DropdownMenuItem<String>>((String value) {
                          //     return DropdownMenuItem<String>(
                          //       value: value,
                          //       child: Text(value),
                          //     );
                          //   }).toList(),
                          // ),
                          Container(
                            child: TextFormField(
                              initialValue: "${courierData.vehicleColor}",
                              decoration: InputDecoration(labelText:
                              'Vehicle Color:',
                                hintText: "${courierData.vehicleColor}",
                                floatingLabelBehavior: FloatingLabelBehavior.always,
                                labelStyle: TextStyle(
                                    fontStyle: FontStyle.italic,
                                    color: Colors.green
                                ),
                              ),
                              validator: (String val) => val.isEmpty ? 'Enter your vehicle color' : null,
                              onChanged: (val) => setState(() => _vehicleColor = val),
                            ),
                          ),
                          Container(
                            child: Center(
                              child: Text(
                                "Manage Password",
                                style: TextStyle(
                                  fontSize: 20,
                                  color: Colors.black54,
                                ),
                              ),
                            ),
                          ),
                          Container(
                            child: TextFormField(
                              obscureText: true,
                              decoration: InputDecoration(labelText:
                              'Password:',
                                hintText: dots(courierData.password.length),
                                floatingLabelBehavior: FloatingLabelBehavior.always,
                                errorText: (checkCurrentPassword ?
                                null :
                                "Please double check your current password"
                                ),
                                labelStyle: TextStyle(
                                    fontStyle: FontStyle.italic,
                                    color: Colors.green
                                ),
                              ),
                              validator: (String val){
                                if(val.length < 8 && val.length > 0){
                                  return 'Password should be 8 characters long';
                                }
                                else
                                  return null;
                              },
                              //initialValue: "${customerData.password}",
                              onChanged: (val) => setState(() => _currentPassword = val),
                            ),
                          ),
                          Container(
                            child: TextFormField(
                              obscureText: true,
                              decoration: InputDecoration(labelText:
                              'New Password:',
                                floatingLabelBehavior: FloatingLabelBehavior.always,
                                labelStyle: TextStyle(
                                  fontStyle: FontStyle.italic,
                                  color: Colors.green,
                                ),
                              ),
                              validator: (String val){
                                if(val.length < 8 && val.length > 0){
                                  return 'Password should be 8 characters long';
                                } else if(_currentPassword != null){
                                  if(val.isEmpty){
                                    return 'Kindly provide your new password';
                                  } else {
                                    return null;
                                  }
                                }
                                else
                                  return null;
                              },
                              onChanged: (val) => setState(() => _newPassword = val),
                            ),
                          ),
                          Container(
                            child: TextFormField(
                              obscureText: true,
                              decoration: InputDecoration(labelText:
                              'Repeat Password:',
                                floatingLabelBehavior: FloatingLabelBehavior.always,
                                labelStyle: TextStyle(
                                    fontStyle: FontStyle.italic,
                                    color: Colors.green
                                ),
                              ),
                              validator: (String val){
                                if(_currentPassword != null){
                                  if(val.isEmpty){
                                    return "Kindly provide repeat password for verification";
                                  } else if(_newPassword != val){
                                    return "Password does not match";
                                  } else {
                                    return null;
                                  }
                                }
                                else
                                  return null;
                              },
                              onChanged: (val) => setState(() => _confirmPassword = val),
                            ),
                          ),
                          Container(
                            margin: EdgeInsets.only(right: 20),
                            child: Align(
                              alignment: Alignment.topRight,
                              child: ElevatedButton(
                                  child: Text(
                                    'Save Changes', style: TextStyle(color: Colors.white, fontSize:15),
                                  ),
                                  style: ElevatedButton.styleFrom(
                                    primary: Color(0xfffb0d0d),
                                  ),
                                  onPressed: () async {
                                    final Courier validCourier = Courier();

                                    if(_currentPassword != null)
                                      checkCurrentPassword = await validCourier.validateCurrentPassword(_currentPassword);
                                    setState(() {

                                    });
                                    if (_updateKey.currentState.validate() && checkCurrentPassword) {
                                      validCourier.updateCurrentEmail(_currentEmail);
                                      validCourier.updateCurrentPassword(_newPassword);

                                      await DatabaseService(uid: user.uid)
                                          .updateCourierData(
                                        _currentFName ?? courierData.fName,
                                        _currentLName ?? courierData.lName,
                                        _currentEmail ?? courierData.email,
                                        _currentContactNo ?? courierData.contactNo,
                                        _confirmPassword ?? courierData.password,
                                        _currentAddress ?? courierData.address,
                                        _status ?? courierData.status,
                                        _approved ?? courierData.approved,
                                        _vehicleType ?? courierData.vehicleType,
                                        _vehicleColor ?? courierData.vehicleColor,
                                      );
                                      Navigator.pop(context, false);
                                    }
                                  }
                              ),
                            ),
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
    } else {
      return LoginScreen();
    }
  }
}