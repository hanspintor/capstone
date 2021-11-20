import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_admin_scaffold/admin_scaffold.dart';
import 'package:pluto_grid/pluto_grid.dart';
import 'package:proxpress/auth.dart';
import 'package:proxpress/database.dart';
import 'package:proxpress/delivery_prices.dart';
import 'package:proxpress/login_screen.dart';

class DeliveryPricesPage extends StatefulWidget {
  final String savedPassword;
  DeliveryPricesPage({this.savedPassword});
  @override
  _DeliveryPricesPageState createState() => _DeliveryPricesPageState();
}

class _DeliveryPricesPageState extends State<DeliveryPricesPage> {
  final AuthService _auth = AuthService();
  @override
  Widget build(BuildContext context) {
    final FirebaseAuth auth = FirebaseAuth.instance;
    final User user = auth.currentUser;

    return AdminScaffold(
      backgroundColor: Colors.white,
      sideBar: SideBar(
        iconColor: Colors.red,
        activeIconColor: Colors.white,
        activeTextStyle: TextStyle(color: Colors.white,),
        textStyle: TextStyle(color: Colors.red),
        activeBackgroundColor: Colors.red,
        items: const [
          MenuItem(
            title: 'Courier',
            route: '/dashboard',
            icon: Icons.local_shipping_rounded,
          ),
          MenuItem(
            title: 'Delivery Prices',
            route: '/prices',
            icon: Icons.price_change,
          ),
          MenuItem(
            title: 'Reports',
            route: '/reports',
            icon: Icons.report_problem,
          ),
          MenuItem(
            title: 'Cash-outs',
            route: '/cashouts',
            icon: Icons.account_balance_wallet_rounded,
          ),
        ],
        selectedRoute: '/prices',
        onSelected: (item) {
          if (item.route != null) {
            Navigator.of(context).pushNamed(item.route);
          }
        },
        header: Container(
          height: 100,
          width: double.infinity,
          color: Color(0xFFEEEEEE),
          child: Center(
              child: Container(
                child: Image.asset('assets/PROXpressLogo.png'),
              )
          ),
        ),
        footer: Container(
          height: 50,
          width: double.infinity,
          child: Center(
            child: Container(
              height: MediaQuery.of(context).size.height / 20,
              width: MediaQuery.of(context).size.width / 1,
              child: ElevatedButton.icon(
                label: Text('Logout'),
                icon: Icon(Icons.logout_rounded),
                style: ElevatedButton.styleFrom(primary: Colors.red, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(0)),),
                onPressed: () async{
                  print(user.uid);
                  if (user != null) {
                    await _auth.signOut();
                  }
                  Navigator.push(context, MaterialPageRoute(builder: (context) => LoginScreen()));
                },
              ),
            ),
          ),
        ),
      ),
      body: StreamBuilder<List<DeliveryPrice>>(
          stream: DatabaseService().deliveryPriceList,
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              List<DeliveryPrice> price = snapshot.data;
              print(price[0].baseFare);

              List<String> priceUIDs = [];
              price.forEach((element) {
                priceUIDs.add(element.uid);
              });

              List<PlutoColumn> columns = [
                PlutoColumn(
                  enableEditingMode: false,
                  title: 'Vehicle Type',
                  field: 'vehicle_type',
                  type: PlutoColumnType.text(),
                ),
                PlutoColumn(
                  title: 'Base Fare',
                  field: 'base_fare',
                  type: PlutoColumnType.number(),
                ),
                PlutoColumn(
                  title: 'Fare Per KM',
                  field: 'fare_per_km',
                  type: PlutoColumnType.number(),
                ),
              ];

              List<PlutoRow> rows = List.generate(price.length, (index) {
                return PlutoRow(
                  cells: {
                    'vehicle_type': PlutoCell(value: price[index].vehicleType),
                    'base_fare': PlutoCell(value: price[index].baseFare),
                    'fare_per_km': PlutoCell(value: price[index].farePerKM),
                  },
                );
              });

              return Padding(
                padding: EdgeInsets.all(100),
                child: PlutoGrid(
                    columns: columns,
                    rows: rows,
                    onChanged: (PlutoGridOnChangedEvent event) async{

                      if (event.columnIdx == 1) {
                        await DatabaseService(uid: priceUIDs[event.rowIdx]).updateBaseFare(event.value);
                      } else await DatabaseService(uid: priceUIDs[event.rowIdx]).updateFarePerKM(event.value);
                    },
                  createHeader: (PlutoGridStateManager) {
                    return Container(
                        color: Color(0xFFEEEEEE),
                        child: Align(
                          alignment: Alignment.center,
                          child: Text('Delivery Prices',
                              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 30)
                          ),
                        )
                    );
                  },
                  createFooter: (PlutoGridStateManager) {
                    return Container(
                        color: Color(0xFFEEEEEE),
                        child: Align(
                          alignment: Alignment.center,
                        )
                    );
                  },
                ),
              );
            }
            else return Container();
          }
      ),
    );
  }
}