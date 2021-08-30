import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class DashboardCustomer extends StatefulWidget{
  @override
  _DashboardCustomerState createState() => _DashboardCustomerState();
}

class Couriers {
  String firstName = '';
  String lastName = '';
  String vehicleType = '';
  String vehicleColor= '';
  double price = 0;
  String icon = '';

  Couriers({ this.firstName, this.lastName, this.vehicleType, this.vehicleColor, this.price, this.icon });
}

class _DashboardCustomerState extends State<DashboardCustomer> {
  List<Couriers> couriers = [
    Couriers(firstName: 'Pedro', lastName: 'Penduko', vehicleType: 'Sedan', vehicleColor: 'Red', price: 120,),
    Couriers(firstName: 'Pedro', lastName: 'Penduko', vehicleType: 'Sedan', vehicleColor: 'Red', price: 120,),
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
              Icons.help_outline,
            ),
              onPressed: (){
                showDialog(
                  context: context,
                  builder: (BuildContext context){
                    return AlertDialog(
                      title: Text("Help"),
                      content: Text('nice'),
                      actions: [
                        TextButton(
                          child: Text("OK"),
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                        ),
                      ],
                    );
                  }
                );
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
        body: SingleChildScrollView(
          child: Center(
            child: Column(
              children: [
                SizedBox(height: 10),
                Align(
                  alignment: Alignment.bottomCenter,
                  child: Text(
                    "Couriers Available",
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
                              onTap: () {
                                Navigator.pushNamed(context, '/customerRemarks');
                              },
                              title: Text('${couriers[index].firstName} ${couriers[index].lastName}'),
                              leading: Icon(Icons.local_shipping_rounded),
                              subtitle: Text(
                                  "Vehicle Type: ${couriers[index].vehicleType} \nVehicle Color: ${couriers[index].vehicleColor} \nPrice: ${couriers[index].price.toString()}"
                              ),
                              trailing: IconButton(
                                icon: Icon(Icons.info_outline),
                                onPressed: () {
                                  showDialog(
                                      context: context,
                                      builder: (BuildContext context){
                                        return AlertDialog(
                                          title: Text("Help"),
                                          content: Text('nice'),
                                          actions: [
                                            TextButton(
                                              child: Text("OK"),
                                              onPressed: () {
                                                Navigator.of(context).pop();
                                              },
                                            ),
                                          ],
                                        );
                                      }
                                  );
                                },
                              )
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