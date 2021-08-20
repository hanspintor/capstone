import 'package:firebase_core/firebase_core.dart';
import 'package:proxpress/dashboard_customer.dart';
import 'package:flutter/material.dart';
import 'package:proxpress/load_screen.dart';
import 'package:proxpress/login_screen.dart';
import 'package:proxpress/reg_landing_page.dart';
import 'package:proxpress/signup_courier.dart';
import 'package:proxpress/signup_customer.dart';
import 'package:proxpress/dashboard_location.dart';
import 'package:page_transition/page_transition.dart';


Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MaterialApp(home: PROXpressApp()));
}

class PROXpressApp extends StatelessWidget{


  @override
  Widget build(BuildContext context) {
    return MaterialApp(

      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.red,
      ),
      onGenerateRoute: (settings) {
        switch (settings.name) {
          case '/':
            return PageTransition(child: LoadScreen(), type: PageTransitionType.fade);
            break;
          case '/loginScreen':
            return PageTransition(child: LoginScreen(), type: PageTransitionType.rightToLeftWithFade);
            break;
          case '/regLandingPage':
            return PageTransition(child: RegLandingPage(), type: PageTransitionType.rightToLeftWithFade);
            break;
          case '/signupCustomer':
            return PageTransition(child: SignupCustomer(), type: PageTransitionType.rightToLeftWithFade);
            break;
          case '/signupCourier':
            return PageTransition(child: SignupCourier(), type: PageTransitionType.rightToLeftWithFade);
            break;
          case '/dashboardLocation':
            return PageTransition(child: DashboardLocation(), type: PageTransitionType.rightToLeftWithFade);
            break;
          case '/dashboardCustomer':
            return PageTransition(child: DashboardCustomer(), type: PageTransitionType.rightToLeftWithFade);
            break;
          default:
            return null;
        }
      },
    );
  }
}