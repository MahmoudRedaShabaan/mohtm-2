import 'package:flutter/material.dart';
import 'package:myapp/constants.dart';
import 'package:myapp/login_page.dart';

import 'add_anniversary_page.dart';
void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Mohtm',
      // theme: ThemeData(primarySwatch: MaterialColor(primaryColor.value, <int, Color>{}),),
      initialRoute: '/',
      routes: {
        '/': (context) => LoginPage(),
        '/add_anniversary': (context) => AddAnniversaryPage(),
      },
    );  
  }
}
