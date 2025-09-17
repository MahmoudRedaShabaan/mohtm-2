import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ChangePasswordPage extends StatefulWidget {
  const ChangePasswordPage({super.key});

  @override
  State<ChangePasswordPage> createState() => _ChangePasswordPageState();
}

class _ChangePasswordPageState extends State<ChangePasswordPage> {
  final _formKey = GlobalKey<FormState>();
  final _currentPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmNewPasswordController = TextEditingController();
  bool _obscureCurrentPassword = true;
  bool _obscureNewPassword = true;
  bool _obscureConfirmNewPassword = true;
  bool _isLoading = false;
  String _errorMessage = '';
  String _successMessage = '';

  Future<void> _changePassword() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
        _errorMessage = '';
        _successMessage = '';
      });

      final user = FirebaseAuth.instance.currentUser;
      final currentPassword = _currentPasswordController.text.trim();
      final newPassword = _newPasswordController.text.trim();

      if (user == null) {
        setState(() {
          _isLoading = false;
          _errorMessage = AppLocalizations.of(context)!.userNotLogin;
        });
        return;
      }

      try {
        // 1. Re-authenticate the user
        final credential = EmailAuthProvider.credential(
            email: user.email!, password: currentPassword);
        await user.reauthenticateWithCredential(credential);
        
        // 2. Update the password
        await user.updatePassword(newPassword);

        setState(() {
          _isLoading = false;
          _successMessage = AppLocalizations.of(context)!.changePasswordSuccessMessage;
          // Optionally clear the password fields after success
          _currentPasswordController.clear();
          _newPasswordController.clear();
          _confirmNewPasswordController.clear();
        });

        // Optionally show a success SnackBar
        ScaffoldMessenger.of(context).showSnackBar(
           SnackBar(content: Text(AppLocalizations.of(context)!.changePasswordSuccessMessage)),
        );
      } on FirebaseAuthException catch (e) {
        setState(() {
        _isLoading = false;
        _errorMessage = AppLocalizations.of(context)!.oldPasswordIncorrect;
         });
        print('Error updating password: ${e.code} - ${e.message}');
        // Optionally show an error SnackBar
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AppLocalizations.of(context)!.oldPasswordIncorrect)),
        );
      } catch (e) {
        setState(() {
          _isLoading = false;
          _errorMessage = AppLocalizations.of(context)!.unexpectedErrorOccurred;
        });
        print('Unexpected error during password update: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AppLocalizations.of(context)!.unexpectedErrorOccurred)),
        );
      }
    }
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
          AppLocalizations.of(context)!.changePasswordTitle,
          style: const TextStyle(
            fontFamily: 'Pacifico',
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Color.fromARGB(255, 80, 40, 120),
          ),
        ),
          //title: Text(AppLocalizations.of(context)!.changePasswordTitle),
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
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      TextFormField(
                        controller: _currentPasswordController,
                        obscureText: _obscureCurrentPassword,
                        decoration: InputDecoration(
                          labelText: AppLocalizations.of(context)!.currentPassword,
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
                              _obscureCurrentPassword ? Icons.visibility : Icons.visibility_off,
                              color: Color(0xFF502878),
                            ),
                            onPressed: () {
                              setState(() {
                                _obscureCurrentPassword = !_obscureCurrentPassword;
                              });
                            },
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return AppLocalizations.of(context)!.entercurrentPassword;
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 20.0),
                      TextFormField(
                        controller: _newPasswordController,
                        obscureText: _obscureNewPassword,
                        decoration: InputDecoration(
                          labelText: AppLocalizations.of(context)!.newPassword,
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
                              _obscureNewPassword ? Icons.visibility : Icons.visibility_off,
                              color: Color(0xFF502878),
                            ),
                            onPressed: () {
                              setState(() {
                                _obscureNewPassword = !_obscureNewPassword;
                              });
                            },
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return AppLocalizations.of(context)!.enterNewPassword;
                          }
                          if (value.length < 6) {
                            return AppLocalizations.of(context)!.passwordLengthValidation;
                          }
                          if (value == _currentPasswordController.text.trim()) {
                            return AppLocalizations.of(context)!.passwordsDoNotMatch;
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 20.0),
                      TextFormField(
                        controller: _confirmNewPasswordController,
                        obscureText: _obscureConfirmNewPassword,
                        decoration: InputDecoration(
                          labelText: AppLocalizations.of(context)!.confirmNewPassword,
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
                              _obscureConfirmNewPassword ? Icons.visibility : Icons.visibility_off,
                              color: Color(0xFF502878),
                            ),
                            onPressed: () {
                              setState(() {
                                _obscureConfirmNewPassword = !_obscureConfirmNewPassword;
                              });
                            },
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return AppLocalizations.of(context)!.enterConfirmNewPassword;
                          }
                          if (value != _newPasswordController.text.trim()) {
                            return AppLocalizations.of(context)!.passwordsDoNotMatch;
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 20.0),
                      ElevatedButton(
                        onPressed: _isLoading ? null : _changePassword,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFD6B4F7),
                          foregroundColor: const Color(0xFF502878),
                          minimumSize: const Size(double.infinity, 48),
                          side: const BorderSide(color: Color(0xFFB365C1)),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        child: _isLoading
                            ? const CircularProgressIndicator()
                            : Text(AppLocalizations.of(context)!.changePasswordButtonText),
                      ),
                      const SizedBox(height: 10.0),
                      if (_errorMessage.isNotEmpty)
                        Text(
                          _errorMessage,
                          style: const TextStyle(color: Colors.red),
                        ),
                      if (_successMessage.isNotEmpty)
                        Text(
                          _successMessage,
                          style: const TextStyle(color: Colors.green),
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
}