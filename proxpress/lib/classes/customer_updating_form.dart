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
  String _newPassword;
  String _confirmPassword;

  String dots(int Dotlength){
    String dot = "•";
    for(var i = 0; i<Dotlength; i++){
      dot += "•";
    }
    return dot;
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
                            decoration: InputDecoration(labelText:
                            'First Name:',
                              hintText: "${customerData.fName}",
                              floatingLabelBehavior: FloatingLabelBehavior.always,
                              labelStyle: TextStyle(
                                fontStyle: FontStyle.italic,
                                color: Colors.redAccent,
                              ),
                            ),
                            validator: (String val) => val.isEmpty ? 'Enter your new first name' : null,
                            onChanged: (val) => setState(() => _currentFName = val),
                          ),
                        ),
                        Container(
                          child: TextFormField(
                            decoration: InputDecoration(labelText:
                            'Last Name:',
                              hintText: "${customerData.lName}",
                              floatingLabelBehavior: FloatingLabelBehavior.always,
                              labelStyle: TextStyle(
                                fontStyle: FontStyle.italic,
                                color: Colors.redAccent,
                              ),
                            ),
                            validator: (String val) => val.isEmpty ? 'Enter your new last name' : null,
                            onChanged: (val) => setState(() => _currentLName = val),
                          ),
                        ),
                        Container(
                          child: TextFormField(
                            decoration: InputDecoration(labelText:
                            'Address:',
                              hintText: "${customerData.address}",
                              floatingLabelBehavior: FloatingLabelBehavior.always,
                              labelStyle: TextStyle(
                                fontStyle: FontStyle.italic,
                                color: Colors.redAccent,
                              ),
                            ),
                            keyboardType: TextInputType.streetAddress,
                            validator: (String val) => val.isEmpty ? 'Enter your new address' : null,
                            onChanged: (val) => setState(() => _currentAddress = val),
                          ),
                        ),
                        Container(
                          child: TextFormField(
                            decoration: InputDecoration(labelText:
                            'Email:',
                              hintText: "${customerData.email}",
                              floatingLabelBehavior: FloatingLabelBehavior.always,
                              labelStyle: TextStyle(
                                fontStyle: FontStyle.italic,
                                color: Colors.redAccent,
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
                            decoration: InputDecoration(labelText:
                            'Contact No:',
                             hintText: "${customerData.contactNo}",
                              floatingLabelBehavior: FloatingLabelBehavior.always,
                             labelStyle: TextStyle(
                               fontStyle: FontStyle.italic,
                               color: Colors.redAccent,
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
                              labelStyle: TextStyle(
                                fontStyle: FontStyle.italic,
                                color: Colors.redAccent,
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
                        // Container(
                        //   child: TextFormField(
                        //     obscureText: true,
                        //     decoration: InputDecoration(labelText:
                        //     'New Password:',
                        //       labelStyle: TextStyle(
                        //         fontStyle: FontStyle.italic,
                        //         color: Colors.redAccent,
                        //       ),
                        //     ),
                        //     validator: (String val){
                        //       if(val.length < 8 && val.length > 0){
                        //         return 'Password should be 8 characters long';
                        //       }
                        //       else
                        //         return null;
                        //     },
                        //     onChanged: (val) => setState(() => _newPassword = val),
                        //   ),
                        // ),
                        // Container(
                        //   child: TextFormField(
                        //     obscureText: true,
                        //     decoration: InputDecoration(labelText:
                        //     'Confirmation Password:',
                        //       labelStyle: TextStyle(
                        //         fontStyle: FontStyle.italic,
                        //         color: Colors.redAccent,
                        //       ),
                        //     ),
                        //     validator: (String val){
                        //       if(val.length < 8 && val.length > 0){
                        //         return 'Password should be 8 characters long';
                        //       }
                        //       else if(_currentPassword != null){
                        //         if(_newPassword != val){
                        //           return "Password does not match";
                        //         }
                        //       }
                        //       else
                        //         return null;
                        //     },
                        //     onChanged: (val) => setState(() => _confirmPassword = val),
                        //   ),
                        // ),
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
                              if (_updateKey.currentState.validate()) {
                                await DatabaseService(uid: user.uid)
                                    .updateCustomerData(
                                  _currentFName ?? customerData.fName,
                                  _currentLName ?? customerData.lName,
                                  _currentEmail ?? customerData.email,
                                  _currentContactNo ?? customerData.contactNo,
                                  _currentPassword ?? customerData.password,
                                  _currentAddress ?? customerData.address,
                                );
                                //   if(_currentPassword != null){
                                //     await DatabaseService(uid: user.uid).updateCustomerData(
                                //       _currentFName ?? customerData.fName,
                                //       _currentLName ?? customerData.lName,
                                //       _currentEmail ?? customerData.email,
                                //       _currentContactNo ?? customerData.contactNo,
                                //       _currentPassword ?? customerData.password,
                                //       _currentAddress ?? customerData.address,
                                //     );
                                //   } else{
                                //     await DatabaseService(uid: user.uid).updateCustomerProfile(
                                //       _currentFName ?? customerData.fName,
                                //       _currentLName ?? customerData.lName,
                                //       _currentEmail ?? customerData.email,
                                //       _currentContactNo ?? customerData.contactNo,
                                //       _currentAddress ?? customerData.address,
                                //     );
                                //   }
                                Navigator.pushNamed(
                                    context, '/customerProfile');
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
