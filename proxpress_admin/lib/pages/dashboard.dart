import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_admin_scaffold/admin_scaffold.dart';
import 'package:pluto_grid/pluto_grid.dart';
import 'package:provider/provider.dart';
import 'package:proxpress/couriers.dart';
import 'package:proxpress/database.dart';
import 'package:proxpress/delivery_prices.dart';
import 'package:proxpress/login_screen.dart';
import 'package:proxpress/reports.dart';
import 'package:url_launcher/url_launcher.dart';
import '../auth.dart';

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
          MenuItem(
            title: 'Cash-outs',
            route: '/cashouts',
            icon: Icons.account_balance_wallet_rounded,
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
                //enableRowChecked: true,
                enableEditingMode: false,
                title: 'Name',
                field: 'name',
                type: PlutoColumnType.text(),
              ),
              PlutoColumn(
                enableEditingMode: false,
                title: 'Address',
                field: 'address',
                type: PlutoColumnType.text(),
              ),
              PlutoColumn(
                enableEditingMode: false,
                title: 'Email',
                field: 'email',
                type: PlutoColumnType.text(),
              ),
              PlutoColumn(
                enableEditingMode: false,
                title: 'Vehicle Type',
                field: 'vehicle_type',
                type: PlutoColumnType.text(),
              ),
              PlutoColumn(
                  enableEditingMode: false,
                title: 'Vehicle Color',
                field: 'vehicle_color',
                type: PlutoColumnType.text(),
                renderer: (rendererContext){
                  //print(rendererContext.cell.value);
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 20,
                        height: 20,
                        decoration: BoxDecoration(
                          border: Border.all(),
                          shape: BoxShape.circle,
                          color: Color(rendererContext.cell.value),
                        ),
                      ),
                    ],
                  );
                }
              ),

              PlutoColumn(
                enableEditingMode: false,
                title: 'Credentials',
                field: 'credentials',
                type: PlutoColumnType.text(),
                renderer: (rendererContext) {
                  List<String> images = rendererContext.cell.value.split(' ');

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      InkWell(
                        child: new Text('View Credentials', style: TextStyle(color: Colors.blue, decoration: TextDecoration.underline,),),
                        onTap: () {
                          showDialog(
                              context: context,
                              builder: (BuildContext context) => StatefulBuilder(
                                builder: (context, setState){
                                  return AlertDialog(
                                      content: Container(
                                        height: MediaQuery.of(context).size.height/.1,
                                        width: MediaQuery.of(context).size.width/.1,
                                        child: GridView.builder(
                                          itemCount: 6,
                                            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 3),
                                            itemBuilder: (context, index){
                                              return Column(
                                                children: [
                                                  Container(
                                                    height: 550,
                                                    width: 600,
                                                    child: Image.network(images[index]),
                                                  ),
                                                  if(images[index] == images[0])...[
                                                    Text('Driver\'s License Front', style: TextStyle(fontWeight: FontWeight.bold),),
                                                  ]
                                                  else if (images[index] == images[1])...[
                                                    Text('Driver\'s License Back', style: TextStyle(fontWeight: FontWeight.bold),),
                                                  ]
                                                  else if (images[index] == images[2])...[
                                                      Text('NBI Clearance', style: TextStyle(fontWeight: FontWeight.bold),),
                                                    ]
                                                    else if (images[index] == images[3])...[
                                                        Text('Vehicle Certificate OR', style: TextStyle(fontWeight: FontWeight.bold),),
                                                      ]
                                                      else if (images[index] == images[4])...[
                                                          Text('Vehicle Certificate CR', style: TextStyle(fontWeight: FontWeight.bold),),
                                                        ]
                                                        else if (images[index] == images[5])...[
                                                            Text('Vehicle Photo', style: TextStyle(fontWeight: FontWeight.bold),),
                                                          ]
                                                  else Container(),
                                                ],
                                              );
                                            }
                                        ),
                                      ),
                                      actions: [
                                        TextButton(
                                          child: Text("OK"),
                                          onPressed: () async {
                                            Navigator.pop(context);
                                          },
                                        ),
                                      ]
                                  );
                                },
                              )
                          );
                        }
                      ),
                    ],
                  );
                  },
              ),
              PlutoColumn(
                enableEditingMode: false,
                title: 'Commands',
                field: 'commands',
                type: PlutoColumnType.text(),
                renderer: (renderContext){
                  bool approved = couriers[renderContext.rowIdx].approved;

                  return Row(
                    children: [
                      IconButton(
                          icon: approved ? Icon(Icons.block_rounded, color: Colors.red): Icon(Icons.check_circle_rounded, color: Colors.green),
                          onPressed: approved ? () async {
                            String _adminMessage = " ";
                            showDialog(
                                context: context,
                                builder: (BuildContext context) => StatefulBuilder(
                                  builder: (context, setState){
                                    return AlertDialog(
                                        content: Column(
                                          crossAxisAlignment: CrossAxisAlignment.center,
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            ListTile(
                                              title: Text("Notify the Courier", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),),
                                            ),
                                            SizedBox(height: 20),
                                            SizedBox(
                                              width: 500,
                                              child: TextFormField(
                                                maxLines: 2,
                                                maxLength: 200,
                                                decoration: InputDecoration(
                                                  hintText: 'Type something',
                                                  border: OutlineInputBorder(),
                                                ),
                                                keyboardType: TextInputType.multiline,
                                                onChanged: (val) => setState(() => _adminMessage = val),
                                              ),
                                            ),
                                          ],
                                        ),
                                        actions: [
                                          TextButton(
                                            child: Text("Send"),
                                            onPressed: () async {
                                              await DatabaseService(uid: couriers[renderContext.rowIdx].uid).approveCourier(false);
                                              await DatabaseService(uid: couriers[renderContext.rowIdx].uid).updateCourierMessage(_adminMessage);
                                              //Navigator.pop(context);
                                              Navigator.pushNamed(context, '/dashboard');
                                            },
                                          ),
                                        ]
                                    );
                                  },
                                )
                            );
                            setState(() {

                            });
                          }: () async {
                            await DatabaseService(uid: couriers[renderContext.rowIdx].uid).approveCourier(true);
                            Navigator.pushNamed(context, '/dashboard');
                            },
                      ),
                      !approved ? IconButton(
                          icon: Icon(Icons.announcement_rounded, color: Colors.red,),
                          onPressed: () async{
                            bool licenseFront = false;
                            bool licenseBack = false;
                            bool nbiClearance = false;
                            bool vehicleRegOR = false;
                            bool vehicleRegCR = false;
                            bool vehiclePhoto = false;

                            List credentials = [licenseFront,licenseBack,nbiClearance,vehicleRegOR,vehicleRegCR,vehiclePhoto];
                            String _adminMessage = " ";
                            showDialog(
                                context: context,
                                builder: (BuildContext context) => StatefulBuilder(
                                  builder: (context, setState){
                                    return AlertDialog(
                                        content: Column(
                                          crossAxisAlignment: CrossAxisAlignment.center,
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            ListTile(
                                              title: Text("Notify the Courier", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),),
                                            ),
                                            SizedBox(height: 20),
                                            SizedBox(
                                              width: 500,
                                              child: TextFormField(
                                                maxLines: 2,
                                                maxLength: 200,
                                                decoration: InputDecoration(
                                                  hintText: 'Type something',
                                                  border: OutlineInputBorder(),
                                                ),
                                                keyboardType: TextInputType.multiline,
                                                onChanged: (val) => setState(() => _adminMessage = val),
                                              ),
                                            ),
                                            Column(
                                              children: [
                                                SizedBox(height: 30),
                                                Text("Select the credential that is invalid.", style: TextStyle(fontWeight: FontWeight.bold),),
                                                CheckboxListTile(
                                                  title: Text('Driver\'s License Front'),
                                                  value: credentials[0],
                                                  onChanged: (bool value) {
                                                    setState(() {
                                                      credentials[0] = value;
                                                    });
                                                  },
                                                ),
                                                CheckboxListTile(
                                                  title: const Text('Driver\'s License Back'),
                                                  value: credentials[1],
                                                  onChanged: (bool value) {
                                                    setState(() {
                                                      credentials[1] = value;
                                                    });
                                                  },
                                                ),
                                                CheckboxListTile(
                                                  title: const Text('NBI Clearance'),
                                                  value: credentials[2],
                                                  onChanged: (bool value) {
                                                    setState(() {
                                                      credentials[2] = value;
                                                    });
                                                  },
                                                ),
                                                CheckboxListTile(
                                                  title: const Text('Vehicle Registration OR'),
                                                  value: credentials[3],
                                                  onChanged: (bool value) {
                                                    setState(() {
                                                      credentials[3] = value;
                                                    });
                                                  },
                                                ),
                                                CheckboxListTile(
                                                  title: const Text('Vehicle Registration CR'),
                                                  value: credentials[4],
                                                  onChanged: (bool value) {
                                                    setState(() {
                                                      credentials[4] = value;
                                                    });
                                                  },
                                                ),
                                                CheckboxListTile(
                                                  title: const Text('Vehicle Photo'),
                                                  value: credentials[5],
                                                  onChanged: (bool value) {
                                                    setState(() {
                                                      credentials[5] = value;
                                                    });
                                                  },
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),

                                        actions: [
                                          TextButton(
                                            child: Text("Send"),
                                            onPressed: () async {
                                              await DatabaseService(uid: couriers[renderContext.rowIdx].uid).updateCourierMessage(_adminMessage);
                                              await DatabaseService(uid: couriers[renderContext.rowIdx].uid).updateCredentials(credentials);
                                              Navigator.pushNamed(context, '/dashboard');
                                            },
                                          ),
                                        ]);
                                  },
                                )
                            );
                          }
                      ): Container(),
                    ],
                  );
                }
              ),
            ];

            List<PlutoRow> rows = List.generate(couriers.length, (index) {

              String credentials = couriers[index].driversLicenseFront_+ ' ' +
                  couriers[index].driversLicenseBack_+ ' ' +
                  couriers[index].nbiClearancePhoto_+ ' ' +
                  couriers[index].vehicleRegistrationOR_+ ' ' +
                  couriers[index].vehicleRegistrationCR_+ ' ' +
                  couriers[index].vehiclePhoto_;
              return PlutoRow(
                cells: {
                  'name': PlutoCell(value: "${couriers[index].fName} ${couriers[index].lName}"),
                  'address': PlutoCell(value: couriers[index].address),
                  'email': PlutoCell(value: couriers[index].email),
                  'vehicle_type': PlutoCell(value: couriers[index].vehicleType),
                  'vehicle_color': PlutoCell(value: couriers[index].vehicleColor),
                  'credentials': PlutoCell(value: credentials,),
                  'commands' : PlutoCell(value: couriers[index].approved)
                },
              );
            });

            return Padding(
              padding: EdgeInsets.all(100),
              child: PlutoGrid(
                  columns: columns,
                  rows: rows,
                createHeader: (PlutoGridStateManager){
                    return Container(
                        color: Color(0xFFEEEEEE),
                        child: Align(
                          alignment: Alignment.center,
                          child: Text('Couriers',
                              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 30)
                          ),
                        )
                    );
                },
                createFooter: (PlutoGridStateManager){
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
