import 'package:flutter/material.dart';

class DashboardCustomer extends StatefulWidget{
  @override
  _DashboardCustomerState createState() => _DashboardCustomerState();
}

class _DashboardCustomerState extends State<DashboardCustomer> {

  Widget _alertmessage(){
    return Center(
      child: Column(
        children: [
          Container(
            child: Text("Bitch"),
          ),
        ],
      ),
    );
  }

  Widget _buildInfo(){
    return Center(
      child: Card(
        margin:EdgeInsets.only(bottom: 30),
        child: InkWell(
          onTap: (){
            showDialog(
                context: context, builder: (BuildContext context) => AlertDialog(
              content: (_alertmessage()),
            )
            );
          },
          child: SizedBox(
            width: 160,
            height: 50,
            child: Container(
              margin:EdgeInsets.only(left: 10),
              child: Text("Name:  \nVehicle:  \nDescription: \nPrice: ",textAlign: TextAlign.justify, style: TextStyle(fontSize: 10)),
            ),
          ),
        ),
        shadowColor: Colors.black,
        color:Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(10)),
      ),
      ),
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
                      title: const Text('Home'),
                      onTap: () {
                        // Update the state of the app
                        // ...
                        // Then close the drawer
                        Navigator.pop(context);
                      },
                    ),
                    ListTile(
                      title: const Text('Courier Bookmarks'),
                      onTap: () {
                        // Update the state of the app
                        // ...
                        // Then close the drawer
                        Navigator.pop(context);
                      },
                    ),
                    ListTile(
                      title: const Text('Delivery Status'),
                      onTap: () {
                        // Update the state of the app
                        // ...
                        // Then close the drawer
                        Navigator.pop(context);
                      },
                    ),
                    ListTile(
                      title: const Text('Search Courier'),
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
                      margin: EdgeInsets.only(left: 65),
                      child: Text("Couriers Available",
                        style: TextStyle(
                        fontSize: 25,
                        ),
                      ),
                    ),
                  ],
                ),
                Card(
                  margin: EdgeInsets.all(13),
                  child: Column(
                    children: [
                      Container(
                        margin: EdgeInsets.only(top: 10, bottom: 30, left: 100, right: 100),
                        child: TextFormField(
                          decoration: InputDecoration(labelText: 'Search', prefixIcon: Icon(Icons.search_rounded)),
                        ),
                      ),
                      Container(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: <Widget>[
                            Container(
                              child: _buildInfo(),
                            ),
                            Container(
                              child: _buildInfo(),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: <Widget>[
                            Container(
                              child: _buildInfo(),
                            ),
                            Container(
                              child: _buildInfo(),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: <Widget>[
                            Container(
                              child: _buildInfo(),
                            ),
                            Container(
                              child: _buildInfo(),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                shadowColor: Colors.black,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(10))),
                ),
              ],
            ),
          ),
        )
    );
  }
}

