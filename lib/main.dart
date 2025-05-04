import 'package:flutter/material.dart';
import 'package:myapp/login_page.dart';

import 'add_anniversary_page.dart';
import 'change_password_page.dart';
import 'profile_page.dart'; // Assuming you have a profile_page.dart with a ProfilePage widget
import 'register_page.dart';
import 'forget_password_page.dart';

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
      routes: <String, WidgetBuilder>{
        '/': (context) => const LoginPage(),
        '/forget_password': (context) => const ForgetPasswordPage(),
        '/change_password': (context) => const ChangePasswordPage(),
        '/profile':
            (context) =>
                ProfilePage(user: loggedInUser), // Pass the global user here
        '/register': (context) => const RegisterPage(),
      },
    );
  }
}
