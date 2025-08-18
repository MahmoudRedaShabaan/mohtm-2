import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:myapp/appfeedback.dart';
import 'constants.dart';
import 'home_page.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_messaging/firebase_messaging.dart';


class LoginPage extends StatefulWidget {
  final void Function(String lang)? onLanguageChanged;
  final String? currentLanguage;
  const LoginPage({super.key, this.onLanguageChanged, this.currentLanguage});

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  bool _rememberMe = false;
  String? _fcmToken;
  @override
  void initState() {
    super.initState();
    _loadSavedCredentials();
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
  }
  void _loadSavedCredentials() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if (mounted) {
      _emailController.text = prefs.getString('saved_email') ?? '';
      _passwordController.text = prefs.getString('saved_password') ?? '';
      _rememberMe = prefs.getBool('remember_me') ?? false;
    }
  }
  // GOOGLE SIGN-IN
  Future<void> signInWithGoogle() async {
    try {
      final GoogleSignIn googleSignIn = GoogleSignIn();
      await googleSignIn.signOut(); // Show account picker every time
      final GoogleSignInAccount? googleUser = await googleSignIn.signIn();
      if (googleUser == null) return; // User cancelled
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        idToken: googleAuth.idToken,
      );
      // Validate user registration in Firestore before login
      final userEmail = googleUser.email;
      final query = await FirebaseFirestore.instance
          .collection('users')
          .where('email', isEqualTo: userEmail)
          .limit(1)
          .get();
      if (query.docs.isNotEmpty) {
        UserCredential userCredential = await FirebaseAuth.instance.signInWithCredential(credential);
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => HomePage(
              onLanguageChanged: widget.onLanguageChanged ?? (_) {},
              currentLanguage: widget.currentLanguage ?? 'en',
            ),
          ),
        );
        _initFCM();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AppLocalizations.of(context)!.soticalUseNotFound)),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Google sign-in failed: $e')),
      );
    }
  }

  // FACEBOOK SIGN-IN
  Future<void> signInWithFacebook() async {
    try {
      // Import the required package in your pubspec.yaml: flutter_facebook_auth
      // and add: import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
      final LoginResult result = await FacebookAuth.instance.login();
      if (result.status == LoginStatus.success) {
        final OAuthCredential facebookAuthCredential = FacebookAuthProvider.credential(result.accessToken!.tokenString);
        // Check if user email exists in Firestore 'users' collection
        final userCredential = await FirebaseAuth.instance.signInWithCredential(facebookAuthCredential);
        final userEmail = userCredential.user?.email;
        if (userEmail != null) {
          final query = await FirebaseFirestore.instance
              .collection('users')
              .where('email', isEqualTo: userEmail)
              .limit(1)
              .get();
          if (query.docs.isNotEmpty) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => HomePage(
                  onLanguageChanged: widget.onLanguageChanged ?? (_) {},
                  currentLanguage: widget.currentLanguage ?? 'en',
                ),
              ),
            );
          } else {
            // Sign out if not registered
            await FirebaseAuth.instance.signOut();
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(AppLocalizations.of(context)!.soticalUseNotFound)),
            );
          }
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Facebook sign-in failed: ${result.message}')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Facebook sign-in failed: $e')),
      );
    }
  }
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  String _errorMessage = '';
  bool _obscurePassword = true;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Color(0xFFF3E6F9),
            Color(0xFFE9D7F7),
            Color(0xFFD6B4F7),
            Color(0xFFC7A1E6),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          surfaceTintColor: Colors.transparent,
          shadowColor: Colors.transparent,
          automaticallyImplyLeading: false,
          actions: [
            IconButton(
              icon: const Icon(Icons.language, color: Colors.black),
              onPressed: () {
                showModalBottomSheet(
                  context: context,
                  useSafeArea: true,
                  builder: (context) {
                    return SafeArea(
                      child: SingleChildScrollView(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            ListTile(
                              leading: Icon(
                                Icons.check,
                                color: (widget.currentLanguage ?? 'en') == 'en' ? Colors.green : Colors.transparent,
                              ),
                              title: const Text('English'),
                              onTap: () {
                                widget.onLanguageChanged?.call('en');
                                Navigator.pop(context);
                              },
                            ),
                            ListTile(
                              leading: Icon(
                                Icons.check,
                                color: (widget.currentLanguage ?? 'en') == 'ar' ? Colors.green : Colors.transparent,
                              ),
                              title: const Text('العربية'),
                              onTap: () {
                                widget.onLanguageChanged?.call('ar');
                                Navigator.pop(context);
                              },
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
            IconButton(
              icon: const Icon(Icons.contact_mail, color: Color.fromARGB(255, 4, 4, 242)),
              tooltip: AppLocalizations.of(context)!.contactUs,
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const AppFeedbackPage()),
                );
              },
            ),
          ],
        ),
        body: Center(
          child: SingleChildScrollView(
            child: Card(
              elevation: 8,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(32),
              ),
              color: const Color(0xFFF3E6F9),
              margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
              child: Padding(
                padding: const EdgeInsets.all(32.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Image.asset(
                      'assets/images/iconremovebg.png',
                      height: 100,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      AppLocalizations.of(context)!.loginToMohtm,
                      style: const TextStyle(
                        fontFamily: 'Roboto',
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF502878),
                      ),
                    ),
                    const SizedBox(height: 32),
                    TextField(
                      controller: _emailController,
                      decoration: InputDecoration(
                        hintText: AppLocalizations.of(context)!.email,
                        filled: true,
                        fillColor: const Color(0xFFE9D7F7),
                        prefixIcon: const Icon(Icons.email, color: Color(0xFF502878)),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(25),
                          borderSide: BorderSide(color: Color(0xFF502878)),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(25),
                          borderSide: BorderSide(color: Color(0xFFB365C1)),
                        ),
                      ),
                      keyboardType: TextInputType.emailAddress,
                      style: const TextStyle(fontFamily: 'Roboto'),
                    ),
                    const SizedBox(height: 20),
                    TextField(
                      controller: _passwordController,
                      decoration: InputDecoration(
                        hintText: AppLocalizations.of(context)!.password,
                        filled: true,
                        fillColor: const Color(0xFFE9D7F7),
                        prefixIcon: const Icon(Icons.lock, color: Color(0xFF502878)),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(25),
                          borderSide: BorderSide(color: Color(0xFF502878)),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(25),
                          borderSide: BorderSide(color: Color(0xFFB365C1)),
                        ),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscurePassword ? Icons.visibility : Icons.visibility_off,
                            color: Color(0xFF502878),
                          ),
                          onPressed: () {
                            setState(() {
                              _obscurePassword = !_obscurePassword;
                            });
                          },
                        ),
                      ),
                      obscureText: _obscurePassword,
                      style: const TextStyle(fontFamily: 'Roboto'),
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton.icon(
                      icon: const Icon(Icons.login, color: Color(0xFF502878)),
                      label: Text(AppLocalizations.of(context)!.login),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFD6B4F7),
                        foregroundColor: const Color(0xFF502878),
                        minimumSize: const Size(double.infinity, 48),
                        side: const BorderSide(color: Color(0xFFB365C1)),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      onPressed: () {
                        loginUserWithEmailAndPassword2();
                      },
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Checkbox(
                          value: _rememberMe,
                          activeColor: const Color(0xFFB365C1),
                          onChanged: (value) {
                            setState(() {
                              _rememberMe = value ?? false;
                            });
                          },
                        ),
                        Text(AppLocalizations.of(context)!.rememberme, style: const TextStyle(color: Color(0xFF502878))),
                      ],
                    ),
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: () {
                          Navigator.pushNamed(context, '/forget_password');
                        },
                        child: Text(AppLocalizations.of(context)!.forgetPasswordquestion, style: const TextStyle(color: Color(0xFFB365C1))),
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.pushNamed(
                          context,
                          '/register',
                        );
                      },
                      child: Text(
                        AppLocalizations.of(context)!.donthaveAnAccount,
                        style: const TextStyle(color: Color(0xFFB365C1)),
                      ),
                    ),
                    const SizedBox(height: 12),
                    ElevatedButton.icon(
                      icon: const Icon(Icons.login, color: Color(0xFF502878)),
                      label: Text(AppLocalizations.of(context)!.signinwithGoogle),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFD6B4F7),
                        foregroundColor: const Color(0xFF502878),
                        minimumSize: const Size(double.infinity, 48),
                        side: const BorderSide(color: Color(0xFFB365C1)),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      onPressed: signInWithGoogle,
                    ),
                    // ElevatedButton.icon for Facebook can be added here with similar style
                    if (_errorMessage.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 16.0),
                        child: Text(
                          _errorMessage,
                          style: const TextStyle(color: Colors.red, fontFamily: 'Roboto'),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // Future<void> loginUserWithEmailAndPassword() async {
  //   try {
  //     final UserCredential = await FirebaseAuth.instance
  //         .signInWithEmailAndPassword(
  //           email: _emailController.text.trim(),
  //           password: _passwordController.text.trim(),
  //         );
  //     Navigator.pushReplacement(
  //       context,
  //       MaterialPageRoute(builder: (context) => HomePage(
  //             onLanguageChanged: widget.onLanguageChanged ?? (_) {},
  //             currentLanguage: widget.currentLanguage ?? 'en',
  //           )),
  //     );
  //     print(UserCredential);
  //     // return "true";
  //   } on FirebaseAuthException catch (e) {
  //     print(e.message);
  //     _errorMessage = e.message.toString();
  //     // return "e.message";
  //   }
  // }

  Future<void> loginUserWithEmailAndPassword2() async {
    try {
      final UserCredential userCredential = await FirebaseAuth.instance
          .signInWithEmailAndPassword(
            email: _emailController.text.trim(),
            password: _passwordController.text.trim(),
          );
      _initFCM();
      SharedPreferences prefs = await SharedPreferences.getInstance();
      if (_rememberMe) {
        await prefs.setString('saved_email', _emailController.text.trim());
        await prefs.setString('saved_password', _passwordController.text.trim());
      } else {
        await prefs.remove('saved_email');
        await prefs.remove('saved_password');
      }
      await prefs.setBool('remember_me', _rememberMe);
      // Check if email is verified
      if (userCredential.user != null && !userCredential.user!.emailVerified) {
        await FirebaseAuth.instance.signOut();
        if (mounted) {
          setState(() {
            _errorMessage = AppLocalizations.of(context)!.emailNotVerifiedMessage;
          });
        }
        return;
      }
      // User logged in successfully and email is verified!
      print('Logged in user: \\${userCredential.user?.uid}');
      // Navigate to your home screen or next page
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => HomePage(
              onLanguageChanged: widget.onLanguageChanged ?? (_) {},
              currentLanguage: widget.currentLanguage ?? 'en',
            ),
        ), // Replace HomeScreen
      );
      if (mounted) {
        setState(() {
          _errorMessage = ''; // Clear any previous error messages
        });
      }
    } on FirebaseAuthException catch (e) {
      if (mounted) {
        setState(() {
          print(e);
          print(e.code);
          print("reda");
          _errorMessage = _handleFirebaseError(e.code);
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = AppLocalizations.of(context)!.unexpectedErrorOccurred;
        });
      }
    }
  }

  String _handleFirebaseError(String errorCode) {
    switch (errorCode) {
      case 'user-not-found':
        return AppLocalizations.of(context)!.userNotFound;
      case 'wrong-password':
        return AppLocalizations.of(context)!.userNotFound;
      case 'invalid-email':
        return AppLocalizations.of(context)!.userNotFound;
      case 'user-disabled':
        return AppLocalizations.of(context)!.userNotFound;
      case 'invalid-credential':
        return AppLocalizations.of(context)!.userNotFound;
      default:
        return AppLocalizations.of(context)!.errorOccurred;
    }
  }
}
