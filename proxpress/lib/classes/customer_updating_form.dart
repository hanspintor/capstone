import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:proxpress/Load/user_load.dart';
import 'package:proxpress/services/auth.dart';
import 'package:proxpress/services/database.dart';
import 'package:proxpress/models/user.dart';
import 'package:provider/provider.dart';
import 'package:proxpress/models/customers.dart';
import  'package:proxpress/UI/notif_drawer.dart';
import 'package:proxpress/services/default_profile_pic.dart';
import 'package:proxpress/services/file_storage.dart';



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
  String _newPassword;
  String _confirmPassword;
  bool checkCurrentPassword = true;

  final AuthService _auth = AuthService();

  String dots(int Dotlength){
    String dot = "•";
    for(var i = 0; i<Dotlength; i++){
      dot += "•";
    }
    return dot;
  }
  Future _getDefaultProfile(BuildContext context, String imageName) async {
    Image image;
    await FireStorageService.loadImage(context, imageName).then((value) {
      image = Image.network(
        value.toString(),
        // fit: BoxFit.scaleDown,
      );
    });
    return image;
  }

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
                              ClipOval(
                                child: FutureBuilder(
                                    future: _getDefaultProfile(context, "profile-user.png"),
                                    builder: (context, snapshot) {
                                      return Container(
                                        width: MediaQuery.of(context).size.width / 4,
                                        height: MediaQuery.of(context).size.width / 4,
                                        child: snapshot.data,
                                      );
                                    }
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
                                               XFile image = await ImagePicker().pickImage(source: ImageSource.gallery);
                                               print(image.path);
                                                await _auth.uploadProfilePicture(File(image.path));
                                                setState(() {

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
                        Container(
                          child: TextFormField(
                            initialValue: "${customerData.fName}",
                            decoration: InputDecoration(labelText:
                            'First Name:',
                              hintText: "${customerData.fName}",
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
                            initialValue: "${customerData.lName}",
                            decoration: InputDecoration(labelText:
                            'Last Name:',
                              hintText: "${customerData.lName}",
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
                            initialValue: "${customerData.address}",
                            decoration: InputDecoration(labelText:
                            'Address:',
                              hintText: "${customerData.address}",
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
                            initialValue: "${customerData.email}",
                            decoration: InputDecoration(labelText:
                            'Email:',
                              hintText: "${customerData.email}",
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
                            initialValue: "${customerData.contactNo}",
                            decoration: InputDecoration(labelText:
                            'Contact No:',
                             hintText: "${customerData.contactNo}",
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
                              hintText: dots(customerData.password.length),
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
                                  final Customer validCustomer = Customer();

                                  if(_currentPassword != null)
                                    checkCurrentPassword = await validCustomer.validateCurrentPassword(_currentPassword);
                                  setState(() {

                                  });
                                  if (_updateKey.currentState.validate() && checkCurrentPassword) {
                                    validCustomer.updateCurrentEmail(_currentEmail);
                                    validCustomer.updateCurrentPassword(_newPassword);
                                    await DatabaseService(uid: user.uid)
                                        .updateCustomerData(
                                      _currentFName ?? customerData.fName,
                                      _currentLName ?? customerData.lName,
                                      _currentEmail ?? customerData.email,
                                      _currentContactNo ?? customerData.contactNo,
                                      _confirmPassword ?? customerData.password,
                                      _currentAddress ?? customerData.address,
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
  }
}
