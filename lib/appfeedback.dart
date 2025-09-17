import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:myapp/home_page.dart';
import 'package:myapp/login_page.dart';

class AppFeedbackPage extends StatefulWidget {
  const AppFeedbackPage({super.key});

  @override
  State<AppFeedbackPage> createState() => _AppFeedbackPageState();
}

class _AppFeedbackPageState extends State<AppFeedbackPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _commentController = TextEditingController();
  String? _errorMessage;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    final user = FirebaseAuth.instance.currentUser;
    if (user != null && user.email != null) {
      _emailController.text = user.email!;
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _titleController.dispose();
    _commentController.dispose();
    super.dispose();
  }

  Future<void> _submitFeedback() async {
    setState(() {
      _errorMessage = null;
    });
    final email = _emailController.text.trim();
    final title = _titleController.text.trim();
    final comment = _commentController.text.trim();
    final user = FirebaseAuth.instance.currentUser;

    if (title.isEmpty || comment.isEmpty) {
      setState(() {
        _errorMessage = AppLocalizations.of(context)!.feedbackrequiredFields;
      });
      return;
    }
    if (comment.length > 1000) {
      setState(() {
        _errorMessage = AppLocalizations.of(context)!.commentTooLong;
      });
      return;
    }
    setState(() {
      _isSubmitting = true;
    });
    try {
      await FirebaseFirestore.instance.collection('comments').add({
        'userid': user?.uid,
        'email': email,
        'title': title,
        'comment': comment,
        'timestamp': FieldValue.serverTimestamp(),
        'read': false,
      });
      setState(() {
        _isSubmitting = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context)!.feedbackSent)),
      );
      _titleController.clear();
      _commentController.clear();
      Future.delayed(const Duration(milliseconds: 500), () {
        if (user != null) {
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(
              builder:
                  (context) => HomePage(
                    onLanguageChanged: (_) {},
                    currentLanguage:
                        Localizations.localeOf(context).languageCode,
                  ),
            ),
            (route) => false,
          );
        } else {
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(
              builder:
                  (context) => LoginPage(
                    onLanguageChanged: (_) {},
                    currentLanguage:
                        Localizations.localeOf(context).languageCode,
                  ),
            ),
            (route) => false,
          );
        }
      });
    } catch (e) {
      setState(() {
        _isSubmitting = false;
        _errorMessage = AppLocalizations.of(context)!.feedbackError;
      });
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
            AppLocalizations.of(context)!.feedbackTitle,
            style: const TextStyle(
              fontFamily: 'Pacifico',
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Color.fromARGB(255, 80, 40, 120),
            ),
          ),
          //title: Text(AppLocalizations.of(context)!.feedbackTitle),
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
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    TextField(
                      controller: _emailController,
                      decoration: InputDecoration(
                        labelText: AppLocalizations.of(context)?.email,
                        filled: true,
                        fillColor: const Color(0xFFE9D7F7),
                        prefixIcon: const Icon(
                          Icons.email,
                          color: Color(0xFF502878),
                        ),
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
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _titleController,
                      decoration: InputDecoration(
                        labelText: AppLocalizations.of(context)?.subject,
                        filled: true,
                        fillColor: const Color(0xFFE9D7F7),
                        prefixIcon: const Icon(
                          Icons.title,
                          color: Color(0xFF502878),
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(25),
                          borderSide: BorderSide(color: Color(0xFF502878)),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(25),
                          borderSide: BorderSide(color: Color(0xFFB365C1)),
                        ),
                      ),
                      maxLength: 50,
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _commentController,
                      decoration: InputDecoration(
                        labelText: AppLocalizations.of(context)!.body,
                        filled: true,
                        fillColor: const Color(0xFFE9D7F7),
                        prefixIcon: const Icon(
                          Icons.comment,
                          color: Color(0xFF502878),
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(25),
                          borderSide: BorderSide(color: Color(0xFF502878)),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(25),
                          borderSide: BorderSide(color: Color(0xFFB365C1)),
                        ),
                      ),
                      maxLines: 6,
                      maxLength: 250,
                    ),
                    const SizedBox(height: 24),
                    if (_errorMessage != null)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 12.0),
                        child: Text(
                          _errorMessage!,
                          style: const TextStyle(color: Colors.red),
                        ),
                      ),
                    ElevatedButton.icon(
                      icon: const Icon(Icons.send, color: Color(0xFF502878)),
                      label: Text(AppLocalizations.of(context)!.send),
                      onPressed: _isSubmitting ? null : _submitFeedback,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFD6B4F7),
                        foregroundColor: const Color(0xFF502878),
                        minimumSize: const Size(double.infinity, 48),
                        side: const BorderSide(color: Color(0xFFB365C1)),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
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
}
