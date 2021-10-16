import 'package:firebase_core/firebase_core.dart';
import 'package:proxpress/UI/CourierUI/courier_create_post.dart';
import 'package:proxpress/UI/CourierUI/courier_profile.dart';
import 'package:proxpress/UI/CourierUI/pending_deliveries.dart';
import 'package:proxpress/UI/CourierUI/transaction_history.dart';
import 'package:proxpress/UI/CustomerUI/customer_create_post.dart';
import 'package:flutter/material.dart';
import 'package:proxpress/Load/load_screen.dart';
import 'package:proxpress/UI/CustomerUI/delivery_status_class.dart';
import 'package:proxpress/UI/login_screen.dart';
import 'package:proxpress/UI/reg_landing_page.dart';
import 'package:proxpress/UI/signup_courier.dart';
import 'package:proxpress/UI/signup_customer.dart';
import 'package:proxpress/UI/CustomerUI/dashboard_location.dart';
import 'package:page_transition/page_transition.dart';
import 'package:proxpress/UI/CourierUI/courier_dashboard.dart';
import 'package:proxpress/authenticate.dart';
import 'package:proxpress/classes/courier_classes/courier_updating_form.dart';
import 'package:proxpress/services/auth.dart';
import 'package:proxpress/services/notification.dart';
import 'UI/CourierUI/ongoing_delivery.dart';
import 'UI/CourierUI/proxpress_template_courier.dart';
import 'UI/CustomerUI/courier_bookmarks.dart';
import 'UI/CustomerUI/customer_profile.dart';
import 'package:provider/provider.dart';
import 'package:proxpress/models/user.dart';
import 'package:proxpress/wrapper.dart';
import 'package:proxpress/classes/customer_classes/customer_updating_form.dart';
import 'package:flutter/services.dart';

import 'UI/CustomerUI/proxpress_template_customer.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  NotificationService().initNotification();
  await Firebase.initializeApp();
  SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.dark
  ));
  runApp(PROXpressApp());
}

class PROXpressApp extends StatelessWidget{
  @override
  Widget build(BuildContext context) {
    return StreamProvider<TheUser>.value(
      value: AuthService().user,
      initialData: null,
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          primarySwatch: Colors.red,
        ),
        home: LoadScreen(),
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
            case '/courierBookmarks':
              return PageTransition(child: CourierBookmarks(), type: PageTransitionType.rightToLeftWithFade);
              break;
            case '/customerProfile':
              return PageTransition(child: CustomerProfile(), type: PageTransitionType.rightToLeftWithFade);
              break;
            case '/wrapper':
              return PageTransition(child: Wrapper(), type: PageTransitionType.rightToLeftWithFade);
              break;
            case '/customerUpdate':
              return PageTransition(child:CustomerUpdate(), type: PageTransitionType.bottomToTop);
              break;
            case '/customerProfile':
              return PageTransition(child:CustomerProfile(), type: PageTransitionType.rightToLeftWithFade);
              break;
            case '/courierDashboard':
              return PageTransition(child: CourierDashboard(), type: PageTransitionType.rightToLeftWithFade);
              break;
            case '/authenticate':
              return PageTransition(child: Authenticate(), type: PageTransitionType.bottomToTop);
              break;
            case '/courierProfile':
              return PageTransition(child: CourierProfile(), type: PageTransitionType.rightToLeftWithFade);
              break;
            case '/pendingDeliveries':
              return PageTransition(child: PendingDeliveries(), type: PageTransitionType.rightToLeftWithFade);
              break;
            case '/courierUpdate':
              return PageTransition(child: CourierUpdate(), type: PageTransitionType.bottomToTop);
              break;
            case '/ongoingDelivery':
              return PageTransition(child: OngoingDelivery(), type: PageTransitionType.rightToLeftWithFade);
              break;
            case '/transactionHistory':
              return PageTransition(child: TransactionHistory(), type: PageTransitionType.rightToLeftWithFade);
              break;
            case '/myRequests':
              return PageTransition(child: MyRequests(), type: PageTransitionType.rightToLeftWithFade);
              break;
            case '/template':
              return PageTransition(child: AppBarTemp(), type: PageTransitionType.rightToLeftWithFade);
              break;
            case '/template1':
              return PageTransition(child: AppBarTemp1(), type: PageTransitionType.rightToLeftWithFade);
              break;
            case '/customerCreatePost':
              return PageTransition(child: CustomerCreatePost(), type: PageTransitionType.bottomToTop);
              break;
            case '/courierCreatePost':
              return PageTransition(child: CourierCreatePost(), type: PageTransitionType.bottomToTop);
              break;
            default:
              return null;
          }
        },
      ),
    );
  }
}
