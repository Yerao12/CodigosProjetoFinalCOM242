import 'package:estufa_app/HomeScreen.dart';
import 'package:flutter/material.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  runApp(MaterialApp(
    home: MyApp(),
    debugShowCheckedModeBanner: false,
  ));
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        //primaryColor: Color.fromARGB(255, 154, 196, 105),
        primaryColor: Color.fromARGB(255, 234, 247, 219),
      ),
      debugShowCheckedModeBanner: false,
      title: 'App Estufa de Flores',
      home: HomeScreen(),
      routes: {
        "/home": (_) => new HomeScreen(),
      },
    );
  }
}
