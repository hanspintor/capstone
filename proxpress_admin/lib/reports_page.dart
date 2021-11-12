import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_admin_scaffold/admin_scaffold.dart';
import 'package:pluto_grid/pluto_grid.dart';
import 'package:provider/provider.dart';
import 'package:proxpress/auth.dart';
import 'package:proxpress/couriers.dart';
import 'package:proxpress/database.dart';
import 'package:proxpress/delivery_price_list.dart';
import 'package:proxpress/delivery_prices.dart';
import 'package:proxpress/login_screen.dart';
import 'package:proxpress/report_list.dart';
import 'package:proxpress/reports.dart';
import 'package:intl/intl.dart';

class ReportsPage extends StatefulWidget {
  final String savedPassword;
  ReportsPage({this.savedPassword});

  @override
  _ReportsPageState createState() => _ReportsPageState();
}

class _ReportsPageState extends State<ReportsPage> {
  final AuthService _auth = AuthService();

  Future<List<List<String>>> getNames(List<DocumentReference> couriers, List<DocumentReference> customers,int size) async {
    final List<String> generatedCouriers = [];
    final List<String> generatedCustomers = [];
    for (int i = 0; i < size; i++) {
      String reportTo = '';
      await FirebaseFirestore.instance
          .collection('Couriers')
          .doc(couriers[i].id)
          .get()
          .then((DocumentSnapshot documentSnapshot) {
        if (documentSnapshot.exists) {
          reportTo = '${documentSnapshot['First Name']} ${documentSnapshot['Last Name']}';
        }
      });
      generatedCouriers.add(reportTo);
    }
    for (int i = 0; i < size; i++) {
      String reportBy = '';
      await FirebaseFirestore.instance
          .collection('Customers')
          .doc(customers[i].id)
          .get()
          .then((DocumentSnapshot documentSnapshot) {
        if (documentSnapshot.exists) {
          reportBy = '${documentSnapshot['First Name']} ${documentSnapshot['Last Name']}';
        }
      });
      generatedCustomers.add(reportBy);
    }
    List<List<String>> combinedNames = [];
    combinedNames.add(generatedCustomers);
    combinedNames.add(generatedCouriers);
    print(combinedNames);
    return combinedNames;
  }

  // Future<List<String>> getCustomers (List<DocumentReference> customers, int size) async {
  //   final List<String> generatedCustomers = [];
  //   for (int i = 0; i < size; i++) {
  //     String reportBy = '';
  //     await FirebaseFirestore.instance
  //         .collection('Customers')
  //         .doc(customers[i].id)
  //         .get()
  //         .then((DocumentSnapshot documentSnapshot) {
  //       if (documentSnapshot.exists) {
  //         reportBy = '${documentSnapshot['First Name']} ${documentSnapshot['Last Name']}';
  //       }
  //     });
  //     generatedCustomers.add(reportBy);
  //   }
  //   return generatedCustomers;
  // }

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
        selectedRoute: '/reports',
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
      body: StreamBuilder<List<Reports>>(
        stream: DatabaseService().reportList,
        builder: (context, snapshot) {
          if(snapshot.hasData){
            List<Reports> reports = snapshot.data;

            List<PlutoColumn> columns = [
              PlutoColumn(
                enableEditingMode: false,
                title: 'Report Number',
                field: 'report_no',
                type: PlutoColumnType.number(),
              ),
              PlutoColumn(
                enableEditingMode: false,
                title: 'Customer Name',
                field: 'customer_name',
                type: PlutoColumnType.text(),
              ),
              PlutoColumn(
                enableEditingMode: false,
                title: 'Courier Name',
                field: 'courier_name',
                type: PlutoColumnType.text(),
              ),
              PlutoColumn(
                enableEditingMode: false,
                title: 'Complaint',
                field: 'complaint',
                type: PlutoColumnType.text(),
              ),
              PlutoColumn(
                enableEditingMode: false,
                title: 'Time Reported',
                field: 'time_reported',
                type: PlutoColumnType.time(),
              ),
            ];

            List<DocumentReference> couriers = [];
            List<DocumentReference> customers = [];

            reports.forEach((element) {
              couriers.add(element.reportTo);
              customers.add(element.reportBy);
            });

            return FutureBuilder<List<List<String>>>(
              future: getNames(couriers, customers, couriers.length),
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  List<List<String>> combinedNames = snapshot.data;

                  List<PlutoRow> rows = List.generate(reports.length, (index) {
                    String temp = '';

                    print(temp);
                    return PlutoRow(
                      cells: {
                        'report_no': PlutoCell(value: index + 1),
                        'customer_name': PlutoCell(value: combinedNames[0][index]),
                        'courier_name': PlutoCell(value: combinedNames[1][index]),
                        'complaint': PlutoCell(value: reports[index].reportMessage),
                        'time_reported': PlutoCell(value: DateFormat.yMMMMd('en_US').format(reports[index].time.toDate())),
                      },
                    );
                  });

                  return Padding(
                    padding: EdgeInsets.all(100),
                    child: PlutoGrid(
                        columns: columns,
                        rows: rows,
                        // onChanged: (PlutoGridOnChangedEvent event) {
                        //   //print(event);
                        //   // setState(() {
                        //   //   event.value
                        //   // });
                        // },
                        onLoaded: (PlutoGridOnLoadedEvent event) {
                          //print(event);
                        },
                      createHeader: (PlutoGridStateManager){
                        return Container(
                            color: Color(0xFFEEEEEE),
                            child: Align(
                              alignment: Alignment.center,
                              child: Text('Reports',
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
                } else {
                  print ('something');
                  return Container();
                }
              }
            );
          } else {
            return Container();
          }
        }
      ),
    );
  }
}
