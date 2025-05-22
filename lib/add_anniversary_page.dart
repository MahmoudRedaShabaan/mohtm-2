import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class AddAnniversaryPage extends StatelessWidget {
  const AddAnniversaryPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Add Anniversary')),
      body: AddAnniversaryForm(),
    );
  }
}

class AddAnniversaryForm extends StatefulWidget {
  const AddAnniversaryForm({super.key});

  @override
  _AddAnniversaryFormState createState() => _AddAnniversaryFormState();
}

class _AddAnniversaryFormState extends State<AddAnniversaryForm> {
  final _formKey = GlobalKey<FormState>();
  DateTime? _selectedDate;
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _relationshipController = TextEditingController(); // NEW
  String? _selectedType;
  String? _selectedPriority; // NEW
  final TextEditingController _otherTypeController = TextEditingController();
  final List<String> _anniversaryTypes = [
    'Wedding',
    'Death',
    'Birthday',
    'Other',
  ];

  // Priority options
  final List<String> _priorityOptions = ['High', 'Medium', 'Low'];

  // Remember Before options
  final List<String> _rememberBeforeOptions = [
    'Month',
    'Week',
    'Day',
    'Hour',
    'At time of event'
  ];
  List<String> _selectedRememberBefore = ['At time of event']; // Always selected


  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime(2100),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Form(
        key: _formKey,
        child: ListView(
          children: <Widget>[
            const SizedBox(height: 7.0),
            GestureDetector(
              onTap: () => _selectDate(context),
              child: InputDecorator(
                decoration: const InputDecoration(
                  labelText: 'Anniversary Date*',
                  border: OutlineInputBorder(),
                  focusedBorder: OutlineInputBorder(
                    // Border when the TextField is focused
                    borderSide: BorderSide(color: Colors.orange, width: 2.0),
                    borderRadius: BorderRadius.all(Radius.circular(5.0)),
                  ),
                  enabledBorder: OutlineInputBorder(
                    // Border when the TextField is enabled but not focused
                    borderSide: BorderSide(color: Colors.grey, width: 1.0),
                    borderRadius: BorderRadius.all(Radius.circular(8.0)),
                  ),
                ),
                child: Text(
                  _selectedDate == null
                      ? 'Select Date'
                      : '${_selectedDate!.toLocal()}'.split(' ')[0],
                  style: TextStyle(
                    color: _selectedDate == null ? Colors.grey[700] : null,
                  ),
                ),
              ),
              // Add validator to InputDecorator to validate date
              // InputDecorator does not have a validator property directly.
              // Validation for date is handled in the ElevatedButton onPressed.
            ),
            const SizedBox(height: 7.0),
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Name',
                hintText: 'Enter name of Anniversary',
                border: OutlineInputBorder(),
                focusedBorder: OutlineInputBorder(
                  // Border when the TextField is focused
                  borderSide: BorderSide(color: Colors.orange, width: 2.0),
                  borderRadius: BorderRadius.all(Radius.circular(5.0)),
                ),
                enabledBorder: OutlineInputBorder(
                  // Border when the TextField is enabled but not focused
                  borderSide: BorderSide(color: Colors.grey, width: 1.0),
                  borderRadius: BorderRadius.all(Radius.circular(8.0)),
                ),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter the anniversary name';
                }
                return null;
              },
            ),
            const SizedBox(height: 7.0),
            TextFormField(
              controller: _descriptionController,
              decoration: const InputDecoration(
                labelText: 'Description',
                border: OutlineInputBorder(),
                focusedBorder: OutlineInputBorder(
                  // Border when the TextField is focused
                  borderSide: BorderSide(color: Colors.orange, width: 2.0),
                  borderRadius: BorderRadius.all(Radius.circular(5.0)),
                ),
                enabledBorder: OutlineInputBorder(
                  // Border when the TextField is enabled but not focused
                  borderSide: BorderSide(color: Colors.grey, width: 1.0),
                  borderRadius: BorderRadius.all(Radius.circular(8.0)),
                ),
              ),
              maxLines: 3,
              maxLength: 200,
            ),
          //  const SizedBox(height: 7.0),
            DropdownButtonFormField<String>(
              decoration: const InputDecoration(
                labelText: 'Type*',
                border: OutlineInputBorder(),
                focusedBorder: OutlineInputBorder(
                  // Border when the TextField is focused
                  borderSide: BorderSide(color: Colors.orange, width: 2.0),
                  borderRadius: BorderRadius.all(Radius.circular(5.0)),
                ),
                enabledBorder: OutlineInputBorder(
                  // Border when the TextField is enabled but not focused
                  borderSide: BorderSide(color: Colors.grey, width: 1.0),
                  borderRadius: BorderRadius.all(Radius.circular(8.0)),
                ),
              ),
              value: _selectedType,
              onChanged: (String? newValue) {
                setState(() {
                  _selectedType = newValue;
                });
              },
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please select the anniversary type';
                }
                return null;
              },
              items:
                  _anniversaryTypes.map<DropdownMenuItem<String>>((
                    String value,
                  ) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
            ),
            if (_selectedType == 'Other') ...[
              const SizedBox(height: 7.0),
              TextFormField(
                controller: _otherTypeController,
                decoration: const InputDecoration(
                  labelText: 'Specify Type*',
                  border: OutlineInputBorder(),
                  focusedBorder: OutlineInputBorder(
                    // Border when the TextField is focused
                    borderSide: BorderSide(color: Colors.orange, width: 2.0),
                    borderRadius: BorderRadius.all(Radius.circular(5.0)),
                  ),
                  enabledBorder: OutlineInputBorder(
                    // Border when the TextField is enabled but not focused
                    borderSide: BorderSide(color: Colors.grey, width: 1.0),
                    borderRadius: BorderRadius.all(Radius.circular(8.0)),
                  ),
                ),
                validator: (value) {
                  if (_selectedType == 'Other' &&
                      (value == null || value.isEmpty)) {
                    return 'Please specify the anniversary type';
                  }
                  return null;
                },
              ),
            ],
            // Relationship field
            const SizedBox(height: 7.0),
            TextFormField(
              controller: _relationshipController,
              decoration: const InputDecoration(
                labelText: 'Relationship',
                hintText: 'Enter relationship',
                border: OutlineInputBorder(),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.orange, width: 2.0),
                  borderRadius: BorderRadius.all(Radius.circular(5.0)),
                ),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.grey, width: 1.0),
                  borderRadius: BorderRadius.all(Radius.circular(8.0)),
                ),
              ),
            ),
            // Priority dropdown
            const SizedBox(height: 7.0),
            DropdownButtonFormField<String>(
              decoration: const InputDecoration(
                labelText: 'Priority*',
                border: OutlineInputBorder(),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.orange, width: 2.0),
                  borderRadius: BorderRadius.all(Radius.circular(5.0)),
                ),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.grey, width: 1.0),
                  borderRadius: BorderRadius.all(Radius.circular(8.0)),
                ),
              ),
              value: _selectedPriority,
              onChanged: (String? newValue) {
                setState(() {
                  _selectedPriority = newValue;
                });
              },
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please select the priority';
                }
                return null;
              },
              items: _priorityOptions
                  .map((priority) => DropdownMenuItem<String>(
                        value: priority,
                        child: Text(priority),
                      ))
                  .toList(),
            ),
            // Remember Before multi-selection
            const SizedBox(height: 7.0),
            const Text(
              'Remember Before*',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            Column(
              children: _rememberBeforeOptions.map((option) {
                final isAtTime = option == 'At time of event';
                return CheckboxListTile(
                  title: Text(option),
                  value: _selectedRememberBefore.contains(option),
                  onChanged: isAtTime
                      ? null // Always selected and disabled
                      : (bool? checked) {
                          setState(() {
                            if (checked == true) {
                              _selectedRememberBefore.add(option);
                            } else {
                              _selectedRememberBefore.remove(option);
                            }
                          });
                        },
                  controlAffinity: ListTileControlAffinity.leading,
                );
              }).toList(),
            ),
            const SizedBox(height: 24.0),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () async {
                  if (_formKey.currentState!.validate() &&
                      _selectedDate != null) {
                    // Process the data (e.g., save to a database)
                    // Then navigate back to the home page
                    String res=await uploadTask();
                    ScaffoldMessenger.of(context).showSnackBar(
                       SnackBar(content: Text(res)),
                    );
                    if(res=="success"){
                      Navigator.pop(context);
                    }
                  }
                },
                style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30.0),
                  ),
                ),
                child: const Padding(
                  padding: EdgeInsets.symmetric(vertical: 12.0),
                  child: Text('Save', style: TextStyle(fontSize: 18)),
                ),
              ),
              //   ],
            ),
          ],
        ),
      ),
    );
  }
  Future <String> uploadTask() async{
  try {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return "User not logged in";
    }else {
      await FirebaseFirestore.instance.collection("anniversaries").add({
      "title": _nameController.text,
      "description": _descriptionController.text,
      "date": _selectedDate, // Firestore will store as Timestamp
      "type": _selectedType == 'Other' ? _otherTypeController.text : _selectedType,
      "relationship": _relationshipController.text,
      "priority": _selectedPriority,
      "rememberBefore": _selectedRememberBefore,
      "color": 0xFF000000, // Example color code
      "createdBy": user?.uid,
      "createdAt": FieldValue.serverTimestamp(),
    });
    return "success";
    }
  } catch (e) {
    print(e);
    return "Adding failed: ${e}";
  }
}
}
