import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:myapp/lookup.dart';


class AddAnniversaryPage extends StatelessWidget {
  const AddAnniversaryPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title:  Text(AppLocalizations.of(context)!.addAnniversaryTitle)),
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
  // Use eventTypes from LookupService instead of static list

  // Priority options from LookupService
  List<String> get _priorityOptions {
    final locale = Localizations.localeOf(context).languageCode;
    return LookupService().annPriorities.map<String>((priority) {
      return locale == 'ar' ? (priority['priorityAr'] ?? '') : (priority['priorityEn'] ?? '');
    }).toList();
  }

  // Remember Before options
  final List<String> _rememberBeforeOptions = [
    'Month',
    'Week',
    'Day',
    'At time of event'
  ];
  
  String _selectedRememberBefore = 'At time of event'; // Default selection


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
                decoration: InputDecoration(
                  //labelText: AppLocalizations.of(context)!.selectDateLabel,
                  border: const OutlineInputBorder(),
                  focusedBorder: const OutlineInputBorder(
                    // Border when the TextField is focused
                    borderSide: BorderSide(color: Colors.orange, width: 2.0),
                    borderRadius: BorderRadius.all(Radius.circular(5.0)),
                  ),
                  enabledBorder: const OutlineInputBorder(
                    // Border when the TextField is enabled but not focused
                    borderSide: BorderSide(color: Colors.grey, width: 1.0),
                    borderRadius: BorderRadius.all(Radius.circular(8.0)),
                  ),
                ),
                child: Text(
                  _selectedDate == null
                      ? AppLocalizations.of(context)!.selectDateLabel
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
              decoration:  InputDecoration(
                labelText: AppLocalizations.of(context)!.anniversaryNameLabel,
                hintText: AppLocalizations.of(context)!.anniversaryNameHint,
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
                  return AppLocalizations.of(context)!.anniversaryNameValidation;
                }
                return null;
              },
            ),
            const SizedBox(height: 7.0),
            TextFormField(
              controller: _descriptionController,
              decoration:  InputDecoration(
                labelText: AppLocalizations.of(context)!.anniversaryDescriptionLabel,
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
              decoration:  InputDecoration(
                labelText: AppLocalizations.of(context)!.type,
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
              value: _selectedType,
              onChanged: (String? newValue) {
                setState(() {
                  _selectedType = newValue;
                });
              },
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return AppLocalizations.of(context)!.anniversarytypeValidation;
                }
                return null;
              },
              items: LookupService().eventTypes
                  .map<DropdownMenuItem<String>>((type) {
                    final locale = Localizations.localeOf(context).languageCode;
                    final value = locale == 'ar' ? (type['arabicName'] ?? '') : (type['englishName'] ?? '');
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
            ),
            // Show specific name field if selected type is 'Other' or 'اخرى'
            if (_selectedType == 'Other' || _selectedType == 'اخرى') ...[
              const SizedBox(height: 7.0),
              TextFormField(
                controller: _otherTypeController,
                decoration:  InputDecoration(
                  labelText: AppLocalizations.of(context)!.specifyType,
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
                validator: (value) {
                  if ((_selectedType == 'Other' || _selectedType == 'اخرى') &&
                      (value == null || value.isEmpty)) {
                    return AppLocalizations.of(context)!.anniversaryOtherTypeValidation;
                  }
                  return null;
                },
              ),
            ],
            // Relationship field
            const SizedBox(height: 7.0),
            TextFormField(
              controller: _relationshipController,
              decoration:  InputDecoration(
                labelText: AppLocalizations.of(context)!.relationship,
                hintText: AppLocalizations.of(context)!.relationshipHint,
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
              decoration:  InputDecoration(
                labelText: AppLocalizations.of(context)!.priority,
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
                  return AppLocalizations.of(context)!.priorityValidation;
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
            // Remember Before radio selection
            const SizedBox(height: 7.0),
            Text(
              AppLocalizations.of(context)!.rememberBefore,
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            Column(
              children: _rememberBeforeOptions.map((option) {
                return RadioListTile<String>(
                  title: Text(option),
                  value: option,
                  groupValue: _selectedRememberBefore,
                  onChanged: (String? value) {
                    setState(() {
                      _selectedRememberBefore = value!;
                    });
                  },
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
                child:  Padding(
                  padding: EdgeInsets.symmetric(vertical: 12.0),
                  child: Text(AppLocalizations.of(context)!.save, style: TextStyle(fontSize: 18)),
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
    } else {
      // Calculate rememberBeforeDate
      DateTime? rememberBeforeDate;
      if (_selectedDate != null) {
        switch (_selectedRememberBefore) {
          case 'Month':
            rememberBeforeDate = _selectedDate!.subtract(const Duration(days: 30));
            break;
          case 'Week':
            rememberBeforeDate = _selectedDate!.subtract(const Duration(days: 7));
            break;
          case 'Day':
            rememberBeforeDate = _selectedDate!.subtract(const Duration(days: 1));
            break;
          case 'At time of event':
          default:
            rememberBeforeDate = _selectedDate;
        }
      }
      await FirebaseFirestore.instance.collection("anniversaries").add({
        "title": _nameController.text,
        "description": _descriptionController.text,
        "date": _selectedDate, // Firestore will store as Timestamp
        "type": (() {
          final locale = Localizations.localeOf(context).languageCode;
          if (locale == 'ar') {
            final typeObj = LookupService().eventTypes.firstWhere(
              (type) => type['arabicName']?.toString().trim() == _selectedType?.toString().trim(),
              orElse: () => <String, dynamic>{},
            );
            return typeObj.containsKey('id') ? typeObj['id'] : null;
          } else {
            final typeObj = LookupService().eventTypes.firstWhere(
              (type) => type['englishName']?.toString().trim() == _selectedType?.toString().trim(),
              orElse: () => <String, dynamic>{},
            );
            return typeObj.containsKey('id') ? typeObj['id'] : null;
          }
        })(),
        if (_selectedType == 'Other' || _selectedType == 'اخرى')
          "addType": _otherTypeController.text,
        "relationship": _relationshipController.text,
        "priority": (() {
          final locale = Localizations.localeOf(context).languageCode;
          final priorityObj = LookupService().annPriorities.firstWhere(
            (priority) => (locale == 'ar' ? priority['priorityAr'] : priority['priorityEn']) == _selectedPriority,
            orElse: () => <String, dynamic>{},
          );
          return priorityObj.containsKey('id') ? priorityObj['id'] : _selectedPriority;
        })(),
        "rememberBefore": _selectedRememberBefore,
        "rememberBeforeDate": rememberBeforeDate,
        "color": 0xFF000000, // Example color code
        "createdBy": user.uid,
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
