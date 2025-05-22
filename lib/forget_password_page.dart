import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ForgetPasswordPage extends StatefulWidget {
  const ForgetPasswordPage({Key? key}) : super(key: key);

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
    return Scaffold(
      appBar: AppBar(title: const Text('Forget Password')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(labelText: 'Email'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your email';
                  }
                  if (!value.contains('@')) {
                    return 'Please enter a valid email';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 32),
              // ElevatedButton(
              //     onPressed: _isLoading ? null : () => _resetPassword(context),
              //     child: _isLoading
              //         ? const CircularProgressIndicator()
              //         : const Text('Send Reset Email'),
              //   ),
              ElevatedButton(
                onPressed: () async {
                  if (_formKey.currentState!.validate()) {
                    // TODO: Implement forget password logic here (e.g., send email)
                    if (!_isLoading) {
                      String res = await _resetPassword(context);
                      ScaffoldMessenger.of(
                        context,
                      ).showSnackBar(SnackBar(content: Text(res)));
                     // Navigator.pop(context);
                      // Go back to login page
                    }
                  }
                },
                child: const Text('Reset Password'),
              ),
             if (_resetMessage.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 16.0),
                    child: Text(
                      _resetMessage,
                      style: TextStyle(color: const Color.fromARGB(255, 236, 6, 6), fontFamily: 'Roboto'),
                      textAlign: TextAlign.center,
                      
                    ),
                  ),
            ],
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
          _emailController.text.trim(),
        );
        if (res == true) {
          await FirebaseAuth.instance.sendPasswordResetEmail(
            email: _emailController.text.trim(),
          );
          setState(() {
            _isLoading = false;
            print(
              'Password reset email sent to ${_emailController.text.trim()}. Please check your inbox (and spam folder).',
            );
            _resetMessage =
                'Password reset email sent to ${_emailController.text.trim()}. Please check your inbox (and spam folder).';
          });
        } else {
          setState(() {
          _isLoading = false;
          _resetMessage = 'Email not found';
          });
        }
      } on FirebaseAuthException catch (e) {
        setState(() {
          _isLoading = false;
          _resetMessage = 'Error sending reset email: ${e.message}';
        });
        print('Error sending reset email: ${e.code} - ${e.message}');
        // Optionally, show a SnackBar here as well
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: ${e.message}')));
      } catch (e) {
        setState(() {
          _isLoading = false;
          _resetMessage = 'An unexpected error occurred.';
        });
        print('Unexpected error during password reset: $e');
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    }else{
      setState(() {
       // _isLoading = true;
        _resetMessage = '';
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
