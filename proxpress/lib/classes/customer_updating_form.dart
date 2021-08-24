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

  String _currentName;
  String _currentFName;
  String _currentLName;
  String _currentAddress;
  String _currentEmail;
  String _currentContactNo;
  String _currentPassword;
  String _confirmPassword;


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
                  return Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Container(
                        // temporary not yet configured
                        child: Image.asset(
                          "assets/PROExpress-logo.png",
                          height: 100,
                          width: 200,
                        ),
                      ),
                      Container(
                        child: TextFormField(
                          decoration: InputDecoration(labelText: 'Name:'),
                          validator: (val) => val.isEmpty ? 'Enter your new name' : null,
                          initialValue: "${customerData.fName} ${customerData.lName}",
                        ),
                      ),
                      Container(
                        child: TextFormField(
                          decoration: InputDecoration(labelText: 'Address:'),
                          initialValue: "${customerData.address}",
                          validator: (val) => val.isEmpty ? 'Enter your new address' : null,
                        ),
                      ),
                      Container(
                        child: TextFormField(
                          decoration: InputDecoration(labelText: 'Email:'),
                          validator: (val) => val.isEmpty ? 'Enter your new email' : null,
                          initialValue: "${customerData.email}",
                        ),
                      ),
                      Container(
                        child: TextFormField(
                          decoration: InputDecoration(labelText: 'Contact No:'),
                          validator: (val) => val.isEmpty ? 'Enter your new contact no' : null,
                          initialValue: "${customerData.contactNo}",
                        ),
                      ),
                      Container(
                        child: TextFormField(
                          obscureText: true,
                          decoration: InputDecoration(labelText: 'Password:'),
                          validator: (val) => val.isEmpty ? 'Enter your new password' : null,
                          initialValue: "${customerData.password}",
                        ),
                      ),
                      Container(
                        child: TextFormField(
                          obscureText: true,
                          validator: (val) => val.isEmpty ? 'Enter your new name' : null,
                          decoration: InputDecoration(labelText: 'Confirmation Password:'),
                        ),
                      ),
                      ElevatedButton(
                          child: Text(
                            'Save Changes', style: TextStyle(color: Colors.white, fontSize:18),
                          ),
                          style: ElevatedButton.styleFrom(
                            primary: Color(0xfffb0d0d),
                          ),
                          onPressed: () async {

                          }
                      ),
                    ],
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
