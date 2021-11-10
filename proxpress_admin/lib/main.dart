import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:page_transition/page_transition.dart';
import 'package:provider/provider.dart';
import 'package:proxpress/couriers.dart';
import 'package:proxpress/dashboard.dart';
import 'package:proxpress/database.dart';
import 'package:proxpress/delivery_prices_page.dart';
import 'package:proxpress/login_screen.dart';
import 'package:proxpress/reports_page.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(PROXpressApp());
}

class PROXpressApp extends StatelessWidget{
  @override
  Widget build(BuildContext context) {
    return StreamProvider<List<Courier>>.value(
      value: DatabaseService().courierList,
      initialData: null,
      child: MaterialApp(
        title: 'PROXpress',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          primarySwatch: Colors.red,
        ),
        home: Dashboard(),
        onGenerateRoute: (settings){
          switch(settings.name){
            case '/dashboard':
              return PageTransition(child: Dashboard(), type: PageTransitionType.fade);
              break;
            case '/prices':
              return PageTransition(child: DeliveryPricesPage(), type: PageTransitionType.fade);
              break;
            case '/reports':
              return PageTransition(child: ReportsPage(), type: PageTransitionType.fade);
              break;
            default:
              return null;
          }
        },
      ),
    );
  }
}
