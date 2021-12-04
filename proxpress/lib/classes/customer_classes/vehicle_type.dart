import 'package:flutter/material.dart';

class VehicleType extends StatefulWidget {
  @override
  _VehicleTypeState createState() => _VehicleTypeState();
}

class _VehicleTypeState extends State<VehicleType> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        iconTheme: IconThemeData(color: Color(0xfffb0d0d)),
        flexibleSpace: Container(
          margin: EdgeInsets.only(top: 10),
          child: Image.asset(
            "assets/PROExpress-logo.png",
            height: 120,
            width: 120,
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text('Select Vehicle',style: TextStyle(fontSize: 25,),),
            ),
            Padding(
              padding: const EdgeInsets.all(10),
              child: Card(
                child: InkWell(
                  onTap: (){
                  },
                  child: ListTile(
                    leading: Container(
                      width: 80,
                        child: Image.asset('assets/vehicles/motorcycle.png', color: Colors.grey[700])
                    ),
                    title: Text('Motorcycle',style: TextStyle(fontWeight: FontWeight.bold),),
                    subtitle: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 5),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                        Text('0.5 x 0.4 x 0.5 Meter'),
                        Text('Up to 20 kg'),
                      ]),
                    ),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(10),
              child: Card(
                child: InkWell(
                  onTap: (){
                  },
                  child: ListTile(
                    leading: Container(
                        width: 80,
                        child: Image.asset('assets/vehicles/sedan.png', color: Colors.grey[700])
                    ),
                    title: Text('Sedan',style: TextStyle(fontWeight: FontWeight.bold),),
                    subtitle: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 5),
                      child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                        Text('1 x 0.6 x 0.7 Meter'),
                        Text('Up to 200 kg'),
                      ]),
                    ),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(10),
              child: Card(
                child: InkWell(
                  onTap: (){
                  },
                  child: ListTile(
                    leading: Container(
                        width: 80,
                        child: Image.asset('assets/vehicles/mpv.png', color: Colors.grey[700])
                    ),
                    title: Text('Multi-Purpose  Vehicle (MPV)',style: TextStyle(fontWeight: FontWeight.bold),),
                    subtitle: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 5),
                      child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                        Text('1.2 x 1 x 0.9 Meter'),
                        Text('Up to 300 kg'),
                      ]),
                    ),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(10),
              child: Card(
                child: InkWell(
                  onTap: (){
                  },
                  child: ListTile(
                    leading: Container(
                        width: 80,
                        child: Image.asset('assets/vehicles/pickup-truck.png', color: Colors.grey[700])
                    ),
                    title: Text('Pickup Truck',style: TextStyle(fontWeight: FontWeight.bold),),
                    subtitle: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 5),
                      child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                        Text('1.4 x 1.4 x 1.5 Meter'),
                        Text('Up to 500 kg'),
                      ]),
                    ),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(10),
              child: Card(
                child: InkWell(
                  onTap: (){
                  },
                  child: ListTile(
                    leading: Container(
                        width: 80,
                        child: Image.asset('assets/vehicles/van.png', color: Colors.grey[700])
                    ),
                    title: Text('Van',style: TextStyle(fontWeight: FontWeight.bold),),
                    subtitle: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 5),
                      child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                        Text('2.1 x 1.2 x 1.2 Meter'),
                        Text('Up to 600 kg'),
                      ]),
                    ),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(10),
              child: Card(
                child: InkWell(
                  onTap: (){
                  },
                  child: ListTile(
                    leading: Container(
                        width: 80,
                        child: Image.asset('assets/vehicles/fb-type.png', color: Colors.grey[700])
                    ),
                    title: Text('Family Business Type Van',style: TextStyle(fontWeight: FontWeight.bold),),
                    subtitle: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 5),
                      child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                        Text('2.2 x 1.5 x 1.3 Meter'),
                        Text('Up to 700 kg'),
                      ]),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
