import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'home_page.dart';


class RegisterPage extends StatefulWidget {
  const RegisterPage({Key? key}) : super(key: key);

  @override
  _RegisterPageState createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  // GOOGLE SIGN-IN
  Future<void> signInWithGoogle() async {
    try {
      final GoogleSignIn googleSignIn = GoogleSignIn();
      await googleSignIn.signOut(); // Force account picker every time
      final GoogleSignInAccount? googleUser = await googleSignIn.signIn();
      if (googleUser == null) return; // User cancelled
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );
      UserCredential userCredential = await FirebaseAuth.instance.signInWithCredential(credential);
      // Check if user email exists in Firestore 'users' collection
      final userEmail = userCredential.user?.email;
      if (userEmail != null) {
        final query = await FirebaseFirestore.instance
            .collection('users')
            .where('email', isEqualTo: userEmail)
            .limit(1)
            .get();
        if (query.docs.isEmpty) {
          // Add user to Firestore with basic values
          await FirebaseFirestore.instance
              .collection('users')
              .doc(userCredential.user!.uid)
              .set({
            'email': userEmail,
            'gender': '1',
          });
        }
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => HomePage(
              onLanguageChanged: (String _) {},
              currentLanguage: 'en',
            ),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AppLocalizations.of(context)!.soticalUseNotFound)),
        );
      }
    } catch (e) {
      print('Google sign-in failed: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Google sign-in failed: $e')),
      );
    }
  }

  // FACEBOOK SIGN-IN
  Future<void> signInWithFacebook() async {
    try {
      final LoginResult result = await FacebookAuth.instance.login();
      if (result.status == LoginStatus.success) {
        final OAuthCredential facebookAuthCredential = FacebookAuthProvider.credential(result.accessToken!.tokenString);
        final userCredential = await FirebaseAuth.instance.signInWithCredential(facebookAuthCredential);
        final userEmail = userCredential.user?.email;
        if (userEmail != null) {
          final query = await FirebaseFirestore.instance
              .collection('users')
              .where('email', isEqualTo: userEmail)
              .limit(1)
              .get();
          if (query.docs.isEmpty) {
            // Add user to Firestore with basic values
            await FirebaseFirestore.instance
                .collection('users')
                .doc(userCredential.user!.uid)
                .set({
              'email': userEmail,
              'gender': '1',
            });
          }
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => HomePage(
                onLanguageChanged: (String _) {},
                currentLanguage: 'en',
              ),
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(AppLocalizations.of(context)!.soticalUseNotFound)),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Facebook sign-in failed: ${result.message}')),
        );
      }
    } catch (e) {
      print('Facebook sign-in failed: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Facebook sign-in failed: $e')),
      );
    }
  }
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

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
          title: Text(AppLocalizations.of(context)!.registerTitle),
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
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      TextFormField(
                        controller: _emailController,
                        decoration: InputDecoration(
                          labelText: AppLocalizations.of(context)!.email,
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
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return AppLocalizations.of(context)!.emailValidation;
                          }
                          if (!value.contains('@')) {
                            return AppLocalizations.of(context)!.emailValidation;
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 20),
                      TextFormField(
                        controller: _passwordController,
                        decoration: InputDecoration(
                          labelText: AppLocalizations.of(context)!.password,
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
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return AppLocalizations.of(context)!.passwordValidation;
                          }
                          if (value.length < 6) {
                            return AppLocalizations.of(context)!.passwordLengthValidation;
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 20),
                      TextFormField(
                        controller: _confirmPasswordController,
                        decoration: InputDecoration(
                          labelText: AppLocalizations.of(context)!.confirmPassword,
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
                              _obscureConfirmPassword ? Icons.visibility : Icons.visibility_off,
                              color: Color(0xFF502878),
                            ),
                            onPressed: () {
                              setState(() {
                                _obscureConfirmPassword = !_obscureConfirmPassword;
                              });
                            },
                          ),
                        ),
                        obscureText: _obscureConfirmPassword,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return AppLocalizations.of(context)!.pleaseConfirmPassword;
                          }
                          if (value != _passwordController.text) {
                            return AppLocalizations.of(context)!.passwordMatchValidation;
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 32),
                      ElevatedButton(
                        onPressed: () async {
                          if (_formKey.currentState!.validate()) {
                            String res=await createAccountByEmailAndPassword();
                            ScaffoldMessenger.of(context).showSnackBar(
                               SnackBar(content: Text(res)),
                            );
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFD6B4F7),
                          foregroundColor: const Color(0xFF502878),
                          minimumSize: const Size(double.infinity, 48),
                          side: const BorderSide(color: Color(0xFFB365C1)),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        child: Text(AppLocalizations.of(context)!.register),
                      ),
                      const SizedBox(height: 12),
                      ElevatedButton.icon(
                        icon: const Icon(Icons.login, color: Color(0xFF502878)),
                        label: Text(AppLocalizations.of(context)!.sigupWithGoogle),
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
                      const SizedBox(height: 12),
                      // ElevatedButton.icon for Facebook can be added here with similar style
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
  Future<String> createAccountByEmailAndPassword() async {
    String email = _emailController.text;
    String password = _passwordController.text;

    try {
      UserCredential userCredential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(email: email, password: password);

      User? user = userCredential.user;
      if (user != null) {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .set({
          'email': _emailController.text,
          'gender':'1'
        });
        // Send email verification
        await user.sendEmailVerification();
        // Return a message instructing the user to check their email
        return AppLocalizations.of(context)!.registerSuccessMessageWithVerification;
      } else {
        return AppLocalizations.of(context)!.registerErrorMessage;
      }
    } on FirebaseAuthException catch (e) {
      // Handle registration errors
      print(e);
      print(e.code);
      print("mmmreda");
      print(e.message);
      return "Registration failed: ${e.message}";
    } catch (e) {
      // Handle other potential errors (e.g., Firestore errors)
      print("Error saving user data: $e");
      return AppLocalizations.of(context)!.registerErrorMessage;
    }
  }

}

// print(default_api.read_file(path = "lib/login_page.dart"))