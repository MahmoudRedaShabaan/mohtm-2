import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:myapp/anniversary_info_page.dart';
import 'home_page.dart';
import 'package:myapp/login_page.dart';
import 'add_anniversary_page.dart';
import 'change_password_page.dart';
import 'profile_page.dart';
import 'register_page.dart';
import 'forget_password_page.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'firebase_options.dart';
 import 'package:flutter_gen/gen_l10n/app_localizations.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  Locale _locale = const Locale('en');

  void setLocale(Locale locale) {
    setState(() {
      _locale = locale;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Mohtm',
      locale: _locale,
      supportedLocales: const [
        Locale('en'),
        Locale('ar'),
      ],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        AppLocalizations.delegate,
      ],
      home: StreamBuilder(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasData) {
            // User is logged in
            return HomePage(
              onLanguageChanged: (lang) {
                setLocale(Locale(lang));
              },
              currentLanguage: _locale.languageCode,
            );
          }
          // User is not logged in
          return const LoginPage();
        },
      ),
      routes: <String, WidgetBuilder>{
        '/forget_password': (context) => const ForgetPasswordPage(),
        '/change_password': (context) => const ChangePasswordPage(),
        '/anniversary_info': (context) => const AnniversaryInfoPage(anniversaryId: ''),
        '/profile': (context) => ProfilePage(),
        '/register': (context) => const RegisterPage(),
        '/add_anniversary': (context) => const AddAnniversaryPage(),
      },
    );
  }
}