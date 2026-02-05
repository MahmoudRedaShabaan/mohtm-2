import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'l10n/app_localizations.dart';


class ForgetPasswordPage extends StatefulWidget {
  const ForgetPasswordPage({super.key});

  @override
  _ForgetPasswordPageState createState() => _ForgetPasswordPageState();
}

class _ForgetPasswordPageState extends State<ForgetPasswordPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  bool _isLoading = false;
  String _resetMessage = '';

  @override
  void dispose() {
    _emailController.dispose();
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
          title: Text(
          AppLocalizations.of(context)!.forgetPassword,
          style: const TextStyle(
            fontFamily: 'Pacifico',
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Color.fromARGB(255, 80, 40, 120),
          ),
        ),
        //  title: Text(AppLocalizations.of(context)!.forgetPassword),
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
                            return AppLocalizations.of(context)!.pleaseEntervalidEmail;
                          }
                          if (!value.contains('@')) {
                            return AppLocalizations.of(context)!.pleaseEntervalidEmail;
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 32),
                      ElevatedButton(
                        onPressed: () async {
                          if (_formKey.currentState!.validate()) {
                            if (!_isLoading) {
                              String res = await _resetPassword(context);
                              ScaffoldMessenger.of(
                                context,
                              ).showSnackBar(SnackBar(content: Text(res)));
                            }
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
                        child: Text(AppLocalizations.of(context)!.restPassword),
                      ),
                      if (_resetMessage.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(top: 16.0),
                          child: Text(
                            _resetMessage,
                            style: TextStyle(color: const Color(0xFFEC06EC), fontFamily: 'Roboto'),
                            textAlign: TextAlign.center,
                          ),
                        ),
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

  Future<String> _resetPassword(BuildContext context) async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
        _resetMessage = '';
      });
      try {
        bool res = await checkIfEmailExistsInFirestore(
          _emailController.text.toLowerCase().trim(),
        );
        if (res == true) {
          await FirebaseAuth.instance.sendPasswordResetEmail(
            email: _emailController.text.toLowerCase().trim(),
          );
          setState(() {
            _isLoading = false;
            print(
              AppLocalizations.of(context)!.passwordResetSent(_emailController.text.toLowerCase().trim()),
            );
            _resetMessage = AppLocalizations.of(context)!.passwordResetSent(_emailController.text.toLowerCase().trim());
          });
        } else {
          setState(() {
          _isLoading = false;
          _resetMessage = AppLocalizations.of(context)!.emailNotFound;
          });
        }
      } on FirebaseAuthException catch (e) {
        setState(() {
          _isLoading = false;
          _resetMessage = AppLocalizations.of(context)!.errorSendRestmail(e.message.toString().trim());

         // _resetMessage = 'Error sending reset email: ${e.message}';
        });
        print('Error sending reset email: ${e.code} - ${e.message}');
        // Optionally, show a SnackBar here as well
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: ${e.message}')));
      } catch (e) {
        setState(() {
          _isLoading = false;
          _resetMessage = AppLocalizations.of(context)!.unexpectedErrorOccurred;
        });
        print('Unexpected error during password reset: $e');
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    }else{
      setState(() {
       // _isLoading = true;
        _resetMessage = AppLocalizations.of(context)!.pleaseInterValidInputs;
      });
    }
    return _resetMessage;
  }

  Future<bool> checkIfEmailExistsInFirestore(String email) async {
    try {
      final QuerySnapshot<Map<String, dynamic>> snapshot =
          await FirebaseFirestore.instance
              .collection('users')
              .where('email', isEqualTo: email)
              .limit(1) // We only need to find one matching document
              .get();

      return snapshot
          .docs
          .isNotEmpty; // If there's at least one document, the email exists
    } catch (e) {
      print('Error checking email in Firestore: $e');
      return false; // Assume it doesn't exist in case of an error
    }
  }
}
