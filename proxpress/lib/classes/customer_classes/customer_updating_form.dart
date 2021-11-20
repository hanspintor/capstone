import 'dart:async';
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:loader_overlay/loader_overlay.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:page_transition/page_transition.dart';
import 'package:proxpress/Load/user_load.dart';
import 'package:proxpress/UI/CustomerUI/proxpress_template_customer.dart';
import 'package:proxpress/UI/login_screen.dart';
import 'package:proxpress/services/database.dart';
import 'package:proxpress/models/user.dart';
import 'package:provider/provider.dart';
import 'package:proxpress/models/customers.dart';
import 'package:proxpress/UI/CustomerUI/notif_drawer_customer.dart';
import 'package:proxpress/services/upload_file.dart';

class CustomerUpdate extends StatefulWidget {
  @override
  _CustomerUpdateState createState() => _CustomerUpdateState();
}

class _CustomerUpdateState extends State<CustomerUpdate> {
  void _openEndDrawer() {
    _scaffoldKey.currentState.openEndDrawer();
  }

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final GlobalKey<FormState> _fullNameKey = GlobalKey<FormState>();
  final GlobalKey<FormState> _addressKey = GlobalKey<FormState>();
  final GlobalKey<FormState> _emailKey = GlobalKey<FormState>();
  final GlobalKey<FormState> _contactNumKey = GlobalKey<FormState>();
  final GlobalKey<FormState> _passKey = GlobalKey<FormState>();

  final Customer validCustomer = Customer();


  String _currentFName;
  String _currentLName;
  String _currentAddress;
  String _currentEmail;
  String _currentContactNo;
  String _currentPassword;
  String _newPassword;
  String _confirmPassword;
  List bookmarks;
  bool checkCurrentPassword = true;
  bool checkCurrentEmail = true;

  File profilePicture;
  bool uploadedNewPic = false;
  String savedUrl = '';
  String saveDestination = '';

  // bool _isLoading = false;
  String fetchedUrl;
  String defaultProfilePic = 'https://firebasestorage.googleapis.com/v0/b/proxpress-629e3.appspot.com/o/profile-user.png?alt=media&token=6727618b-4289-4438-8a93-a4f14753d92e';

  String dots(int dotLength){
    String dot = "•";
    for(var i = 0; i < dotLength; i++){
      dot += "•";
    }
    return dot;
  }

  @override
  Widget build(BuildContext context) {
    void processDone() {
      showToast('Changes has been saved.');
      Navigator.pop(context, false);
    }

    final user = Provider.of<TheUser>(context);

    final auth = FirebaseAuth.instance;

    return user == null ? LoginScreen() : Scaffold(
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
        endDrawer: NotifDrawerCustomer(),
        body: LoaderOverlay(
          child: SingleChildScrollView(
            child: StreamBuilder<Customer>(
                stream: DatabaseService(uid: user.uid).customerData,
                builder: (context,snapshot){
                  if(snapshot.hasData){
                    Customer customerData = snapshot.data;
                    fetchedUrl = customerData.avatarUrl;
                    return Column(
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
                                        icon: Icon(!uploadedNewPic ? Icons.edit_rounded : Icons.save,color: Colors.white,),
                                        onPressed: !uploadedNewPic ? () async {
                                          String datetime = DateTime.now().toString();

                                          final result = await FilePicker.platform.pickFiles(allowMultiple: false, type: FileType.image);

                                          final pathProfilePicUploaded = result.files.single.path;
                                          setState(() {
                                            uploadedNewPic = true;
                                            profilePicture = File(pathProfilePicUploaded);
                                          });

                                          final profilePictureDestination = 'Customers/${user.uid}/profilepic_${user.uid}_$datetime';

                                          setState((){
                                            saveDestination = profilePictureDestination.toString();
                                            if (saveDestination != null && saveDestination.length > 0) {
                                              saveDestination = saveDestination.substring(0, saveDestination.length - 1);
                                            }
                                          });
                                        } : () async {
                                          context.loaderOverlay.show();
                                          await UploadFile.uploadFile(saveDestination, profilePicture);

                                          savedUrl = await FirebaseStorage.instance
                                              .ref(saveDestination)
                                              .getDownloadURL();

                                          if (savedUrl != null || savedUrl == 'null') {
                                            await DatabaseService(uid: user.uid).updateCustomerProfilePic(savedUrl);
                                          }

                                          setState(() {
                                            fetchedUrl = savedUrl;
                                            uploadedNewPic = false;
                                          });
                                          context.loaderOverlay.hide();
                                          showToast('Changes has been saved.');
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
                                  subtitle: Text("${customerData.fName} ${customerData.lName}"),
                                  trailing: Icon(Icons.chevron_right_rounded),
                                ),
                                onPressed: () {
                                  showMaterialModalBottomSheet(
                                    context: context,
                                    builder: (context) => SingleChildScrollView(
                                      controller: ModalScrollController.of(context),
                                      child: Form(
                                        key: _fullNameKey,
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
                                                          hintText: "${customerData.fName}",
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
                                                          hintText: "${customerData.lName}",
                                                          floatingLabelBehavior: FloatingLabelBehavior.always,
                                                          labelStyle: TextStyle(
                                                              fontStyle: FontStyle.italic,
                                                              color: Colors.black
                                                          ),
                                                        ),
                                                        onChanged: (val) => setState(() => _currentLName = val),
                                                      ),
                                                    ),
                                                    Container(
                                                      margin: EdgeInsets.only(right: 20),
                                                      child: Align(
                                                        alignment: Alignment.topRight,
                                                        child: ElevatedButton.icon(
                                                          icon: Icon(Icons.save),
                                                          label: Text('Save', style: TextStyle(color: Colors.white, fontSize:15),),
                                                          style: ElevatedButton.styleFrom(
                                                            primary: Color(0xfffb0d0d),
                                                          ),
                                                          onPressed: () async {
                                                            if (_fullNameKey.currentState.validate()) {
                                                              await DatabaseService(uid:user.uid).updateCustomerFullName(_currentFName == '' ? customerData.fName : _currentFName ?? customerData.fName, _currentLName == '' ? customerData.lName : _currentLName ?? customerData.lName);
                                                              processDone();
                                                            }
                                                          },
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ],

                                          ),
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              ),
                              OutlinedButton(
                                child: ListTile(
                                  title: Text('Address', style: TextStyle(fontWeight: FontWeight.bold)),
                                  subtitle: Text("${customerData.address}"),
                                  trailing: Icon(Icons.chevron_right_rounded),
                                ),
                                onPressed: () {
                                  showMaterialModalBottomSheet(
                                    context: context,
                                    builder: (context) => SingleChildScrollView(
                                      controller: ModalScrollController.of(context),
                                      child: Form(
                                        key: _addressKey,
                                        child: Container(
                                          child: Padding(
                                            padding: EdgeInsets.fromLTRB(8,8,8,MediaQuery.of(context).viewInsets.bottom),
                                            child: Column(
                                              children: [
                                                Padding(
                                                  padding: const EdgeInsets.all(8),
                                                  child: TextFormField(
                                                    decoration: InputDecoration(
                                                      hintText: "${customerData.address}",
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
                                                Container(
                                                  margin: EdgeInsets.only(right: 20),
                                                  child: Align(
                                                    alignment: Alignment.topRight,
                                                    child: ElevatedButton.icon(
                                                      icon: Icon(Icons.save),
                                                      label: Text('Save', style: TextStyle(color: Colors.white, fontSize:15),),
                                                      style: ElevatedButton.styleFrom(
                                                        primary: Color(0xfffb0d0d),
                                                      ),
                                                      onPressed: () async {
                                                        if (_addressKey.currentState.validate()) {
                                                          await DatabaseService(uid:user.uid).updateCustomerAddress(_currentAddress == '' ? customerData.address : _currentAddress ?? customerData.address);
                                                          processDone();
                                                        }
                                                      },
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              ),
                              OutlinedButton(
                                  child: ListTile(
                                    title: Text('Email', style: TextStyle(fontWeight: FontWeight.bold)),
                                    subtitle: Text("${customerData.email}"),
                                    trailing: Icon(Icons.chevron_right_rounded),
                                  ),
                                  onPressed: () {
                                    showMaterialModalBottomSheet(
                                      context: context,
                                      builder: (context) => Form(
                                        key: _emailKey,
                                        child: SingleChildScrollView(
                                          controller: ModalScrollController.of(context),
                                          child: Container(
                                            child: Padding(
                                              padding: EdgeInsets.fromLTRB(8,8,8,MediaQuery.of(context).viewInsets.bottom),
                                              child: Column(
                                                children: [
                                                  Padding(
                                                    padding: const EdgeInsets.all(8.0),
                                                    child: TextFormField(
                                                      decoration: InputDecoration(
                                                        hintText: "${customerData.email}",
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
                                                        else return null;
                                                          },
                                                      onChanged: (val) => setState(() => _currentEmail = val),
                                                    ),
                                                  ),
                                                  Container(
                                                    margin: EdgeInsets.only(right: 20),
                                                    child: Align(
                                                      alignment: Alignment.topRight,
                                                      child: ElevatedButton.icon(
                                                        icon: Icon(Icons.save),
                                                        label: Text('Save', style: TextStyle(color: Colors.white, fontSize:15),),
                                                        style: ElevatedButton.styleFrom(
                                                          primary: Color(0xfffb0d0d),
                                                        ),
                                                        onPressed: () async {
                                                          if (_emailKey.currentState.validate()) {
                                                            if (_currentEmail != null ) {
                                                              await DatabaseService(uid:user.uid).updateCustomerEmail(_currentEmail);
                                                              validCustomer.updateCurrentEmail(_currentEmail);
                                                              showToast("Pleaser verify your ${_currentEmail}");
                                                              Timer(Duration(seconds: 2), () {
                                                                Navigator.popAndPushNamed(context, '/template');
                                                              });

                                                            } else {
                                                              Navigator.pop(context);
                                                            }
                                                          }
                                                        },
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    );
                                  }
                              ),
                              OutlinedButton(
                                child: ListTile(
                                  title: Text('Contact Number', style: TextStyle(fontWeight: FontWeight.bold)),
                                  subtitle: Text("${customerData.contactNo}"),
                                  trailing: Icon(Icons.chevron_right_rounded),
                                ),
                                onPressed: (){
                                  showMaterialModalBottomSheet(
                                    context: context,
                                    builder: (context) => SingleChildScrollView(
                                      controller: ModalScrollController.of(context),
                                      child: Form(
                                        key: _contactNumKey,
                                        child: Container(
                                          child: Padding(
                                            padding: EdgeInsets.fromLTRB(8,8,8,MediaQuery.of(context).viewInsets.bottom),
                                            child: Column(
                                              children: [
                                                Padding(
                                                  padding: const EdgeInsets.all(8.0),
                                                  child: TextFormField(
                                                    decoration: InputDecoration(
                                                      hintText: "${customerData.contactNo}",
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
                                                Container(
                                                  margin: EdgeInsets.only(right: 20),
                                                  child: Align(
                                                    alignment: Alignment.topRight,
                                                    child: ElevatedButton.icon(
                                                      icon: Icon(Icons.save),
                                                      label: Text('Save', style: TextStyle(color: Colors.white, fontSize:15),),
                                                      style: ElevatedButton.styleFrom(
                                                        primary: Color(0xfffb0d0d),
                                                      ),
                                                      onPressed: () async {
                                                        if (_contactNumKey.currentState.validate()) {
                                                          await DatabaseService(uid:user.uid).updateCustomerContactNo(_currentContactNo == '' ? customerData.contactNo : _currentContactNo ?? customerData.contactNo);
                                                          processDone();
                                                        }
                                                      },
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              ),
                              OutlinedButton(
                                child: ListTile(
                                  title: Text('Change Password', style: TextStyle(fontWeight: FontWeight.bold)),
                                  subtitle: Text(dots(customerData.password.length)),
                                  trailing: Icon(Icons.chevron_right_rounded),
                                ),
                                onPressed: () async {
                                  await showMaterialModalBottomSheet(
                                    context: context,
                                    builder: (context) => SingleChildScrollView(
                                      controller: ModalScrollController.of(context),
                                      child: Form(
                                        key: _passKey,
                                        child: Container(
                                          child: Padding(
                                            padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
                                            child: Column(
                                              children: [
                                                Padding(
                                                  padding: const EdgeInsets.all(8.0),
                                                  child: Column(
                                                    children: [
                                                      Padding(
                                                        padding: const EdgeInsets.all(15),
                                                        child: TextFormField(
                                                          obscureText: true,
                                                          decoration: InputDecoration(labelText:
                                                          'Password:',
                                                            hintText: dots(customerData.password.length),
                                                            floatingLabelBehavior: FloatingLabelBehavior.always,
                                                            labelStyle: TextStyle(
                                                                fontStyle: FontStyle.italic,
                                                                color: Colors.black
                                                            ),
                                                          ),
                                                          validator: (String val){
                                                            if (val.length < 8 && val.length > 0) {
                                                              return 'Password should be 8 characters long';
                                                            } else if (val != customerData.password) {
                                                              return 'Please double check your current password';
                                                            } else
                                                              return null;
                                                          },
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
                                                            if(_newPassword != null){
                                                              if(val.isEmpty){
                                                                return "Kindly provide repeat password for verification";
                                                              } else if(_newPassword != _confirmPassword){
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
                                                Container(
                                                  margin: EdgeInsets.only(right: 20),
                                                  child: Align(
                                                    alignment: Alignment.topRight,
                                                    child: ElevatedButton.icon(
                                                      icon: Icon(Icons.save),
                                                      label: Text('Save', style: TextStyle(color: Colors.white, fontSize:15),),
                                                      style: ElevatedButton.styleFrom(
                                                        primary: Color(0xfffb0d0d),
                                                      ),
                                                      onPressed: () async {
                                                        if (_passKey.currentState.validate()) {
                                                          checkCurrentPassword = await validCustomer.validateCurrentPassword(_currentPassword);
                                                          if(_newPassword != null && checkCurrentPassword) {
                                                            await DatabaseService(uid:user.uid).updateCustomerPassword(_newPassword);
                                                            validCustomer.updateCurrentPassword(_newPassword);
                                                            processDone();
                                                          }
                                                        }
                                                      },
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
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
                    );
                  }
                  else{
                    return UserLoading();
                  }
                }
            ),
          ),
        )
    );
  }

  Future showToast(String message) async {
    await Fluttertoast.cancel();
    Fluttertoast.showToast(msg: message, fontSize: 18, backgroundColor: Colors.grey, textColor: Colors.black);
  }
}