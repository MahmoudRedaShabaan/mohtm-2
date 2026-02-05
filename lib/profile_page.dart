import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:myapp/lookup.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
// import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'l10n/app_localizations.dart';


class User {
  String firstName;
  String lastName;
  String email;
  String phoneNumber;
  String gender;
  DateTime? birthDay;
  String? profilePictureUrl;

  User({
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.phoneNumber,
    required this.gender,
    this.birthDay,
    this.profilePictureUrl,
  });

  // Factory method to create a User object from Firestore data
  factory User.fromFirestore(Map<String, dynamic> data) {
    return User(
      firstName: data['firstName'] ?? '',
      lastName: data['lastName'] ?? '',
      email: data['email'] ?? '',
      phoneNumber: data['phoneNumber'] ?? '',
      gender: data['gender'] ?? '',
      birthDay:
          data['birthDay'] != null
              ? (data['birthDay'] as Timestamp).toDate()
              : null,
      profilePictureUrl: data['profilePictureUrl'],
    );
  }
}

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  bool _isEditing = false;
  late TextEditingController _firstNameController;
  late TextEditingController _lastNameController;
  late TextEditingController _emailController;
  late TextEditingController _phoneNumberController;
  late TextEditingController _birthDayController;
  String? _selectedGenderId;
  DateTime? _selectedBirthDate;
  User? _user;
  File? _pickedImage;
  final bool _isUploadingImage = false;

  @override
  void initState() {
    super.initState();
    _fetchUserData();
  }

  Future<void> _fetchUserData() async {
    try {
      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser == null) {
        throw Exception("No user is currently logged in.");
      }

      final docSnapshot =
          await FirebaseFirestore.instance
              .collection(
                'users',
              ) // Replace with your Firestore collection name
              .doc(currentUser.uid) // Use the logged-in user's UID
              .get();

      if (docSnapshot.exists) {
        final userData = User.fromFirestore(docSnapshot.data()!);
        setState(() {
          _user = userData;
          _initializeControllers(userData);
        });
      } else {
        throw Exception("User data not found.");
      }
    } catch (e) {
      print("Error fetching user data: $e");
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error fetching user data: $e')));
    }
  }

  void _initializeControllers(User user) {
    _firstNameController = TextEditingController(text: user.firstName);
    _lastNameController = TextEditingController(text: user.lastName);
    _emailController = TextEditingController(text: user.email);
    _phoneNumberController = TextEditingController(text: user.phoneNumber);
    _birthDayController = TextEditingController(
      text: user.birthDay?.toLocal().toString().split(' ')[0] ?? '',
    );
    _selectedGenderId = user.gender;
    _selectedBirthDate = user.birthDay;
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _phoneNumberController.dispose();
    _birthDayController.dispose();
    super.dispose();
  }

  void _toggleEditMode() {
    if (_isEditing) {
      _saveChanges();
    } else {
      setState(() {
        _isEditing = true;
      });
    }
  }

  Future<void> _saveChanges() async {
    if (_user == null) return;

    try {
      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser == null) {
        throw Exception("No user is currently logged in.");
      }

      // String? imageUrl = _user!.profilePictureUrl;
      // if (_pickedImage != null) {
      //   final uploadedUrl = await _uploadProfileImage(_pickedImage!);
      //   if (uploadedUrl != null) {
      //     imageUrl = uploadedUrl;
      //   }
      // }
      String? imageUrl = _user!.profilePictureUrl;
      if (_pickedImage != null) {
        final localPath = await _saveProfileImageLocally(_pickedImage!);
        if (localPath != null) {
          imageUrl = localPath;
        }
      }

      await FirebaseFirestore.instance
          .collection('users')
          .doc(currentUser.uid)
          .update({
            'firstName': _firstNameController.text,
            'lastName': _lastNameController.text,
            'phoneNumber': _phoneNumberController.text,
            'gender': _selectedGenderId,
            'birthDay': _selectedBirthDate,
            'profilePictureUrl': imageUrl,
          });

      setState(() {
        _user!.firstName = _firstNameController.text;
        _user!.lastName = _lastNameController.text;
        _user!.phoneNumber = _phoneNumberController.text;
        _user!.gender = _selectedGenderId!;
        _user!.birthDay = _selectedBirthDate;
        _user!.profilePictureUrl = imageUrl;
        _pickedImage = null;
        _isEditing = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            AppLocalizations.of(context)!.profileUpdatedsuccessfully,
          ),
        ),
      );
    } catch (e) {
      print("Error saving changes: $e");
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error saving changes: $e')));
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedBirthDate ?? DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != _selectedBirthDate) {
      setState(() {
        _selectedBirthDate = picked;
        _birthDayController.text = picked.toLocal().toString().split(' ')[0];
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_user == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

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
            AppLocalizations.of(context)!.profile,
            style: const TextStyle(
              fontFamily: 'Pacifico',
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Color.fromARGB(255, 80, 40, 120),
            ),
          ),
          //title: Text(AppLocalizations.of(context)!.profile),
          actions: [
            IconButton(
              icon: Icon(_isEditing ? Icons.save : Icons.edit),
              onPressed: _toggleEditMode,
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
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    SizedBox(
                      width: 120,
                      height: 120,
                      child: Stack(
                        children: [
                          ClipOval(
                            child:
                                _pickedImage != null
                                    ? Image.file(
                                      _pickedImage!,
                                      fit: BoxFit.cover,
                                      width: 120,
                                      height: 120,
                                    )
                                    : (_user!.profilePictureUrl != null
                                        ? (_user!.profilePictureUrl!.startsWith(
                                              '/',
                                            )
                                            ? (File(
                                                  _user!.profilePictureUrl!,
                                                ).existsSync()
                                                ? Image.file(
                                                  File(
                                                    _user!.profilePictureUrl!,
                                                  ),
                                                  fit: BoxFit.cover,
                                                  width: 120,
                                                  height: 120,
                                                )
                                                : Image.asset(
                                                  'assets/images/placeholder.png',
                                                  fit: BoxFit.cover,
                                                  width: 120,
                                                  height: 120,
                                                ))
                                            : Image.network(
                                              _user!.profilePictureUrl!,
                                              fit: BoxFit.cover,
                                              width: 120,
                                              height: 120,
                                              errorBuilder: (
                                                context,
                                                error,
                                                stackTrace,
                                              ) {
                                                return Image.asset(
                                                  'assets/images/placeholder.png',
                                                  fit: BoxFit.cover,
                                                  width: 120,
                                                  height: 120,
                                                );
                                              },
                                            ))
                                        : Image.asset(
                                          'assets/images/placeholder.png',
                                          fit: BoxFit.cover,
                                          width: 120,
                                          height: 120,
                                        )),
                          ),
                          if (_isEditing)
                            Positioned(
                              bottom: 0,
                              right: 0,
                              child: InkWell(
                                onTap: _pickImage,
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: Colors.black54,
                                    shape: BoxShape.circle,
                                  ),
                                  padding: const EdgeInsets.all(8),
                                  child: const Icon(
                                    Icons.camera_alt,
                                    color: Colors.white,
                                    size: 24,
                                  ),
                                ),
                              ),
                            ),
                          if (_isUploadingImage)
                            const Positioned.fill(
                              child: Center(child: CircularProgressIndicator()),
                            ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    TextFormField(
                      controller: _firstNameController,
                      enabled: _isEditing,
                      decoration: InputDecoration(
                        labelText: AppLocalizations.of(context)!.firstName,
                        filled: true,
                        fillColor: const Color(0xFFE9D7F7),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(25),
                          borderSide: BorderSide(color: Color(0xFF502878)),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(25),
                          borderSide: BorderSide(color: Color(0xFFB365C1)),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _lastNameController,
                      enabled: _isEditing,
                      decoration: InputDecoration(
                        labelText: AppLocalizations.of(context)!.lastName,
                        filled: true,
                        fillColor: const Color(0xFFE9D7F7),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(25),
                          borderSide: BorderSide(color: Color(0xFF502878)),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(25),
                          borderSide: BorderSide(color: Color(0xFFB365C1)),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _emailController,
                      enabled: false,
                      decoration: InputDecoration(
                        labelText: AppLocalizations.of(context)!.email,
                        filled: true,
                        fillColor: const Color(0xFFE9D7F7),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(25),
                          borderSide: BorderSide(color: Color(0xFF502878)),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(25),
                          borderSide: BorderSide(color: Color(0xFFB365C1)),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _phoneNumberController,
                      enabled: _isEditing,
                      decoration: InputDecoration(
                        labelText: AppLocalizations.of(context)!.phone,
                        filled: true,
                        fillColor: const Color(0xFFE9D7F7),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(25),
                          borderSide: BorderSide(color: Color(0xFF502878)),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(25),
                          borderSide: BorderSide(color: Color(0xFFB365C1)),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    GestureDetector(
                      onTap: _isEditing ? () => _selectDate(context) : null,
                      child: AbsorbPointer(
                        child: TextFormField(
                          controller: _birthDayController,
                          enabled: _isEditing,
                          decoration: InputDecoration(
                            labelText: AppLocalizations.of(context)!.birthdate,
                            filled: true,
                            fillColor: const Color(0xFFE9D7F7),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(25),
                              borderSide: BorderSide(color: Color(0xFF502878)),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(25),
                              borderSide: BorderSide(color: Color(0xFFB365C1)),
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      initialValue: _selectedGenderId,
                      items:
                          (() {
                            final locale =
                                Localizations.localeOf(context).languageCode;
                            return LookupService().gender
                                .map<DropdownMenuItem<String>>((gender) {
                                  final value = gender['id'].toString();
                                  final name =
                                      locale == 'ar'
                                          ? (gender['genderAr'] ?? '')
                                          : (gender['genderEn'] ?? '');
                                  return DropdownMenuItem<String>(
                                    value: value,
                                    child: Text(name),
                                  );
                                })
                                .toList();
                          })(),
                      onChanged:
                          _isEditing
                              ? (newValue) {
                                setState(() {
                                  _selectedGenderId = newValue;
                                });
                              }
                              : null,
                      decoration: InputDecoration(
                        labelText: AppLocalizations.of(context)!.gender,
                        filled: true,
                        fillColor: const Color(0xFFE9D7F7),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(25),
                          borderSide: BorderSide(color: Color(0xFF502878)),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(25),
                          borderSide: BorderSide(color: Color(0xFFB365C1)),
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

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 75,
    );
    if (pickedFile != null) {
      setState(() {
        _pickedImage = File(pickedFile.path);
      });
    }
  }

  // Future<String?> _uploadProfileImage(File imageFile) async {
  //   try {
  //     setState(() {
  //       _isUploadingImage = true;
  //     });
  //     final user = FirebaseAuth.instance.currentUser;
  //     if (user == null) return null;
  //     final ref = FirebaseStorage.instance
  //         .ref()
  //         .child('profile_pictures')
  //         .child('${user.uid}.jpg');
  //     await ref.putFile(imageFile);
  //     final url = await ref.getDownloadURL();
  //     setState(() {
  //       _isUploadingImage = false;
  //     });
  //     return url;
  //   } catch (e) {
  //     setState(() {
  //       _isUploadingImage = false;
  //     });
  //     print('Image upload error: $e');
  //     return null;
  //   }
  // }
  Future<String?> _saveProfileImageLocally(File imageFile) async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final fileName =
          'profile_${FirebaseAuth.instance.currentUser?.uid ?? 'user'}.jpg';
      final localPath = path.join(directory.path, fileName);
      final savedImage = await imageFile.copy(localPath);
      return savedImage.path;
    } catch (e) {
      print('Local image save error: $e');
      return null;
    }
  }
}
