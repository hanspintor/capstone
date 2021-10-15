import 'dart:async';
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
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
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:proxpress/services/upload_file.dart';

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
  bool checkCurrentPassword = true;
  String _vehicleType;
  String _vehicleColor;
  static Timer _sessionTimer;
  static Timer _sessionTimerPrint;
  int count = 0;
  int duration = 1;
  final AuthService _auth = AuthService();

  File profilePicture;
  bool uploadedNewPic = false;
  String savedUrl = '';
  String saveDestination = '';

  //String avatarUrl;
  String fetchedUrl;
  String defaultProfilePic = 'https://firebasestorage.googleapis.com/v0/b/proxpress-629e3.appspot.com/o/profile-user.png?alt=media&token=6727618b-4289-4438-8a93-a4f14753d92e';

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
  void handleTimeOut() async{
    await _auth.signOut();
  }

  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    final FirebaseAuth _auth = FirebaseAuth.instance;
    User user = _auth.currentUser;

      return new GestureDetector(
        onTap: (){
          if(count != 0){
            print("Session Revived");
          } else {
            print("Session Started");
            count=1;
          }
          _sessionTimer?.cancel();
          _sessionTimer = new Timer(Duration(minutes: duration), handleTimeOut);
          _sessionTimerPrint?.cancel();
          _sessionTimerPrint = new Timer(Duration(minutes: duration), () {
            print("Session Expired");
          });

        },
        child: user == null ? LoginScreen() : Scaffold(
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
                      fetchedUrl = courierData.avatarUrl;

                      Widget saveChanges(String field){
                        return Container(
                          margin: EdgeInsets.only(right: 20),
                          child: Align(
                            alignment: Alignment.topRight,
                            child: ElevatedButton.icon(
                                icon: Icon(Icons.save),
                                label: Text(
                                  'Save', style: TextStyle(color: Colors.white, fontSize:15),
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
                                    if(_currentEmail != null)
                                      validCourier.updateCurrentEmail(_currentEmail);
                                    if(_newPassword != null)
                                      validCourier.updateCurrentPassword(_newPassword);
                                    if(field == 'Full Name'){
                                      await DatabaseService(uid:user.uid).updateCourierFullName(_currentFName ?? courierData.fName, _currentLName ?? courierData.lName);
                                    }
                                    else if(field == 'Address'){
                                      await DatabaseService(uid:user.uid).updateCourierAddress(_currentAddress);
                                    }
                                    else if(field == 'Email'){
                                      await DatabaseService(uid:user.uid).updateCourierEmail(_currentEmail);
                                    }
                                    else if(field == 'Contact No'){
                                      await DatabaseService(uid:user.uid).updateCourierContactNo(_currentContactNo);
                                    }
                                    else if(field == 'Password'){
                                      await DatabaseService(uid:user.uid).updateCourierPassword(_currentPassword);
                                    }

                                    showToast('Changes has been saved.');
                                    Navigator.pop(context, false);
                                  }
                                }
                            ),
                          ),
                        );
                      }

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
                                    child: CircleAvatar(
                                      radius: 55,
                                      backgroundImage: uploadedNewPic
                                          ? FileImage(File(profilePicture.path))
                                          : NetworkImage(fetchedUrl),
                                      backgroundColor: Colors.white,
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
                                                String datetime = DateTime.now().toString();

                                                final result = await FilePicker.platform.pickFiles(allowMultiple: false);

                                                final pathProfilePicUploaded = result.files.single.path;
                                                setState(() {
                                                  uploadedNewPic = true;
                                                  profilePicture = File(pathProfilePicUploaded);
                                                });

                                                final profilePictureDestination = 'Couriers/${user.uid}/profilepic_${user.uid}_$datetime';

                                                setState((){
                                                  saveDestination = profilePictureDestination.toString();
                                                  if (saveDestination != null && saveDestination.length > 0) {
                                                    saveDestination = saveDestination.substring(0, saveDestination.length - 1);
                                                  }
                                                });
                                              }
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.fromLTRB(0,20,0,0),
                              child: Column(
                                children: [
                                  OutlinedButton(
                                    child: ListTile(
                                      title: Text('Full Name', style: TextStyle(fontWeight: FontWeight.bold)),
                                      subtitle: Text("${courierData.fName} ${courierData.lName}"),
                                      trailing: Icon(Icons.chevron_right_rounded),
                                    ),
                                    onPressed: () {
                                      showMaterialModalBottomSheet(
                                        context: context,
                                        builder: (context) => SingleChildScrollView(
                                          controller: ModalScrollController.of(context),
                                          child: Container(
                                            child: Column(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                Padding(
                                                  padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
                                                  child: Column(
                                                    children: [
                                                      Padding(
                                                        padding: const EdgeInsets.all(8),
                                                        child: TextFormField(
                                                          decoration: InputDecoration(labelText:
                                                          'First Name:',
                                                            hintText: "${courierData.fName}",
                                                            floatingLabelBehavior: FloatingLabelBehavior.always,
                                                            labelStyle: TextStyle(
                                                                fontStyle: FontStyle.italic,
                                                                color: Colors.black
                                                            ),
                                                          ),
                                                          onChanged: (val) => setState(() => _currentFName = val),
                                                        ),
                                                      ),
                                                      Padding(
                                                        padding: EdgeInsets.all(8),
                                                        child: TextFormField(
                                                          decoration: InputDecoration(labelText:
                                                          'Last Name:',
                                                            hintText: "${courierData.lName}",
                                                            floatingLabelBehavior: FloatingLabelBehavior.always,
                                                            labelStyle: TextStyle(
                                                                fontStyle: FontStyle.italic,
                                                                color: Colors.black
                                                            ),
                                                          ),
                                                          onChanged: (val) => setState(() => _currentLName = val),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                                saveChanges('Full Name'),
                                              ],

                                            ),
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                  OutlinedButton(
                                    child: ListTile(
                                      title: Text('Address', style: TextStyle(fontWeight: FontWeight.bold)),
                                      subtitle: Text("${courierData.address}"),
                                      trailing: Icon(Icons.chevron_right_rounded),
                                    ),
                                    onPressed: () {
                                      showMaterialModalBottomSheet(
                                        context: context,
                                        builder: (context) => SingleChildScrollView(
                                          controller: ModalScrollController.of(context),
                                          child: Container(
                                            child: Column(
                                              children: [
                                                Padding(
                                                  padding: EdgeInsets.fromLTRB(8,8,8,MediaQuery.of(context).viewInsets.bottom),
                                                  child: TextFormField(
                                                    decoration: InputDecoration(
                                                      hintText: "${courierData.address}",
                                                      floatingLabelBehavior: FloatingLabelBehavior.always,
                                                      labelStyle: TextStyle(
                                                          fontStyle: FontStyle.italic,
                                                          color: Colors.black
                                                      ),
                                                    ),
                                                    keyboardType: TextInputType.streetAddress,
                                                    onChanged: (val) => setState(() => _currentAddress = val),
                                                  ),
                                                ),
                                                saveChanges('Address'),
                                              ],

                                            ),
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                  OutlinedButton(
                                      child: ListTile(
                                        title: Text('Email', style: TextStyle(fontWeight: FontWeight.bold)),
                                        subtitle: Text("${courierData.email}"),
                                        trailing: Icon(Icons.chevron_right_rounded),
                                      ),
                                      onPressed: () {
                                        showMaterialModalBottomSheet(
                                          context: context,
                                          builder: (context) => SingleChildScrollView(
                                            controller: ModalScrollController.of(context),
                                            child: Container(
                                              child: Column(
                                                children: [
                                                  Padding(
                                                    padding: EdgeInsets.fromLTRB(8,8,8,MediaQuery.of(context).viewInsets.bottom),
                                                    child: TextFormField(
                                                      decoration: InputDecoration(
                                                        hintText: "${courierData.email}",
                                                        floatingLabelBehavior: FloatingLabelBehavior.always,
                                                        labelStyle: TextStyle(
                                                            fontStyle: FontStyle.italic,
                                                            color: Colors.black
                                                        ),
                                                      ),
                                                      validator: (String val){
                                                        if(val.isEmpty){
                                                          return null;
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
                                                  saveChanges('Email'),
                                                ],

                                              ),
                                            ),
                                          ),
                                        );
                                      }
                                  ),
                                  OutlinedButton(
                                    child: ListTile(
                                      title: Text('Contact Number', style: TextStyle(fontWeight: FontWeight.bold)),
                                      subtitle: Text("${courierData.contactNo}"),
                                      trailing: Icon(Icons.chevron_right_rounded),
                                    ),
                                    onPressed: (){
                                      showMaterialModalBottomSheet(
                                        context: context,
                                        builder: (context) => SingleChildScrollView(
                                          controller: ModalScrollController.of(context),
                                          child: Container(
                                            child: Column(
                                              children: [
                                                Padding(
                                                  padding: EdgeInsets.fromLTRB(8,8,8,MediaQuery.of(context).viewInsets.bottom),
                                                  child: TextFormField(
                                                    decoration: InputDecoration(
                                                      hintText: "${courierData.contactNo}",
                                                      floatingLabelBehavior: FloatingLabelBehavior.always,
                                                      labelStyle: TextStyle(
                                                          fontStyle: FontStyle.italic,
                                                          color: Colors.black
                                                      ),
                                                    ),
                                                    maxLength: 11,
                                                    keyboardType: TextInputType.number,
                                                    validator: (String val){
                                                      if(val.length < 11 && val.length > 0){
                                                        return 'Your contact number should be 11 digits';
                                                      }
                                                      else
                                                        return null;
                                                    },
                                                    onChanged: (val) => setState(() => _currentContactNo = val),
                                                  ),
                                                ),
                                                saveChanges('Contact No'),
                                              ],
                                            ),
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                  OutlinedButton(
                                    child: ListTile(
                                      title: Text('Change Password', style: TextStyle(fontWeight: FontWeight.bold)),
                                      subtitle: Text(dots(courierData.password.length)),
                                      trailing: Icon(Icons.chevron_right_rounded),
                                    ),
                                    onPressed: () {
                                      showMaterialModalBottomSheet(
                                        context: context,
                                        builder: (context) => SingleChildScrollView(
                                          controller: ModalScrollController.of(context),
                                          child: Container(
                                            child: Column(
                                              children: [
                                                Padding(
                                                  padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
                                                  child: Column(
                                                    children: [
                                                      Padding(
                                                        padding: const EdgeInsets.all(15),
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
                                                                color: Colors.black
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
                                                      Padding(
                                                        padding: const EdgeInsets.all(15),
                                                        child: TextFormField(
                                                          obscureText: true,
                                                          decoration: InputDecoration(labelText:
                                                          'New Password:',
                                                            floatingLabelBehavior: FloatingLabelBehavior.always,
                                                            labelStyle: TextStyle(
                                                              fontStyle: FontStyle.italic,
                                                              color: Colors.black,
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
                                                      Padding(
                                                        padding: const EdgeInsets.all(15),
                                                        child: TextFormField(
                                                          obscureText: true,
                                                          decoration: InputDecoration(labelText:
                                                          'Repeat Password:',
                                                            floatingLabelBehavior: FloatingLabelBehavior.always,
                                                            labelStyle: TextStyle(
                                                                fontStyle: FontStyle.italic,
                                                                color: Colors.black
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
                                                    ],
                                                  ),
                                                ),
                                                saveChanges('Password'),
                                              ],
                                            ),
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                ],
                              ),
                            )
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
        ),
      );
  }
  Future showToast(String message) async {
    await Fluttertoast.cancel();
    Fluttertoast.showToast(msg: message, fontSize: 18, backgroundColor: Colors.grey, textColor: Colors.black);
  }
}