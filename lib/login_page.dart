import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'constants.dart';
import 'home_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  Locale _locale = const Locale('en');
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  String _errorMessage = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: neutralColor,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Text(
                  'Login to Mohtm',
                  style: TextStyle(
                    fontFamily: 'Roboto',
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 48),
                TextField(
                  controller: _emailController,
                  decoration: InputDecoration(
                    hintText: 'Email',
                    filled: true,
                    prefixIcon: const Icon(Icons.email, color: Colors.black54),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(25),

                      borderSide: const BorderSide(color: Colors.black),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(color: accentColor),
                    ),
                  ),
                  keyboardType: TextInputType.emailAddress,
                  style: const TextStyle(fontFamily: 'Roboto'),
                ),
                const SizedBox(height: 24),
                TextField(
                  controller: _passwordController,
                  decoration: InputDecoration(
                    hintText: 'Password',
                    filled: true,
                    prefixIcon: const Icon(Icons.lock, color: Colors.black54),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(25),

                      borderSide: const BorderSide(color: Colors.black),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(color: accentColor),
                    ),
                  ),
                  obscureText: true,
                  style: const TextStyle(fontFamily: 'Roboto'),
                ),
                const SizedBox(height: 32),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () {
                      Navigator.pushNamed(context, '/forget_password');
                    },
                    child: Text('Forget Password?'),
                  ),
                ),
                TextButton(
                  onPressed: () {
                    // if (_emailController.text == 'test@ex' &&
                    //     _passwordController.text == '12345') {
                    //   Navigator.pushReplacement(
                    //     context,
                    //     MaterialPageRoute(builder: (context) => HomePage()),
                    //   );
                    // } else {
                    //   setState(() {
                    //     _errorMessage = 'Invalid email or password';
                    //   });
                    // }
                    loginUserWithEmailAndPassword2();
                  },
                  style: TextButton.styleFrom(
                    backgroundColor: primaryColor,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 50,
                      vertical: 15,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: Text(
                    'Login',
                    style: TextStyle(
                      color: neutralColor,
                      fontSize: 18,
                      fontFamily: 'Roboto',
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                TextButton(
                  onPressed: () {
                    // Navigate to the registration page
                    Navigator.pushNamed(
                      context,
                      '/register',
                    ); // Assuming you have a '/register' route
                  },
                  child: Text(
                    'Don\'t have an account?',
                    style: TextStyle(
                      color:
                          accentColor, // Use accentColor for link-like appearance
                    ),
                  ),
                ),
                if (_errorMessage.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 16.0),
                    child: Text(
                      _errorMessage,
                      style: TextStyle(color: Colors.red, fontFamily: 'Roboto'),
                    ),
                  ),
              ],
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

  Future<void> loginUserWithEmailAndPassword() async {
    try {
      final UserCredential = await FirebaseAuth.instance
          .signInWithEmailAndPassword(
            email: _emailController.text.trim(),
            password: _passwordController.text.trim(),
          );
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => HomePage(
              onLanguageChanged: (lang) {
                setLocale(Locale(lang));
              },
              currentLanguage: _locale.languageCode,
            )),
      );
      print(UserCredential);
      // return "true";
    } on FirebaseAuthException catch (e) {
      print(e.message);
      _errorMessage = e.message.toString();
      // return "e.message";
    }
  }
void setLocale(Locale locale) {
    setState(() {
      _locale = locale;
    });
  }
  Future<void> loginUserWithEmailAndPassword2() async {
    try {
      final UserCredential userCredential = await FirebaseAuth.instance
          .signInWithEmailAndPassword(
            email: _emailController.text.trim(),
            password: _passwordController.text.trim(),
          );
      // User logged in successfully!
      print('Logged in user: ${userCredential.user?.uid}');
      // Navigate to your home screen or next page
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => HomePage(
              onLanguageChanged: (lang) {
                setLocale(Locale(lang));
              },
              currentLanguage: _locale.languageCode,
            ),
        ), // Replace HomeScreen
      );
      setState(() {
        _errorMessage = ''; // Clear any previous error messages
      });
    } on FirebaseAuthException catch (e) {
      setState(() {
        print(e);
        print(e.code);
        print("reda");
        _errorMessage = _handleFirebaseError(e.code);
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'An unexpected error occurred.';
      });
    }
  }

  String _handleFirebaseError(String errorCode) {
    switch (errorCode) {
      case 'user-not-found':
        return 'No user found with this email.';
      case 'wrong-password':
        return 'Wrong password provided for that user.';
      case 'invalid-email':
        return 'The email address is not valid.';
      case 'user-disabled':
        return 'The user account has been disabled.';
      case 'invalid-credential':
        return 'Invaild email or Password.';
      default:
        return 'An erroroccurred during login.';
    }
  }
}
