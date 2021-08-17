import 'package:ProExpress/courier_bookmarks.dart';
import 'package:ProExpress/dashboard_customer.dart';
import 'package:flutter/material.dart';
import 'package:ProExpress/load_screen.dart';
import 'package:ProExpress/login_screen.dart';
import 'package:ProExpress/reg_landing_page.dart';
import 'package:ProExpress/signup_courier.dart';
import 'package:ProExpress/signup_customer.dart';
import 'package:ProExpress/dashboard_location.dart';
import 'package:page_transition/page_transition.dart';

void main()=> runApp(PROExporessApp());

class PROExporessApp extends StatelessWidget{

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
          case '/courierBookmarks':
            return PageTransition(child: CourierBookmarks(), type: PageTransitionType.rightToLeftWithFade);
            break;
          default:
            return null;
        }
      },
    );
  }
}