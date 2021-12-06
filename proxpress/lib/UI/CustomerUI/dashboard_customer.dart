import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:proxpress/UI/login_screen.dart';
import 'package:proxpress/classes/customer_classes/courier_list.dart';
import 'package:proxpress/models/couriers.dart';
import 'package:proxpress/models/delivery_prices.dart';
import 'package:proxpress/models/user.dart';
import 'package:proxpress/services/database.dart';

class DashboardCustomer extends StatefulWidget{
  final String pickupAddress;
  final GeoPoint pickupCoordinates;
  final String dropOffAddress;
  final GeoPoint dropOffCoordinates;
  final double distance;
  final String vehicleType;

  DashboardCustomer({
    Key key,
    @required this.pickupAddress,
    @required this.pickupCoordinates,
    @required this.dropOffAddress,
    @required this.dropOffCoordinates,
    @required this.distance,
    @required this.vehicleType,
  }) : super(key: key);

  @override
  _DashboardCustomerState createState() => _DashboardCustomerState();
}

class _DashboardCustomerState extends State<DashboardCustomer> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  TextEditingController _searchController = TextEditingController();
  String searched = '';

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  _onSearchChanged() {
    print(_searchController.text);
    searched = _searchController.text;
  }

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<TheUser>(context);

    print(widget.pickupAddress);
    print(widget.pickupCoordinates.toString());

    print(widget.dropOffAddress);
    print(widget.dropOffCoordinates.toString());

    return user == null ? LoginScreen() : StreamProvider<List<Courier>>.value(
      value: DatabaseService().courierList,
      initialData: [],
      child: Scaffold(
          drawerEnableOpenDragGesture: false,
          endDrawerEnableOpenDragGesture: false,
          key:_scaffoldKey,
          appBar: AppBar(
            backgroundColor: Colors.white,
            iconTheme: IconThemeData(color: Color(0xfffb0d0d),),
            actions: [
              IconButton(
                icon: Icon(Icons.help_outline,),
                iconSize: 25,
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        titlePadding: EdgeInsets.fromLTRB(8, 0, 8, 0),
                        title: Column(
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(0),
                              child: Container(
                                margin: EdgeInsets.all(0),
                                alignment: Alignment.topRight,
                                child: IconButton(
                                  icon: const Icon(Icons.close_sharp),
                                  color: Colors.redAccent,
                                  onPressed: () {
                                    Navigator.pop(context);
                                  },
                                ),
                              ),
                            ),
                            Container(
                              padding: EdgeInsets.only(bottom: 15),
                              decoration: BoxDecoration(
                                  border: Border(
                                      bottom: BorderSide(color: Colors.grey[500])
                                  )
                              ),
                              child: Center(
                                  child: Text.rich(
                                    TextSpan(children: [
                                      TextSpan(text: "Standard Rates\n",),
                                      TextSpan(text: "The distance (km) of your delivery request will be based from your previously pinned locations.", style: Theme.of(context).textTheme.bodyText2),
                                    ],
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                              ),
                            ),
                          ],
                        ),
                        content: Container(
                          width: double.maxFinite,
                          child: StreamBuilder<List<DeliveryPrice>>(
                            stream: DatabaseService().deliveryPriceList,
                            builder: (context, snapshot) {
                              if (snapshot.hasData) {
                                List<DeliveryPrice> deliveryPrices = snapshot.data;

                                deliveryPrices.sort((a, b) => a.baseFare.compareTo(b.baseFare));

                                List<String> parcelWeights = ['20', '200', '500', '300', '700', '600'];

                                return ListView.builder(
                                  shrinkWrap: true,
                                  itemCount: deliveryPrices.length,
                                  itemBuilder: (context, index) {
                                    return ListTile(
                                      title: Text(deliveryPrices[index].vehicleType, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),),
                                      subtitle: Container(
                                        padding: EdgeInsets.only(top: 5),
                                        child: Text.rich(
                                          TextSpan(children: [
                                            TextSpan(text: "Base Fare: ", style: Theme.of(context).textTheme.bodyText2.copyWith(fontWeight: FontWeight.bold)),
                                            TextSpan(text: "\₱${deliveryPrices[index].baseFare}\n", style: Theme.of(context).textTheme.bodyText2),
                                            TextSpan(text: "Fare Per KM: ", style: Theme.of(context).textTheme.bodyText2.copyWith(fontWeight: FontWeight.bold)),
                                            TextSpan(text: "\₱${deliveryPrices[index].farePerKM}\n",style: Theme.of(context).textTheme.bodyText2),
                                            TextSpan(text: "Fare Per KM: ", style: Theme.of(context).textTheme.bodyText2.copyWith(fontWeight: FontWeight.bold)),
                                            TextSpan(text: "Up to ${parcelWeights[index]} kg\n",style: Theme.of(context).textTheme.bodyText2),
                                          ],
                                          ),
                                        ),
                                      ),
                                      isThreeLine: true,
                                    );
                                  },
                                );
                              } else {
                                return Container();
                              }
                            }
                          ),
                        ),
                      );
                    }
                  );
                },
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
          ),
          body: SingleChildScrollView(
            child: Container(
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
                  CourierList(
                    pickupAddress: widget.pickupAddress,
                    pickupCoordinates: widget.pickupCoordinates,
                    dropOffAddress: widget.dropOffAddress,
                    dropOffCoordinates: widget.dropOffCoordinates,
                    distance: widget.distance,
                    vehicleType: widget.vehicleType,
                  ),
                ],
              ),
            ),
          )
      ),
    );
  }
}