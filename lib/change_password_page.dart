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
          _errorMessage = 'No user is currently logged in.';
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
          _errorMessage = 'Error updating password: ${e.message}';
        });
        print('Error updating password: ${e.code} - ${e.message}');
        // Optionally show an error SnackBar
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${e.message}')),
        );
      } catch (e) {
        setState(() {
          _isLoading = false;
          _errorMessage = 'An unexpected error occurred.';
        });
        print('Unexpected error during password update: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title:  Text(AppLocalizations.of(context)!.changePasswordTitle),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
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
                    border: const OutlineInputBorder(),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscureCurrentPassword
                            ? Icons.visibility
                            : Icons.visibility_off,
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
                    border: const OutlineInputBorder(),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscureNewPassword
                            ? Icons.visibility
                            : Icons.visibility_off,
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
                    border: const OutlineInputBorder(),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscureConfirmNewPassword
                            ? Icons.visibility
                            : Icons.visibility_off,
                      ),
                      onPressed: () {
                        setState(() {
                          _obscureConfirmNewPassword =
                              !_obscureConfirmNewPassword;
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
                  child: _isLoading
                      ? const CircularProgressIndicator()
                      :  Text(AppLocalizations.of(context)!.changePasswordButtonText),
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
    );
  }
}