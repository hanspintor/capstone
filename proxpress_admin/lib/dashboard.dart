import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_admin_scaffold/admin_scaffold.dart';
import 'package:pluto_grid/pluto_grid.dart';
import 'package:provider/provider.dart';
import 'package:proxpress/courier_list.dart';
import 'package:proxpress/couriers.dart';
import 'package:proxpress/database.dart';
import 'package:proxpress/delivery_price_list.dart';
import 'package:proxpress/delivery_prices.dart';
import 'package:proxpress/login_screen.dart';
import 'package:proxpress/report_list.dart';
import 'package:proxpress/reports.dart';
import 'package:url_launcher/url_launcher.dart';
import 'auth.dart';

class Dashboard extends StatefulWidget {
  final String savedPassword;
  Dashboard({this.savedPassword});

  @override
  _DashboardState createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> with SingleTickerProviderStateMixin {
  final AuthService _auth = AuthService();
  int activeTab = 0;

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
        ],
        selectedRoute: '/dashboard',
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
      body: StreamBuilder<List<Courier>>(
          stream: DatabaseService().courierList,
        builder: (context, snapshot) {
          if(snapshot.hasData){
            List<Courier> couriers = snapshot.data;

            List<PlutoColumn> columns = [
              PlutoColumn(
                title: 'Name',
                field: 'name',
                type: PlutoColumnType.text(),
              ),
              PlutoColumn(
                title: 'Address',
                field: 'address',
                type: PlutoColumnType.text(),
              ),
              PlutoColumn(
                title: 'Email',
                field: 'email',
                type: PlutoColumnType.text(),
              ),
              PlutoColumn(
                title: 'Vehicle Type',
                field: 'vehicle_type',
                type: PlutoColumnType.text(),
              ),
              PlutoColumn(
                title: 'Vehicle Color',
                field: 'vehicle_color',
                type: PlutoColumnType.text(),
                renderer: (rendererContext){
                  //print(rendererContext.cell.value);
                  return Container(
                    width: 20,
                    height: 20,
                    decoration: BoxDecoration(
                      border: Border.all(),
                      shape: BoxShape.circle,
                      color: Color(rendererContext.cell.value),
                    ),
                  );
                }
              ),

              PlutoColumn(
                title: 'Credentials',
                field: 'credentials',
                type: PlutoColumnType.text(),
                renderer: (rendererContext) {
                  return InkWell(
                    child: new Text('View Credentials', style: TextStyle(color: Colors.blue, decoration: TextDecoration.underline,),),
                    onTap: () => launch(rendererContext.cell.value),
                  );
                  },
              ),
            ];

            List<PlutoRow> rows = List.generate(couriers.length, (index) {
              return PlutoRow(
                cells: {
                  'name': PlutoCell(value: "${couriers[index].fName} ${couriers[index].lName}"),
                  'address': PlutoCell(value: couriers[index].address),
                  'email': PlutoCell(value: couriers[index].email),
                  'vehicle_type': PlutoCell(value: couriers[index].vehicleType),
                  'vehicle_color': PlutoCell(value: couriers[index].vehicleColor),
                  'credentials': PlutoCell(value: couriers[index].driversLicenseFront_,),
                },
              );
            });

            return Padding(
              padding: EdgeInsets.all(100),
              child: PlutoGrid(
                  columns: columns,
                  rows: rows,
                  onChanged: (PlutoGridOnChangedEvent event) {
                    print(event);
                  },
                  onLoaded: (PlutoGridOnLoadedEvent event) {
                    print(event);
                  }
              ),
            );
          }
          else return Container();
        }
      ),
    );
  }
}
