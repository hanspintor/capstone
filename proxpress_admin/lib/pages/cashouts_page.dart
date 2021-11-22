import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_admin_scaffold/admin_scaffold.dart';
import 'package:pluto_grid/pluto_grid.dart';
import 'package:proxpress/auth.dart';
import 'package:proxpress/couriers.dart';
import 'package:proxpress/database.dart';
import 'package:proxpress/login_screen.dart';

class CashOuts extends StatefulWidget {
  @override
  _CashOutsState createState() => _CashOutsState();
}

class _CashOutsState extends State<CashOuts> {
  PlutoGridStateManager stateManager;
  final AuthService _auth = AuthService();
  int activeTab = 0;

  @override
  Widget build(BuildContext context) {
    Stream<List<Courier>> courierList = FirebaseFirestore.instance
        .collection('Couriers')
        .where('Requested Cash-out', isEqualTo: true)
        .snapshots()
        .map(DatabaseService().courierDataListFromSnapshot);

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
        selectedRoute: '/cashouts',
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
          stream: courierList,
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              List<Courier> couriers = snapshot.data;

              List<PlutoColumn> columns = [
                PlutoColumn(
                  enableEditingMode: false,
                  title: 'Name',
                  field: 'name',
                  type: PlutoColumnType.text(),
                ),
                PlutoColumn(
                  enableEditingMode: false,
                  title: 'Contact Number',
                  field: 'contactno',
                  type: PlutoColumnType.text(),
                ),
                PlutoColumn(
                  enableEditingMode: false,
                  title: 'Wallet',
                  field: 'wallet',
                  type: PlutoColumnType.text(),
                ),
                PlutoColumn(
                    enableEditingMode: false,
                    title: 'Commands',
                    field: 'commands',
                    type: PlutoColumnType.text(),
                    renderer: (renderContext) {
                      return Row(
                        children: [
                          TextButton(
                            child: Text('Cash-out'),
                            onPressed: () async {
                              showDialog(
                                  context: context,
                                  builder: (BuildContext context) => StatefulBuilder(
                                    builder: (context, setState) {
                                      return AlertDialog(
                                          content: Text('Are you sure you want to proceed?'),
                                          actions: [
                                            ElevatedButton(
                                              child: Text("YES"),
                                              onPressed: () async {
                                                await DatabaseService(uid: couriers[renderContext.rowIdx].uid).updateRequestCashOut(0,false);
                                                Navigator.pushNamed(context, '/cashouts');
                                              },
                                            ),
                                            TextButton(
                                              child: Text("NO"),
                                              onPressed: () async {
                                                Navigator.pushNamed(context, '/cashouts');
                                              },
                                            ),
                                          ]);
                                    },
                                  )
                              );
                            },
                          ),
                        ],
                      );
                    }
                ),
              ];

              List<PlutoRow> rows = List.generate(couriers.length, (index) {

                return PlutoRow(
                  cells: {
                    'name': PlutoCell(value: "${couriers[index].fName} ${couriers[index].lName}"),
                    'contactno': PlutoCell(value: couriers[index].contactNo),
                    'wallet': PlutoCell(value: couriers[index].wallet),
                    'commands': PlutoCell(value: couriers[index].requestedCashOut),
                  },
                );
              });

              return Padding(
                padding: EdgeInsets.all(100),
                child: PlutoGrid(
                  columns: columns,
                  rows: rows,
                  createHeader: (PlutoGridStateManager) {
                    return Container(
                        color: Color(0xFFEEEEEE),
                        child: Align(
                          alignment: Alignment.center,
                          child: Text('Cash-outs',
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