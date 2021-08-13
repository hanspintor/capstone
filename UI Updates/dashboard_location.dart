import 'package:flutter/material.dart';
import 'dashboard_customer.dart';

class DashboardLocation extends StatefulWidget{
  @override
  _DashboardLocationState createState() => _DashboardLocationState();
}

class _DashboardLocationState extends State<DashboardLocation>{
  String _pickup;
  String _dropoff;

  void _validate(){
    if(!locKey.currentState.validate()){
      return;
    }
    locKey.currentState.save();
    print (_pickup);
    print (_dropoff);
  }

  Widget _alertmessage(){
    return null;
  }

  final GlobalKey<FormState> locKey = GlobalKey<FormState>();

  Widget _buildPickup(){
    return TextFormField(
      decoration: InputDecoration(labelText: 'Pick up location', prefixIcon: Icon(Icons.location_searching_rounded)),
      keyboardType: TextInputType.streetAddress,
      validator: (String value){
        if(value.isEmpty){
          return 'Pick up location is required';
        }
      },
      onSaved: (String value){
        _pickup = value;
      },
    );
  }

  Widget _buildDropoff(){
    return TextFormField(
      decoration: InputDecoration(labelText: 'Drop off location', prefixIcon: Icon(Icons.place)),
      keyboardType: TextInputType.streetAddress,
      validator: (String value){
        if(value.isEmpty){
          return 'Drop off location is required';
        }
      },
      onSaved: (String value){
        _dropoff = value;
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
            backgroundColor: Colors.white,
            iconTheme: IconThemeData(color: Color(0xfffb0d0d),),
            actions: [
              IconButton(icon: Icon(
                Icons.notifications_none_rounded,
              ),
                onPressed: (){
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
        drawer: Drawer(
          child: Column(
            mainAxisSize: MainAxisSize.max,
            children: [
              Expanded(
                child: ListView(
                  children: [
                    DrawerHeader(
                      decoration: BoxDecoration(
                      ),
                      child: Text('User'),
                    ),
                    ListTile(
                      title: const Text('Home', style: TextStyle(color: Color(0xfffb0d0d))),
                      onTap: () {
                        // Update the state of the app
                        // ...
                        // Then close the drawer
                        Navigator.pop(context);
                      },
                    ),
                    ListTile(
                      title: const Text('Courier Bookmarks', style: TextStyle(color: Color(0xfffb0d0d))),
                      onTap: () {
                        // Update the state of the app
                        // ...
                        // Then close the drawer
                        Navigator.pop(context);
                      },
                    ),
                    ListTile(
                      title: const Text('Delivery Status', style: TextStyle(color: Color(0xfffb0d0d))),
                      onTap: () {
                        // Update the state of the app
                        // ...
                        // Then close the drawer
                        Navigator.pop(context);
                      },
                    ),
                    ListTile(
                      title: const Text('Search Courier', style: TextStyle(color: Color(0xfffb0d0d))),
                      onTap: () {
                        // Update the state of the app
                        // ...
                        // Then close the drawer
                        Navigator.pop(context);
                      },
                    ),
                  ],
                ),
              ),
              Container(
                child: Align(
                  alignment: Alignment.bottomCenter,
                  child:RaisedButton(
                    child: Text(
                      'Logout', style: TextStyle(color: Colors.white, fontSize:18),
                    ),
                    color: Colors.black,
                    onPressed: (){
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
        body: SingleChildScrollView(
          child: Center(
            child: Column(
              children: [
                Row(
                  children: [
                    Container(
                      child: IconButton(icon: Icon(
                        Icons.arrow_back,
                        color: Colors.black,
                      ),
                        onPressed: (){
                          Navigator.pop(context, false);
                        },
                        iconSize: 25,
                      ),
                    ),
                    Container(
                      margin: EdgeInsets.only(left: 75),
                      child: Text(
                        "Welcome User",
                        style: TextStyle(
                          fontSize: 25,
                        ),
                      ),
                    ),
                  ],
                ),
                Container(
                  margin: EdgeInsets.only(right: 40, left: 40, bottom: 40, top: 100),
                  child: Form(
                    key: locKey,
                    child: Card(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Container(
                            margin: EdgeInsets.only(top: 10),
                            child: Text(
                              "Pin a Location",
                              style: TextStyle(
                                fontSize: 20,
                              ),
                            ),
                          ),
                          Container(
                            margin: EdgeInsets.symmetric(horizontal: 35),
                            child: _buildPickup(),
                          ),
                          Container(
                            margin: EdgeInsets.symmetric(horizontal: 35, vertical: 23),
                            child: _buildDropoff(),
                          ),
                        ],
                      ),
                      shadowColor: Colors.black,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.all(Radius.circular(10))
                      ),
                    ),
                  ),
                ),
                RaisedButton(
                  child: Text(
                    'Proceed', style: TextStyle(color: Colors.white, fontSize:18),
                  ),
                  color: Color(0xfffb0d0d),
                  onPressed: (){
                    // _validate();
                    Navigator.push(
                        context,
                        new MaterialPageRoute(builder: (context) => new DashboardCustomer()));
                  },
                ),
              ],
            ),
          ),
        )
    );
  }
}

