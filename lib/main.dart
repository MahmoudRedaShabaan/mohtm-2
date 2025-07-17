import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:myapp/anniversary_info_page.dart';
import 'package:shared_preferences/shared_preferences.dart';
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
import 'lookup.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // If you're going to use other Firebase services in the background, initialize them here.
  await Firebase.initializeApp();
  print('Handling a background message: ${message.messageId}');
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await LookupService().initialize();
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  Locale _locale = const Locale('en');
  String? _fcmToken;

  void setLocale(Locale locale) async {
    setState(() {
      _locale = locale;
    });
    // Save selected language
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('selected_language', locale.languageCode);
  }
    @override
  void initState() {
    super.initState();
    _restoreLocale();
    _initFCM();
  }

  void _restoreLocale() async {
    final prefs = await SharedPreferences.getInstance();
    final langCode = prefs.getString('selected_language');
    if (langCode != null && langCode.isNotEmpty && langCode != _locale.languageCode) {
      setState(() {
        _locale = Locale(langCode);
      });
    }
  }

  void _initFCM() async {
    FirebaseMessaging messaging = FirebaseMessaging.instance;

    // Request permissions on iOS
    NotificationSettings settings= await messaging.requestPermission();
    print('User granted permission: ${settings.authorizationStatus}');
    final token = await messaging.getToken();
    setState(() {
      _fcmToken = token;
    });
    print("FCM Token: $_fcmToken");

    // Update the logged-in user's fcmToken in Firestore (initial set)
    final user = FirebaseAuth.instance.currentUser;
    if (user != null && token != null) {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .update({'fcmToken': token});
    }

    // Listen for token refreshes
    FirebaseMessaging.instance.onTokenRefresh.listen((newToken) async {
      print("New FCM Token: $newToken");
      setState(() {
        _fcmToken = newToken;
      });
      // Update the logged-in user's fcmToken in Firestore
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .update({'fcmToken': newToken});
      }
    });
  // Handle foreground messages
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print('Got a message whilst in the foreground!');
      print('Message data: ${message.data}');

      if (message.notification != null) {
        print('Message also contained a notification: ${message.notification!.title} - ${message.notification!.body}');
        // TODO: Display a local notification or update UI
      }
    });

    // Handle interaction when the app is opened from a terminated state
    RemoteMessage? initialMessage = await FirebaseMessaging.instance.getInitialMessage();
    if (initialMessage != null) {
      print('App opened from terminated state with message: ${initialMessage.data}');
      // TODO: Handle navigation or data based on the initial message
    }

    // Handle interaction when the app is opened from a background state
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      print('App opened from background state with message: ${message.data}');
      // TODO: Handle navigation or data based on the message
    });
    // // Subscribe to topic for all users
    // await messaging.subscribeToTopic('all_users');

    // // Handle foreground messages
    // FirebaseMessaging.onMessage.listen((RemoteMessage message) {
    //   if (message.notification != null) {
    //     // Show a dialog, snackbar, or local notification
    //     print('Message in foreground: ${message.notification!.title}');
    //   }
    // });
  }
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Mohtm',
      locale: _locale,
      supportedLocales: const [Locale('en'), Locale('ar')],
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
          return LoginPage(
            onLanguageChanged: (lang) {
              setLocale(Locale(lang));
            },
            currentLanguage: _locale.languageCode,
          );
        },
      ),
      routes: <String, WidgetBuilder>{
        '/forget_password': (context) => const ForgetPasswordPage(),
        '/change_password': (context) => const ChangePasswordPage(),
        '/anniversary_info':
            (context) => const AnniversaryInfoPage(anniversaryId: ''),
        '/profile': (context) => ProfilePage(),
        '/register': (context) => const RegisterPage(),
        '/add_anniversary': (context) => const AddAnniversaryPage(),
      },
    );
  }
}
