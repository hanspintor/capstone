import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'package:proxpress/couriers.dart';
import 'package:proxpress/dashboard.dart';
import 'package:proxpress/database.dart';
import 'package:proxpress/login_screen.dart';

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
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          primarySwatch: Colors.red,
        ),
        home: LoginScreen(),
      ),
    );
  }
}
