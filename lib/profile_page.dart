import 'package:flutter/material.dart';

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
}

User loggedInUser = User(
  firstName: 'reda',
  lastName: 'mohamed',
  email: 'reda@gmail.com',
  phoneNumber: '+21366666666',
  gender: 'Male',
  birthDay: DateTime(1990, 1, 1),
  profilePictureUrl: 'https://upload.wikimedia.org/wikipedia/commons/thumb/2/2c/Default_pfp.svg/1200px-Default_pfp.svg.png',
);
class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key, required this.user});
  final User user;
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
  String? _selectedGender;
  DateTime? _selectedBirthDate;

  @override
  void initState() {
    super.initState();
    _firstNameController = TextEditingController(text: widget.user.firstName);
    _lastNameController = TextEditingController(text: widget.user.lastName);
    _emailController = TextEditingController(text: widget.user.email);
    _phoneNumberController = TextEditingController(text: widget.user.phoneNumber);
    _birthDayController = TextEditingController(
        text: widget.user.birthDay?.toLocal().toString().split(' ')[0] ?? '');
    _selectedGender = widget.user.gender;
    _selectedBirthDate = widget.user.birthDay;
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
  void _saveChanges() {
    // Update the global loggedInUser variable
 loggedInUser.firstName = _firstNameController.text;
    loggedInUser.lastName = _lastNameController.text;
    loggedInUser.phoneNumber = _phoneNumberController.text;
    loggedInUser.gender = _selectedGender!;
    loggedInUser.birthDay = _selectedBirthDate;

    // Update the UI and navigate back
    setState(() {
      _isEditing = false; // Exit edit mode
 // You might want to show a success message here
    });
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
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        actions: [          IconButton(
            icon: Icon(_isEditing ? Icons.save : Icons.edit),
            onPressed: _isEditing ? _saveChanges : _toggleEditMode,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            CircleAvatar(
              radius: 60,
              backgroundImage: widget.user.profilePictureUrl != null
                  ? NetworkImage(widget.user.profilePictureUrl!)
                  : const AssetImage('assets/placeholder.png')
                      as ImageProvider,
            ),
            const SizedBox(height: 20),
            TextFormField(
              controller: _firstNameController,
              enabled: _isEditing,
              decoration: const InputDecoration(labelText: 'First Name'),
            ),
            TextFormField(
              controller: _lastNameController,
              enabled: _isEditing,
              decoration: const InputDecoration(labelText: 'Last Name'),
            ),
            TextFormField(
              controller: _emailController,
              enabled: false,
              decoration: const InputDecoration(labelText: 'Email'),
            ),
            TextFormField(
              controller: _phoneNumberController,
              enabled: _isEditing,
              decoration: const InputDecoration(labelText: 'Phone Number'),
            ),
            GestureDetector(
              onTap: _isEditing ? () => _selectDate(context) : null,
              child: AbsorbPointer(
                child: TextFormField(
                  controller: _birthDayController,
                  enabled: _isEditing,
                  decoration: const InputDecoration(labelText: 'Birth Day'),
                ),
              ),
            ),
            DropdownButtonFormField<String>(
              value: _selectedGender,
              items: const [
                DropdownMenuItem(value: 'Male', child: Text('Male')),
                DropdownMenuItem(value: 'Female', child: Text('Female')),
              ],
              onChanged: _isEditing
                  ? (newValue) {
                      setState(() {
                        _selectedGender = newValue;
                      });
                    }
                  : null,
              decoration: const InputDecoration(labelText: 'Gender'),
            ),
          ],
        ),
      ),
    );
  }
}