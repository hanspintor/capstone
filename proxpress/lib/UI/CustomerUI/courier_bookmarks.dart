import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../menu_drawer.dart';
import '../notif_drawer.dart';

class CourierBookmarks extends StatefulWidget{
  @override
  _CourierBookmarksState createState() => _CourierBookmarksState();
}

class Couriers {
  String name = '';
  String vehicleType = '';
  String description = '';
  double price = 0;
  String icon = '';

  Couriers({ this.name, this.vehicleType, this.description, this.price, this.icon });
}

class _CourierBookmarksState extends State<CourierBookmarks> {
  List<Couriers> couriers = [
    Couriers(name: 'Pedro Penduko', vehicleType: 'Sedan', description: 'I can deliver items up to 200kg.', price: 120),
    Couriers(name: 'Pedro Penduko', vehicleType: 'Sedan', description: 'I can deliver items up to 200kg.', price: 120),
  ];

  void _openEndDrawer() {
    _scaffoldKey.currentState.openEndDrawer();
  }

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

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
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
            width: 110,
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
        drawerEnableOpenDragGesture: false,
        endDrawerEnableOpenDragGesture: false,
        key:_scaffoldKey,
        appBar: AppBar(
          backgroundColor: Colors.white,
          iconTheme: IconThemeData(color: Color(0xfffb0d0d),),
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
        drawer: MainDrawer(),
        endDrawer: NotifDrawer(),
        body: SingleChildScrollView(
          child: Center(
            child: Column(
              children: [
                SizedBox(height: 10),
                Align(
                  alignment: Alignment.bottomCenter,
                  child: Text(
                    "Bookmarked Couriers",
                    style: TextStyle(
                      fontSize: 25,
                    ),
                  ),
                ),
                Card(
                  margin: EdgeInsets.all(20),
                  child: Column(
                    children: [
                      Container(
                        margin: EdgeInsets.only(top: 10, bottom: 30, left: 100, right: 100),
                        child: TextFormField(
                          decoration: InputDecoration(labelText: 'Search', prefixIcon: Icon(Icons.search_rounded)),
                        ),
                      ),
                      ListView.builder(
                        shrinkWrap: true,
                        itemBuilder: (context, index) {
                          return Card(
                            margin: EdgeInsets.fromLTRB(20, 0, 20, 20),
                            child: ListTile(
                              title: Text(couriers[index].name),
                              leading: Icon(Icons.account_circle_rounded, size: 50,),
                              subtitle: Text(
                                  "Vehicle Type: ${couriers[index].vehicleType} \nDescription: ${couriers[index].vehicleType} \nPrice: ${couriers[index].price.toString()}"
                              ),
                            ),
                          );
                        },
                        itemCount: couriers.length,
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

